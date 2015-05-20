#!/bin/bash

if [[ ! -f $PG_ROOT_DIR/.initialized ]]; then
    echo "Creating $PG_ROOT_DIR directory"
    mkdir -p $PG_ROOT_DIR
    mkdir -p $PG_DATA_DIR

    echo "Copying postgresql files to $PG_ROOT_DIR directory"
    cp -R /var/lib/postgresql/9.4/main/* $PG_DATA_DIR
    cp -R /etc/postgresql/9.4/main/pg_hba.conf $PG_HBA_FILE
    cp -R /etc/postgresql/9.4/main/postgresql.conf $PG_CONF_FILE

    DB_PASSWORD=$(< /dev/urandom tr -dc A-Za-z0-9 | head -c 16)

    echo $DB_PASSWORD > .pwd
    chown -R postgres:postgres $PG_ROOT_DIR
    chmod -R 700 $PG_ROOT_DIR

    echo "Creating super user with password '$DB_PASSWORD'"
    su postgres sh -c "/usr/lib/postgresql/9.4/bin/postgres --single  -D $PG_DATA_DIR  -c config_file=$PG_CONF_FILE" <<< "CREATE USER root WITH SUPERUSER PASSWORD '$DB_PASSWORD';"
    #su postgres sh -c "/usr/lib/postgresql/9.3/bin/postgres --single  -D  /var/lib/postgresql/9.3/main  -c config_file=/etc/postgresql/9.3/main/postgresql.conf" <<< "CREATE DATABASE db ENCODING 'UTF8' TEMPLATE template0;"

    touch $PG_ROOT_DIR/.initialized
fi

chown -R postgres:postgres $PG_ROOT_DIR
chmod -R 700 $PG_ROOT_DIR

echo "Starting PostgreSQL 9.4 Server"
echo "Superuser password: $(cat .pwd)"
su postgres sh -c "/usr/lib/postgresql/9.4/bin/postgres -D $PG_DATA_DIR  -c config_file=$PG_CONF_FILE  -c listen_addresses=*"
