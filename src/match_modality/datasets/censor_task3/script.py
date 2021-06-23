# VIASH START
par = {
    "input": "../../../resources/test/dyngen_bifurcating_antibody/dataset.h5ad",
    "output": "output.h5ad",
    "shuffle_cells_output": "shuffle_cells.csv",
}
# VIASH END

import anndata
import random
import csv
from pathlib import Path

# load dataset to be censored
adata = anndata.read_h5ad(par["input"])

# check which modalities are included
has_antibody = "protein" in adata.layers.keys()
has_atac = "chromatin" in adata.layers.keys()

# check if exactly 1 modality is included
# TODO: is this necessary? Can integration of all 3 modalities be required?
assert has_antibody != has_atac, "Strictly one of adata.layers[\"chromatin\"] and adata.layers[\"protein\"] must be " \
                                 "defined."

rna = adata.X
mod2 = adata.layers["protein"] if has_antibody else adata.layers["chromatin"]

# Generate the indices partition -> so that the shuffling can be saved
shuffle_cells = random.sample([x for x in range(rna.shape[0])], k=rna.shape[0])

# shuffle according to these indices
mod2 = mod2[shuffle_cells, :]

with open(par["shuffle_cells_output"], 'w') as shuffle_file:
    shuffle_writer = csv.writer(shuffle_file, delimiter=",")
    shuffle_writer.writerow(shuffle_cells)

censored = anndata.AnnData(
    X=rna,
    layers={
        "modality2": mod2
    },
    uns={
        "dataset_id":adata.uns["dataset_id"],
        "modality2": "protein" if has_antibody else "chromatin"
    }
)

censored.write_h5ad(filename=Path(par["output"]), compression="gzip")