#######################################################
#Sanity Check: Compare POD and original data estimates
#######################################################
#get estimate of omega from the POD analysis
library(readr)
args <- commandArgs(trailingOnly = TRUE)
name = args[1]

pdf(paste0("CALIBRATION_FILES/PLOTS/", name, ".omega_corr.pdf"))
#omega=as.matrix(read.table(paste0("OUT/", name, "_mat_omega.out")))
omega=as.matrix(read.table(paste0("OUT/", "Alexandrina_Mapourika", "_mat_omega.out")))
pod.omega=as.matrix(read.table(paste0("CALIBRATION_FILES/", name, "_mat_omega.out")))
plot(pod.omega,omega) ; abline(a=0,b=1)
dev.off()

#Filter the contrast file according to the calibrated C2 statistic
snpdet=read.table("combined.filtered.nomasked.genobaypass.3poolsperLake.snpdet")
colnames(snpdet) = c("chrom", "snp", "ref","alt")
c2=read.table(paste0("OUT/", name, "_summary_contrast.out"),h=T)
c2 = cbind(snpdet, c2)[,c(1,2,9,10)]
pod.c2=read.table(paste0("CALIBRATION_FILES/", name, "_summary_contrast.out"),h=T)
c2 = c2[c2$C2_std > quantile(pod.c2$C2_std,probs=0.96), ] #gets you about top 3% of SNPs
colnames(c2) = c("chrom", "snp", paste0(name,"_C2"), paste0(name, "_log10.1.pval."))
write_delim(c2 ,paste0("OUT/", name, "_summary_contrast.calibrated.out"), delim = "\t")
