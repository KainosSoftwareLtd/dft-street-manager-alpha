# Requirements:
- Terraform 0.11 - https://www.terraform.io
- KOPS - https://github.com/kubernetes/kops
- kubectl - https://kubernetes.io/docs/tasks/tools/install-kubectl/
- Access to AWS account
- Access to https://github.com/KainosSoftwareLtd/dft-street-manager-ux
- Docker - https://docs.docker.com/docker-for-mac/

## Bootstrap AWS components:
```
./create_cluster.sh
```

## Build and publish UX app container:
Clone `dft-street-manager-ux`. Go into app directory.

```
$(aws ecr get-login --no-include-email --region eu-west-2)
docker build -t dft-streetworks-ux .
docker tag dft-streetworks-ux:latest 583284001540.dkr.ecr.eu-west-2.amazonaws.com/dft-streetworks-ux:latest
docker push 583284001540.dkr.ecr.eu-west-2.amazonaws.com/dft-streetworks-ux:latest
```

## Deploy apps:
```
# Deploy applications
cd kubernetes-deployments && ./install.sh; cd ..
```

Frontend is available at `kubectl get ing -o yaml |grep hostname |cut -d":" -f2`

## Tear down:
```
./delete_cluster.sh
```
