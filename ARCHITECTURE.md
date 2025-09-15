# Arquitetura da Avaliação de Saúde do OpenShift

Este documento descreve a arquitetura e design da ferramenta de Avaliação de Saúde do OpenShift, implementada em Ansible com playbooks e roles modulares, otimizada para execução em RHCOS (Red Hat CoreOS).

## Visão Geral da Arquitetura

A ferramenta de Avaliação de Saúde do OpenShift é construída com uma arquitetura modular baseada em Ansible que permite análise abrangente de clusters OpenShift 4.17. A ferramenta segue princípios de design limpo, separação de responsabilidades, extensibilidade e **execução somente leitura** (não-invasiva).

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Ansible       │    │   Roles         │    │   Relatórios    │
│   Playbook      │───▶│   de Análise    │───▶│   Gerados       │
│   Principal     │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   OpenShift     │    │   Data          │    │   HTML/JSON/    │
│   Cluster       │    │   Collector     │    │   Markdown      │
│   (Somente      │    │   Architecture  │    │   Reports       │
│    Leitura)     │    │   Security      │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Arquitetura Ansible

```
┌─────────────────────────────────────────────────────────────────┐
│                    Ansible Playbook Principal                   │
│              (openshift_health_check.yml)                      │
└─────────────────────────┬───────────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
        ▼                 ▼                 ▼
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│   Data      │  │Architecture │  │  Security   │
│  Collector  │  │  Analyzer   │  │  Analyzer   │
│    Role     │  │    Role     │  │    Role     │
└─────────────┘  └─────────────┘  └─────────────┘
        │                 │                 │
        ▼                 ▼                 ▼
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│ Best        │  │  Resource   │  │   Report    │
│ Practices   │  │ Optimizer   │  │ Generator   │
│ Analyzer    │  │    Role     │  │    Role     │
└─────────────┘  └─────────────┘  └─────────────┘
```

## Componentes Principais

### 1. Ansible Playbook Principal (`playbooks/openshift_health_check.yml`)

Orquestra toda a execução da avaliação de saúde do OpenShift.

**Responsabilidades:**
- Coordenar a execução de todos os roles
- Validar variáveis obrigatórias
- Gerenciar o fluxo de execução
- Consolidar resultados finais

**Características:**
- Execução em modo somente leitura
- Suporte a tags para execução seletiva
- Validação de conectividade
- Geração de relatórios consolidados

### 2. Data Collector Role (`roles/data_collector/`)

Responsável por coletar dados do cluster OpenShift usando Ansible.

**Responsabilidades:**
- Conectar ao cluster OpenShift
- Coletar informações de recursos
- Executar comandos `oc` e `kubectl`
- Estruturar dados para análise
- Validar conectividade

**Principais Tasks:**
- `validate_connection.yml`: Validação de conectividade
- `collect_cluster_info.yml`: Coleta de informações do cluster
- `collect_nodes.yml`: Coleta de dados de nós
- `collect_namespaces.yml`: Coleta de namespaces
- `collect_pods.yml`: Coleta de pods
- `collect_services.yml`: Coleta de serviços
- `collect_deployments.yml`: Coleta de deployments
- `collect_rbac.yml`: Coleta de configurações RBAC
- `collect_security_configs.yml`: Coleta de configurações de segurança
- `collect_operators.yml`: Coleta de operadores
- `collect_metrics.yml`: Coleta de métricas
- `collect_events.yml`: Coleta de eventos
- `consolidate_data.yml`: Consolidação de dados

**Dados Coletados:**
- Informações do cluster (versão, nós, namespaces)
- Recursos (pods, serviços, deployments)
- Configurações de segurança (RBAC, SCCs, NetworkPolicies)
- Operadores e configurações
- Métricas de performance
- Eventos e logs

### 3. Analysis Engine (Roles de Análise)

Roles especializados para análise de diferentes aspectos do cluster.

#### 3.1 Architecture Analyzer Role (`roles/architecture_analyzer/`)

