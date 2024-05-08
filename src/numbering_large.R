source("src/Functions.R")

# Argument
args <- commandArgs(trailingOnly = TRUE)
infile <- args[1]
outfile1 <- args[2]
outfile2 <- args[3]

# Load
print("Load")
driver <- dbDriver("SQLite")
con <- dbConnect(driver, infile)
cmd <- paste0("SELECT DISTINCT col FROM data")
value <- unlist(dbGetQuery(con, cmd))
value <- substr(value, 1, 1)
value <- unique(value)

# Pre-processings
print("Pre-processing")
id_value <- seq_len(length(value)) - 1
names(id_value) <- value

# Save
print("Save (id_value)")
write.table(id_value, outfile1, quote=FALSE, col.names=FALSE)

print("Partition Setting")
start_value <- 1
end_value <- 4745333673
num_partitions <- 100
partition_size <- ceiling((end_value - start_value + 1) / 100)
starts <- seq(start_value, end_value - partition_size,
	by = partition_size)
ends <- starts + partition_size - 1
starts[100] <- ends[99] + 1
ends[100] <- end_value

print("Save (index)")
for(i in seq(100)){
	print(cat(i , " / ", 100, "\n"))
	if(i == 100){
		cmd2 <- paste0("SELECT col FROM data LIMIT -1 OFFSET ", starts[i])
	}else{
		cmd2 <- paste0("SELECT col FROM data LIMIT ", partition_size,
			" OFFSET ", starts[i])
	}
	tmp <- dbGetQuery(con, cmd2)
	index <- id_value[substr(unlist(tmp), 1, 1)]
	write.table(index, outfile2, quote=FALSE, col.names=FALSE, row.names=FALSE, append=TRUE)
}
