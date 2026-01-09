-- Customize Mason

---@type LazySpec
return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    commit = "517ef5994ef9d6b738322664d5fdd948f0fdeb46",
    -- overrides `require("mason-tool-installer").setup(...)`
    opts = {
      -- Make sure to use the names found in `:Mason`
      ensure_installed = {
        "lua-language-server",
        "bash-language-server",
        "pyright", -- lightweight Python LSP with formatting support
        "stylua",
        "tree-sitter-cli",
      },
      -- Disable auto-install during Docker build to avoid interruption
      -- Tools will auto-install on first container startup
      run_on_start = vim.env.DOCKER_BUILD ~= "1",
    },
    -- Extend AstroNvim's default config instead of replacing it
    config = function(plugin, opts)
      -- Call AstroNvim's default config (handles run_on_start correctly)
      require("astronvim.plugins.configs.mason-tool-installer")(plugin, opts)

      -- Add custom command for Docker builds
      -- MasonInstall runs in blocking/synchronous mode when no UI is attached (headless mode)
      vim.api.nvim_create_user_command("MasonInstallAll", function()
        vim.cmd("MasonInstall " .. table.concat(opts.ensure_installed, " "))
      end, { desc = "Install all mason tools (blocking in headless mode)" })
    end,
  },
}
