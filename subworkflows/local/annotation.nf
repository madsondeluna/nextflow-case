/*
========================================================================================
    ANNOTATION SUBWORKFLOW
========================================================================================
*/

include { PEPTIDE_PROPERTIES } from '../../modules/local/peptide_properties'

workflow ANNOTATION {
    take:
    amp_results // channel: [ val(meta), path(amp_predictions) ]

    main:
    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()

    //
    // MODULE: Calculate peptide properties
    //
    PEPTIDE_PROPERTIES ( amp_results )
    ch_versions = ch_versions.mix(PEPTIDE_PROPERTIES.out.versions.first())
    ch_multiqc_files = ch_multiqc_files.mix(PEPTIDE_PROPERTIES.out.properties)

    emit:
    properties   = PEPTIDE_PROPERTIES.out.properties  // channel: [ val(meta), path(properties) ]
    versions     = ch_versions                         // channel: [ versions.yml ]
    multiqc_files = ch_multiqc_files                   // channel: [ multiqc files ]
}
