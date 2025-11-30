#  Checklist de Instalação e Primeira Execução

Use este checklist para garantir que tudo está configurado corretamente.

---

##  Instalação

### Java
- [ ] Java 11 ou superior instalado
- [ ] Comando `java -version` funciona
- [ ] Versão exibida é 11 ou superior

**Testar:**
```bash
java -version
```

---

### Nextflow
- [ ] Nextflow baixado
- [ ] Nextflow movido para `/usr/local/bin/`
- [ ] Comando `nextflow -version` funciona
- [ ] Versão 23.04 ou superior

**Testar:**
```bash
nextflow -version
```

---

### Docker
- [ ] Docker Desktop instalado (macOS) ou Docker Engine (Linux)
- [ ] Docker está rodando
- [ ] Comando `docker --version` funciona
- [ ] Comando `docker run hello-world` funciona

**Testar:**
```bash
docker --version
docker run hello-world
```

---

### Pipeline AMPscan
- [ ] Repositório clonado
- [ ] Arquivo `main.nf` existe
- [ ] Arquivo `nextflow.config` existe
- [ ] Diretórios `workflows/`, `modules/`, `bin/` existem

**Testar:**
```bash
cd ~/Documents/nextflow-case
ls -la main.nf nextflow.config
```

---

## Teste Inicial

### Execução de Teste
- [ ] Comando de teste executado
- [ ] Containers Docker baixados
- [ ] Pipeline completou sem erros
- [ ] Diretório `results/` foi criado
- [ ] Arquivo `results/multiqc/multiqc_report.html` existe

**Executar:**
```bash
nextflow run main.nf -profile test,docker
```

---

### Verificação dos Resultados
- [ ] Relatório MultiQC abre no navegador
- [ ] Resultados em `results/amp/macrel/` existem
- [ ] Arquivo de log `.nextflow.log` foi criado
- [ ] Timeline em `results/pipeline_info/` existe

**Verificar:**
```bash
ls -la results/
open results/multiqc/multiqc_report.html
```

---

##  Preparação de Dados

### Seus Dados
- [ ] Arquivos FASTA preparados
- [ ] Arquivos FASTA estão no formato correto
- [ ] Caminhos absolutos dos arquivos anotados
- [ ] Samplesheet CSV criado
- [ ] Samplesheet validado (sem erros de formato)

**Exemplo de Samplesheet:**
```csv
sample,fasta
amostra1,/Users/madsonluna/Documents/dados/amostra1.fasta
```

---

##  Primeira Execução Real

### Execução com Seus Dados
- [ ] Comando executado com `--input` apontando para seu samplesheet
- [ ] Pipeline iniciou sem erros
- [ ] Processos estão sendo executados
- [ ] Diretório de output foi criado

**Executar:**
```bash
nextflow run main.nf \
  --input meus_dados.csv \
  --outdir meus_resultados \
  -profile docker
```

---

### Monitoramento
- [ ] Log `.nextflow.log` está sendo atualizado
- [ ] Processos aparecem como concluídos ()
- [ ] Sem erros críticos no log

**Monitorar:**
```bash
tail -f .nextflow.log
```

---

##  Análise de Resultados

### Resultados Gerados
- [ ] Diretório de resultados existe
- [ ] Predições de AMPs em `amp/macrel/` existem
- [ ] Arquivo de propriedades em `annotation/` existe
- [ ] Relatório MultiQC gerado
- [ ] Timeline e reports em `pipeline_info/` existem

**Verificar:**
```bash
find meus_resultados/ -type f
```

---

### Visualização
- [ ] Relatório MultiQC abre corretamente
- [ ] Estatísticas fazem sentido
- [ ] Gráficos são exibidos
- [ ] Arquivos de predição podem ser abertos

**Abrir:**
```bash
open meus_resultados/multiqc/multiqc_report.html
```

---

##  Troubleshooting

### Se algo der errado:

#### Pipeline não inicia
- [ ] Verificar se Docker está rodando
- [ ] Verificar se Nextflow está instalado
- [ ] Verificar se está no diretório correto

#### Erro no samplesheet
- [ ] Verificar formato CSV (vírgula como separador)
- [ ] Verificar caminhos absolutos
- [ ] Verificar se arquivos FASTA existem
- [ ] Verificar se não há espaços nos nomes

#### Erro de memória
- [ ] Aumentar `--max_memory`
- [ ] Fechar outros programas
- [ ] Verificar recursos disponíveis no Docker Desktop

#### Pipeline muito lento
- [ ] Aumentar `--max_cpus`
- [ ] Verificar se Docker tem recursos suficientes
- [ ] Considerar desabilitar ferramentas opcionais

---

##  Próximos Passos

Após completar este checklist:

- [ ] Ler `docs/usage.md` para uso avançado
- [ ] Explorar `docs/examples.md` para casos de uso
- [ ] Experimentar diferentes parâmetros
- [ ] Visualizar resultados com `bin/visualize_results.py`

---

##  Checklist Completo!

Se você marcou todos os itens acima, parabéns! 

Você está pronto para:
-  Executar análises de AMPs
-  Customizar parâmetros
-  Interpretar resultados
-  Resolver problemas comuns

