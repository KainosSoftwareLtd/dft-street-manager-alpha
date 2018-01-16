#!/usr/bin/env bash

kubectl apply -f dft-streetworks-ux-deployment.yaml
kubectl apply -f dft-streetworks-ux-service.yaml
kubectl apply -f dft-streetworks-ux-ingress.yaml
