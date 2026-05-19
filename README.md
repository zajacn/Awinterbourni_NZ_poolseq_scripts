These scripts have been used to analyse Pool-Seq data for the following publication:

Genome assembly of Atriophallophorus winterbourni has been downloaded from WormBase parasite and organized using Genome_Assembly_Organization scripts. Only scaffolds with protein coding genes have been used for the analysis. Contigs with mitochondrial genes and genes within fully softmasked genomic regions were excluded from analysis. 

Scripts used for the analysis are divided into the following folders:

Genome_Assembly_Organization - contains scripts on how the genomic was prepared for analysis
Mitochondrial_Genome - contains the assembled mitochondrial genome sequence and annotation and a circos config file for plotting 
Mapping - contains scripts on how raw data was mapped to the assemblies
Sync - contains scripts on how variants were called and filtered
DIYABC and Treemix - contain scripts on how this software was run for admixture/gene flow estimation
FST - contains scripts for pairwise and sliding window FST estimation using grenedalf
PoPoolation2 - contains parameter file from running Fisher's exact test
BayPass - contains scripts for running BayPass analysis (estimating covariance matrix and per snp C2 statistic)
Gene_Ontology - contains scripts on annotating each GO with IC and clustering GO terms using natural language processing
Additional - contains a script used to create a map of populations and some supporting scripts
Rmd_Reports - contains all reports used to analyse and visualise the data - which code refers to which figure is labelled within those reports

