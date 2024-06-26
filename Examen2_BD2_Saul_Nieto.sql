CREATE OR REPLACE TRIGGER TRG_DLT_ARTISTAS
BEFORE DELETE ON ARTISTAS
FOR EACH ROW
DECLARE
    V_NUM_TOP_ARTISTAS NUMBER;
    V_NUM_ARTISTA_GRUPO NUMBER;
BEGIN
    DELETE FROM CANCIONES 
    WHERE ID_ARTISTA = :OLD.ID_ARTISTA;
    
    SELECT COUNT(1)
    INTO V_NUM_TOP_ARTISTAS
    FROM TOP_ARTISTAS_MENSUALES
    WHERE ID_ARTISTA = :OLD.ID_ARTISTA;
    
    SELECT COUNT(1)
    INTO V_NUM_ARTISTA_GRUPO
    FROM ARTISTAS_GRUPOS
    WHERE ID_ARTISTA = :OLD.ID_ARTISTA;
    
    IF (V_NUM_TOP_ARTISTAS >= 1)
        THEN DELETE FROM TOP_ARTISTAS_MENSUALES
        WHERE ID_ARTISTA = :OLD.ID_ARTISTA;
    END IF;
    
    IF (V_NUM_TOP_ARTISTAS >= 1)
        THEN DELETE FROM ARTISTAS_GRUPOS
        WHERE ID_ARTISTA = :OLD.ID_ARTISTA;
    END IF; 
END;

CREATE OR REPLACE TRIGGER TRG_IN_REPRODUCCIONES
AFTER INSERT ON REPRODUCCIONES
FOR EACH ROW
DECLARE
    V_NUM_ESTADISTICAS NUMBER;
BEGIN
    
    SELECT COUNT(1)
    INTO V_NUM_ESTADISTICAS
    FROM ESTADISTICAS
    WHERE ID_USUARIO = :NEW.ID_USUARIO AND ID_CANCION = :NEW.ID_CANCION;
    
    IF (V_NUM_ESTADISTICAS <= 0)
        THEN INSERT INTO ESTADISTICAS
        VALUES(
        :NEW.ID_USUARIO,
        :NEW.ID_CANCION,
        1,
        :NEW.FECHA_REPRODUCCION,
        :NEW.DURACION_REPRODUCCION_SEGUNDOS / 60;
        );
    ELSE
        UPDATE FROM ESTADISTICAS
        WHERE ID_USUARIO = :NEW.ID_USUARIO AND ID_CANCION = :NEW.ID_CANCION
        SET CANTIDAD_REPRODUCCIONES = CANTIDAD_REPRODUCCIONES+1,
        SET FECHA_ULTIMA_REPRODUCCION = :NEW.FECHA_REPRODUCCION,
        SET CANTIDAD_MINUTOS_REPRODUCCION = CANTIDAD_MINUTOS_REPRODUCCION + 
            (:NEW.DURACION_REPRODUCCION_SEGUNDOS / 60);
    END IF;
    
    UPDATE FROM CANCIONES
    WHERE ID_CANCION = :NEW.ID_CANCION
    SET CANTIDAD_REPRODUCCIONES = CANTIDAD_REPRODUCCIONES + 1;
    
END;

CREATE OR REPLACE TRIGGER TRG_UPD_LISTAS_REPRODUCCION
AFTER UPDATE ON LISTAS_REPRODUCCION
FOR EACH ROW
DECLARE
    V_PLAN NUMBER
    V_NUM_PLAN_ACTIVO NUMBER
BEGIN
    /*verificacion de plan activo*/
    SELECT ID_PLAN
    INTO V_PLAN
    FROM USUARIOS
    WHERE ID_USUARIO = :NEW.ID_USUARIO;
    
    SELECT COUNT(1)
    INTO V_NUM_PLAN_ACTIVO
    FROM PLANES
    WHERE ID_PLAN = V_PLAN;
    
    IF (V_NUM_PLAN_ACTIVO <= 0)
        ROLLBACK;
    END IF;
    
END;

CREATE OR REPLACE TRIGGER TRG_UPD_LISTAS_X_CANCIONES
AFTER UPDATE ON LISTAS_X_CANCIONES
FOR EACH ROW
DECLARE
    V_NUM_ACTIVE_PLAN NUMBER;
    V_USUARIO_LISTA NUMBER;
    V_PLAN_USUARIO NUMBER;
BEGIN
    SELECT ID_USUARIO
    INTO V_USUARIO_LISTA
    FROM LISTAS_REPRODUCCION
    WHERE ID_LISTA = :NEW.ID_LISTA;
    
    SELECT ID_PLAN
    INTO V_PLAN_USUARIO
    FROM USUARIOS
    WHERE ID_USUARIO = V_USUARIO_LISTA;
    
    SELECT COUNT(1)
    INTO V_NUM_ACTIVE_PLAN
    FROM PLANES
    WHERE ID_PLAN = V_PLAN_USUARIO;
    
    IF (V_NUM_ACTIVE_PLAN <= 0)
        ROLLBACK;
    END IF;
    
END;

CREATE OR REPLACE PROCEDURE P_REPORTE_POPULARIDAD
DECLARE
    V_NUM_TOTAL_REPRODUCCIONES NUMBER;
BEGIN

    /*usamos un cursor implicito para llevar las canciones por artista,
    que usaremos para dar los id de las canciones que deben ser sumadas,
    y as� obtener el total de reproducciones por cada artista*/
    
    
    /*suma de las reproducciones por cancion*/
    SELECT COUNT(1)
    INTO V_NUM_TOTAL_REPRODUCCIONES
    FROM REPRODUCCIONES
    WHERE ID_CANCION = 1;
    
END;

