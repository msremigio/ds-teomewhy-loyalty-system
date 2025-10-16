-- Active: 1760406591313@@127.0.0.1@3306

SELECT DISTINCT
    date("DtCriacao", 'start of month', '+1 month', '-1 day') AS "DtRef"
FROM
    transacoes
ORDER BY
    "DtRef";