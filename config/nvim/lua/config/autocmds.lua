-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Claude Code CLIとの併用: vim.uv.new_fs_event()によるバックグラウンドファイル監視
-- フォーカスなしでもClaude Codeの編集を即座に検知してバッファをリロードする
-- Neovim公式watch-file例に準拠し、stop/start再登録方式を採用
local file_watchers = {}

local function watch_buffer(buffer)
  local filepath = vim.api.nvim_buf_get_name(buffer)
  if filepath == "" or vim.bo[buffer].buftype ~= "" then
    return
  end
  if file_watchers[buffer] then
    file_watchers[buffer]:stop()
    file_watchers[buffer]:close()
    file_watchers[buffer] = nil
  end
  local watcher = vim.uv.new_fs_event()
  if not watcher then
    return
  end
  local ok, _ = watcher:start(filepath, {}, vim.schedule_wrap(function(error, _, _)
    if error then
      return
    end
    if not vim.api.nvim_buf_is_valid(buffer) then
      watcher:stop()
      watcher:close()
      file_watchers[buffer] = nil
      return
    end
    watcher:stop()
    vim.cmd("checktime " .. buffer)
    watch_buffer(buffer)
  end))
  if not ok then
    watcher:close()
    return
  end
  file_watchers[buffer] = watcher
end

local function unwatch_buffer(buffer)
  local watcher = file_watchers[buffer]
  if watcher then
    watcher:stop()
    watcher:close()
    file_watchers[buffer] = nil
  end
end

local watcher_group = vim.api.nvim_create_augroup("file_watcher_for_claude_code", { clear = true })

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = watcher_group,
  callback = function(event)
    watch_buffer(event.buf)
  end,
})

vim.api.nvim_create_autocmd("BufFilePost", {
  group = watcher_group,
  callback = function(event)
    watch_buffer(event.buf)
  end,
})

vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout", "BufUnload" }, {
  group = watcher_group,
  callback = function(event)
    unwatch_buffer(event.buf)
  end,
})

-- フォールバック: フォーカス復帰時のchecktime（watcher未対応環境向け）
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "BufEnter" }, {
  group = vim.api.nvim_create_augroup("reload_from_claude_code", { clear = true }),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Claude Code CLIとの併用: 安全な自動保存
-- 保存前にchecktimeで外部変更を取り込み、Claude Codeの編集を上書きしない
-- 通常ファイルのみ対象とし、特殊バッファは無視する
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost" }, {
  group = vim.api.nvim_create_augroup("autosave_for_claude_code", { clear = true }),
  callback = function()
    local buffer = vim.api.nvim_get_current_buf()
    if vim.bo[buffer].buftype ~= "" or vim.fn.bufname(buffer) == "" then
      return
    end
    vim.cmd("checktime")
    if vim.bo[buffer].modified then
      vim.cmd("silent! write")
    end
  end,
})
