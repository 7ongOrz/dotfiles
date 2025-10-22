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
        -- ===== 语言服务器 =====
        -- Python, C++, CMake LSP 已由社区包自动安装
        -- basedpyright - 由 astrocommunity.pack.python 提供
        -- clangd - 由 astrocommunity.pack.cpp 提供
        -- neocmakelsp - 由 astrocommunity.pack.cmake 提供

        "lua-language-server", -- Lua LSP
        "bash-language-server", -- Bash LSP

        -- ===== 格式化工具 =====
        -- black, isort - 由 astrocommunity.pack.python 提供
        "stylua", -- Lua formatter

        -- ===== 调试器 =====
        -- debugpy - 由 astrocommunity.pack.python 提供
        -- codelldb - 由 astrocommunity.pack.cpp 提供

        -- ===== 其他工具 =====
        "tree-sitter-cli",
      },
    },
  },
}
