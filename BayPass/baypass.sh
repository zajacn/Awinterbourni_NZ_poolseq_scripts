#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --time=05:00:00
#SBATCH --array=10
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=500M
#SBATCH --job-name=baypass

##########################################
echo "Natalia Zajac, GDC, 17/09/24"
echo "$(date) start ${SLURM_JOB_ID}"
##########################################

source /cluster/project/gdc/shared/stack/GDCstack.sh
NEWDIR=/cluster/scratch/zajacn

k=$SLURM_ARRAY_TASK_ID
contrast=`sed -n ${k}p < /cluster/scratch/zajacn/BayPass/list_of_contrasts`

#Core model
/cluster/home/zajacn/baypass_public/sources/g_baypass -gfile $NEWDIR/BayPass/combined.filtered.nomasked.genobaypass.3poolsperLake.genobaypass -poolsizefile $NEWDIR/BayPass/combined.filtered.nomasked.genobaypass.3poolsperLake.poolsize -d0yij 15 -contrastfile $NEWDIR/BayPass/contrast_${contrast}.txt -efile $NEWDIR/BayPass/contrast_${contrast}.txt -outprefix $NEWDIR/BayPass/OUT/${contrast}
#Calibration
/cluster/home/zajacn/baypass_public/sources/g_baypass -gfile $NEWDIR/BayPass/CALIBRATION_FILES/G.${contrast}.btapods -outprefix $NEWDIR/BayPass/CALIBRATION_FILES/${contrast}  -poolsizefile $NEWDIR/BayPass/combined.filtered.nomasked.genobaypass.3poolsperLake.poolsize  -contrastfile $NEWDIR/BayPass/contrast_${contrast}.txt  -efile $NEWDIR/BayPass/contrast_${contrast}.txt


