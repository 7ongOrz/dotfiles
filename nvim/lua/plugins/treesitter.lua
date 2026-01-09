-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  build = ":TSUpdate",
  opts = {
    -- Enable sync_install only during Docker build to avoid slow installations on dev machines
    sync_install = vim.env.DOCKER_BUILD == "1",
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
