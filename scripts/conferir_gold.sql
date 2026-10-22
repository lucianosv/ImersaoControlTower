-- Conferência da Gold (Prompt 03)

SELECT situacao, COUNT(*) AS projetos, ROUND(SUM(estouro_previsto) / 1e6, 2) AS estouro_mi,
       COUNT_IF(melancia) AS melancias
FROM lakehouse_vertice.gold.projeto_situacao_atual 
GROUP BY situacao 
ORDER BY situacao;

SELECT 'estouro_em_andamento' AS kpi, ROUND(SUM(estouro_previsto) / 1e6, 2) AS valor_mi 
FROM lakehouse_vertice.gold.projeto_situacao_atual
WHERE status = 'em_andamento';

SELECT colaborador_id, nome, papel, projeto_id,
       ROUND(SUM(horas_apontadas) / SUM(horas_disponiveis), 3) AS utilizacao, SUM(horas_ociosas) AS horas_paradas
FROM lakehouse_vertice.gold.utilizacao_pessoa_semana
WHERE semana > DATE'2026-07-24'
GROUP BY ALL ORDER BY utilizacao LIMIT 5;
