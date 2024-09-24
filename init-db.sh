#!/bin/bash
set -e

# Configurar DDL event trigger
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE OR REPLACE FUNCTION ddl_event_trigger() RETURNS event_trigger AS \$\$
    BEGIN
        
    -- Insertar un registro en la tabla de auditoría
    INSERT INTO ddl_audit_log (event_time, user_name, command_tag)
    VALUES (current_timestamp, current_user, tg_tag);
    END;
    \$\$ LANGUAGE plpgsql;


    -- Crear la tabla de auditoría si no existe
    CREATE TABLE IF NOT EXISTS ddl_audit_log (
       id serial PRIMARY KEY,
       event_time timestamp NOT NULL,
       user_name text NOT NULL,
       command_tag text NOT NULL
     );

    CREATE EVENT TRIGGER ddl_event_trigger ON ddl_command_start EXECUTE FUNCTION ddl_event_trigger();
    ALTER EVENT TRIGGER ddl_event_trigger ENABLE ALWAYS;
EOSQL

# Verificar transacciones largas
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    SELECT pid, age(clock_timestamp(), query_start), usename, query
    FROM pg_stat_activity
    WHERE state != 'idle' AND query_start < now() - interval '5 minutes';
EOSQL

