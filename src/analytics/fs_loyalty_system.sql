-- Active: 1760406591313@@127.0.0.1@3306
WITH
"DailyInteractions" AS (
SELECT 
    "IdCliente" AS "ClientId"
    ,date("DtCriacao") AS "DtDay"
    ,CAST(strftime('%H', "DtCriacao", 'localtime') AS INTEGER) AS "DtTime"
    ,CAST(strftime('%u', "DtCriacao") AS INTEGER) AS "DtWeekday"
    ,"IdTransacao" AS "TransactionId"
    ,"QtdePontos" AS "QtyPoints"
FROM
    transacoes
WHERE
    date("DtCriacao") <= '2025-09-30'
),
"DailyFrequency" AS (
SELECT DISTINCT
    "ClientId"
    ,"DtDay"
FROM
    "DailyInteractions"
),
"LagDailyFrequency" AS (
SELECT
    "ClientId"
    ,"DtDay"
    ,LAG("DtDay") OVER(PARTITION BY "ClientId" ORDER BY "DtDay") AS "LagDtDay"
FROM
    "DailyFrequency"
),
"FrequencyInterval" AS (
SELECT
    "ClientId"
    ,AVG(julianday("DtDay") - julianday("LagDtDay")) AS "AvgFrequencyInterval"
    ,AVG(julianday("DtDay") - julianday("LagDtDay")) FILTER (WHERE "DtDay" > date('2025-09-30', '-28 days')) AS "Past28DaysAvgFrequencyInterval"
FROM
    "LagDailyFrequency"
GROUP BY
    "ClientId"
),
"ClientsLifetime" AS (
SELECT
    "idCliente" AS "ClientId"
    ,date("DtCriacao") AS "DtCreated"
FROM
    clientes
WHERE
    date("DtCriacao") <= '2025-09-30'
),
"InteractionCategories" AS (
SELECT
    "ClientId"
    ,SUM(CASE WHEN "DescCategoriaProduto" = 'chat' THEN 1 ELSE 0 END) AS "QtyInteractionsChat"
    ,SUM(CASE WHEN "DescCategoriaProduto" = 'churn_model' THEN 1 ELSE 0 END) AS "QtyInteractionsChurnModel"
    ,SUM(CASE WHEN "DescCategoriaProduto" = 'food' THEN 1 ELSE 0 END) AS "QtyInteractionsFood"
    ,SUM(CASE WHEN "DescCategoriaProduto" = 'lovers' THEN 1 ELSE 0 END) AS "QtyInteractionsLovers"
    ,SUM(CASE WHEN "DescCategoriaProduto" = 'ponei' THEN 1 ELSE 0 END) AS "QtyInteractionsPonei"
    ,SUM(CASE WHEN "DescCategoriaProduto" = 'present' THEN 1 ELSE 0 END) AS "QtyInteractionsPresent"
    ,SUM(CASE WHEN "DescCategoriaProduto" = 'rpg' THEN 1 ELSE 0 END) AS "QtyInteractionsRPG"
    ,SUM(CASE WHEN "DescCategoriaProduto" = 'streamelements' THEN 1 ELSE 0 END) AS "QtyInteractionsStreamElements"
    ,SUM(CASE WHEN "DescCategoriaProduto" = 'chat' THEN 1.0 ELSE 0 END)/COUNT("TransactionId") AS "InteractionsChatProp"
    ,SUM(CASE WHEN "DescCategoriaProduto" = 'churn_model' THEN 1.0 ELSE 0 END)/COUNT("TransactionId") AS "InteractionsChurnModelProp"
    ,SUM(CASE WHEN "DescCategoriaProduto" = 'food' THEN 1.0 ELSE 0 END)/COUNT("TransactionId") AS "InteractionsFoodProp"
    ,SUM(CASE WHEN "DescCategoriaProduto" = 'lovers' THEN 1.0 ELSE 0 END)/COUNT("TransactionId") AS "InteractionsLoversProp"
    ,SUM(CASE WHEN "DescCategoriaProduto" = 'ponei' THEN 1.0 ELSE 0 END)/COUNT("TransactionId") AS "InteractionsPoneiProp"
    ,SUM(CASE WHEN "DescCategoriaProduto" = 'present' THEN 1.0 ELSE 0 END)/COUNT("TransactionId") AS "InteractionsPresentProp"
    ,SUM(CASE WHEN "DescCategoriaProduto" = 'rpg' THEN 1.0 ELSE 0 END)/COUNT("TransactionId") AS "InteractionsRPGProp"
    ,SUM(CASE WHEN "DescCategoriaProduto" = 'streamelements' THEN 1.0 ELSE 0 END)/COUNT("TransactionId") AS "InteractionsStreamElementsProp"
FROM
    "DailyInteractions"
LEFT JOIN transacao_produto ON ("DailyInteractions"."TransactionId" = transacao_produto."IdTransacao")
LEFT JOIN produtos ON (transacao_produto."IdProduto" = produtos."IdProduto")
GROUP BY
    "ClientId"
),
"ClientsAggMetrics" AS (
SELECT
    "ClientId"
    ,COUNT("TransactionId") AS "LifetimeQtyInteractions"
    ,COUNT("TransactionId") FILTER (WHERE "DtDay" > date('2025-09-30', '-7 days')) AS "Past7DaysQtyInteractions"
    ,COUNT("TransactionId") FILTER (WHERE "DtDay" > date('2025-09-30', '-14 days')) AS "Past14DaysQtyInteractions"
    ,COUNT("TransactionId") FILTER (WHERE "DtDay" > date('2025-09-30', '-28 days')) AS "Past28DaysQtyInteractions"
    ,COUNT("TransactionId") FILTER (WHERE "DtDay" > date('2025-09-30', '-56 days')) AS "Past56DaysQtyInteractions"
    ,MIN(julianday('2025-09-30') - julianday("DtDay")) AS "Recency"
    ,COUNT(DISTINCT "DtDay") AS "LifetimeFrequency"
    ,COUNT(DISTINCT "DtDay") FILTER (WHERE "DtDay" > date('2025-09-30', '-7 days')) AS "Past7DaysFrequency"
    ,COUNT(DISTINCT "DtDay") FILTER (WHERE "DtDay" > date('2025-09-30', '-14 days')) AS "Past14DaysFrequency"
    ,COUNT(DISTINCT "DtDay") FILTER (WHERE "DtDay" > date('2025-09-30', '-28 days')) AS "Past28DaysFrequency"
    ,COUNT(DISTINCT "DtDay") FILTER (WHERE "DtDay" > date('2025-09-30', '-56 days')) AS "Past56DaysFrequency"
    ,SUM(CASE WHEN "QtyPoints" > 0 THEN "QtyPoints" ELSE 0 END) AS "LifetimePosValue"
    ,SUM(CASE WHEN "DtDay" > date('2025-09-30', '-7 days') AND "QtyPoints" > 0 THEN "QtyPoints" ELSE 0 END) AS "Past7DaysPosValue"
    ,SUM(CASE WHEN "DtDay" > date('2025-09-30', '-14 days') AND "QtyPoints" > 0 THEN "QtyPoints" ELSE 0 END) AS "Past14DaysPosValue"
    ,SUM(CASE WHEN "DtDay" > date('2025-09-30', '-28 days') AND "QtyPoints" > 0 THEN "QtyPoints" ELSE 0 END) AS "Past28DaysPosValue"
    ,SUM(CASE WHEN "DtDay" > date('2025-09-30', '-56 days') AND "QtyPoints" > 0 THEN "QtyPoints" ELSE 0 END) AS "Past56DaysPosValue"
    ,SUM(CASE WHEN "QtyPoints" < 0 THEN "QtyPoints" ELSE 0 END) AS "LifetimeNegValue"
    ,SUM(CASE WHEN "DtDay" > date('2025-09-30', '-7 days') AND "QtyPoints" < 0 THEN "QtyPoints" ELSE 0 END) AS "Past7DaysNegValue"
    ,SUM(CASE WHEN "DtDay" > date('2025-09-30', '-14 days') AND "QtyPoints" < 0 THEN "QtyPoints" ELSE 0 END) AS "Past14DaysNegValue"
    ,SUM(CASE WHEN "DtDay" > date('2025-09-30', '-28 days') AND "QtyPoints" < 0 THEN "QtyPoints" ELSE 0 END) AS "Past28DaysNegValue"
    ,SUM(CASE WHEN "DtDay" > date('2025-09-30', '-56 days') AND "QtyPoints" < 0 THEN "QtyPoints" ELSE 0 END) AS "Past56DaysNegValue"
    ,SUM("QtyPoints") AS "LifetimeNetValue"
    ,SUM(CASE WHEN "DtDay" > date('2025-09-30', '-7 days') THEN "QtyPoints" ELSE 0 END) AS "Past7DaysNetValue"
    ,SUM(CASE WHEN "DtDay" > date('2025-09-30', '-14 days') THEN "QtyPoints" ELSE 0 END) AS "Past14DaysNetValue"
    ,SUM(CASE WHEN "DtDay" > date('2025-09-30', '-28 days') THEN "QtyPoints" ELSE 0 END) AS "Past28DaysNetValue"
    ,SUM(CASE WHEN "DtDay" > date('2025-09-30', '-56 days') THEN "QtyPoints" ELSE 0 END) AS "Past56DaysNetValue"
    ,SUM(CASE WHEN "DtTime" BETWEEN 7 AND 11 THEN 1 ELSE 0 END) AS "QtyMorningInteractions"
    ,SUM(CASE WHEN "DtTime" BETWEEN 12 AND 17 THEN 1 ELSE 0 END) AS "QtyEveningInteractions"
    ,SUM(CASE WHEN "DtTime" < 7 OR "DtTime" > 17 THEN 1 ELSE 0 END) AS "QtyNightInteractions"
    ,SUM(CASE WHEN "DtWeekday" BETWEEN 1 AND 5 THEN 1 ELSE 0 END) AS "QtyWeekInteractions"
    ,SUM(CASE WHEN "DtWeekday" > 5 THEN 1 ELSE 0 END) AS "QtyWeekendInteractions"
    ,SUM(CASE WHEN "DtWeekday" = 1 THEN 1 ELSE 0 END) AS "QtyMondayInteractions"
    ,SUM(CASE WHEN "DtWeekday" = 2 THEN 1 ELSE 0 END) AS "QtyTuesdayInteractions"
    ,SUM(CASE WHEN "DtWeekday" = 3 THEN 1 ELSE 0 END) AS "QtyWednesdayInteractions"
    ,SUM(CASE WHEN "DtWeekday" = 4 THEN 1 ELSE 0 END) AS "QtyThursdayInteractions"
    ,SUM(CASE WHEN "DtWeekday" = 5 THEN 1 ELSE 0 END) AS "QtyFridayInteractions"
    ,SUM(CASE WHEN "DtWeekday" = 6 THEN 1 ELSE 0 END) AS "QtySaturdayInteractions"
    ,SUM(CASE WHEN "DtWeekday" = 7 THEN 1 ELSE 0 END) AS "QtySundayInteractions"
FROM
    "DailyInteractions"    
GROUP BY
    "ClientId"
),
"ClientsProportionalMetrics" AS (
SELECT
    *
    ,(CAST("LifetimeQtyInteractions" AS FLOAT)/"LifetimeFrequency") AS "LifeTimeDailyInteractionsAvg"
    ,COALESCE(CAST("Past7DaysQtyInteractions" AS FLOAT)/"Past7DaysFrequency", 0) AS "Past7DaysInteractionsAvg"
    ,COALESCE(CAST("Past14DaysQtyInteractions" AS FLOAT)/"Past14DaysFrequency", 0) AS "Past14DaysInteractionsAvg"
    ,COALESCE(CAST("Past28DaysQtyInteractions" AS FLOAT)/"Past28DaysFrequency", 0) AS "Past28DaysInteractionsAvg"
    ,COALESCE(CAST("Past56DaysQtyInteractions" AS FLOAT)/"Past56DaysFrequency", 0) AS "Past56DaysInteractionsAvg"
    ,COALESCE("Past28DaysFrequency"/28.0, 0) AS "Past28DaysFrequencyAvg"
    ,(CAST("QtyMorningInteractions" AS FLOAT)/"LifetimeQtyInteractions") AS "MorningInteractionsProp"
    ,(CAST("QtyEveningInteractions" AS FLOAT)/"LifetimeQtyInteractions") AS "EveningInteractionsProp"
    ,(CAST("QtyNightInteractions" AS FLOAT)/"LifetimeQtyInteractions") AS "NightInteractionsProp"
    ,(CAST("QtyWeekInteractions" AS FLOAT)/"LifetimeQtyInteractions") AS "WeekInteractionsProp"
    ,(CAST("QtyWeekendInteractions" AS FLOAT)/"LifetimeQtyInteractions") AS "WeekendInteractionsProp"
    ,(CAST("QtyMondayInteractions" AS FLOAT)/"LifetimeQtyInteractions") AS "MondayInteractionsProp"
    ,(CAST("QtyTuesdayInteractions" AS FLOAT)/"LifetimeQtyInteractions") AS "TuesdayInteractionsProp"
    ,(CAST("QtyWednesdayInteractions" AS FLOAT)/"LifetimeQtyInteractions") AS "WednesdayInteractionsProp"
    ,(CAST("QtyThursdayInteractions" AS FLOAT)/"LifetimeQtyInteractions") AS "ThursdayInteractionsProp"
    ,(CAST("QtyFridayInteractions" AS FLOAT)/"LifetimeQtyInteractions") AS "FridayInteractionsProp"
    ,(CAST("QtySaturdayInteractions" AS FLOAT)/"LifetimeQtyInteractions") AS "SaturdayInteractionsProp"
    ,(CAST("QtySundayInteractions" AS FLOAT)/"LifetimeQtyInteractions") AS "SundayInteractionsProp"
FROM
    "ClientsAggMetrics"
),
"FinalResult" AS (
SELECT
    date('2025-09-30') AS "DtRef"
    ,"ClientsProportionalMetrics".*
    ,(julianday('2025-09-30') - julianday("DtCreated")) AS "LifetimeDays"
    ,"FrequencyInterval"."AvgFrequencyInterval"
    ,"FrequencyInterval"."Past28DaysAvgFrequencyInterval"
    ,"InteractionCategories"."QtyInteractionsChat"
    ,"InteractionCategories"."QtyInteractionsChurnModel"
    ,"InteractionCategories"."QtyInteractionsFood"
    ,"InteractionCategories"."QtyInteractionsLovers"
    ,"InteractionCategories"."QtyInteractionsPonei"
    ,"InteractionCategories"."QtyInteractionsPresent"
    ,"InteractionCategories"."QtyInteractionsRPG"
    ,"InteractionCategories"."QtyInteractionsStreamElements"
    ,"InteractionCategories"."InteractionsChatProp"
    ,"InteractionCategories"."InteractionsChurnModelProp"
    ,"InteractionCategories"."InteractionsFoodProp"
    ,"InteractionCategories"."InteractionsLoversProp"
    ,"InteractionCategories"."InteractionsPoneiProp"
    ,"InteractionCategories"."InteractionsPresentProp"
    ,"InteractionCategories"."InteractionsRPGProp"
    ,"InteractionCategories"."InteractionsStreamElementsProp"
FROM
    "ClientsProportionalMetrics"
LEFT JOIN "ClientsLifetime" ON ("ClientsProportionalMetrics"."ClientId" = "ClientsLifetime"."ClientId")
LEFT JOIN "FrequencyInterval" ON ("ClientsProportionalMetrics"."ClientId" = "FrequencyInterval"."ClientId")
LEFT JOIN "InteractionCategories" ON ("ClientsProportionalMetrics"."ClientId" = "InteractionCategories"."ClientId")
)
SELECT
    *
FROM
    "FinalResult";