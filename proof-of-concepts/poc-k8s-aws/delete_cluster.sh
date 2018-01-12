#!/usr/bin/env bash

export NAME=streetworks-alfa-poc.k8s.local
export KOPS_STATE_STORE=s3://$(cd terraform && terraform output s3-kubernetes-configuration)
kops delete cluster --name ${NAME} --yes

cd terraform; terraform destroy -force; cd ..
