-- Conferência da Camada Silver (Prompt 02)

-- 1. As três ferramentas num modelo só
SELECT ferramenta, COUNT(DISTINCT projeto_id) AS projetos, COUNT(*) AS tarefas
FROM lakehouse_vertice.silver.tarefas GROUP BY 1 ORDER BY 1;

-- 2. Custos: não mudou o custo da noite 1 (193,35 mi)
SELECT ROUND(SUM(valor) / 1e6, 2) AS total_custos_mi FROM lakehouse_vertice.silver.custos;

-- 3. Colaboradores: 520 deduplicados
SELECT COUNT(*) AS total_colaboradores, COUNT(DISTINCT colaborador_id) AS colaboradores_unicos FROM lakehouse_vertice.silver.colaboradores;

-- 4. Entregas Fornecedor: CodeForge normalizado
SELECT fornecedor, COUNT(DISTINCT fornecedor_como_veio) AS grafias_originais FROM lakehouse_vertice.silver.entregas_fornecedor
WHERE fornecedor LIKE 'CodeForge%' GROUP BY 1;

-- 5. Percentual acima de 100%
SELECT COUNT_IF(pct_veio_acima_de_100) AS tarefas_acima_de_100 FROM lakehouse_vertice.silver.tarefas;
