#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --time=5-00:00:00
#SBATCH --array=1-88
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=500M
#SBATCH --job-name=treemix

##########################################
echo "Natalia Zajac, GDC, 31/07/24"
echo "$(date) start ${SLURM_JOB_ID}"
##########################################

source /cluster/project/gdc/shared/stack/GDCstack.sh
module load treemix/1.13
NEWDIR=/cluster/scratch/zajacn

k=$SLURM_ARRAY_TASK_ID

#For treemix
#mig=`sed -n ${k}p < /cluster/scratch/zajacn/Treemix/subsampled_data/list_of_migrations`
#dataset="76"

#Run treemix test
#for x in 1 2 3 4 5 6 7 8 9 10;
#do
#	treemix -i $NEWDIR/Treemix/subsampled_data/random_sample_without_replacement_0${dataset}.txt.gz -m $mig -seed 12356 -o $NEWDIR/Treemix/${dataset}/Treemix_allPools.${x}.${mig} -k 10;
#done

#Run FourPop from Treemix package for the whole genome
dataset=`sed -n ${k}p < /cluster/scratch/zajacn/Treemix/whole_genome_split/list_of_datasets`
fourpop -i $NEWDIR/Treemix/whole_genome_split/random_sample_without_replacement_0${dataset}.txt.gz -k 10 > $NEWDIR/Treemix/FourPop/fourpop.${dataset}.out
