from snakemake.utils import min_version

#################################
# Setting
#################################
# Minimum Version of Snakemake
min_version("8.10.8")

N_SPLITS = 100
SP_INDICES = ['%03d' % x for x in list(range(N_SPLITS))]
SIZES = ['small', 'medium', 'large']
N_WINDOWS = 83 # 変更不可能
WINDOW_INDICES = ['%02d' % x for x in list(range(1, N_WINDOWS+1))]
SUMR_FILES = ["Sample_NoCounts.csv", "Feature_Means.csv", "Feature_LogMeans.csv", "Feature_SqrtMeans.csv", "Feature_CPMMeans.csv", "Feature_LogCPMMeans.csv", "Feature_SqrtCPMMeans.csv", "Feature_CPTMeans.csv", "Feature_LogCPTMeans.csv", "Feature_SqrtCPTMeans.csv", "Feature_CPMEDMeans.csv", "Feature_LogCPMEDMeans.csv", "Feature_SqrtCPMEDMeans.csv", "Feature_Vars.csv", "Feature_LogVars.csv", "Feature_SqrtVars.csv", "Feature_CPMVars.csv", "Feature_LogCPMVars.csv", "Feature_SqrtCPMVars.csv", "Feature_CPTVars.csv", "Feature_LogCPTVars.csv", "Feature_SqrtCPTVars.csv", "Feature_CPMEDVars.csv", "Feature_LogCPMEDVars.csv", "Feature_SqrtCPMEDVars.csv", "Feature_CV2s.csv"]
HEADTAIL = ['head', 'tail']
rule all:
	input:
		expand('plot/{size}/{ht}/score.png', size=SIZES, ht=HEADTAIL),
		expand('plot/{size}/{ht}/variance.png', size=SIZES, ht=HEADTAIL),
		expand('plot/{size}/{ht}/umap.png', size=SIZES, ht=HEADTAIL)

rule extract_cols:
	input:
		'data/receipt_diseases.csv'
	output:
		'data/receipt_diseases_3cols.csv'
	container:
		'docker://koki/desc_investigation:20240508'
	benchmark:
		'benchmarks/extract_cols.txt'
	log:
		'logs/extract_cols.log'
	shell:
		'src/extract_cols.sh {input} {output} >& {log}'

rule split:
	input:
		'data/receipt_diseases_3cols.csv'
	output:
		'data/FINISH_split'
	container:
		'docker://koki/desc_investigation:20240508'
	benchmark:
		'benchmarks/split.txt'
	log:
		'logs/split.log'
	shell:
		'src/split.sh {N_SPLITS} {input} {output} >& {log}'

rule join:
	input:
		'data/FINISH_split',
		'data/m_icd10.csv'
	output:
		'data/join_{sp_index}.csv'
	container:
		'docker://koki/desc_investigation:20240508'
	benchmark:
		'benchmarks/join_{sp_index}.txt'
	log:
		'logs/join_{sp_index}.log'
	shell:
		'src/join.sh {wildcards.sp_index} {input} {output} >& {log}'

rule cat:
	input:
		expand('data/join_{sp_index}.csv', sp_index=SP_INDICES)
	output:
		'data/cat.csv'
	container:
		'docker://koki/desc_investigation:20240508'
	benchmark:
		'benchmarks/cat.txt'
	log:
		'logs/cat.log'
	shell:
		'src/cat.sh {output} >& {log}'

rule sqlite:
	input:
		'data/cat.csv'
	output:
		'data/cat.sqlite'
	container:
		'docker://koki/desc_investigation:20240508'
	benchmark:
		'benchmarks/sqlite.txt'
	log:
		'logs/sqlite.log'
	shell:
		'src/sqlite.sh {input} {output} >& {log}'

rule receipt_ym:
	input:
		'data/cat.sqlite'
	output:
		'data/receipt_ym.txt'
	container:
		'docker://koki/desc_investigation:20240508'
	benchmark:
		'benchmarks/receipt_ym.txt'
	log:
		'logs/receipt_ym.log'
	shell:
		'src/receipt_ym.sh {input} {output} >& {log}'

