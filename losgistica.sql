CREATE TABLE audit_logs (
    id BIGSERIAL PRIMARY KEY,
    fecha TIMESTAMP DEFAULT NOW(),
    nivel TEXT,
    operacion TEXT,
    detalle TEXT,
    sqlstate TEXT
);

CREATE OR REPLACE FUNCTION calcular_costo_envio(
    p_peso envios.peso%TYPE,
    p_prioridad TEXT
)
RETURNS NUMERIC
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_base NUMERIC := 500;
    v_resultado NUMERIC;
BEGIN
    v_resultado := v_base + (p_peso * 12);

    IF p_prioridad = 'alta' THEN
        v_resultado := v_resultado * 1.5;
    END IF;

    RETURN v_resultado;
END;
$$;

CREATE OR REPLACE PROCEDURE crear_envio(
    p_cliente_id clientes.id%TYPE,
    p_origen centros_distribucion.id%TYPE,
    p_destino centros_distribucion.id%TYPE,
    p_peso envios.peso%TYPE,
    p_prioridad TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_envio_id envios.id%TYPE;
    v_costo NUMERIC;
BEGIN
    INSERT INTO envios(
        cliente_id,
        centro_origen_id,
        centro_destino_id,
        estado,
        fecha_envio,
        peso,
        etiquetas
    )
    VALUES (
        p_cliente_id,
        p_origen,
        p_destino,
        'pendiente',
        NOW(),
        p_peso,
        jsonb_build_object('prioridad', p_prioridad)
    )
    RETURNING id INTO v_envio_id;

    BEGIN
        v_costo := calcular_costo_envio(p_peso, p_prioridad);

        INSERT INTO audit_logs(nivel, operacion, detalle)
        VALUES (
            'INFO',
            'CREAR_ENVIO',
            'Envio ' || v_envio_id || ' costo: ' || v_costo
        );

    EXCEPTION
        WHEN OTHERS THEN
            INSERT INTO audit_logs(nivel, operacion, detalle, sqlstate)
            VALUES (
                'ERROR',
                'CREAR_ENVIO_COSTO',
                SQLERRM,
                SQLSTATE
            );
    END;

EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO audit_logs(nivel, operacion, detalle, sqlstate)
        VALUES (
            'FATAL',
            'CREAR_ENVIO',
            SQLERRM,
            SQLSTATE
        );
END;
$$;

SELECT calcular_costo_envio(10, 'alta');

CALL crear_envio(1, 1, 2, 10, 'alta');

SELECT * FROM audit_logs ORDER BY fecha DESC;