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

cd data
echo "receipt_ym,kojin_id,diseases_code,icd10_code" > cat.csv
cat join_*.csv >> cat.csv