rule rolling:
	input:
		'data/receipt_ym.txt',
		'data/cat.sqlite'
	output:
		'data/rolling_{window}_x.txt',
		'data/rolling_{window}_y.txt'
	wildcard_constraints:
		window='|'.join([re.escape(x) for x in WINDOW_INDICES])
	container:
		'docker://koki/desc_investigation:20240508'
	benchmark:
		'benchmarks/rolling_{window}.txt'
	log:
		'logs/rolling_{window}.log'
	shell:
		'src/rolling.sh {wildcards.window} {input} {output} >& {log}'

rule cat_rolling_x:
	input:
		expand('data/rolling_{window}_x.txt', window=WINDOW_INDICES)
	output:
		'data/rolling_x.txt'
	wildcard_constraints:
		window='|'.join([re.escape(x) for x in WINDOW_INDICES])
	container:
		'docker://koki/desc_investigation:20240508'
	benchmark:
		'benchmarks/cat_rolling_x.txt'
	log:
		'logs/cat_rolling_x.log'
	shell:
		'src/cat_rolling_x.sh {output} >& {log}'

rule cat_rolling_y:
	input:
		expand('data/rolling_{window}_y.txt', window=WINDOW_INDICES)
	output:
		'data/rolling_y.txt'
	wildcard_constraints:
		window='|'.join([re.escape(x) for x in WINDOW_INDICES])
	container:
		'docker://koki/desc_investigation:20240508'
	benchmark:
		'benchmarks/cat_rolling_y.txt'
	log:
		'logs/cat_rolling_y.log'
	shell:
		'src/cat_rolling_y.sh {output} >& {log}'

rule sqlite_rolling_x:
	input:
		'data/rolling_x.txt'
	output:
		'data/rolling_x.sqlite'
	container:
		'docker://koki/desc_investigation:20240508'
	benchmark:
		'benchmarks/sqlite_rolling_x.txt'
	log:
		'logs/sqlite_rolling_x.log'
	shell:
		'src/sqlite_rolling_x.sh {input} {output} >& {log}'

rule sqlite_rolling_y:
	input:
		'data/rolling_y.txt'
	output:
		'data/rolling_y.sqlite'
	container:
		'docker://koki/desc_investigation:20240508'
	benchmark:
		'benchmarks/sqlite_rolling_y.txt'
	log:
		'logs/sqlite_rolling_y.log'
	shell:
		'src/sqlite_rolling_y.sh {input} {output} >& {log}'

rule numbering_x:
	input:
		'data/rolling_x.sqlite'
	output:
		'data/row_id_number_{size}.txt',
		'data/row_coo_{size}.txt'
	container:
		'docker://koki/desc_investigation:20240508'
	benchmark:
		'benchmarks/numbering_x_{size}.txt'
	log:
		'logs/numbering_x_{size}.log'
	shell:
		'src/numbering_x_{wildcards.size}.sh {input} {output} >& {log}'

rule numbering_y:
	input:
		'data/rolling_y.sqlite'
	output:
		'data/col_id_number_{size}.txt',
		'data/col_coo_{size}.txt'
	container:
		'docker://koki/desc_investigation:20240508'
	benchmark:
		'benchmarks/numbering_y_{size}.txt'
	log:
		'logs/numbering_y_{size}.log'
	shell:
		'src/numbering_y_{wildcards.size}.sh {input} {output} >& {log}'

rule paste:
	input:
		'data/row_coo_{size}.txt',
		'data/col_coo_{size}.txt'
	output:
		'data/{size}/coo.txt'
	wildcard_constraints:
		size='|'.join([re.escape(x) for x in SIZES])
	container:
		'docker://koki/desc_investigation:20240508'
	benchmark:
		'benchmarks/paste_{size}.txt'
	log:
		'logs/paste_{size}.log'
	shell:
		'src/paste_{wildcards.size}.sh {input} {output} >& {log}'

rule downsampling:
	input:
		'data/{size}/coo.txt'
	output:
		'data/{size}/{ht}/coo.txt'
	container:
		'docker://koki/desc_investigation:20240508'
	benchmark:
		'benchmarks/paste_{size}_{ht}.txt'
	log:
		'logs/paste_{size}_{ht}.log'
	shell:
		'src/{wildcards.ht}.sh {input} {output} >& {log}'

