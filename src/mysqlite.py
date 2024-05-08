import sys
import sqlite3

# Arguments
args = sys.argv
infile = args[1]
outfile = args[2]

import_file_name = infile
cell_separator = ","
insert_query = "INSERT INTO data (receipt_ym, kojin_id, diseases_code, icd10_code) VALUES (?, ?, ?, ?);"
db_connection = sqlite3.connect(outfile)
db_cursor = db_connection.cursor()
db_cursor.execute("CREATE TABLE data (receipt_ym TEXT, kojin_id INTEGER, diseases_code INTEGER, icd10_code TEXT);")
db_cursor.execute("BEGIN TRANSACTION")
with open(import_file_name, 'r') as import_file:
	for line in import_file:
		cleaned_columns = [column.strip() for column in line.split(cell_separator)]
		db_cursor.execute(insert_query, tuple(cleaned_columns))

db_connection.commit()
db_cursor.execute("VACUUM;")
db_cursor.close()
db_connection.close()

