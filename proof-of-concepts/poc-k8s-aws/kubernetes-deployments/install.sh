#!/usr/bin/env bash

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
cd ingress-nginx; ./install.sh; cd ..
cd dft-streetworks-api; ./install.sh; cd ..
cd dft-streetworks-ux; ./install.sh; cd ..
