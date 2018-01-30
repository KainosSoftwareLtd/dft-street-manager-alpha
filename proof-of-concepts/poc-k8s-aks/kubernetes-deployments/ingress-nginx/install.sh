#!/usr/bin/env bash

# source:
# https://github.com/kubernetes/ingress-nginx/blob/master/deploy/README.md

curl https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/namespace.yaml | kubectl apply -f -
curl https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/default-backend.yaml | kubectl apply -f -
curl https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/configmap.yaml | kubectl apply -f -
curl https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/tcp-services-configmap.yaml | kubectl apply -f -
curl https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/udp-services-configmap.yaml | kubectl apply -f -
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/patch-service-with-rbac.yaml
kubectl patch deployment -n ingress-nginx nginx-ingress-controller --type='json' \
 --patch="$(curl https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/publish-service-patch.yaml)"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/azure/service.yaml
