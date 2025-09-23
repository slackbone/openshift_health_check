# Changelog - OpenShift Health Check

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [1.2.0] - 2024-09-23

### Adicionado
- **Funcionalidade de Simulação com Dados Randômicos**
  - Script `simulate_execution.py` para gerar dados fictícios realistas
  - Geração de 6 relatórios HTML com dados simulados
  - Estrutura completa de diretórios organizados por execução
  - Dados JSON simulados para todas as categorias de análise

- **Script de Visualização de Relatórios**
  - `view_reports.sh` para facilitar a visualização dos relatórios HTML
  - Suporte a listagem de execuções disponíveis
  - Abertura de relatórios específicos ou todos os relatórios
  - Interface amigável com cores e formatação

- **Documentação de Simulação**
  - `SIMULACAO.md` com guia completo de uso da simulação
  - Instruções detalhadas para execução e visualização
  - Explicação dos dados gerados e limitações
  - Exemplos práticos de uso

### Funcionalidades da Simulação
- **Dados Realistas Simulados**
  - Informações de cluster (nome, versão, plataforma, região)
  - Distribuição de recursos (nós, namespaces, pods, serviços)
  - Pontuações randômicas para todas as categorias
  - Análise de custos com economia potencial
  - Questões identificadas e recomendações

- **Relatórios HTML Completos**
  - Relatório consolidado executivo
  - Relatório de coleta de dados
  - Relatório de análise de arquitetura
  - Relatório de análise de segurança
  - Relatório de boas práticas
  - Relatório de otimização de recursos

### Melhorado
- **Experiência de Desenvolvimento**
  - Permite testar estrutura dos relatórios sem cluster real
  - Validação de templates HTML antes da execução em produção
  - Demonstração das funcionalidades da ferramenta
  - Facilita análise do design e layout dos relatórios

- **Documentação**
  - README principal atualizado com seção de simulação
  - Changelog atualizado com nova versão
  - Guia completo de simulação disponível

### Vantagens da Simulação
- ✅ Testa a estrutura dos relatórios sem cluster real
- ✅ Valida o design e layout dos templates HTML
- ✅ Demonstra as funcionalidades da ferramenta
- ✅ Permite análise dos relatórios antes da execução real
- ✅ Facilita desenvolvimento e testes de novos templates

## [1.1.0] - 2024-12-15

### Adicionado
- **Nova estrutura de relatórios organizados por execução e tipo**
  - Estrutura hierárquica: `{cluster_name}_{timestamp}/`
  - Organização por categoria: `data_collection/`, `architecture_analysis/`, `security_analysis/`, etc.
  - Separação de relatórios Markdown (técnicos) e HTML (executivos)
  - Suporte a múltiplos clusters simultâneos

- **Script para execução em múltiplos clusters**
  - `run_health_check_multiple_clusters.sh` com funcionalidades avançadas
  - Suporte a execução em cluster específico
  - Modo dry-run para validação
  - Modo verbose para debugging
  - Limpeza automática de relatórios antigos
  - Comparação entre execuções

- **Templates e configurações para múltiplos clusters**
  - `multiple_clusters_config.yml` - Configuração para múltiplos clusters
  - `multiple_clusters_inventory.yml` - Inventário para múltiplos clusters
  - `group_vars_all.yml` - Variáveis de grupo de exemplo

- **Relatório consolidado em Markdown**
  - Template `consolidated_health_check_report.j2`
  - Relatório executivo em formato Markdown
  - Estrutura organizada com seções detalhadas

- **Documentação atualizada**
  - README principal atualizado com nova estrutura
  - ARCHITECTURE.md com seção sobre nova estrutura
  - `example_usage_updated.md` com exemplos atualizados
  - README dos relatórios com guia de navegação

### Modificado
- **Playbook principal** (`openshift_health_check.yml`)
  - Adicionada variável `cluster_name` para identificação única
  - Criação automática de estrutura de diretórios organizada
  - Mensagem de conclusão atualizada com nova estrutura

- **Roles atualizados**
  - `data_collector`: Diretório de saída alterado para `data_collection/`
  - `report_generator`: Caminhos de saída atualizados para nova estrutura
  - `best_practices_analyzer`: Criado arquivo de defaults
  - `resource_optimizer`: Criado arquivo de defaults

- **Templates HTML**
  - Caminhos de saída atualizados para estrutura organizada
  - Relatórios HTML organizados por categoria

### Melhorado
- **Organização de relatórios**
  - Facilita comparação entre execuções
  - Melhora navegação e localização de relatórios
  - Suporte a limpeza automática de relatórios antigos
  - Estrutura preparada para backup seletivo

- **Suporte a múltiplos clusters**
  - Execução simultânea em vários clusters
  - Configuração flexível por cluster
  - Gestão de credenciais por cluster
  - Relatórios isolados por cluster

- **Experiência do usuário**
  - Mensagens de conclusão mais informativas
  - Estrutura de diretórios intuitiva
  - Documentação com exemplos práticos
  - Scripts de automação avançados

### Documentação
- README principal atualizado com nova estrutura
- ARCHITECTURE.md com seção sobre nova estrutura
- Exemplos de uso atualizados
- Guia de navegação pelos relatórios
- Scripts de exemplo para múltiplos clusters

## [1.0.0] - 2024-12-01

### Adicionado
- Implementação inicial em Ansible
- Suporte a OpenShift 4.17
- Otimização para RHCOS (Red Hat CoreOS)
- Análise de arquitetura, segurança e recursos
- Geração de relatórios em múltiplos formatos
- Script de execução automatizada
- Documentação completa em português brasileiro
- Análise de impacto para ambientes de produção

### Componentes Principais
- **Data Collector Role**: Coleta de dados do cluster OpenShift
- **Architecture Analyzer Role**: Análise de infraestrutura do cluster
- **Security Analyzer Role**: Análise de configurações de segurança
- **Best Practices Analyzer Role**: Verificação de conformidade com boas práticas
- **Resource Optimizer Role**: Análise de uso de recursos
- **Report Generator Role**: Geração de relatórios em múltiplos formatos

### Funcionalidades
- Execução somente leitura (não-invasiva)
- Suporte a tags para execução seletiva
- Validação de conectividade
- Geração de relatórios consolidados
- Tratamento robusto de erros
- Configuração flexível via variáveis

---

## Como Contribuir

Para contribuir com este projeto:

1. Fork o repositório
2. Crie uma branch para sua feature (`git checkout -b feature/nova-funcionalidade`)
3. Faça commit das mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

## Versionamento

Este projeto usa [Versionamento Semântico](https://semver.org/lang/pt-BR/). Para as versões disponíveis, veja as [tags neste repositório](https://github.com/seu-usuario/openshift_health_check/tags).

## Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.
