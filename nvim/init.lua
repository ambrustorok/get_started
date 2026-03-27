-- ~/.config/nvim/init.lua

-- Leader must be defined before plugins
vim.g.mapleader = " "

-- Basic editor settings
local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.mouse = "a"
opt.termguicolors = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.splitbelow = true
opt.splitright = true
opt.ignorecase = true
opt.smartcase = true
opt.clipboard = ""

local function set_match_highlights()
  vim.api.nvim_set_hl(0, "TrailingWhitespace", { bg = "#5f0000" })
  vim.api.nvim_set_hl(0, "NonAsciiCharacter", { bg = "#3b2f00", fg = "#ffd75f", underline = true })
end

local function refresh_window_matches()
  if vim.bo.buftype ~= "" then
    return
  end

  if vim.w.trailing_whitespace_match then
    pcall(vim.fn.matchdelete, vim.w.trailing_whitespace_match)
  end
  if vim.w.non_ascii_match then
    pcall(vim.fn.matchdelete, vim.w.non_ascii_match)
  end

  vim.w.trailing_whitespace_match = vim.fn.matchadd("TrailingWhitespace", [[\s\+$]])
  vim.w.non_ascii_match = vim.fn.matchadd("NonAsciiCharacter", [=[[^\x00-\x7F]]=])
end

set_match_highlights()

local highlight_group = vim.api.nvim_create_augroup("ConfigHighlights", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  group = highlight_group,
  callback = function()
    set_match_highlights()
    refresh_window_matches()
  end,
})

vim.api.nvim_create_autocmd({ "BufWinEnter", "InsertLeave", "WinEnter" }, {
  group = highlight_group,
  callback = refresh_window_matches,
})

-- Install package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  import = "plugins",
}, {
  change_detection = { notify = false },
})

-- Make Mason-installed binaries visible to Neovim
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

-- Load mappings (file tree + diagnostics)
local mappings_path = vim.fn.stdpath("config") .. "/lua/mappings.lua"
local ok, err = pcall(dofile, mappings_path)
if not ok then
  vim.notify("Failed to load mappings: " .. err, vim.log.levels.ERROR)
end
