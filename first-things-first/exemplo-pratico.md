#  Exemplo Prático Completo

Este é um exemplo **passo a passo real** de como executar o pipeline AMPscan do início ao fim.

---

##  Cenário

Você é um pesquisador que montou o genoma de duas bactérias:
- *Escherichia coli* 
- *Staphylococcus aureus* 

Você quer descobrir se essas bactérias produzem peptídeos antimicrobianos.

---

##  Estrutura de Diretórios

Vamos organizar tudo assim:

```
~/Documents/
├── nextflow-case/           # Pipeline (já clonado)
└── projeto-amps/            # Seu projeto
    ├── dados/               # Dados de entrada
    │   ├── ecoli_xyz.fasta
    │   └── staph_abc.fasta
    ├── samplesheet.csv      # Lista de amostras
    └── resultados/          # Será criado pelo pipeline
```

---

## Passo 1: Criar Estrutura de Diretórios

```bash
# Criar diretórios do projeto
mkdir -p ~/Documents/projeto-amps/dados
cd ~/Documents/projeto-amps
```

---

## Passo 2: Preparar Dados de Entrada

### Opção A: Usar Dados de Exemplo

Para este tutorial, vamos usar dados públicos de teste:

```bash
# Baixar genomas de exemplo
cd dados/

# E. coli (exemplo)
curl -o ecoli_xyz.fasta "https://raw.githubusercontent.com/nf-core/test-datasets/modules/data/genomics/prokaryotes/bacteroides_fragilis/genome/genome.fna.gz"
gunzip ecoli_xyz.fasta.gz

# S. aureus (exemplo)
curl -o staph_abc.fasta "https://raw.githubusercontent.com/nf-core/test-datasets/modules/data/genomics/prokaryotes/haemophilus_influenzae/genome/genome.fna.gz"
gunzip staph_abc.fasta.gz

cd ..
```

### Opção B: Usar Seus Dados Reais

Se você já tem seus arquivos FASTA:

```bash
# Copiar seus arquivos para o diretório dados/
cp /caminho/para/seus/arquivos/*.fasta ~/Documents/projeto-amps/dados/
```

---

## Passo 3: Verificar os Dados

```bash
# Ver primeiras linhas dos arquivos
head -20 dados/ecoli_xyz.fasta
head -20 dados/staph_abc.fasta

# Contar sequências
grep -c "^>" dados/ecoli_xyz.fasta
grep -c "^>" dados/staph_abc.fasta
```

**Saída esperada:**
```
>contig_1
ATGAAACGCATTAGCACCACCATTACCACCACCATCACCATTACCACAGGTAACGGTGCG
...
```

---

## Passo 4: Criar Samplesheet

```bash
# Criar arquivo CSV com caminhos ABSOLUTOS
cat > samplesheet.csv << EOF
sample,fasta
ecoli_xyz,${HOME}/Documents/projeto-amps/dados/ecoli_xyz.fasta
staph_abc,${HOME}/Documents/projeto-amps/dados/staph_abc.fasta
EOF

# Verificar o arquivo criado
cat samplesheet.csv
```

**Saída esperada:**
```csv
sample,fasta
ecoli_xyz,/Users/madsonluna/Documents/projeto-amps/dados/ecoli_xyz.fasta
staph_abc,/Users/madsonluna/Documents/projeto-amps/dados/staph_abc.fasta
```

**Importante:** Os caminhos devem ser absolutos (começando com `/Users/...`)

---

## Passo 5: Validar Samplesheet

```bash
# Verificar se os arquivos existem
while IFS=, read -r sample fasta; do
    if [ "$sample" != "sample" ]; then
        if [ -f "$fasta" ]; then
            echo " $sample: OK"
        else
            echo " $sample: ARQUIVO NÃO ENCONTRADO - $fasta"
        fi
    fi
done < samplesheet.csv
```

**Saída esperada:**
```
 ecoli_xyz: OK
 staph_abc: OK
```

---

## Passo 6: Executar o Pipeline

```bash
# Ir para o diretório do pipeline
cd ~/Documents/nextflow-case

# Executar
nextflow run main.nf \
  --input ~/Documents/projeto-amps/samplesheet.csv \
  --outdir ~/Documents/projeto-amps/resultados \
  -profile docker
```

---

## Passo 7: Acompanhar a Execução

### Terminal 1: Executando o pipeline
Deixe rodando...

### Terminal 2: Monitorar progresso
```bash
cd ~/Documents/nextflow-case
tail -f .nextflow.log
```

