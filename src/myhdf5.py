import sys
import numpy as np
from scipy.sparse import csc_matrix
import h5py

# Arguments
args = sys.argv
infile = args[1]
outfile = args[2]

# Load
loaded_data = np.load(infile)
data = loaded_data['data']
indices = loaded_data['indices']
indptr = loaded_data['indptr']
shape = loaded_data['shape']

# Save
with h5py.File(outfile, 'w') as f:
	desc_group = f.create_group('desc')
	desc_group.create_dataset('data', data=data)
	desc_group.create_dataset('indices', data=indices)
	desc_group.create_dataset('indptr', data=indptr)
	desc_group.create_dataset('shape', data=shape)
