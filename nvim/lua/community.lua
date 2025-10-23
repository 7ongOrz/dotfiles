-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",

  -- === 编程语言包 ===
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.python" },
  { import = "astrocommunity.pack.cpp" },
  { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.pack.cmake" },

  -- === 重量级语言包（暂时注释，需要时再启用）===
  -- { import = "astrocommunity.pack.rust" },        -- 🔴 ~200MB (rust-analyzer)
  -- { import = "astrocommunity.pack.go" },          -- 🔴 ~100MB (gopls)
  -- { import = "astrocommunity.pack.typescript" },  -- 🔴 ~120MB (tsserver + 多个工具)

  -- === Web 前端（暂时注释）===
  -- { import = "astrocommunity.pack.html-css" },    -- 🔴 ~80MB (多个 LSP)

  -- === 配置文件 ===
  { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.markdown" },
  { import = "astrocommunity.pack.yaml" },
  { import = "astrocommunity.pack.toml" },

  -- === 编辑器增强 ===
  { import = "astrocommunity.motion.flash-nvim" },

  -- === 终端集成 ===
  { import = "astrocommunity.terminal-integration.vim-tmux-navigator" },
  -- { import = "astrocommunity.terminal-integration.vim-tmux-yank" },  -- 🔴 在非tmux环境中会创建异常文件
  { import = "astrocommunity.terminal-integration.vim-tpipeline" },     -- ✅ 基础配置，与自定义配置互补

  -- === Git 工具 ===
  { import = "astrocommunity.git.git-blame-nvim" },

  -- === 补全引擎 ===
  { import = "astrocommunity.completion.blink-cmp" },

  -- === 缩进工具 ===
  { import = "astrocommunity.indent.indent-tools-nvim" },
  { import = "astrocommunity.indent.indent-blankline-nvim" },

  -- import/override with your plugins folder
}
