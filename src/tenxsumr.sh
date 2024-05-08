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

INFILE=$1
OUTDIR=`sed -e 's||Sample_NoCounts.csv|g' $2`

julia /bin/tenxsumr --tenxfile $INFILE --outdir $OUTDIR --group desc --chunksize 5000
