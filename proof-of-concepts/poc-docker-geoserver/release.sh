#!/usr/bin/env bash

export REPO=$1
export NAME=$2
export TAG=$3
export PROJECT=$(grep project_id ${HOME}/cicd.json |cut -d\" -f4)

docker tag ${REPO}/${PROJECT}/${NAME}:${TAG} ${REPO}/${PROJECT}/${NAME}:latest
gcloud docker -- push ${REPO}/${PROJECT}/${NAME}:${TAG}
gcloud docker -- push ${REPO}/${PROJECT}/${NAME}:latest

echo "*** Container was build and published with tags:"
echo "*** latest"
echo "*** ${TAG}"
echo "*** Do the REAL deployment with kubectl!"
