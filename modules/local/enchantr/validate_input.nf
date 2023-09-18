/*
 * Reformat design file and check validity
 */
process VALIDATE_INPUT {
    tag "$samplesheet"
    label 'immcantation'
    label 'process_single'

    conda "bioconda::r-enchantr=0.1.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker.io/ssnn/suite:prerelease':
        'docker.io/ssnn/suite:prerelease' }"

    input:
    file samplesheet
    path miairr
    val collapseby
    val cloneby

    output:
    path "*/validated_input.tsv", emit: validated_input
    path "*/validated_input_not-valid.tsv", emit: not_valid_input, optional: true
    path "versions.yml", emit: versions

    script:
    """
    Rscript -e "enchantr:::enchantr_report('validate_input', report_params=list('input'='${samplesheet}','collapseby'='${collapseby}','cloneby'='${cloneby}','reassign'='${params.reassign}','miairr'='${miairr}','outdir'=getwd()))"

    echo "\"${task.process}\":" > versions.yml
    Rscript -e "cat(paste0('  enchantr: ',packageVersion('enchantr'),'\n'))" >> versions.yml
    """
}
