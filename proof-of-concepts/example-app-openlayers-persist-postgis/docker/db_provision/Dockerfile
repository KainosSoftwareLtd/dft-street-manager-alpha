FROM alpine:3.7

ENV PGHOST="localhost"
ENV PGPORT="5432"
ENV PGUSER="docker"
ENV PGPASS="docker"
ENV PGDATABASE="gis"

RUN apk upgrade --no-cache && \
    apk add --no-cache postgresql-client

ADD db_provision.sh /usr/bin/db_provision.sh
ADD create_table_points.sql /root/create_table_points.sql

ENTRYPOINT /usr/bin/db_provision.sh ${PGHOST} ${PGPORT} ${PGUSER} ${PGPASS} ${PGDATABASE}
