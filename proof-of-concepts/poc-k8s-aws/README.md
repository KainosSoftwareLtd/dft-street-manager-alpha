# Requirements:
- Terraform 0.11 - https://www.terraform.io
- KOPS - https://github.com/kubernetes/kops
- kubectl - https://kubernetes.io/docs/tasks/tools/install-kubectl/
- stern - https://github.com/wercker/stern
- Access to AWS account
- Access to https://github.com/KainosSoftwareLtd/dft-street-manager-ux
- Docker - https://docs.docker.com/docker-for-mac/

## Bootstrap AWS components:
```
./create_cluster.sh
```

## Build and publish UX app container:
Clone `dft-street-manager-ux`. Go into app directory and checkout to `ops-demo` branch.

```
$(aws ecr get-login --no-include-email --region eu-west-2)
docker build -t 583284001540.dkr.ecr.eu-west-2.amazonaws.com/dft-streetworks-ux:latest .
docker push 583284001540.dkr.ecr.eu-west-2.amazonaws.com/dft-streetworks-ux:latest
```

## Deploy apps:
```
# Deploy applications
cd kubernetes-deployments && ./install.sh; cd ..
```

Frontend is available at `kubectl get ing -o yaml |grep hostname |cut -d":" -f2` (give it 5 min to spin up).

## Demo

### Master Node failure
Terminate random Master instance with:
```
aws ec2 terminate-instances --instance-ids $(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId]' --filters "Name=tag:k8s.io/role/master,Values=1" --output text |sort --random-sort | head -n 1)
```

Observe behaviour with:
```
kops validate cluster
kubectl cluster-info
```

### Worker Node failure
Terminate random Worker instance with:

```
aws ec2 terminate-instances --instance-ids $(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId]' --filters "Name=private-dns-name,Values=$(kubectl get pod -o json |grep ip |sort --random-sort -u |cut -d\" -f4 |head -n 1)" --output text)
```

Observe behaviour with:
```
kubectl get pod -o wide -w
kops validate cluster
```

## Tear down:
```
./delete_cluster.sh
```