**Responsabilidades:**
- Analisar infraestrutura do cluster
- Avaliar configuração de nós
- Verificar alta disponibilidade
- Analisar escalabilidade

**Principais Tasks:**
- `analyze_cluster_overview.yml`: Análise da visão geral do cluster
- `analyze_node_architecture.yml`: Análise da arquitetura de nós
- `analyze_network_architecture.yml`: Análise da arquitetura de rede
- `analyze_storage_architecture.yml`: Análise da arquitetura de storage
- `analyze_operator_health.yml`: Análise da saúde dos operadores
- `analyze_resource_distribution.yml`: Análise da distribuição de recursos
- `consolidate_analysis.yml`: Consolidação da análise

**Métricas Analisadas:**
- Visão geral do cluster
- Análise de nós e recursos
- Configuração de rede e storage
- Saúde dos operadores
- Distribuição de recursos

#### 3.2 Security Analyzer Role (`roles/security_analyzer/`)

**Responsabilidades:**
- Analisar configurações de segurança
- Verificar conformidade com padrões
- Identificar vulnerabilidades
- Avaliar RBAC e permissões

**Principais Tasks:**
- `analyze_rbac.yml`: Análise de RBAC e permissões
- `analyze_network_security.yml`: Análise de segurança de rede
- `analyze_pod_security.yml`: Análise de segurança de pods
- `analyze_secrets_management.yml`: Análise de gerenciamento de secrets
- `analyze_compliance.yml`: Análise de conformidade
- `consolidate_analysis.yml`: Consolidação da análise de segurança

**Verificações de Segurança:**
- RBAC e permissões
- Segurança de rede
- Segurança de pods
- Gerenciamento de secrets
- Conformidade (CIS, NIST, PSS)

#### 3.3 Best Practices Analyzer Role (`roles/best_practices_analyzer/`)

**Responsabilidades:**
- Verificar conformidade com boas práticas
- Avaliar padrões de nomenclatura
- Analisar configurações operacionais
- Verificar documentação

**Principais Tasks:**
- `analyze_naming_conventions.yml`: Análise de convenções de nomenclatura
- `analyze_resource_management.yml`: Análise de gerenciamento de recursos
- `analyze_deployment_practices.yml`: Análise de práticas de deployment
- `analyze_monitoring.yml`: Análise de monitoramento e observabilidade
- `analyze_backup_recovery.yml`: Análise de backup e disaster recovery
- `consolidate_analysis.yml`: Consolidação da análise

**Áreas de Análise:**
- Convenções de nomenclatura
- Gerenciamento de recursos
- Práticas de deployment
- Monitoramento e observabilidade
- Backup e disaster recovery

#### 3.4 Resource Optimizer Role (`roles/resource_optimizer/`)

**Responsabilidades:**
- Analisar uso de recursos
- Identificar oportunidades de otimização
- Calcular eficiência
- Sugerir melhorias de custo

**Principais Tasks:**
- `analyze_cpu_usage.yml`: Análise de uso de CPU
- `analyze_memory_usage.yml`: Análise de uso de memória
- `analyze_requests_limits.yml`: Análise de requests e limits
- `analyze_quotas.yml`: Análise de quotas e limites
- `analyze_waste.yml`: Análise de desperdício
- `analyze_scaling.yml`: Análise de oportunidades de scaling
- `consolidate_analysis.yml`: Consolidação da análise

**Análises de Recursos:**
- Uso de CPU e memória
- Requests e limits
- Quotas e limites
- Análise de desperdício
- Oportunidades de scaling

### 4. Report Generator Role (`roles/report_generator/`)

**Responsabilidades:**
- Consolidar resultados de análise
- Gerar relatórios em múltiplos formatos
- Criar resumos executivos
- Produzir recomendações

**Principais Tasks:**
- `consolidate_results.yml`: Consolidação de resultados
- `generate_html_report.yml`: Geração de relatório HTML
- `generate_json_report.yml`: Geração de relatório JSON
- `generate_markdown_report.yml`: Geração de relatório Markdown
- `generate_executive_summary.yml`: Geração de resumo executivo

