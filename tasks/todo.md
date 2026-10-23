# Todo List: Imersão Control Tower

## Ingestão Bronze (Aula 02 / Refatoração Modular)
- [x] Padronizar notebooks para `src/ingestao/01_ingestao_api.py` e `src/ingestao/02_ingestao_boto3.py`
- [x] Modularizar jobs da Bronze em 3 níveis (Atômico e Camada):
  - [x] `resources/bronze_api.job.yml` (`vertice_bronze_api`): Ingestão da API pública BrasilAPI
  - [x] `resources/bronze_datalake.job.yml` (`vertice_bronze_datalake`): Ingestão S3/Supabase das 9 tabelas
  - [x] `resources/validacao_bronze.job.yml` (`vertice_validacao_bronze`): Conferência das 9 tabelas
  - [x] `resources/camada_bronze.job.yml` (`vertice_camada_bronze`): Orquestrador da camada Bronze
- [x] Configurar credenciais reais do Supabase S3 via secret scope / parâmetros
- [x] Executar e testar ingestão no Databricks (`TERMINATED SUCCESS`)

## Entrega 1: O Bundle & Conferência da Bronze (Aula 03 - Prompt 1)
- [x] Inicializar Git no projeto e conectar ao fork no GitHub (`lucianosv/ImersaoControlTower`)
- [x] Configurar `databricks.yml` com workspace `dbc-55900bb8-c180` e warehouse `72f6049c981e743b`
- [x] Padronizar conferência em `src/conferencia/00-conferencia-bronze.sql`
- [x] Executar validação das 9 tabelas da bronze com sucesso via `vertice_validacao_bronze`

## Entrega 2: Camada Silver Desacoplada (Aula 03 - Prompt 2)
- [x] Padronizar scripts SQL em `src/silver/` (01 a 05: projetos, tarefas, status/custos, pessoas, fornecedores)
- [x] Criar pipeline DLT independente em `resources/silver.pipeline.yml` (`vertice_camada_silver`)
- [x] Executar deploy no Databricks (`databricks bundle deploy --profile DEFAULT`)
- [x] Executar pipeline `vertice_camada_silver` com sucesso (`UPDATE COMPLETED`)
- [x] Auditar as tabelas e métricas na `lakehouse_vertice.silver` (custo R$ 193,35 mi, 520 colaboradores, 4.917 tarefas)

## Entrega 3: Camada Gold Desacoplada & Testes (Aula 03 - Prompt 3)
- [x] Modelar camada Gold em `src/gold/`:
  - [x] `01-fato-projeto-semana.sql`: Evolução temporal EVM (PV, EV, AC acumulados, SPI, CPI)
  - [x] `02-situacao-e-pessoas.sql`: Fotografia de hoje (`projeto_situacao_atual`) e alocação (`utilizacao_pessoa_semana`)
- [x] Criar pipeline DLT independente em `resources/gold.pipeline.yml` (`vertice_camada_gold`)
- [x] Criar suíte de 10 testes de qualidade automatizados em `src/testes/testes.sql`
- [x] Criar job atômico de testes em `resources/testes_qualidade.job.yml` (`vertice_testes_qualidade`)
- [x] Atualizar orquestrador mestre `resources/vertice.job.yml` (`vertice_farol`) em sequência estrita:
  `camada_bronze` -> `camada_silver` -> `camada_gold` -> `testes_de_qualidade`
- [x] Validar execução do pipeline completo sem concorrência (1 máquina por vez, sem erro de cota)
- [x] Executar suíte de 10 testes com sucesso (`10 ok / 0 erros`)

## Entrega 4: IA nos Textos de Status (Aula 03 - Prompt 4)
- [x] Extrair status estruturado com GenAI em `src/ia/status_estruturado.sql`
- [x] Criar job atômico `resources/status_com_ia.job.yml` (`vertice_status_com_ia`)
- [x] Integrar tarefa `status_com_ia` no orquestrador mestre `resources/vertice.job.yml`
- [x] Executar e auditar a tabela `lakehouse_vertice.gold.status_estruturado` (ia: 163, regra: 2.954, palavra_chave: 794; PRJ-011: falta_sre com 12 semanas e 57 dias de impacto)

## Entrega 5: Métricas Governadas (Aula 03 - Prompt 5)
- [x] Criar Metric View no Unity Catalog em `src/metricas/metricas.sql` (`lakehouse_vertice.gold.mv_projetos`)
- [x] Criar job atômico `resources/metricas_governadas.job.yml` (`vertice_metricas_governadas`)
- [x] Integrar etapa `metricas_governadas` no orquestrador mestre `resources/vertice.job.yml`
- [x] Executar e auditar métricas via `scripts/conferir_metricas.sql` (SPI 0,92 · CPI 0,97 · R$ 6,47 mi de estouro · 7 críticos · 4 melancias)
- [x] Executar suíte de validação oficial `99-verificacao.sql` (**20 de 20 testes "ok"**)

## Aula 04: Produtos de Dados & IA

### Prompt 1 · Agente de Contratos
- [x] Extração de PDFs contratuais com `ai_parse_document` em `lakehouse_vertice.silver.documentos_elementos`
- [x] Extração de 72 cláusulas em `lakehouse_vertice.silver.contratos_clausulas`
- [x] Extração estruturada com schema JSON tipado em `lakehouse_vertice.gold.contratos`
- [x] Validação oficial com `99-verificacao.sql` (11 de 11 testes "ok")
- [x] Publicação do Genie Agent **"Farol · Diretoria + Contratos"** (`01f1cef91e391e499f841a1901bb967a`)

### Prompt 2 & 3 · Databricks App (Farol Torre) & Lakebase
- [x] Provisionar projeto Lakebase Postgres `farol-torre`
- [x] Criar e popular `lakehouse_vertice.gold.score_estouro_30d` (18 alto · 4 médio · 19 baixo; PRJ-024 46%)
- [x] Configurar queries analíticas (`kpis.sql`, `projetos_risco.sql`, `pessoas_ociosas.sql`)
- [x] Configurar rotas do backend (`/api/score-estouro`, `/api/decisoes`, `/api/quem-sou`)
- [x] Validação completa do app com `databricks apps validate` (tipagem, lint, testes e build)
- [x] Deploy do bundle com service principal criado
- [x] Conceder permissões no Unity Catalog (`USE CATALOG lakehouse_vertice`, `SELECT` na gold e silver)
- [x] Deploy bem-sucedido com `databricks apps deploy farol-torre` (`SUCCEEDED`, status `RUNNING`)
- [x] URL do App no ar: `https://farol-torre-7474652991272888.aws.databricksapps.com`
