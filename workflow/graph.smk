from snakemake.utils import min_version

#################################
# Setting
#################################
# Minimum Version of Snakemake
min_version("8.10.8")

SIZES = ['small', 'medium', 'large']
JOIN_INDICES = ['%03d' % x for x in list(range(11))]

rule all:
	input:
		expand('data/{size}/adjmatrix.txt', size=SIZES)

rule coo2adjmatrix:
	input:
		'data/{size}/split_coo_{size}_{join}',
		'data/col_id_number_{size}.txt'
	output:
		'data/{size}/adj_{size}_{join}'
	container:
		'docker://koki/desc_investigation:20240508'
	benchmark:
		'benchmarks/coo2adjmatrix_{size}_{join}.txt'
	log:
		'logs/coo2adjmatrix_{size}_{join}.log'
	shell:
		'src/coo2adjmatrix.sh {input} {output} >& {log}'

def adjfiles(wld):
		return(expand('data/{size}/adj_{size}_{join}',
			size=wld[0], join=JOIN_INDICES))

rule merge_adjmatrix:
	input:
		adjfiles
	output:
		'data/{size}/adjmatrix.txt'
	container:
		'docker://koki/desc_investigation:20240508'
	benchmark:
		'benchmarks/merge_adjmatrix_{size}.txt'
	log:
		'logs/merge_adjmatrix_{size}.log'
	shell:
		'src/merge_adjmatrix.sh {wildcards.size} {output} >& {log}'
