source("src/Functions.R")

# Argument
args <- commandArgs(trailingOnly = TRUE)
infile1 <- args[1]
infile2 <- args[2]
outfile <- args[3]

# Load
print("Load")
data <- read.delim(infile1, header=FALSE, nrow=1000)
data <- data + 1
icd10 <- read.delim(infile2, header=FALSE, sep=" ")[,1]

# Slide
data[,1] <- as.numeric(as.factor(data[,1]))

# Sparse Matrix
nr <- length(unique(data[,1]))
nc <- length(icd10)
sm <- sparseMatrix(data[,1], data[,2],
	x=rep(1, length=nrow(data)), dims=c(nr, nc))
adj <- as.matrix(t(sm) %*% sm)
rownames(adj) <- icd10
colnames(adj) <- icd10

# Save
write.table(adj, outfile, quote=FALSE)