**Formatos Suportados:**
- HTML (interativo com gráficos)
- JSON (para integração)
- Markdown (para documentação)
- Resumo executivo consolidado

## Fluxo de Dados

### 1. Coleta de Dados (Ansible)

```
OpenShift Cluster → Data Collector Role → JSON Data Files
```

1. **Conectividade**: Estabelece conexão com o cluster via Ansible
2. **Coleta**: Executa comandos `oc` e `kubectl` via Ansible
3. **Estruturação**: Organiza dados em arquivos JSON
4. **Validação**: Verifica integridade dos dados coletados
5. **Armazenamento**: Salva dados em diretório estruturado

### 2. Análise (Roles de Análise)

```
JSON Data Files → Analysis Roles → Analysis Results
```

1. **Processamento**: Cada role processa dados relevantes
2. **Análise**: Aplica regras e verificações específicas
3. **Scoring**: Calcula scores e métricas
4. **Recomendações**: Gera recomendações baseadas em análise
5. **Consolidação**: Consolida resultados por categoria

### 3. Geração de Relatório (Templates Jinja2)

```
Analysis Results → Report Generator Role → Final Reports
```

1. **Consolidação**: Combina resultados de todos os roles
2. **Resumo Executivo**: Cria visão geral dos resultados
3. **Formatação**: Aplica templates Jinja2
4. **Saída**: Gera relatórios em múltiplos formatos
5. **Estruturação**: Organiza relatórios em diretório final

## Decisões de Design

### 1. Arquitetura Ansible

**Decisão**: Implementação baseada em Ansible com playbooks e roles.

**Justificativa**:
- Facilita automação e escalabilidade
- Permite execução em múltiplos clusters
- Suporte nativo a RHCOS (Red Hat CoreOS)
- Integração com ferramentas de automação existentes
- Execução somente leitura (não-invasiva)

### 2. Modularidade

**Decisão**: Arquitetura modular com roles Ansible independentes.

**Justificativa**:
- Facilita manutenção e extensão
- Permite execução independente de roles
- Melhora testabilidade
- Reduz acoplamento entre componentes
- Suporte a tags para execução seletiva

### 3. Extensibilidade

**Decisão**: Interface comum para todos os roles de análise.

**Justificativa**:
- Permite adição de novos tipos de análise
- Facilita integração de ferramentas externas
- Suporta diferentes versões do OpenShift
- Permite customização por cliente
- Reutilização de roles em diferentes contextos

### 4. Configurabilidade

**Decisão**: Sistema de configuração flexível via variáveis Ansible e arquivos de configuração.

**Justificativa**:
- Suporta diferentes ambientes (produção, homologação, desenvolvimento)
- Permite customização sem modificação de código
- Facilita automação e integração
- Melhora usabilidade
- Configuração via group_vars e host_vars

### 5. Segurança e Não-Invasividade

**Decisão**: Execução somente leitura com zero operações de escrita.

**Justificativa**:
- Garante que o cluster permanece inalterado
- Permite execução em ambientes de produção
- Reduz riscos de impacto operacional
- Facilita aprovação em ambientes críticos
- Auditoria completa de todas as operações

### 6. Tolerância a Falhas

**Decisão**: Tratamento robusto de erros e fallbacks em Ansible.

**Justificativa**:
- Garante execução mesmo com problemas parciais
- Fornece informações úteis mesmo com falhas
- Melhora experiência do usuário
- Facilita debugging
- Suporte a execução com falhas parciais

## Estrutura de Dados

### 1. Dados Coletados (JSON)

```json
{
  "cluster_info": {...},
  "nodes": {...},
  "namespaces": {...},
  "pods": {...},
  "services": {...},
  "deployments": {...},
  "rbac": {...},
  "security_configs": {...},
  "operators": {...},
  "metrics": {...},
  "events": {...}
}
```

