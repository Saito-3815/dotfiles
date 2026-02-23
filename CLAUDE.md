# dotfiles 開発環境仕様書

本ドキュメントは、現在運用している CLI ベース開発環境の構成、
管理方法、および新規PCへの適用手順を定義する。

対象環境：
- macOS
- zsh
- tmux
- Ghostty
- CLI中心ワークフロー

---

# 1. dotfiles 構成

~/dotfiles/
├── bin/
│   └── 2p
├── config/
│   ├── tmux/
│   │   └── tmux.conf
│   ├── yazi/
│   │   └── yazi.toml
│   └── ghostty/
│       └── config
├── scripts/
│   └── bootstrap.sh
├── Brewfile
└── CLAUDE.md

2p は tmux セッション生成用テンプレートスクリプトである。
config/ 配下に各ツールの設定ファイルを集約し、bootstrap.sh でシンボリックリンクを作成する。

---

# 2. PATH 設定（標準方式）

dotfiles 配下のスクリプトを直接参照する。

.zshrc に以下を追加する：

export PATH="$HOME/dotfiles/bin:$PATH"

反映：

source ~/.zshrc

確認：

which 2p

期待出力：

/Users/<user>/dotfiles/bin/2p

---

# 3. 2p 仕様

## 3.1 概要

任意のプロジェクトディレクトリに対して、
共通の2ペイン構成で tmux セッションを生成する。

構成：

左ペイン  : yazi  
右ペイン  : claude  

既存セッションが存在する場合は切り替え、
存在しない場合は新規作成する。

---

## 3.2 コマンド仕様

2p [session_name] [project_root]

省略ルール：

- project_root 省略 → カレントディレクトリを使用
- session_name 省略 → ディレクトリ名を使用

使用例：

2p
2p myapp
2p myapp ~/src/myapp

---

# 4. レイアウト管理

スクリプト内で以下の変数により管理する：

LAYOUT='657d,183x51,0,0{106x51,0,0,0,76x51,107,0,2}'

これは tmux の window_layout 文字列である。

---

## 4.1 レイアウト更新手順

1. tmux 上で理想形に調整
2. 以下を実行

tmux display-message -p "#{window_layout}"

3. 出力された文字列を LAYOUT に反映
4. セッションを再生成

tmux kill-session -t <session>  
2p <session> <root>

---

# 5. 新規PCへの適用手順

## 5.1 dotfiles の取得

git clone <repository-url> ~/dotfiles

---

## 5.2 前提パッケージ

brew bundle --file=~/dotfiles/Brewfile

※ ghostty / claude CLI は別途インストール

---

## 5.3 bootstrap 実行

~/dotfiles/scripts/bootstrap.sh

これにより以下が自動実行される：
- 設定ファイルのシンボリックリンク作成（~/.tmux.conf, ~/.config/yazi/, ~/.config/ghostty/）
- PATH設定（.zshrc への追記）
- bin/2p への実行権限付与

反映：

source ~/.zshrc

---

## 5.4 動作確認

任意ディレクトリで：

2p

---

# 6. 代替方式（シンボリックリンク）

PATH方式を使用しない場合：

mkdir -p ~/.local/bin
ln -s ~/dotfiles/bin/2p ~/.local/bin/2p
chmod +x ~/dotfiles/bin/2p

.zshrc に：

export PATH="$HOME/.local/bin:$PATH"

---

# 7. トラブルシューティング

## コマンドが見つからない場合

echo $PATH

$HOME/dotfiles/bin が含まれていることを確認する。

---

## tmux が起動しない場合

tmux -V

tmux がインストールされていることを確認する。

---

# 8. 運用方針

- レイアウトはスクリプト内で一元管理する
- セッションは再生成可能とする
- 実行状態の同期は行わない
- 再現性を最優先とする
- 設定ファイルは config/ 配下で一元管理し、bootstrap.sh でリンクを作成する
- bootstrap.sh は冪等（何度実行しても安全）とする
