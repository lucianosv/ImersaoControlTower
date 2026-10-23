-- Conferência da Metric View lakehouse_vertice.gold.mv_projetos
SELECT MEASURE(spi) AS spi,
       MEASURE(cpi) AS cpi,
       MEASURE(estouro_previsto) AS estouro,
       MEASURE(projetos_criticos) AS criticos,
       MEASURE(projetos_melancia) AS melancias
FROM lakehouse_vertice.gold.mv_projetos;

-- Abertura por ferramenta (Excel, ClickUp, MS Project)
SELECT ferramenta,
       MEASURE(spi) AS spi,
       MEASURE(projetos_em_risco) AS em_risco
FROM lakehouse_vertice.gold.mv_projetos
GROUP BY ferramenta
ORDER BY spi;
