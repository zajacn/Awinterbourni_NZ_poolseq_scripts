library(phangorn)
library(ape)
library(phytools)

tree = ape::read.tree("Documents/lausanne_postdoc/jokela_lab_info/Trees/trees.txt")
tree = as.multiPhylo(tree)
poolnames = read.csv("../Treemix/Tree_Space_Analysis_Consensus/pops.lst.txt", sep = " ", header = F)
metadata = data.frame(pool = poolnames$V1 , lake = sapply(str_split(poolnames$V1, "_"), .subset, 1)) %>% column_to_rownames("pool") %>% mutate(lake = if_else(lake == "Alex", "Alexandrina", lake))
metadata = metadata[-13,, drop = FALSE]
sample_map = setNames(metadata$pool, rownames(metadata))
metadata$pool = paste0(metadata$lake, rep(c(1,2,3), 5))
for (i in seq(1,84,1)){tree[[i]]$tip.label = unname(unlist(sample_map[tree[[i]]$tip.label]))}
