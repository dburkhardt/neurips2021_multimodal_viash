nextflow.enable.dsl=2

srcDir = "${params.rootDir}/src"
targetDir = "${params.rootDir}/target/nextflow"
task = "predict_modality"

include  { baseline_randomforest }       from "$targetDir/${task}_methods/baseline_randomforest/main.nf"      params(params)
include  { baseline_linearmodel }        from "$targetDir/${task}_methods/baseline_linearmodel/main.nf"       params(params)
include  { baseline_knn }  from "$targetDir/${task}_methods/baseline_knn/main.nf" params(params)
include  { baseline_babel }              from "$targetDir/${task}_methods/baseline_babel/main.nf"             params(params)
include  { dummy_zeros }                 from "$targetDir/${task}_methods/dummy_zeros/main.nf"                params(params)
include  { dummy_constant }              from "$targetDir/${task}_methods/dummy_constant/main.nf"             params(params)
include  { dummy_random }                from "$targetDir/${task}_methods/dummy_random/main.nf"               params(params)
include  { dummy_solution }              from "$targetDir/${task}_methods/dummy_solution/main.nf"             params(params)
include  { correlation }                 from "$targetDir/${task}_metrics/correlation/main.nf"                params(params)
include  { msle }                        from "$targetDir/${task}_metrics/msle/main.nf"                       params(params)
include  { check_format }                from "$targetDir/${task}_metrics/check_format/main.nf"               params(params)
include  { extract_scores }              from "$targetDir/common/extract_scores/main.nf"                      params(params)
include  { bind_tsv_rows }               from "$targetDir/common/bind_tsv_rows/main.nf"                       params(params)
include  { getDatasetId as get_id_predictions; getDatasetId as get_id_solutions } from "$srcDir/common/workflows/anndata_utils.nf"

workflow pilot_wf {
  main:

  // get input files for methods
  def inputs = 
    Channel.fromPath("output/public_datasets/$task/**.h5ad")
      | map { [ it.getParent().baseName, it ] }
      | filter { !it[1].name.contains("output_test_mod2") }
      | groupTuple
      | map { id, datas -> 
        def fileMap = datas.collectEntries { [ (it.name.split(/\./)[-2].replace("output_", "input_")), it ]}
        [ id, fileMap, params ]
      }
  
  // get solutions
  def solution = 
    Channel.fromPath("output/public_datasets/$task/**.h5ad")
      | map { [ it.getParent().baseName, it ] }
      | filter { it[1].name.contains("output_test_mod2") }

  // for now, code needs one of these code blocks per method.
  def b0 = inputs 
    | baseline_randomforest
    | join(solution)
    | map { id, pred, params, sol -> [ id + "_baseline_randomforest", [ input_prediction: pred, input_solution: sol ], params ]}
  def b1 = inputs 
    | baseline_linearmodel
    | join(solution)
    | map { id, pred, params, sol -> [ id + "_baseline_linearmodel", [ input_prediction: pred, input_solution: sol ], params ]}
  def b2 = inputs 
    | baseline_knn
    | join(solution)
    | map { id, pred, params, sol -> [ id + "_baseline_knn", [ input_prediction: pred, input_solution: sol ], params ]}
  def b3 = inputs 
    | baseline_babel
    | join(solution)
    | map { id, pred, params, sol -> [ id + "_baseline_babel", [ input_prediction: pred, input_solution: sol ], params ]}

  def d0 = inputs 
    | dummy_zeros
    | join(solution)
    | map { id, pred, params, sol -> [ id + "_dummy_zeros", [ input_prediction: pred, input_solution: sol ], params ]}
  def d1 = inputs 
    | dummy_constant
    | join(solution)
    | map { id, pred, params, sol -> [ id + "_dummy_constant", [ input_prediction: pred, input_solution: sol ], params ]}
  def d2 = inputs 
    | dummy_random
    | join(solution)
    | map { id, pred, params, sol -> [ id + "_dummy_random", [ input_prediction: pred, input_solution: sol ], params ]}
  def d3 = solution
    | map { id, input -> [ id, input, params ] }  
    | dummy_solution
    | join(solution)
    | map { id, pred, params, sol -> [ id + "_dummy_solution", [ input_prediction: pred, input_solution: sol ], params ]}

  def predictions = b0.mix(b1, b2, b3, d0, d1, d2, d3)

  // fetch dataset ids in predictions and in solutions
  def prediction_dids = predictions | map { it[1].input_prediction } | get_id_predictions
  def solution_dids = solution | map { it[1] } | get_id_solutions

  // create solutions meta
  def solutionsMeta = solution_dids
    | map{ it[0] }
    | collectFile(name: "solutions_meta.tsv", newLine: true, seed: "dataset_id")
  
  // create metrics meta
  def metricsMeta = 
    Channel.fromPath("$srcDir/$task/**/metric_meta*.tsv")
      | toList()
      | map{ [ "meta", it, params ] }
      | bind_tsv_rows
      | map{ it[1] }

  // compute metrics & combine results
  predictions
    | (correlation & msle & check_format)
    | mix
    | toList()
    | map{ [ it.collect{it[1]} ] }
    | combine(metricsMeta)
    | combine(solutionsMeta)
    | map{ [ "output", [ input: it[0], metric_meta: it[1], dataset_meta: it[2] ], params ] }
    | extract_scores
}
