return {
  {
    "folke/snacks.nvim",
    opts = {
      -- Completely disables snacks' default bigfile system to stop the errors
      bigfile = { enabled = false },
      picker = {
        sources = {
          explorer = {
            layout = {
              layout = {
                width = 30,
                min_width = 30,
              },
            },
          },
        },
      },
    },
  },
}
