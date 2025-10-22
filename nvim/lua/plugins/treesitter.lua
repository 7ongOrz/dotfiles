-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main", -- 使用 main 分支而不是已归档的 master 分支
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "cmake", -- CMake syntax highlighting
      "python", -- Python syntax highlighting
      "cpp", -- C++ syntax highlighting
      "c", -- C syntax highlighting
      "bash", -- Bash syntax highlighting
      "json", -- JSON syntax highlighting
      "jsonc", -- JSON with comments syntax highlighting
      "markdown", -- Markdown syntax highlighting
      -- add more arguments for adding more treesitter parsers
    },
  },
}
