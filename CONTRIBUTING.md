# Contributing to AMPscan

Obrigado por considerar contribuir para o AMPscan! 🎉

## Como Contribuir

### Reportar Bugs

Se você encontrar um bug, por favor abra uma [issue](https://github.com/madsondeluna/nextflow-case/issues) incluindo:

- Descrição clara do problema
- Passos para reproduzir
- Comportamento esperado vs. observado
- Versão do Nextflow e perfil usado
- Arquivo `.nextflow.log` (se relevante)

### Sugerir Melhorias

Sugestões são bem-vindas! Abra uma issue com:

- Descrição da melhoria
- Justificativa (por que seria útil)
- Exemplos de uso (se aplicável)

### Pull Requests

1. **Fork** o repositório
2. **Clone** seu fork localmente
3. **Crie um branch** para sua feature: `git checkout -b feature/minha-feature`
4. **Faça suas mudanças** seguindo o estilo do código
5. **Teste** suas mudanças: `nextflow run main.nf -profile test,docker`
6. **Commit** suas mudanças: `git commit -m "Add: minha feature"`
7. **Push** para seu fork: `git push origin feature/minha-feature`
8. Abra um **Pull Request**

## Diretrizes de Código

### Nextflow

- Use **DSL2** syntax
- Siga padrões **nf-core** quando possível
- Documente processos e workflows
- Use labels apropriados para recursos

```groovy
process EXEMPLO {
    tag "$meta.id"
    label 'process_medium'
    
    input:
    tuple val(meta), path(input)
    
    output:
    tuple val(meta), path("output"), emit: resultado
    
    script:
    """
    comando --input $input --output output
    """
}
```

### Python

- Siga **PEP 8**
- Use type hints quando possível
- Documente funções com docstrings
- Adicione shebang: `#!/usr/bin/env python3`

```python
#!/usr/bin/env python3

def calcular_propriedade(sequencia: str) -> float:
    """
    Calcula propriedade da sequência.
    
    Args:
        sequencia: Sequência de aminoácidos
        
    Returns:
        Valor da propriedade calculada
    """
    return resultado
```

### Groovy

- Use indentação de 4 espaços
- Documente classes e métodos
- Siga convenções Java/Groovy

## Adicionar Nova Ferramenta

Para adicionar uma nova ferramenta de predição de AMPs:

1. **Criar módulo** em `modules/local/nova_ferramenta.nf`
2. **Adicionar ao subworkflow** `amp_screening.nf`
3. **Adicionar parâmetros** em `nextflow.config`
4. **Adicionar container** (Docker/Singularity)
5. **Atualizar documentação**
6. **Adicionar testes**

### Template de Módulo

```groovy
process NOVA_FERRAMENTA {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::ferramenta=1.0.0"
    container "${ workflow.containerEngine == 'singularity' ?
        'https://depot.galaxyproject.org/singularity/ferramenta:1.0.0' :
        'biocontainers/ferramenta:1.0.0' }"

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path("*.tsv"), emit: predictions
    path "versions.yml", emit: versions

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    ferramenta \\
        --input $fasta \\
        --output ${prefix}.tsv \\
        --threads $task.cpus

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        ferramenta: \$(ferramenta --version)
    END_VERSIONS
    """
}
```

## Testes

### Executar Testes

```bash
# Teste mínimo
nextflow run main.nf -profile test,docker

# Teste completo
nextflow run main.nf -profile test_full,docker
```

### Adicionar Novos Testes

1. Adicionar dados de teste em `assets/`
2. Criar/atualizar `conf/test*.config`
3. Documentar resultados esperados

## Documentação

Ao adicionar features, atualize:

- `README.md` - Visão geral
- `docs/usage.md` - Instruções de uso
- `docs/architecture.md` - Detalhes técnicos
- `CHANGELOG.md` - Mudanças
- `CITATIONS.md` - Novas ferramentas

## Versionamento

Seguimos [Semantic Versioning](https://semver.org/):

- **MAJOR**: Mudanças incompatíveis
- **MINOR**: Novas features compatíveis
- **PATCH**: Bug fixes

## Código de Conduta

- Seja respeitoso e construtivo
- Aceite feedback com boa vontade
- Foque no que é melhor para a comunidade

## Licença

Ao contribuir, você concorda que suas contribuições serão licenciadas sob a mesma licença MIT do projeto.

## Dúvidas?

Abra uma [issue](https://github.com/madsondeluna/nextflow-case/issues) ou entre em contato!

---

Obrigado por contribuir! 
