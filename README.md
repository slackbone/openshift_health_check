# Avaliação de Saúde do OpenShift - Versão Ansible

Uma ferramenta de avaliação abrangente para clusters OpenShift 4.17, implementada em Ansible com playbooks e roles modulares, otimizada para execução em RHCOS (Red Hat CoreOS).

## Visão Geral

Esta ferramenta foi desenvolvida para fornecer uma análise completa da saúde, segurança e conformidade de clusters OpenShift. A versão Ansible oferece as mesmas funcionalidades da versão Python original, mas com a flexibilidade e escalabilidade do Ansible, especificamente otimizada para o ambiente RHCOS.

## Arquitetura

A ferramenta segue uma arquitetura modular com os seguintes componentes:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Data          │    │   Analysis      │    │   Report        │
│   Collection    │───▶│   Engine        │───▶│   Generation    │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   OpenShift     │    │   Security      │    │   HTML/PDF/     │
│   Cluster       │    │   Architecture  │    │   JSON/MD       │
│                 │    │   Best Practices│    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Componentes Principais

### 1. Data Collector Role
- **Responsabilidades**: Coleta dados do cluster OpenShift
- **Dados Coletados**: Informações do cluster, nós, namespaces, pods, serviços, deployments, RBAC, configurações de segurança, operadores, métricas e eventos

### 2. Architecture Analyzer Role
- **Responsabilidades**: Analisa infraestrutura do cluster
- **Análises**: Visão geral do cluster, análise de nós, configuração de rede e storage, saúde dos operadores, distribuição de recursos

### 3. Security Analyzer Role
- **Responsabilidades**: Analisa configurações de segurança
- **Verificações**: RBAC e permissões, segurança de rede, segurança de pods, gerenciamento de secrets, conformidade (CIS, NIST, PSS)

### 4. Best Practices Analyzer Role
- **Responsabilidades**: Verifica conformidade com boas práticas
- **Áreas**: Convenções de nomenclatura, gerenciamento de recursos, práticas de deployment, monitoramento e observabilidade

### 5. Resource Optimizer Role
- **Responsabilidades**: Analisa uso de recursos
- **Análises**: Uso de CPU e memória, requests e limits, quotas e limites, análise de desperdício, oportunidades de scaling

### 6. Report Generator Role
- **Responsabilidades**: Gera relatórios em múltiplos formatos
- **Formatos**: HTML (interativo), PDF, JSON, Markdown

## Pré-requisitos

### Software Necessário
- **Ansible**: Versão 2.9 ou superior
- **OpenShift CLI (oc)** ou **Kubernetes CLI (kubectl)**
- **Python**: Versão 3.6 ou superior (RHCOS)
- **Git**: Para clonar o repositório
- **RHCOS**: Red Hat CoreOS (sistema operacional padrão do OpenShift)

### Permissões Necessárias
- Acesso de leitura ao cluster OpenShift
- Token de autenticação válido
- Permissões para listar recursos do cluster
- Usuário com permissões de cluster-reader ou superior

## Instalação

### 1. Clone o Repositório
```bash
git clone <repository-url>
cd openshift_health_check
```

### 2. Instale as Dependências
```bash
# Instalar Ansible (RHCOS/RHEL)
sudo dnf install ansible

# Instalar OpenShift CLI
# Baixe de: https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/
wget https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz
tar -xzf oc.tar.gz
sudo mv oc /usr/local/bin/

# Verificar instalação
oc version
ansible --version
```

### 3. Configure o Ambiente
```bash
# Copie o arquivo de configuração
cp ansible/configs/ansible.cfg ~/.ansible.cfg

# Crie o diretório de logs
mkdir -p ansible/logs
```

## Uso

### Método 0: Simulação com Dados Randômicos (Para Teste)

Antes de executar em um cluster real, você pode testar a ferramenta com dados simulados:

```bash
# Executar simulação completa
python3 simulate_execution.py

# Visualizar relatórios gerados
./view_reports.sh -a

# Listar execuções disponíveis
./view_reports.sh -l

# Abrir apenas relatório consolidado
./view_reports.sh -c
```

