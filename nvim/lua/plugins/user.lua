-- Custom user plugins and plugin overrides

---@type LazySpec
return {

  -- == Discord Rich Presence ==
  "andweeb/presence.nvim",

  -- == LSP Signature Helper ==
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function()
      require("lsp_signature").setup()
    end,
  },

  -- == Custom Dashboard ==
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = table.concat({
            " █████  ███████ ████████ ██████   ██████ ",
            "██   ██ ██         ██    ██   ██ ██    ██",
            "███████ ███████    ██    ██████  ██    ██",
            "██   ██      ██    ██    ██   ██ ██    ██",
            "██   ██ ███████    ██    ██   ██  ██████ ",
            "",
            "███    ██ ██    ██ ██ ███    ███",
            "████   ██ ██    ██ ██ ████  ████",
            "██ ██  ██ ██    ██ ██ ██ ████ ██",
            "██  ██ ██  ██  ██  ██ ██  ██  ██",
            "██   ████   ████   ██ ██      ██",
          }, "\n"),
        },
      },
    },
  },

  -- == Disable Better Escape ==
  { "max397574/better-escape.nvim", enabled = false },

  -- == LuaSnip Customization ==
  {
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
      -- 调用 AstroNvim 默认配置（处理 vscode/snipmate/lua 加载器）
      require("astronvim.plugins.configs.luasnip")(plugin, opts)

      -- 扩展文件类型片段
      local luasnip = require("luasnip")
      luasnip.filetype_extend("javascript", { "javascriptreact" })
    end,
  },

  -- == Autopairs Customization ==
  {
    "windwp/nvim-autopairs",
    config = function(plugin, opts)
      -- 调用 AstroNvim 默认配置
      require("astronvim.plugins.configs.nvim-autopairs")(plugin, opts)

      -- 添加自定义配对规则
      local npairs = require("nvim-autopairs")
      local Rule = require("nvim-autopairs.rule")
      local cond = require("nvim-autopairs.conds")

      npairs.add_rules({
        -- LaTeX 中的 $ 符号配对
        Rule("$", "$", { "tex", "latex" })
          :with_pair(cond.not_after_regex("%%")) -- 在 %% 后不配对
          :with_move(cond.none()) -- 不移动光标
          :with_cr(cond.none()), -- 不在换行时触发
      })
    end,
  },
}
