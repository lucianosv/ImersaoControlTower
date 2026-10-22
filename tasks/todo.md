# Todo List: Imersão Control Tower

## Ingestão Bronze (Aula 02)
- [x] Job `vertice_ingestao_bronze` em `resources/ingestao_bronze.job.yml`
- [x] Tarefa `api` → notebook `01_ingestao_api_gabarito`
- [x] Tarefa `data_lake` → notebook `02_ingestao_boto3_gabarito` com parâmetros do S3, depende de `api`
- [x] Validar sintaxe do bundle com `databricks bundle validate --profile DEFAULT`

## Entrega 1: O Bundle & Conferência da Bronze (Aula 03 - Prompt 1)
- [x] Inicializar Git no projeto e conectar ao fork no GitHub
- [x] Configurar `databricks.yml` com workspace `dbc-55900bb8-c180` e warehouse `72f6049c981e743b`
- [x] Corrigir `CLAUDE.md` para profile `DEFAULT`
- [x] Criar query de conferência das 9 tabelas da bronze em `src/conferencia/00-conferencia-bronze.sql`
- [x] Job de validação `vertice_validacao_bronze` em `resources/validacao_bronze.job.yml`
- [x] Job orquestrador `vertice_farol` em `resources/vertice.job.yml` (dispara ingestão e validação)
- [x] Orquestrar com `run_job_task` e ordem ingestão → validação (`depends_on`)
- [x] Deploy no Databricks (`databricks bundle deploy --profile DEFAULT`)
- [x] Run do pipeline completo verde (`databricks bundle run vertice_farol --profile DEFAULT`)
- [x] Conferência das 9 tabelas conferida: todas batem com o seed 42
- [x] Limpar jobs órfãos e com erro no Databricks

## Entrega 2: Camada Silver (Aula 03 - Prompt 2)
- [ ] Criar pipeline declarativo Lakeflow/DLT em `resources/medalhao.pipeline.yml`
- [ ] Criar SQL de unificação das 3 ferramentas (Excel + ClickUp + MS Project) na Silver
- [ ] Adicionar etapa `medalhao` no `vertice.job.yml` (após a validação)
- [ ] Validar, fazer deploy e rodar o pipeline

## Entrega 3: Camada Gold & Testes (Aula 03 - Prompt 3)
- [ ] Modelar camada Gold
- [ ] Criar testes de qualidade com `raise_error()`

## Entrega 4: IA nos Textos de Status (Aula 03 - Prompt 4)
- [ ] Extrair status estruturado com funções GenAI (`ai_extract` / `ai_classify`)

## Entrega 5: Métricas Governadas (Aula 03 - Prompt 5)
- [ ] Criar Metric Views e vincular ao Genie / Dashboard

## Higiene do Repositório
- [x] Secret scope `vertice` criado no workspace com `aws_access_key_id` e `aws_secret_access_key`
- [x] Chaves fora do `resources/ingestao_bronze.job.yml` e fora dos notebooks
- [x] Notebook de ingestão buscando a chave no escopo (com queda para os widgets quando rodado na mão)
- [x] Notebook de aquecimento apontando para o mesmo data lake (`DataLakeVertice`) e lendo a chave do escopo
- [x] `databricks.yml` sem as variáveis de credencial mortas (o escopo é o mecanismo)
- [x] Referências do material corrigidas para os nomes em uso (bucket, endpoint, região, job, profile)
- [ ] Rotacionar a chave do Supabase e limpar o histórico do git (`14e8de0` ainda tem a chave antiga)
- [ ] Decidir o destino das pastas `aulas/z_aula-*_old` (material arquivado, com o workspace antigo)
