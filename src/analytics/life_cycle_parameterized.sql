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

WITH
"DailyInteractions" AS(
SELECT DISTINCT
    date("DtCriacao") AS "DtDay"
    ,"IdCliente" AS "ClientId"
FROM
    transacoes
WHERE
    date("DtCriacao") <= '{date}'
),
"ClientsFirstAndLastInteractions" AS(
SELECT
    "ClientId"
    ,MIN("DtDay") AS "DtFirstInteraction"
    ,(julianday('{date}') - julianday(MIN("DtDay"))) AS "DaysSinceFirstInteraction"
    ,MAX("DtDay") AS "DtLastInteraction"
    ,(julianday('{date}') - julianday(MAX("DtDay"))) AS "DaysSinceLastInteraction"
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
    ,(julianday('{date}') - julianday("DtDay")) AS "DaysSinceSecondToLastInteraction"
FROM
    "ClientsOrderedInteractions"
WHERE
    "RnInteraction" = 2
),
"ClientsInteractionsMetrics" AS (
SELECT
    "ClientsFirstAndLastInteractions"."ClientId"
    ,"ClientsFirstAndLastInteractions"."DaysSinceFirstInteraction"
    ,"ClientsFirstAndLastInteractions"."DaysSinceLastInteraction"
    ,"ClientsSecondToLastInteractions"."DaysSinceSecondToLastInteraction"
FROM
    "ClientsFirstAndLastInteractions"
LEFT JOIN "ClientsSecondToLastInteractions" ON("ClientsFirstAndLastInteractions"."ClientId" = "ClientsSecondToLastInteractions"."ClientId")
)
SELECT
    date('{date}') AS "DtRef"
    ,"ClientId"
    ,"DaysSinceFirstInteraction"
    ,"DaysSinceLastInteraction"
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
FROM
    "ClientsInteractionsMetrics";