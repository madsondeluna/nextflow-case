# Estrutura do Projeto AMPscan

```
nextflow-case/
│
├── 📄 main.nf                          # Ponto de entrada do pipeline
├── ⚙️  nextflow.config                  # Configuração principal
├── 🚀 setup.sh                         # Script de instalação
│
├── 📚 Documentação
│   ├── README.md                       # Visão geral do projeto
│   ├── CHANGELOG.md                    # Histórico de versões
│   ├── CITATIONS.md                    # Citações das ferramentas
│   ├── CONTRIBUTING.md                 # Guia de contribuição
│   ├── LICENSE                         # Licença MIT
│   └── docs/
│       ├── quickstart.md              # Início rápido
│       ├── usage.md                   # Guia completo de uso
│       ├── architecture.md            # Arquitetura técnica
│       └── examples.md                # Exemplos práticos
│
├── 🔧 Workflows
│   └── workflows/
│       └── ampscan.nf                 # Workflow principal
│
├── 📦 Subworkflows
│   └── subworkflows/local/
│       ├── input_check.nf             # Validação de entrada
│       ├── amp_screening.nf           # Screening de AMPs
│       └── annotation.nf              # Anotação de peptídeos
│
├── 🧩 Módulos
│   └── modules/local/
│       ├── samplesheet_check.nf       # Validação de samplesheet
│       ├── macrel.nf                  # Predição ML (Macrel)
│       ├── hmmer.nf                   # Busca de domínios (HMMER)
│       ├── ampcombi.nf                # Combinação de resultados
│       └── peptide_properties.nf      # Cálculo de propriedades
│
├── 🐍 Scripts
│   └── bin/
│       ├── check_samplesheet.py       # Validação de samplesheet
│       ├── calculate_peptide_properties.py  # Propriedades físico-químicas
│       └── visualize_results.py       # Visualização de resultados
│
├── 📚 Bibliotecas
│   └── lib/
│       ├── WorkflowMain.groovy        # Funções principais
│       └── WorkflowAmpscan.groovy     # Funções específicas
│
├── ⚙️  Configurações
│   └── conf/
│       ├── base.config                # Recursos computacionais
│       ├── test.config                # Teste mínimo
│       └── test_full.config           # Teste completo
│
└── 📁 Assets
    └── assets/
        ├── samplesheet_test.csv       # Dados de teste
        └── hmm_models/
            └── README.md              # Guia de modelos HMM

```

## Componentes Principais

### 🎯 Workflows (workflows/)
Orquestração de alto nível do pipeline

### 🔄 Subworkflows (subworkflows/)
Agrupamentos lógicos de processos relacionados

### ⚙️ Módulos (modules/)
Processos individuais encapsulando ferramentas específicas

### 🐍 Scripts (bin/)
Scripts auxiliares em Python para processamento de dados

### 📚 Bibliotecas (lib/)
Funções Groovy reutilizáveis

### ⚙️ Configurações (conf/)
Perfis e configurações de recursos

## Fluxo de Dados

```
Input FASTA
    ↓
INPUT_CHECK (validação)
    ↓
AMP_SCREENING (paralelo)
    ├── Macrel (ML)
    ├── HMMER (HMM)
    └── AMPcombi (combinação)
    ↓
ANNOTATION (propriedades)
    ↓
MultiQC (relatórios)
    ↓
Results/
```

## Arquivos Criados

Total: **29 arquivos**

- 📄 Nextflow: 9 arquivos (.nf)
- 🐍 Python: 3 scripts
- 📚 Groovy: 2 bibliotecas
- ⚙️ Config: 4 arquivos
- 📖 Docs: 10 arquivos (.md)
- 🔧 Shell: 1 script

## Próximos Passos

1. ✅ Estrutura completa criada
2. 📝 Documentação abrangente
3. 🧪 Pronto para testes
4. 🚀 Pronto para uso

Para começar: `./setup.sh` ou consulte `docs/quickstart.md`
