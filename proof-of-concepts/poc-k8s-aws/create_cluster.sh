#!/usr/bin/env bash

# Terraform first
cd terraform; terraform init; terraform apply -auto-approve; cd ..

# Create GOSSIP cluster with jumphost
export NAME=streetworks-alfa-poc.k8s.local
export KOPS_STATE_STORE=s3://$(cd terraform && terraform output s3-kubernetes-configuration)
kops create cluster ${NAME} \
  --master-count 3 \
  --master-size t2.micro \
  --node-count 3 \
  --node-size t2.micro \
  --zones eu-west-2a,eu-west-2b \
  --topology private \
  --networking weave \
  --yes

until $(kops validate cluster 2>/dev/null >/dev/null); do
  echo "Cluster not ready yet."
  sleep 10
done
kops validate cluster
