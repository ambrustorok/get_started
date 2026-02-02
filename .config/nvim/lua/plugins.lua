return {
    -- Nvim-Tree configuration
    {
        'nvim-tree/nvim-tree.lua',
        version = "*",
        lazy = false, -- load during startup if it's your main file explorer
        dependencies = {
            'nvim-tree/nvim-web-devicons', -- optional, for file icons
        },
        config = function()
            require("nvim-tree").setup({
                -- Add your configuration options here if needed
            })
        end,
    },
}