A simulação gera:
- **6 relatórios HTML** com dados randômicos realistas
- **Estrutura completa** de diretórios organizados
- **Dados JSON** simulados para todas as categorias
- **Relatórios Markdown** para análise técnica

**Vantagens da Simulação:**
- ✅ Testa a estrutura dos relatórios sem cluster real
- ✅ Valida o design e layout dos templates HTML
- ✅ Demonstra as funcionalidades da ferramenta
- ✅ Permite análise dos relatórios antes da execução real

Para mais detalhes, consulte: **[Guia de Simulação](SIMULACAO.md)**

### Método 1: Script de Execução (Recomendado)

```bash
# Execução completa
./ansible/run_health_check.sh \
  -u https://api.cluster.example.com:6443 \
  -t sha256~seu-token-aqui

# Execução com tags específicas
./ansible/run_health_check.sh \
  -u https://api.cluster.example.com:6443 \
  -t sha256~seu-token-aqui \
  --tags seguranca

# Modo de verificação (dry run)
./ansible/run_health_check.sh \
  -u https://api.cluster.example.com:6443 \
  -t sha256~seu-token-aqui \
  --check
```

### Método 2: Execução Direta com Ansible

```bash
cd ansible

# Execução completa
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  -e cluster_url="https://api.cluster.example.com:6443" \
  -e cluster_token="sha256~your-token-here" \
  -e cluster_name="production-cluster"

# Execução com tags específicas
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  -e cluster_url="https://api.cluster.example.com:6443" \
  -e cluster_token="sha256~your-token-here" \
  -e cluster_name="production-cluster" \
  --tags "security,architecture"
```

### Método 3: Execução em Múltiplos Clusters

```bash
# Executar em todos os clusters configurados
./examples/run_health_check_multiple_clusters.sh

# Executar em cluster específico
./examples/run_health_check_multiple_clusters.sh -c production-cluster

# Executar em modo dry-run
./examples/run_health_check_multiple_clusters.sh -d

# Listar clusters disponíveis
./examples/run_health_check_multiple_clusters.sh -l
```

### Tags Disponíveis

- `coleta_dados`: Coleta de dados do cluster
- `arquitetura`: Análise de arquitetura
- `seguranca`: Análise de segurança
- `boas_praticas`: Análise de boas práticas
- `recursos`: Análise de recursos
- `relatorios`: Geração de relatórios
- `todos`: Executa todas as análises (padrão)

## Configuração

### Variáveis de Ambiente

As seguintes variáveis podem ser configuradas:

```yaml
# Conexão com o cluster
openshift_cluster_url: "https://api.cluster.example.com:6443"
openshift_token: "sha256~your-token-here"
openshift_kubeconfig: "~/.kube/config"

# Configurações de coleta de dados
collect_cluster_info: true
collect_nodes: true
collect_namespaces: true
# ... outras configurações

# Configurações de análise
analyze_cluster_overview: true
analyze_node_architecture: true
# ... outras configurações

# Limites de segurança
max_privileged_containers: 0
max_root_containers: 0
max_host_network_pods: 0
```

### Arquivo de Inventário

Configure o arquivo `ansible/inventory/hosts.yml` para execução remota:

```yaml
all:
  children:
    openshift_clusters:
      hosts:
        cluster1:
          ansible_host: bastion.example.com
          ansible_user: admin
          openshift_cluster_url: "https://api.cluster1.example.com:6443"
          openshift_token: "your-token-here"
```

## Estrutura de Saída

Os relatórios são organizados por execução e tipo no diretório `reports/` com a seguinte estrutura:

