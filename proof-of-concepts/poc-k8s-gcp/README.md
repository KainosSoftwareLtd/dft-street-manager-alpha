# Table of Contents
1. [Requirements](#requirements)
2. [Bootstrap GCE components](#bootstrap-google-components)
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
- Access to GCE account
- Access to https://github.com/KainosSoftwareLtd/dft-street-manager-ux
- Docker - https://docs.docker.com/docker-for-mac/

## Bootstrap Google components:
```
./create_cluster.sh
```

## Build and publish UX app container:
Clone `dft-street-manager-ux`. Go into app directory and checkout to `ops-demo` branch.

```
# 1) Login to your Docker hub using the following command. :

docker login

# 2) Login to your google cloud cli using the following command. :

gcloud auth application-default login
gcloud config set project supple-league-190515

# 3) GIT the latest repository and CD into that directory. :

git clone https://github.com/KainosSoftwareLtd/dft-street-manager-ux.git ~/docker/dft-street-manager-ux
cd ~/docker/dft-street-manager-ux

# 4) Build your Docker image using the following command. For information on building a Docker file from scratch see the instructions here. You can skip this step if your image is already built:
docker build -t local/dft-street-manager-ux .

# 5) After the build completes, tag your image so you can push the image to this repository:
docker tag local/dft-street-manager-ux eu.gcr.io/supple-league-190515/dft-streetworks-ux:latest

# 6) Run the following command to push this image to your newly created Google repository:
gcloud docker -- push eu.gcr.io/supple-league-190515/dft-streetworks-ux:latest

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

Check if cluster is up
```
export NAME=streetworks-alfa-poc.k8s.local
kubectl get nodes --show-labels --context=${NAME}
```

Observe behaviour with:
```
export NAME=streetworks-alfa-poc.k8s.local
kubectl get nodes --show-labels --context=${NAME}

kubectl get pod -o wide -w
kops validate cluster
stern dft-street-manager-api-deployment
stern dft-street-manager-ux-deployment
```

Observe Config YAML with:
```
export NAME=streetworks-alfa-poc.k8s.local
kops get cluster --state ${KOPS_STATE_STORE}/ ${NAME} -oyaml
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

Change Worker nodes specification (machine type from f1micro to f1small, minSize and maxSize to 2):
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

A: 

**Q: What technical gaps, limitations or technical challenges were encountered with the technology, tooling or process, during the spike?**

A: None so far.

**Q: How would we automate the testing & deployment of our apps - eg Jenkins hooks, kubectl client?**

A: Testing separate services can be done using `docker-compose` (this will allow us to use mocks, ie. database). Deployment-ready services will be stored in docker-style repositories (ie. ECR). We will use [Semantic Versioning](https://semver.org) if possible. Kubernetes deployments will be done using [Helm](https://github.com/kubernetes/helm).
