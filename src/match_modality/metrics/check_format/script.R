cat("Load dependencies\n")
library(assertthat, quietly = TRUE, warn.conflicts = FALSE)
requireNamespace("anndata", quietly = TRUE)

## VIASH START
task <- "match_modality"
par <- list(
  input_solution = paste0("resources_test/", task, "/openproblems_bmmc_multiome_starter/openproblems_bmmc_multiome_starter.test_sol.h5ad"),
  input_prediction = paste0("resources_test/", task, "/openproblems_bmmc_multiome_starter/openproblems_bmmc_multiome_starter.prediction.h5ad"),
  output = paste0("resources_test/", task, "/openproblems_bmmc_multiome_starter/openproblems_bmmc_multiome_starter.scores.h5ad")
)
## VIASH END

cat("Read prediction h5ad\n")
ad_sol <- anndata::read_h5ad(par$input_solution)

cat("Checking solution h5ad\n")
correct_format <- tryCatch({
  # read prediction
  ad_pred <- anndata::read_h5ad(par$input_prediction)

  # check dataset id
  dataset_id <- ad_pred$uns[["dataset_id"]]
  assert_that(dataset_id == ad_sol$uns[["dataset_id"]])

  # check method id
  method_id <- ad_pred$uns[["method_id"]]
  assert_that(
    is.character(method_id),
    method_id != ""
  )

  # check X
  assert_that(
    is(ad_pred$X, "sparseMatrix"),
    ad_pred$n_obs == ad_sol$n_obs,
    ad_pred$n_vars == ad_sol$n_vars,
    length(ad_pred$X@x) <= 1000 * ad_sol$n_obs,
    isTRUE(all.equal(
      Matrix::rowSums(ad_pred$X),
      rep(1, ad_pred$n_obs),
      check.attributes = FALSE,
      tolerance = 1e-5
    ))
  )

  1
}, error = function(e) {
  cat("ERROR: ", e$message, "\n", sep = "")
  0
})


cat("Create output object\n")
out <- anndata::AnnData(
  uns = list(
    dataset_id = ad_pred$uns$dataset_id,
    method_id = ad_pred$uns$method_id,
    metric_ids = c("finished", "correct_format"),
    metric_values = c(1, correct_format)
  )
)

cat("Write output to h5ad file\n")
zzz <- out$write_h5ad(par$output, compression = "gzip")
