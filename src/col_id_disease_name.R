source("src/Functions.R")

# Argument
args <- commandArgs(trailingOnly = TRUE)
infile1 <- args[1]
infile2 <- args[2]
outfile <- args[3]
# infile1 = 'data/col_id_number_small.txt'
# infile2 = 'data/m_icd10.csv'

# Load
col_id_number <- read.table(infile1, stringsAsFactors = FALSE)
m_icd10 <- read.csv(infile2, stringsAsFactors = FALSE)[, c("icd10_code", "icd10_name")]
m_icd10 <- unique(m_icd10)

# > dim(col_id_number)
# [1] 7581    2
# > dim(m_icd10)
# [1] 25875    14

# Preprocess
colnames(col_id_number) <- c("icd10_code", "number")
merged_data <- merge(col_id_number, m_icd10, by = "icd10_code", all.x = TRUE)

# Sort
merged_data <- merged_data[order(merged_data$number), ]
colnames(merged_data) <- NULL

# Output
write.csv(merged_data, file = outfile, row.names = FALSE, quote = FALSE)
