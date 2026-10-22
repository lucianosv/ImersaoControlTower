# Implementation Plan: Projeto Farol e Ingestão Bronze

## Overview

Este plano cobre o pipeline completo de dados da imersão Control Tower na Vértice Tecnologia.
O bundle `vertice` (na raiz do repositório) trata a **camada Bronze** e já deixa a estrutura
pronta para as camadas Silver/Gold (aulas 03 e 04).

O bundle foi organizado em **três jobs modulares**, orquestrados por um job principal:

```
                    ┌──────────────────────────────┐
                    │  vertice_farol  (orquestra)  │
                    └──────────────┬───────────────┘
                                   │ run_job_task
                 ┌─────────────────┴──────────────────┐
                 ▼                                    ▼
   ┌───────────────────────────┐      ┌──────────────────────────────┐
   │ vertice_ingestao_bronze  │ ───▶ │ vertice_validacao_bronze    │
   │  api → data_lake          │depends_on │ conferencia_bronze (sql)  │
   └───────────────────────────┘      └──────────────────────────────┘
```

## Architecture Decisions

- **Databricks Asset Bundle (`vertice`)**: Gerenciamento de infraestrutura como código (IaC).
- **Workspace**: `https://dbc-55900bb8-c180.cloud.databricks.com`
- **Profile Databricks**: `DEFAULT`
- **Ambiente**: Databricks Free Edition (Serverless)
- **SQL Warehouse**: `72f6049c981e743b` (Serverless Starter Warehouse)
- **Catálogo**: `lakehouse_vertice` com schemas `bronze`, `silver`, `gold`
- **Jobs modulares, não um job gigante**: a ingestão e a validação são jobs separados; o job
  `vertice_farol` só orquestra. Assim cada etapa roda e falha isoladamente, e o DAG mostra
  onde parou.
- **Conferência depois da ingestão**: a validação só roda se a ingestão terminar bem
  (`depends_on`). Sem essa ordem, a conferência poderia ler a bronze da semana passada e
  dar um falso "ok".
- **Sem agendamento automático por enquanto**: os três jobs rodam sob demanda
  (`databricks bundle run vertice_farol`). O target `dev` mantém
  `presets: { trigger_pause_status: PAUSED }` para preservar recursos do Free Edition.
- **O SQL fica no repositório**: a conferência é versionada em
  `src/conferencia/00-conferencia-bronze.sql` e o bundle a publica no workspace.

## Jobs Definidos no Bundle

### 1. `vertice_ingestao_bronze` (`resources/ingestao_bronze.job.yml`)
Carrega a camada Bronze a partir das duas fontes da noite 2.

- **Tarefas**:
  - `api`: notebook `/Users/${workspace.current_user.userName}/ImersaoControlTower/01_ingestao_api_gabarito`
    (feriados nacionais pela API pública BrasilAPI)
  - `data_lake`: **depende de `api`**, notebook
    `/Users/${workspace.current_user.userName}/ImersaoControlTower/02_ingestao_boto3_gabarito`
    (data lake S3/Supabase via boto3; baixa, extrai e grava as 9 tabelas da bronze)
- **Parâmetros do data lake** (via `base_parameters`): `S3_ENDPOINT`, `AWS_DEFAULT_REGION`,
  `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`

### 2. `vertice_validacao_bronze` (`resources/validacao_bronze.job.yml`)
Confere a integridade da bronze antes de qualquer cálculo.

- **Tarefa**: `conferencia_bronze` — `sql_task` no warehouse `${var.warehouse_id}`,
  lendo o arquivo `../src/conferencia/00-conferencia-bronze.sql`
- **Conteúdo do SQL**: uma linha por tabela da bronze com `esperado` (seed 42) e `obtido`
  (contagem real). Se qualquer linha divergir, `raise_error()` interrompe o job com a
  mensagem de que tabela divergiu e o que fazer.
- **Contagens esperadas (seed 42)**: projetos 60 · status_semanal 3911 · excel_tarefas 1663 ·
  clickup_tarefas 2119 · msproject_tarefas 1260 · colaboradores 523 · apontamentos 30883 ·
  custos 23640 · entregas_fornecedor 640

### 3. `vertice_farol` (`resources/vertice.job.yml`)
Orquestrador da esteira. Não tem SQL próprio: só dispara os outros jobs.

- **Tarefas**:
  - `ingestao_bronze`: `run_job_task` → `${resources.jobs.vertice_ingestao_bronze.id}`
  - `validacao_bronze`: **depende de `ingestao_bronze`**,
    `run_job_task` → `${resources.jobs.vertice_validacao_bronze.id}`
- **Próximas entregas** (prompts 2 a 5): acrescentar aqui as etapas
  `medalhao` (silver), `testes_de_qualidade`, `status_com_ia` e `metricas_governadas`

## Como Rodar

```bash
databricks bundle validate --profile DEFAULT   # confere o YAML
databricks bundle deploy   --profile DEFAULT   # publica os 3 jobs
databricks bundle run vertice_farol --profile DEFAULT   # roda a esteira inteira
```

Para rodar só a validação (a bronze já carregada):

```bash
databricks bundle run vertice_validacao_bronze --profile DEFAULT
```

## Status Atual

- [x] Bundle `vertice` com 3 jobs (`vertice_farol`, `vertice_ingestao_bronze`, `vertice_validacao_bronze`)
- [x] Orquestração com `run_job_task` e ordem ingestão → validação
- [x] `databricks bundle validate` sem erros
- [x] `databricks bundle run vertice_farol` verde: 3 min 20 s (ingestão ~3 min + validação 12 s)
- [x] Conferência confere as 9 tabelas: todas batem com o seed 42
- [x] Cronograma e variáveis do bundle ajustados ao workspace `dbc-55900bb8-c180`
- [ ] Migrar as credenciais do S3 do job para as variáveis do bundle (hoje estão no YAML)

## Riscos e Mitigações

| Risco | Impacto | Mitigação |
|---|---|---|
| Ingestão parcial (upload interrompido) | Alto | A validação aborta o pipeline antes do Silver; a mensagem de erro aponta `00-carregar-dados` e `01-ingestao-bronze` |
| `mode: development` prefixa nomes e quebra o SQL | Alto | Nunca usar `mode: development`; pausar agendamento com `presets` |
| Credenciais do S3 no YAML do repositório | Alto | Mover para `variables` do bundle e injecting no deploy |
| Job editado na interface do workspace trava o `bundle deploy` | Médio | Editar sempre o YAML do repositório e redeployar |

## Open Questions

- [ ] Em que momento os jobs passam a ter agendamento (segunda 6h) sem o `PAUSED`?
- [ ] As etapas de Silver/Gold entram como `pipeline_task` (Lakeflow) neste mesmo orquestrador?
