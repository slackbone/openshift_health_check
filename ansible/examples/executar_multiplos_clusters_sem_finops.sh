#!/bin/bash

# Script de Execução em Múltiplos Clusters - OpenShift Health Check SEM FinOps
# Este script demonstra como executar a avaliação de saúde em múltiplos clusters excluindo FinOps

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

# Configurações
CONFIG_FILE=""
DRY_RUN=""
VERBOSE=""
LIST_CLUSTERS=""
SPECIFIC_CLUSTER=""
TAGS=""

# Função para exibir uso
usage() {
    echo "Uso: $0 [OPÇÕES]"
    echo ""
    echo "Executor da Avaliação de Saúde do OpenShift em Múltiplos Clusters - SEM FinOps"
    echo ""
    echo "Opções:"
    echo "  -c, --config FILE           Arquivo de configuração de clusters (obrigatório)"
    echo "  -l, --list                  Listar clusters disponíveis"
    echo "  -s, --specific CLUSTER      Executar apenas em cluster específico"
    echo "  --tags TAGS                 Lista separada por vírgulas de tags para executar"
    echo "  -v, --verbose               Habilitar saída verbosa"
    echo "  -d, --dry-run               Executar em modo de verificação (dry run)"
    echo "  -h, --help                  Mostrar esta mensagem de ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0 -c multiple_clusters_config.yml"
    echo "  $0 -c multiple_clusters_config.yml -s production-cluster"
    echo "  $0 -c multiple_clusters_config.yml --tags seguranca"
    echo "  $0 -c multiple_clusters_config.yml -l"
    echo ""
    echo "Tags disponíveis (SEM FinOps):"
    echo "  coleta_dados      - Coletar dados do cluster OpenShift"
    echo "  arquitetura       - Analisar arquitetura do cluster"
    echo "  seguranca         - Analisar configurações de segurança"
    echo "  boas_praticas     - Analisar conformidade com boas práticas"
    echo "  relatorios        - Gerar relatórios"
    echo ""
    echo "⚠️  IMPORTANTE: FinOps será automaticamente desabilitado em todos os clusters"
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

# Função para listar clusters
list_clusters() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_error "Arquivo de configuração não encontrado: $CONFIG_FILE"
        exit 1
    fi
    
    log "📋 Clusters disponíveis no arquivo $CONFIG_FILE:"
    echo ""
    
    # Extrair nomes dos clusters do arquivo YAML
    if command -v yq &> /dev/null; then
        yq eval '.clusters[].name' "$CONFIG_FILE" | while read -r cluster; do
            echo "  - $cluster"
        done
    else
        # Fallback usando grep (menos preciso)
        grep -A 1 "name:" "$CONFIG_FILE" | grep -v "name:" | sed 's/^[[:space:]]*//' | sed 's/"//g' | while read -r cluster; do
            if [[ -n "$cluster" ]]; then
                echo "  - $cluster"
            fi
        done
    fi
    echo ""
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        -l|--list)
            LIST_CLUSTERS="true"
            shift
            ;;
        -s|--specific)
            SPECIFIC_CLUSTER="$2"
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
        -d|--dry-run)
            DRY_RUN="--check"
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
if [[ -z "$CONFIG_FILE" && "$LIST_CLUSTERS" != "true" ]]; then
    log_error "Arquivo de configuração é obrigatório. Use a opção -c ou --config."
    usage
    exit 1
fi

# Se apenas listar clusters
if [[ "$LIST_CLUSTERS" == "true" ]]; then
    list_clusters
    exit 0
fi

# Verificar se o arquivo de configuração existe
if [[ ! -f "$CONFIG_FILE" ]]; then
    log_error "Arquivo de configuração não encontrado: $CONFIG_FILE"
    exit 1
fi

# Definir tags padrão se não fornecidas
if [[ -z "$TAGS" ]]; then
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

log "🚀 Iniciando Avaliação de Saúde do OpenShift em Múltiplos Clusters - SEM FinOps..."
log "📁 Arquivo de Configuração: $CONFIG_FILE"
log "🏷️  Tags: $TAGS"
log "⚠️  FinOps: DESABILITADO em todos os clusters"

