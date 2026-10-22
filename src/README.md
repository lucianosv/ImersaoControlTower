# src — o código que o bundle publica

Uma pasta por camada (ou por tipo de tarefa). O `databricks bundle deploy` copia
esta árvore para o workspace; os jobs não dependem de nada digitado à mão lá.

```
src/
├── conferencia/  00-conferencia-bronze.sql   sql_task do vertice_validacao_bronze
├── silver/       *.sql                       pipeline vertice_medalhao (prompt 2)
├── gold/         *.sql                       o mesmo pipeline, schema gold (prompt 3)
├── testes/       testes.sql                  sql_task dos testes de qualidade (prompt 3)
├── ia/           status_estruturado.sql      sql_task da IA nos status (prompt 4)
└── metricas/     metricas.sql                sql_task da metric view (prompt 5)
```

## Regras

- **Um arquivo por assunto**: `01-projetos.sql`, `02-tarefas.sql`… O nome do arquivo
  é a ordem em que a pessoa lê, não a ordem de execução — no pipeline declarativo quem
  manda é o `FROM`.
- **Pastas vazias não viajam no git.** Esta pasta só é versionada quando recebe o
  primeiro arquivo. `silver/` e `gold/` não têm `.gitkeep` de propósito: o pipeline
  carrega todo arquivo da pasta (glob `**`), e um placeholder quebraria a leitura.
- **Caminho completo só na entrada**: dentro do pipeline, referencie as tabelas do
  próprio pipeline pelo nome (`projetos`, `tarefas`); leia a bronze pelo nome completo
  (`lakehouse_vertice.bronze.<tabela>`).
- **Sem segredo em arquivo**: credenciais vêm do secret scope `vertice` do workspace.

## Job por camada

`vertice_farol` não executa SQL: ele orquestra um job por camada, com `run_job_task`.

```
vertice_farol
├── ingestao_bronze     → job vertice_ingestao_bronze
├── validacao_bronze    → job vertice_validacao_bronze
└── medalhao            → job vertice_medalhao (o job da camada silver/gold)
```

Cada camada nova ganha o seu job e uma task no orquestrador. O `pipeline_task` fica
dentro do job da camada (`vertice_medalhao`), não no orquestrador.
