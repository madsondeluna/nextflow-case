# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-11-30

### Adicionado

- Pipeline inicial para screening de peptídeos antimicrobianos (AMPs)
- Integração com Macrel para predição de AMPs por machine learning
- Integração com HMMER para busca de domínios conservados
- Integração com AMPcombi para combinação de resultados
- Módulo de anotação para cálculo de propriedades físico-químicas
- Suporte para Docker e Singularity
- Configurações de teste (test e test_full)
- Documentação completa de uso
- Validação automática de samplesheet
- Geração de relatórios MultiQC
- Perfis de configuração para diferentes ambientes

### Características

- Arquitetura modular baseada em Nextflow DSL2
- Containerização completa para reprodutibilidade
- Paralelização automática de amostras
- Retry automático em caso de falhas
- Logs detalhados de execução
- Timeline e relatórios de execução

### Ferramentas Incluídas

- Macrel v1.2.0
- HMMER v3.3.2
- AMPcombi v0.1.7
- Biopython v1.79
- MultiQC

[1.0.0]: https://github.com/madsondeluna/nextflow-case/releases/tag/v1.0.0
