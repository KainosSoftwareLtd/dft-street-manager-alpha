# Table of Contents
1. [Requirements](#requirements)
2. [AZ cli](#AZ-cli-requirements)
3. [Bootstrap azure components](#Bootstrap-azure-components)
4. [Build and publish UX app container](#build-and-publish-ux-app-container)
5. [Deploy apps](#deploy-apps)
6. [Demo](#demo)
7. [Tear down](#tear-dpown)
8. [FAQ](#faq)

# Requirements:
- Python 2.7 or greater
- Go environment - brew install go/brew upgrade go
- Go Dependency tool - brew install dep
- Git - brew install git/brew upgrade git
- Dep Git required for Azure SDK - go get -u github.com/golang/dep/cmd/dep
- Dep (Recommende) required for Azure SDK - dep ensure -add github.com/Azure/azure-sdk-for-go
- Terraform v0.11.2 - https://www.terraform.io - brew install terraform/brew upgrade terraform
- KOPS - https://github.com/kubernetes/kops
- kubectl - https://kubernetes.io/docs/tasks/tools/install-kubectl/
- stern - https://github.com/wercker/stern
- Access to Azure account
- Service Principal created with Contributor role permissions
- Access to https://github.com/KainosSoftwareLtd/dft-street-manager-ux
- Docker - https://docs.docker.com/docker-for-mac/

# AZ cli requirements:

````
1) Azure Login substitute your login_ID and Password
Example(s):
	az login -u login_id!! -p Password!!
	az login -u  brettb@kainos.com -p Th1s1smySuperSecr3tPassw0rd1999!
2) Azure Service Principal created with the Contributor role
````

# Bootstrap azure components:

```
./create_cluster.sh
```

## Build and publish UX app container:
Clone `dft-street-manager-ux`. Go into app directory and checkout to `ops-demo` branch.

```
1) Login to your Docker hub using the following command. :

docker login

2) Login to your Azure cloud cli using the following command. :

#--using the following examples login change login_ID!! and Password!! entries as required.
az login -u login_id!! -p Password!!
#--Create the required security group for Countainer Registry
az group create -n stwksRG -l westeurope
#--Create the Container Registry
az acr create --resource-group stwksRG --name streetworksux --sku Basic
#--Login to the Container Registry
az acr login --name streetworksux
#--Get the Container Registry DNS entry
az acr list --resource-group stwksRG --query "[].{acrLoginServer:loginServer}" --output table
AcrLoginServer
streetworksux.azurecr.io
#--Register the Container Service so that az aks command works
az provider register -n Microsoft.ContainerService
#--Register Compute and Network objects for deleting resources
az provider register -n Microsoft.Compute
az provider register -n Microsoft.Network
#--Create the required security group for AKS Kubernetes service
az group create -n strwksk8sRG -l westeurope
#--List Group [subscription](http://jmespath.org/specification.html#spec)
az group list --query "[?starts_with(name, 'strwksk8sRG')].{subscription: id, location: location,name: name}" --output jsonc
az ad sp list --query "[?contains(name, 'strwksk8sRG')]" --output jsonc
#--Example(s) Service Principal Name query (Michael Schott was the created SPN)
az ad sp list --query "[?contains(displayName, 'Schot')]" --output jsonc
az ad sp list --query "[?contains(displayName, 'Schot')].{TenantID: additionalProperties.appOwnerTenantId, UserID: appId, DisplayName: displayName, ObjectType: objectType}" --output jsonc
#--Create Service Principal Name or get Systems to create if you've no access to Azure AD
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/2e4c4ac4-8d97-47c6-b3a7-db98b1d102b7/resourceGroups/strwksk8sRG"
#--Create AKS Kubernetes Cluster 
#--	(Replace 'MySecretPasswordlocatedinPassRepository' with password from Service Principal Secret held in the Pass store
az aks create --resource-group strwksk8sRG --name StrwksK8sCluster --location westeurope --service-principal b9d8f245-f1ed-4610-bdcb-83337b57a252 --client-secret 'MySecretPasswordlocatedinPassRepository' --kubernetes-version 1.8.2 --node-count 1 --generate-ssh-keys

#--Set Default Context
az aks get-credentials --resource-group=strwksk8sRG --name=StrwksK8sCluster
#--Scale to 3 Nodes
az aks scale --resource-group=strwksk8sRG --name=StrwksK8sCluster --node-count 3
#--Kubernetes-Dashboard can be accessed by 
az aks browse --name StrwksK8sCluster  --resource-group strwksk8sRG

3) GIT the latest repository and CD into that directory. :

git clone https://github.com/KainosSoftwareLtd/dft-street-manager-ux.git ~/docker/dft-street-manager-ux
cd ~/docker/dft-street-manager-ux

4) Build your Docker image using the following command. For information on building a Docker file from scratch see the instructions here. You can skip this step if your image is already built:
docker build -t local/dft-street-manager-ux .

5) After the build completes, tag your image so you can push the image to this repository:
docker tag local/dft-street-manager-ux streetworksux.azurecr.io/dft-streetworks-ux:latest

6) Run the following command to push this image to your newly created Azure repository:
docker push streetworksux.azurecr.io/dft-streetworks-ux:latest

6) Repeat this for second API Image as per below
#Pull Image
docker pull schottmichal/go-restful-api-example:latest
#Docker Tag Image
docker tag schottmichal/go-restful-api-example streetworksux.azurecr.io/go-restful-api-example:latest
#Docker Push Image
docker push streetworksux.azurecr.io/go-restful-api-example:latest

```

## Deploy apps:
```
# Deploy applications
cd kubernetes-deployments && ./install.sh; cd ..
```

Frontend is available at `kubectl get ing -o yaml |grep hostname |cut -d":" -f2` (give it 5 min to spin up).

To access kubernetes-dashboard, open terminal and type `az aks browse --name StrwksK8sCluster  --resource-group strwksk8sRG`. Dashboard is now available at http://localhost:8001/.

## Demo

### Scale up and down K8S infrastructure
Change number of Worker nodes (maxSize and minSize should be equal) with:
```
az aks scale --resource-group=strwksk8sRG --name=StrwksK8sCluster --node-count 3
az aks scale --resource-group=strwksk8sRG --name=StrwksK8sCluster --node-count 1
```

Check if cluster is up
```
kubectl get nodes --show-labels --all-namespaces
```

Observe behaviour with:
```
kubectl get pod -o wide -w
stern dft-street-manager-api-deployment
stern dft-street-manager-ux-deployment
```

Observe Config YAML with:
```
export NAME=streetworks-alfa-poc.k8s.local
kubectl get nodes -o yaml
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

```

Change Worker nodes specification (machine type from f1micro to f1small, minSize and maxSize to 2):
```

```

Deploy changes with:
```
kubectl apply -f dft-streetworks-api-deployment.yaml
```

Observe behaviour with:
```
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
kubectl cluster-info
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