**O que você verá:**

```
N E X T F L O W  ~  version 23.10.0
Launching `main.nf` [fervent_pasteur] DSL2

executor >  local (8)
[a1/b2c3d4] process > AMPSCAN:INPUT_CHECK:SAMPLESHEET_CHECK        [100%] 1 of 1 
[e5/f6g7h8] process > AMPSCAN:AMP_SCREENING:MACREL_CONTIGS (ecoli) [100%] 2 of 2 
[i9/j0k1l2] process > AMPSCAN:AMP_SCREENING:MACREL_CONTIGS (staph) [100%] 2 of 2 
...
```

### Tempo estimado:
- **Primeira execução**: 15-30 minutos (baixando containers)
- **Próximas execuções**: 5-15 minutos

---

## Passo 8: Pipeline Concluído!

Quando terminar, você verá:

```
Completed at: 30-Nov-2025 20:45:32
Duration    : 12m 15s
CPU hours   : 1.2
Succeeded   : 15
```

---

## Passo 9: Explorar os Resultados

### 9.1 Estrutura Criada

```bash
cd ~/Documents/projeto-amps
tree resultados/
```

**Estrutura:**
```
resultados/
├── amp/
│   ├── macrel/
│   │   ├── ecoli_xyz/
│   │   │   ├── ecoli_xyz.prediction.gz
│   │   │   ├── ecoli_xyz.all_orfs.faa.gz
│   │   │   └── ecoli_xyz.stats.tsv
│   │   └── staph_abc/
│   │       ├── staph_abc.prediction.gz
│   │       ├── staph_abc.all_orfs.faa.gz
│   │       └── staph_abc.stats.tsv
├── annotation/
│   ├── ecoli_xyz_properties.tsv
│   └── staph_abc_properties.tsv
├── multiqc/
│   └── multiqc_report.html
└── pipeline_info/
    ├── execution_report.html
    └── execution_timeline.html
```

---

### 9.2 Abrir Relatório Principal

```bash
# macOS
open resultados/multiqc/multiqc_report.html

# Linux
xdg-open resultados/multiqc/multiqc_report.html
```

**O que você verá:**
- Resumo geral das análises
- Número de AMPs encontrados por amostra
- Gráficos comparativos
- Estatísticas de qualidade

---

### 9.3 Ver AMPs Encontrados

```bash
# E. coli
echo "=== E. coli XYZ ==="
zcat resultados/amp/macrel/ecoli_xyz/ecoli_xyz.prediction.gz | head -10

# S. aureus
echo "=== S. aureus ABC ==="
zcat resultados/amp/macrel/staph_abc/staph_abc.prediction.gz | head -10
```

**Exemplo de saída:**
```
sequence_id     sequence                    AMP_probability  AMP_family
ORF_001         MKKLLVLGLVLGPVLG...        0.95            Defensin
ORF_002         ATCDLLSGTGINHSAK...        0.87            Bacteriocin
```

---

### 9.4 Contar AMPs Encontrados

```bash
# Contar por amostra
echo "E. coli: $(zcat resultados/amp/macrel/ecoli_xyz/ecoli_xyz.prediction.gz | tail -n +2 | wc -l) AMPs"
echo "S. aureus: $(zcat resultados/amp/macrel/staph_abc/staph_abc.prediction.gz | tail -n +2 | wc -l) AMPs"
```

---

### 9.5 Ver Propriedades dos Peptídeos

```bash
# Ver propriedades da E. coli
cat resultados/annotation/ecoli_xyz_properties.tsv | column -t | less
```

**Colunas importantes:**
- `length`: Tamanho do peptídeo
- `molecular_weight`: Peso molecular
- `charge_at_pH7`: Carga elétrica
- `gravy`: Hidrofobicidade
- `helix_fraction`: Fração de α-hélice

---

## Passo 10: Análise Avançada

### 10.1 Filtrar AMPs de Alta Confiança

```bash
# AMPs com probabilidade > 0.9
zcat resultados/amp/macrel/ecoli_xyz/ecoli_xyz.prediction.gz | \
  awk -F'\t' 'NR==1 || $3 > 0.9' > amps_alta_confianca.tsv

# Ver quantos
wc -l amps_alta_confianca.tsv
```

---

### 10.2 Gerar Gráficos

