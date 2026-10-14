-- A small list of actions shared by mappings, the palette and reminders.
-- Providers are plain functions; there is no plugin discovery framework.
local M = { actions = {}, tip = nil }
local state = { used = {}, shown = {}, dismissed = {}, snoozed_until = 0, enabled = true }
local session_started = os.time()
local last_tip = 0
local path = vim.fn.stdpath("state") .. "/editor-guide.json"

local function save()
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  local ok = pcall(vim.fn.writefile, { vim.json.encode(state) }, path .. ".tmp")
  if ok then
    vim.uv.fs_rename(path .. ".tmp", path)
  end
end

function M.available(action)
  if not action.available then
    return true
  end
  local ok, available, reason = pcall(action.available)
  if not ok then
    return false, "Provider unavailable: " .. tostring(available)
  end
  return available, reason
end

function M.run(action)
  local available, reason = M.available(action)
  if not available then
    vim.notify(reason or action.help, vim.log.levels.INFO)
    return
  end
  state.used[action.id] = os.time()
  if M.tip and M.tip.id == action.id then
    M.tip = nil
  end
  local ok, err = pcall(action.run)
  if not ok then
    vim.notify(action.title .. ": " .. tostring(err), vim.log.levels.ERROR)
  end
end

function M.add(action)
  table.insert(M.actions, action)
  if action.key then
    vim.keymap.set(action.mode or "n", action.key, function()
      M.run(action)
    end, { desc = action.title })
  end
end

function M.list(all)
  local items = {}
  for _, action in ipairs(M.actions) do
    local available, reason = M.available(action)
    if all or available then
      items[#items + 1] = {
        action = action,
        text = ("%s  %s — %s%s"):format(
          action.title,
          action.key or "",
          action.help,
          available and "" or (" [unavailable: " .. (reason or "see help") .. "]")
        ),
      }
    end
  end
  return items
end

function M.palette(all)
  -- Availability is captured before entering the picker; actions execute back
  -- in the original buffer after it closes.
  local items = M.list(all)
  local mode = vim.fn.mode()
  local selection
  if mode == "v" or mode == "V" or mode == "\22" then
    selection = { start = vim.fn.getpos("v"), finish = vim.fn.getpos("."), mode = mode }
  end
  local ok, pick = pcall(require, "mini.pick")
  if not ok then
    vim.ui.select(items, {
      prompt = "Editor actions",
      format_item = function(item)
        return item.text
      end,
    }, function(item)
      if item then
        M.run(item.action)
      end
    end)
    return
  end
  pick.start({
    source = {
      name = all and "All editor features" or "What can I do here?",
      items = items,
      choose = function(item)
        vim.schedule(function()
          if selection then
            vim.fn.setpos(".", selection.start)
            vim.cmd("normal! " .. selection.mode)
            vim.fn.setpos(".", selection.finish)
          end
          M.run(item.action)
        end)
      end,
    },
  })
end

