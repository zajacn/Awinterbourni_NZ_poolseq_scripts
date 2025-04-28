library(ezRun)
options(error=recover)
library(GenomicFeatures)
library(tidyr)
library(readr)
library(dplyr)
library(tidyverse)
        
## Load environments
Sys.setenv(Picard_jar = '/usr/local/ngseq/packages/Tools/Picard/2.22.8/picard.jar')
Sys.setenv(PATH = paste("/usr/local/ngseq/packages/Tools/IGVTools/2.8.10", Sys.getenv("PATH"), sep = ":"))
Sys.setenv(PATH = paste("/usr/local/ngseq/packages/Tools/samtools/1.11/bin/", Sys.getenv("PATH"), sep = ":"))

# Make sure jdk version matches that required by Picard 
# (start new shell and run `module load Tools/Picard` to
# see with which version of Java the default one is overridden)
Sys.setenv(PATH = paste("/usr/local/ngseq/packages/Dev/jdk/14/bin", Sys.getenv("PATH"), sep = ":"))

## config
setwd("/scratch/zajacn/references/")
organism <- "Atriophallophorus_winterbourni"
db <- "EBI"
build <- "GCA_013407085.1"

## download
gtfURL <- "https://ftp.ebi.ac.uk/pub/databases/wormbase/parasite/releases/WBPS19/species/atriophallophorus_winterbourni/PRJNA636673/atriophallophorus_winterbourni.PRJNA636673.WBPS19.canonical_geneset.gtf.gz"
download.file(gtfURL, basename(gtfURL))
ezSystem(paste0("gunzip ", basename(gtfURL)))
genomeURL <- "https://ftp.ebi.ac.uk/pub/databases/wormbase/parasite/releases/WBPS19/species/atriophallophorus_winterbourni/PRJNA636673/atriophallophorus_winterbourni.PRJNA636673.WBPS19.genomic_softmasked.fa.gz"
download.file(genomeURL, basename(genomeURL))
featureFn <- ""
genomeFn <- basename(genomeURL)

#Gene names contain dots which will be filtered out, so I am removing this part from the function

buildRefDir = function(x, genomeFile, genesFile, keepOriginalIDs = FALSE){
  # x is EzRef object
  require(rtracklayer)
  require(Rsamtools)
  
  gtfPath <- dirname(x@refFeatureFile)
  fastaPath <- dirname(x@refFastaFile)
  dir.create(gtfPath, recursive=TRUE)
  dir.create(fastaPath, recursive=TRUE)
  if(!is.null(x@refAnnotationVersion)){
    unlink(file.path(x@refBuildDir, "Annotation", "Genes"), recursive = TRUE)
    file.symlink(file.path(x@refAnnotationVersion, "Genes"),
                 file.path(x@refBuildDir, "Annotation", "Genes"))
  }
  
  ## fasta
  genome <- readBStringSet(genomeFile)
  ### remove everything after chr id
  names(genome) <- str_replace(names(genome), " .*$", "")
  writeXStringSet(genome, x@refFastaFile)
  
  ## 2 GTF files:
  ### features.gtf
  gtf <- import(genesFile)
  
  #### some controls over gtf
  if(is.null(gtf$gene_biotype)){
    if(is.null(gtf$gene_type)){
      message("gene_biotype is not available in gtf. Assigning protein_coding.")
      gtf$gene_biotype <- "protein_coding"
    }else{
      ## In GENCODE gtf, there is gene_type, instead of gene_biotype.
      gtf$gene_biotype <- gtf$gene_type
      gtf$gene_type <- NULL
    }
  }

  if(is.null(gtf$gene_name)){
    message("gene_name is not available in gtf. Assigning gene_id.")
    gtf$gene_name <- gtf$gene_id
  }
  
  export(gtf, con=file.path(gtfPath, "features.gtf"))
  ### genes.gtf
  export(gtf[gtf$gene_biotype %in% listBiotypes("genes")],
         con=file.path(gtfPath, "genes.gtf"))
  ### transcripts.only.gtf
  export(gtf[gtf$type %in% "transcript"],
         con=file.path(gtfPath, "transcripts.only.gtf"))
  indexFa(x@refFastaFile)
  
  ## create the chromsizes file
  fai <- read_tsv(str_c(x@refFastaFile, ".fai"), col_names = FALSE)
  write_tsv(fai %>% dplyr::select(1:2), file = x@refChromSizesFile, col_names = FALSE)
  
  dictFile <- str_replace(x@refFastaFile, "\\.fa$", ".dict")
  if (file.exists(dictFile)) {
    file.remove(dictFile)
  }
  cmd <- paste("java -Xms1g -Xmx10g -Djava.io.tmpdir=. -jar /misc/ngseq10/packages/Tools/Picard/2.22.8/picard.jar", "CreateSequenceDictionary",
               paste0("R=", x@refFastaFile), paste0("O=", dictFile))
  ezSystem(cmd)
}

## make reference folder
refBuild <- file.path(organism, db, build, "Annotation", "Version-2024-06-21")
param <- ezParam(list(refBuild=refBuild, genomesRoot='.'))
buildRefDir(param$ezRef, genomeFile=genomeFn, genesFile=featureFn)
buildIgvGenome(param$ezRef)

#GO annotation performed with OMA,Pannzer2 and EggNOG combined
egg <- read.delim("EGGNOG_Atriophallophorus_winterbourni.tsv", header = FALSE)
oma <- read.table("OMA_GO_Atriophallophorus_winterbourni.txt", header = FALSE, skip = 4)[,c(2,4)]
pan <- read_tsv("PAN_GO_Atriophallophorus_winterbourni.txt", col_types = cols(.default = "c"))[,c(1,3)] %>% mutate(goid = paste0("GO:",goid))
colnames(egg) = c("transcript", "GO")
colnames(oma) = c("transcript", "GO")
colnames(pan) = c("transcript", "GO")
ann = rbind(egg, oma, pan)
ann = ann[!duplicated(ann),]
library(GO.db)
ann$ontology <- select(GO.db, ann$GO, "ONTOLOGY")
ann$gene = str_remove(ann$transcript, "-mRNA-1")
ann = ann[ann$transcript != "augustus_masked-agouti_scaf_1682-processed-gene-0.10-mRNA-1",]

