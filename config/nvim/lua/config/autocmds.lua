-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Claude Code CLIとの併用: 操作停止時・バッファ離脱時・フォーカス喪失時に自動保存
-- LazyVimがautoread + checktimeで外部変更の自動リロードを担当し、
-- このautocmdがNeovim側の編集を即座にディスクに反映する
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "BufLeave", "FocusLost" }, {
  group = vim.api.nvim_create_augroup("autosave_for_claude_code", { clear = true }),
  command = "silent! write",
})
