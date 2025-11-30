#  Primeira Execução - Guia para Iniciantes

Bem-vindo! Este guia foi criado para quem **nunca executou um pipeline Nextflow antes**. Vamos te guiar passo a passo, desde a instalação até a primeira análise completa.

---

##  Índice

1. [Antes de Começar](#1-antes-de-começar)
2. [Instalação do Ambiente](#2-instalação-do-ambiente)
3. [Entendendo o Pipeline](#3-entendendo-o-pipeline)
4. [Preparando Seus Dados](#4-preparando-seus-dados)
5. [Primeira Execução (Teste)](#5-primeira-execução-teste)
6. [Executando com Seus Dados](#6-executando-com-seus-dados)
7. [Interpretando os Resultados](#7-interpretando-os-resultados)
8. [Próximos Passos](#8-próximos-passos)
9. [Problemas Comuns](#9-problemas-comuns)

---

## 1. Antes de Começar

### O que você vai precisar:

-  Um computador com macOS, Linux ou Windows (WSL2)
-  Conexão com a internet
-  Pelo menos 8GB de RAM
-  Pelo menos 20GB de espaço em disco
-  Permissões de administrador (para instalar software)
-  Aproximadamente 30-60 minutos

### O que você vai aprender:

- Como instalar Nextflow e Docker
- Como executar um pipeline bioinformático
- Como preparar dados de entrada
- Como interpretar resultados

---

## 2. Instalação do Ambiente

### Passo 2.1: Instalar Java

Nextflow precisa de Java. Vamos verificar se você já tem:

```bash
# Abra o Terminal e digite:
java -version
```

**Se aparecer algo como "java version 11" ou superior**:  Você já tem Java!

**Se aparecer "command not found"**: Você precisa instalar Java.

#### Instalar Java no macOS:
```bash
# Usando Homebrew (recomendado)
brew install openjdk@11

# Ou baixe de: https://adoptium.net/
```

#### Instalar Java no Linux (Ubuntu/Debian):
```bash
sudo apt update
sudo apt install openjdk-11-jdk
```

---

### Passo 2.2: Instalar Nextflow

Agora vamos instalar o Nextflow:

```bash
# 1. Baixar o Nextflow
curl -s https://get.nextflow.io | bash

# 2. Mover para um local acessível
sudo mv nextflow /usr/local/bin/

# 3. Verificar instalação
nextflow -version
```

**Você deve ver algo como:**
```
nextflow version 23.10.0.5889
```

 **Sucesso!** Nextflow instalado!

---

### Passo 2.3: Instalar Docker

Docker é usado para executar as ferramentas do pipeline de forma isolada e reprodutível.

#### macOS:
1. Baixe Docker Desktop: https://www.docker.com/products/docker-desktop
2. Instale o arquivo `.dmg`
3. Abra o Docker Desktop
4. Aguarde até ver "Docker Desktop is running" na barra de menu

#### Linux (Ubuntu/Debian):
```bash
# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Adicionar seu usuário ao grupo docker
sudo usermod -aG docker $USER

# Reinicie o terminal ou faça logout/login
```

#### Verificar instalação:
```bash
docker --version
docker run hello-world
```

 **Se você viu "Hello from Docker!"**, está tudo certo!

---

### Passo 2.4: Baixar o Pipeline AMPscan

```bash
# 1. Vá para o diretório onde quer trabalhar
cd ~/Documents

# 2. Clone o repositório
git clone https://github.com/madsondeluna/nextflow-case.git

# 3. Entre no diretório
cd nextflow-case

# 4. Verifique os arquivos
ls -la
```

**Você deve ver:**
- `main.nf` - O arquivo principal do pipeline
- `nextflow.config` - Configurações
- `workflows/`, `modules/`, etc.

---

## 3. Entendendo o Pipeline

### O que é o AMPscan?

O AMPscan é um pipeline que:
1.  Recebe sequências de DNA (em formato FASTA)
2.  Procura por genes que codificam peptídeos antimicrobianos (AMPs)
3.  Analisa propriedades desses peptídeos
4.  Gera relatórios e gráficos

### Como funciona?

```
Seus dados (FASTA)
        ↓
    Validação
        ↓
    Predição de AMPs
    ├── Macrel (Machine Learning)
    ├── HMMER (Busca de padrões)
    └── AMPcombi (Combina resultados)
        ↓
    Análise de Propriedades
        ↓
    Relatórios (HTML, gráficos)
```

---

## 4. Preparando Seus Dados

### Formato necessário: FASTA

Seus dados devem estar em formato FASTA. Exemplo:

```
>contig_1
ATGAAACGCATTAGCACCACCATTACCACCACCATCACCATTACCACAGGTAACGGTGCG
GGCTGA
>contig_2
ATGAGCGAACAACTTATTGCTTTATTTGCAGGTGTTGCAGGCGGTGTTGCAGGCGGTGTT
```

### Criar o Samplesheet

O pipeline precisa de um arquivo CSV que lista suas amostras:

```bash
# Crie um arquivo chamado samplesheet.csv
nano samplesheet.csv
```

**Formato do arquivo:**
```csv
sample,fasta
minha_amostra,/caminho/completo/para/arquivo.fasta
```

**Exemplo real:**
```csv
sample,fasta
bacteria_1,/Users/madsonluna/Documents/dados/bacteria_1.fasta
bacteria_2,/Users/madsonluna/Documents/dados/bacteria_2.fasta
```

⚠️ **IMPORTANTE:**
- Use **caminhos completos** (absolutos), não relativos
- Não use espaços nos nomes das amostras
- Certifique-se que os arquivos FASTA existem

---

## 5. Primeira Execução (Teste)

Antes de usar seus dados, vamos fazer um teste com dados de exemplo:

### Passo 5.1: Executar o Teste

```bash
# Certifique-se de estar no diretório do pipeline
cd ~/Documents/nextflow-case

# Execute o teste
nextflow run main.nf -profile test,docker
```

### O que vai acontecer:

1. ⬇️ Nextflow vai baixar dados de teste
2.  Docker vai baixar as imagens dos containers (primeira vez demora!)
3. ⚙️ O pipeline vai executar todas as etapas
4.  Resultados serão salvos em `results/`

### Quanto tempo demora?

- **Primeira vez**: 15-30 minutos (baixando containers)
- **Próximas vezes**: 5-10 minutos

### Acompanhando a execução:

Você verá algo assim:

```
N E X T F L O W  ~  version 23.10.0
Launching `main.nf` [silly_euler] DSL2 - revision: abc123

executor >  local (5)
[12/34a5b6] process > AMPSCAN:INPUT_CHECK:SAMPLESHEET_CHECK (samplesheet.csv) [100%] 1 of 1 
[67/89cd0e] process > AMPSCAN:AMP_SCREENING:MACREL_CONTIGS (sample1)         [100%] 1 of 1 
...
```

 **Quando terminar, você verá:**
```
Completed at: 30-Nov-2025 20:30:00
Duration    : 8m 23s
CPU hours   : 0.5
Succeeded   : 12
```

---

### Passo 5.2: Verificar os Resultados

```bash
# Listar resultados
ls -la results/

# Ver estrutura completa
find results/ -type f
```

**Você deve ver:**
```
results/
├── amp/
│   └── macrel/
│       └── test_sample1/
├── multiqc/
│   └── multiqc_report.html
└── pipeline_info/
    └── execution_report.html
```

### Passo 5.3: Abrir o Relatório

```bash
# Abrir relatório MultiQC no navegador
open results/multiqc/multiqc_report.html

# Ou no Linux:
xdg-open results/multiqc/multiqc_report.html
```

 **Parabéns!** Você executou seu primeiro pipeline Nextflow!

---

## 6. Executando com Seus Dados

Agora que o teste funcionou, vamos usar seus dados reais.

### Passo 6.1: Preparar o Samplesheet

Crie o arquivo `meus_dados.csv`:

```csv
sample,fasta
amostra_1,/Users/madsonluna/Documents/dados/amostra1.fasta
amostra_2,/Users/madsonluna/Documents/dados/amostra2.fasta
```

### Passo 6.2: Executar o Pipeline

```bash
nextflow run main.nf \
  --input meus_dados.csv \
  --outdir resultados_reais \
  -profile docker
```

**Explicando os parâmetros:**
- `--input`: Seu arquivo CSV com as amostras
- `--outdir`: Onde salvar os resultados
- `-profile docker`: Usar Docker para os containers

### Passo 6.3: Monitorar a Execução

Em outro terminal, você pode acompanhar o log:

```bash
tail -f .nextflow.log
```

Para parar de acompanhar: `Ctrl + C`

---

## 7. Interpretando os Resultados

### Estrutura dos Resultados

```
resultados_reais/
├── amp/                          # Predições de AMPs
│   ├── macrel/
│   │   ├── amostra_1/
│   │   │   ├── amostra_1.prediction.gz    # AMPs encontrados
│   │   │   ├── amostra_1.all_orfs.faa.gz  # Todas as proteínas
│   │   │   └── amostra_1.stats.tsv        # Estatísticas
│   ├── hmmer/                    # Domínios encontrados
│   └── ampcombi/                 # Resultados combinados
├── annotation/                   # Propriedades dos peptídeos
│   └── amostra_1_properties.tsv
├── multiqc/                      # Relatório consolidado
│   └── multiqc_report.html       # COMECE POR AQUI!
└── pipeline_info/                # Informações da execução
    ├── execution_report.html
    └── execution_timeline.html
```

### Principais Arquivos

#### 1. **MultiQC Report** (Importante!)
```bash
open resultados_reais/multiqc/multiqc_report.html
```

Este relatório mostra:
- Quantos AMPs foram encontrados
- Estatísticas gerais
- Gráficos comparativos

#### 2. **Predições de AMPs**
```bash
# Ver AMPs encontrados
zcat resultados_reais/amp/macrel/amostra_1/amostra_1.prediction.gz | head
```

Colunas importantes:
- `sequence_id`: ID do peptídeo
- `sequence`: Sequência de aminoácidos
- `AMP_probability`: Probabilidade de ser AMP (0-1)

#### 3. **Propriedades dos Peptídeos**
```bash
# Ver propriedades
cat resultados_reais/annotation/amostra_1_properties.tsv | head
```

Informações:
- Tamanho do peptídeo
- Peso molecular
- Carga elétrica
- Hidrofobicidade

---

## 8. Próximos Passos

### Visualizar Resultados

Use o script de visualização:

```bash
bin/visualize_results.py \
  --properties resultados_reais/annotation/amostra_1_properties.tsv \
  --outdir graficos/
```

### Customizar a Análise

Você pode ajustar parâmetros:

```bash
# Procurar peptídeos menores (10-50 aminoácidos)
nextflow run main.nf \
  --input meus_dados.csv \
  --outdir resultados_custom \
  --amp_macrel_min_length 10 \
  --amp_macrel_max_length 50 \
  -profile docker
```

### Executar Apenas Macrel (mais rápido)

```bash
nextflow run main.nf \
  --input meus_dados.csv \
  --outdir resultados_rapido \
  --amp_skip_hmmer \
  --amp_skip_ampcombi \
  -profile docker
```

---

## 9. Problemas Comuns

###  Erro: "command not found: nextflow"

**Solução:**
```bash
# Verificar se está no PATH
echo $PATH

# Reinstalar em /usr/local/bin
curl -s https://get.nextflow.io | bash
sudo mv nextflow /usr/local/bin/
```

---

###  Erro: "Docker is not running"

**Solução:**
1. Abra o Docker Desktop
2. Aguarde até aparecer "Docker Desktop is running"
3. Tente novamente

---

###  Erro: "FASTA file does not exist"

**Solução:**
- Use caminhos **absolutos** no samplesheet
- Verifique se o arquivo existe:
  ```bash
  ls -la /caminho/completo/arquivo.fasta
  ```

---

###  Pipeline muito lento

**Solução:**
```bash
# Aumentar CPUs disponíveis
nextflow run main.nf \
  --input meus_dados.csv \
  --max_cpus 8 \
  -profile docker
```

---

###  Erro de memória

**Solução:**
```bash
# Aumentar memória disponível
nextflow run main.nf \
  --input meus_dados.csv \
  --max_memory 16.GB \
  -profile docker
```

---

###  Execução interrompida

**Solução:**
Use `-resume` para continuar de onde parou:
```bash
nextflow run main.nf \
  --input meus_dados.csv \
  --outdir resultados \
  -profile docker \
  -resume
```

---

##  Glossário

**Nextflow**: Software para criar e executar pipelines bioinformáticos

**Pipeline**: Série de análises executadas em sequência

**Container**: Ambiente isolado com todas as ferramentas necessárias

**FASTA**: Formato de arquivo para sequências biológicas

**AMP**: Antimicrobial Peptide (Peptídeo Antimicrobiano)

**Samplesheet**: Arquivo CSV que lista suas amostras

**MultiQC**: Ferramenta que gera relatórios consolidados

---

##  Recursos Adicionais

- **Documentação Completa**: `docs/usage.md`
- **Exemplos Práticos**: `docs/examples.md`
- **Arquitetura Técnica**: `docs/architecture.md`
- **Nextflow Docs**: https://www.nextflow.io/docs/latest/

---

##  Precisa de Ajuda?

1. Verifique a seção [Problemas Comuns](#9-problemas-comuns)
2. Consulte `docs/usage.md` para mais detalhes
3. Abra uma issue: https://github.com/madsondeluna/nextflow-case/issues

---

##  Checklist de Sucesso

Marque conforme avança:

- [ ] Java instalado e funcionando
- [ ] Nextflow instalado e funcionando
- [ ] Docker instalado e rodando
- [ ] Pipeline clonado
- [ ] Teste executado com sucesso
- [ ] Samplesheet criado com meus dados
- [ ] Pipeline executado com meus dados
- [ ] Resultados visualizados
- [ ] Relatório MultiQC aberto

