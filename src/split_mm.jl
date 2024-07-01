using DelimitedFiles
using SparseArrays
using Printf
using FileIO
using MatrixMarket

# 引数の取得
infile = ARGS[1]
outfile = ARGS[2]

# 行数とブロックサイズの設定
total_rows = 344419908
block_size = 1000

# 行数に基づいてデータをブロックに分割
num_blocks = div(total_rows + block_size - 1, block_size)

# サイズごとに列数は異なる
num_columns = 7581

function process_block(start_row, end_row, block_data, num_block_rows, num_columns, i)
    # ブロック内の相対的な行インデックスに変換（1-originに調整）
    row_indices = block_data[:, 1] .- start_row .+ 1
    col_indices = block_data[:, 2] .+ 1

    # COO形式の行列を作成
    coo_matrix = sparse(row_indices, col_indices, ones(Int64, size(block_data, 1)), num_block_rows, num_columns)

    # Matrix Market形式で保存
    filenum = @sprintf("%06d", i + 1)
    dirnum = filenum[1:2] * "n" ^ 4
    outmmfile = "data/mm/small/$dirnum/$filenum.mm"
    mmwrite(outmmfile, coo_matrix)
    println("$(i + 1) / $num_blocks")
end

# ファイルを読みながら処理
open(infile, "r") do file
    for i in 0:num_blocks-1
        start_row = i * block_size
        end_row = min((i + 1) * block_size, total_rows)
        num_block_rows = end_row - start_row

        # ブロック内のデータを抽出
         block_data = Vector{Tuple{Int64, Int64}}()
        while !eof(file)
            line = readline(file)
            row_col = split(line)
            row = parse(Float64, row_col[1])
            col = parse(Float64, row_col[2])
            if row >= start_row && row < end_row
                push!(block_data, (Int64(row), Int64(col)))
            end
            if row >= end_row
                break
            end
        end

        if !isempty(block_data)
            row_indices = [x[1] for x in block_data]
            col_indices = [x[2] for x in block_data]
            block_data_array = hcat(row_indices, col_indices)
            process_block(start_row, end_row, block_data_array, num_block_rows, num_columns, i)
        end
    end
end

# 空のファイルを作成
touch(outfile)