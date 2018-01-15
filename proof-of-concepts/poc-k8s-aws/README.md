# Table of Contents
1. [Requirements](#requirements)
2. [Bootstrap AWS components](#bootstrap-aws-components)
3. [Build and publish UX app container](#build-and-publish-ux-app-container)
4. [Deploy apps](#deploy-apps)
5. [Demo](#demo)
6. [Tear down](#tear-dpown)
7. [FAQ](#faq)

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

To access kubernetes-dashboard, open terminal and type `kubectl proxy`. Dashboard is now available at http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/.

## Demo

### Scale up and down K8S infrastructure
Change number of Worker nodes (maxSize and minSize should be equal) with:
```
kops edit ig nodes
kops update cluster --yes
```

Observe behaviour with:
```
kubectl get pod -o wide -w
kops validate cluster
stern dft-street-manager-api-deployment
stern dft-street-manager-ux-deployment
```

### Scale up and down applications
Change number of pod replicas (spec.replicas field) with:
```
kubectl edit deployment/dft-street-manager-api-deployment
kubectl edit deployment/dft-street-manager-ux-deployment
```

Observe behaviour with:
```
kubectl get pod -o wide -w
stern dft-street-manager-api-deployment
stern dft-street-manager-ux-deployment
```

### Rolling application update
Change application version (spec.template.spec.image field) (ie. latest to 1.0) with:
```
kubectl edit deployment/dft-street-manager-api-deployment
```

Observe behaviour with:
```
kubectl get pod -o wide -w
stern dft-street-manager-api-deployment
```

**NOTE**

RollingUpdate is the default strategy. You can confirm it by searching deployment specification for:
```
strategy:
  rollingUpdate:
    maxSurge: 25%
    maxUnavailable: 25%
  type: RollingUpdate
```

### Cluster configuration update

Change cluster global configuration (kubernetesApiAccess, sshAccess, nonMasqueradeCIDR, ...)
```
kops edit cluster
```

Change Worker nodes specification (machine type from t2.micro to t2.small, minSize and maxSize to 2):
```
kops edit ig nodes
```

Deploy changes with:
```
kops cluster update --yes
kops rolling-update cluster
kops rolling-update cluster --yes
```

Observe behaviour with:
```
kops validate cluster
kubectl cluster-info
stern dft-street-manager-api-deployment
stern dft-street-manager-ux-deployment
```

### Master Node failure
Terminate random Master instance with:
```
aws ec2 terminate-instances --instance-ids $(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId]' --filters "Name=tag:k8s.io/role/master,Values=1" --output text |sort --random-sort | head -n 1)
```

Observe behaviour with:
```
kops validate cluster
kubectl cluster-info
stern dft-street-manager-api-deployment
stern dft-street-manager-ux-deployment
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
stern dft-street-manager-api-deployment
stern dft-street-manager-ux-deployment
```

## Tear down:
```
./delete_cluster.sh
```

## FAQ:

**Q: Will the 'frontend' and 'backend', connected via a 'Service' object, allow us to deploy apps in a multi-tier fashion?**

A: In short - yes. Until explicity defined, anything by default is not publicly exposed.

**Q: Will the private-via-bastion network layout cause us issues when publishing services to the internet?**

A: No. Loadbalancers will be put in public network (thus exposing service to the world).

**Q: How does outbound internet access work, eg for third party API calls? Do outbound calls originate from a fixed IP, to allow IP whitelisting on the remote side?**

A: Each NATGW got an elastic IP address assigned. Until AZ isn't destroyed, the outgoing IP won't change.

**Q: What technical gaps, limitations or technical challenges were encountered with the technology, tooling or process, during the spike?**

A: None so far.

**Q: How would we automate the testing & deployment of our apps - eg Jenkins hooks, kubectl client?**

A: Testing separate services can be done using `docker-compose` (this will allow us to use mocks, ie. database). Deployment-ready services will be stored in docker-style repositories (ie. ECR). We will use [Semantic Versioning](https://semver.org) if possible. Kubernetes deployments will be done using [Helm](https://github.com/kubernetes/helm).
