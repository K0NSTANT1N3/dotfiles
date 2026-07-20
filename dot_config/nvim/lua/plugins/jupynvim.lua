return {
  {
    "sheng-tse/jupynvim",
    -- Lazily load the plugin ONLY when an ipynb filetype is detected
    ft = { "ipynb" },
    init = function()
      vim.filetype.add({
        extension = {
          ipynb = "ipynb",
        },
      })
    end,
    config = function()
      local jupynvim = require("jupynvim")
      jupynvim.setup({
        -- Terminal notebook image rendering. In tmux this also needs:
        -- set -g allow-passthrough on
        image_renderer = "placeholder",
        image_rows = 24,
        image_cols = 80,
        log_level = "info",
      })

      -- Emergency manual trigger in case the buffer does not attach automatically.
      vim.api.nvim_create_user_command("Jupy", function()
        jupynvim.attach()
      end, {})
    end,
  },
}
