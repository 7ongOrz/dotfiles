-- Customize Mason

---@type LazySpec
return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
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
    config = function(_, opts)
      require("mason-tool-installer").setup(opts)

      -- Create MasonInstallAll command for headless installation
      -- MasonInstall runs in blocking/synchronous mode when no UI is attached (headless mode)
      vim.api.nvim_create_user_command("MasonInstallAll", function()
        vim.cmd("MasonInstall " .. table.concat(opts.ensure_installed, " "))
      end, { desc = "Install all mason tools (blocking in headless mode)" })
    end,
  },
}
