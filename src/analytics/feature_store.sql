-- Active: 1760406591313@@127.0.0.1@3306
WITH
"DailyTransactions" AS (
SELECT 
    "IdCliente" AS "ClientId"
    ,date("DtCriacao") AS "DtDay"
    ,"IdTransacao" AS "TransactionId"
    ,"QtdePontos" AS "QtyPoints"
FROM
    transacoes
WHERE
    date("DtCriacao") <= '2025-09-30'
),
"ClientsAggMetrics" AS (
SELECT
    "ClientId"
    ,COUNT("TransactionId") AS "LifetimeQtyTransactions"
    ,COUNT("TransactionId") FILTER (WHERE "DtDay" > date('2025-09-30', '-7 days')) AS "Past7DaysQtyTransactions"
    ,COUNT("TransactionId") FILTER (WHERE "DtDay" > date('2025-09-30', '-14 days')) AS "Past14DaysQtyTransactions"
    ,COUNT("TransactionId") FILTER (WHERE "DtDay" > date('2025-09-30', '-28 days')) AS "Past28DaysQtyTransactions"
    ,COUNT("TransactionId") FILTER (WHERE "DtDay" > date('2025-09-30', '-56 days')) AS "Past56DaysQtyTransactions"
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
FROM
    "DailyTransactions"    
GROUP BY
    "ClientId"
)
SELECT
    *
FROM
    "ClientsAggMetrics";