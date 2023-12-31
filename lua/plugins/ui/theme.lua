return {
    {
        "lunarvim/onedarker.nvim",
        lazy = false,
        priority = 1000,
        opts = {}
    },
    {
        "lunarvim/darkplus.nvim",
        lazy = true,
    },
    {
        "navarasu/onedark.nvim",
        lazy = true,
        config = function()
            require('onedark').setup({ style = "deep" })
            -- Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
        end
    }
}
