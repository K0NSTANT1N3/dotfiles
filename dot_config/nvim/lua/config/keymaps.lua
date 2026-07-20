-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("i", "zx", "<Esc>", { desc = "Esc (Colemak zx)" })
vim.keymap.set("i", "ZX", "<Esc>", { desc = "Esc (Colemak zx)" })
vim.keymap.set("v", "zx", "<Esc>", { desc = "Esc (Colemak zx)" })
vim.keymap.set("v", "ZX", "<Esc>", { desc = "Esc (Colemak zx)" })

vim.keymap.set("n", "<leader>rr", vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set({ "n", "v" }, "<leader>ra", vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set({ "n", "v" }, "<C-S-l>", vim.lsp.buf.code_action, { desc = "Code action" })

vim.keymap.set("n", "<leader>ro", function()
    vim.lsp.buf.code_action({
        apply = true,
        context = {
            only = { "source.organizeImports" },
            diagnostics = {},
        },
    })
end, { desc = "Organize imports" })

vim.keymap.set("n", "<leader>rf", function()
    vim.lsp.buf.code_action({
        apply = true,
        context = {
            only = { "source.fixAll" },
            diagnostics = {},
        },
    })
end, { desc = "Fix all" })

vim.keymap.set({ "n", "v" }, "<leader>rF", function()
    require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format manually" })
