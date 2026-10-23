# src — o código que o bundle publica

Uma pasta por camada (ou por tipo de tarefa). O `databricks bundle deploy` sincroniza esta árvore com o workspace; os jobs e pipelines não dependem de nada digitado manualmente lá.

```
src/
├── ingestao/     01_ingestao_api.py          notebook_task do vertice_bronze_api
│                 02_ingestao_boto3.py        notebook_task do vertice_bronze_datalake
├── conferencia/  00-conferencia-bronze.sql   sql_task do vertice_validacao_bronze
├── silver/       *.sql                       pipeline DLT vertice_camada_silver (prompt 2)
├── gold/         *.sql                       pipeline DLT vertice_camada_gold (prompt 3)
├── testes/       testes.sql                  sql_task do vertice_testes_qualidade (prompt 3)
├── ia/           status_estruturado.sql      sql_task da IA nos status (prompt 4)
└── metricas/     metricas.sql                sql_task da metric view (prompt 5)
```

## Regras

- **Um arquivo por assunto**: `01-projetos.sql`, `02-tarefas.sql`… O nome do arquivo
  é a ordem em que a pessoa lê, não a ordem de execução — no pipeline declarativo quem
  manda é o grafo de dependências do `FROM`.
- **Pastas vazias não viajam no git.** Esta pasta só é versionada quando recebe o
  primeiro arquivo. `silver/` e `gold/` não têm `.gitkeep` de propósito: o pipeline
  carrega todo arquivo da pasta (glob `**`), e um placeholder quebraria a leitura.
- **Caminho completo só na entrada**: dentro do pipeline, referencie as tabelas do
  próprio pipeline pelo nome (`projetos`, `tarefas`); leia a bronze pelo nome completo
  (`lakehouse_vertice.bronze.<tabela>`).
- **Sem segredo em arquivo**: credenciais vêm do secret scope `vertice` do workspace ou
  parâmetros de ambiente.

## Arquitetura em 3 Níveis

O projeto adota uma arquitetura modular em 3 níveis:

### 1. Nível 3: Jobs Atômicos / Individuais
- `vertice_bronze_api`: Ingestão isolada dos feriados nacionais.
- `vertice_bronze_datalake`: Ingestão isolada do S3 (9 tabelas brutas).
- `vertice_validacao_bronze`: Conferência SQL de contagens da Bronze.
- `vertice_testes_qualidade`: Execução isolada dos 10 testes de qualidade automatizados.

### 2. Nível 2: Orquestradores por Camada (Desacoplados)
- `vertice_camada_bronze`: Encadeia API -> Data Lake -> Validação.
- `vertice_camada_silver`: Pipeline DLT exclusivo da camada Silver (`src/silver/**`).
- `vertice_camada_gold`: Pipeline DLT exclusivo da camada Gold (`src/gold/**`).

### 3. Nível 1: Orquestrador Mestre Geral
- `vertice_farol`: Encadeia a esteira completa em sequência estrita (sem concorrência de máquinas):
  `camada_bronze` -> `camada_silver` -> `camada_gold` -> `testes_de_qualidade`.
