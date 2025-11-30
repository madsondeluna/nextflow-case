# Exemplos Práticos - AMPscan

Este documento contém exemplos práticos de uso do pipeline AMPscan para diferentes cenários.

## Índice

1. [Screening de Genoma Bacteriano](#1-screening-de-genoma-bacteriano)
2. [Análise de Metagenoma](#2-análise-de-metagenoma)
3. [Validação de AMPs Conhecidos](#3-validação-de-amps-conhecidos)
4. [Pipeline Customizado](#4-pipeline-customizado)
5. [Análise em Lote](#5-análise-em-lote)
6. [Visualização de Resultados](#6-visualização-de-resultados)

---

## 1. Screening de Genoma Bacteriano

### Cenário
Você montou o genoma de uma bactéria e quer identificar potenciais peptídeos antimicrobianos.

### Dados
```
genome_assembly.fasta  # Genoma montado
```

### Passo a Passo

#### 1.1 Criar Samplesheet

```bash
cat > bacteria_genome.csv << EOF
sample,fasta
bacteria_sp,/data/genomes/genome_assembly.fasta
EOF
```

#### 1.2 Executar Pipeline Completo

```bash
nextflow run main.nf \
  --input bacteria_genome.csv \
  --outdir results_bacteria \
  --max_cpus 8 \
  -profile docker
```

#### 1.3 Verificar Resultados

```bash
# Ver predições
zcat results_bacteria/amp/macrel/bacteria_sp/bacteria_sp.prediction.gz | head

# Ver estatísticas
cat results_bacteria/amp/macrel/bacteria_sp/bacteria_sp.stats.tsv

# Abrir relatório MultiQC
open results_bacteria/multiqc/multiqc_report.html
```

---

## 2. Análise de Metagenoma

### Cenário
Você tem contigs montados de um metagenoma intestinal e quer identificar AMPs.

### Dados
```
gut_metagenome_contigs.fasta  # Contigs do metagenoma
```

### Passo a Passo

#### 2.1 Preparar Dados

```bash
# Criar samplesheet
cat > metagenome.csv << EOF
sample,fasta
gut_sample1,/data/metagenomes/gut_contigs_sample1.fasta
gut_sample2,/data/metagenomes/gut_contigs_sample2.fasta
gut_sample3,/data/metagenomes/gut_contigs_sample3.fasta
EOF
```

#### 2.2 Executar com Parâmetros Otimizados

```bash
# Para metagenomas, use peptídeos menores
nextflow run main.nf \
  --input metagenome.csv \
  --outdir results_metagenome \
  --amp_macrel_min_length 8 \
  --amp_macrel_max_length 80 \
  --max_cpus 16 \
  --max_memory 64.GB \
  -profile docker
```

#### 2.3 Análise Comparativa

```bash
# Combinar resultados de todas as amostras
cd results_metagenome/amp/macrel/

# Contar AMPs por amostra
for sample in gut_sample*; do
    echo -n "$sample: "
    zcat $sample/*.prediction.gz | tail -n +2 | wc -l
done
```

---

## 3. Validação de AMPs Conhecidos

### Cenário
Você tem uma lista de peptídeos conhecidos e quer validar usando HMMER.

### Dados
```
known_amps.fasta  # Sequências de AMPs conhecidos
custom_amp.hmm    # Modelo HMM customizado
```

### Passo a Passo

#### 3.1 Preparar Samplesheet

```bash
cat > validation.csv << EOF
sample,fasta
known_amps,/data/validation/known_amps.fasta
EOF
```

#### 3.2 Executar Apenas HMMER

```bash
nextflow run main.nf \
  --input validation.csv \
  --outdir results_validation \
  --amp_skip_macrel \
  --amp_skip_ampcombi \
  --amp_hmmer_models /data/hmm_models/custom_amp.hmm \
  -profile docker
```

#### 3.3 Analisar Hits

```bash
# Ver hits do HMMER
cat results_validation/amp/hmmer/known_amps.tblout.txt | grep -v "^#"
```

---

## 4. Pipeline Customizado

### Cenário
Você quer executar apenas Macrel com parâmetros específicos.

### Passo a Passo

#### 4.1 Configuração Customizada

```bash
# Criar arquivo de configuração custom
cat > custom.config << EOF
params {
    // Parâmetros do Macrel
    amp_macrel_min_length = 15
    amp_macrel_max_length = 60
    
    // Desabilitar outras ferramentas
    amp_skip_ampcombi = true
    amp_skip_hmmer = true
    
    // Recursos
    max_cpus = 12
    max_memory = '48.GB'
}
EOF
```

#### 4.2 Executar com Configuração Custom

```bash
nextflow run main.nf \
  --input samplesheet.csv \
  --outdir results_custom \
  -profile docker \
  -c custom.config
```

---

## 5. Análise em Lote

### Cenário
Você tem múltiplos genomas para analisar em paralelo.

### Passo a Passo

#### 5.1 Criar Samplesheet Grande

```bash
cat > batch_analysis.csv << EOF
sample,fasta
ecoli_strain1,/data/genomes/ecoli_1.fasta
ecoli_strain2,/data/genomes/ecoli_2.fasta
staph_strain1,/data/genomes/staph_1.fasta
staph_strain2,/data/genomes/staph_2.fasta
pseudo_strain1,/data/genomes/pseudo_1.fasta
pseudo_strain2,/data/genomes/pseudo_2.fasta
EOF
```

#### 5.2 Executar em HPC com Singularity

```bash
# Para ambiente HPC
nextflow run main.nf \
  --input batch_analysis.csv \
  --outdir results_batch \
  --max_cpus 32 \
  --max_memory 128.GB \
  -profile singularity \
  -resume
```

#### 5.3 Monitorar Execução

```bash
# Em outro terminal, monitorar progresso
tail -f .nextflow.log

# Ver timeline após conclusão
open results_batch/pipeline_info/execution_timeline_*.html
```

---

## 6. Visualização de Resultados

### Cenário
Você quer gerar gráficos e estatísticas dos resultados.

### Passo a Passo

#### 6.1 Usar Script de Visualização

```bash
# Visualizar propriedades de uma amostra
bin/visualize_results.py \
  --properties results/annotation/sample1_properties.tsv \
  --outdir plots/sample1/
```

#### 6.2 Análise Comparativa

```bash
# Combinar propriedades de múltiplas amostras
cat results/annotation/*_properties.tsv | \
  awk 'NR==1 || !/^sequence_id/' > all_properties.tsv

# Visualizar
bin/visualize_results.py \
  --properties all_properties.tsv \
  --outdir plots/combined/
```

#### 6.3 Análise Estatística em R

```r
# Carregar dados
library(tidyverse)

props <- read_tsv("all_properties.tsv")

# Resumo estatístico
summary(props)

# Gráfico de distribuição
ggplot(props, aes(x = length, y = charge_at_pH7, color = gravy)) +
  geom_point(alpha = 0.6) +
  theme_minimal() +
  labs(title = "AMP Properties",
       x = "Length (aa)",
       y = "Charge at pH 7")

ggsave("amp_scatter.png", width = 10, height = 6, dpi = 300)
```

---

## 7. Troubleshooting de Casos Específicos

### 7.1 Genoma Muito Grande

```bash
# Aumentar recursos e usar resume
nextflow run main.nf \
  --input large_genome.csv \
  --outdir results \
  --max_memory 256.GB \
  --max_time 48.h \
  -profile singularity \
  -resume
```

### 7.2 Muitas Amostras (>100)

```bash
# Processar em batches
split -l 20 all_samples.csv batch_

# Executar cada batch
for batch in batch_*; do
    nextflow run main.nf \
      --input $batch \
      --outdir results_$(basename $batch) \
      -profile docker \
      -resume
done
```

### 7.3 Apenas Peptídeos Curtos

```bash
# Focar em peptídeos 8-30 aa
nextflow run main.nf \
  --input samplesheet.csv \
  --outdir results_short \
  --amp_macrel_min_length 8 \
  --amp_macrel_max_length 30 \
  -profile docker
```

---

## 8. Integração com Outros Pipelines

### 8.1 Após Montagem de Genoma

```bash
# Pipeline de montagem → AMPscan
# 1. Montar genoma
spades.py -1 R1.fq -2 R2.fq -o assembly/

# 2. Criar samplesheet
echo "sample,fasta" > samplesheet.csv
echo "my_sample,$(pwd)/assembly/contigs.fasta" >> samplesheet.csv

# 3. Executar AMPscan
nextflow run main.nf --input samplesheet.csv -profile docker
```

### 8.2 Pré-processamento de Contigs

```bash
# Filtrar contigs pequenos antes do AMPscan
seqkit seq -m 300 contigs.fasta > contigs_filtered.fasta

# Executar AMPscan
nextflow run main.nf \
  --input samplesheet.csv \
  --outdir results \
  -profile docker
```

---

## Recursos Adicionais

- **Documentação Completa**: [docs/usage.md](usage.md)
- **Arquitetura**: [docs/architecture.md](architecture.md)
- **Início Rápido**: [docs/quickstart.md](quickstart.md)

## Suporte

Para mais exemplos ou dúvidas:
- Abra uma [issue](https://github.com/madsondeluna/nextflow-case/issues)
- Consulte a [documentação](https://github.com/madsondeluna/nextflow-case)
