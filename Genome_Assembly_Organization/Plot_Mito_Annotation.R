##Plotting Mito Contig
library(GenomicRanges)
library(rtracklayer)
library(ggbio)
library(ggplot2)
library(ggrepel) 

bed_file <- "../Genome_Resources/Galaxy2-MITOS2-Mitochondrial-Annotation.bed"
annotations <- import(bed_file, format = "bed")

# Step 2: Define the sequence range for the plot (adjust name and length as per your sequence details)
seq_name <- "Mito"  # Example sequence name; replace as needed
seq_length <- 15000  # Replace with actual sequence length

seq_range <- GRanges(seqnames = seq_name, ranges = IRanges(start = 1, end = seq_length))

# Convert annotations to a data frame if not already done
annotations_df <- as.data.frame(annotations)

# Assign a unique color to each gene by creating a factor for each label
annotations_df$color <- factor(annotations_df$name)

# Create the plot with unique colors for each gene and no legend
p = ggplot() + 
  geom_segment(data = annotations_df, 
               aes(x = start, xend = end, y = 1, yend = 1, color = color),  # Color each segment by gene name
               size = 1) +
  geom_label_repel(data = annotations_df, 
                   aes(x = (start + end) / 2, y = 1.01, label = name, color = color),  # Color each label by gene name
                   angle = 45, hjust = 0.01, size = 3, box.padding = 0.3, point.padding = 0.5) +
  xlab("Position") +
  ylab("Annotations") +
  ggtitle("Sequence Annotation with Gene Names") +
  theme_minimal() +
  ylim(0.8, 1.2) +
  scale_color_manual(values = scales::hue_pal()(length(unique(annotations_df$name))), guide = "none")



