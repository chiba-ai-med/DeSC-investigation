source("src/Functions.R")

# Argument
args <- commandArgs(trailingOnly = TRUE)
i <- as.numeric(args[1])
infile1 <- args[2]
infile2 <- args[3]
outfile1 <- args[4]
outfile2 <- args[5]

# Load
print("Load")
receipt_ym <- unlist(read.delim(infile1, header=FALSE))
driver <- dbDriver("SQLite")
con <- dbConnect(driver, infile2)

# Rolling
# Patient ID => x
# ICD-10 Category => y
print("Rolling")
cmd <- paste0("SELECT DISTINCT kojin_id, icd10_code FROM data WHERE ",
	paste(
	paste0("receipt_ym == '", receipt_ym[i:(i+5)], "'"),
		collapse=" OR "), ";")
tmp <- dbGetQuery(con, cmd)
x <- paste0(receipt_ym[i], "..", receipt_ym[i+5], "_", tmp$kojin_id)
y <- tmp$icd10_code

# Save
print("Save")
write.table(x, outfile1, quote=FALSE, col.names=FALSE, row.names=FALSE)
write.table(y, outfile2, quote=FALSE, col.names=FALSE, row.names=FALSE)
