-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.lazyvim_ruby_lsp = "ruby_lsp"
vim.g.lazyvim_ruby_formatter = "rubocop"

vim.opt.conceallevel = 0
vim.opt.spell = false
vim.opt.foldlevel = 99
vim.opt.foldenable = false
vim.opt.wrap = true

-- Claude Code CLIとの併用: CursorHold発火間隔を1秒に設定（checktimeによる外部変更検知に使用）
vim.o.updatetime = 1000