rule downsampling_pca:
	input:
		'data/{size}/{ht}/coo.txt'
	output:
		'data/{size}/{ht}/loading.txt',
		'data/{size}/{ht}/eigenvalue.txt',
		'data/{size}/{ht}/score.txt'
	container:
		'docker://koki/desc_investigation:20240508'
	benchmark:
		'benchmarks/downsampling_pca_{size}_{ht}.txt'
	log:
		'logs/downsampling_pca_{size}_{ht}.log'
	shell:
		'src/downsampling_pca.sh {input} {output} >& {log}'

rule downsampling_umap:
	input:
		'data/{size}/{ht}/score.txt'
	output:
		'data/{size}/{ht}/umap.txt'
	container:
		'docker://koki/desc_investigation:20240508'
	benchmark:
		'benchmarks/downsampling_umap_{size}_{ht}.txt'
	log:
		'logs/downsampling_umap_{size}_{ht}.log'
	shell:
		'src/downsampling_umap.sh {input} {output} >& {log}'

rule plot_downsampling_pca:
	input:
		'data/col_id_number_{size}.txt',
		'data/{size}/{ht}/coo.txt',
		'data/{size}/{ht}/score.txt',
		'data/{size}/{ht}/eigenvalue.txt'
	output:
		'plot/{size}/{ht}/score.png',
		'plot/{size}/{ht}/variance.png'
	container:
		'docker://koki/desc_investigation:20240508'
	benchmark:
		'benchmarks/plot_downsampling_pca_{size}_{ht}.txt'
	log:
		'logs/plot_downsampling_pca_{size}_{ht}.log'
	shell:
		'src/plot_downsampling_pca.sh {input} {output} >& {log}'

rule plot_downsampling_umap:
	input:
		'data/col_id_number_{size}.txt',
		'data/{size}/{ht}/coo.txt',
		'data/{size}/{ht}/umap.txt'
	output:
		'plot/{size}/{ht}/umap.png'
	container:
		'docker://koki/desc_investigation:20240508'
	benchmark:
		'benchmarks/plot_downsampling_umap_{size}_{ht}.txt'
	log:
		'logs/plot_downsampling_umap_{size}_{ht}.log'
	shell:
		'src/plot_downsampling_umap.sh {input} {output} >& {log}'

# rule downsampling_csc:
# 	input:
# 		'data/{size}/{ht}/coo.txt'
# 	output:
# 		'data/{size}/{ht}/coo.npz'
# 	container:
# 		'docker://koki/desc_investigation:20240508'
# 	benchmark:
# 		'benchmarks/csc_{size}_{ht}.txt'
# 	log:
# 		'logs/csc_{size}_{ht}.log'
# 	shell:
# 		'src/csc.sh {input} {output} >& {log}'

# rule downsampling_hdf5:
# 	input:
# 		'data/{size}/{ht}/coo.npz'
# 	output:
# 		'data/{size}/{ht}/coo.h5'
# 	container:
# 		'docker://koki/desc_investigation:20240508'
# 	benchmark:
# 		'benchmarks/hdf5_{size}_{ht}.txt'
# 	log:
# 		'logs/hdf5_{size}_{ht}.log'
# 	shell:
# 		'src/hdf5.sh {input} {output} >& {log}'

# rule downsampling_tenxsumr
# 	input:
# 		'data/{size}/{ht}/coo.h5'
# 	output:
# 		...
# 	container:
# 		'docker://ghcr.io/rikenbit/onlinepcajl:7bbf4de'
# 	benchmark:
# 		'benchmarks/tenxsumr_{size}_{ht}.txt'
# 	log:
# 		'logs/tenxsumr_{size}_{ht}.log'
# 	shell:
# 		'src/tenxsumr.sh {input} {output} >& {log}'

# rule downsampling_tenxpca
# 	input:
# 		'data/{size}/{ht}/coo.h5'
# 	output:
# 		'output/{size}/Feature_Means.csv'
	# container:
	# 	'docker://ghcr.io/rikenbit/onlinepcajl:7bbf4de'
# 	benchmark:
# 		'benchmarks/tenxpca_{size}.txt'
# 	log:
# 		'logs/tenxpca_{size}.log'
# 	shell:
# 		'src/tenxpca.sh {input} {output} >& {log}'

