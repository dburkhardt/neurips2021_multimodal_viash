#!/bin/bash

# run prior to running this script:
# bin/viash_build -q 'common|predict_modality'

set -ex

# get the root of the directory
REPO_ROOT=$(git rev-parse --show-toplevel)

# ensure that the command below is run from the root of the repository
cd "$REPO_ROOT"

target_dir=target/docker
in_file=resources_test/common/test_resource
out_file=resources_test/predict_modality/test_resource
mkdir -p `dirname $out_file`

$target_dir/predict_modality_datasets/censor_dataset/censor_dataset \
  --input_mod1 ${in_file}.output_rna.h5ad \
  --input_mod2 ${in_file}.output_mod2.h5ad \
  --output_train_mod1 ${out_file}.train_mod1.h5ad \
  --output_train_mod2 ${out_file}.train_mod2.h5ad \
  --output_test_mod1 ${out_file}.test_mod1.h5ad \
  --output_test_mod2 ${out_file}.test_mod2.h5ad
  
$target_dir/predict_modality_methods/baseline_randomforest/baseline_randomforest \
  --input_train_mod1 ${out_file}.train_mod1.h5ad \
  --input_train_mod2 ${out_file}.train_mod2.h5ad \
  --input_test_mod1 ${out_file}.test_mod1.h5ad \
  --output ${out_file}.prediction.h5ad
  
$target_dir/predict_modality_metrics/calculate_cor/calculate_cor \
  --input_prediction ${out_file}.prediction.h5ad \
  --input_solution ${out_file}.test_mod2.h5ad \
  --output ${out_file}.scores.h5ad

$target_dir/common/extract_scores/extract_scores \
  --input ${out_file}.scores.h5ad \
  --metric_meta src/predict_modality/metrics/calculate_cor/metric_meta.tsv \
  --output ${out_file}.scores.tsv \
  --summary ${out_file}.summary.tsv