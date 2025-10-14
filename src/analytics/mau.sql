SELECT
    date(transacoes."DtCriacao", 'start of month') AS "DtMonth"
    ,COUNT(DISTINCT transacoes."IdCliente") AS "MAU"
FROM
    transacoes
GROUP BY
    1
ORDER BY
    1;