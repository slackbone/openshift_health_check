#!/usr/bin/env python3
"""
Script de Simulação de Execução do OpenShift Health Check
Gera dados randômicos e cria relatórios HTML para análise
"""

import os
import json
import random
import datetime
from pathlib import Path
import shutil

class OpenShiftHealthCheckSimulator:
    def __init__(self):
        self.base_dir = Path(__file__).parent
        self.reports_dir = self.base_dir / "reports"
        self.ansible_dir = self.base_dir / "ansible"
        self.templates_dir = self.ansible_dir / "templates"
        
        # Gerar timestamp único para esta execução
        self.timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        self.cluster_name = "demo-cluster"
        self.execution_id = f"{self.cluster_name}_{self.timestamp}"
        self.output_dir = self.reports_dir / self.execution_id
        
        # Dados simulados
        self.mock_data = self._generate_mock_data()
        
    def _generate_mock_data(self):
        """Gera dados randômicos para simulação"""
        return {
            "cluster_info": {
                "name": self.cluster_name,
                "version": "4.17.0",
                "platform": "AWS",
                "region": "us-east-1",
                "nodes": {
                    "total": random.randint(8, 15),
                    "masters": 3,
                    "workers": random.randint(5, 12),
                    "infra": random.randint(2, 4)
                },
                "namespaces": random.randint(25, 50),
                "pods": random.randint(200, 500),
                "services": random.randint(50, 120)
            },
            "scores": {
                "overall": random.randint(65, 95),
                "data_collection": random.randint(90, 100),
                "architecture": random.randint(70, 95),
                "security": random.randint(60, 90),
                "best_practices": random.randint(65, 85),
                "resource_optimization": random.randint(55, 80)
            },
            "costs": {
                "current_monthly": random.randint(2000, 5000),
                "optimized_monthly": random.randint(1500, 4000),
                "potential_savings": random.randint(300, 1000),
                "savings_percentage": random.randint(10, 25)
            },
            "issues": self._generate_issues(),
            "recommendations": self._generate_recommendations(),
            "metrics": self._generate_metrics()
        }
    
    def _generate_issues(self):
        """Gera questões simuladas"""
        issues = []
        issue_types = [
            {"category": "Segurança", "priority": "Alta", "description": "Pods executando com privilégios elevados", "impact": "Risco de segurança crítico"},
            {"category": "Recursos", "priority": "Média", "description": "Nós subutilizados identificados", "impact": "Desperdício de recursos"},
            {"category": "Arquitetura", "priority": "Baixa", "description": "Configuração de rede não otimizada", "impact": "Performance reduzida"},
            {"category": "Boas Práticas", "priority": "Média", "description": "Falta de labels padronizados", "impact": "Dificuldade de gerenciamento"},
            {"category": "Segurança", "priority": "Alta", "description": "Secrets não criptografados", "impact": "Vulnerabilidade de dados"}
        ]
        
        # Selecionar 3-5 questões aleatórias
        selected_issues = random.sample(issue_types, random.randint(3, 5))
        return selected_issues
    
    def _generate_recommendations(self):
        """Gera recomendações simuladas"""
        return {
            "high_priority": [
                "Implementar Pod Security Standards",
                "Criptografar secrets sensíveis",
                "Configurar Network Policies",
                "Atualizar imagens com vulnerabilidades"
            ],
            "medium_priority": [
                "Padronizar labels de recursos",
                "Implementar Resource Quotas",
                "Configurar HPA para aplicações críticas",
                "Otimizar requests e limits"
            ],
            "low_priority": [
                "Implementar monitoring avançado",
                "Configurar backup automatizado",
                "Documentar arquitetura",
                "Implementar CI/CD pipelines"
            ]
        }
    
    def _generate_metrics(self):
        """Gera métricas simuladas"""
        return {
            "cpu_usage": {
                "current": random.randint(45, 85),
                "optimized": random.randint(30, 70)
            },
            "memory_usage": {
                "current": random.randint(50, 90),
                "optimized": random.randint(35, 75)
            },
            "storage_usage": {
                "current": random.randint(60, 95),
                "optimized": random.randint(40, 80)
            },
            "network_throughput": {
                "current": random.randint(70, 95),
                "optimized": random.randint(80, 100)
            }
        }
    
    def create_directory_structure(self):
        """Cria a estrutura de diretórios para os relatórios"""
        directories = [
            self.output_dir,
            self.output_dir / "data_collection",
            self.output_dir / "architecture_analysis", 
            self.output_dir / "security_analysis",
            self.output_dir / "best_practices_analysis",
            self.output_dir / "resource_optimization",
            self.output_dir / "consolidated",
            self.output_dir / "html",
            self.output_dir / "html" / "data_collection",
            self.output_dir / "html" / "architecture_analysis",
            self.output_dir / "html" / "security_analysis", 
            self.output_dir / "html" / "best_practices_analysis",
            self.output_dir / "html" / "resource_optimization",
            self.output_dir / "html" / "consolidated"
        ]
        
        for directory in directories:
            directory.mkdir(parents=True, exist_ok=True)
            print(f"✓ Criado diretório: {directory}")
    
    def generate_json_data_files(self):
        """Gera arquivos JSON com dados simulados"""
        data_files = {
            "data_collection/cluster_info.json": self.mock_data["cluster_info"],
            "data_collection/collection_summary.json": {
                "total_components": 5,
                "success_rate": 100,
                "execution_time": "12 minutos",
                "data_points_collected": random.randint(1000, 5000)
            },
            "architecture_analysis/architecture_analysis.json": {
                "cluster_overview": self.mock_data["cluster_info"],
                "node_analysis": {
                    "healthy_nodes": self.mock_data["cluster_info"]["nodes"]["total"] - random.randint(0, 2),
                    "unhealthy_nodes": random.randint(0, 2),
                    "node_distribution": "Bem distribuído"
                },
                "network_analysis": {
                    "policies_configured": random.randint(5, 15),
                    "services_exposed": random.randint(10, 30),
                    "ingress_controllers": random.randint(1, 3)
                }
            },
            "security_analysis/security_analysis.json": {
                "rbac_analysis": {
                    "total_users": random.randint(20, 50),
                    "admin_users": random.randint(2, 5),
                    "service_accounts": random.randint(50, 100)
                },
                "pod_security": {
                    "privileged_pods": random.randint(0, 5),
                    "host_network_pods": random.randint(0, 3),
                    "security_policies": random.randint(3, 8)
                }
            },
            "best_practices_analysis/best_practices_analysis.json": {
                "naming_conventions": {
                    "compliant_resources": random.randint(70, 95),
                    "non_compliant_resources": random.randint(5, 30)
                },
                "resource_management": {
                    "resources_with_limits": random.randint(60, 90),
                    "resources_without_limits": random.randint(10, 40)
                }
            },
            "resource_optimization/resource_optimization.json": {
                "cost_analysis": self.mock_data["costs"],
                "resource_usage": self.mock_data["metrics"],
                "optimization_opportunities": random.randint(5, 15)
            }
        }
        
        for file_path, data in data_files.items():
            full_path = self.output_dir / file_path
            with open(full_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
            print(f"✓ Gerado arquivo JSON: {file_path}")
    
    def generate_consolidated_html_report(self):
        """Gera o relatório HTML consolidado"""
        template_path = self.templates_dir / "consolidated_health_check_report.html"
        
        if not template_path.exists():
            # Criar template HTML consolidado se não existir
            self._create_consolidated_html_template()
        
        # Ler template base
        base_template = self.templates_dir / "base_report_template.html"
        with open(base_template, 'r', encoding='utf-8') as f:
            base_content = f.read()
        
        # Gerar conteúdo do relatório consolidado
        consolidated_content = self._generate_consolidated_content()
        
        # Substituir placeholders
        html_content = base_content.replace("{{ report_title }}", "Relatório Consolidado de Saúde do OpenShift")
        html_content = html_content.replace("{{ generation_timestamp }}", datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
        html_content = html_content.replace("{% block content %}{% endblock %}", consolidated_content)
        
        # Salvar relatório
        output_path = self.output_dir / "html" / "consolidated" / "consolidated_health_check_report.html"
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(html_content)
        
        print(f"✓ Gerado relatório HTML consolidado: {output_path}")
        return output_path
    
    def _create_consolidated_html_template(self):
        """Cria template HTML consolidado se não existir"""
        template_content = """<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Relatório Consolidado - OpenShift Health Check</title>
    <style>
        /* Estilos do template base já incluídos */
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Relatório Consolidado de Saúde do OpenShift</h1>
            <div class="subtitle">Análise Executiva Completa</div>
        </div>
        
        <!-- Conteúdo será inserido aqui -->
        
        <div class="footer">
            <p><strong>OpenShift Health Check</strong></p>
            <p>Relatório gerado automaticamente</p>
        </div>
    </div>
</body>
</html>"""
        
        template_path = self.templates_dir / "consolidated_health_check_report.html"
        with open(template_path, 'w', encoding='utf-8') as f:
            f.write(template_content)
    
    def _generate_consolidated_content(self):
        """Gera o conteúdo HTML do relatório consolidado"""
        scores = self.mock_data["scores"]
        costs = self.mock_data["costs"]
        issues = self.mock_data["issues"]
        recommendations = self.mock_data["recommendations"]
        
        # Determinar status geral
        overall_score = scores["overall"]
        if overall_score >= 90:
            status_class = "status-excellent"
            status_text = "🟢 Excelente"
        elif overall_score >= 70:
            status_class = "status-good" 
            status_text = "🟡 Bom"
        elif overall_score >= 50:
            status_class = "status-warning"
            status_text = "🟠 Regular"
        else:
            status_class = "status-critical"
            status_text = "🔴 Crítico"
        
        content = f"""
        <div class="report-info">
            <h2>📊 Informações da Análise</h2>
            <div class="info-grid">
                <div class="info-item">
                    <span class="info-label">Cluster:</span>
                    <span class="info-value">{self.cluster_name}</span>
                </div>
                <div class="info-item">
                    <span class="info-label">Data da Análise:</span>
                    <span class="info-value">{datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")}</span>
                </div>
                <div class="info-item">
                    <span class="info-label">Pontuação Geral:</span>
                    <span class="info-value"><span class="{status_class}">{overall_score}/100 - {status_text}</span></span>
                </div>
                <div class="info-item">
                    <span class="info-label">Tempo de Execução:</span>
                    <span class="info-value">12 minutos</span>
                </div>
            </div>
        </div>

        <div class="section">
            <div class="section-header">
                <h2>📈 Pontuações por Categoria</h2>
                <div class="section-subtitle">Análise detalhada de cada área</div>
            </div>
            <div class="section-content">
                <div class="metrics-grid">
                    <div class="metric-card">
                        <div class="metric-value">{scores['data_collection']}/100</div>
                        <div class="metric-label">Coleta de Dados</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value">{scores['architecture']}/100</div>
                        <div class="metric-label">Arquitetura</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value">{scores['security']}/100</div>
                        <div class="metric-label">Segurança</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value">{scores['best_practices']}/100</div>
                        <div class="metric-label">Boas Práticas</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value">{scores['resource_optimization']}/100</div>
                        <div class="metric-label">Otimização</div>
                    </div>
                </div>
            </div>
        </div>

        <div class="section">
            <div class="section-header">
                <h2>💰 Análise de Custos</h2>
                <div class="section-subtitle">Oportunidades de economia identificadas</div>
            </div>
            <div class="section-content">
                <div class="metrics-grid">
                    <div class="metric-card">
                        <div class="metric-value">${costs['current_monthly']:,}</div>
                        <div class="metric-label">Custo Atual/Mês</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value">${costs['optimized_monthly']:,}</div>
                        <div class="metric-label">Custo Otimizado/Mês</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value">${costs['potential_savings']:,}</div>
                        <div class="metric-label">Economia Potencial</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value">{costs['savings_percentage']}%</div>
                        <div class="metric-label">% de Economia</div>
                    </div>
                </div>
            </div>
        </div>

        <div class="section">
            <div class="section-header">
                <h2>🚨 Questões Identificadas</h2>
                <div class="section-subtitle">Problemas que requerem atenção</div>
            </div>
            <div class="section-content">
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Categoria</th>
                                <th>Prioridade</th>
                                <th>Descrição</th>
                                <th>Impacto</th>
                            </tr>
                        </thead>
                        <tbody>
        """
        
        for issue in issues:
            priority_class = f"priority-{issue['priority'].lower()}"
            content += f"""
                            <tr>
                                <td>{issue['category']}</td>
                                <td><span class="{priority_class}">{issue['priority']}</span></td>
                                <td>{issue['description']}</td>
                                <td>{issue['impact']}</td>
                            </tr>
            """
        
        content += """
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <div class="section">
            <div class="section-header">
                <h2>📋 Plano de Ação</h2>
                <div class="section-subtitle">Recomendações priorizadas</div>
            </div>
            <div class="section-content">
                <div class="recommendations">
                    <h3>🔴 Alta Prioridade (Próximos 7 dias)</h3>
        """
        
        for rec in recommendations["high_priority"]:
            content += f"                    <div class='recommendation-item'>{rec}</div>\n"
        
        content += """
                </div>
                <div class="recommendations">
                    <h3>🟡 Média Prioridade (Próximos 30 dias)</h3>
        """
        
        for rec in recommendations["medium_priority"]:
            content += f"                    <div class='recommendation-item'>{rec}</div>\n"
        
        content += """
                </div>
                <div class="recommendations">
                    <h3>🟢 Baixa Prioridade (Próximos 90 dias)</h3>
        """
        
        for rec in recommendations["low_priority"]:
            content += f"                    <div class='recommendation-item'>{rec}</div>\n"
        
        content += """
                </div>
            </div>
        </div>
        """
        
        return content
    
    def generate_individual_html_reports(self):
        """Gera relatórios HTML individuais para cada categoria"""
        reports = [
            {
                "name": "data_collection",
                "title": "Relatório de Coleta de Dados",
                "content": self._generate_data_collection_content()
            },
            {
                "name": "architecture_analysis", 
                "title": "Relatório de Análise de Arquitetura",
                "content": self._generate_architecture_content()
            },
            {
                "name": "security_analysis",
                "title": "Relatório de Análise de Segurança", 
                "content": self._generate_security_content()
            },
            {
                "name": "best_practices_analysis",
                "title": "Relatório de Boas Práticas",
                "content": self._generate_best_practices_content()
            },
            {
                "name": "resource_optimization",
                "title": "Relatório de Otimização de Recursos",
                "content": self._generate_resource_optimization_content()
            }
        ]
        
        for report in reports:
            # Ler template base
            base_template = self.templates_dir / "base_report_template.html"
            with open(base_template, 'r', encoding='utf-8') as f:
                base_content = f.read()
            
            # Substituir placeholders
            html_content = base_content.replace("{{ report_title }}", report["title"])
            html_content = html_content.replace("{{ generation_timestamp }}", datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
            html_content = html_content.replace("{% block content %}{% endblock %}", report["content"])
            
            # Salvar relatório
            output_path = self.output_dir / "html" / report["name"] / f"{report['name']}_report.html"
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(html_content)
            
            print(f"✓ Gerado relatório HTML: {report['name']}")
    
    def _generate_data_collection_content(self):
        """Gera conteúdo para relatório de coleta de dados"""
        cluster_info = self.mock_data["cluster_info"]
        return f"""
        <div class="report-info">
            <h2>📊 Informações do Cluster</h2>
            <div class="info-grid">
                <div class="info-item">
                    <span class="info-label">Nome:</span>
                    <span class="info-value">{cluster_info['name']}</span>
                </div>
                <div class="info-item">
                    <span class="info-label">Versão:</span>
                    <span class="info-value">{cluster_info['version']}</span>
                </div>
                <div class="info-item">
                    <span class="info-label">Plataforma:</span>
                    <span class="info-value">{cluster_info['platform']}</span>
                </div>
                <div class="info-item">
                    <span class="info-label">Região:</span>
                    <span class="info-value">{cluster_info['region']}</span>
                </div>
            </div>
        </div>

        <div class="section">
            <div class="section-header">
                <h2>🖥️ Recursos do Cluster</h2>
                <div class="section-subtitle">Distribuição de recursos coletados</div>
            </div>
            <div class="section-content">
                <div class="metrics-grid">
                    <div class="metric-card">
                        <div class="metric-value">{cluster_info['nodes']['total']}</div>
                        <div class="metric-label">Total de Nós</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value">{cluster_info['nodes']['masters']}</div>
                        <div class="metric-label">Nós Master</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value">{cluster_info['nodes']['workers']}</div>
                        <div class="metric-label">Nós Worker</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value">{cluster_info['namespaces']}</div>
                        <div class="metric-label">Namespaces</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value">{cluster_info['pods']}</div>
                        <div class="metric-label">Pods</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value">{cluster_info['services']}</div>
                        <div class="metric-label">Serviços</div>
                    </div>
                </div>
            </div>
        </div>
        """
    
    def _generate_architecture_content(self):
        """Gera conteúdo para relatório de arquitetura"""
        return """
        <div class="section">
            <div class="section-header">
                <h2>🏗️ Análise de Arquitetura</h2>
                <div class="section-subtitle">Estrutura e configuração do cluster</div>
            </div>
            <div class="section-content">
                <div class="recommendations">
                    <h3>✅ Pontos Fortes</h3>
                    <div class="recommendation-item">Distribuição adequada de nós master e worker</div>
                    <div class="recommendation-item">Configuração de rede bem estruturada</div>
                    <div class="recommendation-item">Operadores essenciais funcionando corretamente</div>
                </div>
                
                <div class="recommendations">
                    <h3>⚠️ Áreas de Melhoria</h3>
                    <div class="recommendation-item">Otimizar configuração de storage classes</div>
                    <div class="recommendation-item">Implementar backup automatizado</div>
                    <div class="recommendation-item">Configurar monitoring avançado</div>
                </div>
            </div>
        </div>
        """
    
    def _generate_security_content(self):
        """Gera conteúdo para relatório de segurança"""
        return """
        <div class="section">
            <div class="section-header">
                <h2>🔒 Análise de Segurança</h2>
                <div class="section-subtitle">Configurações e políticas de segurança</div>
            </div>
            <div class="section-content">
                <div class="recommendations">
                    <h3>🚨 Questões Críticas</h3>
                    <div class="recommendation-item">Pods executando com privilégios elevados</div>
                    <div class="recommendation-item">Secrets não criptografados</div>
                    <div class="recommendation-item">Falta de Network Policies</div>
                </div>
                
                <div class="recommendations">
                    <h3>✅ Boas Práticas Implementadas</h3>
                    <div class="recommendation-item">RBAC configurado adequadamente</div>
                    <div class="recommendation-item">Service accounts com permissões mínimas</div>
                    <div class="recommendation-item">Imagens escaneadas por vulnerabilidades</div>
                </div>
            </div>
        </div>
        """
    
    def _generate_best_practices_content(self):
        """Gera conteúdo para relatório de boas práticas"""
        return """
        <div class="section">
            <div class="section-header">
                <h2>📋 Análise de Boas Práticas</h2>
                <div class="section-subtitle">Conformidade com padrões e convenções</div>
            </div>
            <div class="section-content">
                <div class="recommendations">
                    <h3>✅ Práticas Implementadas</h3>
                    <div class="recommendation-item">Labels padronizados na maioria dos recursos</div>
                    <div class="recommendation-item">Resource quotas configuradas</div>
                    <div class="recommendation-item">Health checks implementados</div>
                </div>
                
                <div class="recommendations">
                    <h3>⚠️ Melhorias Necessárias</h3>
                    <div class="recommendation-item">Padronizar nomenclatura de recursos</div>
                    <div class="recommendation-item">Implementar resource limits</div>
                    <div class="recommendation-item">Configurar readiness e liveness probes</div>
                </div>
            </div>
        </div>
        """
    
    def _generate_resource_optimization_content(self):
        """Gera conteúdo para relatório de otimização de recursos"""
        costs = self.mock_data["costs"]
        metrics = self.mock_data["metrics"]
        
        return f"""
        <div class="section">
            <div class="section-header">
                <h2>💰 Análise de Custos</h2>
                <div class="section-subtitle">Oportunidades de economia identificadas</div>
            </div>
            <div class="section-content">
                <div class="metrics-grid">
                    <div class="metric-card">
                        <div class="metric-value">${costs['current_monthly']:,}</div>
                        <div class="metric-label">Custo Atual/Mês</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value">${costs['optimized_monthly']:,}</div>
                        <div class="metric-label">Custo Otimizado/Mês</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value">${costs['potential_savings']:,}</div>
                        <div class="metric-label">Economia Potencial</div>
                    </div>
                </div>
            </div>
        </div>

        <div class="section">
            <div class="section-header">
                <h2>📊 Uso de Recursos</h2>
                <div class="section-subtitle">Métricas de utilização atual vs otimizada</div>
            </div>
            <div class="section-content">
                <div class="metrics-grid">
                    <div class="metric-card">
                        <div class="metric-value">{metrics['cpu_usage']['current']}%</div>
                        <div class="metric-label">CPU Atual</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value">{metrics['cpu_usage']['optimized']}%</div>
                        <div class="metric-label">CPU Otimizada</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value">{metrics['memory_usage']['current']}%</div>
                        <div class="metric-label">Memória Atual</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value">{metrics['memory_usage']['optimized']}%</div>
                        <div class="metric-label">Memória Otimizada</div>
                    </div>
                </div>
            </div>
        </div>
        """
    
    def generate_markdown_reports(self):
        """Gera relatórios em Markdown"""
        # Usar o template Jinja2 existente
        template_path = self.templates_dir / "consolidated_health_check_report.j2"
        
        if template_path.exists():
            # Ler template
            with open(template_path, 'r', encoding='utf-8') as f:
                template_content = f.read()
            
            # Substituir variáveis (simulação simples)
            markdown_content = template_content
            markdown_content = markdown_content.replace("{{ cluster_name | default('openshift-cluster.example.com') }}", self.cluster_name)
            markdown_content = markdown_content.replace("{{ overall_score | default(80) }}", str(self.mock_data["scores"]["overall"]))
            markdown_content = markdown_content.replace("{{ data_collection_score | default(100) }}", str(self.mock_data["scores"]["data_collection"]))
            markdown_content = markdown_content.replace("{{ architecture_score | default(85) }}", str(self.mock_data["scores"]["architecture"]))
            markdown_content = markdown_content.replace("{{ security_score | default(78) }}", str(self.mock_data["scores"]["security"]))
            markdown_content = markdown_content.replace("{{ best_practices_score | default(82) }}", str(self.mock_data["scores"]["best_practices"]))
            markdown_content = markdown_content.replace("{{ resource_optimization_score | default(75) }}", str(self.mock_data["scores"]["resource_optimization"]))
            
            # Salvar relatório Markdown
            output_path = self.output_dir / "consolidated" / "consolidated_health_check_report.md"
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(markdown_content)
            
            print(f"✓ Gerado relatório Markdown: {output_path}")
    
    def run_simulation(self):
        """Executa a simulação completa"""
        print("🚀 Iniciando simulação do OpenShift Health Check...")
        print(f"📁 Diretório de saída: {self.output_dir}")
        
        # Criar estrutura de diretórios
        self.create_directory_structure()
        
        # Gerar arquivos JSON com dados simulados
        self.generate_json_data_files()
        
        # Gerar relatórios HTML
        print("\n📊 Gerando relatórios HTML...")
        self.generate_consolidated_html_report()
        self.generate_individual_html_reports()
        
        # Gerar relatórios Markdown
        print("\n📝 Gerando relatórios Markdown...")
        self.generate_markdown_reports()
        
        print(f"\n✅ Simulação concluída com sucesso!")
        print(f"📂 Relatórios gerados em: {self.output_dir}")
        print(f"\n🌐 Para visualizar os relatórios HTML:")
        print(f"   file://{self.output_dir}/html/consolidated/consolidated_health_check_report.html")
        
        return self.output_dir

def main():
    """Função principal"""
    simulator = OpenShiftHealthCheckSimulator()
    output_dir = simulator.run_simulation()
    
    print(f"\n📋 Resumo da Simulação:")
    print(f"   • Cluster: {simulator.cluster_name}")
    print(f"   • Execução: {simulator.execution_id}")
    print(f"   • Pontuação Geral: {simulator.mock_data['scores']['overall']}/100")
    print(f"   • Economia Potencial: ${simulator.mock_data['costs']['potential_savings']:,}/mês")
    print(f"   • Questões Identificadas: {len(simulator.mock_data['issues'])}")

if __name__ == "__main__":
    main()
