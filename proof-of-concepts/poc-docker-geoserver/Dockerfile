# Base
FROM alpine:3.7 AS base

ENV GEOSERVER_VERSION=2.12.1

RUN apk upgrade --no-cache && \
    apk add --no-cache \
      openjdk8 \
      tini \
    && \
    adduser -D geoserver && \
    mkdir -p /var/lib/geoserver_data && \
    chown -R geoserver:geoserver /var/lib/geoserver_data

VOLUME ["/var/lib/geoserver_data"]

WORKDIR /home/geoserver

ENTRYPOINT ["/sbin/tini", "--"]

# Deps
FROM base AS dependencies

RUN apk add --no-cache curl unzip && \
    curl -OL http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/geoserver-${GEOSERVER_VERSION}-bin.zip && \
    unzip -q geoserver-${GEOSERVER_VERSION}-bin.zip

# Final image
FROM base AS release
COPY --from=dependencies /home/geoserver/geoserver-${GEOSERVER_VERSION} ./geoserver-${GEOSERVER_VERSION}
RUN chown geoserver:geoserver -R /home/geoserver /var/lib/geoserver_data

USER geoserver

ENV GEOSERVER_HOME="/home/geoserver/geoserver-${GEOSERVER_VERSION}"
ENV GEOSERVER_DATA_DIR="/var/lib/geoserver_data"
ENV JAVA_OPTS="-server -Xms2g -Xmx2g"

EXPOSE 8080

CMD /home/geoserver/geoserver-${GEOSERVER_VERSION}/bin/startup.sh
