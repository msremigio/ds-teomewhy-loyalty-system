-- CUSTOMER FREQUENCY VALUE CLUSTERS
/*
01-VOLATILE --> (Frequency <= 5 AND Value <= 500)
02-LURKER --> (Frequency > 5 AND Value <= 500)
03-HESITANT --> (Frequency < 8 AND Value > 500)
04-PUPIL --> (8 <= Frequency <= 15 AND Value > 500)
05-SUPPORTER --> (Frequency > 15 AND Value > 500)
06-HYPEBEAST --> (Frequency <= 15 AND Value >= 1500)
07-FANATIC --> (Frequency > 15 AND Value >= 1500)
*/

WITH
"ClietsFrequencyAndValue" AS (
SELECT
    "IdCliente" AS "ClientId"
    ,COUNT(DISTINCT date("DtCriacao")) AS "Frequency"
    ,SUM("QtdePontos") FILTER (WHERE "QtdePontos" > 0) AS "Value"
FROM
    transacoes
WHERE
    date("DtCriacao") BETWEEN date('2025-08-31', '-27 days') AND date('2025-08-31')
GROUP BY
    1
),
"ClientsEngagementMetrics" AS (
SELECT
    "ClientId"
    ,"Frequency"
    ,"Value"
    ,(CASE 
        WHEN "Frequency" > 15 AND "Value" >= 1500 THEN '21-FANATIC' 
        WHEN "Frequency" > 15 AND "Value" > 500 THEN '20-SUPPORTER' 
        WHEN "Frequency" > 5 AND "Value" <= 500 THEN '11-LURKER'
        WHEN "Frequency" <= 15 AND "Value" >= 1500 THEN '10-HYPEBEAST'  
        WHEN "Frequency" < 8 AND "Value" > 500 THEN '02-HESITANT' 
        WHEN "Frequency" <= 5 AND "Value" <= 500 THEN '01-VOLATILE'
        WHEN ("Frequency" BETWEEN 8 AND 15) AND "Value" > 500 THEN '12-PUPIL' 
    END) AS "FrequencyValueCluster"
FROM
    "ClietsFrequencyAndValue"
)
SELECT
    *
FROM
    "ClientsEngagementMetrics"
ORDER BY
    "Frequency" ASC
    ,"Value" DESC;