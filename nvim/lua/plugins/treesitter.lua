-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "cmake",
      "python",
      "cpp",
      "c",
      "bash",
      "dockerfile",
      "json",
      "jsonc",
      "markdown",
      "yaml",
      "toml",
      -- add more arguments for adding more treesitter parsers
    },
  },
}
