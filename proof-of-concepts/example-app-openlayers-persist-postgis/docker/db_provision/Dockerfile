FROM alpine:3.7

ENV PG_HOST="localhost"
ENV PG_PORT="5432"
ENV PG_USER="docker"
ENV PG_PASS="docker"
ENV PG_DATABASE="gis"

RUN apk upgrade --no-cache && \
    apk add --no-cache postgresql-client

ADD db_provision.sh /usr/bin/db_provision.sh
ADD create_table_points.sql /root/create_table_points.sql

ENTRYPOINT /usr/bin/db_provision.sh ${PG_HOST} ${PG_PORT} ${PG_USER} ${PG_PASS} ${PG_DATABASE}
