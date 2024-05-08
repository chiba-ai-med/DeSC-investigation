import sys

# Arguments
args = sys.argv
infile = args[1]
outfile1 = args[2]
outfile2 = args[3]

# Load
print("Load")
with open(infile, 'r') as file:
    data = [line.strip() for line in file]

# Pre-processing
print("Pre-processing")
unique_values = list(dict.fromkeys(data))
numbering = {value: i for i, value in enumerate(unique_values)}

# Save
print("Save (Corresponding Table)")
with open(outfile1, 'w') as file:
    for value, number in numbering.items():
        file.write(f"{value},{number}\n")

print("Save (Numbered Input Data)")
with open(outfile2, 'w') as file:
    for value in data:
        number = numbering[value]
        file.write(f"{number}\n")
