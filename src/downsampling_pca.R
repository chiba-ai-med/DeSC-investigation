source("src/Functions.R")

# Argument
args <- commandArgs(trailingOnly = TRUE)
infile <- args[1]
outfile1 <- args[2]
outfile2 <- args[3]
outfile3 <- args[4]

# Load
print("Load")
data <- read.delim(infile, header=FALSE)
data <- data + 1

# Slide
data[,1] <- as.numeric(as.factor(data[,1]))
data[,2] <- as.numeric(as.factor(data[,2]))

# Sparse Matrix
sm <- sparseMatrix(data[,1], data[,2], x=1)
dm <- as.matrix(sm)

# PCA
out <- prcomp_irlba(dm, 10)

# Explainced Variance
expvar <- summary(out)$importance[2,]

# Save
write.table(out$x, outfile1,
	quote=FALSE, col.names=FALSE, row.names=FALSE)
write.table(expvar, outfile2,
	quote=FALSE, col.names=FALSE, row.names=FALSE)
write.table(out$rotation, outfile3,
	quote=FALSE, col.names=FALSE, row.names=FALSE)
