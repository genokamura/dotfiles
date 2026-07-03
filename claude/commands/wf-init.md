---
description: 現在のリポジトリにウォーターフォール開発ハーネスを敷く（docs/ とステータスファイルを初期化）
---

waterfall スキル（~/.claude/skills/waterfall/SKILL.md）を読み込み、その規律に従って
このリポジトリをウォーターフォール管理下に置いてください。

引数（任意・プロジェクト名など）: $ARGUMENTS

手順:
1. 既に docs/PROJECT_STATUS.md がある場合は初期化せず、現状を報告して終了する。
2. ユーザーにプロジェクト名と一言の目的を確認する（$ARGUMENTS から読み取れれば省略）。
3. スキルの templates/ から docs/PROJECT_STATUS.md と docs/01_requirements.md を
   コピーして生成し、{{PROJECT_NAME}}・{{DATE}} を置換する。
   （02 以降のドキュメントは各フェーズ開始時に生成するので今は作らない。）
4. 要件定義フェーズを「進行中」にし、次にやること
   （背景・スコープのヒアリング → REQ の起票）を提示する。
