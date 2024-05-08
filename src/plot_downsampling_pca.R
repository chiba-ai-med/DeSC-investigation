source("src/Functions.R")

# Argument
args <- commandArgs(trailingOnly = TRUE)
infile1 <- args[1]
infile2 <- args[2]
infile3 <- args[3]
infile4 <- args[4]
outfile1 <- args[5]
outfile2 <- args[6]

# Load
id_value <- read.table(infile1, header=FALSE)
coo <- read.table(infile2, header=FALSE)
score <- as.matrix(read.table(infile3, header=FALSE))
expvar <- unlist(read.table(infile4, header=FALSE))

# Label
tmp <- id_value[,1]
names(tmp) <- id_value[,2]
label <- tmp[unique(coo[,2])]
label <- substr(label, 1, 1)
label <- factor(label, levels=sort(unique(label)))

# Plot (Scatter Plot）
png(file=outfile1, width=1000, height=1000)
colnames(score) <- paste0("PC", seq(ncol(score)))
pairs(score, pch=16, cex=2, col=label)
dev.off()

# Plot (Variance）
png(file=outfile2, width=750, height=750)
par(ps=30)
plot(cumsum(expvar), pch=16, cex=4, type="b", xlab="PC", ylab="Cumulative Explained Variance (%)")
dev.off()