### 2. Resultados de Análise (JSON)

```json
{
  "architecture_analysis": {
    "cluster_overview": {...},
    "node_analysis": {...},
    "network_analysis": {...},
    "storage_analysis": {...},
    "operator_analysis": {...},
    "resource_distribution": {...}
  },
  "security_analysis": {
    "rbac_analysis": {...},
    "network_security": {...},
    "pod_security": {...},
    "secrets_management": {...},
    "compliance_analysis": {...}
  },
  "best_practices_analysis": {
    "naming_conventions": {...},
    "resource_management": {...},
    "deployment_practices": {...},
    "monitoring": {...},
    "backup_recovery": {...}
  },
  "resource_analysis": {
    "cpu_usage": {...},
    "memory_usage": {...},
    "requests_limits": {...},
    "quotas": {...},
    "waste_analysis": {...},
    "scaling_opportunities": {...}
  }
}
```

### 3. Dados de Relatório (Templates Jinja2)

```json
{
  "metadata": {
    "cluster_url": "...",
    "analysis_timestamp": "...",
    "ansible_version": "...",
    "collection_host": "..."
  },
  "executive_summary": {...},
  "analysis_results": {...},
  "recommendations": [...],
  "risk_assessment": {...},
  "compliance_summary": {...},
  "overall_scores": {
    "architecture_score": 85,
    "security_score": 92,
    "best_practices_score": 78,
    "resource_score": 88
  }
}
```

## Padrões de Código Ansible

### 1. Nomenclatura

- **Roles**: snake_case (ex: `data_collector`, `architecture_analyzer`)
- **Tasks**: snake_case (ex: `collect_cluster_info.yml`)
- **Variáveis**: snake_case (ex: `cluster_data`, `openshift_token`)
- **Constantes**: UPPER_CASE (ex: `DEFAULT_TIMEOUT`)
- **Tags**: snake_case (ex: `coleta_dados`, `arquitetura`)

### 2. Estrutura de Tasks

```yaml
- name: Descrição clara da task
  block:
    - name: Operação principal
      command: "{{ cli_command }} get nodes -o json"
      register: nodes_result
      environment:
        KUBECONFIG: "{{ openshift_kubeconfig }}"
        
    - name: Processar resultado
      set_fact:
        nodes_data: "{{ nodes_result.stdout | from_json }}"
        
  rescue:
    - name: Tratar erro
      debug:
        msg: "Erro na coleta de dados: {{ ansible_failed_result.msg }}"
```

### 3. Tratamento de Erros

```yaml
- name: Operação com tratamento de erro
  block:
    - name: Operação que pode falhar
      command: "{{ cli_command }} get pods --all-namespaces"
      register: pods_result
      failed_when: false
      
    - name: Verificar resultado
      fail:
        msg: "Falha na coleta de pods"
      when: pods_result.rc != 0
      
  rescue:
    - name: Tratar falha
      debug:
        msg: "Coleta de pods falhou, continuando com dados parciais"
      set_fact:
        pods_data: "{}"
```

## Considerações de Performance

### 1. Coleta de Dados (Ansible)

- **Execução Sequencial**: Coleta de dados em sequência para evitar sobrecarga
- **Timeouts Configuráveis**: Timeouts apropriados para evitar travamentos
- **Filtros**: Filtros para reduzir quantidade de dados coletados
- **Rate Limiting**: Controle de taxa de execução de comandos
- **Validação de Conectividade**: Verificação prévia de conectividade

### 2. Análise (Roles)

- **Processamento Local**: Análise realizada localmente no nó de execução
- **Dados JSON**: Processamento eficiente de dados em formato JSON
- **Filtros de Dados**: Filtros para reduzir volume de dados processados
- **Memória**: Gerenciamento cuidadoso de uso de memória
- **Paralelização**: Execução paralela de roles independentes

### 3. Relatórios (Templates Jinja2)

