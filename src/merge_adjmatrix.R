source("src/Functions.R")

# Argument
args <- commandArgs(trailingOnly = TRUE)
size <- args[1]
outfile <- args[2]

# Load
files <- paste0("data/", size, "/adj_", size, "_",
	formatC(0:100, width=3, flag="0"))

# Merge
adj <- Reduce("+", lapply(files, function(x){
	as.matrix(read.table(x))
}))

# Save
write.table(adj, outfile, quote=FALSE)