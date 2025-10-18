-- CUSTOMER LIFECYCLE STAGES
/*
01-CURIOUS --> (DaysSinceFirstInteraction < 7)
02-LOYAL --> (DaysSinceLastInteraction < 7 AND DaysSinceSecondToLastInteraction < 15)
03-NOMAD --> (7 <= DaysSinceLastInteraction < 15)
04-DISCOURAGED --> (15 <= DaysSinceLastInteraction < 28)
05-ASLEEP --> (DaysSinceLastInteraction >= 28)
02-OVERCOMER --> (DaysSinceLastInteraction < 7 AND 15 <= DaysSinceSecondToLastInteraction < 28) ///////// Started to interact coming from 04-DISCOURAGED
02-AWAKENED --> (DaysSinceLastInteraction < 7 AND DaysSinceSecondToLastInteraction >= 28) ///////// Started to interact coming from 05-ASLEEP
*/

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
"DailyInteractions" AS(
SELECT DISTINCT
    date("DtCriacao") AS "DtDay"
    ,"IdCliente" AS "ClientId"
FROM
    transacoes
WHERE
    date("DtCriacao") BETWEEN date('2025-08-31', '-27 days') AND date('2025-08-31')
),
"ClientsFirstAndLastInteractions" AS(
SELECT
    "ClientId"
    ,MIN("DtDay") AS "DtFirstInteraction"
    ,(julianday('2025-08-31') - julianday(MIN("DtDay"))) AS "DaysSinceFirstInteraction"
    ,MAX("DtDay") AS "DtLastInteraction"
    ,(julianday('2025-08-31') - julianday(MAX("DtDay"))) AS "DaysSinceLastInteraction"
FROM
    "DailyInteractions"
GROUP BY
    "ClientId"
),
"ClientsOrderedInteractions" AS (
SELECT
    "ClientId"
    ,"DtDay"
    ,ROW_NUMBER() OVER(PARTITION BY "ClientId" ORDER BY "DtDay" DESC) AS "RnInteraction"
FROM
    "DailyInteractions"    
),
"ClientsSecondToLastInteractions" AS(
SELECT
    "ClientId"
    ,"RnInteraction"
    ,"DtDay" AS "DtSecondToLastInteraction"
    ,(julianday('2025-08-31') - julianday("DtDay")) AS "DaysSinceSecondToLastInteraction"
FROM
    "ClientsOrderedInteractions"
WHERE
    "RnInteraction" = 2
),
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
"ClientsInteractionsMetrics" AS (
SELECT
    "ClientsFirstAndLastInteractions"."ClientId"
    ,"ClientsFirstAndLastInteractions"."DaysSinceFirstInteraction"
    ,"ClientsFirstAndLastInteractions"."DaysSinceLastInteraction"
    ,"ClientsSecondToLastInteractions"."DaysSinceSecondToLastInteraction"
    ,"ClietsFrequencyAndValue"."Frequency"
    ,"ClietsFrequencyAndValue"."Value"
FROM
    "ClientsFirstAndLastInteractions"
LEFT JOIN "ClientsSecondToLastInteractions" ON("ClientsFirstAndLastInteractions"."ClientId" = "ClientsSecondToLastInteractions"."ClientId")
LEFT JOIN "ClietsFrequencyAndValue" ON("ClientsFirstAndLastInteractions"."ClientId" = "ClietsFrequencyAndValue"."ClientId")
)
SELECT
    "ClientId"
    ,"DaysSinceLastInteraction" AS "Recency"
    ,"Frequency"
    ,"Value"
    ,"DaysSinceFirstInteraction"
    ,"DaysSinceSecondToLastInteraction"
    ,(CASE 
        WHEN ("DaysSinceFirstInteraction" < 7) THEN '01-CURIOUS'
        WHEN ("DaysSinceLastInteraction" < 7) AND ("DaysSinceSecondToLastInteraction" - "DaysSinceLastInteraction" < 15) THEN '02-LOYAL'
        WHEN ("DaysSinceLastInteraction" BETWEEN 7 AND 14) THEN '03-NOMAD'
        WHEN ("DaysSinceLastInteraction" BETWEEN 15 AND 27) THEN '04-DISCOURAGED'
        WHEN ("DaysSinceLastInteraction" >= 28) THEN '05-ASLEEP'
        WHEN ("DaysSinceLastInteraction" < 7) AND ("DaysSinceSecondToLastInteraction" - "DaysSinceLastInteraction" BETWEEN 15 AND 27) THEN '02-OVERCOMER'
        WHEN ("DaysSinceLastInteraction" < 7) AND ("DaysSinceSecondToLastInteraction" - "DaysSinceLastInteraction" >= 28) THEN '02-AWAKENED'
    END) AS "LifeCycleStage"
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
    "ClientsInteractionsMetrics";