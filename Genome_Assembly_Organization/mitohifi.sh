echo -e "\n#Path to MitoFinder image \nexport PATH=\$PATH:$p" >> ~/.bashrc
source ~/.bashrc
singularity exec --bind /srv/GT/analysis/zajacn/p3203/:/srv/GT/analysis/zajacn/p3203/ mitohifi_master.sif mitohifi.py -c ../Atriophallophorus_winterbourni/EBI/GCA_013407085.1/Sequence/WholeGenomeFasta/genome.fa -f ../Clonorchis_sinensis_referencemt.fasta -g ../Clonorchis_sinensis_referencemt.gb -t 8 -a "animal" -o 21
