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

ls data/mm/small/00nnnn/*.mm > $1

for i in {1..9}; do
    ls data/mm/small/0${i}nnnn/*.mm >> $1
done

for i in {10..34}; do
    ls data/mm/small/${i}nnnn/*.mm >> $1
done
