# Guia de Uso - AMPscan

## Índice

1. [Instalação](#instalação)
2. [Preparação de Dados](#preparação-de-dados)
3. [Executando o Pipeline](#executando-o-pipeline)
4. [Interpretando Resultados](#interpretando-resultados)
5. [Casos de Uso Comuns](#casos-de-uso-comuns)
6. [Troubleshooting](#troubleshooting)

## Instalação

### Pré-requisitos

1. **Nextflow** (>= 23.04.0)
```bash
curl -s https://get.nextflow.io | bash
sudo mv nextflow /usr/local/bin/
```

2. **Docker** ou **Singularity**
   - Docker: https://docs.docker.com/get-docker/
   - Singularity: https://sylabs.io/guides/3.0/user-guide/installation.html

### Clone do Repositório

```bash
git clone https://github.com/madsondeluna/nextflow-case.git
cd nextflow-case
```

## Preparação de Dados

### Formato do Samplesheet

Crie um arquivo CSV com as seguintes colunas:

```csv
sample,fasta
amostra1,/caminho/para/amostra1.fasta
amostra2,/caminho/para/amostra2.fasta
```

**Requisitos:**
- Coluna `sample`: Nome único da amostra (sem espaços)
- Coluna `fasta`: Caminho completo para arquivo FASTA
- Arquivos FASTA devem conter sequências nucleotídicas (contigs montados)

### Exemplo de FASTA

```
>contig_1
ATGAAACGCATTAGCACCACCATTACCACCACCATCACCATTACCACAGGTAACGGTGCG
GGCTGA
>contig_2
ATGAGCGAACAACTTATTGCTTTATTTGCAGGTGTTGCAGGCGGTGTTGCAGGCGGTGTT
```

## Executando o Pipeline

### Execução Básica

```bash
nextflow run main.nf \
  --input samplesheet.csv \
  --outdir results \
  -profile docker
```

### Opções Avançadas

#### 1. Executar apenas Macrel

```bash
nextflow run main.nf \
  --input samplesheet.csv \
  --outdir results \
  --amp_skip_ampcombi \
  --amp_skip_hmmer \
  -profile docker
```

#### 2. Customizar parâmetros do Macrel

```bash
nextflow run main.nf \
  --input samplesheet.csv \
  --outdir results \
  --amp_macrel_min_length 15 \
  --amp_macrel_max_length 80 \
  -profile docker
```

#### 3. Usar modelos HMM customizados

```bash
nextflow run main.nf \
  --input samplesheet.csv \
  --outdir results \
  --amp_hmmer_models /caminho/para/modelos/*.hmm \
  -profile docker
```

#### 4. Executar em ambiente HPC com Singularity

```bash
nextflow run main.nf \
  --input samplesheet.csv \
  --outdir results \
  --max_cpus 32 \
  --max_memory 128.GB \
  -profile singularity
```

### Perfis Disponíveis

- `docker`: Usa containers Docker (recomendado para uso local)
- `singularity`: Usa containers Singularity (recomendado para HPC)
- `conda`: Usa ambientes Conda (não recomendado)
- `test`: Executa com dados de teste

## Interpretando Resultados

### Estrutura de Saída

```
results/
├── amp/                          # Resultados de predição de AMPs
│   ├── macrel/
│   │   ├── sample1/
│   │   │   ├── sample1.prediction.gz    # Predições de AMPs
│   │   │   ├── sample1.all_orfs.faa.gz  # Todas as ORFs
│   │   │   └── sample1.stats.tsv        # Estatísticas
│   ├── hmmer/
│   │   └── sample1.tblout.txt           # Hits de domínios
│   └── ampcombi/
│       └── combined_results.tsv         # Resultados combinados
├── annotation/
│   └── sample1_properties.tsv           # Propriedades físico-químicas
├── multiqc/
│   └── multiqc_report.html              # Relatório consolidado
└── pipeline_info/
    ├── execution_report.html            # Relatório de execução
    └── execution_timeline.html          # Timeline de execução
```

### Arquivo de Predições (Macrel)

Formato TSV com colunas:
- `sequence_id`: ID da sequência
- `sequence`: Sequência do peptídeo
- `AMP_probability`: Probabilidade de ser AMP (0-1)
- `AMP_family`: Família predita do AMP

### Arquivo de Propriedades

Propriedades físico-químicas calculadas:
- `length`: Comprimento do peptídeo
- `molecular_weight`: Peso molecular (Da)
- `isoelectric_point`: Ponto isoelétrico
- `charge_at_pH7`: Carga em pH 7
- `gravy`: Índice de hidrofobicidade
- `helix_fraction`: Fração de α-hélice
- `sheet_fraction`: Fração de β-folha

## Casos de Uso Comuns

### 1. Screening de Genomas Bacterianos

```bash
# Preparar samplesheet com genomas montados
cat > genomes.csv << EOF
sample,fasta
ecoli,/data/genomes/ecoli_assembly.fasta
staph,/data/genomes/staph_assembly.fasta
EOF

# Executar pipeline completo
nextflow run main.nf \
  --input genomes.csv \
  --outdir amp_results \
  -profile docker
```

### 2. Análise de Metagenomas

```bash
# Para metagenomas, use contigs montados
nextflow run main.nf \
  --input metagenome_contigs.csv \
  --outdir metag_amps \
  --amp_macrel_min_length 10 \
  -profile docker
```

### 3. Validação de Peptídeos Conhecidos

```bash
# Use apenas HMMER com modelos específicos
nextflow run main.nf \
  --input known_peptides.csv \
  --outdir validation \
  --amp_skip_macrel \
  --amp_skip_ampcombi \
  --amp_hmmer_models custom_models/*.hmm \
  -profile docker
```

## Troubleshooting

### Erro: "Input samplesheet not specified"

**Solução:** Certifique-se de usar `--input` (com dois hífens)
```bash
nextflow run main.nf --input samplesheet.csv --outdir results -profile docker
```

### Erro: "FASTA file does not exist"

**Solução:** Verifique os caminhos no samplesheet
```bash
# Use caminhos absolutos
/home/user/data/sample.fasta

# Ou caminhos relativos ao diretório de execução
./data/sample.fasta
```

### Pipeline muito lento

**Soluções:**
1. Aumente recursos disponíveis:
```bash
nextflow run main.nf \
  --input samplesheet.csv \
  --max_cpus 16 \
  --max_memory 64.GB \
  -profile docker
```

2. Desabilite ferramentas não essenciais:
```bash
nextflow run main.nf \
  --input samplesheet.csv \
  --amp_skip_ampcombi \
  -profile docker
```

### Erro de memória

**Solução:** Aumente a memória máxima
```bash
nextflow run main.nf \
  --input samplesheet.csv \
  --max_memory 128.GB \
  -profile docker
```

### Container não encontrado

**Solução:** Pull manual do container
```bash
# Para Docker
docker pull biocontainers/macrel:1.2.0--py39h6935b12_0

# Para Singularity
singularity pull docker://biocontainers/macrel:1.2.0--py39h6935b12_0
```

## Recursos Adicionais

- **Documentação Nextflow**: https://www.nextflow.io/docs/latest/
- **Macrel**: https://github.com/BigDataBiology/macrel
- **HMMER**: http://hmmer.org/
- **Issues**: https://github.com/madsondeluna/nextflow-case/issues

## Suporte

Para questões e problemas:
1. Verifique a seção [Troubleshooting](#troubleshooting)
2. Consulte os logs em `results/pipeline_info/`
3. Abra uma issue no GitHub com:
   - Comando executado
   - Mensagem de erro completa
   - Arquivo `.nextflow.log`
