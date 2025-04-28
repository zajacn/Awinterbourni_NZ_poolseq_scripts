# For splitting the genome into equal chuncks
shuf ../../../BayPass/without_Paringa_Pool4/combined.filtered.nomasked.genobaypass.3poolsperLake.genobaypass | split -l 50000 -d -a 3 - whole_genome_split/random_sample_without_replacement_
mv whole_genome_split/random_sample_without_replacement_000 whole_genome_split/random_sample_without_replacement_088
for i in {01..88}; do awk '{print $1","$2"\t"$3","$4"\t"$5","$6"\t"$7","$8"\t"$9","$10"\t"$11","$12"\t"$13","$14"\t"$15","$16"\t"$17","$18"\t"$19","$20"\t"$21","$22"\t"$23","$24"\t"$25","$26"\t"$27","$28"\t"$29","$30}' whole_genome_split/random_sample_without_replacement_0${i} > whole_genome_split/temp_${i}; done
for i in {01..88}; do cat <( zcat /cluster/work/gdc/people/zajacn/Treemix/with_Paringa_Pool4/subsampled_files_for_Treemix/random_samples/combined.filtered.nomasked.genobaypass.treemix.1.txt.gz  | head -n1 | cut -f1-12,14-16) whole_genome_split/temp_${i} > whole_genome_split/random_sample_without_replacement_0${i}.txt; done
gzip *
