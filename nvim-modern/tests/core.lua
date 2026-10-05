-- Offline tests: no plugin downloads, no project dependency installation.
local config = assert(vim.env.MODERN_CONFIG)
vim.opt.runtimepath:prepend(config)
package.path = config .. "/lua/?.lua;" .. config .. "/lua/?/init.lua;" .. package.path
local count = 0
local function eq(expected, actual, message)
  assert(
    vim.deep_equal(expected, actual),
    message .. ": expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual)
  )
  count = count + 1
end
local temp = vim.fn.tempname()
vim.fn.mkdir(temp, "p")
local function file(name, text)
  vim.fn.mkdir(vim.fs.dirname(name), "p")
  vim.fn.writefile(vim.split(text or "", "\n"), name)
end
local function bin(name, version)
  file(name, "#!/bin/sh\nprintf 'Version " .. version .. "\\n'\n")
  vim.fn.setfperm(name, "rwxr-xr-x")
end
local ts = require("editor.typescript")
local root = temp .. "/project"
file(root .. "/.git/HEAD")
file(root .. "/package.json", "{}")
file(root .. "/pnpm-lock.yaml")
file(root .. "/packages/app/src/main.ts")
local source = root .. "/packages/app/src/main.ts"
eq("ts_ls", ts.resolve(source).mode, "Normal project uses fallback")
eq(root, ts.resolve(source).root, "Workspace lock is the root")
file(root .. "/packages/app/node_modules/typescript/lib/tsserver.js")
bin(root .. "/packages/app/node_modules/.bin/tsc", "5.9.3")
eq("ts_ls", ts.resolve(source).mode, "TS5 does not pretend to speak LSP")
eq(
  root .. "/packages/app/node_modules/typescript/lib/tsserver.js",
  ts.resolve(source).tsserver,
  "Local TS SDK respected"
)
bin(root .. "/node_modules/.bin/tsgo", "7.0.2")
eq("tsc", ts.resolve(source).mode, "Parent native compiler wins over child TS5 fallback")
eq(root .. "/node_modules/.bin/tsgo", ts.resolve(source).cmd[1], "Local native compiler chosen")
file(root .. "/node_modules/@effect/tsgo/package.json", "{}")
eq(true, ts.resolve(source).effect, "Effect setup detected")
bin(root .. "/packages/app/node_modules/.bin/tsc", "7.0.2")
eq(
  root .. "/packages/app/node_modules/.bin/tsc",
  ts.resolve(source).cmd[1],
  "Closest native compiler wins"
)
eq(
  { root .. "/packages/app/node_modules/.bin/tsc", "--lsp", "--stdio" },
  ts.resolve(source).cmd,
  "Correct native LSP arguments"
)
bin(temp .. "/node_modules/.bin/oxlint", "1.0.0")
eq(nil, ts.local_bin(source, "oxlint"), "Never cross Git boundary for tools")
bin(root .. "/node_modules/.bin/oxlint", "1.0.0")
eq(root .. "/node_modules/.bin/oxlint", ts.local_bin(source, "oxlint"), "Find workspace linter")
local plain = temp .. "/plain"
file(plain .. "/package.json", "{}")
file(plain .. "/src/file.ts")
eq(plain, ts.resolve(plain .. "/src/file.ts").root, "Non-Git project root")
local guide = require("editor.guide")
local ran = 0
guide.add({
  id = "visible",
  title = "Visible",
  help = "Test",
  remind = true,
  run = function()
    ran = ran + 1
  end,
})
guide.add({
  id = "hidden",
  title = "Hidden",
  help = "Test",
  remind = true,
  available = function()
    return false, "No capability"
  end,
  run = function()
    error("Must not run")
  end,
})
guide.add({
  id = "broken",
  title = "Broken provider",
  help = "Test",
  available = function()
    error("Provider failed")
  end,
  run = function()
    error("Must not run")
  end,
})
eq(1, #guide.list(false), "Context only lists available actions")
eq(3, #guide.list(true), "All features includes unavailable actions")
eq(false, guide.available(guide.actions[3]), "Broken provider does not break guide")
eq("visible", guide.next_tip().id, "Remind about unused available features")
guide.run(guide.actions[1])
eq(1, ran, "Action executed")
eq(nil, guide.next_tip(), "Used feature no longer nags")
guide.reminders("off")
eq(nil, guide.next_tip(os.time() + 30 * 86400), "Disabled reminders")
guide.reminders("reset")
guide.tip = guide.actions[1]
guide.reminders("dismiss")
eq(nil, guide.next_tip(), "Dismiss persists for feature")
guide.reminders("reset")
guide.reminders("snooze")
eq(nil, guide.next_tip(), "Snooze suppresses reminders")
guide.reminders("on")
eq("visible", guide.next_tip().id, "On clears snooze")
guide.tip = { title = "100% useful", key = "<leader>?" }
eq("Tip: 100%% useful (<leader>?)", guide.status(), "Statusline escapes percent signs")
-- Corrupt persisted counters must not break CursorHold.
local state_path = vim.fn.stdpath("state") .. "/editor-guide.json"
file(state_path, '{"used":{"visible":"bad"},"shown":{"visible":{}},"enabled":true}')
guide.setup()
eq("visible", guide.next_tip().id, "Invalid counter types ignored")
vim.fn.delete(temp, "rf")
print(("Core tests: %d assertions passed"):format(count))
