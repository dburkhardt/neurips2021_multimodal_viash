# neurips2021_multimodal_viash 1.0.1

## MINOR CHANGES

* Reduce default memory consumption for starter kits to 10GB.

* Rewrite starter kit code so it clears memory more quickly.

* Add separate system check script to starter kits.

## BUG FIXES

* Fix Match Modality method unit test.


# neurips2021_multimodal_viash 1.0.0

## NEW FEATURES

Common:

* Dataset processor: Added a component for computing pseudotime scores
  if none are provided.

* Dataset processor: Added a component for simulating batch effects if 
  dataset doesn't consist of multiple batches.

* Dataset processor: Added a component for generating cell type labels if 
  if none are provided.

* NextFlow: Added resource labels to better specify a components resource requirements.
  - CPU: { lowcpu: 2, midcpu: 4, highcpu: 15, vhighcpu: 30 }
  - Memory: { lowmem: 10 GB, midmem: 20 GB, highmem: 55 GB, vhighmem: 110 GB }
  - Time: { lowtime: 10m, midtime: 20m, hightime: 60m }

Task 1, Predict Modality:
* Testing: Added reusable unit test¹ for method components and starter kits.
* Testing: Added reusable unit test¹ for metrics.
* Metric: Added MSE and MSLE metrics.
* Dummy Method: Added a random dummy method.

Task 2, Match Modality:
* Testing: Added reusable unit test¹ for method components and starter kits.
* Testing: Added reusable unit test¹ for metrics.
* Metric: Added a match probability metric.
* Metric: Also compute AUROC and AUPR of whether cell type labels match.

Task 3, Joint Embedding:
* Testing: Added reusable unit test¹ for method components and starter kits.
* Testing: Added reusable unit test¹ for metrics.
* Metric: Added Cell Cycle Conservation, Trajectory Conservation and Graph Connectivity metrics.


## MAJOR CHANGES

Common:
* Extract scores: Return table in long instead of wide format.

Task 1, Predict Modality:
* Censoring: The expression matrices passed to methods are log-transformed and normalised (if size factors were computed).

## MINOR CHANGES

Common:
* Dataset loader: dyngen always simulates a linear trajectory. 
  The component now also outputs pseudotime and cell cycle information.

## BUG FIXES

Task 2, Match Modality:
* Methods: Set dimensionality of sparse matrices to match expected dimensionality.
* Dummy methods: Set dimensionality of sparse matrices to match expected dimensionality.
* Starter kits: Set dimensionality of sparse matrices to match expected dimensionality.
* Censor component: Fix solution object (forgot to include an np.argsort)

## NOTES

¹ Requires viash 0.5.3.

# neurips2021_multimodal_viash 0.5.0

## NEW FEATURES

Common:
* Dataset loader: Added babel_GM12878 dataset.
* Dataset processing: Added component for creating a train/test split.
* Dataset processing: Added component for creating starter kits.

Task 1, Predict Modality:
* Metric: Added component for checking the format of a prediction.
* Starter Kit: Added starter kit for Python users.
* NextFlow: Added pipeline for running the pilot.

Task 2, Match Modality
* Metric: Added component for checking the format of a prediction.
* NextFlow: Added pipeline for running the pilot.
* NextFlow: Added pipeline for generating a submission.
* NextFlow: Added pipeline for evaluating a submission.

Task 3, Joint Embedding:
* Metric: Added component for computing the 'latent_mixing_metric' metric from TotalVI.
* Metric: Added component for checking the format of a prediction.
* NextFlow: Added pipeline for running the pilot.
* NextFlow: Added pipeline for generating a submission.
* NextFlow: Added pipeline for evaluating a submission.
* Starter Kit: Added starter kit for Python users.
* Starter Kit: Added starter kit for R users.

## MAJOR CHANGES

* Refactored Task 2, Match Modality into a supervised problem with a train/test split.
  Train data, test data and pairings data are stored in separate files.

# neurips2021_multimodal_viash 0.4.0

## NEW FEATURES