- **Templates Eficientes**: Templates Jinja2 otimizados
- **Geração Incremental**: Geração incremental de relatórios
- **Compressão**: Compressão de dados quando apropriado
- **Cache**: Cache de relatórios para evitar regeneração
- **Formato Múltiplo**: Geração simultânea de múltiplos formatos

## Segurança

### 1. Operações Somente Leitura

- **Zero Escrita**: Nenhuma operação de escrita no cluster
- **Comandos Seguros**: Apenas comandos `oc get`, `oc describe`, `oc cluster-info`
- **Estado Inalterado**: Cluster permanece inalterado após execução
- **Auditoria**: Log completo de todas as operações realizadas

### 2. Autenticação

- **Tokens**: Uso de tokens de autenticação seguros
- **Rotação**: Suporte a rotação de tokens
- **Validação**: Validação de credenciais
- **Auditoria**: Log de operações de autenticação
- **Permissões Mínimas**: Apenas permissões de leitura

### 3. Autorização

- **Permissões**: Verificação de permissões necessárias (apenas leitura)
- **Princípio do Menor Privilégio**: Uso mínimo de permissões
- **Auditoria**: Log de operações de autorização
- **Isolamento**: Isolamento de dados sensíveis
- **Cluster-Reader**: Permissões mínimas de cluster-reader

### 4. Dados Sensíveis

- **Criptografia**: Criptografia de dados sensíveis
- **Mascaramento**: Mascaramento de informações sensíveis
- **Retenção**: Políticas de retenção de dados
- **Limpeza**: Limpeza segura de dados temporários
- **Não Persistência**: Dados não são persistidos no cluster

## Extensibilidade

### 1. Novos Roles de Análise

```yaml
# roles/custom_analyzer/tasks/main.yml
---
- name: Análise customizada
  block:
    - name: Coletar dados específicos
      command: "{{ cli_command }} get custom-resource -o json"
      register: custom_data
      
    - name: Processar dados
      set_fact:
        custom_analysis:
          metrics: "{{ custom_data.stdout | from_json }}"
          recommendations: [...]
          
    - name: Salvar resultados
      copy:
        content: "{{ custom_analysis | to_nice_json }}"
        dest: "{{ output_dir }}/custom_analysis.json"
```

### 2. Novos Formatos de Relatório

```yaml
# roles/report_generator/tasks/generate_custom_report.yml
---
- name: Gerar relatório customizado
  template:
    src: custom_report.j2
    dest: "{{ output_dir }}/custom_report.{{ format }}"
    
- name: Processar dados para relatório
  set_fact:
    custom_report_data:
      analysis_results: "{{ analysis_results }}"
      custom_metrics: "{{ custom_metrics }}"
```

### 3. Novos Tipos de Coleta de Dados

```yaml
# roles/data_collector/tasks/collect_custom_data.yml
---
- name: Coletar dados customizados
  block:
    - name: Executar comando customizado
      command: "{{ cli_command }} get custom-resource --all-namespaces -o json"
      register: custom_result
      
    - name: Salvar dados customizados
      copy:
        content: "{{ custom_result.stdout }}"
        dest: "{{ data_output_dir }}/custom_data.json"
```

## Monitoramento e Observabilidade

### 1. Logging (Ansible)

- **Níveis**: DEBUG, INFO, WARNING, ERROR, CRITICAL
- **Estrutura**: Logs estruturados em JSON
- **Rotação**: Rotação automática de logs
- **Agregação**: Agregação de logs para análise
- **Auditoria**: Log completo de todas as operações

### 2. Métricas

- **Performance**: Métricas de performance da execução Ansible
- **Uso**: Métricas de uso de recursos do nó de execução
- **Erros**: Métricas de erros e falhas
- **Tempo**: Métricas de tempo de execução por role
- **Cobertura**: Métricas de cobertura de dados coletados

### 3. Alertas

- **Falhas**: Alertas para falhas críticas na execução
- **Performance**: Alertas para problemas de performance
- **Segurança**: Alertas para problemas de segurança detectados
- **Conformidade**: Alertas para problemas de conformidade
- **Conectividade**: Alertas para problemas de conectividade

