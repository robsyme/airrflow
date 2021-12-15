include { initOptions; saveFiles; getSoftwareName } from '../functions'

params.options = [:]
def options    = initOptions(params.options)

process FIND_THRESHOLD {
    tag "all_reps"
    label 'immcantation'
    label 'enchantr'
    label 'process_long'

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    conda (params.enable_conda ? "bioconda::changeo=1.0.2 bioconda::igblast=1.15.0" : null)              // Conda package

    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/mulled-v2-2665a8a48fa054ad1fcccf53e711669939b3eac1:09e1470e7d75ed23a083425eb01ce0418c9e8827-0"  // Singularity image
    } else {
        container "quay.io/biocontainers/mulled-v2-2665a8a48fa054ad1fcccf53e711669939b3eac1:09e1470e7d75ed23a083425eb01ce0418c9e8827-0"                        // Docker image
    }

    input:
    path tab // tuple val(meta) // sequence tsv in AIRR format
    val(cloneby)
    val(singlecell)


    output:
    tuple val(meta), path("*threshold-pass.tsv"), emit: tab // sequence tsv in AIRR format
    path("*_command_log.txt"), emit: logs //process logs
    path "*_report"
    path "*_threshold-summary.tsv"
    path "*_threshold-mean.tsv"
    env mean_threshold, emit: mean_threshold

    script:
    meta=[]
    """
    Rscript -e "enchantr::enchantr_report('find_threshold', report_params=list('input'='${tab.join(',')}','cloneby'='${cloneby}','singlecell'='${singlecell}','outdir'=getwd(), 'nproc'=${task.cpus},'outname'='all_reps', 'log'='all_reps_clone_command_log'))"
    mean_threshold="\$(cat all_reps_threshold-mean.tsv)"
    mv enchantr all_reps_dist_report
    """

}
