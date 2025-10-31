-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Create MasonInstallAll command for Docker builds
-- MasonInstall runs in blocking/synchronous mode when no UI is attached (headless mode)
vim.api.nvim_create_user_command("MasonInstallAll", function()
  local lazy_config = require("lazy.core.config")
  local installer = lazy_config.plugins["mason-tool-installer.nvim"]

  if installer and installer._.cache and installer._.cache.opts then
    local tools = installer._.cache.opts.ensure_installed or {}
    if #tools > 0 then
      vim.cmd("MasonInstall " .. table.concat(tools, " "))
    else
      vim.notify("No tools configured in mason-tool-installer ensure_installed", vim.log.levels.WARN)
    end
  else
    vim.notify("mason-tool-installer.nvim not configured", vim.log.levels.ERROR)
  end
end, { desc = "Install all mason tools (blocking in headless mode)" })