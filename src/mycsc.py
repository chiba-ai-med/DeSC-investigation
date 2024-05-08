import sys
import numpy as np
import scipy.sparse as sp

# Arguments
args = sys.argv
infile = args[1]
outfile = args[2]

# Load
print("Load")
data = np.loadtxt(infile, dtype=np.int64)

print("Load (Value)")
value = [1] * data.shape[0]

print("COO")
coo_matrix = sp.coo_matrix((value, (data[:,0], data[:,1])))

# COO => CSC
print("COO => CSC")
csc_matrix = coo_matrix.tocsc()

# Save
print("Save")
np.savez(outfile, data=csc_matrix.data, indices=csc_matrix.indices,
	indptr=csc_matrix.indptr, shape=csc_matrix.shape)
