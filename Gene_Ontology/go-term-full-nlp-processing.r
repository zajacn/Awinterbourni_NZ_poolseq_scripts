# Install and load required packages
if (!requireNamespace("tm", quietly = TRUE)) install.packages("tm")
if (!requireNamespace("cluster", quietly = TRUE)) install.packages("cluster")
if (!requireNamespace("factoextra", quietly = TRUE)) install.packages("factoextra")
if (!requireNamespace("wordcloud", quietly = TRUE)) install.packages("wordcloud")

library(tm)
library(cluster)
library(factoextra)
library(wordcloud)

# Read the GO terms from a file
go_terms = term2name$BP
colnames(go_terms) =  c("GO_ID", "Term_Name")
IC = read.delim("../Atriophallophorus_winterbourni/EBI/GCA_013407085.1/GO_files/Atrio_GO_IC", header = F, sep = " ")
go_terms = merge(go_terms, IC, by.x = "GO_ID", by.y = "V1", all.x = TRUE)
go_terms = go_terms %>% replace(is.na(.), 10)
go_terms = go_terms[go_terms$V2 > 5,]

# Create a corpus from the Term_Name column
corpus <- Corpus(VectorSource(go_terms$Term_Name))

# Preprocess the text
preprocess_corpus <- function(corpus) {
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removeWords, stopwords("english"))
  corpus <- tm_map(corpus, stripWhitespace)
  return(corpus)
}

corpus <- preprocess_corpus(corpus)

# Create a document-term matrix
dtm <- DocumentTermMatrix(corpus)

# Calculate TF-IDF
tfidf <- weightTfIdf(dtm)

# Convert the TF-IDF matrix to a regular matrix
mat <- as.matrix(tfidf)[rowSums(as.matrix(tfidf)) > 0,]

# Normalize the TF-IDF matrix
mat <- mat/sqrt(rowSums(mat^2))

# Perform k-means clustering
set.seed(42)  # for reproducibility
k <- 150  # number of clusters, you can adjust this
km <- kmeans(mat, centers = k)

# Add cluster assignments to the original data frame
go_terms$Cluster <- km$cluster

#If you removeSparse:
#go_terms = merge(go_terms %>% rownames_to_column(), as.data.frame(km$cluster) %>% rownames_to_column(), by = "rowname", all.x = TRUE)

# Function to get top terms for each cluster
get_top_terms <- function(cluster_num, n = 5) {
  cluster_terms <- mat[km$cluster == cluster_num, ]
  col_sums <- colSums(cluster_terms)
  top_terms <- sort(col_sums, decreasing = TRUE)[1:n]
  paste(names(top_terms), collapse = ", ")
}

# Generate cluster labels with top terms
cluster_labels <- sapply(1:k, function(i) paste("Cluster", i, ":", get_top_terms(i)))

# Print results
for (i in 1:k) {
  cat("\n", cluster_labels[i], "\n")
  print(go_terms$Term_Name[go_terms$Cluster == i])
  cat("\n")
}

# Visualize the clustering
pdf("cluster_visualization.pdf")
fviz_cluster(km, data = mat, labelsize = 8)
dev.off()

# Generate word clouds for each cluster
pdf("cluster_wordclouds.pdf")
par(mfrow = c(3, 4))  # Adjust based on number of clusters
for (i in 1:k) {
  cluster_terms <- mat[km$cluster == i, ]
  word_freqs <- sort(colSums(cluster_terms), decreasing = TRUE)
  wordcloud(words = names(word_freqs), freq = word_freqs, 
            max.words = 30, random.order = FALSE, min.freq = 0.01,
            colors = brewer.pal(8, "Dark2"))
  title(paste("Cluster", i))
}
dev.off()

# Calculate silhouette width
sil <- silhouette(km$cluster, dist(mat))
avg_sil <- mean(sil[, 3])
cat("Average silhouette width:", avg_sil, "\n")

# Write results to a file
write.csv(go_terms, "clustered_go_terms.csv", row.names = FALSE)

# Print summary
cat("\nClustering complete. Results saved to 'clustered_go_terms.csv'.\n")
cat("Cluster visualization saved as 'cluster_visualization.pdf'.\n")
cat("Cluster word clouds saved as 'cluster_wordclouds.pdf'.\n")
cat("Number of clusters:", k, "\n")
cat("Number of GO terms:", nrow(go_terms), "\n")
cat("Average silhouette width:", avg_sil, "\n")
