#!/usr/bin/env bash

# Terraform first
#cd terraform; terraform init; terraform apply -auto-approve; cd ..

# Create GOSSIP cluster with jumphost
export NAME=streetworks-alfa-poc.k8s.local
export PROJECTID=supple-league-190515
export ZONES=${MASTER_ZONES:-"europe-west2-a,europe-west2-b,europe-west2-c"}
export KOPS_STATE_STORE=gs://$(cd terraform && terraform output gce-kubernetes-configuration)
export KOPS_FEATURE_FLAGS=AlphaAllowGCE
kops create cluster ${NAME} \
  --zones $ZONES \
  --master-zones $ZONES \
  --project $PROJECTID \
  --image "ubuntu-os-cloud/ubuntu-1604-xenial-v20170202" \
  --node-count 3 \
  --master-count 3 \
  --node-size f1-micro \
  --master-size f1-micro \
  --topology private \
  --networking weave \
  --yes

until $(kops validate cluster 2>/dev/null >/dev/null); do
  echo "Cluster not ready yet."
  sleep 10
done
kops validate cluster
