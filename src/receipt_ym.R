source("src/Functions.R")

# Argument
args <- commandArgs(trailingOnly = TRUE)
infile <- args[1]
outfile <- args[2]

print("Setting")
driver <- dbDriver("SQLite")
con <- dbConnect(driver, infile)

# Year / Month
print("Year / Month")
receipt_ym <- dbGetQuery(con, "SELECT DISTINCT receipt_ym FROM data;")
receipt_ym <- sort(receipt_ym[2:nrow(receipt_ym), ])

# Save
write.table(receipt_ym, outfile, sep=",",
	quote=FALSE, col.names=FALSE, row.names=FALSE)
