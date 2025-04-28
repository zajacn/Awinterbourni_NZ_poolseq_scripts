for i in $(find . -name "Treemix_allPools.*.50.treeout.gz"); do zcat $i | head -n1 >> subset_dataset_trees_M50; done
#then use phylip consense on that file - default settings
