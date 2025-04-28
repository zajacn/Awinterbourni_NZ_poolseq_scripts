library(dplyr)
library(tidyverse)
library(Biostrings)

##Run as Rscript --vanilla <file.sync> <minimum coverage> <maximum coverage> <minimum read count>

args <- commandArgs(trailingOnly = TRUE)

#stop the script if no command line argument
if(length(args)==0){
  print("Please choose a sync file!")
  stop("Requires command line argument.")
}

sync=args[1]
output= paste0(str_remove(sapply(strsplit(sync, "/"), .subset, lengths(strsplit(sync, "/"))), ".sync"), ".filtered.sync")
output=file.path(getwd(), output)
#Load in parameters
mincov=as.integer(args[2])
maxcov=as.integer(args[3])
mincount=as.integer(args[4])

#Load table
df = read_delim(sync)
#Filter missing values
df = df %>% filter(!if_any(starts_with("20190830.B"), ~ . == ".:.:.:.:.:."))
#Choose only SNPs and remove indels
df = df[nchar(df$ref) == 1,]
#Filter by coverage (25-350 per sample)
cov_filter = df[,c(1:3)]
for (i in colnames(df)[-1:-3]){
  cov_filter[,i] = apply(df[,i], 1, function(x) sum(as.numeric(unlist(str_split(x, ":")))) )
}
cov_filter = cov_filter %>% filter(if_all(starts_with("20190830.B"), ~ . > mincov) & if_all(starts_with("20190830.B"), ~ . < maxcov))
df = df[paste(df$`#chr`, df$pos, df$ref) %in% paste(cov_filter$`#chr`, cov_filter$pos, cov_filter$ref),]

#Replace all counts under 6 with 0
final = df[,c(1:3)]
for (i in colnames(df)[-1:-3]){
  final[,i] = df[,i, drop =FALSE] %>% 
    separate(i, into = c("A", "T", "C", "G", "N", "del"), sep = ":") %>%
    mutate(A = if_else(as.numeric(A) < mincount, 0, as.numeric(A)), 
           T = if_else(as.numeric(T) < mincount, 0, as.numeric(T)), 
           C = if_else(as.numeric(C) < mincount, 0, as.numeric(C)), 
           G = if_else(as.numeric(G) < mincount, 0, as.numeric(G)), 
           N = if_else(as.numeric(N) < mincount, 0, as.numeric(N)), 
           del = if_else(as.numeric(del) < mincount, 0, as.numeric(del))) %>% 
    mutate(i = paste0(A,":", T, ":", C, ":", G, ":", N, ":", del)) %>% 
    dplyr::select(i)
}

#Filter for biallelic SNPs
biallelic_snps = final[,c(1:3)]
for (i in colnames(final)[-1:-3]){
  biallelic_snps[,i] = final[,i, drop =FALSE] %>% 
    separate(i, into = c("A", "T", "C", "G", "N", "del"), sep = ":") %>% 
    mutate(A = if_else(as.numeric(A) > mincount, "A", "0"), 
           T = if_else(as.numeric(T) > mincount, "T", "0"), 
           C = if_else(as.numeric(C) > mincount, "C", "0"), 
           G = if_else(as.numeric(G) > mincount, "G", "0"), 
           N = if_else(as.numeric(N) > mincount, "N", "0"), 
           del = if_else(as.numeric(del) > mincount, "del", "0")) %>% 
    mutate(summary = gsub(" ", "", gsub("0", "", paste(A,C,T,G,N,del)))) %>% 
    dplyr::select(summary)
}
unique_row_values <- function(row) {
  concatenated <- paste(row, collapse = "")
  elements <- strsplit(concatenated, "")[[1]]
  unique_elements <- unique(elements)
  paste(unique_elements, collapse = "")
}

biallelic_snps$alt = apply(biallelic_snps[,c(-1:-3)], 1, unique_row_values)
biallelic_snps = biallelic_snps[!grepl("del", biallelic_snps$alt) & !grepl("N", biallelic_snps$alt) ,] # Remove deletions and Ns
biallelic_snps = biallelic_snps[nchar(biallelic_snps$alt) == 2,] # subset only biallelic
final = final[paste(final$`#chr`, final$pos, final$ref) %in% paste(biallelic_snps$`#chr`, biallelic_snps$pos, biallelic_snps$ref),]
#Write output
write_delim(final, output, delim = "\t")
