#!/usr/bin/env bash

# Terraform first
cd terraform; terraform init; terraform apply -auto-approve; cd ..

# Assign Cluster Variables
export NAME=streetworks-alfa-poc.k8s.local
export PROJECTID=$(gcloud config get-value project |head -n1)
export ZONES=${MASTER_ZONES:-"europe-west2-a,europe-west2-b,europe-west2-c"}
export KOPS_STATE_STORE=gs://$(cd terraform && terraform output gce-kubernetes-configuration)
export NODE_SIZE=${NODE_SIZE:-n1-standard-1}
export NODE_COUNT=3
export MASTER_SIZE=${MASTER_SIZE:-n1-standard-1}
export MASTER_COUNT=3
export TOPOLOGY=private
export NETWORKING=weave
export KOPS_FEATURE_FLAGS=AlphaAllowGCE

# Create GOSSIP cluster with jumphost
kops create cluster \
--cloud gce \
--name ${NAME} \
--zones ${ZONES} \
--project ${PROJECTID} \
--state ${KOPS_STATE_STORE} \
--node-count ${NODE_COUNT} \
--master-count ${MASTER_COUNT} \
--node-size ${NODE_SIZE} \
--master-size ${MASTER_SIZE} \
--topology ${TOPOLOGY} \
--networking ${NETWORKING} \
--yes

#kops get cluster --state ${KOPS_STATE_STORE}/ ${NAME} -oyaml

#  kops delete cluster ${NAME} --yes

until $(kops validate cluster 2>/dev/null >/dev/null); do
  echo "Cluster not ready yet."
  sleep 10
done


