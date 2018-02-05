#!/usr/bin/env bash

export REPO=$1
export NAME=$2
export TAG=$(git rev-parse HEAD)

echo ${GOOGLE_CREDENTIALS} | base64 --decode > ${HOME}/.cicd.json
gcloud auth activate-service-account continiousintegrationdelivery@lyrical-bolt-194013.iam.gserviceaccount.com --key-file=${HOME}/.cicd.json
docker tag ${REPO}/${NAME}:${TAG} ${REPO}/${NAME}:latest
gcloud docker -- push ${REPO}/${NAME}:${TAG}
gcloud docker -- push ${REPO}/${NAME}:latest

echo "*** Container was build and published with tags:"
echo "*** latest"
echo "*** ${TAG}"
echo "*** Do the REAL deployment with kubectl!"
