/*
========================================================================================
    AMP SCREENING SUBWORKFLOW
========================================================================================
*/

include { MACREL_CONTIGS   } from '../../modules/local/macrel'
include { AMPCOMBI_PARSE   } from '../../modules/local/ampcombi'
include { HMMER_HMMSEARCH  } from '../../modules/local/hmmer'

workflow AMP_SCREENING {
    take:
    fastas // channel: [ val(meta), path(fasta) ]

    main:
    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()
    ch_amp_results = Channel.empty()

    //
    // MODULE: Macrel - AMP prediction using machine learning
    //
    if (!params.amp_skip_macrel) {
        MACREL_CONTIGS ( fastas )
        ch_versions = ch_versions.mix(MACREL_CONTIGS.out.versions.first())
        ch_amp_results = ch_amp_results.mix(MACREL_CONTIGS.out.predictions)
        ch_multiqc_files = ch_multiqc_files.mix(MACREL_CONTIGS.out.stats)
    }

    //
    // MODULE: HMMER - Domain search for AMPs
    //
    if (!params.amp_skip_hmmer) {
        // Prepare HMM models channel
        if (params.amp_hmmer_models) {
            ch_hmm_models = Channel.fromPath(params.amp_hmmer_models)
        } else {
            // Use default AMP HMM models
            ch_hmm_models = Channel.fromPath("${projectDir}/assets/hmm_models/*.hmm")
        }

        HMMER_HMMSEARCH ( 
            fastas,
            ch_hmm_models.collect()
        )
        ch_versions = ch_versions.mix(HMMER_HMMSEARCH.out.versions.first())
        ch_amp_results = ch_amp_results.mix(HMMER_HMMSEARCH.out.hits)
    }

    //
    // MODULE: AMPcombi - Combine results from multiple predictors
    //
    if (!params.amp_skip_ampcombi && !params.amp_skip_macrel) {
        // Collect all results for AMPcombi
        ch_ampcombi_input = ch_amp_results
            .groupTuple(by: 0)
            .map { meta, files -> 
                [ meta, files.flatten() ]
            }

        AMPCOMBI_PARSE ( ch_ampcombi_input )
        ch_versions = ch_versions.mix(AMPCOMBI_PARSE.out.versions.first())
        ch_multiqc_files = ch_multiqc_files.mix(AMPCOMBI_PARSE.out.summary)
    }

    emit:
    results      = ch_amp_results           // channel: [ val(meta), path(results) ]
    versions     = ch_versions              // channel: [ versions.yml ]
    multiqc_files = ch_multiqc_files        // channel: [ multiqc files ]
}
