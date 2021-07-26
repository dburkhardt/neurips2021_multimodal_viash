## VIASH START
par = dict(
    input_prediction="resources_test/task2/test_resource.prediction.h5ad",
    output="resources_test/task2/test_resource.ari.h5ad",
    debug=True
)

## VIASH END

print('Importing libraries')
import pprint
import scanpy as sc
import anndata
from collections import OrderedDict
from scIB.clustering import opt_louvain
from scIB.metrics import ari

if par['debug']:
    pprint.pprint(par)

OUTPUT_TYPE = 'graph'
METRIC = 'ari'

input_prediction = par['input_prediction']
input_solution = par['input_solution']
output = par['output']

print("Read prediction anndata")
adata_prediction = sc.read(input_prediction)

print("Read solution anndata")
adata_solution = sc.read(input_solution)

print('Merge batch')
adata = adata_prediction
# TODO: proper merge of obs via obs_names
adata.obs['batch'] = adata_solution.obs['batch']
adata.obs['celltype'] = adata_solution.obs['celltype']

print('Preprocessing')
adata.obsm['X_emb'] = adata.X
sc.pp.neighbors(adata, use_rep='X_emb')

print('Clustering')
opt_louvain(
    adata,
    label_key='cell_type',
    cluster_key='cluster',
    plot=False,
    inplace=True,
    force=True
)

print('Compute score')
score = ari(adata, group1='cluster', group2='cell_type')

# store adata with metrics
print("Create output object")
out = anndata.AnnData(
    X=None,
    shape=adata.shape,
    uns=OrderedDict(
        dataset_id=adata.uns['dataset_id'],
        method_id=adata.uns['method_id'],
        metric_ids=[METRIC],
        metric_values=[score],
        metric_moreisbetter=[True]
    )
)

print("Write output to h5ad file")
out.write(output, compression='gzip')
