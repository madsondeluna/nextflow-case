# Modelos HMM para AMPs

Este diretório deve conter modelos HMM (Hidden Markov Models) para busca de domínios conservados em peptídeos antimicrobianos.

## Fontes de Modelos HMM

### 1. Pfam
- URL: http://pfam.xfam.org/
- Famílias relevantes:
  - PF00062: Defensins
  - PF01097: Bacteriocin
  - PF02052: Gallidermin

### 2. CAMP (Collection of Anti-Microbial Peptides)
- URL: http://www.camp.bicnirrh.res.in/
- Download de modelos customizados

### 3. APD3 (Antimicrobial Peptide Database)
- URL: https://aps.unmc.edu/
- Modelos baseados em estruturas conhecidas

## Como Usar

### Download de Modelos Pfam

```bash
# Exemplo: Download de modelo de defensinas
wget http://pfam.xfam.org/family/PF00062/hmm -O defensin.hmm

# Preparar modelo
hmmpress defensin.hmm
```

### Usar Modelos Customizados

```bash
nextflow run main.nf \
  --input samplesheet.csv \
  --amp_hmmer_models /caminho/para/modelos/*.hmm \
  -profile docker
```

## Criar Seus Próprios Modelos

### A partir de Alinhamento

```bash
# 1. Criar alinhamento múltiplo (MSA)
muscle -in peptides.fasta -out alignment.afa

# 2. Construir modelo HMM
hmmbuild modelo_custom.hmm alignment.afa

# 3. Calibrar modelo
hmmcalibrate modelo_custom.hmm

# 4. Preparar para busca
hmmpress modelo_custom.hmm
```

### A partir de Sequências Conhecidas

```bash
# 1. Coletar sequências de AMPs conhecidos
# 2. Alinhar com MAFFT ou MUSCLE
mafft --auto known_amps.fasta > aligned_amps.afa

# 3. Construir modelo
hmmbuild amp_family.hmm aligned_amps.afa
```

## Estrutura de Arquivo HMM

```
HMMER3/f [3.3.2 | August 2020]
NAME  AMP_family
ACC   PF00000
DESC  Antimicrobial peptide family
LENG  50
ALPH  amino
...
```

## Modelos Recomendados

Para começar, recomendamos usar modelos do Pfam:

1. **PF00062** - Defensins (α e β)
2. **PF01097** - Bacteriocin_IIc
3. **PF02052** - Gallidermin
4. **PF00666** - Bacteriocin_II
5. **PF01721** - Lactococcin

## Referências

- HMMER User Guide: http://hmmer.org/documentation.html
- Pfam Database: http://pfam.xfam.org/
- Building HMM profiles: http://eddylab.org/software/hmmer/Userguide.pdf

## Nota

Este diretório está vazio por padrão. Você deve adicionar seus próprios modelos HMM ou baixá-los das fontes mencionadas acima.
