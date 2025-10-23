-- Active: 1755824425005@@127.0.0.1@3306
SELECT
    clients_lifecycle."DtRef"
    ,clients_lifecycle."ClientId"
    ,clients_lifecycle."DaysSinceLastInteraction" AS "Recency"
    ,clients_fv_clusters."Frequency"
    ,clients_fv_clusters."Value"
    ,clients_lifecycle."LifeCycleStage"
    ,clients_fv_clusters."FrequencyValueCluster"
FROM
    clients_lifecycle
LEFT JOIN clients_fv_clusters ON (clients_lifecycle."DtRef" = clients_fv_clusters."DtRef" AND clients_lifecycle."ClientId" = clients_fv_clusters."ClientId");



SELECT
    clients_lifecycle."DtRef"
    ,clients_lifecycle."LifeCycleStage"
    ,clients_fv_clusters."FrequencyValueCluster"
    ,COUNT(clients_lifecycle."ClientId") AS "NumClients"
FROM
    clients_lifecycle
LEFT JOIN clients_fv_clusters ON (clients_lifecycle."DtRef" = clients_fv_clusters."DtRef" AND clients_lifecycle."ClientId" = clients_fv_clusters."ClientId")
WHERE
    clients_lifecycle."LifeCycleStage" <> '05-ASLEEP'
GROUP BY
    clients_lifecycle."DtRef"
    ,clients_lifecycle."LifeCycleStage"
    ,clients_fv_clusters."FrequencyValueCluster"
ORDER BY
    clients_lifecycle."DtRef"
    ,clients_lifecycle."LifeCycleStage"
    ,clients_fv_clusters."FrequencyValueCluster"