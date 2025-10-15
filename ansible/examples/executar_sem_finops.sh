#!/bin/bash

# Script de Execução - OpenShift Health Check SEM FinOps
# Este script demonstra como executar a avaliação de saúde excluindo funcionalidades de FinOps

set -e

# Cores para saída
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sem Cor

# Diretório do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="${SCRIPT_DIR}/.."

# Valores padrão
CLUSTER_URL=""
CLUSTER_TOKEN=""
CLUSTER_NAME=""
KUBECONFIG_PATH=""
VERBOSE=""
DRY_RUN=""
TAGS=""

# Função para exibir uso
usage() {
    echo "Uso: $0 [OPÇÕES]"
    echo ""
    echo "Executor da Avaliação de Saúde do OpenShift - SEM FinOps"
    echo ""
    echo "Opções:"
    echo "  -u, --url URL              URL do cluster OpenShift (obrigatório)"
    echo "  -t, --token TOKEN          Token de autenticação OpenShift (obrigatório)"
    echo "  -n, --name NAME            Nome do cluster (opcional, padrão: openshift-cluster)"
    echo "  -k, --kubeconfig CAMINHO   Caminho para arquivo kubeconfig (opcional)"
    echo "  --tags TAGS                Lista separada por vírgulas de tags para executar"
    echo "  -v, --verbose              Habilitar saída verbosa"
    echo "  --check                    Executar em modo de verificação (dry run)"
    echo "  --diff                     Mostrar diferenças quando arquivos são alterados"
    echo "  -h, --help                 Mostrar esta mensagem de ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0 -u https://api.cluster.example.com:6443 -t sha256~abc123..."
    echo "  $0 -u https://api.cluster.example.com:6443 -t sha256~abc123... --tags seguranca"
    echo "  $0 -u https://api.cluster.example.com:6443 -t sha256~abc123... --check"
    echo ""
    echo "Tags disponíveis (SEM FinOps):"
    echo "  coleta_dados      - Coletar dados do cluster OpenShift"
    echo "  arquitetura       - Analisar arquitetura do cluster"
    echo "  seguranca         - Analisar configurações de segurança"
    echo "  boas_praticas     - Analisar conformidade com boas práticas"
    echo "  relatorios        - Gerar relatórios"
    echo "  todos_sem_finops  - Executar todas as análises exceto FinOps"
    echo ""
    echo "⚠️  IMPORTANTE: A tag 'recursos' contém FinOps e será excluída automaticamente"
}

# Função para registrar mensagens
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# Função para registrar erros
log_error() {
    echo -e "${RED}[ERRO]${NC} $1" >&2
}

# Função para registrar sucesso
log_success() {
    echo -e "${GREEN}[SUCESSO]${NC} $1"
}

# Função para registrar avisos
log_warning() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -u|--url)
            CLUSTER_URL="$2"
            shift 2
            ;;
        -t|--token)
            CLUSTER_TOKEN="$2"
            shift 2
            ;;
        -n|--name)
            CLUSTER_NAME="$2"
            shift 2
            ;;
        -k|--kubeconfig)
            KUBECONFIG_PATH="$2"
            shift 2
            ;;
        --tags)
            TAGS="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE="-v"
            shift
            ;;
        --check)
            DRY_RUN="--check"
            shift
            ;;
        --diff)
            DIFF="--diff"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            log_error "Opção desconhecida: $1"
            usage
            exit 1
            ;;
    esac
done

# Validar parâmetros obrigatórios
if [[ -z "$CLUSTER_URL" ]]; then
    log_error "URL do cluster é obrigatória. Use a opção -u ou --url."
    usage
    exit 1
fi

if [[ -z "$CLUSTER_TOKEN" ]]; then
    log_error "Token do cluster é obrigatório. Use a opção -t ou --token."
    usage
    exit 1
fi

# Definir valores padrão
if [[ -z "$CLUSTER_NAME" ]]; then
    CLUSTER_NAME="openshift-cluster"
fi

if [[ -z "$KUBECONFIG_PATH" ]]; then
    KUBECONFIG_PATH="~/.kube/config"
fi

# Processar tags - excluir FinOps automaticamente
if [[ -z "$TAGS" ]]; then
    TAGS="todos_sem_finops"
fi

# Remover 'recursos' das tags se presente (contém FinOps)
if [[ "$TAGS" == *"recursos"* ]]; then
    log_warning "Removendo tag 'recursos' pois contém funcionalidades de FinOps"
    TAGS=$(echo "$TAGS" | sed 's/recursos,//g' | sed 's/,recursos//g' | sed 's/recursos//g')
fi

# Se 'todos' estiver presente, substituir por tags sem FinOps
if [[ "$TAGS" == *"todos"* ]]; then
    log_warning "Substituindo 'todos' por tags sem FinOps"
    TAGS="coleta_dados,arquitetura,seguranca,boas_praticas,relatorios"
fi

# Verificar se o Ansible está instalado
if ! command -v ansible-playbook &> /dev/null; then
    log_error "Ansible não está instalado. Por favor, instale o Ansible primeiro."
    exit 1
