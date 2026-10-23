-- Conferência da classificação do Prompt 04 (IA nos Status)
SELECT metodo, COUNT(*) AS total
FROM lakehouse_vertice.gold.status_estruturado
GROUP BY 1
ORDER BY 1;

-- Pergunta de negócio: Por que o PRJ-011 atrasou?
SELECT causa_bloqueio, COUNT(*) AS semanas, SUM(coalesce(dias_impacto, 0)) AS dias_de_impacto
FROM lakehouse_vertice.gold.status_estruturado
WHERE projeto_id = 'PRJ-011' AND data_status >= DATE'2026-07-18'
  AND causa_bloqueio NOT IN ('sem_bloqueio', 'nao_reportado')
GROUP BY 1
ORDER BY 2 DESC;
