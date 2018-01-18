#!/usr/bin/env bash

# Terraform first
cd terraform; terraform init; terraform apply -auto-approve; cd ..

# Assign Cluster Variables
export NAME=streetworks-alfa-poc.k8s.local
export PROJECTID=supple-league-190515
export PROJECTID=$(gcloud config get-value project)
export Image_Name="ubuntu-os-cloud/ubuntu-1604-xenial-v20170202"
export ZONES=${MASTER_ZONES:-"europe-west1-d,europe-west1-c,europe-west1-b"}
#Not Supported in Alpha
# export ZONES=${MASTER_ZONES:-"europe-west2-c,europe-west2-a,europe-west2-b"}
# export ZONES=${MASTER_ZONES:-"europe-west3-b,europe-west3-c,europe-west3-a"}
# export ZONES=${MASTER_ZONES:-"europe-west4-c,europe-west4-b"}
export KOPS_STATE_STORE=gs://$(cd terraform && terraform output gce-kubernetes-configuration)
export NODE_SIZE=${NODE_SIZE:-f1-micro}
export NODE_COUNT=3
export MASTER_SIZE=${MASTER_SIZE:-f1-micro}
export MASTER_COUNT=3
export TOPOLOGY=private
export NETWORKING=weave
export KOPS_FEATURE_FLAGS=AlphaAllowGCE
echo ${KOPS_STATE_STORE}
# Create GOSSIP cluster with jumphost
kops create cluster \
--name ${NAME} \
--zones ${ZONES} \
--project ${PROJECTID} \
--state ${KOPS_STATE_STORE} \
--image ${Image_Name} \
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


