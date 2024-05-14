source("src/Functions.R")

# Argument
args <- commandArgs(trailingOnly = TRUE)
size <- args[1]
outfile <- args[2]

# Load
files <- paste0("data/", size, "/diag_", size, "_",
	formatC(0:10, width=3, flag="0"))

# Merge
diag <- Reduce("+", lapply(files, function(x){
	read.table(x)[,2]
}))
names(diag) <- read.table(files[1])[,1]

# Save
write.table(diag, outfile, quote=FALSE, col.names=FALSE)