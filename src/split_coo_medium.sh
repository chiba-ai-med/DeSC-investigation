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

split -d -a 3 -l 474480718 $1 split_coo_medium_
mv split_coo_medium_* data/medium/
touch $2