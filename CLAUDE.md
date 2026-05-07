# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## リポジトリ概要

DeSC レセプトデータ（receipt_diseases.csv → ICD-10 マスタ m_icd10.csv で結合）を、Snakemake で前処理 → 疎行列化 → ダウンサンプリング/PCA・UMAP → 隣接行列構築まで通すパイプライン群。実体は3本の独立ワークフローで、共通の中間ファイル（`data/{size}/coo.txt` 等）を介して直列に走る。

## ワークフロー（`workflow/*.smk`）

3本とも `workflow/` 直下の `.smk` で完結し、`rule all` の入力パターンが終端ターゲット。

- `sparse.smk` — レセプトCSV → 100分割 join → cat → SQLite → 83窓 rolling → numbering → COO → 100分割。`SIZES = ['small','medium','large']`、`N_SPLITS=100`、`N_WINDOWS=83`（コメントに「変更不可能」と明記）。`small` のみ追加で `split_mm.jl` により MatrixMarket 形式へ展開し `data/mm/small/x_new_list.txt` を生成する分岐がある。

  **「83窓 rolling」の意味**: `receipt_ym.R` がデータに出現する distinct な年月をソートして並べ（先頭1行は捨てる）、`rolling.R` がそのうち連続する **6ヶ月幅の窓を 1ヶ月刻みでずらして** 走らせる。窓ごとに SQLite から `(kojin_id, icd10_code)` のユニーク組を引き、行ID は `"YYYYMM..YYYYMM_kojin_id"` と窓接頭辞を付けるので、**同じ患者でも窓が違えば別行**（= 行は「患者 × 窓」、列は ICD-10）。`N_WINDOWS=83` は「月数 − 5」というデータ依存の定数で、現在のデータが 88ヶ月ぶんあることに由来する固定値。データ期間を変えるならここと `receipt_ym.R` 側を合わせて直す必要があるため「変更不可能」のコメントが入っている。
- `downsampling.smk` — `data/{size}/coo.txt` を入力に head/tail 抽出 → PCA → UMAP → プロット。
- `graph.smk` — `data/{size}/split_coo_{size}_{join}` から `coo2adjmatrix` を100+1並列で走らせ `merge_adjmatrix` で `data/{size}/adjmatrix.txt` に集約。

各ルールは漏れなく `container:`, `resources: mem_mb=10000000`, `benchmark: 'benchmarks/...'`, `log: 'logs/...'` を持ち、shell は必ず `src/*.sh ... >& {log}` の形。新規ルールを追加するときも同じテンプレに揃える。

コンテナは2種類使い分けられている:
- `docker://koki/desc_investigation:20240508` — R / Python ルール用
- `docker://koki/desc_investigation_julia:20240701` — `split_mm` ルール（Julia）専用

## 実行方法

```bash
# 各ワークフローの実行（リポジトリルートから）
snakemake -s workflow/sparse.smk --use-singularity --cores <N>
snakemake -s workflow/downsampling.smk --use-singularity --cores <N>
snakemake -s workflow/graph.smk --use-singularity --cores <N>

# DAG 図再生成（plot/{sparse,downsampling,graph}.png に出力）
bash workflow/dag.sh
```

Snakemake は **8.10.8 以上**（`min_version` で要求）。クラスタ実行を前提にしており、`src/*.sh` の先頭には SGE (`#$ -q node.q` 等) と SLURM (`#SBATCH -p node03-06` 等) のディレクティブが両方書かれているので、ジョブスケジューラ越しにそのまま投げられる。

## `src/` の構造ルール

ロジックは言語別スクリプト、Snakemake から呼ばれるのは必ず `.sh` ラッパー、というレイヤ分割が徹底されている:

- `src/<name>.sh` — クラスタ用ヘッダ + `Rscript src/<name>.R $@` / `python src/my<name>.py $@` / `julia src/<name>.jl $@` を呼ぶだけの薄いラッパー。
- `src/<name>.R` — 本体ロジック。`commandArgs(trailingOnly=TRUE)` で位置引数を受ける。先頭で `source("src/Functions.R")` するのが規約。
- `src/my<name>.py` — Python 本体（`mycsc.py`, `myhdf5.py`, `mysqlite.py`, `mynumbering.py`）。シェル側は `src/<name>.sh`（`csc.sh`, `hdf5.sh` …）と名前がずれることに注意。
- `src/split_mm.jl` — Julia は1本だけ。MatrixMarket 出力。

サイズ別に同じ処理を別スクリプトに分けているケースがある（`numbering_x_small.sh`, `numbering_x_medium.sh`, `numbering_x_large.sh` がそれぞれ `numbering.R` / `numbering_medium.R` / `numbering_large.R` を呼ぶ等）。Snakemake 側はワイルドカード `{size}` から動的にスクリプト名を組み立てて呼んでいる（例: `src/numbering_x_{wildcards.size}.sh`）。新しい処理を追加するときも `.sh` と本体スクリプトの両方を `size` 別にそろえる。

## 共通ユーティリティ `src/Functions.R`

- `.NCOLUMNS = c(small=7581, medium=215, large=25)` — ICD-10 階層粒度ごとの列数。Julia 側 `split_mm.jl` の `num_columns = 7581`、R 側 `col_id_disease_name.R` の merge 後行数（7581）もこの定義と整合させる必要がある。
- `.STARTPOSITION(index, nrows)`, `.skip.read.table(...)` — COO ファイルをブロック単位で読む共通ヘルパ。
- `library()` 群（`RSQLite`, `DBI`, `data.table`, `Rtsne`, `Matrix`, `irlba`）は Functions.R で一括ロードされるため、各スクリプトは `source("src/Functions.R")` だけで足りる。

## サイズパラメータの意味

`small` / `medium` / `large` はデータ量ではなく **ICD-10 のカテゴリ粒度**（列数 7581 / 215 / 25）。3パターン全部回したくない場合は `rule all` の `expand(..., size=SIZES)` を絞るか `--config` で切る。

## 出力ディレクトリと .gitignore

`data/`, `logs/`, `benchmarks/`, `plot/`, `.snakemake/` はすべて `.gitignore` 済み（中間生成物は git に乗らない）。デバッグ時のログは `logs/<rule>.log`、実行時間とメモリは `benchmarks/<rule>.txt` に必ず残る設計。