MF <- unique(drop_na(ann[ann$ontology$ONTOLOGY == "MF",][,c("gene", "transcript", "GO")]))
colnames(MF) <- c("gene", "transcript", "GO MF")
BP <- unique(drop_na(ann[ann$ontology$ONTOLOGY == "BP",][,c("gene", "transcript", "GO")]))
colnames(BP) <- c("gene", "transcript", "GO BP")
CC <- unique(drop_na(ann[ann$ontology$ONTOLOGY == "CC",][,c("gene", "transcript", "GO")]))
colnames(CC) <- c("gene", "transcript", "GO CC")
ann <- merge(BP, merge(CC, MF, by=c("gene", "transcript"), all = TRUE), by = c("gene", "transcript"), all = TRUE)
ann = ann %>% group_by(gene,transcript) %>% summarise_all(function(x){unique(x) %>% str_c(collapse="; ")})

makeFeatAnnEnsembl_modified <- function (featureFile, genomeFile, biomartFile = NULL, goannotationFile) 
{
  require(rtracklayer)
  require(data.table)
  featAnnoFile <- str_replace(featureFile, "\\.gtf$", "_annotation_byTranscript.txt")
  featAnnoGeneFile <- str_replace(featureFile, "\\.gtf$", 
                                  "_annotation_byGene.txt")
  feature <- import(featureFile)
  transcripts <- feature[feature$type == "transcript"]
  if (length(transcripts) == 0L) {
    exons <- feature[feature$type == "exon"]
    exonsByTx <- GenomicRanges::split(exons, exons$transcript_id)
    transcripts <- unlist(range(exonsByTx))
    transcripts$transcript_id <- names(transcripts)
    names(transcripts) <- NULL
    transcripts$gene_id <- exons$gene_id[match(transcripts$transcript_id, 
                                               exons$transcript_id)]
    transcripts$gene_name <- exons$gene_name[match(transcripts$transcript_id, 
                                                   exons$transcript_id)]
    transcripts$gene_biotype <- exons$gene_biotype[match(transcripts$transcript_id, 
                                                         exons$transcript_id)]
  }
  transcripts <- transcripts[!duplicated(transcripts$transcript_id)]
  gw <- getTranscriptGcAndWidth(genomeFn = genomeFile, featureFn = featureFile)
  featAnno <- tibble(transcript_id = transcripts$transcript_id, 
                     gene_id = transcripts$gene_id, gene_name = transcripts$gene_name, 
                     type = transcripts$gene_biotype, strand = as.character(strand(transcripts)), 
                     seqid = as.character(seqnames(transcripts)), start = start(transcripts), 
                     end = end(transcripts), biotypes = transcripts$gene_biotype)
  featAnno <- left_join(featAnno, gw)
  stopifnot(!featAnno %>% dplyr::select(start, end, gc, featWidth) %>% 
              is.na() %>% any())
  stopifnot(all(featAnno %>% pull(biotypes) %in% listBiotypes("all")))
  isProteinCoding <- featAnno %>% pull(biotypes) %in% listBiotypes("protein_coding")
  isLNC <- featAnno %>% pull(biotypes) %in% listBiotypes("long_noncoding")
  isSHNC <- featAnno %>% pull(biotypes) %in% listBiotypes("short_noncoding")
  isrRNA <- featAnno %>% pull(biotypes) %in% listBiotypes("rRNA")
  istRNA <- featAnno %>% pull(biotypes) %in% listBiotypes("tRNA")
  isMtrRNA <- featAnno %>% pull(biotypes) %in% listBiotypes("Mt_rRNA")
  isMttRNA <- featAnno %>% pull(biotypes) %in% listBiotypes("Mt_tRNA")
  isPseudo <- featAnno %>% pull(biotypes) %in% listBiotypes("pseudogene")
  featAnno$type[isPseudo] <- "pseudogene"
  featAnno$type[isLNC] <- "long_noncoding"
  featAnno$type[isSHNC] <- "short_noncoding"
  featAnno$type[isProteinCoding] <- "protein_coding"
  featAnno$type[isrRNA] <- "rRNA"
  featAnno$type[istRNA] <- "tRNA"
  featAnno$type[isMtrRNA] <- "Mt_rRNA"
  featAnno$type[isMttRNA] <- "Mt_tRNA"
  featAnno <- merge(x=featAnno, y=goannotationFile, by.x = c("transcript_id","gene_id"), by.y=c("transcript", "gene"), all=TRUE)
  write_tsv(featAnno, file = featAnnoFile)
  featAnnoGene <- aggregateFeatAnno(featAnno)
  write_tsv(featAnnoGene, file = featAnnoGeneFile)
  invisible(list(transcript = featAnno, gene = featAnnoGene))
}

makeFeatAnnEnsembl_modified(featureFile=file.path(dirname(param$ezRef@refFeatureFile),
                                                              "features.gtf"), 
                            genomeFile=param$ezRef@refFastaFile,
                            biomartFile = NULL, goannotationFile=ann)
makeFeatAnnEnsembl_modified(featureFile=file.path(dirname(param$ezRef@refFeatureFile),
                                                  "genes.gtf"),
                            genomeFile=param$ezRef@refFastaFile,
                            biomartFile = NULL, goannotationFile=ann)