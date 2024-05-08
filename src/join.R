source("src/Functions.R")

# Argument
args <- commandArgs(trailingOnly = TRUE)
n <- as.numeric(args[1])
infile <- args[3]
outfile <- args[4]

# Loading
infile1 <- paste0("data/split_", formatC(n, width=3, flag=0))
left <- fread(infile1)
colnames(left) <- c("receipt_ym", "kojin_id", "diseases_code")
right <- fread(infile, select=c("diseases_code", "icd10_code"))

# Merge by diseases_code
data <- merge(left, right, by = "diseases_code",
	all = FALSE, allow.cartesian = TRUE)
data <- data[,
	c("receipt_ym", "kojin_id", "diseases_code", "icd10_code")]

# Save
fwrite(data, file=outfile, col.names=FALSE)
