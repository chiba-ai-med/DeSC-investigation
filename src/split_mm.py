import os
import sys
import numpy as np
import scipy.sparse
import scipy.io
from pathlib import Path

# Arguments
args = sys.argv
size = args[1]
infile = args[2]
outfile = args[3]

# Load
data = np.loadtxt(infile, dtype=np.int64)

# Output Directory
os.makedirs(f'data/mm/', exist_ok=True)
os.makedirs(f'data/mm/{size}/', exist_ok=True)

# 行数とブロックサイズの設定
total_rows = 344419908
block_size = 1000

# 行数に基づいてデータをブロックに分割
num_blocks = (total_rows + block_size - 1) // block_size

# サイズごとに列数は異なる
if size == "small":
    num_columns = 7581
elif size == "medium":
    num_columns = 215
elif size == "large":
    num_columns = 25
else:
    raise ValueError("Invalid size specified")

for i in range(num_blocks):
    # Start/Endの行
    start_row = i * block_size
    end_row = min((i + 1) * block_size, total_rows)
    # ブロック内のデータを抽出
    block_data = data[(data[:, 0] >= start_row) & (data[:, 0] < end_row)]
    # ブロック内の相対的な行インデックスに変換
    block_data[:, 0] -= start_row
    # 行数と列数を取得
    num_block_rows = end_row - start_row
    # COO形式の行列を作成
    coo_matrix = scipy.sparse.coo_matrix(
        (np.ones(block_data.shape[0]), (block_data[:, 0], block_data[:, 1])),
        shape=(num_block_rows, num_columns))
    # Matrix Market形式で保存
    filenum = '{:06}'.format(i+1)
    dirnum1 = filenum[0] + 'n' * 5
    dirnum2 = filenum[:2] + 'n' * 4
    os.makedirs(f'data/mm/{size}/{dirnum1}/', exist_ok=True)
    os.makedirs(f'data/mm/{size}/{dirnum1}/{dirnum2}/', exist_ok=True)
    outmmfile = f'data/mm/{size}/{dirnum1}/{dirnum2}/{filenum}.mm'
    scipy.io.mmwrite(outmmfile, coo_matrix)
    print(f'{i + 1} / {num_blocks}', flush=True)

# Empty File
Path(outfile).touch()
