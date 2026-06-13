# Global instructions for Claude Code (symlinked to ~/.claude/CLAUDE.md)
#
# This file is version-controlled in the dotfiles repo. Project-specific
# memory still lives in each repo's own CLAUDE.md.

## 言語 / Communication
- 日本語で応答する（コード・コマンド・識別子は原文のまま）。
- 結論を先に、簡潔に。冗長な前置きは省く。

## コーディング方針
- 既存コードのスタイル（命名・コメント密度・イディオム）に合わせる。
- 軽量・ポータブルを優先。不要な依存を増やさない。
- 破壊的・不可逆な操作（force push, ファイル削除, 外部送信）は事前に確認する。

## 環境
- 主な開発環境は Neovim + WSL2 + zsh。
- dotfiles は ~/.dotfiles で管理（このファイルもその一部）。
