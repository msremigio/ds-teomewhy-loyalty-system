WITH
"UsersCompletedEpsodes" AS (
SELECT
    "idUsuario" AS "UserId"
    ,"descSlugCurso" AS "CourseName"
    ,COUNT(1) AS "CompletedEpsodes"
FROM
    cursos_episodios_completos
WHERE
    date("dtCriacao") <= '2025-09-30'
GROUP BY
    "idUsuario"
    ,"descSlugCurso"
),
"CourseNames" AS (
SELECT DISTINCT
    "descSlugCurso" AS "CourseName"
FROM
    cursos
),
"CourseNumEpsodes" AS (
SELECT
    "descSlugCurso" AS "CourseName"
    ,COUNT(1) AS "NumEpsodes"
FROM
    cursos_episodios
GROUP BY
    "descSlugCurso"
),
"UsersLastInteractions" AS (
SELECT
    "idUsuario" AS "UserId"
    ,date(MAX("dtCriacao")) AS "DtDay"
FROM
    cursos_episodios_completos
WHERE
    date("dtCriacao") <= '2025-09-30'
GROUP BY
    "idUsuario"
UNION ALL
SELECT
    "idUsuario" AS "UserId"
    ,date(MAX("dtCriacao")) AS "DtDay"
FROM
    habilidades_usuarios
WHERE
    date("dtCriacao") <= '2025-09-30'
GROUP BY
    "idUsuario"
UNION ALL
SELECT
    "idUsuario" AS "UserId"
    ,date(MAX("dtRecompensa")) AS "DtDay"
FROM
    recompensas_usuarios
WHERE
    date("dtRecompensa") <= '2025-09-30'    
GROUP BY
    "idUsuario"
),
"UsersEducationPlatformRecency" AS (
SELECT
    "UserId"
    ,MIN(julianday('2025-09-30') - julianday("DtDay")) AS "EducationPlatformRecency"
FROM
    "UsersLastInteractions"
GROUP BY
    "UserId"
),
"UsersCoursesProgress" AS (
SELECT
    "UserId"
    ,COUNT(DISTINCT "UsersCompletedEpsodes"."CourseName") AS "QtyEnrolledCourses"
    ,SUM(CASE WHEN "CompletedEpsodes" = "NumEpsodes" THEN 1 ELSE 0 END) AS "QtyCompletedCourses"
    ,SUM(CASE WHEN "CompletedEpsodes" < "NumEpsodes" THEN 1 ELSE 0 END) AS "QtyIncompletedCourses"
    ,SUM(CASE WHEN "UsersCompletedEpsodes"."CourseName" = 'carreira' THEN 1.0 * "CompletedEpsodes"/"NumEpsodes" ELSE 0.0 END) AS "CourseCarreiraCompletionProp"
    ,SUM(CASE WHEN "UsersCompletedEpsodes"."CourseName" = 'coleta-dados-2024' THEN 1.0 * "CompletedEpsodes"/"NumEpsodes" ELSE 0.0 END) AS "CourseColetaDados2024CompletionProp"
    ,SUM(CASE WHEN "UsersCompletedEpsodes"."CourseName" = 'ds-databricks-2024' THEN 1.0 * "CompletedEpsodes"/"NumEpsodes" ELSE 0.0 END) AS "CourseDatabricks2024CompletionProp"
    ,SUM(CASE WHEN "UsersCompletedEpsodes"."CourseName" = 'ds-pontos-2024' THEN 1.0 * "CompletedEpsodes"/"NumEpsodes" ELSE 0.0 END) AS "CoursePontos2024CompletionProp"
    ,SUM(CASE WHEN "UsersCompletedEpsodes"."CourseName" = 'estatistica-2024' THEN 1.0 * "CompletedEpsodes"/"NumEpsodes" ELSE 0.0 END) AS "CourseEstatistica2024CompletionProp"
    ,SUM(CASE WHEN "UsersCompletedEpsodes"."CourseName" = 'estatistica-2025' THEN 1.0 * "CompletedEpsodes"/"NumEpsodes" ELSE 0.0 END) AS "CourseEstatistica2025CompletionProp"
    ,SUM(CASE WHEN "UsersCompletedEpsodes"."CourseName" = 'github-2024' THEN 1.0 * "CompletedEpsodes"/"NumEpsodes" ELSE 0.0 END) AS "CourseGithub2024CompletionProp"
    ,SUM(CASE WHEN "UsersCompletedEpsodes"."CourseName" = 'github-2025' THEN 1.0 * "CompletedEpsodes"/"NumEpsodes" ELSE 0.0 END) AS "CourseGithub2025CompletionProp"
    ,SUM(CASE WHEN "UsersCompletedEpsodes"."CourseName" = 'ia-canal-2025' THEN 1.0 * "CompletedEpsodes"/"NumEpsodes" ELSE 0.0 END) AS "CourseCanal2025CompletionProp"
    ,SUM(CASE WHEN "UsersCompletedEpsodes"."CourseName" = 'lago-mago-2024' THEN 1.0 * "CompletedEpsodes"/"NumEpsodes" ELSE 0.0 END) AS "CourseLagoMago2024CompletionProp"
    ,SUM(CASE WHEN "UsersCompletedEpsodes"."CourseName" = 'machine-learning-2025' THEN 1.0 * "CompletedEpsodes"/"NumEpsodes" ELSE 0.0 END) AS "CourseMachineLearning2025CompletionProp"
    ,SUM(CASE WHEN "UsersCompletedEpsodes"."CourseName" = 'matchmaking-trampar-de-casa-2024' THEN 1.0 * "CompletedEpsodes"/"NumEpsodes" ELSE 0.0 END) AS "CourseTramparCasa2024CompletionProp"
    ,SUM(CASE WHEN "UsersCompletedEpsodes"."CourseName" = 'ml-2024' THEN 1.0 * "CompletedEpsodes"/"NumEpsodes" ELSE 0.0 END) AS "CourseML2024CompletionProp"
    ,SUM(CASE WHEN "UsersCompletedEpsodes"."CourseName" = 'mlflow-2025' THEN 1.0 * "CompletedEpsodes"/"NumEpsodes" ELSE 0.0 END) AS "CourseMLFlow2025CompletionProp"
    ,SUM(CASE WHEN "UsersCompletedEpsodes"."CourseName" = 'pandas-2024' THEN 1.0 * "CompletedEpsodes"/"NumEpsodes" ELSE 0.0 END) AS "CoursePandas2024CompletionProp"
    ,SUM(CASE WHEN "UsersCompletedEpsodes"."CourseName" = 'pandas-2025' THEN 1.0 * "CompletedEpsodes"/"NumEpsodes" ELSE 0.0 END) AS "CoursePandas2025CompletionProp"
    ,SUM(CASE WHEN "UsersCompletedEpsodes"."CourseName" = 'python-2024' THEN 1.0 * "CompletedEpsodes"/"NumEpsodes" ELSE 0.0 END) AS "CoursePython2024CompletionProp"
    ,SUM(CASE WHEN "UsersCompletedEpsodes"."CourseName" = 'python-2025' THEN 1.0 * "CompletedEpsodes"/"NumEpsodes" ELSE 0.0 END) AS "CoursePython2025CompletionProp"
    ,SUM(CASE WHEN "UsersCompletedEpsodes"."CourseName" = 'sql-2020' THEN 1.0 * "CompletedEpsodes"/"NumEpsodes" ELSE 0.0 END) AS "CourseSQL2020CompletionProp"
    ,SUM(CASE WHEN "UsersCompletedEpsodes"."CourseName" = 'sql-2025' THEN 1.0 * "CompletedEpsodes"/"NumEpsodes" ELSE 0.0 END) AS "CourseSQL2025CompletionProp"
    ,SUM(CASE WHEN "UsersCompletedEpsodes"."CourseName" = 'streamlit-2025' THEN 1.0 * "CompletedEpsodes"/"NumEpsodes" ELSE 0.0 END) AS "CourseStreamlit2025CompletionProp"
    ,SUM(CASE WHEN "UsersCompletedEpsodes"."CourseName" = 'trampar-lakehouse-2024' THEN 1.0 * "CompletedEpsodes"/"NumEpsodes" ELSE 0.0 END) AS "CourseLakeHouse2024CompletionProp"
    ,SUM(CASE WHEN "UsersCompletedEpsodes"."CourseName" = 'tse-analytics-2024' THEN 1.0 * "CompletedEpsodes"/"NumEpsodes" ELSE 0.0 END) AS "CourseTseAnalytics2024CompletionProp"
FROM
    "UsersCompletedEpsodes"
LEFT JOIN "CourseNumEpsodes" ON ("UsersCompletedEpsodes"."CourseName" = "CourseNumEpsodes"."CourseName")
GROUP BY
    "UserId"
),
"FinalResult" AS(
SELECT
    "idTMWCliente" AS "ClientId"
    ,"UsersCoursesProgress".*
    ,"UsersEducationPlatformRecency"."EducationPlatformRecency"
FROM
    "UsersCoursesProgress"
LEFT JOIN "UsersEducationPlatformRecency" ON ("UsersCoursesProgress"."UserId" = "UsersEducationPlatformRecency"."UserId")
INNER JOIN usuarios_tmw ON ("UsersCoursesProgress"."UserId" = usuarios_tmw."idUsuario")
)
SELECT
    date('2025-09-30') AS "DtRef"
    ,*
FROM
    "FinalResult";