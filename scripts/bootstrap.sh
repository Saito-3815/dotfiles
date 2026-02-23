#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"

# --- リンク作成関数 ---
link_file() {
  local src="$1"
  local dst="$2"

  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "skip: $dst (already linked)"
    return
  fi

  mkdir -p "$(dirname "$dst")"

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    local backup="${dst}.bak"
    echo "backup: $dst -> $backup"
    mv "$dst" "$backup"
  fi

  ln -s "$src" "$dst"
  echo "link: $src -> $dst"
}

# --- 設定ファイルのリンク ---
link_file "$DOTFILES/config/tmux/tmux.conf"    "$HOME/.tmux.conf"
link_file "$DOTFILES/config/yazi/yazi.toml"     "$HOME/.config/yazi/yazi.toml"
link_file "$DOTFILES/config/ghostty/config"     "$HOME/.config/ghostty/config"

# --- PATH設定 ---
if ! grep -q 'dotfiles/bin' "$HOME/.zshrc" 2>/dev/null; then
  echo '' >> "$HOME/.zshrc"
  echo 'export PATH="$HOME/dotfiles/bin:$PATH"' >> "$HOME/.zshrc"
  echo "added: PATH setting to .zshrc"
else
  echo "skip: PATH already configured in .zshrc"
fi

# --- 実行権限 ---
chmod +x "$DOTFILES/bin/tmux-2p"

echo ""
echo "bootstrap complete."
