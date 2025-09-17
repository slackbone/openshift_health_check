# Exemplos de Uso - OpenShift Health Check

Este documento fornece exemplos práticos de como usar a ferramenta OpenShift Health Check.

> **📢 Atualização v1.1.0**: Este documento contém exemplos da versão anterior. Para exemplos atualizados com a nova estrutura de relatórios organizados por execução e tipo, consulte [example_usage_updated.md](example_usage_updated.md).

## Exemplos Básicos

### 1. Execução Completa

```bash
# Execução completa com todos os módulos
./ansible/run_health_check.sh \
  -u https://api.cluster.example.com:6443 \
  -t sha256~eyJhbGciOiJSUzI1NiIsImtpZCI6Ik1yNS1BVWliZkJpaTdOZDFqQmViYXhib1hXMCJ9...
```

### 2. Análise de Segurança Apenas

```bash
# Executar apenas análise de segurança
./ansible/run_health_check.sh \
  -u https://api.cluster.example.com:6443 \
  -t sha256~eyJhbGciOiJSUzI1NiIsImtpZCI6Ik1yNS1BVWliZkJpaTdOZDFqQmViYXhib1hXMCJ9... \
  --tags security
```

### 3. Análise de Arquitetura e Recursos

```bash
# Executar análise de arquitetura e recursos
./ansible/run_health_check.sh \
  -u https://api.cluster.example.com:6443 \
  -t sha256~eyJhbGciOiJSUzI1NiIsImtpZCI6Ik1yNS1BVWliZkJpaTdOZDFqQmViYXhib1hXMCJ9... \
  --tags "architecture,resources"
```

## Exemplos Avançados

### 1. Modo de Verificação (Dry Run)

```bash
# Verificar o que seria executado sem executar
./ansible/run_health_check.sh \
  -u https://api.cluster.example.com:6443 \
  -t sha256~eyJhbGciOiJSUzI1NiIsImtpZCI6Ik1yNS1BVWliZkJpaTdOZDFqQmViYXhib1hXMCJ9... \
  --check
```

### 2. Execução com Saída Verbosa

```bash
# Executar com saída detalhada
./ansible/run_health_check.sh \
  -u https://api.cluster.example.com:6443 \
  -t sha256~eyJhbGciOiJSUzI1NiIsImtpZCI6Ik1yNS1BVWliZkJpaTdOZDFqQmViYXhib1hXMCJ9... \
  --verbose
```

### 3. Usando Kubeconfig Personalizado

```bash
# Usar kubeconfig personalizado
./ansible/run_health_check.sh \
  -u https://api.cluster.example.com:6443 \
  -t sha256~eyJhbGciOiJSUzI1NiIsImtpZCI6Ik1yNS1BVWliZkJpaTdOZDFqQmViYXhib1hXMCJ9... \
  -k /path/to/custom/kubeconfig
```

## Exemplos com Ansible Direto

### 1. Execução Básica

```bash
cd ansible

ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  -e cluster_url="https://api.cluster.example.com:6443" \
  -e cluster_token="sha256~eyJhbGciOiJSUzI1NiIsImtpZCI6Ik1yNS1BVWliZkJpaTdOZDFqQmViYXhib1hXMCJ9..."
```

### 2. Execução com Variáveis Personalizadas

```bash
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  -e cluster_url="https://api.cluster.example.com:6443" \
  -e cluster_token="sha256~eyJhbGciOiJSUzI1NiIsImtpZCI6Ik1yNS1BVWliZkJpaTdOZDFqQmViYXhib1hXMCJ9..." \
  -e max_privileged_containers=5 \
  -e min_master_nodes=3
```

### 3. Execução com Tags Específicas

```bash
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  -e cluster_url="https://api.cluster.example.com:6443" \
  -e cluster_token="sha256~eyJhbGciOiJSUzI1NiIsImtpZCI6Ik1yNS1BVWliZkJpaTdOZDFqQmViYXhib1hXMCJ9..." \
  --tags "data_collection,security"
```

## Exemplos de Configuração

### 1. Arquivo de Inventário Personalizado

```yaml
# inventory/custom_hosts.yml
all:
  children:
    production_clusters:
      hosts:
        prod-cluster-1:
          ansible_host: bastion-prod.example.com
          ansible_user: admin
          openshift_cluster_url: "https://api.prod-cluster-1.example.com:6443"
          openshift_token: "sha256~prod-token-1..."
          
        prod-cluster-2:
          ansible_host: bastion-prod.example.com
          ansible_user: admin
          openshift_cluster_url: "https://api.prod-cluster-2.example.com:6443"
          openshift_token: "sha256~prod-token-2..."
          
    staging_clusters:
      hosts:
        staging-cluster:
          ansible_host: bastion-staging.example.com
          ansible_user: admin
          openshift_cluster_url: "https://api.staging-cluster.example.com:6443"
          openshift_token: "sha256~staging-token..."
```

### 2. Variáveis de Grupo Personalizadas

```yaml
# group_vars/production_clusters.yml
# Configurações específicas para clusters de produção
max_privileged_containers: 0
max_root_containers: 0
min_master_nodes: 3
min_worker_nodes: 3

# Configurações de coleta mais rigorosas
collect_metrics: true
collect_events: true
analyze_compliance: true
```

### 3. Variáveis de Host Personalizadas

