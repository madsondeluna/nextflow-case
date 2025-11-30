process PEPTIDE_PROPERTIES {
    tag "$meta.id"
    label 'process_low'

    conda "bioconda::biopython=1.79"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/biopython:1.79' :
        'biocontainers/biopython:1.79' }"

    input:
    tuple val(meta), path(predictions)

    output:
    tuple val(meta), path("${prefix}_properties.tsv"), emit: properties
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}"
    
    """
    calculate_peptide_properties.py \\
        --input $predictions \\
        --output ${prefix}_properties.tsv \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
        biopython: \$(python -c "import Bio; print(Bio.__version__)")
    END_VERSIONS
    """

    stub:
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_properties.tsv
    touch versions.yml
    """
}
