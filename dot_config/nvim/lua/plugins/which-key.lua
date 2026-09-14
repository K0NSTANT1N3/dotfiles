return {
  {
    "folke/which-key.nvim",
    config = function(_, opts)
      local which_key = require("which-key")
      which_key.setup(opts)

      if not vim.tbl_isempty(opts.defaults) then
        LazyVim.warn("which-key: opts.defaults is deprecated. Please use opts.spec instead.")
        which_key.register(opts.defaults)
      end

      -- which-key reads continuation keys with getcharstr(), bypassing
      -- 'langmap'. Translate that single input stream so every leader, g, z,
      -- operator, and other multi-key sequence keeps its QWERTY positions.
      local state = require("which-key.state")
      if not state._physical_qwerty_getchar then
        local original_getchar = state.getchar
        state.getchar = function()
          local ok, key = original_getchar()
          if ok then
            key = require("config.keyboard_layout").translate_key(key, vim.api.nvim_get_mode().mode)
          end
          return ok, key
        end
        state._physical_qwerty_getchar = true
      end
    end,
  },
}
