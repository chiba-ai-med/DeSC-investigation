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

rule all:
	input:
		expand('data/{size}/FINISH_split', size=SIZES)

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

rule split_coo:
	input:
		'data/{size}/coo.txt'
	output:
		'data/{size}/FINISH_split'
	container:
		'docker://koki/desc_investigation:20240508'
	benchmark:
		'benchmarks/split_coo_{size}.txt'
	log:
		'logs/split_coo_{size}.log'
	shell:
		'src/split_coo_{wildcards.size}.sh {input} {output} >& {log}'