function M.help()
  local lines = {
    "# Your editor",
    "",
    "Space ? : contextual actions    Space h a : all features    Space h k : keys",
    "Select an action to run it. Unavailable actions explain what is missing.",
    "",
    "## Language servers in this buffer",
    "",
  }
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    lines[#lines + 1] = "None attached; open code and check Space u h / :Mason."
  end
  for _, client in ipairs(clients) do
    local provider = client.server_capabilities.codeActionProvider
    local kinds = type(provider) == "table" and provider.codeActionKinds or {}
    lines[#lines + 1] = "- "
      .. client.name
      .. (#kinds > 0 and (": " .. table.concat(kinds, ", ")) or "")
  end
  lines[#lines + 1] = ""
  lines[#lines + 1] =
    "gra requests actual cursor/selection actions; Space c s requests whole-file source actions."
  lines[#lines + 1] = ""
  lines[#lines + 1] = "## Features"
  lines[#lines + 1] = ""
  for _, item in ipairs(M.list(true)) do
    lines[#lines + 1] = "- " .. item.text
  end
  vim.cmd("botright new")
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype, vim.bo[buf].bufhidden, vim.bo[buf].swapfile = "nofile", "wipe", false
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype, vim.bo[buf].modifiable = "markdown", false
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, desc = "Close guide" })
end

function M.next_tip(now)
  now = now or os.time()
  if not state.enabled or now < state.snoozed_until then
    return nil
  end
  for _, action in ipairs(M.actions) do
    local used = state.used[action.id]
    local shown = state.shown[action.id]
    if type(used) ~= "number" then
      used = nil
    end
    if type(shown) ~= "number" then
      shown = nil
    end
    if
      action.remind
      and not state.dismissed[action.id]
      and (not used or now - used >= 14 * 86400)
      and (not shown or now - shown >= 7 * 86400)
      and M.available(action)
    then
      return action
    end
  end
end

function M.status()
  if not M.tip then
    return ""
  end
  return ("Tip: %s (%s)"):format(M.tip.title, M.tip.key or ":EditorFeatures"):gsub("%%", "%%%%")
end

function M.reminders(arg)
  if arg == "off" then
    state.enabled = false
  elseif arg == "on" then
    state.enabled = true
    state.snoozed_until = 0
  elseif arg == "snooze" then
    state.snoozed_until = os.time() + 86400
  elseif arg == "dismiss" and M.tip then
    state.dismissed[M.tip.id] = true
  elseif arg == "reset" then
    state = { used = {}, shown = {}, dismissed = {}, enabled = true, snoozed_until = 0 }
  end
  M.tip = nil
  save()
end

function M.setup()
  local ok, value = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
  end)
  if ok and type(value) == "table" then
    -- Ignore corrupt state instead of breaking editor startup.
    if type(value.used) == "table" then
      state.used = value.used
    end
    if type(value.dismissed) == "table" then
      state.dismissed = value.dismissed
    end
    if type(value.shown) == "table" then
      state.shown = value.shown
    end
    if type(value.snoozed_until) == "number" then
      state.snoozed_until = value.snoozed_until
    end
    if type(value.enabled) == "boolean" then
      state.enabled = value.enabled
    end
  end
  vim.keymap.set({ "n", "x" }, "<leader>?", function()
    M.palette(false)
  end, { desc = "What can I do here?" })
  vim.keymap.set("n", "<leader>ha", function()
    M.palette(true)
  end, { desc = "All features (including missing tools)" })
  vim.keymap.set("n", "<leader>hh", M.help, { desc = "Editor guide" })
  vim.keymap.set("n", "<leader>hk", function()
    require("which-key").show()
  end, { desc = "Show keybindings" })
  vim.keymap.set("n", "<leader>hd", function()
    M.reminders("dismiss")
  end, { desc = "Dismiss current reminder" })
  vim.keymap.set("n", "<leader>hs", function()
    M.reminders("snooze")
  end, { desc = "Snooze reminders for a day" })
  vim.api.nvim_create_user_command("EditorFeatures", function(opts)
    M.palette(opts.bang)
  end, { bang = true })
  vim.api.nvim_create_user_command("EditorHelp", M.help, {})
  vim.api.nvim_create_user_command("EditorReminders", function(opts)
    M.reminders(opts.args)
  end, {
    nargs = 1,
    complete = function()
      return { "on", "off", "snooze", "dismiss", "reset" }
    end,
  })
  vim.api.nvim_create_user_command("EditorHealth", function()
    vim.g.editor_health_buf = vim.api.nvim_get_current_buf()
    vim.cmd("checkhealth editor")
  end, {})
  vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
      local now = os.time()
      if
        #vim.api.nvim_list_uis() == 0
        or vim.bo.buftype ~= ""
        or vim.fn.mode() ~= "n"
        or now - session_started < 60
        or now - last_tip < 600
      then
        return
      end
      M.tip = M.next_tip(now)
      if M.tip then
        state.shown[M.tip.id] = now
      end
      last_tip = now
      vim.cmd.redrawstatus()
    end,
  })
  vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
      if M.tip and not M.available(M.tip) then
        M.tip = nil
        vim.cmd.redrawstatus()
      end
    end,
  })
  vim.api.nvim_create_autocmd("VimLeavePre", { callback = save })
end
return M
