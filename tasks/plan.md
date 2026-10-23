# Implementation Plan: Torre de Controle (Projeto Farol)

## Overview

Este plano cobre a arquitetura, orquestração e implementação do pipeline completo de dados da imersão Control Tower na Vértice Tecnologia.

A arquitetura foi estruturada em **3 Níveis de Modularidade** para garantir flexibilidade de desenvolvimento, isolamento de falhas e respeito estrito ao limite de computação do Databricks Free Tier (1 máquina serverless por vez):

1. **Nível 3 (Atômico / Individual - para debug e reprocessamento cirúrgico):**
   - `vertice_bronze_api` ([resources/bronze_api.job.yml](file:///c:/Jornada%20de%20Dados/ImersaoControlTower-main/resources/bronze_api.job.yml)): Ingestão da API pública BrasilAPI via `src/ingestao/01_ingestao_api.py`.
   - `vertice_bronze_datalake` ([resources/bronze_datalake.job.yml](file:///c:/Jornada%20de%20Dados/ImersaoControlTower-main/resources/bronze_datalake.job.yml)): Ingestão do Data Lake S3/Supabase (`DataLakeVertice`) via boto3 e carga das 9 tabelas da bronze via `src/ingestao/02_ingestao_boto3.py`.
   - `vertice_validacao_bronze` ([resources/validacao_bronze.job.yml](file:///c:/Jornada%20de%20Dados/ImersaoControlTower-main/resources/validacao_bronze.job.yml)): Conferência de integridade das 9 tabelas da bronze via `src/conferencia/00-conferencia-bronze.sql`.
   - `vertice_testes_qualidade` ([resources/testes_qualidade.job.yml](file:///c:/Jornada%20de%20Dados/ImersaoControlTower-main/resources/testes_qualidade.job.yml)): Execução isolada dos 10 testes de qualidade automatizados via `src/testes/testes.sql`.

2. **Nível 2 (Por Camada - independentes e desacoplados):**
   - `vertice_camada_bronze` ([resources/camada_bronze.job.yml](file:///c:/Jornada%20de%20Dados/ImersaoControlTower-main/resources/camada_bronze.job.yml)): Encadeia em série API -> Data Lake -> Validação.
   - `vertice_camada_silver` ([resources/silver.pipeline.yml](file:///c:/Jornada%20de%20Dados/ImersaoControlTower-main/resources/silver.pipeline.yml)): Pipeline DLT exclusivo da Silver (`src/silver/**`), unificando ClickUp, Excel e MS Project.
   - `vertice_camada_gold` ([resources/gold.pipeline.yml](file:///c:/Jornada%20de%20Dados/ImersaoControlTower-main/resources/gold.pipeline.yml)): Pipeline DLT exclusivo da Gold (`src/gold/**`), materializando métricas analíticas e de alocação.

3. **Nível 1 (Orquestrador Mestre Geral):**
   - `vertice_farol` ([resources/vertice.job.yml](file:///c:/Jornada%20de%20Dados/ImersaoControlTower-main/resources/vertice.job.yml)): Orquestrador geral que encadeia a esteira sequencial ponta a ponta:
     `camada_bronze` -> `camada_silver` -> `camada_gold` -> `testes_de_qualidade`.

---

## Architecture Decisions

- **Databricks Asset Bundle (`vertice`)**: Gerenciamento de infraestrutura como código (IaC).
- **Estrutura 100% Autocontida em `src/`**: Todo o código (Python e SQL) versionado no Git.
- **Workspace**: `https://dbc-55900bb8-c180.cloud.databricks.com`
- **Profile Databricks**: `DEFAULT`
- **Ambiente**: Databricks Free Edition (Serverless)
- **SQL Warehouse**: `72f6049c981e743b` (Serverless Starter Warehouse)
- **Catálogo**: `lakehouse_vertice` com schemas `bronze`, `silver`, `gold`
- **Isolamento de Silver e Gold**:
  - Silver e Gold mantidos como **pipelines DLT separados**.
  - No orquestrador Farol, o Databricks executa as etapas com dependência estrita (`depends_on`), garantindo que apenas 1 máquina de computação esteja ativa por vez.
- **Sem Agendamentos Automáticos (`schedule: None`)**: Disparos manuais sob demanda para evitar consumo indevido de cotas.

---

## Status das Entregas

- [x] **Entrega 1 (Bronze & Validação):** Concluída, validada e modularizada em jobs individuais e de camada.
- [x] **Entrega 2 (Silver Desacoplada):** Concluída via pipeline DLT `vertice_camada_silver` (4.917 tarefas, R$ 193,35 mi em custos, 520 colaboradores).
- [x] **Entrega 3 (Gold Desacoplada & Testes):** Concluída via pipeline DLT `vertice_camada_gold` e `vertice_testes_qualidade` (todos os 10 testes passando).
- [x] **Entrega 4 (IA nos Status):** Concluída via `src/ia/status_estruturado.sql` e job `vertice_status_com_ia` (3.911 status classificados com sucesso).
- [ ] **Entrega 5 (Métricas Governadas & Genie/Dashboard):** Metric views e catálogo semântico.

