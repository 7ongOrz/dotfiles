# dotfiles

个人开发环境配置文件

## 包含配置

- **Neovim** - 基于 AstroNvim v5+ 的现代编辑器配置
- **Tmux** - 终端复用器配置，使用 TPM 管理插件

## 快速开始

### Neovim

```bash
# 链接配置到标准路径
ln -s $(pwd)/nvim ~/.config/nvim

# 启动 Neovim，自动安装插件
nvim
```

### Tmux

```bash
# 链接配置
ln -s $(pwd)/tmux ~/.config/tmux

# 初始化子模块（TPM 插件管理器）
git submodule update --init --recursive

# 在 tmux 中按 Prefix + I 安装插件（Prefix 默认为 Ctrl-a）
```

## 语言支持

支持 15+ 种编程语言的 LSP、格式化和语法高亮：

**系统编程**: C, C++, Rust
**后端开发**: Python, Go
**Web 开发**: TypeScript, JavaScript, HTML, CSS
**脚本语言**: Bash, Lua
**配置文件**: JSON, YAML, TOML, Markdown, Docker
**构建工具**: CMake

## 主要特性

### Neovim
- 完整的 LSP 支持（代码补全、跳转、重构）
- TreeSitter 语法高亮和代码折叠
- 自动安装 LSP 服务器和格式化工具
- LazyGit 集成
- flash.nvim 快速跳转
- Tmux 深度集成

### Tmux
- 自定义前缀键 (Ctrl-a)
- Vi 模式按键绑定
- 会话持久化（tmux-resurrect）
- 丰富的插件生态

## License

MIT
