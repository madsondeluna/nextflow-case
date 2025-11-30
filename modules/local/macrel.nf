process MACREL_CONTIGS {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::macrel=1.2.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/macrel:1.2.0--py39h6935b12_0':
        'biocontainers/macrel:1.2.0--py39h6935b12_0' }"

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path("${prefix}/*.prediction.gz")     , emit: predictions
    tuple val(meta), path("${prefix}/*.all_orfs.faa.gz")   , emit: orfs
    tuple val(meta), path("${prefix}/*.smorfs.faa.gz")     , emit: smorfs, optional: true
    tuple val(meta), path("${prefix}/*.log")               , emit: log
    tuple val(meta), path("${prefix}/*.stats.tsv")         , emit: stats
    path "versions.yml"                                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}"
    def min_length = params.amp_macrel_min_length ?: 10
    def max_length = params.amp_macrel_max_length ?: 100
    
    """
    macrel contigs \\
        --fasta $fasta \\
        --output ${prefix} \\
        --tag ${prefix} \\
        --minlength $min_length \\
        --maxlength $max_length \\
        --threads $task.cpus \\
        $args

    # Compress outputs
    gzip ${prefix}/*.prediction
    gzip ${prefix}/*.all_orfs.faa
    [ -f ${prefix}/*.smorfs.faa ] && gzip ${prefix}/*.smorfs.faa || true

    # Generate stats for MultiQC
    echo -e "Sample\\tTotal_ORFs\\tAMPs_predicted" > ${prefix}/${prefix}.stats.tsv
    TOTAL_ORFS=\$(zcat ${prefix}/*.all_orfs.faa.gz | grep -c "^>" || echo "0")
    AMPS=\$(zcat ${prefix}/*.prediction.gz | tail -n +2 | wc -l)
    echo -e "${prefix}\\t\$TOTAL_ORFS\\t\$AMPS" >> ${prefix}/${prefix}.stats.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        macrel: \$(macrel --version 2>&1 | sed 's/macrel //g')
    END_VERSIONS
    """

    stub:
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir -p ${prefix}
    touch ${prefix}/${prefix}.prediction.gz
    touch ${prefix}/${prefix}.all_orfs.faa.gz
    touch ${prefix}/${prefix}.log
    touch ${prefix}/${prefix}.stats.tsv
    touch versions.yml
    """
}
