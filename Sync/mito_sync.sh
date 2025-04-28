#!/bin/bash
#SBATCH --cpus-per-task=1
#SBATCH --time=10:00:00
#SBATCH --mem-per-cpu=150G
#SBATCH --job-name=grenedalf

##########################################
echo "Natalia Zajac, GDC, 04/07/24"
echo "$(date) start ${SLURM_JOB_ID}"
##########################################

source /cluster/project/gdc/shared/stack/GDCstack.sh
module load grendalf/0.6.2

NEWDIR=/cluster/scratch/zajacn
MITOFASTA=/cluster/work/gdc/people/zajacn/Mitochondrial/Mitos2/consensus_mic_mito.fasta

grenedalf sync --sam-path ${NEWDIR}/Mito_SYNC/*.mito.sorted.dedup.bam \
		--sam-min-map-qual 20 \
		--sam-min-base-qual 20 \
		--reference-genome-fasta $MITOFASTA \
		--threads 1 \
		--file-prefix all_samples.mito \
		--out-dir ${NEWDIR}/Mito_SYNC

#Rscript --vanilla ../Scripts/filter_sync.R all_samples.mitosync.sync 150 10000 25 /cluster/scratch/zajacn/mito_SYNC
