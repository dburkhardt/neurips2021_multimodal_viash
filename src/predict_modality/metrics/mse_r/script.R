cat("Load dependencies\n")
options(tidyverse.quiet = TRUE)
library(tidyverse)
library(testthat, quietly = TRUE, warn.conflicts = FALSE)
library(Matrix, quietly = TRUE, warn.conflicts = FALSE)
requireNamespace("anndata", quietly = TRUE)

## VIASH START
par <- list(
  input_solution = c("resources_test/predict_modality/openproblems_bmmc_multiome_starter/openproblems_bmmc_multiome_starter.test_mod2.h5ad"),
  input_prediction = c("resources_test/predict_modality/openproblems_bmmc_multiome_starter/openproblems_bmmc_multiome_starter.prediction.h5ad"),
  output = "openproblems_bmmc_multiome_starter/openproblems_bmmc_multiome_starter.scores.h5ad"
)
## VIASH END

cat("Reading solution file\n")
ad_sol <- anndata::read_h5ad(par$input_solution)

cat("Reading prediction file\n")
ad_pred <- anndata::read_h5ad(par$input_prediction)

cat("Check prediction format\n")
expect_equal(
  ad_sol$uns$dataset_id, ad_pred$uns$dataset_id,
  info = "Prediction and solution have differing dataset_ids"
)
expect_true(
  isTRUE(all.equal(dim(ad_sol), dim(ad_pred))),
  info = "Dataset and prediction anndata objects should have the same shape / dimensions."
)

cat("Computing MSE metrics\n")
# Wrangle data
comp <-
  full_join(
    summary(ad_sol$X) %>% rename(solx = x),
    summary(ad_pred$X) %>% rename(predx = x),
    by = c("i", "j")
  ) %>%
  select(-i, -j) %>%
  mutate(
    solx = ifelse(is.na(solx), 0, solx),
    predx = ifelse(is.na(predx), 0, predx),
  )
scores <- comp %>%
  summarise(
    mse = sum((solx - predx)^2) / length(ad_pred$X),
    rmse = sqrt(mse),
    logp1_mse = log10(mse + 1),
    logp1_rmse = log10(rmse + 1),
    mae = sum(abs(solx - predx)) / length(ad_pred$X)
  )

cat("Create output object\n")
out <- anndata::AnnData(
  uns = list(
    dataset_id = ad_pred$uns$dataset_id,
    method_id = ad_pred$uns$method_id,
    metric_ids = names(scores),
    metric_values = as.vector(as.matrix(scores))
  )
)

cat("Write output to h5ad file\n")
zzz <- out$write_h5ad(par$output, compression = "gzip")
