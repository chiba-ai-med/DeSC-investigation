from snakemake.utils import min_version

#################################
# Setting
#################################
# Minimum Version of Snakemake
min_version("8.10.8")

SIZES = ['small', 'medium', 'large']
HEADTAIL = ['head', 'tail']

rule all:
	input:
		expand('plot/{size}/{ht}/score.png', size=SIZES, ht=HEADTAIL),
		expand('plot/{size}/{ht}/variance.png', size=SIZES, ht=HEADTAIL),
		expand('plot/{size}/{ht}/umap.png', size=SIZES, ht=HEADTAIL)

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
