# dotfiles

Neovim + WSL2 を中心とした、軽量・キーボード操作完結・ポータブルな開発環境設定。
`curl | bash` で一発インストールできます。あわせて、Claude Code で開発プロセス
（スクラム / ウォーターフォール / TDD / CI/CD）を規律立てて回すための
**開発プロセスハーネス**を同梱しています。

- **軽量・高速** — zsh + [starship](https://starship.rs/)、遅延ロード前提の [lazy.nvim](https://github.com/folke/lazy.nvim) 構成
- **キーボード操作で完結** — telescope / which-key / flash / oil による移動・検索・ファイル操作
- **AI とのシームレス連携** — [claudecode.nvim](https://github.com/coder/claudecode.nvim) で Neovim から Claude Code を直接操作、GitHub Copilot インライン補完
- **WSL2 連携** — Windows クリップボードとの透過的な相互コピペ、`wslview` での URL/ファイルオープン
- **ポータブル** — シンボリックリンク方式。再実行は冪等で、既存ファイルは自動バックアップ

## 目次

1. [インストール](#インストール)
2. [構成](#構成)
3. [日常の使い方（エディタ・シェル）](#日常の使い方)
4. [開発プロセスハーネス（Claude Code）](#開発プロセスハーネスclaude-code)
   - [どれを使う？ 早見表](#どれを使う-早見表)
   - [典型フロー](#典型フロー)
   - [コマンド一覧](#コマンド一覧)
5. [カスタマイズ・更新](#カスタマイズ)

## インストール

前提: Ubuntu / Debian 系 Linux（WSL2 推奨）、`sudo` 可能なユーザー。

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/genokamura/dotfiles/main/install.sh)
```

インストーラが行うこと（冪等・再実行可）:

1. リポジトリを `~/.dotfiles` に clone
2. システムパッケージ（git, zsh, tmux, ripgrep, fd, fzf ...）を apt で導入
3. 最新安定版 Neovim / Node.js v22（fnm 経由）/ starship / zsh プラグイン /（WSL なら）win32yank を導入
4. 設定ファイルをシンボリックリンク（既存ファイルは `~/.dotfiles-backup/<時刻>/` へ退避）
5. デフォルトシェルを zsh に変更

インストール後:

```bash
exec zsh   # シェル再読み込み
nvim       # 初回起動でプラグインが自動インストールされる
```

さらに必要に応じて:

```bash
# git の identity（リポジトリには含めていない）
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
```

Neovim 内での初回セットアップ: `:Copilot auth`（Copilot を使う場合）。

<details>
<summary>インストールのカスタマイズ / うまくいかないとき</summary>

| 環境変数 | 既定値 | 説明 |
|----------|--------|------|
| `DOTFILES_DIR` | `~/.dotfiles` | clone 先 |
| `DOTFILES_REPO` | このリポジトリ | clone 元 URL |
| `DOTFILES_BRANCH` | `main` | 取得するブランチ |
| `NODE_VERSION` | `22` | fnm で入れる Node のメジャーバージョン |

- **シェルが zsh に変わらない**: `sudo chsh -s "$(which zsh)" "$USER"` を手動実行（パスワード未設定の WSL で起きがち）
- **gopls などのインストール失敗通知**: 該当言語のツールチェーン（Go 等）が無い場合は自動導入をスキップする設計。言語を使い始めたら `:MasonInstall <server>` で導入
</details>

## 構成

```
dotfiles/
├── install.sh           # ブートストラップ（curl | bash 対応・冪等）
├── nvim/                # ~/.config/nvim（lazy.nvim / LSP / 補完 / AI 連携）
├── zsh/                 # .zshenv / .zshrc + aliases / exports / functions / wsl
├── starship/ tmux/ git/ ripgrep/ editorconfig/   # 各種設定
├── bin/                 # clip / codeshare などのヘルパスクリプト
└── claude/              # Claude Code 資産（~/.claude/ にリンクされる）
    ├── CLAUDE.md        #   グローバル指示
    ├── commands/        #   /コマンド（定型プロンプト）
    ├── skills/          #   プロセス規律（eng-core / tdd-cicd / scrum / waterfall ...）
    └── agents/          #   開発サブエージェント定義
```

## 日常の使い方

### Neovim（Leader = `Space`）

`<leader>` を押して待つと which-key が候補を表示するので、暗記は不要です。

| キー | 動作 |
|------|------|
| `<leader><space>` / `<leader>fg` | ファイル検索 / プロジェクト全文 grep |
| `-` | 親ディレクトリをファイラ（oil）で開く |
| `s` | flash で画面内ジャンプ |
| `gd` / `gr` / `K` | 定義へ / 参照一覧 / ホバー（LSP） |
| `<leader>ca` / `<leader>cr` / `<leader>cf` | コードアクション / リネーム / フォーマット |
| `<leader>gg` / `]h` `[h` | lazygit / 次・前の git hunk |
| `<C-h/j/k/l>` | ウィンドウ移動（tmux ペインと共通操作感） |

**AI 連携**:

| キー | 動作 |
|------|------|
| `<leader>ac` / `<leader>af` | Claude Code を開く / フォーカス |
| `<leader>as`（選択中）/ `<leader>ab` | 選択範囲を送る / バッファをコンテキスト追加 |
| `<leader>aa` / `<leader>ad` | Claude の差分を承認 / 却下 |
| `<C-l>`（挿入中） | Copilot 候補を確定（`<M-]>` `<M-[>` で切替、`<C-]>` で破棄） |

### シェル

| コマンド | 説明 |
|----------|------|
| `clip` / `clip -o` | クリップボードへコピー / 貼り付け（WSL は Windows と共有） |
| `codeshare <file>` | ファイルを Markdown コードブロック化してクリップボードへ（チャット貼り付け用） |
| `mkcd` `extract` `fcd` `fkill` `note` | 小物関数（`zsh/functions.zsh`） |
| `v` `g` `gs` `gpu` `t` `dotf` | 主要エイリアス（nvim / git / status / push -u / tmux / dotfiles へ cd） |

## 開発プロセスハーネス（Claude Code）

Claude Code に開発プロセスの規律を課すための Skills / Commands / Agents 一式です。
設計思想は「**判断より仕組み**」— ①状態のファイル外部化 ②小さな作業単位
③実行結果に基づく検証 ④明示的な停止点 ⑤テスト改竄禁止などの誠実性ルール、で
LLM の能力差を補償します。**Done の判定は常に人間**が行います。

### どれを使う？ 早見表

| やりたいこと | 最初に打つコマンド |
|--------------|-------------------|
| 新しいプロダクトを反復的に作りたい | `/scrum-init` |
| 仕様が固い開発を工程管理したい（要件→設計→実装→テスト） | `/wf-init` |
| リポジトリに CI/CD とテスト基盤を敷きたい | `/pipeline-init` |
| これから作る機能のテストを設計したい | `/test-design` |
| 1つのタスクを TDD で実装したい | `/tdd` |
| コミット/PR 前の最終チェックをしたい | `/preflight` |
| 既存テストの品質を診断したい | `/test-audit` |
| アーキテクチャ上の決定を記録したい | `/adr` |
| 作業を中断した / セッションを再開した | `/standup` |
| エージェントチームにスプリントを消化させたい | `/sprint-run` |
| 新しいプロセスハーネス自体を作りたい | `/harness-design <テーマ>` |

### 典型フロー

**① スクラムで新規開発**（あなた = プロダクトオーナー）:

```
/scrum-init          バックログ初期化・最初のストーリー起票（受入基準は Given/When/Then）
/pipeline-init       CI とローカル検証ゲートを先に敷く（最初のスプリント推奨）
/sprint-plan         ゴール設定 → PBI 選択 → タスク分解
/sprint-run          エージェントチームが消化（下記）— または自分で /tdd を回す
/standup             進捗確認・中断からの再開（いつでも）
/sprint-end          受入基準を実検証 → あなたが受入判定 → レトロ
```

**② ウォーターフォールで工程管理**:

```
/wf-init             docs/ に要件定義書とステータスファイルを敷く
（要件を対話で起票）
/wf-gate             フェーズゲート審査 → あなたの承認 → 次工程へ（設計→実装→テスト→受入）
/wf-status           現在地とトレーサビリティ（REQ→DSN→DTL→TST）の確認
```

**③ 日々の実装**（プロセスを問わず）:

```
/test-design PBI-003   受入基準 → テストリスト（配置レベル・実物/代役の判定）
/tdd                   red → green → refactor を1項目ずつ
/preflight             ゲート実行 + 差分自己レビュー → コミット
```

**④ 既存プロジェクトの品質改善**:

```
/test-audit          古典学派の規律で監査（実装結合・過剰モック・非決定性）
（指摘から直すものを選ぶ）
/tdd                 再現テスト → 修正
```

### エージェントチーム実行（/sprint-run）

スプリントバックログの消化を「少数の意思決定者（あなた）＋複数の開発エージェント」で行うモードです。

- **チーム**: `dev-implementer`（TDD 実装・並列時は worktree 分離）→ `dev-reviewer`（敵対的レビュー・全件報告）→ `qa-verifier`（ゲートと受入基準の実行検証）。生成と検証は必ず別エージェント
- **あなたの出番は5つだけ**: ①ゴール/スコープ ②受入 ③ADR級の設計 ④裁定 ⑤リスク承認。それ以外は自動で進み、エスカレーションは「状況/選択肢/推奨」1画面で届く
- **コスト最適化**: 実装は Sonnet、機械的タスクは Haiku、critical・大規模横断・フレーク裁定は Opus に自動昇格（理由込みで記録され、レトロで配分を検証）
- **中断に強い**: SPRINT.md のタスクボードが唯一の正。いつ中断しても `/standup` で再開
- 詳細: `claude/skills/scrum/agent-team.md`

### コマンド一覧

| カテゴリ | コマンド | 一言で |
|----------|----------|--------|
| スクラム | `/scrum-init` `/sprint-plan` `/sprint-run` `/standup` `/sprint-end` | 立ち上げ / 計画 / エージェント実行 / デイリー / レビュー&レトロ |
| ウォーターフォール | `/wf-init` `/wf-gate` `/wf-status` | 立ち上げ / 工程ゲート / 現在地 |
| テスト・CI | `/test-design` `/tdd` `/test-audit` `/pipeline-init` | テスト設計 / TDD実装 / テスト監査 / CI構築 |
| 品質・記録 | `/preflight` `/adr` | コミット前チェック / 設計判断の記録 |
| メタ | `/harness-design` | ハーネス自体の設計・拡張 |
| その他 | `/explain-ja` | コードの日本語解説 |

### プロセス規律（Skills — 自動で読み込まれる知識）

| Skill | 内容 | 自動発動の例 |
|-------|------|-------------|
| `eng-core` | 共通規律: TDD・検証ゲート・ADR・セキュリティ（STRIDE簡易）・preflight・誠実性ルール | 実装/修正タスク・コミット前 |
| `tdd-cicd` | 古典学派TDD（状態検証・sociable test・モック境界）と CI/CD（ローカル=CIパリティ・ステージ分割・ラチェット・フレーク隔離）。プロジェクト決定は `docs/TEST_STRATEGY.md` へ | テスト・パイプラインを扱うとき |
| `scrum` | バックログ（INVEST・Given/When/Then）・スプリント・DoR/DoD・エージェントチーム調停 | `docs/PRODUCT_BACKLOG.md` があるリポジトリ |
| `waterfall` | フェーズゲート・トレーサビリティ・変更管理 | `docs/PROJECT_STATUS.md` があるリポジトリ |

### 資産の管理と拡張

`claude/` 配下が `~/.claude/` にリンクされ、全マシンで同じプロンプト・Skill・エージェントが使えます（`~/.claude/` の実行時状態には触りません）。

- **定型プロンプト追加**: `claude/commands/<name>.md` → `/<name>` で呼べる
- **Skill 追加**: `claude/skills/<name>/SKILL.md`（description に「いつ使うか」を具体的に）
- **ハーネスの拡張は `/harness-design <テーマ>`** — 要求明確化 → 最新知見調査 → 設計合意 → 実装 → 検証 → push → 改善ループ定義、を設計原則チェックリスト付きで実行
- **settings.json** は権限設定の上書き事故を防ぐため自動リンクしません。使う場合: `cp ~/.dotfiles/claude/settings.json.example ~/.claude/settings.json`

## カスタマイズ

- 設定はすべてシンボリックリンクなので、`~/.dotfiles` を編集すれば即反映されます
- マシン固有の設定は `~/.gitconfig.local`（git）等のローカルファイルへ
- 更新: `cd ~/.dotfiles && git pull`（nvim プラグインの更新は `:Lazy sync`）

## ライセンス

MIT