## Considerações Futuras

### 1. Escalabilidade (Ansible)

- **Execução Distribuída**: Suporte a execução em múltiplos nós
- **Clustering**: Suporte a múltiplos clusters simultâneos
- **Load Balancing**: Balanceamento de carga entre nós
- **Auto-scaling**: Escalonamento automático de nós de execução
- **Inventário Dinâmico**: Inventário dinâmico baseado em descoberta

### 2. Integração

- **APIs REST**: APIs REST para integração com ferramentas externas
- **Webhooks**: Suporte a webhooks para notificações
- **SDKs**: SDKs para diferentes linguagens
- **Plugins Ansible**: Sistema de plugins para Ansible
- **Integração CI/CD**: Integração com pipelines de CI/CD

### 3. Inteligência Artificial

- **ML**: Machine learning para análise de padrões
- **Predição**: Predição de problemas baseada em histórico
- **Otimização**: Otimização automática de configurações
- **Recomendações**: Recomendações inteligentes baseadas em ML
- **Análise Preditiva**: Análise preditiva de tendências

### 4. Automação Avançada

- **Agendamento**: Agendamento automático de execuções
- **Integração com ITSM**: Integração com ferramentas de ITSM
- **Dashboard**: Dashboard em tempo real
- **Relatórios Automáticos**: Geração automática de relatórios
- **Integração com SIEM**: Integração com ferramentas de SIEM

## Estrutura do Projeto

### Organização de Arquivos

```
openshift_health_check/
├── ansible/
│   ├── playbooks/
│   │   └── openshift_health_check.yml    # Playbook principal
│   ├── roles/
│   │   ├── data_collector/               # Role de coleta de dados
│   │   ├── architecture_analyzer/        # Role de análise de arquitetura
│   │   ├── security_analyzer/            # Role de análise de segurança
│   │   ├── best_practices_analyzer/      # Role de análise de boas práticas
│   │   ├── resource_optimizer/           # Role de otimização de recursos
│   │   └── report_generator/             # Role de geração de relatórios
│   ├── inventory/
│   │   └── hosts.yml                     # Inventário de hosts
│   ├── group_vars/
│   │   └── all.yml                       # Variáveis globais
│   ├── configs/
│   │   └── ansible.cfg                   # Configuração do Ansible
│   ├── examples/
│   │   ├── example_config.yml            # Configuração de exemplo
│   │   └── example_usage.md              # Exemplos de uso
│   └── run_health_check.sh               # Script de execução
├── reports/                              # Diretório de relatórios gerados
├── README.md                             # Documentação principal
├── ARCHITECTURE.md                       # Este documento
└── ANALISE_IMPACTO.md                    # Análise de impacto
```

### Estrutura de Roles

Cada role segue a estrutura padrão do Ansible:

```
roles/role_name/
├── tasks/
│   ├── main.yml                          # Tasks principais
│   ├── task1.yml                         # Tasks específicas
│   └── task2.yml
├── templates/
│   └── template.j2                       # Templates Jinja2
├── vars/
│   └── main.yml                          # Variáveis do role
├── defaults/
│   └── main.yml                          # Valores padrão
├── meta/
│   └── main.yml                          # Metadados do role
└── files/                                # Arquivos estáticos
```

### Fluxo de Execução

1. **Inicialização**: Validação de variáveis e conectividade
2. **Coleta de Dados**: Execução do role `data_collector`
3. **Análise**: Execução dos roles de análise em paralelo
4. **Geração de Relatórios**: Execução do role `report_generator`
5. **Consolidação**: Consolidação final de resultados

### Configuração e Customização

- **Variáveis**: Configuração via `group_vars/all.yml`
- **Inventário**: Configuração de hosts via `inventory/hosts.yml`
- **Tags**: Execução seletiva via tags Ansible
- **Templates**: Customização de relatórios via templates Jinja2
- **Filtros**: Filtros de dados via variáveis de configuração