fi

# Verificar se oc ou kubectl está disponível
if ! command -v oc &> /dev/null && ! command -v kubectl &> /dev/null; then
    log_error "Nem o comando 'oc' nem 'kubectl' está disponível. Por favor, instale o OpenShift CLI ou Kubernetes CLI."
    exit 1
fi

# Criar diretório de logs
mkdir -p "${ANSIBLE_DIR}/logs"

# Criar diretório de relatórios
mkdir -p "${ANSIBLE_DIR}/../reports"

log "🚀 Iniciando Avaliação de Saúde do OpenShift - SEM FinOps..."
log "📊 URL do Cluster: $CLUSTER_URL"
log "🏷️  Nome do Cluster: $CLUSTER_NAME"
log "📁 Kubeconfig: $KUBECONFIG_PATH"
log "🏷️  Tags: $TAGS"
log "⚠️  FinOps: DESABILITADO"

# Verificar conectividade básica
log "🔍 Verificando conectividade com o cluster..."
if command -v oc &> /dev/null; then
    if oc cluster-info --server="$CLUSTER_URL" --token="$CLUSTER_TOKEN" &> /dev/null; then
        log_success "✅ Conectividade com o cluster verificada"
    else
        log_warning "⚠️  Não foi possível verificar conectividade, mas continuando..."
    fi
fi

# Build ansible-playbook command
ANSIBLE_CMD="ansible-playbook"
ANSIBLE_CMD="$ANSIBLE_CMD -i inventory/hosts.yml"
ANSIBLE_CMD="$ANSIBLE_CMD playbooks/openshift_health_check.yml"
ANSIBLE_CMD="$ANSIBLE_CMD -e cluster_url='$CLUSTER_URL'"
ANSIBLE_CMD="$ANSIBLE_CMD -e cluster_token='$CLUSTER_TOKEN'"
ANSIBLE_CMD="$ANSIBLE_CMD -e cluster_name='$CLUSTER_NAME'"
ANSIBLE_CMD="$ANSIBLE_CMD -e kubeconfig_path='$KUBECONFIG_PATH'"
ANSIBLE_CMD="$ANSIBLE_CMD -e analyze_cost_optimization=false"
ANSIBLE_CMD="$ANSIBLE_CMD -e enable_cost_analysis=false"
ANSIBLE_CMD="$ANSIBLE_CMD --tags '$TAGS'"

if [[ -n "$VERBOSE" ]]; then
    ANSIBLE_CMD="$ANSIBLE_CMD $VERBOSE"
fi

if [[ -n "$DRY_RUN" ]]; then
    ANSIBLE_CMD="$ANSIBLE_CMD $DRY_RUN"
fi

if [[ -n "$DIFF" ]]; then
    ANSIBLE_CMD="$ANSIBLE_CMD $DIFF"
fi

# Change to ansible directory
cd "$ANSIBLE_DIR"

# Executar o playbook
log "🎯 Executando: $ANSIBLE_CMD"
if eval "$ANSIBLE_CMD"; then
    log_success "🎉 Avaliação de Saúde do OpenShift concluída com sucesso (SEM FinOps)!"
    
    # Encontrar o diretório de relatório mais recente
    LATEST_REPORT=$(find ../reports -type d -name "20*" | sort | tail -1)
    if [[ -n "$LATEST_REPORT" ]]; then
        log_success "📊 Relatórios gerados em: $LATEST_REPORT"
        log "📋 Relatórios disponíveis:"
        
        # Listar relatórios HTML
        if [[ -d "$LATEST_REPORT/html" ]]; then
            log "  📄 Relatórios HTML (Executivos):"
            find "$LATEST_REPORT/html" -name "*.html" | while read -r file; do
                log "    - $(basename "$file")"
            done
        fi
        
        # Listar relatórios Markdown
        if [[ -d "$LATEST_REPORT" ]]; then
            log "  📝 Relatórios Markdown (Detalhados):"
            find "$LATEST_REPORT" -name "*.md" | while read -r file; do
                log "    - $(basename "$file")"
            done
        fi
        
        # Listar dados JSON
        if [[ -d "$LATEST_REPORT" ]]; then
            log "  📊 Dados JSON:"
            find "$LATEST_REPORT" -name "*.json" | while read -r file; do
                log "    - $(basename "$file")"
            done
        fi
        
        # Verificar se há relatórios de FinOps (não deveria ter)
        if [[ -d "$LATEST_REPORT/resource_optimization" ]]; then
            log_warning "⚠️  Diretório resource_optimization encontrado - verificar se FinOps foi desabilitado corretamente"
        fi
        
        log ""
        log "🌐 Para visualizar o relatório HTML executivo:"
        log "   file://$LATEST_REPORT/html/consolidated/consolidated_health_check_report.html"
        log ""
        log "📖 Para visualizar o relatório Markdown detalhado:"
        log "   cat $LATEST_REPORT/consolidated/consolidated_health_check_report.md"
    fi
else
    log_error "❌ Avaliação de Saúde do OpenShift falhou!"
    exit 1
fi