```bash
cd ~/Documents/nextflow-case

# Gráficos para E. coli
bin/visualize_results.py \
  --properties ~/Documents/projeto-amps/resultados/annotation/ecoli_xyz_properties.tsv \
  --outdir ~/Documents/projeto-amps/graficos_ecoli/

# Gráficos para S. aureus
bin/visualize_results.py \
  --properties ~/Documents/projeto-amps/resultados/annotation/staph_abc_properties.tsv \
  --outdir ~/Documents/projeto-amps/graficos_staph/
```

**Gráficos gerados:**
- Distribuição de tamanhos
- Distribuição de pesos moleculares
- Distribuição de cargas
- Hidrofobicidade vs Carga
- Estrutura secundária

---

### 10.3 Comparar Amostras

```bash
cd ~/Documents/projeto-amps

# Combinar propriedades
cat resultados/annotation/*_properties.tsv | \
  awk 'NR==1 || !/^sequence_id/' > todas_propriedades.tsv

# Gerar gráficos comparativos
cd ~/Documents/nextflow-case
bin/visualize_results.py \
  --properties ~/Documents/projeto-amps/todas_propriedades.tsv \
  --outdir ~/Documents/projeto-amps/graficos_comparacao/
```

---

## Passo 11: Exportar Resultados

### 11.1 Criar Relatório Resumido

```bash
cd ~/Documents/projeto-amps

cat > resumo_analise.txt << EOF
===========================================
ANÁLISE DE PEPTÍDEOS ANTIMICROBIANOS
===========================================

Data: $(date)
Pipeline: AMPscan v1.0.0

AMOSTRAS ANALISADAS:
-------------------
1. E. coli XYZ
2. S. aureus ABC

RESULTADOS:
-----------
E. coli: $(zcat resultados/amp/macrel/ecoli_xyz/ecoli_xyz.prediction.gz | tail -n +2 | wc -l) AMPs encontrados
S. aureus: $(zcat resultados/amp/macrel/staph_abc/staph_abc.prediction.gz | tail -n +2 | wc -l) AMPs encontrados

ARQUIVOS GERADOS:
-----------------
- Relatório MultiQC: resultados/multiqc/multiqc_report.html
- Predições: resultados/amp/macrel/
- Propriedades: resultados/annotation/
- Gráficos: graficos_*/

===========================================
EOF

cat resumo_analise.txt
```

---

### 11.2 Comprimir Resultados

```bash
# Criar backup comprimido
tar -czf resultados_amps_$(date +%Y%m%d).tar.gz resultados/ graficos_*/

# Verificar tamanho
ls -lh resultados_amps_*.tar.gz
```

---

## Passo 12: Próximas Análises

### Executar Novamente com Parâmetros Diferentes

```bash
cd ~/Documents/nextflow-case

# Procurar peptídeos menores (10-40 aa)
nextflow run main.nf \
  --input ~/Documents/projeto-amps/samplesheet.csv \
  --outdir ~/Documents/projeto-amps/resultados_curtos \
  --amp_macrel_min_length 10 \
  --amp_macrel_max_length 40 \
  -profile docker
```

---

##  Resumo do Exemplo

 **O que fizemos:**
1. Criamos estrutura de diretórios
2. Preparamos dados de entrada (FASTA)
3. Criamos samplesheet
4. Executamos o pipeline
5. Exploramos os resultados
6. Geramos gráficos
7. Criamos relatório resumido

 **O que aprendemos:**
- Como organizar um projeto
- Como preparar dados para o pipeline
- Como executar e monitorar
- Como interpretar resultados
- Como gerar visualizações

 **Tempo total:** ~45 minutos

---

##  Checklist de Conclusão

- [ ] Diretórios criados
- [ ] Dados preparados
- [ ] Samplesheet validado
- [ ] Pipeline executado com sucesso
- [ ] Relatório MultiQC visualizado
- [ ] AMPs identificados
- [ ] Propriedades analisadas
- [ ] Gráficos gerados
- [ ] Resultados exportados

---

##  Dicas Finais

1. **Sempre use caminhos absolutos** no samplesheet
2. **Verifique os dados** antes de executar
3. **Use `-resume`** se a execução for interrompida
4. **Salve o relatório MultiQC** - é o mais importante!
5. **Faça backup** dos resultados importantes

---

##  Próximos Passos

Agora que você completou este exemplo, você pode:

1. **Usar seus dados reais** seguindo o mesmo processo
2. **Explorar parâmetros** diferentes (veja `docs/usage.md`)
3. **Automatizar** análises com scripts
4. **Integrar** com outros pipelines
