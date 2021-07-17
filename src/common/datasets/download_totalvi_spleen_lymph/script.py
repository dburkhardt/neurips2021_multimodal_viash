print("Load dependencies")
import urllib.request
import tempfile
import anndata
import scanpy as sc
import pandas as pd

## VIASH START
par = {
    "id": "spleen_lymph_111",
    "input": "https://github.com/YosefLab/totalVI_reproducibility/raw/master/data/spleen_lymph_111.h5ad",
    "output_rna": "output_rna.h5ad",
    "output_mod2": "output_mod2.h5ad"
}
## VIASH END

###############################################################################
###                     DOWNLOAD AND READ DATA.                             ###
###############################################################################
print("Downloading file from", par['input'])
h5ad_temp = tempfile.NamedTemporaryFile()
url = par['input']
urllib.request.urlretrieve(url, h5ad_temp.name)

print("Reading h5ad file")
adata = sc.read_h5ad(h5ad_temp.name)
h5ad_temp.close()

###############################################################################
###                     CREATE H5AD FOR BOTH MODALITIES                     ###
###############################################################################
new_obs = adata.obs.rename(columns = {'cell_types': 'cell_type', 'batch_indices': 'batch'}, inplace = False)

print("Extracting RNA counts")
adata_rna = anndata.AnnData(
    X = adata.X,
    obs = new_obs,
    var = adata.var,
)

adata_rna.var['feature_types'] = "GEX"

print("Extracting ADT counts")
adata_adt = anndata.AnnData(
    X = adata.obsm['protein_expression'],
    obs = new_obs,
    var = pd.DataFrame(index=list(adata.uns['protein_names']))
)
adata_adt.var['feature_types'] = "ADT"

###############################################################################
###                             SAVE OUTPUT                                 ###
###############################################################################
print("Saving output")
adata_rna.write_h5ad(par['output_rna'], compression = "gzip")
adata_adt.write_h5ad(par['output_mod2'], compression = "gzip")

