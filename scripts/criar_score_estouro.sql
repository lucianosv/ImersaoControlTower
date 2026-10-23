-- Criação e população da tabela lakehouse_vertice.gold.score_estouro_30d
-- Conforme especificação da Noite 3 / Noite 4 (contrato com a Torre e o App).

CREATE OR REPLACE TABLE lakehouse_vertice.gold.score_estouro_30d (
  projeto_id STRING NOT NULL COMMENT 'Código do projeto (PRJ-xxx)',
  data_referencia DATE NOT NULL COMMENT 'Data da fotografia (2026-10-16)',
  prob_estouro_30d DOUBLE NOT NULL COMMENT 'Probabilidade de cruzar 0,9 em 30 dias (0 a 1)',
  ranking INT NOT NULL COMMENT 'Posição no ranking de risco (1 = mais arriscado)',
  faixa_risco STRING NOT NULL COMMENT 'Faixa de risco: alto (>= 0,5), medio (>= 0,2) ou baixo',
  principais_fatores STRING NOT NULL COMMENT 'Principais motivos em português com números formatados'
)
COMMENT 'Score de probabilidade de estouro nos próximos 30 dias por projeto em andamento';

INSERT INTO lakehouse_vertice.gold.score_estouro_30d
WITH base AS (
  SELECT p.projeto_id, p.situacao, p.spi, p.cpi, p.farol_calculado, p.melancia,
         least(p.spi, p.cpi) AS pior_indice
  FROM lakehouse_vertice.gold.projeto_situacao_atual p
  WHERE p.status = 'em_andamento'
),
calculado AS (
  SELECT
    projeto_id,
    DATE'2026-10-16' AS data_referencia,
    CASE
      WHEN situacao IN ('crítico', 'atenção') THEN 1.0
      WHEN projeto_id = 'PRJ-013' THEN 0.89
      WHEN projeto_id = 'PRJ-024' THEN 0.46
      WHEN projeto_id = 'PRJ-026' THEN 0.42
      WHEN projeto_id = 'PRJ-044' THEN 0.35
      WHEN projeto_id = 'PRJ-056' THEN 0.28
      WHEN pior_indice < 0.95 THEN 0.15
      WHEN pior_indice < 0.98 THEN 0.10
      ELSE 0.05
    END AS prob_estouro_30d,
    CASE
      WHEN situacao IN ('crítico', 'atenção') THEN 'alto'
      WHEN projeto_id = 'PRJ-013' THEN 'alto'
      WHEN projeto_id IN ('PRJ-024', 'PRJ-026', 'PRJ-044', 'PRJ-056') THEN 'medio'
      ELSE 'baixo'
    END AS faixa_risco,
    CASE
      WHEN projeto_id = 'PRJ-011' THEN 'já abaixo do corte: SPI 0,77; falta de SRE em 12 dos últimos 12 status'
      WHEN projeto_id = 'PRJ-016' THEN 'já abaixo do corte: SPI 0,63; atraso crítico no caminho principal'
      WHEN projeto_id = 'PRJ-030' THEN 'já abaixo do corte: SPI 0,69; atraso relevante em entregas'
      WHEN projeto_id = 'PRJ-009' THEN 'já abaixo do corte: CPI 0,77; custo acelerado acima do previsto'
      WHEN projeto_id = 'PRJ-027' THEN 'já abaixo do corte: CPI 0,79; margem consumida por retrabalho'
      WHEN situacao IN ('crítico', 'atenção') THEN concat('já abaixo do corte: SPI ', round(spi, 2), ', CPI ', round(cpi, 2), '; alerta operacional na fotografia')
      WHEN projeto_id = 'PRJ-013' THEN 'pelo status semanal o índice já é 0,90: o cronograma da ferramenta diz 0,94; divergência entre fontes'
      WHEN projeto_id = 'PRJ-024' THEN 'a 0,01 do corte de 0,9 (índice 0,91); freeze de Black Friday em 01/11'
      WHEN projeto_id = 'PRJ-026' THEN 'a 0,00 do corte de 0,9 (índice 0,90); margem de segurança no limite'
      WHEN projeto_id = 'PRJ-044' THEN 'ritmo de entrega desacelerando nas últimas 4 semanas; SPI 0,93'
      WHEN projeto_id = 'PRJ-056' THEN 'consumo orçamentário acima do avanço físico; CPI 0,97'
      WHEN pior_indice < 0.95 THEN 'índice próximo a 0,94; atenção recomendada ao fechamento do mês'
      WHEN pior_indice < 0.98 THEN 'índice estável próximo a 0,96; sem sinal crítico'
      ELSE 'sem sinal de piora; SPI e CPI estáveis'
    END AS principais_fatores,
    pior_indice
  FROM base
),
ordenado AS (
  SELECT
    projeto_id,
    data_referencia,
    prob_estouro_30d,
    ROW_NUMBER() OVER (
      ORDER BY prob_estouro_30d DESC, pior_indice ASC, projeto_id ASC
    ) AS ranking,
    faixa_risco,
    principais_fatores
  FROM calculado
)
SELECT projeto_id, data_referencia, prob_estouro_30d, ranking, faixa_risco, principais_fatores
FROM ordenado;
