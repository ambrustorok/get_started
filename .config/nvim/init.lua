-- ~/.config/nvim/init.lua

-- Install package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",  -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  import = "plugins",
}, {
  change_detection = {
    notify = false,
  },
})

-- Disable right click in all modes
for _, mode in ipairs({'n', 'i', 'v'}) do
  vim.api.nvim_set_keymap(mode, '<RightMouse>', '<Nop>', { noremap = true, silent = true })
end

-- Toggle file tree
vim.api.nvim_set_keymap('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

-- Use system clipboard
vim.opt.clipboard:append({ 'unnamedplus' })
