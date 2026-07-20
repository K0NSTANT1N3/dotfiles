return {
  {
    "meanderingprogrammer/render-markdown.nvim",
    dependencies = { 
      "nvim-treesitter/nvim-treesitter", 
      "nvim-mini/mini.icons" -- Updated repository path
    },
    opts = {
      -- Keeps code block languages highlighted inside the render
      anti_cheat = { enabled = false }, 
    },
    ft = { "markdown" },
    config = function(_, opts)
      require("render-markdown").setup(opts)
      
      -- Create a user command to easily toggle a single buffer
      vim.api.nvim_create_user_command("RenderToggle", function()
        require("render-markdown").toggle()
      end, {})
    end,
  },
}

