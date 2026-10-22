## Task [1]: Criar estrutura de diretórios do bundle

**Description:** Criar os diretórios necessários para a organização do bundle vertice: resources/, src/conferencia/, src/silver/, src/gold/, src/ia/, src/metricas/, src/testes/, scripts/.

**Acceptance criteria:**
- [ ] Diretórios resources/ e src/ criado na raiz do repositório
- [ ] Subdiretórios conferencia/, silver/, gold/, ia/, metricas/, testes/ dentro de src/
- [ ] Diretório scripts/ criado na raiz

**Verification:**
- [ ] `dir /a` ou `ls -la` mostra todos os diretórios criados
- [ ] Nenhum erro ao listar a estrutura do repositório

**Dependencies:** None

**Files likely touched:**
- `tasks/todo.md` (marcar como concluído)
- (Nenhum arquivo de código ainda - apenas estrutura de pastas)

**Estimated scope:** XS - 1 task, criação de pastas

---

## Task [2]: Criar databricks.yml do bundle vertice

**Description:** Criar o arquivo `databricks.yml` na raiz do bundle com configuração do bundle name, variables (catalog, warehouse_id) e targets (dev/prod). Seguir as convenções do CLAUDE.md da noite 2.

**Acceptance criteria:**
- [ ] Arquivo `databricks.yml` criado na raiz do repositório
- [ ] bundle name: `vertice`
- [ ] variables: catalog (default lakehouse_vertice), warehouse_id (id descoberto via `databricks warehouses list`)
- [ ] targets: dev (default) e prod com configuração completa
- [ ] NÃO usar `mode: development` no target dev (usar presets: { trigger_pause_status: PAUSED })
- [ ] ARMADILHA comentada no YAML explicando o perigo do mode development

**Verification:**
- [ ] `databricks bundle validate --profile imersao-out26` passa sem erros
- [ ] YAML segue o schema esperado (nome no topo, include, variables, targets, resources)

**Dependencies:** Task 1 (pastas criadas)

**Files likely touched:**
- `databricks.yml` (novo arquivo)
- `tasks/todo.md`

**Estimated scope:** S - 1 file, 1 task

---

## Task [3]: Criar resources/vertice.job.yml

**Description:** Criar `resources/vertice.job.yml` com a configuração do job `vertice_farol`: agendamento toda segunda às 6h (America/Sao_Paulo), após status semanal, e uma tarefa inicial `conferencia_bronze`.

**Acceptance criteria:**
- [ ] Arquivo `resources/vertice.job.yml` criado
- [ ] Job nome: `vertice_farol`
- [ ] Agendamento: toda segunda às 6h (America/Sao_Paulo)
- [ ] Depende do status semanal de sexta
- [ ] Uma tarefa por enquanto: `conferencia_bronze` usando sql_task
- [ ] Comentário no topo listando tarefas que prompts adicionarão depois (medalhão, testes_de_qualidade, status_com_ia, metricas_governadas)

**Verification:**
- [ ] `databricks bundle deploy --profile imersao-out26` cria o job no workspace
- [ ] Job aparece no DAG do workspace
- [ ] URL do job exibido via `databricks bundle summary --profile imersao-out26`

**Dependencies:** Task 2 (databricks.yml criado)

**Files likely touched:**
- `resources/vertice.job.yml` (novo arquivo)
- `databricks.yml` (referenciado)
- `tasks/todo.md`

**Estimated scope:** S - 1 file, 1 task

---

## Task [4]: Criar src/conferencia/00-conferencia-bronze.sql

**Description:** Criar a SQL de conferência das 9 tabelas da bronze contra contagens esperadas (seed 42). Cada tabela deve ter uma linha com o esperado e o obtido; se divergir, chamar raise_error() com mensagem sobre qual tabela e o que fazer.

**Acceptance criteria:**
- [ ] SQL consulta todas as 9 tabelas do schema bronze: projetos, status_semanal, excel_tarefas, clickup_tarefas, msproject_tarefas, colaboradores, apontamentos, custos, entregas_fornecedor
- [ ] Cada tabela retorna uma linha com: nome_tabela, expected_count, obtained_count
- [ ] Se alguma tabela divergir, raise_error() com mensagem identificando a tabela e ação corretiva
- [ ] Contagens esperadas (seed 42): projetos 60, status_semanal 3911, excel_tarefas 1663, clickup_tarefas 2119, msproject_tarefas 1260, colaboradores 523, apontamentos 30883, custos 23640, entregas_fornecedor 640

