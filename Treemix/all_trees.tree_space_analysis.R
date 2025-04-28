library(TreeDist)
library("TreeTools", quietly = TRUE)
library(protoclust)
trees = ape::read.tree("../Treemix/Tree_Space_Analysis_Consensus/all_trees.nwk.txt")
spectrum <- hcl.colors(83, "plasma")
treeNumbers = seq(1,83,1)
treeCols <- spectrum[treeNumbers]

#Choose one
distances <- ClusteringInfoDistance(trees) #Choose this
distances <- PhylogeneticInfoDistance(trees)
distances <- as.dist(Quartet::QuartetDivergence(
  Quartet::ManyToManyQuartetAgreement(trees), similarity = FALSE))

#Choose one
mapping <- cmdscale(distances, k = 12)
kruskal <- MASS::isoMDS(distances, k = 12)
mapping <- kruskal$points
sammon <- MASS::sammon(distances, k = 12)
mapping <- sammon$points
rownames(mapping) = seq(1,83,1)

pdf("Treemix/Classical_Multidimensional_Scaling.Treemix.pdf")
par(mar = rep(0, 4))
plot(mapping,
     asp = 1, # Preserve aspect ratio - do not distort distances
     ann = FALSE, axes = T, # Don't label axes: dimensions are meaningless
     col = treeCols, pch = 20
)
text(mapping, rownames(mapping), cex=0.6, pos=4, col="red")
dev.off()

possibleClusters <- 1:10

# Partitioning around medoids
pamClusters <- lapply(possibleClusters, function(k) cluster::pam(distances, k = k))
pamSils <- vapply(pamClusters[c(2:10)], function(pamCluster) {
  mean(cluster::silhouette(pamCluster)[, 3])
}, double(1))

bestPam <- which.max(pamSils)
pamSil <- pamSils[bestPam]
pamCluster <- pamClusters[[bestPam]]$cluster

# Hierarchical clustering
hTree <- protoclust(distances)
hClusters <- lapply(possibleClusters[c(2:10)], function(k) cutree(hTree, k = k))
hSils <- vapply(hClusters, function(hCluster) {
  mean(cluster::silhouette(hCluster, distances)[, 3])
}, double(1))

bestH <- which.max(hSils)
hSil <- hSils[bestH]
hCluster <- hClusters[[bestH]]

# k-means++ clustering
kClusters <- lapply(possibleClusters, function(k) KMeansPP(distances, k = k))
kSils <- vapply(kClusters[c(2:10)], function(kCluster) {
  mean(cluster::silhouette(kCluster$cluster, distances)[, 3])
}, double(1))

bestK <- which.max(kSils)
kSil <- kSils[bestK]
kCluster <- kClusters[[bestK]]$cluster

pdf("Treemix/Cluster_identification.Treemix.pdf")
plot(pamSils ~ possibleClusters[c(2:10)],
     xlab = "Number of clusters", ylab = "Silhouette coefficient",
     ylim = range(c(pamSils, hSils)))
points(hSils ~ possibleClusters[c(2:10)], pch = 2, col = 2)
points(kSils ~ possibleClusters[c(2:10)], pch = 3, col = 3)
legend("topright", c("Partitioning around medoids", "Hierarchical", "k-means++"),
       pch = 1:3, col = 1:3)
dev.off()

nClusters <- 2
whichResult <- match(nClusters, possibleClusters)
cluster <- hClusters[[whichResult]]


class(hTree) <- "hclust"
par(mar = c(0, 0, 0, 0))
plot(hTree, labels = FALSE, main = "")
points(seq_along(trees), rep(1, length(trees)), pch = 16,
       col = spectrum[hTree$order])

#Plot the comparison of the clustering methods
pdf("Treemix/Consensus_Trees_from_Clusters.pdf")
par(mfrow = c(1, 2), mar = rep(0.2, 4))
col1 <- spectrum[mean(treeNumbers[cluster == 1])]
col2 <- spectrum[mean(treeNumbers[cluster == 2])]
plot(consensus(trees[cluster == 1], p = 0.5),
     edge.color = col1, edge.width = 2, tip.color = col1)
text(6, 15, "40 trees")
plot(consensus(trees[cluster == 2], p = 0.5),
     edge.color = col2, edge.width = 2, tip.color = col2)
text(5, 15, "41 trees")
dev.off()
#Validating the mapping
## How many dimensions will we need to adequately describe distances between trees
txc <- vapply(seq_len(ncol(mapping)), function(k) {
  newDist <- dist(mapping[, seq_len(k)])
  MappingQuality(distances, newDist, 10)["TxC"]
}, 0)
plot(txc, xlab = "Dimension")
abline(h = 0.9, lty = 2)

##choose a minimum spanning tree
mstEnds <- MSTEdges(distances)

##plot the first 5 dimensions
nDim <- which.max(txc > 0.9)
pdf("Treemix/Dimensions_plot.pdf")
plotSeq <- matrix(0, nDim, nDim)
plotSeq[upper.tri(plotSeq)] <- seq_len(nDim * (nDim - 1) / 2)
plotSeq <- t(plotSeq[-nDim, -1])
plotSeq[nDim * 1:3] <- (nDim * (nDim - 1) / 2) + 1:3
layout(plotSeq)
par(mar = rep(0.1, 4))
for (i in 2:nDim) for (j in seq_len(i - 1)) {
  # Set up blank plot
  plot(mapping[, j], mapping[, i], ann = FALSE, axes = FALSE, frame.plot = TRUE,
       type = "n", asp = 1, xlim = range(mapping), ylim = range(mapping))
  
  # Plot MST
  MSTSegments(mapping[, c(j, i)], mstEnds,
              col = StrainCol(distances, mapping[, c(j, i)]))
  
  # Add points
  points(mapping[, j], mapping[, i], pch = 16, col = treeCols)
  
  # Mark clusters
  for (clI in unique(cluster)) {
    inCluster <- cluster == clI
    clusterX <- mapping[inCluster, j]
    clusterY <- mapping[inCluster, i]
    hull <- chull(clusterX, clusterY)
    polygon(clusterX[hull], clusterY[hull], lty = 1, lwd = 2,
            border = "#54de25bb")
    text(mean(clusterX), mean(clusterY), clI, col = "#54de25bb", font = 2)
  }
}
dev.off()
# Annotate dimensions
plot(0, 0, type = "n", ann = FALSE, axes = FALSE)
text(0, 0, "Dimension 2")
plot(0, 0, type = "n", ann = FALSE, axes = FALSE)
text(0, 0, "Dimension 3")
plot(0, 0, type = "n", ann = FALSE, axes = FALSE)
text(0, 0, "Dimension 4")

