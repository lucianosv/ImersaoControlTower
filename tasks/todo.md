# Todo List: Imersão Control Tower

## Ingestão Bronze (Aula 02)
- [x] Padronizar notebooks para `src/ingestao/01_ingestao_api.py` e `src/ingestao/02_ingestao_boto3.py`
- [x] Configurar definição do job `vertice_ingestao_bronze` em `resources/ingestao_bronze.job.yml`
- [x] Configurar credenciais reais do Supabase S3
- [x] Executar e testar ingestão no Databricks (`TERMINATED SUCCESS`)

## Entrega 1: O Bundle & Conferência da Bronze (Aula 03 - Prompt 1)
- [x] Inicializar Git no projeto e conectar ao fork no GitHub
- [x] Configurar `databricks.yml` com workspace `dbc-55900bb8-c180` e warehouse `72f6049c981e743b`
- [x] Padronizar conferência em `src/conferencia/00-conferencia-bronze.sql`
- [x] Criar job `vertice_validacao_bronze` em `resources/validacao_bronze.job.yml`
- [x] Executar validação das 9 tabelas da bronze com sucesso

## Entrega 2: Camada Silver (Aula 03 - Prompt 2)
- [x] Padronizar scripts SQL em `src/silver/` (01 a 05)
- [x] Criar pipeline Lakeflow Spark Declarative em `resources/vertice_medalhao.pipeline.yml`
- [x] Integrar etapa `medalhao` no job orquestrador `resources/vertice.job.yml`
- [x] Executar deploy no Databricks (`databricks bundle deploy --profile DEFAULT`)
- [x] Executar pipeline `vertice_medalhao` no Databricks com sucesso (`UPDATE COMPLETED`)
- [x] Auditar as 7 tabelas e métricas na `lakehouse_vertice.silver` (custo R$ 193,35 mi, 520 colaboradores, etc.)

## Entrega 3: Camada Gold & Testes (Aula 03 - Prompt 3)
- [ ] Modelar camada Gold em `src/gold/`
- [ ] Adicionar testes de qualidade em `src/testes/testes.sql`

## Entrega 4: IA nos Textos de Status (Aula 03 - Prompt 4)
- [ ] Extrair status estruturado com GenAI em `src/ia/status_estruturado.sql`

## Entrega 5: Métricas Governadas (Aula 03 - Prompt 5)
- [ ] Criar Metric Views e vincular ao Genie / Dashboard
