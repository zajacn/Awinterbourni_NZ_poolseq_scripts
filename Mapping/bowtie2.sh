#!/bin/bash
#SBATCH --partition=employee
#SBATCH --array=2-10
#SBATCH --cpus-per-task=10
#SBATCH --time=1-00:00:00
#SBATCH --mem-per-cpu=10G
#SBATCH --nodelist=fgcz-c-045
#SBATCH --job-name=fastp

module load QC/fastp/0.23.4
module load Aligner/Bowtie2/2.4.2
module load Tools/samtools/1.17

DIR=/srv/GT/analysis/zajacn/p31899_LKarygianni/o34473
k=$SLURM_ARRAY_TASK_ID
name=`sed -n ${k}p < /scratch/zajac_test/p3203/list_of_samples`

DIR=/srv/gstore/projects/p3203/NovaSeq_20190830_NOV172_o5842_DataDelivery
ADAPTERS=/srv/GT/databases/contaminants/allIllumina-forTrimmomatic-20160202.fa
BOWTIEREF=/srv/GT/analysis/zajacn/p3203/Atriophallophorus_winterbourni/EBI/GCA_013407085.1/Sequence/BOWTIE2Index/Awgenome

fastp --in1 $DIR/${name}_R1.fastq.gz --in2 $DIR/${name}_R2.fastq.gz --out1 /scratch/zajac_test/p3203/${name}_filtered_R1.fastq.gz --out2 /scratch/zajac_test/p3203/${name}_filtered_R2.fastq.gz --thread 8 --trim_front1 0 --trim_tail1 0 --average_qual 20 --adapter_fasta ${ADAPTERS} --max_len1 0 --max_len2 0 --trim_poly_x --poly_x_min_len 10 --length_required 18 --compression 4 2> /scratch/zajac_test/p3203/${name}_processing.log
cat /scratch/zajac_test/p3203/fastp.json >> /scratch/zajac_test/p3203/${name}_preprocessing2.log
bowtie2 --no-unal -p 8 --rg-id ${name} --rg SM:${name} --rg LB:RGLB_${name} --rg PL:illumina --rg PU:RGPU_3${name} -x $BOWTIEREF -1 /scratch/zajac_test/p3203/${name}_filtered_R1.fastq.gz -2 /scratch/zajac_test/p3203/${name}_filtered_R2.fastq.gz 2> /scratch/zajac_test/p3203/${name}_bowtie2.log | samtools view -S -b -  > /scratch/zajac_test/p3203/${name}.bam
samtools sort -l 9 -m 8750M -@ 8 /scratch/zajac_test/p3203/${name}.bam -o /scratch/zajac_test/p3203/${name}.sorted.bam
samtools index /scratch/zajac_test/p3203/${name}.sorted.bam
sambamba markdup -r -t  /scratch/zajac_test/p3203/${name}.sorted.bam /scratch/zajac_test/p3203/${name}.sorted.dedup.bam
