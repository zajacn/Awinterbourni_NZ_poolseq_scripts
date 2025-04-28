library(dplyr)
library(tidyverse)
library(Biostrings)
library(data.table)

##Run as Rscript --vanilla <file.sync> <masked_regions.bed>

args <- commandArgs(trailingOnly = TRUE)

#stop the script if no command line argument
if(length(args)==0){
  print("Please choose a sync file!")
  stop("Requires command line argument.")
}

sync=args[1]
filter_file=args[2]
output= paste0(str_remove(sapply(strsplit(sync, "/"), .subset, lengths(strsplit(sync, "/"))), ".filtered.sync"), ".filtered.nomasked.sync")
output=file.path(getwd(), output)

df = read.csv(sync, sep = "\t", header = F)
print(head(df))
filter = read.csv(filter_file, sep = "\t", header = F)

filter = data.table(filter)
colnames(filter) = c("chr", "start", "end")
setkey(filter, chr, start, end)

test_sync = df[,c(1,2)]
colnames(test_sync) = c("chr", "snp")
test_sync = data.table(test_sync)
test_sync[, snp2 := snp]
test_sync$snp = as.numeric(test_sync$snp)
test_sync$snp2 = as.numeric(test_sync$snp2)
setkey(test_sync, chr, snp, snp2)

obj = foverlaps(test_sync, filter, by.x = c("chr", "snp", "snp2"), 
                by.y = c("chr", "start", "end"), type = "within", nomatch = 0)

df = df[!paste(df$V1, df$V2) %in% paste(obj$chr, obj$snp),]
write_delim(df, output, delim = "\t", )
#cmd = paste("sed -i '1d'", output)
#ezSystem(cmd)
