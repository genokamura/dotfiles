---
name: example-skill
description: Skill の雛形。実際のスキルを作るときはこのディレクトリを複製し、name と description、本文を書き換える。description には「いつ使うか」を具体的に書くと自動起動の判定精度が上がる。
---

# Example Skill（雛形）

これは Skills の構造を示すテンプレートです。`~/.claude/skills/<skill-name>/SKILL.md`
として配置され、`description` の条件に合致したとき Claude が読み込みます。

## 使い方の例
1. このディレクトリ（`example-skill/`）を新しい名前でコピーする。
2. フロントマターの `name` をディレクトリ名と一致させる。
3. `description` に「どんなときに使うスキルか」を具体的に書く。
4. 以下に手順・規約・参照ファイルなどを記述する。

## 補足
- 補助ファイル（スクリプトやテンプレート）を同じディレクトリに置き、本文から参照できる。
- リポジトリ管理されているので、複数マシンで同じスキルが使える。
