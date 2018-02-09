# Base
FROM alpine:3.7 AS base

ENV GEOSERVER_VERSION=2.12.1

RUN apk add --update bash && rm -rf /var/cache/apk/*

RUN apk upgrade --no-cache && \
    apk add --no-cache \
      openjdk8 \
      tini \
      python \
    && \
    adduser -D geoserver && \
    mkdir -p /var/lib/geoserver_data && \
    chown -R geoserver:geoserver /var/lib/geoserver_data

RUN apk add --no-cache curl unzip && \
    curl -sSL https://sdk.cloud.google.com > /tmp/gcl && \
    apk del curl unzip

VOLUME ["/var/lib/geoserver_data"]

WORKDIR /home/geoserver

ENTRYPOINT ["/sbin/tini", "--"]

# Deps
FROM base AS dependencies

RUN apk add --no-cache curl unzip && \
    curl -OL http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/geoserver-${GEOSERVER_VERSION}-bin.zip && \
    unzip geoserver-${GEOSERVER_VERSION}-bin.zip

# Final image
FROM base AS release
COPY --from=dependencies /home/geoserver/geoserver-${GEOSERVER_VERSION} ./geoserver-${GEOSERVER_VERSION}
RUN chown geoserver:geoserver -R /home/geoserver /var/lib/geoserver_data

ENV PATH=$PATH:/home/geoserver/google-cloud-sdk/bin
RUN bash /tmp/gcl --install-dir=/home/geoserver --disable-prompts && \
  chmod +x /home/geoserver/google-cloud-sdk/bin/* && \
  chown -R geoserver:geoserver /home/geoserver /home/geoserver/google-cloud-sdk

USER geoserver

ENV GEOSERVER_HOME="/home/geoserver/geoserver-${GEOSERVER_VERSION}"
ENV GEOSERVER_DATA_DIR="/var/lib/geoserver_data"
ENV JAVA_OPTS="-server -Xms1g -Xmx1g"
ENV PATH=$PATH:/home/geoserver/google-cloud-sdk/bin

EXPOSE 8080

CMD /home/geoserver/geoserver-${GEOSERVER_VERSION}/bin/startup.sh