```
reports/
├── {cluster_name}_{timestamp}/
│   ├── data_collection/
│   │   ├── cluster_info.json
│   │   ├── nodes.json
│   │   ├── namespaces.json
│   │   ├── pods.json
│   │   ├── services.json
│   │   ├── deployments.json
│   │   ├── rbac.json
│   │   ├── security_configs.json
│   │   ├── operators.json
│   │   ├── metrics.json
│   │   ├── events.json
│   │   ├── collection_summary.json
│   │   └── data_collection_report.md
│   ├── architecture_analysis/
│   │   ├── architecture_analysis.json
│   │   └── architecture_analysis_report.md
│   ├── security_analysis/
│   │   ├── security_analysis.json
│   │   └── security_analysis_report.md
│   ├── best_practices_analysis/
│   │   ├── best_practices_analysis.json
│   │   └── best_practices_analysis_report.md
│   ├── resource_optimization/
│   │   ├── resource_optimization.json
│   │   └── resource_optimization_report.md
│   ├── consolidated/
│   │   └── consolidated_health_check_report.md
│   └── html/
│       ├── data_collection/
│       │   └── data_collection_report.html
│       ├── architecture_analysis/
│       │   └── architecture_analysis_report.html
│       ├── security_analysis/
│       │   └── security_analysis_report.html
│       ├── best_practices_analysis/
│       │   └── best_practices_analysis_report.html
│       ├── resource_optimization/
│       │   └── resource_optimization_report.html
│       └── consolidated/
│           └── consolidated_health_check_report.html
└── README.md
```

### Exemplo de Estrutura Real

```
reports/
├── production-cluster_20241215_143022/
├── staging-cluster_20241215_144530/
├── development-cluster_20241215_150145/
└── README.md
```

## Exemplos de Uso

### 1. Análise Completa
```bash
# Usando script de execução
./ansible/run_health_check.sh \
  -u https://api.cluster.example.com:6443 \
  -t sha256~your-token-here

# Usando Ansible diretamente
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  -e cluster_url="https://api.cluster.example.com:6443" \
  -e cluster_token="sha256~your-token-here" \
  -e cluster_name="production-cluster"
```

### 2. Análise de Segurança Apenas
```bash
# Usando script de execução
./ansible/run_health_check.sh \
  -u https://api.cluster.example.com:6443 \
  -t sha256~your-token-here \
  --tags security

# Usando Ansible diretamente
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  -e cluster_url="https://api.cluster.example.com:6443" \
  -e cluster_token="sha256~your-token-here" \
  -e cluster_name="production-cluster" \
  --tags "seguranca"
```

### 3. Análise de Arquitetura e Recursos
```bash
# Usando script de execução
./ansible/run_health_check.sh \
  -u https://api.cluster.example.com:6443 \
  -t sha256~your-token-here \
  --tags "architecture,resources"

# Usando Ansible diretamente
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  -e cluster_url="https://api.cluster.example.com:6443" \
  -e cluster_token="sha256~your-token-here" \
  -e cluster_name="production-cluster" \
  --tags "arquitetura,recursos"
```

### 4. Modo de Verificação
```bash
# Usando script de execução
./ansible/run_health_check.sh \
  -u https://api.cluster.example.com:6443 \
  -t sha256~your-token-here \
  --check

# Usando Ansible diretamente
ansible-playbook -i inventory/hosts.yml playbooks/openshift_health_check.yml \
  -e cluster_url="https://api.cluster.example.com:6443" \
  -e cluster_token="sha256~your-token-here" \
  -e cluster_name="production-cluster" \
  --check
```

### 5. Execução em Múltiplos Clusters
```bash
# Executar em todos os clusters configurados
./examples/run_health_check_multiple_clusters.sh

# Executar em cluster específico
./examples/run_health_check_multiple_clusters.sh -c production-cluster

# Executar em modo dry-run
./examples/run_health_check_multiple_clusters.sh -d

# Executar com verbose
./examples/run_health_check_multiple_clusters.sh -c production-cluster -v
```

## Solução de Problemas

### Problemas Comuns

1. **Erro de Conexão**
   ```
   ERRO: Não é possível conectar ao cluster OpenShift
   ```
   - Verifique se a URL do cluster está correta
   - Confirme se o token é válido
   - Teste a conectividade: `oc cluster-info`

2. **Permissões Insuficientes**
   ```
   ERRO: Forbidden (403)
   ```
   - Verifique se o token tem as permissões necessárias
   - Confirme se o usuário pode listar recursos
   - Verifique se o usuário tem permissões de cluster-reader

