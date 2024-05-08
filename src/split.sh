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

# N_LINES=`wc -l $2`
# N_LINES=`echo $N_LINES | sed -e 's| .*.csv||g'`
N_LINES=2585550036
CHUNK_SIZE=`expr $N_LINES / $1 + 1`

split -d -a 3 -l $CHUNK_SIZE $2 split_
mv split_* data/
touch $3