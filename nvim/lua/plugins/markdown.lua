return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    -- nvim-treesitter v1 has no `configs` module; setup() lives on the main module.
    -- Parsers are declared here and installed via :TSUpdate / the build step.
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = { "markdown", "markdown_inline" },
      })
    end,
  },

  {
    "OXY2DEV/markview.nvim",
    -- Must NOT be lazy-loaded: the plugin handles its own lazy attachment internally.
    lazy = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("markview").setup({
        preview = {
          icon_provider = "devicons",
        },
      })

      -- <leader>tp  →  toggle the split preview pane
      vim.keymap.set("n", "<leader>tp", function()
        vim.cmd("Markview splitToggle")
      end, { desc = "Toggle markdown split preview" })

      -- <leader>tm  →  toggle in-buffer rendering on/off
      vim.keymap.set("n", "<leader>tm", function()
        vim.cmd("Markview Toggle")
      end, { desc = "Toggle markdown rendering" })
    end,
  },
}
