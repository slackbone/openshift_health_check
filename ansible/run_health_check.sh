#!/bin/bash

# Script de Execução da Avaliação de Saúde do OpenShift
# Este script fornece uma forma fácil de executar o playbook de avaliação de saúde do OpenShift

set -e

# Cores para saída
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sem Cor

# Diretório do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="${SCRIPT_DIR}"

# Valores padrão
CLUSTER_URL=""
CLUSTER_TOKEN=""
KUBECONFIG_PATH=""
TAGS=""
VERBOSE=""
DRY_RUN=""
CHECK_ONLY=""

# Função para exibir uso
usage() {
    echo "Uso: $0 [OPÇÕES]"
    echo ""
    echo "Executor da Avaliação de Saúde do OpenShift"
    echo ""
    echo "Opções:"
    echo "  -u, --url URL              URL do cluster OpenShift (obrigatório)"
    echo "  -t, --token TOKEN          Token de autenticação OpenShift (obrigatório)"
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
    echo "Tags disponíveis:"
    echo "  coleta_dados      - Coletar dados do cluster OpenShift"
    echo "  arquitetura       - Analisar arquitetura do cluster"
    echo "  seguranca         - Analisar configurações de segurança"
    echo "  boas_praticas     - Analisar conformidade com boas práticas"
    echo "  recursos          - Analisar otimização de recursos"
    echo "  relatorios        - Gerar relatórios"
    echo "  todos             - Executar todas as análises (padrão)"
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
            CHECK_ONLY="--check"
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
            log_error "Unknown option: $1"
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

# Definir kubeconfig padrão se não fornecido
if [[ -z "$KUBECONFIG_PATH" ]]; then
    KUBECONFIG_PATH="~/.kube/config"
fi

# Definir tags padrão se não fornecidas
if [[ -z "$TAGS" ]]; then
    TAGS="todos"
fi

# Criar diretório de logs
mkdir -p "${ANSIBLE_DIR}/logs"

# Criar diretório de relatórios
mkdir -p "${ANSIBLE_DIR}/../reports"

log "Iniciando Avaliação de Saúde do OpenShift..."
log "URL do Cluster: $CLUSTER_URL"
log "Kubeconfig: $KUBECONFIG_PATH"
log "Tags: $TAGS"

# Build ansible-playbook command
ANSIBLE_CMD="ansible-playbook"
ANSIBLE_CMD="$ANSIBLE_CMD -i inventory/hosts.yml"
ANSIBLE_CMD="$ANSIBLE_CMD playbooks/openshift_health_check.yml"
ANSIBLE_CMD="$ANSIBLE_CMD -e cluster_url='$CLUSTER_URL'"
ANSIBLE_CMD="$ANSIBLE_CMD -e cluster_token='$CLUSTER_TOKEN'"
ANSIBLE_CMD="$ANSIBLE_CMD -e kubeconfig_path='$KUBECONFIG_PATH'"
ANSIBLE_CMD="$ANSIBLE_CMD --tags '$TAGS'"

if [[ -n "$VERBOSE" ]]; then
    ANSIBLE_CMD="$ANSIBLE_CMD $VERBOSE"
fi

if [[ -n "$CHECK_ONLY" ]]; then
    ANSIBLE_CMD="$ANSIBLE_CMD $CHECK_ONLY"
fi

if [[ -n "$DIFF" ]]; then
    ANSIBLE_CMD="$ANSIBLE_CMD $DIFF"
fi

# Change to ansible directory
cd "$ANSIBLE_DIR"

# Executar o playbook
log "Executando: $ANSIBLE_CMD"
if eval "$ANSIBLE_CMD"; then
    log_success "Avaliação de Saúde do OpenShift concluída com sucesso!"
    
    # Encontrar o diretório de relatório mais recente
    LATEST_REPORT=$(find ../reports -type d -name "20*" | sort | tail -1)
    if [[ -n "$LATEST_REPORT" ]]; then
        log_success "Relatórios gerados em: $LATEST_REPORT"
        log "Relatórios disponíveis:"
        find "$LATEST_REPORT" -name "*.html" -o -name "*.json" -o -name "*.md" | while read -r file; do
            log "  - $(basename "$file")"
        done
    fi
else
    log_error "Avaliação de Saúde do OpenShift falhou!"
    exit 1
fi
