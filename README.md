# dotfiles

Neovim + WSL2 を中心とした、軽量・キーボード操作完結・ポータブルな開発環境設定。
`curl | bash` で一発インストールできます。

## 特徴

- **軽量・高速** — zsh + [starship](https://starship.rs/)、遅延ロード前提の [lazy.nvim](https://github.com/folke/lazy.nvim) 構成
- **キーボード操作で完結** — telescope / which-key / flash / oil による移動・検索・ファイル操作
- **AI とのシームレス連携** — [claudecode.nvim](https://github.com/coder/claudecode.nvim) で Neovim から Claude Code を直接操作
- **WSL2 連携** — Windows クリップボードとの透過的な相互コピペ、`wslview` での URL/ファイルオープン
- **ポータブル** — シンボリックリンク方式。再実行は冪等で、既存ファイルは自動バックアップ

## インストール

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/genokamura/dotfiles/main/install.sh)
```

または:

```bash
curl -fsSL https://raw.githubusercontent.com/genokamura/dotfiles/main/install.sh | bash
```

インストーラが行うこと:

1. リポジトリを `~/.dotfiles` に clone（実行済みチェックアウト内からの実行も検出）
2. システムパッケージ（git, zsh, tmux, ripgrep, fd, fzf ...）を apt で導入
3. 最新安定版 Neovim / starship / zsh プラグイン / (WSL なら) win32yank を導入
4. 各設定ファイルをシンボリックリンク（既存ファイルは `~/.dotfiles-backup/<時刻>/` へ退避）
5. デフォルトシェルを zsh に変更

インストール後:

```bash
exec zsh   # シェルを再読み込み
nvim       # 初回起動でプラグインが自動インストールされる
```

### カスタマイズ用環境変数

| 変数 | 既定値 | 説明 |
|------|--------|------|
| `DOTFILES_DIR` | `~/.dotfiles` | clone 先 |
| `DOTFILES_REPO` | このリポジトリ | clone 元 URL |
| `DOTFILES_BRANCH` | `main` | 取得するブランチ |

## 構成

```
dotfiles/
├── install.sh           # ブートストラップ（curl | bash 対応・冪等）
├── nvim/                # ~/.config/nvim （lazy.nvim 構成）
│   ├── init.lua
│   └── lua/
│       ├── config/      # options / keymaps / autocmds / lazy bootstrap
│       └── plugins/     # プラグインごとの spec（1ファイル1責務）
├── zsh/                 # .zshenv / .zshrc + aliases / exports / functions / wsl
├── starship/            # starship.toml（単一行・高速プロンプト）
├── git/                 # .gitconfig / .gitignore_global
├── tmux/                # .tmux.conf（Ctrl-a prefix・vim風ペイン操作）
├── ripgrep/             # .ripgreprc
├── editorconfig/        # .editorconfig
├── claude/              # Claude Code 資産（CLAUDE.md / commands / skills / agents）
└── bin/                 # clip / codeshare などのヘルパスクリプト
```

## キーバインド要点（Neovim）

Leader = `Space`。`<leader>` を押すと [which-key](https://github.com/folke/which-key.nvim) が候補を表示します。

| キー | 動作 |
|------|------|
| `<leader><space>` / `<leader>ff` | ファイル検索 (telescope) |
| `<leader>fg` | プロジェクト全文 grep |
| `<leader>fb` | バッファ一覧 |
| `-` | 親ディレクトリを oil で開く |
| `s` | flash で画面内ジャンプ |
| `gd` / `gr` / `K` | 定義へ / 参照一覧 / ホバー (LSP) |
| `<leader>ca` / `<leader>cr` / `<leader>cf` | コードアクション / リネーム / フォーマット |
| `<leader>gg` | lazygit |
| `]h` / `[h` | 次/前の git hunk |
| `<C-h/j/k/l>` | ウィンドウ移動（tmux ペインと共通操作感） |

### AI（Claude Code）連携

| キー | 動作 |
|------|------|
| `<leader>ac` | Claude を開く / トグル |
| `<leader>af` | Claude にフォーカス |
| `<leader>as`（ビジュアル選択中） | 選択範囲を Claude に送る |
| `<leader>ab` | 現在のバッファをコンテキストに追加 |
| `<leader>aa` / `<leader>ad` | Claude の差分を承認 / 却下 |
| `<leader>ar` / `<leader>aC` | セッションを resume / continue |

> `claude` CLI（[Claude Code](https://claude.com/claude-code)）が PATH 上に必要です。未導入でも Neovim は問題なく起動します。

## シェルのヘルパ

| コマンド | 説明 |
|----------|------|
| `clip` | 標準入力/ファイルをクリップボードへ（WSL は Windows クリップボード）。`clip -o` で貼り付け |
| `codeshare <file>` | ファイルを Markdown コードブロックにして即クリップボードへ（チャット/AI への貼り付け用） |
| `cb` / `cbp` | クリップボードへコピー / から貼り付け（WSL 用エイリアス） |
| `mkcd` / `extract` / `fcd` / `fkill` / `note` | よく使う小物関数 |

主なエイリアス: `v`=nvim, `g`=git, `gs`=git status, `gpu`=push -u, `t`=tmux, `dotf`=dotfiles へ cd など（`zsh/aliases.zsh` 参照）。

## Claude Code 資産の管理（プロンプト / Skills）

`claude/` 配下を `~/.claude/` にシンボリックリンクし、プロンプトや Skills を
リポジトリで一元管理します。`~/.claude/` の実行時状態（`projects/`, `todos/` 等）は
触らず、必要なものだけをリンクします。

| リポジトリ | リンク先 | 内容 |
|------------|----------|------|
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` | グローバルなメモリ／指示 |
| `claude/commands/` | `~/.claude/commands/` | カスタムスラッシュコマンド（プロンプトファイル） |
| `claude/skills/` | `~/.claude/skills/` | Skills |
| `claude/agents/` | `~/.claude/agents/` | サブエージェント定義 |

- **プロンプト追加**: `claude/commands/<name>.md` を作ると `/<name>` で呼べます（雛形: `explain-ja.md`）。
- **Skill 追加**: `claude/skills/<name>/SKILL.md` を作成（雛形: `example-skill/`）。`description` に「いつ使うか」を具体的に書くと自動起動の精度が上がります。
- **settings.json** は既存の権限設定を上書きしないよう自動リンクしていません。使う場合は手動で:
  ```bash
  cp ~/.dotfiles/claude/settings.json.example ~/.claude/settings.json
  ```

## git の identity 設定

`git/.gitconfig` には個人情報を含めていません。各マシンで以下のいずれかを設定してください:

```bash
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
```

または `~/.gitconfig.local` に記述（`.gitconfig` から `[include]` で読み込まれます）。

## 更新

```bash
cd ~/.dotfiles && git pull
# 設定はシンボリックリンクなので、編集すれば即反映されます。
```

## ライセンス

MIT
