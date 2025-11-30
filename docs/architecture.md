# Arquitetura do Pipeline AMPscan

## Visão Geral

O AMPscan é um pipeline modular para screening de peptídeos antimicrobianos (AMPs) construído com Nextflow DSL2.

## Fluxo de Dados

```
Input (FASTA) → Validation → AMP Screening → Annotation → Reports
```

## Estrutura de Diretórios

```
nextflow-case/
├── main.nf                      # Ponto de entrada do pipeline
├── nextflow.config              # Configuração principal
├── workflows/
│   └── ampscan.nf              # Workflow principal
├── subworkflows/
│   └── local/
│       ├── input_check.nf      # Validação de entrada
│       ├── amp_screening.nf    # Screening de AMPs
│       └── annotation.nf       # Anotação de peptídeos
├── modules/
│   └── local/
│       ├── samplesheet_check.nf
│       ├── macrel.nf           # Predição ML
│       ├── hmmer.nf            # Busca de domínios
│       ├── ampcombi.nf         # Combinação de resultados
│       └── peptide_properties.nf
├── bin/
│   ├── check_samplesheet.py    # Validação de samplesheet
│   └── calculate_peptide_properties.py
├── lib/
│   ├── WorkflowMain.groovy     # Funções principais
│   └── WorkflowAmpscan.groovy  # Funções específicas
├── conf/
│   ├── base.config             # Recursos computacionais
│   ├── test.config             # Teste mínimo
│   └── test_full.config        # Teste completo
├── assets/
│   └── samplesheet_test.csv    # Dados de teste
└── docs/
    ├── quickstart.md           # Início rápido
    └── usage.md                # Documentação completa
```

## Componentes Principais

### 1. Workflow Principal (workflows/ampscan.nf)

Orquestra todo o pipeline:
- Validação de entrada
- Screening de AMPs
- Anotação
- Geração de relatórios

### 2. Subworkflows

#### input_check.nf
- Valida formato do samplesheet
- Verifica existência de arquivos FASTA
- Cria canais Nextflow

#### amp_screening.nf
- **Macrel**: Predição por machine learning
- **HMMER**: Busca de domínios HMM
- **AMPcombi**: Combinação de resultados

#### annotation.nf
- Calcula propriedades físico-químicas
- Peso molecular, pI, hidrofobicidade
- Estrutura secundária predita

### 3. Módulos

Cada módulo encapsula uma ferramenta específica:

```groovy
process MACREL_CONTIGS {
    input:
    tuple val(meta), path(fasta)
    
    output:
    tuple val(meta), path("*.prediction.gz"), emit: predictions
    
    script:
    """
    macrel contigs --fasta $fasta --output results
    """
}
```

### 4. Configuração

#### nextflow.config
- Parâmetros padrão
- Perfis (docker, singularity, conda)
- Limites de recursos

#### conf/base.config
- Labels de processos (low, medium, high)
- Alocação de CPU/memória
- Estratégias de retry

## Fluxo de Execução Detalhado

```
1. main.nf
   ↓
2. workflows/ampscan.nf
   ↓
3. INPUT_CHECK
   ├── Valida samplesheet
   └── Cria canal de FASTA
   ↓
4. AMP_SCREENING (paralelo por amostra)
   ├── MACREL_CONTIGS
   │   └── Predições de AMPs
   ├── HMMER_HMMSEARCH
   │   └── Domínios conservados
   └── AMPCOMBI_PARSE
       └── Resultados combinados
   ↓
5. ANNOTATION
   └── PEPTIDE_PROPERTIES
       └── Propriedades físico-químicas
   ↓
6. MULTIQC
   └── Relatório consolidado
```

## Canais de Dados

### Entrada
```groovy
ch_input = Channel.fromPath(params.input)
```

### Processamento
```groovy
ch_fastas = [ [meta], path(fasta) ]
ch_predictions = [ [meta], path(predictions) ]
```

### Saída
```groovy
ch_multiqc_files.collect()
```

## Containerização

Cada processo usa um container específico:

```groovy
container "biocontainers/macrel:1.2.0--py39h6935b12_0"
```

Benefícios:
- ✅ Reprodutibilidade
- ✅ Isolamento de dependências
- ✅ Portabilidade

## Paralelização

O pipeline paraleliza automaticamente:
- Por amostra (scatter)
- Por ferramenta (quando independentes)

```
Sample1 ─┬─ Macrel ──┐
         ├─ HMMER ───┤─ AMPcombi
         └─ ...      ┘

Sample2 ─┬─ Macrel ──┐
         ├─ HMMER ───┤─ AMPcombi
         └─ ...      ┘
```

## Gestão de Recursos

### Labels de Processo

```groovy
withLabel:process_low {
    cpus   = 2
    memory = 12.GB
    time   = 4.h
}

withLabel:process_high {
    cpus   = 12
    memory = 72.GB
    time   = 16.h
}
```

### Retry Automático

```groovy
errorStrategy = 'retry'
maxRetries    = 2
```

## Outputs

### Estrutura
```
results/
├── amp/
│   ├── macrel/
│   ├── hmmer/
│   └── ampcombi/
├── annotation/
├── multiqc/
└── pipeline_info/
```

### Publicação
```groovy
publishDir "${params.outdir}/amp/macrel", mode: 'copy'
```

## Extensibilidade

### Adicionar Nova Ferramenta

1. Criar módulo em `modules/local/nova_ferramenta.nf`
2. Adicionar ao subworkflow `amp_screening.nf`
3. Atualizar configuração com parâmetros
4. Adicionar container

### Adicionar Novo Subworkflow

1. Criar em `subworkflows/local/`
2. Incluir em `workflows/ampscan.nf`
3. Conectar canais de entrada/saída

## Boas Práticas Implementadas

- DSL2 modular
- Containers para todas as ferramentas
- Validação de entrada
- Logs detalhados
- Retry automático
- Paralelização eficiente
- Documentação completa
- Testes automatizados

## Referências

- [Nextflow DSL2](https://www.nextflow.io/docs/latest/dsl2.html)
- [nf-core guidelines](https://nf-co.re/developers/guidelines)
- [Nextflow patterns](https://nextflow-io.github.io/patterns/)
