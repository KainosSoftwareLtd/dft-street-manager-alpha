#!/usr/bin/env bash

env

echo "$GOOGLE_KEY_FILE" > ${HOME}/service-file.json

if [ ! -z ${CONFIG_VERSION} ] && [ ! -z ${CONFIG_BUCKET} ]; then
  gcloud auth activate-service-account --key-file ${HOME}/service-file.json
  gcloud config set project $(grep project_id ${HOME}/service-file.json |cut -d\" -f4)
  gsutil cp gs://${CONFIG_BUCKET}/geoserver-config-${CONFIG_VERSION}.tgz .
  cd /var/lib/geoserver_data && tar zxf /home/geoserver/geoserver-config-${CONFIG_VERSION}.tgz
  /var/lib/geoserver_data/install.sh
fi

exec "$@"
