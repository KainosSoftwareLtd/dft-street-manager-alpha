#!/usr/bin/env bash

set -e

export CLUSTER_NAME=$1
export REPO=$2
export NAME=$3
export TAG=$4
export PROJECT=$(grep project_id ${HOME}/cicd.json |cut -d\" -f4)

gcloud container clusters get-credentials ${CLUSTER_NAME}

cd kubernetes

sed -i "s/<DOCKER_REPO_HOSTNAME>/${REPO}/" deployment.yaml
sed -i "s/<DOCKER_PROJECT_ID>/${PROJECT}/" deployment.yaml
sed -i "s/<DOCKER_REPO_NAME>/${NAME}/" deployment.yaml
sed -i "s/<DOCKER_TAG>/${TAG}/" deployment.yaml

kubectl apply -f config.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
