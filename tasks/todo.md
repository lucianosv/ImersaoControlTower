# Todo List: Imersão Control Tower

## Ingestão Bronze (Aula 02)
- [x] Configurar definição do job `vertice_ingestao` em `resources/ingestao.job.yml`
- [x] Mapear tarefa `api` para notebook `01_ingestao_api_gabarito`
- [x] Mapear tarefa `data_lake` para notebook `02_ingestao_boto3_gabarito` com parâmetros do S3
- [x] Validar sintaxe do bundle com `databricks bundle validate --profile DEFAULT`

## Entrega 1: O Bundle & Conferência da Bronze (Aula 03 - Prompt 1)
- [x] Inicializar Git no projeto e conectar ao fork no GitHub
- [x] Configurar `databricks.yml` com workspace `dbc-55900bb8-c180` e warehouse `72f6049c981e743b`
- [x] Corrigir `CLAUDE.md` para profile `DEFAULT`
- [x] Criar query de conferência das 9 tabelas da bronze em `src/conferencia/00-conferencia-bronze.sql`
- [x] Criar job `vertice_farol` com tarefa `conferencia_bronze` em `resources/vertice.job.yml`
- [x] Executar deploy no Databricks (`databricks bundle deploy --profile DEFAULT`)
- [x] Executar run do job `vertice_farol` com sucesso (`TERMINATED SUCCESS`)
- [x] Limpar jobs órfãos e com erro no Databricks

## Entrega 2: Camada Silver (Aula 03 - Prompt 2)
- [ ] Criar pipeline declarativo Lakeflow/DLT em `resources/medalhao.pipeline.yml`
- [ ] Criar SQL de unificação das 3 ferramentas (Excel + ClickUp + MS Project) na Silver
- [ ] Adicionar tarefa `medalhao` no `vertice.job.yml`
- [ ] Validar, fazer deploy e rodar o pipeline

## Entrega 3: Camada Gold & Testes (Aula 03 - Prompt 3)
- [ ] Modelar camada Gold
- [ ] Criar testes de qualidade com `raise_error()`

## Entrega 4: IA nos Textos de Status (Aula 03 - Prompt 4)
- [ ] Extrair status estruturado com funções GenAI (`ai_extract` / `ai_classify`)

## Entrega 5: Métricas Governadas (Aula 03 - Prompt 5)
- [ ] Criar Metric Views e vincular ao Genie / Dashboard