```yaml
# host_vars/prod-cluster-1.yml
# Configurações específicas para um cluster
openshift_cluster_url: "https://api.prod-cluster-1.example.com:6443"
openshift_token: "sha256~prod-token-1..."
openshift_context: "production"

# Configurações personalizadas
max_node_cpu_usage: 70
max_node_memory_usage: 70
```

## Exemplos de Automação

### 1. Script de Automação Diária

```bash
#!/bin/bash
# daily_health_check.sh

CLUSTERS=(
  "https://api.cluster1.example.com:6443:token1"
  "https://api.cluster2.example.com:6443:token2"
  "https://api.cluster3.example.com:6443:token3"
)

for cluster_info in "${CLUSTERS[@]}"; do
  IFS=':' read -r url token <<< "$cluster_info"
  
  echo "Running health check for $url"
  
  ./ansible/run_health_check.sh \
    -u "$url" \
    -t "$token" \
    --tags "security,architecture"
    
  if [ $? -eq 0 ]; then
    echo "Health check completed successfully for $url"
  else
    echo "Health check failed for $url"
  fi
done
```

### 2. Integração com CI/CD

```yaml
# .github/workflows/health-check.yml
name: OpenShift Health Check

on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM
  workflow_dispatch:

jobs:
  health-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Install Ansible
        run: |
          sudo apt update
          sudo apt install ansible
          
      - name: Install OpenShift CLI
        run: |
          curl -L https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz | tar -xz
          sudo mv oc /usr/local/bin/
          
      - name: Run Health Check
        run: |
          ./ansible/run_health_check.sh \
            -u ${{ secrets.CLUSTER_URL }} \
            -t ${{ secrets.CLUSTER_TOKEN }} \
            --tags security
            
      - name: Upload Reports
        uses: actions/upload-artifact@v2
        with:
          name: health-check-reports
          path: reports/
```

### 3. Monitoramento com Alertas

```bash
#!/bin/bash
# health_check_with_alerts.sh

CLUSTER_URL="https://api.cluster.example.com:6443"
CLUSTER_TOKEN="sha256~your-token-here"
WEBHOOK_URL="https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"

# Executar health check
./ansible/run_health_check.sh \
  -u "$CLUSTER_URL" \
  -t "$CLUSTER_TOKEN" \
  --tags security

# Verificar se houve problemas de segurança
LATEST_REPORT=$(find reports -type d -name "20*" | sort | tail -1)
SECURITY_SCORE=$(jq -r '.overall_security_score' "$LATEST_REPORT/security_analysis/security_analysis.json")

if [ "$SECURITY_SCORE" -lt 70 ]; then
  # Enviar alerta para Slack
  curl -X POST -H 'Content-type: application/json' \
    --data "{\"text\":\"⚠️ Security Alert: Cluster security score is $SECURITY_SCORE/100\"}" \
    "$WEBHOOK_URL"
fi
```

## Exemplos de Troubleshooting

### 1. Verificar Conectividade

```bash
# Testar conectividade com o cluster
oc cluster-info --server="$CLUSTER_URL" --token="$CLUSTER_TOKEN"

# Verificar permissões
oc auth can-i list pods --all-namespaces --server="$CLUSTER_URL" --token="$CLUSTER_TOKEN"
```

### 2. Executar em Modo Debug

```bash
# Executar com debug máximo
ANSIBLE_DEBUG=1 ./ansible/run_health_check.sh \
  -u "$CLUSTER_URL" \
  -t "$CLUSTER_TOKEN" \
  --verbose
```

### 3. Verificar Logs

```bash
# Verificar logs do Ansible
tail -f ansible/logs/ansible.log

# Verificar dados coletados
ls -la reports/*/raw_data/

# Verificar relatórios gerados
ls -la reports/*/
```

## Exemplos de Personalização

### 1. Adicionar Novas Verificações de Segurança

```yaml
# roles/security_analyzer/vars/main.yml
custom_security_checks:
  - name: "Check for specific labels"
    condition: "item.metadata.labels.security == 'high'"
    severity: "warning"
    
  - name: "Check for specific annotations"
    condition: "item.metadata.annotations.owner == 'security-team'"
    severity: "info"
```

### 2. Personalizar Relatórios

```jinja2
<!-- roles/report_generator/templates/custom_report.j2 -->
# Relatório Personalizado

## Resumo Executivo
Cluster: {{ cluster_url }}
Data: {{ ansible_date_time.iso8601 }}

## Métricas Principais
- Score de Segurança: {{ security_score }}/100
- Score de Arquitetura: {{ architecture_score }}/100
- Score de Recursos: {{ resource_score }}/100

## Recomendações Prioritárias
{% for recommendation in priority_recommendations %}
- {{ recommendation }}
{% endfor %}
```

### 3. Integrar com Ferramentas Externas

```yaml
# roles/report_generator/tasks/send_to_external_systems.yml
- name: Send report to external monitoring system
  uri:
    url: "{{ monitoring_system_url }}"
    method: POST
    body_format: json
    body:
      cluster: "{{ cluster_url }}"
      timestamp: "{{ ansible_date_time.iso8601 }}"
      security_score: "{{ security_score }}"
      report_data: "{{ report_data | to_json }}"
    headers:
      Authorization: "Bearer {{ monitoring_system_token }}"
```

Estes exemplos demonstram a flexibilidade e poder da ferramenta OpenShift Health Check implementada em Ansible.
