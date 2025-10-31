# Docker 构建 AstroNvim 配置时的 Mason 安装问题及解决方案

## 问题描述

在 Dockerfile 中使用 headless 模式构建 AstroNvim 配置时，遇到 `MasonToolsInstall` 命令需要 `sleep 30` 才能正确安装工具的问题。

### 原始 Dockerfile 命令

```dockerfile
RUN set -eux; \
    DOCKER_BUILD=1 nvim --headless "+Lazy! sync" +qa >/dev/null && \
    nvim --headless "+MasonToolsInstall" +"sleep 30" +qa >/dev/null; \
    rm -rf "${HOME}/.cache/nvim" "${HOME}/.local/state/nvim"
```

### 遇到的问题

1. **`MasonToolsInstallSync` 不阻塞**：虽然文档说是同步/阻塞命令，但在 Docker 环境中不工作
2. **`MasonInstallAll` 命令不存在**：第二步执行时报错 `E492: Not an editor command: MasonInstallAll`
3. **插件未安装警告**：构建过程中出现以下警告：
   ```
   Error detected while processing /root/dotfiles/nvim/init.lua:
   Plugin nvim-treesitter-textobjects is not installed
   Plugin mason.nvim is not installed
   Pinned versions of core plugins may have been updated
   Run `:Lazy update` again to get these updates.
   ```
