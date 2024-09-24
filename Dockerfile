FROM postgres:15

# Instalar curl
RUN apt-get update && apt-get install -y curl

# Copiar el script de inicialización
COPY init-db.sh /docker-entrypoint-initdb.d/

# Configurar los parámetros de PostgreSQL
RUN echo "wal_level = logical" >> /usr/share/postgresql/postgresql.conf.sample \
    && echo "max_wal_senders = 10" >> /usr/share/postgresql/postgresql.conf.sample \
    && echo "max_replication_slots = 10" >> /usr/share/postgresql/postgresql.conf.sample \
    && echo "shared_preload_libraries = 'pglogical'" >> /usr/share/postgresql/postgresql.conf.sample \
    && echo "pglogical.conf = '/etc/postgresql/pglogical.conf'" >> /usr/share/postgresql/postgresql.conf.sample
