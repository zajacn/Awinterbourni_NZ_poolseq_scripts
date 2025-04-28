#!/bin/bash
--rename-samples-list#SBATCH --ntasks=1
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=3G
#SBATCH --job-name=grenedalf

#########################################
echo "Natalia Zajac, GDC, 31/07/24"
echo "$(date) start ${SLURM_JOB_ID}"
##########################################

source /cluster/project/gdc/shared/stack/GDCstack.sh
module load grendalf/0.6.2

NEWDIR=/cluster/scratch/zajacn
FASTA=/cluster/work/gdc/people/zajacn/Atriophallophorus_winterbourni/EBI/GCA_013407085.1/Sequence/WholeGenomeFasta/genome.fa

grenedalf diversity --sync-path $NEWDIR/SYNC/all_samples.mito.filtered.sync \
	--window-type queue \
	--window-average-policy available-loci \
	--tajima-d-denominator-policy empirical-min-read-depth \
	--pool-sizes 24 \
	--reference-genome-fasta $NEWDIR/SYNC/final_mitogenome.fasta \
	--window-queue-count 1 \
	--window-queue-stride 0 \
	--filter-sample-min-count 2 \
	--filter-sample-min-read-depth 4 \
	--out-dir $NEWDIR/FST \
	--file-prefix Queue.1SNPs.Mito.Diversity \
	--rename-samples-list $NEWDIR/SYNC/sample_names.lst \
	--threads 2
#the above protocol was adjusted for the new mt genome
#OR genewise
grenedalf diversity --sync-path ../Mito_SYNC/all_samples.mit.sync.filtered.sync --window-type regions --window-average-policy window-length --tajima-d-denominator-policy empirical-min-read-depth --pool-sizes 12 --reference-genome-fasta /cluster/work/gdc/people/zajacn/Mitochondrial/Mitos2/consensus_mic_mito.fasta --filter-sample-min-count 2 --filter-sample-min-read-depth 4 --window-region-bed ../Mito_SYNC/mt.bed --out-dir ../Mito_SYNC/ --file-prefix Queue.1SNPs.Mito.Diversity.Genewise --rename-samples-list ../sample_names.txt  --allow-file-overwriting
