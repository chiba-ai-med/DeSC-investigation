#!/bin/bash
#$ -l nc=4
#$ -p -50
#$ -r yes
#$ -q node.q

#SBATCH -n 4
#SBATCH --nice=50
#SBATCH --requeue
#SBATCH -p node03-06
SLURM_RESTART_COUNT=2

# 出力ディレクトリの作成
mkdir -p data/mm/small

for i in {0..9}; do
    mkdir -p data/mm/small/0${i}nnnn
done

for i in {10..34}; do
    mkdir -p data/mm/small/${i}nnnn
done

julia src/split_mm.jl $@
