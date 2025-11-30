# AMPscan - Pipeline de Análise de Peptídeos Antimicrobianos

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A523.04.0-23aa62.svg)](https://www.nextflow.io/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)

## Introdução

**AMPscan** é um pipeline de bioinformática desenvolvido com Nextflow para screening e análise de peptídeos antimicrobianos (AMPs) em sequências nucleotídicas. Inspirado no nf-core/funcscan, este pipeline oferece uma abordagem modular e reprodutível para identificação de AMPs.

## Características Principais

-  **Múltiplas ferramentas de predição**: Macrel, AMPcombi, HMMER
-  **Análise de sequências**: Suporte para contigs montados (FASTA)
-  **Anotação funcional**: Predição de estrutura e propriedades
-  **Containerização**: Docker/Singularity para reprodutibilidade
-  **Modular**: Baseado em Nextflow DSL2

## Pipeline Overview

O pipeline executa as seguintes etapas principais:

1. **Input Validation**: Validação do samplesheet e arquivos FASTA
2. **AMP Screening**: 
   - Macrel: Predição baseada em machine learning
   - AMPcombi: Combinação de múltiplos preditores
   - HMMER: Busca por domínios conservados
3. **Annotation**: Anotação de propriedades físico-químicas
4. **Results Aggregation**: Consolidação e sumarização dos resultados

## Início Rápido

### Pré-requisitos

- Nextflow >= 23.04.0
- Docker ou Singularity (recomendado para HPC)
- Java >= 11

### Instalação

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/nextflow-case.git
cd nextflow-case

# Teste a instalação
nextflow run main.nf --help
```

### Uso Básico

```bash
# Executar com dados de exemplo
nextflow run main.nf \
  --input samplesheet.csv \
  --outdir results \
  -profile docker

# Executar apenas Macrel
nextflow run main.nf \
  --input samplesheet.csv \
  --outdir results \
  --amp_skip_ampcombi \
  --amp_skip_hmmer \
  -profile docker
```

### Formato do Samplesheet

O arquivo `samplesheet.csv` deve conter:

```csv
sample,fasta
sample1,/path/to/sample1.fasta
sample2,/path/to/sample2.fasta
```

## Parâmetros Principais

### Obrigatórios

- `--input`: Caminho para o samplesheet CSV
- `--outdir`: Diretório de saída para os resultados

### Opcionais - AMP Screening

- `--run_amp_screening`: Executar screening de AMPs (default: true)
- `--amp_skip_macrel`: Pular Macrel (default: false)
- `--amp_skip_ampcombi`: Pular AMPcombi (default: false)
- `--amp_skip_hmmer`: Pular HMMER (default: false)
- `--amp_hmmer_models`: Modelos HMM customizados para HMMER
- `--amp_macrel_min_length`: Tamanho mínimo de peptídeo para Macrel (default: 10)

### Recursos Computacionais

- `--max_cpus`: Número máximo de CPUs (default: 16)
- `--max_memory`: Memória máxima (default: '128.GB')
- `--max_time`: Tempo máximo por job (default: '240.h')

## Estrutura de Saída

```
results/
├── amp/
│   ├── macrel/
│   │   ├── sample1_predictions.tsv
│   │   └── sample2_predictions.tsv
│   ├── ampcombi/
│   │   └── combined_results.tsv
│   └── hmmer/
│       ├── sample1_domains.txt
│       └── sample2_domains.txt
├── annotation/
│   └── amp_properties.tsv
├── multiqc/
│   └── multiqc_report.html
└── pipeline_info/
    ├── execution_report.html
    └── execution_timeline.html
```

## Perfis de Configuração

- `docker`: Usa containers Docker
- `singularity`: Usa containers Singularity
- `conda`: Usa ambientes Conda (não recomendado)
- `test`: Executa com dados de teste mínimos

## Ferramentas Incluídas

| Ferramenta | Versão | Descrição |
|------------|--------|-----------|
| Macrel | 1.2.0 | Predição de AMPs por machine learning |
| AMPcombi | 0.1.7 | Agregação de múltiplos preditores |
| HMMER | 3.3.2 | Busca de domínios por HMM |
| Prodigal | 2.6.3 | Predição de genes |

## Citações

Se você usar este pipeline, por favor cite:

- **Nextflow**: Di Tommaso, P., et al. (2017). Nextflow enables reproducible computational workflows. Nature Biotechnology, 35(4), 316-319.
- **Macrel**: Santos-Júnior, C.D., et al. (2020). Macrel: antimicrobial peptide screening in genomes and metagenomes. PeerJ, 8, e10555.

## Contribuindo

Contribuições são bem-vindas! Por favor, abra uma issue ou pull request.

## Licença

MIT License

## Contato

Para questões e suporte, abra uma issue no GitHub.

---

Desenvolvido com ❤️ usando Nextflow
