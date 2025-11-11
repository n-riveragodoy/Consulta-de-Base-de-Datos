--Caso 1
SELECT
    SUBSTR(numrut_cli, 1, LENGTH(numrut_cli) - 6) || '.' ||
    SUBSTR(numrut_cli, -6, 3) || '.' ||
    SUBSTR(numrut_cli, -3, 3) || '-' ||
    dvrut_cli AS "Rut Cliente",
    
    INITCAP(nombre_cli) || ' ' ||
    INITCAP(appaterno_cli) || ' ' ||
    INITCAP(apmaterno_cli) AS "Nombre Completo Cliente",
    
    INITCAP(direccion_cli) AS "Dirección Cliente",
    
    TO_CHAR(renta_cli, '$9G999G999') AS "Renta Cliente",
    
    '0' ||
    SUBSTR(celular_cli, 1, 1) || '-' ||
    SUBSTR(celular_cli, 3, 3) || '-' ||
    SUBSTR(celular_cli, 4, 4) AS "Celular Cliente",
    
    CASE
        WHEN renta_cli < 200000 THEN 'TRAMO 4'
        WHEN renta_cli BETWEEN 200000 AND 399999 THEN 'TRAMO 3'
        WHEN renta_cli BETWEEN 400000 AND 500000 THEN 'TRAMO 2'
        ELSE 'TRAMO 1'
    END AS "Tramo Renta Cliente"
FROM
    cliente
WHERE
    renta_cli BETWEEN &RENTA_MINIMA AND &RENTA_MAXIMA
    AND celular_cli IS NOT NULL
ORDER BY
    "Nombre Completo Cliente" ASC;

--Caso 2
SELECT
    e.id_categoria_emp AS "CODIGO_CATEGORIA",
    
    catemp.desc_categoria_emp AS "DESCRIPCION_CATEGORIA",
    
    COUNT(*) AS "CANTIDAD_EMPLEADOS",
    
    s.desc_sucursal AS "SUCURSAL",
    TO_CHAR(ROUND(AVG(e.sueldo_emp), 0), '$9G999G999') AS "SUELDO_PROMEDIO"
FROM
    empleado e,
    categoria_empleado catemp,
    sucursal s
WHERE
    e.id_sucursal = s.id_sucursal AND
    e.id_categoria_emp = catemp.id_categoria_emp
GROUP BY
    e.id_sucursal,
    e.id_categoria_emp,
    catemp.desc_categoria_emp,
    s.desc_sucursal
HAVING
    AVG(e.sueldo_emp) >= &SUELDO_PROMEDIO_MINIMO
ORDER BY
    "SUELDO_PROMEDIO" DESC;
    
--Caso 3
SELECT
    id_tipo_propiedad AS "CODIGO_TIPO",
    
    CASE id_tipo_propiedad
        WHEN 'A' THEN 'CASA'
        WHEN 'B' THEN 'DEPARTAMENTO'
        WHEN 'C' THEN 'LOCAL'
        WHEN 'D' THEN 'PARCELA SIN CASA'
        WHEN 'E' THEN 'PARCELA CON CASA'
        ELSE 'Tipo Desconocido'
    END AS "DESCRIPCION_TIPO",

    COUNT(nro_propiedad) AS "TOTAL_PROPIEDADES",

    TO_CHAR(ROUND(AVG(valor_arriendo)), '$9G999G999') AS "PROMEDIO_ARRIENDO",

    TO_CHAR(AVG(superficie), 'FM999D00') AS "PROMEDIO_SUPERFICIE",

    TO_CHAR(ROUND(AVG(valor_arriendo / superficie)), '$9G999G999') AS "VALOR_ARRIENDO_M2",
    
    CASE
        WHEN AVG(valor_arriendo / superficie) < 5000 THEN 'Económico'
        WHEN AVG(valor_arriendo / superficie) BETWEEN 5000 AND 10000 THEN 'Medio'
        ELSE 'Alto'
    END AS "CLASIFICACION"
FROM
    propiedad
GROUP BY
    id_tipo_propiedad
HAVING
    AVG(valor_arriendo / superficie) > 1000
ORDER BY
    "VALOR_ARRIENDO_M2" DESC;