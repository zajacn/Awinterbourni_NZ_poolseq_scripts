#!/usr/bin/Rscript
library(poolfstat)
library(dplyr)
library(readr)
library(stringr)
library(tidyverse)
library(textshaping)
library(reshape2)
library(data.table)

Nb_poly_SNPs = read.csv("/misc/GT/analysis/zajacn/p3203/FST/Queue.1SNP.Hudsonfst.csv")
Nb_poly_SNPs = melt(cbind(Nb_poly_SNPs[,c(1,2,3)], Nb_poly_SNPs[,grepl(".fst", colnames(Nb_poly_SNPs))]), id.vars = c("chrom", "start", "end"))
Nb_poly_SNPs = Nb_poly_SNPs %>% filter(value != "NaN")
Nb_poly_SNPs = Nb_poly_SNPs %>% separate(variable, into = c("pool1", "pool2", "fst"), sep = "\\.")
Nb_poly_SNPs$label = paste0(sapply(str_split(Nb_poly_SNPs$pool1, "_"), .subset, 1), "_", sapply(str_split(Nb_poly_SNPs$pool2, "_"), .subset, 1))
Nb_poly_SNPs = Nb_poly_SNPs %>% separate(label, into = c("pool1", "pool2"), sep = "_") %>% mutate(pool1 = if_else(pool1 == "Alex", "Alexandrina", pool1), pool2 = if_else(pool2 == "Alex", "Alexandrina", pool2)) %>% mutate(label = paste0(pool1, "_", pool2)) %>% dplyr::select(-4,-5)

Fst_grendalf = read_delim("/misc/GT/analysis/zajacn/p3203/FST/Popoolation2/Sliding_Fst_per_Lake/Fst_sliding.Grendalf.Pi.FET.XtX.C2.txt")
windows = Fst_grendalf[,c(1,2,3)]
windows = unique(windows)
windows = data.table(windows)
setkey(windows, chrom, start, end)
snps = Nb_poly_SNPs[,c(1,2)]
colnames(snps) = c("chr", "snp")
snps = snps %>% unique()
snps = data.table(snps)
snps[, Pos2 := snp]
snps$snp = as.numeric(snps$snp)
snps$Pos2 = as.numeric(snps$Pos2)
setkey(snps, chr, snp, Pos2)

Nb_poly_SNPs = Nb_poly_SNPs[,c(1,2,4,5)]
colnames(Nb_poly_SNPs) = c("chrom", "snp", "value", "label")
Nb_poly_SNPs = merge(Nb_poly_SNPs, data.frame(obj) %>% dplyr::select(-5), by.x = c("chrom", "snp"), by.y = c("chr", "snp"))
Nb_poly_SNPs = Nb_poly_SNPs %>% group_by("chrom", "start", "end", "label") %>% summarise(snp_count = n_distinct(snp))
write_delim(Nb_poly_SNPs, "/misc/GT/analysis/zajacn/p3203/FST/Queue.1SNP.Hudsonfst.modified.txt", delim = "\t")

obj = foverlaps(snps, windows, by.x = c("chr", "snp", "Pos2"), by.y = c("chrom", "start", "end"), type = "within", nomatch = 0)
