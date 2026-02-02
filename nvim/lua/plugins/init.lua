return {
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({})
    end,
  },

  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    lazy = false,
    config = function()
      require("mason").setup()
      local ok, lsp_setup = pcall(require, "lsp_setup")
      if ok then
        lsp_setup.setup()
      else
        vim.notify("Failed to load lsp_setup: " .. lsp_setup, vim.log.levels.ERROR)
      end
    end,
  },
}
