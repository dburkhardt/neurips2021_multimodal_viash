import anndata as ad
import logging
import numpy as np
from sklearn.metrics import mean_absolute_error, mean_squared_error

## VIASH START
par = {
  "input_solution" : "resources_test/predict_modality/openproblems_bmmc_multiome_starter/openproblems_bmmc_multiome_starter.test_mod2.h5ad"),
  "input_prediction" : "resources_test/predict_modality/openproblems_bmmc_multiome_starter/openproblems_bmmc_multiome_starter.prediction.h5ad"),
  "output" : "openproblems_bmmc_multiome_starter/openproblems_bmmc_multiome_starter.scores.h5ad"
}
## VIASH END

logging.info("Reading solution file")
ad_sol = ad.read_h5ad(par["input_solution"])

logging.info("Reading prediction file")
ad_pred = ad.read_h5ad(par["input_prediction"])

logging.info("Check prediction format")
if not ad_sol.uns["dataset_id"] == ad_pred.uns["dataset_id"]:
    raise ValueError("Prediction and solution have differing dataset_ids")

if not ad_sol.shape == ad_pred.shape:
    raise ValueError("Dataset and prediction anndata objects should have the same shape / dimensions.")


logging.info("Computing MSE metrics")

mse = ((ad_sol.X - ad_pred.X) ** 2).mean()
rmse = np.sqrt(mse)
mae = (np.abs(ad_sol.X - ad_pred.X)).mean()

logging.info("Create output object")
out = ad.AnnData(
  uns = {
    dataset_id = ad_pred.uns["dataset_id"],
    method_id  = ad_pred.uns["method_id"],
    metric_ids = ["mse", "rmse", "mae"],
    metric_values = [mse, rmse, mae],
  }
)

logging.info("Write output to h5ad file")
out.write_h5ad(par["output"], compression=9)