Common:
* Prediction gatekeeper: Add a gatekeeper component for method predictions.
* Bind TSV rows: Added a component for binding the rows of multiple TSV files.

Task 1, Predict modality:

* Method: Added Babel. It takes quite long to run and is expected to crash on 
  small datasets or RNA+ADT datasets.
* Dummy method: Added a method for predicting all zeros.

Task 2, Match Modality:

* Dummy methods: Added methods for predicting all zeros or all ones.
* Baseline method: Added procrustes method.
* NextFlow: Added pipeline for censoring common datasets.

Task 3, Joint Embedding:

* Method: Added TotalVI.
* NextFlow: Added pipeline for censoring common datasets.
* Metric: Added scIB metrics: ARI, ASW batch, ASW label, NMI.

## MINOR CHANGES

* Renamed location of datasets produced by NextFlow pipelines:
  - `output/common_datasets` became `output/public_datasets/common`.
  - `output/task1` became `output/public_datasets/predict_modality`.
  - `output/task2` became `output/public_datasets/match_modality`.
  - `output/task3` became `output/public_datasets/joint_embedding`.

* Task 1 correlation metric: Reverted allowing multiple input files at once.

* Metrics: Metrics across all tasks now require a `metric_meta.tsv` file 
  to be available in the component directory. This tsv file needs to 
  contain the columns `metric_id`, `metric_min`, `metric_max` and `metric_higherisbetter`.
  In addition, metric components no longer need to output a `.uns['metric_moreisbetter']` 
  field, as this is contained in the metric meta file.

* Extract scores: Will check for missing predictions when provided with the 
  method meta data. Requires a metrics meta file, can optionally consume
  a methods and datasets meta file.

# neurips2021_multimodal_viash 0.3.0

## NEW FEATURES

* Task 2: Added dataset censoring component.
* Task 2: Added baseline methods PCA: LMDS and UMAP.
* Task 2: Added metric: Random Forest OOB Percentage of correct predictions.
* Task 3: Added baseline method: Distance optimization.
* Task 3: Added metric: AUROC and AUPR score.

## MINOR CHANGES

* Common: Extract scores component also outputs a summary tsv.
* Common: Relevel factors in `.obs` and `.var` after QC filtering.
* Task 1: Use `.obs["batch"]` to split up cells in `"train"` and `"test"`, if batch is available.
* Task 1: Make the metric component be able to evaluate many outputs at once.

## BUG FIXES

* Common: Don't forget to set dataset ids for Azimuth and TotalVI datasets.


# neurips2021_multimodal_viash 0.2.0

## NEW FEATURES

* Common: Dataset generator for 1 Azimuth dataset
* Common: Dataset generator for 2 TotalVI Spleen Lymph datasets.
* Common: Dataset generator for 3 TotalVI 10x datasets
* Task 1: R starter Kit for task 1.


# neurips2021_multimodal_viash 0.1.0

Initial release of the OpenProblems / NeurIPS 2021 Multimodal viash evaluation pipeline.

## FEATURES

### Common components
* API descriptions for the dataset generator components.
* Dataset generator for 12 10x public datasets.
* Dataset generator for 16 dyngen simulated datasets.
* Rudimentary dataset filtering component (Needs more work).
* NextFlow pipeline for generating and filtering all the datasets.

### Task 1 components
* API descriptions for task 1 censoring, method and metric components.
* Dataset censoring component.
* Three baseline methods: Random Forests, Linear Model, and KNN Regression.
* Three metrics: Pearson correlation, Spearman correlation, and RMSE.
* Nextflow pipelines for:
  - Censoring common datasets
  - Generating a submission
  - Evaluating a submission
  - Running the baseline methods and evaluating them.

### Task 2 components
* API descriptions for task 2 censoring, method and metric components.

### Task 3 components
* API descriptions for task 3 censoring, method and metric components.
* Dataset censoring component.
* Dummy PCA method.

## KNOWN ISSUES

Unit tests are not working for now. We stopped updating them in order to implement more functionality quicker.