#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=3G
#SBATCH --job-name=grenedalf

#########################################
echo "Natalia Zajac, GDC, 31/07/24"
echo "$(date) start ${SLURM_JOB_ID}"
##########################################

source /cluster/project/gdc/shared/stack/GDCstack.sh
module load grendalf/0.5.1

NEWDIR=/cluster/scratch/zajacn
FASTA=/cluster/work/gdc/people/zajacn/Atriophallophorus_winterbourni/EBI/GCA_013407085.1/Sequence/WholeGenomeFasta/genome.fa

grenedalf fst --sync-path $NEWDIR/SYNC/combined.filtered.nomasked.sync \
	--window-type genome \
	--window-average-policy window-length \
	--method unbiased-hudson \
	--pool-sizes 24 \
	--reference-genome-fai-file $NEWDIR/SYNC/genome.fa.sync.sorted.fai \
	--out-dir $NEWDIR/FST \
	--file-prefix PairwiseFst.Hudson \
	--threads 5

#       --filter-mask-bed $NEWDIR/SYNC/mask.for.fst.bed \
#mitochondrial old
grenedalf fst --sync-path ../Mitochondrial/mito_SYNC/all_samples.mito.filtered.sync --window-type genome --window-average-policy window-length --method unbiased-hudson --pool-sizes 24 --reference-genome-fai ../Mitochondrial/final_mitogenome.fasta.fai --out-dir . --file-prefix PairwiseFst.Hudson.mt --allow-file-overwriting
#mitochondrial mitos2 mt genome
grenedalf fst --sync-path ../Mito_SYNC/all_samples.mit.sync.filtered.sync --window-type genome --window-average-policy window-length --method unbiased-hudson --pool-sizes 24 --reference-genome-fasta /cluster/work/gdc/people/zajacn/Mitochondrial/Mitos2/consensus_mic_mito.fasta --out-dir ../Mito_SYNC/ --file-prefix PairwiseFst.Hudson.mt --allow-file-overwriting
