WITH
"DtReference" AS(
SELECT DISTINCT
    date(transacoes."DtCriacao") AS "DtRef"
FROM
    transacoes
),
"DailyInteractions" AS(
SELECT DISTINCT
    date(transacoes."DtCriacao") AS "DtDay"
    ,"IdCliente" AS "ClientId"
FROM
    transacoes
),
"28DaysInteractions" AS(
SELECT
    "DtReference"."DtRef"
    ,"DailyInteractions"."DtDay"
    ,"DailyInteractions"."ClientId"
FROM
    "DtReference"
LEFT JOIN "DailyInteractions" ON ("DtReference"."DtRef" >= "DailyInteractions"."DtDay" AND (julianday("DtReference"."DtRef") - julianday("DailyInteractions"."DtDay")) < 28)
)
SELECT 
    "DtRef"
    ,COUNT(DISTINCT "ClientId") AS "MAU28Days"
FROM
    "28DaysInteractions"
GROUP BY
    1
ORDER BY
    1;    