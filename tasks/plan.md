# Implementation Plan: Projeto Farol e Ingestão Bronze

## Overview

Este plano cobre o pipeline completo de dados da imersão Control Tower na Vértice Tecnologia:
1. **Ingestão Automatizada da Camada Bronze** (`vertice_ingestao_bronze`):
   - Ingestão da API pública BrasilAPI (feriados nacionais) via `src/ingestao/01_ingestao_api.py`
   - Ingestão do Data Lake S3/Supabase (`DataLakeCentralTower`) via boto3 e carga das 9 tabelas da bronze via `src/ingestao/02_ingestao_boto3.py`
2. **Validação da Bronze** (`vertice_validacao_bronze`):
   - Conferência de integridade das 9 tabelas da bronze via `src/conferencia/00-conferencia-bronze.sql`
3. **Pipeline Declarativo Medalhão** (`vertice_medalhao`):
   - Camada Silver: 7 tabelas unificadas, tratadas e validadas com `EXPECT` via `src/silver/`
   - Camada Gold: (Próxima entrega - Prompt 03)
4. **Torre de Controle / Farol** (`vertice_farol`):
   - Orquestrador principal encadeando: Ingestão Bronze -> Validação Bronze -> Medalhão (Silver/Gold) -> IA -> Métricas

## Architecture Decisions

- **Databricks Asset Bundle (`vertice`)**: Gerenciamento de infraestrutura como código (IaC).
- **Estrutura 100% Autocontida em `src/`**: Todo o código (Python e SQL) versionado no Git.
- **Workspace**: `https://dbc-55900bb8-c180.cloud.databricks.com`
- **Profile Databricks**: `DEFAULT`
- **Ambiente**: Databricks Free Edition (Serverless)
- **SQL Warehouse**: `72f6049c981e743b` (Serverless Starter Warehouse)
- **Catálogo**: `lakehouse_vertice` com schemas `bronze`, `silver`, `gold`

## Status Atual
- [x] Correção de workspace e profile nos arquivos `CLAUDE.md` e `databricks.yml`
- [x] Padronização completa do código em `src/ingestao`, `src/conferencia`, `src/silver`
- [x] Job `vertice_ingestao_bronze` configurado e testado com credenciais reais
- [x] Job `vertice_validacao_bronze` validado com sucesso
- [x] Pipeline Lakeflow `vertice_medalhao` criado, deployado e executado com sucesso
- [x] 7 tabelas criadas e auditadas na `lakehouse_vertice.silver`
- [x] Job orquestrador `vertice_farol` atualizado
