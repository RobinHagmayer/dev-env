-- Auto-load all Lua files from a directory
local function load_dir(dir)
  local path = vim.fn.stdpath("config") .. "/lua/" .. dir
  for _, file in ipairs(vim.fn.readdir(path)) do
    if file:match("%.lua$") then
      local module = dir:gsub("/", ".") .. "." .. file:gsub("%.lua$", "")
      require(module)
    end
  end
end

load_dir("config")
load_dir("plugins")
