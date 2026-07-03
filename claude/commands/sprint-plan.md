---
description: スプリントプランニングを実施する（ゴール設定 → PBI 選択 → タスク分解）
---

scrum スキルと eng-core スキルを読み込み、スプリントプランニングを実施して
ください。

引数（任意・ゴール案や期間）: $ARGUMENTS

手順:
1. docs/PRODUCT_BACKLOG.md と直近のスプリントファイルを読む。
   前スプリントが「完了」状態でなければ、先に /sprint-end を促して終了する。
2. 前スプリントのベロシティ（初回は仮）からキャパシティ目安を出す。
3. バックログ上位の PBI について Definition of Ready を確認する。
   Ready でないものは、その場で PO と受入基準・見積を詰めて Ready にするか、
   見送るかを決める。
4. PO とスプリントゴール（1文）を合意する。
5. ゴールに沿って PBI を選択する（キャパシティ超過なら PO に絞らせる）。
6. templates/SPRINT.md から docs/sprints/SPRINT-NNN.md を生成し、各 PBI を
   eng-core の作業単位（1 red-green-refactor で終わる粒度）のタスクに分解する。
7. バックログ側の選択 PBI の状態を「スプリント中(SPRINT-NNN)」に更新する。
8. 最初に着手するタスクを提示し、実装は /tdd の手順で進めることを確認する。
