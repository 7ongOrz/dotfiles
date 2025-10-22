-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  -- 最小变更：只在 init 设置 prefer_git，避免 tarball 解压
  init = function()
    require("nvim-treesitter.install").prefer_git = true
  end,
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "cmake",
      "python",
      "cpp",
      "c",
      "bash",
      "json",
      "jsonc",
      "markdown",
    },
  },
}
