# Base
FROM alpine:3.7 AS base

ENV GEOSERVER_VERSION=2.12.1
ENV CLOUDSDK_CORE_DISABLE_PROMPTS=1
ENV GEOSERVER_HOME="/home/geoserver/geoserver-${GEOSERVER_VERSION}"
ENV GEOSERVER_DATA_DIR="/var/lib/geoserver_data"
ENV JAVA_OPTS="-server -Xms2g -Xmx2g"
ENV PATH=$PATH:/home/geoserver/google-cloud-sdk/bin
ENV PG_HOST="localhost"
ENV PG_PORT=5432
ENV PG_DATABASE="gis"
ENV PG_USER="docker"
ENV PG_PASSWORD="docker"
ENV MASTERPASSWORD="geoserver"
ENV CONFIG_BUCKET=""
ENV CONFIG_VERSION=""
ENV GOOGLE_KEY_FILE=""

RUN apk upgrade --no-cache && \
    apk add --no-cache \
      openjdk8 \
      tini \
      python \
      curl \
      unzip \
      bash \
    && \
    adduser -D geoserver && \
    mkdir -p /var/lib/geoserver_data && \
    chown -R geoserver:geoserver /var/lib/geoserver_data

WORKDIR /home/geoserver

USER geoserver
RUN curl -OL http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/geoserver-${GEOSERVER_VERSION}-bin.zip && \
    unzip -q geoserver-${GEOSERVER_VERSION}-bin.zip && \
    rm -f geoserver-${GEOSERVER_VERSION}-bin.zip && \
    curl https://sdk.cloud.google.com | bash 2>&1 >/dev/null

USER root
ADD docker-entrypoint.sh /

USER geoserver

VOLUME ["/var/lib/geoserver_data"]

ENTRYPOINT ["/sbin/tini", "--", "/docker-entrypoint.sh"]

EXPOSE 8080

CMD /home/geoserver/geoserver-${GEOSERVER_VERSION}/bin/startup.sh
