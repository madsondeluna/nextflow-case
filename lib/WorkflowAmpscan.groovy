# Groovy library for AMPscan workflow
class WorkflowAmpscan {

    //
    // Check and validate parameters
    //
    public static void initialise(params, log) {
        
        // Check AMP screening parameters
        if (params.run_amp_screening) {
            if (params.amp_skip_macrel && params.amp_skip_ampcombi && params.amp_skip_hmmer) {
                log.error "ERROR: All AMP screening tools are disabled. Please enable at least one tool."
                System.exit(1)
            }
            
            if (params.amp_macrel_min_length && params.amp_macrel_min_length < 1) {
                log.error "ERROR: --amp_macrel_min_length must be greater than 0"
                System.exit(1)
            }
        }
    }

    //
    // Get workflow summary for MultiQC
    //
    public static String paramsSummaryMultiqc(workflow, summary) {
        String summary_section = ''
        for (group in summary.keySet()) {
            def group_params = summary.get(group)
            if (group_params) {
                summary_section += "    <p style=\"font-size:110%\"><b>$group</b></p>\n"
                summary_section += "    <dl class=\"dl-horizontal\">\n"
                for (param in group_params.keySet()) {
                    summary_section += "        <dt>$param</dt><dd><samp>${group_params.get(param) ?: '<span style=\"color:#999999;\">N/A</a>'}</samp></dd>\n"
                }
                summary_section += "    </dl>\n"
            }
        }

        String yaml_file_text  = "id: '${workflow.manifest.name.replace('/','-')}-summary'\n"
        yaml_file_text        += "description: ' - this information is collected when the pipeline is started.'\n"
        yaml_file_text        += "section_name: '${workflow.manifest.name} Workflow Summary'\n"
        yaml_file_text        += "section_href: 'https://github.com/${workflow.manifest.name}'\n"
        yaml_file_text        += "plot_type: 'html'\n"
        yaml_file_text        += "data: |\n"
        yaml_file_text        += "${summary_section}"
        return yaml_file_text
    }

    //
    // Get methods description for MultiQC
    //
    public static String methodsDescriptionText(workflow, mqc_methods_yaml, params) {
        def meta = [:]
        meta.workflow = workflow.toMap()
        meta.summary = [:]
        
        if (workflow.revision) {
            meta.summary.Pipeline_revision = workflow.revision
        }
        
        meta.summary.Nextflow_version = workflow.nextflow.version
        
        if (params.run_amp_screening) {
            def amp_tools = []
            if (!params.amp_skip_macrel) amp_tools.add("Macrel")
            if (!params.amp_skip_hmmer) amp_tools.add("HMMER")
            if (!params.amp_skip_ampcombi) amp_tools.add("AMPcombi")
            meta.summary.AMP_screening_tools = amp_tools.join(", ")
        }

        String methods_text = mqc_methods_yaml.text

        return methods_text
    }
}
