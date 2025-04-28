#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --array=43,54,55,62,67,74,84,86,88%9
#SBATCH --time=10-00:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=50M
#SBATCH --job-name=treemix

##########################################
echo "Natalia Zajac, GDC, 31/07/24"
echo "$(date) start ${SLURM_JOB_ID}"
##########################################

source /cluster/project/gdc/shared/stack/GDCstack.sh
module load treemix/1.13
NEWDIR=/cluster/scratch/zajacn

k=$SLURM_ARRAY_TASK_ID
TREE=$NEWDIR/Treemix/outtree_consensus_M60
OUTPUT=$NEWDIR/Treemix/whole_genome_split_out/random_sample_without_replacement_0${k}

#Run treemix
treemix -i $NEWDIR/Treemix/whole_genome_split/random_sample_without_replacement_0${k}.txt.gz -m 60 -tf $TREE -global -se -seed 1234 -k 10 -o $OUTPUT;

