-- ~/.config/nvim/lua/mappings.lua

local map = vim.keymap.set

-- Toggle file tree
map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { noremap = true, silent = true, desc = "Toggle file tree" })

-- Diagnostics helpers
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- Explicit clipboard yanks: keep `y` local, use `Y` for the system clipboard.
map("n", "Y", '"+yy', { noremap = true, silent = true, desc = "Yank line to system clipboard" })
map("x", "Y", '"+y', { noremap = true, silent = true, desc = "Yank selection to system clipboard" })

-- Git UI
map("n", "<leader>gg", "<cmd>LazyGit<CR>", { noremap = true, silent = true, desc = "Open LazyGit" })
map("n", "<leader>gf", "<cmd>LazyGitCurrentFile<CR>", { noremap = true, silent = true, desc = "Open LazyGit for current file" })
