-- Active: 1760406591313@@127.0.0.1@3306
SELECT
    date(transacoes."DtCriacao") AS "DtDay"
    ,COUNT(DISTINCT transacoes."IdCliente") AS "DAU"
FROM
    transacoes
GROUP BY
    1
ORDER BY
    1;