# Função para executar health check em um cluster
run_health_check() {
    local cluster_name="$1"
    local cluster_url="$2"
    local cluster_token="$3"
    local cluster_tags="$4"
    
    log "🎯 Executando health check para cluster: $cluster_name"
    log "📊 URL: $cluster_url"
    
    # Build ansible-playbook command
    local ansible_cmd="ansible-playbook"
    ansible_cmd="$ansible_cmd -i inventory/hosts.yml"
    ansible_cmd="$ansible_cmd playbooks/openshift_health_check.yml"
    ansible_cmd="$ansible_cmd -e cluster_url='$cluster_url'"
    ansible_cmd="$ansible_cmd -e cluster_token='$cluster_token'"
    ansible_cmd="$ansible_cmd -e cluster_name='$cluster_name'"
    ansible_cmd="$ansible_cmd -e analyze_cost_optimization=false"
    ansible_cmd="$ansible_cmd -e enable_cost_analysis=false"
    ansible_cmd="$ansible_cmd --tags '$cluster_tags'"
    
    if [[ -n "$VERBOSE" ]]; then
        ansible_cmd="$ansible_cmd $VERBOSE"
    fi
    
    if [[ -n "$DRY_RUN" ]]; then
        ansible_cmd="$ansible_cmd $DRY_RUN"
    fi
    
    # Change to ansible directory
    cd "$ANSIBLE_DIR"
    
    # Executar o playbook
    if eval "$ansible_cmd"; then
        log_success "✅ Health check concluído com sucesso para $cluster_name"
        return 0
    else
        log_error "❌ Health check falhou para $cluster_name"
        return 1
    fi
}

# Processar arquivo de configuração
if command -v yq &> /dev/null; then
    # Usar yq se disponível (mais preciso)
    clusters_count=$(yq eval '.clusters | length' "$CONFIG_FILE")
    
    for ((i=0; i<clusters_count; i++)); do
        cluster_name=$(yq eval ".clusters[$i].name" "$CONFIG_FILE")
        cluster_url=$(yq eval ".clusters[$i].url" "$CONFIG_FILE")
        cluster_token=$(yq eval ".clusters[$i].token" "$CONFIG_FILE")
        cluster_tags=$(yq eval ".clusters[$i].tags // \"$TAGS\"" "$CONFIG_FILE")
        
        # Se cluster específico foi solicitado, pular outros
        if [[ -n "$SPECIFIC_CLUSTER" && "$cluster_name" != "$SPECIFIC_CLUSTER" ]]; then
            continue
        fi
        
        # Executar health check
        if run_health_check "$cluster_name" "$cluster_url" "$cluster_token" "$cluster_tags"; then
            log_success "🎉 Cluster $cluster_name processado com sucesso"
        else
            log_error "💥 Falha ao processar cluster $cluster_name"
        fi
        
        echo ""
    done
else
    # Fallback usando grep (menos preciso)
    log_warning "⚠️  yq não está instalado, usando método alternativo (menos preciso)"
    
    # Extrair informações dos clusters
    while IFS= read -r line; do
        if [[ "$line" =~ name:.*\"(.+)\" ]]; then
            cluster_name="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ url:.*\"(.+)\" ]]; then
            cluster_url="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ token:.*\"(.+)\" ]]; then
            cluster_token="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ tags:.*\"(.+)\" ]]; then
            cluster_tags="${BASH_REMATCH[1]}"
        fi
        
        # Se temos todas as informações, executar
        if [[ -n "$cluster_name" && -n "$cluster_url" && -n "$cluster_token" ]]; then
            # Se cluster específico foi solicitado, pular outros
            if [[ -n "$SPECIFIC_CLUSTER" && "$cluster_name" != "$SPECIFIC_CLUSTER" ]]; then
                cluster_name=""
                cluster_url=""
                cluster_token=""
                cluster_tags=""
                continue
            fi
            
            # Usar tags padrão se não especificadas
            if [[ -z "$cluster_tags" ]]; then
                cluster_tags="$TAGS"
            fi
            
            # Executar health check
            if run_health_check "$cluster_name" "$cluster_url" "$cluster_token" "$cluster_tags"; then
                log_success "🎉 Cluster $cluster_name processado com sucesso"
            else
                log_error "💥 Falha ao processar cluster $cluster_name"
            fi
            
            echo ""
            
            # Reset para próximo cluster
            cluster_name=""
            cluster_url=""
            cluster_token=""
            cluster_tags=""
        fi
    done < "$CONFIG_FILE"
fi

# Verificar se cluster específico foi solicitado mas não encontrado
if [[ -n "$SPECIFIC_CLUSTER" ]]; then
    if ! grep -q "name:.*\"$SPECIFIC_CLUSTER\"" "$CONFIG_FILE"; then
        log_error "Cluster '$SPECIFIC_CLUSTER' não encontrado no arquivo de configuração"
        exit 1
    fi
fi

log_success "🎉 Execução em múltiplos clusters concluída (SEM FinOps)!"

# Listar relatórios gerados
log "📊 Relatórios gerados:"
find ../reports -type d -name "20*" | sort | while read -r report_dir; do
    cluster_name=$(basename "$report_dir" | cut -d'_' -f1)
    timestamp=$(basename "$report_dir" | cut -d'_' -f2-)
    log "  - $cluster_name ($timestamp)"
done

log ""
log "🌐 Para visualizar os relatórios HTML:"
find ../reports -name "consolidated_health_check_report.html" | while read -r html_file; do
    log "   file://$(realpath "$html_file")"
done
