# Comandos Rápidos - Cola de Referência

Guia rápido com os comandos mais usados. Copie e cole conforme necessário.

---

##  Instalação

### Instalar Java (macOS)
```bash
brew install openjdk@11
```

### Instalar Java (Linux)
```bash
sudo apt update
sudo apt install openjdk-11-jdk
```

### Instalar Nextflow
```bash
curl -s https://get.nextflow.io | bash
sudo mv nextflow /usr/local/bin/
```

### Verificar Instalações
```bash
java -version
nextflow -version
docker --version
```

---

##  Baixar Pipeline

```bash
cd ~/Documents
git clone https://github.com/madsondeluna/nextflow-case.git
cd nextflow-case
```

---

## Executar Teste

### Teste Básico
```bash
nextflow run main.nf -profile test,docker
```

### Teste Completo
```bash
nextflow run main.nf -profile test_full,docker
```

---

##  Criar Samplesheet

### Template Básico
```bash
cat > samplesheet.csv << 'EOF'
sample,fasta
amostra1,/caminho/completo/amostra1.fasta
amostra2,/caminho/completo/amostra2.fasta
EOF
```

### Com Seus Dados (edite os caminhos!)
```bash
cat > meus_dados.csv << 'EOF'
sample,fasta
bacteria_1,/Users/madsonluna/Documents/dados/bacteria_1.fasta
bacteria_2,/Users/madsonluna/Documents/dados/bacteria_2.fasta
EOF
```

---

##  Executar Pipeline

### Execução Básica
```bash
nextflow run main.nf \
  --input samplesheet.csv \
  --outdir resultados \
  -profile docker
```

### Com Resume (continuar de onde parou)
```bash
nextflow run main.nf \
  --input samplesheet.csv \
  --outdir resultados \
  -profile docker \
  -resume
```

### Apenas Macrel (mais rápido)
```bash
nextflow run main.nf \
  --input samplesheet.csv \
  --outdir resultados \
  --amp_skip_hmmer \
  --amp_skip_ampcombi \
  -profile docker
```

### Peptídeos Curtos (8-30 aa)
```bash
nextflow run main.nf \
  --input samplesheet.csv \
  --outdir resultados \
  --amp_macrel_min_length 8 \
  --amp_macrel_max_length 30 \
  -profile docker
```

### Mais CPUs e Memória
```bash
nextflow run main.nf \
  --input samplesheet.csv \
  --outdir resultados \
  --max_cpus 16 \
  --max_memory 64.GB \
  -profile docker
```

---

##  Visualizar Resultados

### Abrir Relatório MultiQC
```bash
# macOS
open results/multiqc/multiqc_report.html

# Linux
xdg-open results/multiqc/multiqc_report.html
```

### Abrir Timeline
```bash
# macOS
open results/pipeline_info/execution_timeline_*.html

# Linux
xdg-open results/pipeline_info/execution_timeline_*.html
```

### Ver Predições de AMPs
```bash
# Ver primeiras linhas
zcat results/amp/macrel/amostra1/amostra1.prediction.gz | head -20

# Contar AMPs encontrados
zcat results/amp/macrel/amostra1/amostra1.prediction.gz | tail -n +2 | wc -l
```

### Ver Propriedades
```bash
cat results/annotation/amostra1_properties.tsv | column -t | less
```

---

##  Monitoramento

### Ver Log em Tempo Real
```bash
tail -f .nextflow.log
```

### Ver Últimas Linhas do Log
```bash
tail -50 .nextflow.log
```

### Buscar Erros no Log
```bash
grep -i error .nextflow.log
grep -i failed .nextflow.log
```

---

##  Gerar Gráficos

### Visualizar Propriedades
```bash
bin/visualize_results.py \
  --properties results/annotation/amostra1_properties.tsv \
  --outdir graficos/
```

### Combinar Múltiplas Amostras
```bash
# Combinar arquivos
cat results/annotation/*_properties.tsv | \
  awk 'NR==1 || !/^sequence_id/' > todas_propriedades.tsv

# Visualizar
bin/visualize_results.py \
  --properties todas_propriedades.tsv \
  --outdir graficos_combinados/
```

---

## Limpeza

### Limpar Arquivos Temporários
```bash
# Remover diretório work (cuidado!)
rm -rf work/

# Remover logs antigos
rm -f .nextflow.log.*
```

### Limpar Tudo e Recomeçar
```bash
# CUIDADO: Remove TODOS os resultados!
rm -rf work/ results/ .nextflow*
```

---

##  Docker

### Ver Containers Baixados
```bash
docker images | grep biocontainers
```

### Limpar Containers Antigos
```bash
docker system prune -a
```

### Verificar Espaço em Disco
```bash
docker system df
```

---

##  Estrutura de Arquivos

### Listar Estrutura de Resultados
```bash
tree results/

# Ou sem tree:
find results/ -type f | sort
```

### Contar Arquivos por Tipo
```bash
find results/ -name "*.gz" | wc -l
find results/ -name "*.tsv" | wc -l
find results/ -name "*.html" | wc -l
```

---

##  Troubleshooting

### Verificar Status do Docker
```bash
docker info
docker ps
```

### Testar Container Específico
```bash
docker run biocontainers/macrel:1.2.0--py39h6935b12_0 macrel --version
```

### Verificar Recursos Disponíveis
```bash
# CPUs
nproc

# Memória (Linux)
free -h

# Memória (macOS)
sysctl hw.memsize
```

### Forçar Limpeza do Cache
```bash
nextflow clean -f
```

---

##  Informações Úteis

### Ver Parâmetros Disponíveis
```bash
nextflow run main.nf --help
```

### Ver Configuração Atual
```bash
nextflow config
```

### Ver Versão de Tudo
```bash
echo "Java: $(java -version 2>&1 | head -1)"
echo "Nextflow: $(nextflow -version)"
echo "Docker: $(docker --version)"
```

---

##  Atalhos Úteis

### Criar Alias (adicione ao ~/.bashrc ou ~/.zshrc)
```bash
# Atalho para executar pipeline
alias amp-run='nextflow run main.nf -profile docker'

# Atalho para ver resultados
alias amp-results='open results/multiqc/multiqc_report.html'

# Atalho para limpar
alias amp-clean='rm -rf work/ .nextflow.log.*'
```

### Usar os Atalhos
```bash
# Depois de adicionar ao ~/.bashrc:
source ~/.bashrc

# Executar
amp-run --input samplesheet.csv --outdir results
amp-results
```

---

##  Ajuda Rápida

### Problemas Comuns

**Pipeline não inicia:**
```bash
# Verificar Docker
docker info

# Verificar Nextflow
nextflow info
```

**Erro de memória:**
```bash
nextflow run main.nf --input samplesheet.csv --max_memory 32.GB -profile docker
```

**Muito lento:**
```bash
nextflow run main.nf --input samplesheet.csv --max_cpus 8 -profile docker
```

**Continuar execução interrompida:**
```bash
nextflow run main.nf --input samplesheet.csv -profile docker -resume
```

---

##  Backup de Resultados

### Comprimir Resultados
```bash
tar -czf resultados_$(date +%Y%m%d).tar.gz results/
```

### Copiar Apenas Relatórios
```bash
mkdir -p relatorios_finais
cp results/multiqc/*.html relatorios_finais/
cp results/pipeline_info/*.html relatorios_finais/
```
