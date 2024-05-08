source("src/Functions.R")

# Argument
args <- commandArgs(trailingOnly = TRUE)
infile <- args[1]
outfile <- args[2]

# Load
print("Load")
score <- as.matrix(read.table(infile, header=FALSE))

# UMAP
out <- try(Rtsne(dist(score), is_distance=TRUE, perplexity=30, verbose=TRUE), silent=FALSE)
if(class(out)[1] == "try-error"){
	out <- Rtsne(dist(score), is_distance=TRUE, perplexity=5, verbose=TRUE)
}

# Save
write.table(out$Y, outfile,
	quote=FALSE, col.names=FALSE, row.names=FALSE)
