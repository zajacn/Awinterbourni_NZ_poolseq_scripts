library(stringr)
library(dplyr)
library(tidyverse)
source("/cluster/home/zajacn/baypass_public/utils/baypass_utils.R")


OMEGAS = NULL
for (i in list.files("OUT/", pattern = "mat_omega.out")){
  name = str_remove(i, "_mat_omega.out")
  omega = read.table(file.path("OUT/", i),h=F)
  omega = as.matrix(omega)
  OMEGAS[[name]] = omega
}

BETAS=NULL
for (i in list.files("OUT/", pattern = "_beta_params.out")){
  name = str_remove(i, "_summary_beta_params.out")
  pi.beta.coef=read.table(file.path("OUT/", i),h=T)$Mean
  BETAS[[name]] = pi.beta.coef
}

baypass_data <-geno2YN("combined.filtered.nomasked.genobaypass.3poolsperLake.genobaypass")

for (x in names(OMEGAS)){
  simu.bta<-simulate.baypass(omega.mat=OMEGAS[[x]],nsnp=1000,sample.size=baypass_data$NN,beta.pi=BETAS[[x]],pi.maf=0,suffix=paste0(x,".btapods"))
}
