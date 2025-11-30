# Guia de Início Rápido - AMPscan

## 🚀 Instalação Rápida

### 1. Instalar Nextflow

```bash
curl -s https://get.nextflow.io | bash
sudo mv nextflow /usr/local/bin/
```

### 2. Instalar Docker

Siga as instruções em: https://docs.docker.com/get-docker/

### 3. Clone o Repositório

```bash
git clone https://github.com/madsondeluna/nextflow-case.git
cd nextflow-case
```

## 📋 Preparar Seus Dados

Crie um arquivo `samplesheet.csv`:

```csv
sample,fasta
minha_amostra1,/caminho/para/amostra1.fasta
minha_amostra2,/caminho/para/amostra2.fasta
```

## ▶️ Executar o Pipeline

### Teste Rápido (com dados de exemplo)

```bash
nextflow run main.nf -profile test,docker
```

### Com Seus Dados

```bash
nextflow run main.nf \
  --input samplesheet.csv \
  --outdir resultados \
  -profile docker
```

## 📊 Ver Resultados

Após a execução, seus resultados estarão em:

```
resultados/
├── amp/                    # Predições de AMPs
│   └── macrel/            # Resultados do Macrel
├── annotation/            # Propriedades dos peptídeos
└── multiqc/              # Relatório consolidado
    └── multiqc_report.html  ← Abra este arquivo no navegador
```

## 🎯 Exemplos Comuns

### Apenas Macrel (mais rápido)

```bash
nextflow run main.nf \
  --input samplesheet.csv \
  --outdir resultados \
  --amp_skip_ampcombi \
  --amp_skip_hmmer \
  -profile docker
```

### Peptídeos menores (10-50 aa)

```bash
nextflow run main.nf \
  --input samplesheet.csv \
  --outdir resultados \
  --amp_macrel_min_length 10 \
  --amp_macrel_max_length 50 \
  -profile docker
```

### Mais CPUs (mais rápido)

```bash
nextflow run main.nf \
  --input samplesheet.csv \
  --outdir resultados \
  --max_cpus 16 \
  -profile docker
```

## ❓ Problemas?

1. **Pipeline não inicia**: Verifique se Nextflow e Docker estão instalados
2. **Erro no samplesheet**: Use caminhos absolutos para os arquivos FASTA
3. **Falta de memória**: Adicione `--max_memory 64.GB`

Para mais detalhes, consulte: [docs/usage.md](docs/usage.md)

## 📚 Próximos Passos

- Leia a [documentação completa](docs/usage.md)
- Veja as [citações](CITATIONS.md) das ferramentas
- Explore os [parâmetros disponíveis](#parâmetros-principais)

## 🔧 Parâmetros Principais

| Parâmetro | Descrição | Padrão |
|-----------|-----------|--------|
| `--input` | Samplesheet CSV | obrigatório |
| `--outdir` | Diretório de saída | `./results` |
| `--amp_skip_macrel` | Pular Macrel | `false` |
| `--amp_skip_hmmer` | Pular HMMER | `false` |
| `--amp_macrel_min_length` | Tamanho mínimo | `10` |
| `--max_cpus` | CPUs máximas | `16` |
| `--max_memory` | Memória máxima | `128.GB` |

## 💡 Dicas

- Use `-resume` para continuar execuções interrompidas
- Verifique `results/pipeline_info/` para logs detalhados
- O MultiQC Report é o melhor lugar para começar a análise
