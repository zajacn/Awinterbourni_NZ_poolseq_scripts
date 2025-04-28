#!/bin/bash
#SBATCH --cpus-per-task=1
#SBATCH --array=1-249%50
#SBATCH --time=05:00:00
#SBATCH --mem-per-cpu=1G
#SBATCH --job-name=Rscript

##########################################
echo "Natalia Zajac, GDC, 04/07/24"
echo "$(date) start ${SLURM_JOB_ID}"
##########################################

module load stack/2024-06
module load gcc/12.2.0
module load r/4.4.0
module --show_hidden load curl/8.4.0-mxgyalo

NEWDIR=/cluster/scratch/zajacn
list_of_syncs=/cluster/scratch/zajacn/SYNC/list_of_syncs
k=$SLURM_ARRAY_TASK_ID
sequence=`sed -n ${k}p < /cluster/scratch/zajacn/SYNC/jobs_filter.txt`

sed -n $sequence $list_of_syncs | while read -r line;
do
SYNC=$(echo $line)
echo $SYNC
Rscript --vanilla /cluster/scratch/zajacn/Scripts/filter_sync.R $NEWDIR/SYNC/$line 25 350 6 $NEWDIR/filteredSYNC/;
done
