-- Customize blink.cmp keymaps: Tab accepts, Enter does NOT
return {
  "saghen/blink.cmp",
  opts = function(_, opts)
    opts.keymap = opts.keymap or {}

    -- Use the "default" preset (which does NOT bind <CR> to accept)
    -- LazyVim normally uses "enter", which makes Enter accept completions.
    opts.keymap.preset = "default"

    -- Make <Tab> accept the current completion item
    opts.keymap["<Tab>"] = { "select_and_accept", "fallback" }

    -- Optional: Shift-Tab goes to previous item
    opts.keymap["<S-Tab>"] = { "select_prev", "fallback" }

    -- Extra safety: ensure <CR> just does its normal thing (newline)
    opts.keymap["<CR>"] = { "fallback" }
  end,
}
