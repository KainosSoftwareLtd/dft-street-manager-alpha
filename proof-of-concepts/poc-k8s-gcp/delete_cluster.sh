#!/usr/bin/env bash

export NAME=streetworks-alfa-poc.k8s.local
kops delete cluster --name ${NAME} --yes

cd terraform; terraform destroy -force; cd ..
