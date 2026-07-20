return {
  -- Core LSP UI configuration
  {
    "neovim/nvim-lspconfig",
    event = "LspAttach", -- load UI features only after LSP attaches
    init = function()
      -- Floating window border
      local orig = vim.lsp.util.open_floating_preview
      vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or "rounded"
        return orig(contents, syntax, opts, ...)
      end

      -- Diagnostics
      vim.diagnostic.config({
        virtual_text = false,
        underline = true,
        signs = true,
        severity_sort = true,
        float = { border = "rounded" },
      })

      -- Auto show diagnostics popup
      vim.api.nvim_create_autocmd("CursorHold", {
        callback = function()
          vim.diagnostic.open_float(nil, { focusable = false })
        end,
      })

      -- Inlay hints
      pcall(function()
        vim.lsp.inlay_hint.enable(true)
      end)
    end,
  },

  -- Lightbulb plugin
  {
    "kosayoda/nvim-lightbulb",
    event = "LspAttach",
    opts = { autocmd = { enabled = true }, sign = { enabled = true } },
  },

  -- LSP progress notifications
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {},
  },

  -- Breadcrumb symbols
  {
    "SmiteshP/nvim-navic",
    event = "LspAttach",
    opts = {},
  },

  -- Problems panel
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {
      focus = true,
      auto_close = true,
      auto_preview = false,
      win = { border = "rounded" },
    },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Workspace Diagnostics" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
      { "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols" },
      { "<leader>cl", "<cmd>Trouble lsp toggle<cr>", desc = "LSP List" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List" },
    },
  },
}
