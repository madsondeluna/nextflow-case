process AMPCOMBI_PARSE {
    tag "$meta.id"
    label 'process_low'

    conda "bioconda::ampcombi=0.1.7"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ampcombi:0.1.7--pyhdfd78af_0' :
        'biocontainers/ampcombi:0.1.7--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(predictions)

    output:
    tuple val(meta), path("${prefix}/*_ampcombi.tsv"), emit: combined
    tuple val(meta), path("${prefix}/*_summary.tsv"), emit: summary
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}"
    
    """
    mkdir -p ${prefix}

    ampcombi \\
        --input_dir . \\
        --output_dir ${prefix} \\
        --sample_name ${prefix} \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        ampcombi: \$(ampcombi --version 2>&1 | sed 's/ampcombi, version //g')
    END_VERSIONS
    """

    stub:
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir -p ${prefix}
    touch ${prefix}/${prefix}_ampcombi.tsv
    touch ${prefix}/${prefix}_summary.tsv
    touch versions.yml
    """
}
