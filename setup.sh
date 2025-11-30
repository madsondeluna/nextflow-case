#!/bin/bash

# AMPscan Setup Script
# Este script ajuda na configuração inicial do ambiente

set -e

echo "=================================="
echo "  AMPscan Setup"
echo "=================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "ℹ $1"
}

# Check Nextflow
echo "Verificando dependências..."
echo ""

if command -v nextflow &> /dev/null; then
    NF_VERSION=$(nextflow -version 2>&1 | grep "version" | awk '{print $3}')
    print_success "Nextflow instalado (versão $NF_VERSION)"
else
    print_error "Nextflow não encontrado"
    echo ""
    echo "Instalar Nextflow? (y/n)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Instalando Nextflow..."
        curl -s https://get.nextflow.io | bash
        sudo mv nextflow /usr/local/bin/
        print_success "Nextflow instalado com sucesso!"
    else
        print_warning "Nextflow é necessário para executar o pipeline"
    fi
fi

# Check Docker
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | awk '{print $3}' | sed 's/,//')
    print_success "Docker instalado (versão $DOCKER_VERSION)"
    
    # Check if Docker is running
    if docker info &> /dev/null; then
        print_success "Docker está rodando"
    else
        print_warning "Docker está instalado mas não está rodando"
        echo "  Por favor, inicie o Docker Desktop"
    fi
else
    print_warning "Docker não encontrado (recomendado)"
    echo "  Você pode usar Singularity ou Conda como alternativa"
fi

# Check Singularity
if command -v singularity &> /dev/null; then
    SING_VERSION=$(singularity --version)
    print_success "Singularity instalado ($SING_VERSION)"
fi

echo ""
echo "=================================="
echo "  Configuração de Teste"
echo "=================================="
echo ""

# Ask if user wants to run test
echo "Deseja executar um teste rápido do pipeline? (y/n)"
read -r response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo ""
    print_info "Executando teste com dados de exemplo..."
    echo ""
    
    # Determine profile
    PROFILE="test"
    if command -v docker &> /dev/null && docker info &> /dev/null; then
        PROFILE="test,docker"
        print_info "Usando perfil: $PROFILE"
    elif command -v singularity &> /dev/null; then
        PROFILE="test,singularity"
        print_info "Usando perfil: $PROFILE"
    else
        print_warning "Nem Docker nem Singularity disponíveis"
        print_warning "Tentando com Conda (não recomendado)"
        PROFILE="test,conda"
    fi
    
    echo ""
    echo "Comando: nextflow run main.nf -profile $PROFILE"
    echo ""
    echo "Pressione Enter para continuar ou Ctrl+C para cancelar..."
    read -r
    
    nextflow run main.nf -profile $PROFILE
    
    if [ $? -eq 0 ]; then
        echo ""
        print_success "Teste concluído com sucesso!"
        echo ""
        echo "Resultados em: results/"
        echo "Relatório MultiQC: results/multiqc/multiqc_report.html"
    else
        print_error "Teste falhou. Verifique os logs acima."
    fi
fi

echo ""
echo "=================================="
echo "  Próximos Passos"
echo "=================================="
echo ""
echo "1. Prepare seu samplesheet.csv:"
echo "   sample,fasta"
echo "   amostra1,/caminho/para/amostra1.fasta"
echo ""
echo "2. Execute o pipeline:"
echo "   nextflow run main.nf --input samplesheet.csv --outdir results -profile docker"
echo ""
echo "3. Consulte a documentação:"
echo "   - Início rápido: docs/quickstart.md"
echo "   - Guia completo: docs/usage.md"
echo "   - Arquitetura: docs/architecture.md"
echo ""
echo "Para mais informações: https://github.com/seu-usuario/nextflow-case"
echo ""
print_success "Setup concluído!"
echo ""
