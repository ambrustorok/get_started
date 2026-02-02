-- ~/.config/nvim/init.lua

-- Leader must be defined before plugins
vim.g.mapleader = " "

-- Basic editor settings
local opt = vim.opt
opt.number = true
opt.relativenumber = true
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
opt.clipboard:append({ "unnamedplus" })

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
