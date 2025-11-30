process HMMER_HMMSEARCH {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::hmmer=3.3.2"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/hmmer:3.3.2--h1b792b2_1' :
        'biocontainers/hmmer:3.3.2--h1b792b2_1' }"

    input:
    tuple val(meta), path(fasta)
    path hmm_models

    output:
    tuple val(meta), path("*.tblout.txt"), emit: hits
    tuple val(meta), path("*.domtblout.txt"), emit: domain_hits
    tuple val(meta), path("*.txt"), emit: output
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    
    """
    # Concatenate all HMM models if multiple
    cat ${hmm_models} > combined_models.hmm

    hmmsearch \\
        --cpu $task.cpus \\
        --tblout ${prefix}.tblout.txt \\
        --domtblout ${prefix}.domtblout.txt \\
        -o ${prefix}.txt \\
        $args \\
        combined_models.hmm \\
        $fasta

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        hmmer: \$(hmmsearch -h | grep -o '^# HMMER [0-9.]*' | sed 's/^# HMMER *//')
    END_VERSIONS
    """

    stub:
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.tblout.txt
    touch ${prefix}.domtblout.txt
    touch ${prefix}.txt
    touch versions.yml
    """
}