4. **开发机自动安装失效**：添加自定义 `config` 函数后，开发机正常启动时不会自动安装 Mason 工具
   - **根因**：自定义 `config` 覆盖了 AstroNvim 默认 config，缺少 `run_on_start()` 方法调用
   - 参考：[lazy.nvim #1082](https://github.com/folke/lazy.nvim/discussions/1082) - 只会执行最后一个 config 函数
   - 参考：[mason-tool-installer #37](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim/issues/37) - 延迟加载插件错过 VimEnter 事件

## 问题根源分析

### 1. `MasonToolsInstallSync` 为什么不可靠

根据社区讨论和搜索结果：

- **mason-tool-installer.nvim 的 `MasonToolsInstallSync`** 虽然设计为阻塞命令，但在 Docker headless 环境中可能不完全阻塞
- 参考：[mason.nvim Issue #467](https://github.com/williamboman/mason.nvim/issues/467) - 讨论了自动化 mason 安装的挑战
- 参考：[mason.nvim Discussion #1590](https://github.com/williamboman/mason.nvim/discussions/1590) - 关于在 headless 模式下自动安装 LSP 服务器的讨论

**核心发现**：Mason 的原生 `:MasonInstall` 命令在 headless 模式（没有 UI）下会**自动以同步/阻塞模式运行**，这是 Mason 官方的设计。

来源：[mason.nvim Issue #467 评论](https://github.com/williamboman/mason.nvim/issues/467)
> `:MasonInstall` runs in blocking/synchronous mode when no UIs are attached (i.e. nvim --headless)

### 2. `MasonInstallAll` 命令的来源

`MasonInstallAll` **不是官方命令**，而是社区常用的自定义命令：

- **NvChad** 提供了这个命令作为内置功能
- 参考：[mason.nvim Discussion #1618](https://github.com/williamboman/mason.nvim/discussions/1618) - 讨论了为什么 MasonInstallAll 不存在
- **AstroNvim、LazyVim** 等框架没有提供此命令，需要用户自己创建

### 3. 插件未安装警告的本质

经过本地测试验证：

- 这些警告出现在 **`Lazy! sync` 构建过程中**
- 时机：treesitter 编译 parsers 完成后，但其他插件还在并行下载中
- **最终状态**：所有插件都正确安装，功能完全正常
- 参考：[astrocommunity Issue #206](https://github.com/AstroNvim/astrocommunity/issues/206) - 讨论了类似的安装警告问题
- 相关上游问题：[lazy.nvim Issue #803](https://github.com/folke/lazy.nvim/issues/803) - cache_loader 无法加载模块的问题（已在 v9.16.1 修复）

**结论**：这些是**过程中的瞬时警告**，不影响最终功能，类似于编译时的 warning。

### 4. 开发机自动安装失效的根本原因

**现象**：添加自定义 `config` 函数后，开发机正常启动时不会自动安装 Mason 工具了

**根因分析**：

1. **插件延迟加载**：`mason-tool-installer.nvim` 默认为延迟加载（`lazy: true`）
2. **`run_on_start` 依赖 VimEnter 事件**：插件在 VimEnter 事件时自动检查并安装工具
3. **自定义 config 覆盖默认行为**：添加自定义 `config` 函数后，覆盖了 AstroNvim 的默认配置
4. **错过触发时机**：延迟加载的插件在 VimEnter 之后才加载，错过了 `run_on_start` 的触发时机

**关键参考**：
- 参考：[lazy.nvim #1082](https://github.com/folke/lazy.nvim/discussions/1082) - 只会执行最后一个 config 函数
- 参考：[mason-tool-installer #37](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim/issues/37) - 延迟加载插件错过 VimEnter 事件
- AstroNvim 默认 config（`astronvim/plugins/configs/mason-tool-installer.lua`）包含 `run_on_start()` 方法调用，自定义 config 缺少此调用

**解决方案**：
- 移除自定义 `config` 函数，保留 AstroNvim 默认配置
- 在 `polish.lua` 中创建 `MasonInstallAll` 命令，避免干扰插件配置

## 解决方案

### 最终方案：在 `polish.lua` 中创建命令

#### 1. 修改 Mason 配置（`nvim/lua/plugins/mason.lua`）

```lua
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
    -- No config - use AstroNvim's default config which handles run_on_start correctly
  },
}
```

#### 2. 在 `polish.lua` 中创建命令

```lua
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
```

**设计说明**：

1. **只在一处配置工具列表**：`ensure_installed` 是唯一的配置来源
2. **利用原生 `MasonInstall` 的阻塞特性**：在 headless 模式下自动阻塞
3. **Docker 构建时禁用自动安装**：通过 `DOCKER_BUILD=1` 环境变量控制

#### 2. 修改 Dockerfile 命令

```dockerfile
RUN set -eux; \
    DOCKER_BUILD=1 nvim --headless "+Lazy! sync" +qa >/dev/null && \
    nvim --headless "+Lazy! load mason-tool-installer.nvim" "+MasonInstallAll" +qa >/dev/null; \
    rm -rf "${HOME}/.cache/nvim" "${HOME}/.local/state/nvim"
```

**关键改进**：

1. **使用 `Lazy! load mason-tool-installer.nvim`**：强制加载插件，触发配置处理并缓存，使 `polish.lua` 中的 `MasonInstallAll` 命令可以访问插件配置
2. **移除 `sleep 30`**：不再需要，因为 `MasonInstall` 在 headless 下自动阻塞

**为什么需要 `Lazy! load`？**

- 第一步 `Lazy! sync` 只是下载插件文件到磁盘
- 插件是延迟加载的，配置还没有被 Lazy.nvim 处理并缓存
- `Lazy! load` 强制加载插件，触发 Lazy.nvim 处理 `opts` 并缓存到 `_.cache.opts`
- `MasonInstallAll` 命令（在 `polish.lua` 中定义）需要从这个缓存中读取 `ensure_installed` 列表
- 参考：[lazy.nvim 文档 - `:Lazy load`](https://lazy.folke.io/usage)

### 可选方案：过滤构建日志中的警告

如果想要更清爽的构建日志，可以过滤掉那些不影响功能的警告：

```dockerfile
RUN set -eux; \
    DOCKER_BUILD=1 nvim --headless "+Lazy! sync" +qa 2>&1 | grep -v "is not installed" | grep -v "Pinned versions" || true; \
    nvim --headless "+Lazy! load mason-tool-installer.nvim" "+MasonInstallAll" +qa >/dev/null; \
    rm -rf "${HOME}/.cache/nvim" "${HOME}/.local/state/nvim"
```

或者完全静默 stderr：

```dockerfile
RUN set -eux; \
    DOCKER_BUILD=1 nvim --headless "+Lazy! sync" +qa 2>/dev/null || true; \
    nvim --headless "+Lazy! load mason-tool-installer.nvim" "+MasonInstallAll" +qa >/dev/null; \
    rm -rf "${HOME}/.cache/nvim" "${HOME}/.local/state/nvim"
```

## 技术细节

### lazy.nvim 命令对比

| 命令 | 作用 | 是否阻塞（headless） |
|------|------|---------------------|
| `:Lazy sync` | 运行 install, clean 和 update | ✅ 使用 `!` 阻塞 |
| `:Lazy install` | 只安装缺失的插件 | ✅ 使用 `!` 阻塞 |
| `:Lazy update` | 更新插件和 lockfile | ✅ 使用 `!` 阻塞 |
| `:Lazy load <plugin>` | 强制加载未加载的插件 | N/A |

参考：[lazy.nvim Usage 文档](https://lazy.folke.io/usage)

### Mason 在 headless 模式下的行为

根据 Mason 官方文档和社区讨论：

1. **原生 `:MasonInstall` 命令**在 headless 模式下自动阻塞
2. **第三方插件的 Sync 命令**可能不完全可靠
3. **推荐方式**：使用原生 `MasonInstall` + 传递工具列表

### AstroNvim 的插件管理机制

- **社区 packs**（如 `pack.lua`、`pack.cpp`）会自动引入依赖插件
- **pinned plugins 机制**：当使用版本跟踪（`version = "^5"`）时，核心插件会被 pin 到特定版本
- **首次安装时的警告**：在插件并行下载过程中，某些检查代码可能发现依赖还未完成，产生警告
- 参考：[AstroNvim 文档 - Default Plugins](https://docs.astronvim.com/reference/default_plugins/)

## 相关问题和社区讨论

### 1. mason-tool-installer.nvim 的同步问题

- 仓库：[WhoIsSethDaniel/mason-tool-installer.nvim](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim)
- 文档说明：`:MasonToolsInstallSync` 在 headless 模式下阻塞
- 实际问题：在某些 Docker 环境中可能不完全阻塞

### 2. NvChad 的 MasonInstallAll 实现

参考 NvChad 的实现方式：

```lua
{
  "williamboman/mason.nvim",
  cmd = { "Mason", "MasonInstall", "MasonInstallAll", "MasonUpdate" },
  opts = function()
    return require "plugins.configs.mason"
  end,
  config = function(_, opts)
    require("mason").setup(opts)

    vim.api.nvim_create_user_command("MasonInstallAll", function()
      vim.cmd("MasonInstall " .. table.concat(opts.ensure_installed, " "))
    end, {})

    vim.g.mason_binaries_list = opts.ensure_installed
  end,
},
```

来源：社区讨论中提到的 NvChad 配置模式

### 3. LazyVim 的解决方案

LazyVim 社区的类似讨论：
- [LazyVim Discussion #3679](https://github.com/LazyVim/LazyVim/discussions/3679) - 如何在构建脚本中完整设置 LazyVim

建议的方法：
```bash
nvim --headless '+Lazy install' +MasonInstallAll +qall
```

### 4. 其他 Docker 配置参考

- [usrbinkat/docker-lazyvim Gist](https://gist.github.com/usrbinkat/3213e3460613745dba4fe4e9bca35abb) - Docker + LazyVim 配置示例
- [Allaman/nvim Dockerfile](https://github.com/Allaman/nvim/blob/main/Dockerfile) - 简单的 `nvim --headless "+Lazy! sync" +qa` 方案

## 验证方法

### 本地测试

可以在本地模拟 Docker 的全新环境：

```bash
# 创建测试目录
mkdir -p ~/tmp/test_nvim

# 复制配置
cp -r /path/to/dotfiles/nvim ~/tmp/test_nvim/

# 模拟全新安装
cd ~/tmp/test_nvim
env XDG_CONFIG_HOME=~/tmp/test_nvim \
    XDG_DATA_HOME=~/tmp/test_nvim/data \
    XDG_STATE_HOME=~/tmp/test_nvim/state \
    XDG_CACHE_HOME=~/tmp/test_nvim/cache \
    DOCKER_BUILD=1 \
    nvim --headless "+Lazy! sync" +qa

# 检查插件是否安装
ls -la ~/tmp/test_nvim/data/nvim/lazy/ | grep -E "(treesitter-textobjects|mason)"

# 清理测试
rm -rf ~/tmp/test_nvim
```

### Docker 构建验证

构建完成后，验证功能：

```bash
# 检查 Mason 工具是否安装
docker run --rm <image> nvim --headless "+MasonLog" +qa

# 检查插件是否正常加载
docker run --rm <image> nvim --headless "+checkhealth" +qa

# 交互式测试
docker run --rm -it <image> nvim
```

## 总结

1. ✅ **不需要 `sleep 30`**：利用 Mason 原生的 headless 阻塞特性
2. ✅ **单一配置源**：工具列表只在 `ensure_installed` 中维护一次
3. ✅ **自定义命令**：创建 `MasonInstallAll` 整合到配置中
4. ✅ **使用 `Lazy! load`**：确保插件加载和命令注册
5. ✅ **警告可忽略**：构建过程中的警告不影响最终功能

## 参考资料

### 官方文档

- [lazy.nvim 官方文档](https://lazy.folke.io/)
- [mason.nvim GitHub](https://github.com/williamboman/mason.nvim)
- [AstroNvim 官方文档](https://docs.astronvim.com/)
- [mason-tool-installer.nvim](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim)

### 相关 Issues 和讨论

- [mason.nvim #467](https://github.com/williamboman/mason.nvim/issues/467) - 自动化 mason 安装过程
- [mason.nvim #1590](https://github.com/williamboman/mason.nvim/discussions/1590) - headless 模式下的自动安装
- [mason.nvim #1618](https://github.com/williamboman/mason.nvim/discussions/1618) - MasonInstallAll 缺失讨论
- [astrocommunity #206](https://github.com/AstroNvim/astrocommunity/issues/206) - 社区插件安装触发错误
- [lazy.nvim #803](https://github.com/folke/lazy.nvim/issues/803) - cache_loader 模块加载问题
- [lazy.nvim #1188](https://github.com/folke/lazy.nvim/discussions/1188) - 预安装触发讨论
- [LazyVim #3679](https://github.com/LazyVim/LazyVim/discussions/3679) - 构建脚本完整设置

### 社区资源

- [DEV.to - Mason.nvim: The Ultimate Guide](https://dev.to/ralphsebastian/masonnvim-the-ultimate-guide-to-managing-your-neovim-tooling-4520)
- [Docker + Neovim + LazyVim Gist](https://gist.github.com/usrbinkat/3213e3460613745dba4fe4e9bca35abb)

---

**文档版本**：v1.0
**最后更新**：2025-10-31
**适用配置**：AstroNvim v5+, lazy.nvim v11.17.2+
