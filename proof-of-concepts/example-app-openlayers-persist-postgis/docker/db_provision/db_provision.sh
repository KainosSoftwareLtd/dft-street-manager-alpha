#!/usr/bin/env sh

export PGHOST=$1
export PGPORT=$2
export PGUSER=$3
export PGPASSWORD=$4
export PGDATABASE=$5

RETRIES=50

until psql -c "select 1" > /dev/null 2>&1 || [ $RETRIES -eq 0 ]; do
  echo "Waiting for postgres server..."
  sleep 1
done

psql -c "CREATE EXTENSION postgis;"
psql -a -f /root/create_table_points.sql