**Verification:**
- [ ] Executar `databricks bundle run vertice_farol --profile imersao-out26` e verificar saída
- [ ] Todas as 9 tabelas retornam ok
- [ ] Testar alterando um número esperado (ex: projetos 61) - job deve falhar com mensagem da raise_error

**Dependencies:** Task 3 (resources/vertice.job.yml criado, que referencia o SQL)

**Files likely touched:**
- `src/conferencia/00-conferencia-bronze.sql` (novo arquivo)
- `resources/vertice.job.yml` (referencia o caminho ../src/conferencia/00-conferencia-bronze.sql)
- `databricks.yml` (aponta o warehouse_id)

**Estimated scope:** S - 1 file, 1 task

---

## Checkpoint: Foundation (After Tasks 1-4)

- [ ] Todos os diretórios estruturais criados
- [ ] databricks.yml validado sem erros
- [ ] Job vertice_farol deployado no workspace
- [ ] SQL de conferência pronto para execução

---

## Task [5]: Executar bundle run vertice_farol

**Description:** Executar o job vertice_farol via CLI para rodar a tarefa conferencia_bronze e conferir os resultados.

**Acceptance criteria:**
- [ ] Comando `databricks bundle run vertice_farol --profile imersao-out26` executa sem erros fatais
- [ ] Job roda no warehouse Serverless Starter (`666be37e3fededf2`)
- [ ] Tempo medido: run em ~40s (maior parte é warehouse acordando)

**Verification:**
- [ ] Saída do CLI mostra a tarefa executando
- [ ] Resultados exibidos no terminal (9 tabelas com expected vs obtained)

**Dependencies:** Task 4 (SQL de conferência criado), Task 3 (job configurado), Task 2 (bundle config), Task 1 (pastas)

**Files likely touched:**
- Nenhum arquivo modificado (apenas execução)
- `tasks/todo.md` (atualizar status)

**Estimated scope:** XS - execução de CLI, 1 task

---

## Task [6]: Verificar saída da conferência

**Description:** Verificar se a saída do run contém as 9 tabelas com os expected counts corretos (seed 42).

**Acceptance criteria:**
- [ ] Saída contém 9 linhas, uma por tabela
- [ ] Linhas com expected e obtained matching os valores da seed 42
- [ ] Todas as tabelas com status "ok"

**Verification:**
- [ ] Conferir manualmente cada linha da saída
- [ ] Comparar com valores esperados: projetos 60, status_semanal 3911, excel_tarefas 1663, clickup_tarefas 2119, msproject_tarefas 1260, colaboradores 523, apontamentos 30883, custos 23640, entregas_fornecedor 640

**Dependencies:** Task 5 (bundle run executado)

**Files likely touched:**
- Nenhum arquivo modificado
- `tasks/todo.md`

**Estimated scope:** XS - verificação de saída, 1 task

---

## Checkpoint: Core Features (After Tasks 5-6)

- [ ] Conferência de bronze funcionando com todas 9 tabelas
- [ ] Expected counts matching seed 42
- [ ] Job verde no DAG do workspace

---

## Task [7]: Testar que a conferência tem dente

**Description:** Testar a robustez da conferência alterando um número esperado e verificando que o job falha com a mensagem esperada.

**Acceptance criteria:**
- [ ] Alterar um número esperado no SQL (ex: `projetos 61` em vez de `60`)
- [ ] Fazer deploy novamente com `databricks bundle deploy --profile imersao-out26`
- [ ] Rodar `databricks bundle run vertice_farol --profile imersao-out26`
- [ ] Job falha com mensagem indicando divergência na tabela projetos
- [ ] Desfazer a alteração (restaurar `projetos 60`)

**Verification:**
- [ ] Mensagem de erro contém nome da tabela e informação de divergência
- [ ] Após restaurar valor 60, deploy e run bem-sucedidos novamente

**Dependencies:** Task 6 (verificação bem-sucedida), Task 4 (SQL base)

**Files likely touched:**
- `src/conferencia/00-conferencia-bronze.sql` (alterar temporariamente)
- `tasks/todo.md`

**Estimated scope:** S - teste de falha e recuperação, 1 task