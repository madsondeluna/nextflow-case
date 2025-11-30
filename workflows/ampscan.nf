/*
========================================================================================
    VALIDATE INPUTS
========================================================================================
*/

def summary_params = NfcoreSchema.paramsSummaryMap(workflow, params)

// Validate input parameters
WorkflowAmpscan.initialise(params, log)

// Check mandatory parameters
if (params.input) { 
    ch_input = file(params.input) 
} else { 
    exit 1, 'Input samplesheet not specified!' 
}

/*
========================================================================================
    IMPORT LOCAL MODULES/SUBWORKFLOWS
========================================================================================
*/

include { INPUT_CHECK       } from '../subworkflows/local/input_check'
include { AMP_SCREENING     } from '../subworkflows/local/amp_screening'
include { ANNOTATION        } from '../subworkflows/local/annotation'

/*
========================================================================================
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
========================================================================================
*/

include { MULTIQC                     } from '../modules/nf-core/multiqc/main'
include { CUSTOM_DUMPSOFTWAREVERSIONS } from '../modules/nf-core/custom/dumpsoftwareversions/main'

/*
========================================================================================
    RUN MAIN WORKFLOW
========================================================================================
*/

workflow AMPSCAN {

    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()

    //
    // SUBWORKFLOW: Read in samplesheet, validate and stage input files
    //
    INPUT_CHECK (
        ch_input
    )
    ch_versions = ch_versions.mix(INPUT_CHECK.out.versions)

    //
    // SUBWORKFLOW: AMP Screening
    //
    if (params.run_amp_screening) {
        AMP_SCREENING (
            INPUT_CHECK.out.fastas
        )
        ch_versions = ch_versions.mix(AMP_SCREENING.out.versions)
        ch_multiqc_files = ch_multiqc_files.mix(AMP_SCREENING.out.multiqc_files)
        
        ch_amp_results = AMP_SCREENING.out.results
    } else {
        ch_amp_results = Channel.empty()
    }

    //
    // SUBWORKFLOW: Annotation
    //
    if (params.run_annotation && params.run_amp_screening) {
        ANNOTATION (
            ch_amp_results
        )
        ch_versions = ch_versions.mix(ANNOTATION.out.versions)
        ch_multiqc_files = ch_multiqc_files.mix(ANNOTATION.out.multiqc_files)
    }

    //
    // MODULE: Dump software versions
    //
    CUSTOM_DUMPSOFTWAREVERSIONS (
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
    )

    //
    // MODULE: MultiQC
    //
    workflow_summary    = WorkflowAmpscan.paramsSummaryMultiqc(workflow, summary_params)
    ch_workflow_summary = Channel.value(workflow_summary)

    methods_description    = WorkflowAmpscan.methodsDescriptionText(workflow, ch_multiqc_custom_methods_description, params)
    ch_methods_description = Channel.value(methods_description)

    ch_multiqc_files = ch_multiqc_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    ch_multiqc_files = ch_multiqc_files.mix(ch_methods_description.collectFile(name: 'methods_description_mqc.yaml'))
    ch_multiqc_files = ch_multiqc_files.mix(CUSTOM_DUMPSOFTWAREVERSIONS.out.mqc_yml.collect())

    MULTIQC (
        ch_multiqc_files.collect(),
        ch_multiqc_config.toList(),
        ch_multiqc_custom_config.toList(),
        ch_multiqc_logo.toList()
    )
}

/*
========================================================================================
    COMPLETION EMAIL AND SUMMARY
========================================================================================
*/

workflow.onComplete {
    if (params.email || params.email_on_fail) {
        NfcoreTemplate.email(workflow, params, summary_params, projectDir, log, multiqc_report)
    }
    NfcoreTemplate.summary(workflow, params, log)
    if (params.hook_url) {
        NfcoreTemplate.IM_notification(workflow, params, summary_params, projectDir, log)
    }
}

/*
========================================================================================
    THE END
========================================================================================
*/
