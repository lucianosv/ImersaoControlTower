# Implementation Plan: Prompt 1 - O Bundle

## Overview

Criar o bundle `vertice` na raiz do repositório como primeiro das seis entregas da noite 2. Este bundle estabelece a estrutura para o job `vertice_farol`, a conferência de dados da bronze e a base para silver, gold, dashboards e Genie. O bundle deve ser versionado, revisável e executar automaticamente toda segunda às 6h (America/Sao_Paulo).

## Architecture Decisions

- **Bundle único** chamado `vertice`, na raiz do repositório (ao lado do `CLAUDE.md`)
- **Não usar `mode: development`** — ele prefixa nomes com `[dev usuario]` e quebra o SQL. No target `dev`, usar `presets: { trigger_pause_status: PAUSED }`
- **Primeira tarefa é conferência, não transformação** — o job confere se os dados das 3 ferramentas chegaram inteiros antes de calcular KPIs
- **SQL Warehouse** descoberto via `databricks warehouses list --profile imersao-out26` (Free Edition, Serverless Starter Warehouse `666be37e3fededf2`)
- **Catálogo `lakehouse_vertice`** já existe (noite 1) — o bundle NÃO cria catálogo nem schema
- **Estratégia de deploy**: deploy → run → deploy (necessário para Genie/tabelas existirem)

## Task List

### Phase 1: Estrutura Inicial

- [ ] **Task 1**: Criar diretórios `resources/`, `src/conferencia/`, `src/silver/`, `src/gold/`, `src/ia/`, `src/metricas/`, `src/testes/`, `scripts/`

- [ ] **Task 2**: Criar `databricks.yml` com bundle name: `vertice`, variables (catalog, warehouse_id, genie vars) e targets (dev/prod)

- [ ] **Task 3**: Criar `resources/vertice.job.yml` com job `vertice_farol`, agendamento segunda 6h (America/Sao_Paulo) e tarefa `conferencia_bronze`

- [ ] **Task 4**: Criar `src/conferencia/00-conferencia-bronze.sql` conferindo 9 tabelas da bronze contra contagens esperadas (seed 42)

### Checkpoint: Foundation

- [ ] Bundle valida com `databricks bundle validate --profile imersao-out26`
- [ ] Deploy bem-sucedido com `databricks bundle deploy --profile imersao-out26`
- [ ] Job aparece no DAG do workspace com tarefa `conferencia_bronze` verde

### Phase 2: Execução Inicial

- [ ] **Task 5**: Executar `databricks bundle run vertice_farol --profile imersao-out26` para rodar a conferência

- [ ] **Task 6**: Verificar saída da conferência - 9 linhas com ok/expected vs obtained

- [ ] **Task 7**: Testar que falha ao trocar número esperado (proof that conference has teeth)

### Checkpoint: Core Features

- [ ] Conferência de bronze funcionando com todas 9 tabelas
- [ ] Job agendado corretamente no workspace

### Phase 3: Polish

- [ ] **Task 8**: Adicionar comentários explicativos sobre `mode: development` no YAML

- [ ] **Task 9**: Criar documentação inicial no README do bundle

### Checkpoint: Complete

- [ ] Todos os acceptance criteria atendidos
- [ ] Bundle pronto para extensão nos próximos prompts

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Usar `mode: development` acidentalmente | Quebra nomes de schema | Revisar YAML antes de deploy; comentar a armadilha |
| Conferência falha por dado parcial na bronze | Job para, dashboard com dado parcial | Conferir noite 1 foi executada; rodar `00-carregar-dados` se necessário |
| Genie falha no deploy sem tabelas | Tabelas precisam existir primeiro | Ordem: deploy → run → deploy |

## Open Questions

- [ ] Definir variáveis genie_space_id e genie_space_name no databricks.yml (usar valores do profile imersao-out26)

## See Also

- `prompt-01-bundle.md` para contexto completo
- `prd/99-verificacao.sql` para verificações esperadas
- Gabarito em https://github.com/lvgalvao/ImersaoControlTower/tree/main/aulas/aula-03-modelagem-claude-code/claude-code/vertice