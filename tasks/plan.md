# Implementation Plan: Projeto Farol e Ingestão Bronze

## Overview

Este plano cobre o pipeline completo de dados da imersão Control Tower na Vértice Tecnologia:
1. **Ingestão Automatizada da Camada Bronze** (`vertice_ingestao`):
   - Ingestão da API pública BrasilAPI (feriados nacionais) via `01_ingestao_api_gabarito`
   - Ingestão do Data Lake S3/Supabase (`DataLakeCentralTower`) via boto3 e carga das 9 tabelas da bronze via `02_ingestao_boto3_gabarito`
2. **Torre de Controle / Farol** (`vertice_farol`):
   - Entrega 1: Conferência da Bronze (`00-conferencia-bronze.sql`)
   - Entrega 2: Medalhão Lakeflow / Silver (`vertice_medalhao`)
   - Entrega 3: Gold + Testes de Qualidade
   - Entrega 4: IA nos textos de status
   - Entrega 5: Métricas governadas

## Architecture Decisions

- **Databricks Asset Bundle (`vertice`)**: Gerenciamento de infraestrutura como código (IaC).
- **Workspace**: `https://dbc-55900bb8-c180.cloud.databricks.com`
- **Profile Databricks**: `DEFAULT`
- **Ambiente**: Databricks Free Edition (Serverless)
- **SQL Warehouse**: `72f6049c981e743b` (Serverless Starter Warehouse)
- **Catálogo**: `lakehouse_vertice` com schemas `bronze`, `silver`, `gold`
- **Presets**: Em dev, agendamentos são pausados (`trigger_pause_status: PAUSED`) para preservar recursos.

## Jobs Definidos no Bundle

### 1. `vertice_ingestao` (`resources/ingestao.job.yml`)
- **Agendamento**: Segunda a sexta às 6h (America/Sao_Paulo)
- **Tarefas**:
  - `api`: Executa o notebook `/Users/${workspace.current_user.userName}/ImersaoControlTower/01_ingestao_api_gabarito`
  - `data_lake`: Depende de `api`, executa `/Users/${workspace.current_user.userName}/ImersaoControlTower/02_ingestao_boto3_gabarito` recebendo parâmetros do S3

### 2. `vertice_farol` (`resources/vertice.job.yml`)
- **Agendamento**: Segundas-feiras às 6h (America/Sao_Paulo)
- **Tarefas**:
  - `conferencia_bronze`: Valida as contagens das 9 tabelas da bronze com `raise_error()`
  - *(Próximos passos)*: `medalhao` (Silver), `testes_de_qualidade`, `status_com_ia`, `metricas_governadas`

## Status Atual
- [x] Correção de workspace e profile nos arquivos `CLAUDE.md` e `databricks.yml`
- [x] Job `vertice_farol` criado e validado com sucesso (`TERMINATED SUCCESS`)
- [x] Job `vertice_ingestao` configurado para carga da bronze
- [x] Limpeza de jobs legados/órfãos com erro no workspace