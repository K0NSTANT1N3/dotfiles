local clangd_cmd = {
  "clangd",
  "--fallback-style=LLVM",
}

local compiler = vim.fn.exepath("g++")
if compiler ~= "" then
  table.insert(clangd_cmd, "--query-driver=" .. compiler)
end

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" }, -- load only when opening a file
    opts = {
      servers = {
        pyright = { filetypes = { "python" } },
        jdtls = { filetypes = { "java" } },
        clangd = {
          filetypes = { "c", "cpp", "objc", "objcpp" },
          cmd = clangd_cmd,
        },
      },
    },
  },
}