3. **Comando não encontrado**
   ```
   ERRO: Nem o comando 'oc' nem 'kubectl' está disponível
   ```
   - Instale o OpenShift CLI ou Kubernetes CLI
   - Verifique se está no PATH
   - No RHCOS, use: `sudo dnf install openshift-clients`

### Logs

Os logs são salvos em:
- `ansible/logs/ansible.log`: Logs do Ansible
- `reports/{cluster_name}_{timestamp}/data_collection/`: Dados coletados
- `reports/{cluster_name}_{timestamp}/data_collection/collection_summary.json`: Resumo da coleta

### Navegação pelos Relatórios

```bash
# Encontrar a execução mais recente
ls -t reports/ | head -1

# Acessar relatório consolidado HTML (recomendado para executivos)
open reports/{cluster_name}_{timestamp}/html/consolidated/consolidated_health_check_report.html

# Acessar relatório consolidado Markdown (recomendado para técnicos)
cat reports/{cluster_name}_{timestamp}/consolidated/consolidated_health_check_report.md

# Comparar execuções
diff reports/production-cluster_20241215_143022/consolidated/consolidated_health_check_report.md \
      reports/production-cluster_20241214_143022/consolidated/consolidated_health_check_report.md
```

## Contribuição

### Desenvolvimento

1. Fork o repositório
2. Crie uma branch para sua feature
3. Faça commit das mudanças
4. Abra um Pull Request

### Estrutura do Projeto

```
ansible/
├── playbooks/           # Playbooks principais
├── roles/              # Roles do Ansible
│   ├── data_collector/
│   ├── architecture_analyzer/
│   ├── security_analyzer/
│   ├── best_practices_analyzer/
│   ├── resource_optimizer/
│   └── report_generator/
├── inventory/          # Arquivos de inventário
├── group_vars/         # Variáveis de grupo
├── configs/            # Arquivos de configuração
└── templates/          # Templates Jinja2
```

## Licença

Este projeto está licenciado sob a Licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## Suporte

Para suporte e dúvidas:
- Abra uma issue no repositório
- Consulte a documentação
- Entre em contato com a equipe de desenvolvimento

## Documentação Adicional

- **[Simulação](SIMULACAO.md)**: Guia completo para executar simulações com dados randômicos
- **[Análise de Impacto](ANALISE_IMPACTO.md)**: Documento detalhado sobre o impacto da execução do playbook em ambientes de produção
- **[Arquitetura](ARCHITECTURE.md)**: Documentação técnica da arquitetura da ferramenta
- **[Exemplos de Uso](ansible/examples/)**: Exemplos práticos de configuração e uso
- **[Changelog](CHANGELOG.md)**: Histórico de mudanças e versões

## Changelog

### v1.2.0
- **Funcionalidade de Simulação com Dados Randômicos**
- Script `simulate_execution.py` para gerar dados fictícios
- Script `view_reports.sh` para visualização facilitada dos relatórios
- Geração de 6 relatórios HTML com dados realistas simulados
- Documentação completa de simulação em `SIMULACAO.md`
- Permite testar estrutura e design dos relatórios sem cluster real
- Validação de templates HTML antes da execução em produção

### v1.1.0
- **Nova estrutura de relatórios organizados por execução e tipo**
- Suporte a múltiplos clusters simultâneos
- Script para execução em múltiplos clusters
- Relatórios HTML e Markdown organizados separadamente
- Estrutura de diretórios por cluster e timestamp
- Facilita comparação entre execuções
- Limpeza automática de relatórios antigos
- Documentação atualizada com novos exemplos

### v1.0.0
- Implementação inicial em Ansible
- Suporte a OpenShift 4.17
- Otimização para RHCOS (Red Hat CoreOS)
- Análise de arquitetura, segurança e recursos
- Geração de relatórios em múltiplos formatos
- Script de execução automatizada
- Documentação completa em português brasileiro
- Análise de impacto para ambientes de produção
