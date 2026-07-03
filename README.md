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
3. 最新安定版 Neovim / Node.js(v22, fnm 経由) / starship / zsh プラグイン / (WSL なら) win32yank を導入
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

### GitHub Copilot（インライン補完）

入力中にグレーのゴーストテキストで候補を表示します（blink.cmp のメニューとは別レイヤー、メニュー表示中は自動で隠れます）。

| キー | モード | 動作 |
|------|--------|------|
| `<C-l>` | i | 候補を確定 |
| `<M-]>` / `<M-[>` | i | 次 / 前の候補 |
| `<C-]>` | i | 候補を破棄 |
| `<leader>ap` / `<leader>aP` | n | Copilot トグル / 状態確認 |

> 初回のみ `:Copilot auth` で認証が必要です（GitHub Copilot サブスクリプションが前提）。`:Copilot status` で確認できます。Node.js は install.sh が **fnm 経由で v22** を導入します（`NODE_VERSION` 環境変数で変更可）。


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

### 開発プロセスハーネス

ミッションクリティカルな開発を LLM（ミドルクラスモデル含む）で回すためのプロセス規律一式です。設計思想は「**判断より仕組み**」——①状態のファイル外部化（会話記憶に依存しない）②小さな作業単位 ③実行結果に基づく機械的検証 ④明示的な停止点 ⑤テスト改竄禁止などの誠実性ルール、でモデルの能力差を補償します。

**3層構成**（プロセス知識は Skill、入口は Command）:

| Skill | 役割 |
|-------|------|
| `eng-core` | 共通エンジニアリング規律: TDD・検証ゲート・ADR・セキュリティ（STRIDE簡易版）・preflight チェックリスト・誠実性ルール |
| `tdd-cicd` | 古典学派TDD × CI/CD: 状態検証・sociable test・モック境界・テストピラミッド / ローカル=CIパリティ・ステージ分割・ラチェット・フレーク隔離。プロジェクトごとの決定は `docs/TEST_STRATEGY.md` に外部化 |
| `scrum` | スクラム: プロダクトバックログ（INVEST / Given-When-Then 受入基準）・スプリント・DoR/DoD・ベロシティ |
| `waterfall` | ウォーターフォール: フェーズゲート・REQ→DSN→DTL→TST トレーサビリティ・変更管理 |

**工程横断コマンド**（どちらのプロセスでも使用）:

| コマンド | 動作 |
|----------|------|
| `/tdd` | 1タスクを厳密な TDD で実装（テストリスト → red → green → refactor、1項目ずつ） |
| `/test-design` | 受入基準からテストリストを設計（ピラミッド配置・実物/代役の判定・テスト名案） |
| `/pipeline-init` | CI/CD を敷く（ローカルゲート定義 → CI は同一コマンドを呼ぶだけ → ステージ分割雛形） |
| `/test-audit` | 既存テストを古典学派の規律で監査（実装結合・過剰モック・非決定性、読み取り専用） |
| `/preflight` | コミット/PR 前の検証ゲート実行＋差分自己レビュー（推測チェック禁止） |
| `/adr` | 設計判断を ADR として記録（捨てた選択肢と可逆性を必須記載） |

**スクラム**: `/scrum-init`（バックログ初期化）→ `/sprint-plan`（ゴール設定・PBI選択・タスク分解）→ `/standup`（セッション再開兼デイリー: ファイルと git の実態から状態復元）→ `/sprint-end`（受入基準の実検証 → PO 判定 → レトロ）。受入判定は常にユーザー（PO）が行い、Claude は Done を自己宣言しません。

**エージェントチーム実行**（`/sprint-run`）: スプリントバックログの消化を、少数の意思決定者（PO=あなた）＋複数の開発サブエージェントで行うモードです。メインセッションはオーケストレーター（スクラムマスター）に徹し、自分では実装しません。

- **チーム**: `dev-implementer`（TDD 実装、並列時は worktree 分離）/ `dev-reviewer`（敵対的レビュー、読み取り専用）/ `qa-verifier`（ゲート・受入基準の実行検証）— 定義は `claude/agents/`
- **パイプライン**: 実装 → レビュー（差し戻し最大2回）→ 検証 → 統合。実装・レビュー・検証は必ず別エージェント
- **人間の関与は5決定クラスのみ**: ①ゴール/スコープ ②受入 ③ADR級の設計 ④裁定（対立・ブロック）⑤リスク（破壊的操作・セキュリティ）
- **コスト最適化のモデル・ルーティング**: 実装は Sonnet（Opus 級コーディング品質・約6割コスト）、機械的小タスクは Haiku、critical PBI・大規模横断・フレーク切り分けは Opus に昇格（理由込みでボードに記録し、レトロで配分を検証）。差し戻し上限後は人間の前に Opus リトライ1回。詳細: `claude/skills/scrum/agent-team.md` のモデル選択ポリシー
- **SPRINT.md のタスクボードが唯一の正**: 割当・状態遷移はディスパッチ前にボードへ書き込み、途中中断してもボードだけから再開可能
- 調停規約の全文: `claude/skills/scrum/agent-team.md`

**ウォーターフォール**: `/wf-init` → `/wf-gate`（チェックリスト審査 → ユーザー承認 → 工程移行）→ `/wf-status`。ドキュメント先行、承認前に次工程の成果物を作りません。

`docs/PRODUCT_BACKLOG.md`（スクラム）または `docs/PROJECT_STATUS.md`（ウォーターフォール）があるリポジトリでは、対応する Skill が自動で読み込まれます。

**ハーネス自体の拡張**: `/harness-design <テーマ>` で、新しいプロセスハーネス（Skill/Command/Agent）の設計・実装を定型手順（要求明確化 → 最新モデル知見の調査 → 設計合意 → 実装 → 検証 → push → 改善ループ定義）と設計原則チェックリスト（3層アーキテクチャ・LLM補償5原則・コンテキストパケット・coverage-first・モデルルーティング等）に従って再現性高く実行できます。
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
