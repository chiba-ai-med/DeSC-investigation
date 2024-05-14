# DAG graph
snakemake -s workflow/sparse.smk --rulegraph | dot -Tpng > plot/sparse.png
snakemake -s workflow/downsampling.smk --rulegraph | dot -Tpng > plot/downsampling.png
snakemake -s workflow/graph.smk --rulegraph | dot -Tpng > plot/graph.png

