-- Customize Treesitter

---@type LazySpec
return {
  "AstroNvim/astrocore",
  opts = {
    treesitter = {
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
        "markdown",
        "yaml",
        "toml",
      },
    },
  },
}
