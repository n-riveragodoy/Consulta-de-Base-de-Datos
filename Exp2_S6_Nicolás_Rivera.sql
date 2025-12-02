-- Caso 1
SELECT
    p.id_profesional AS "ID",

    INITCAP(p.appaterno || ' ' || p.apmaterno || ' ' || p.nombre) AS "PROFESIONAL",

    b.nro_banca AS "NRO ASESORIA BANCA",

    TO_CHAR(b.monto_banca, '$99G999G999') AS "MONTO_TOTAL_BANCA",

    r.nro_retail AS "NRO ASESORIA RETAIL",

    TO_CHAR(r.monto_retail, '$99G999G999') AS "MONTO_TOTAL_RETAIL",

    (b.nro_banca + r.nro_retail) AS "TOTAL_ASESORIAS",

    TO_CHAR(b.monto_banca + r.monto_retail, '$99G999G999') AS "TOTAL_HONORARIOS"

FROM profesional p

JOIN (
        SELECT 
            a.id_profesional,
            COUNT(*) AS nro_banca,
            SUM(a.honorario) AS monto_banca
        FROM asesoria a
        JOIN empresa e ON a.cod_empresa = e.cod_empresa
        WHERE e.cod_sector = 3
        GROUP BY a.id_profesional
    ) b ON p.id_profesional = b.id_profesional

JOIN (
        SELECT 
            a.id_profesional,
            COUNT(*) AS nro_retail,
            SUM(a.honorario) AS monto_retail
        FROM asesoria a
        JOIN empresa e ON a.cod_empresa = e.cod_empresa
        WHERE e.cod_sector = 4
        GROUP BY a.id_profesional
    ) r ON p.id_profesional = r.id_profesional

WHERE p.id_profesional IN (
        SELECT id_profesional FROM (
            SELECT a.id_profesional
            FROM asesoria a
            JOIN empresa e ON a.cod_empresa = e.cod_empresa
            WHERE e.cod_sector = 3
            UNION
            SELECT a.id_profesional
            FROM asesoria a
            JOIN empresa e ON a.cod_empresa = e.cod_empresa
            WHERE e.cod_sector = 4
        )
    )

ORDER BY p.id_profesional;

-- Caso 2
CREATE TABLE REPORTE_MES AS
SELECT
    p.id_profesional AS "ID_PROF",

    INITCAP(p.appaterno || ' ' || p.apmaterno || ' ' || p.nombre) AS "NOMBRE_COMPLETO",

    INITCAP(pr.nombre_profesion) AS "NOMBRE_PROFESION",

    INITCAP(c.nom_comuna) AS "NOM_COMUNA",

    COUNT(*) AS "NRO_ASESORIAS",

    ROUND(SUM(a.honorario)) AS "MONTO_TOTAL_HONORARIOS",

    ROUND(AVG(a.honorario)) AS "PROMEDIO_HONORARIO",

    MIN(a.honorario) AS "HONORARIO_MINIMO",
    
    MAX(a.honorario) AS "HONORARIO_MAXIMO"

FROM profesional p
JOIN profesion pr ON p.cod_profesion = pr.cod_profesion
LEFT JOIN comuna c ON p.cod_comuna = c.cod_comuna
JOIN asesoria a ON p.id_profesional = a.id_profesional

WHERE
    EXTRACT(MONTH FROM a.fin_asesoria) = 4
    AND EXTRACT(YEAR  FROM a.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1

GROUP BY
    p.id_profesional,
    p.appaterno,
    p.apmaterno,
    p.nombre,
    pr.nombre_profesion,
    c.nom_comuna
;

SELECT * 
FROM REPORTE_MES
ORDER BY id_prof;

-- Caso 3 
-- Antes de actualizar el sueldo
SELECT
    SUM(a.honorario) AS "HONORARIO",
    p.id_profesional AS "ID_PROFESIONAL",
    p.numrun_prof AS "NUMRUN_PROF",
    p.sueldo AS "SUELDO"
FROM profesional p
JOIN asesoria a ON p.id_profesional = a.id_profesional
WHERE
    EXTRACT(MONTH FROM a.fin_asesoria) = 3
    AND EXTRACT(YEAR  FROM a.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1
GROUP BY
    p.id_profesional,
    p.numrun_prof,
    p.sueldo
ORDER BY
    p.id_profesional;
    
-- Actualización sueldo
UPDATE profesional p
SET sueldo = ROUND(p.sueldo *(
            CASE
                WHEN (
                    SELECT SUM(a.honorario)
                    FROM asesoria a
                    WHERE a.id_profesional = p.id_profesional
                      AND EXTRACT(MONTH FROM a.fin_asesoria) = 3
                      AND EXTRACT(YEAR  FROM a.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1
                     ) < 1000000
                THEN 1.10   
                ELSE 1.15   
            END
        )
    )
WHERE EXISTS (
    SELECT 1
    FROM asesoria a
    WHERE a.id_profesional = p.id_profesional
      AND EXTRACT(MONTH FROM a.fin_asesoria) = 3
      AND EXTRACT(YEAR  FROM a.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1
    );

COMMIT;

-- Despues de actualizar el sueldo
SELECT
    SUM(a.honorario) AS "HONORARIO",
    p.id_profesional AS "ID_PROFESIONAL",
    p.numrun_prof AS "NUMRUN_PROF",
    p.sueldo AS "SUELDO"
FROM profesional p
JOIN asesoria a ON p.id_profesional = a.id_profesional
WHERE
    EXTRACT(MONTH FROM a.fin_asesoria) = 3
    AND EXTRACT(YEAR  FROM a.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1
GROUP BY
    p.id_profesional,
    p.numrun_prof,
    p.sueldo
ORDER BY
    p.id_profesional;