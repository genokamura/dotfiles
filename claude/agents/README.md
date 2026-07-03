# agents/ — カスタムサブエージェント定義（~/.claude/agents/ にリンク）

1ファイル = 1エージェント。frontmatter で name / description / tools / model を
指定し、本文がそのエージェントのシステムプロンプトになる。

## スクラム開発チーム（/sprint-run が使用）

| エージェント | 役割 | ツール | 備考 |
|-------------|------|--------|------|
| dev-implementer | 1タスクの TDD 実装 | 読み書き+Bash | 並列時は worktree 分離で起動 |
| dev-reviewer | 差分の敵対的レビュー | 読み取りのみ | approve / request_changes / reject |
| qa-verifier | ゲート・受入基準の実行検証 | 読み取り+Bash | 実行結果のみを根拠に判定 |

- 調停プロトコルは `../skills/scrum/agent-team.md` を参照。
- `model: sonnet` を既定にしている（安価な並列ワーカー）。より高い品質が
  必要なプロジェクトでは frontmatter の model を変更するか、起動時に上書きする。
- サブエージェントはスキルや会話コンテキストを自動継承しない。規律は各定義の
  冒頭で eng-core SKILL.md を読むよう指示してある。新しいエージェントを作る
  ときも同じパターンを踏むこと。
