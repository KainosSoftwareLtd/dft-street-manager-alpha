# Table of Contents
1. [Requirements](#requirements)
2. [AZ cli](#az-cli-requirements)
3. [Bootstrap azure components](#bootstrap-azure-components)
4. [Build and publish UX app container](#build-and-publish-ux-app-container)
5. [Deploy apps](#deploy-applications)
6. [Demo](#demo)
7. [Tear down](#tear-down)
8. [FAQ](#faq)

## Requirements
- Python 2.7 or greater
Note: If Python 3.6 is also installed make sure certificates are bound: `/Applications/Python\ 3.6/Install\ Certificates.command`
- Go environment: `brew install go/brew upgrade go`
- Go Dependency tool: `brew install dep`
- Git: `brew install git` `brew upgrade git`
- Dep Git required for Azure SDK: `go get -u github.com/golang/dep/cmd/dep`
- Dep (Recommended) required for Azure SDK: `dep ensure -add github.com/Azure/azure-sdk-for-go`
- Terraform v0.11.2 - https://www.terraform.io: `brew install terraform/brew upgrade terraform`
- [KOPS](https://github.com/kubernetes/kops)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Sern](https://github.com/wercker/stern)
- Access to Azure account
- Service Principal created with Contributor role permissions
- [Github access to Streetmanager](https://github.com/KainosSoftwareLtd/dft-street-manager-ux)
- [Docker](https://docs.docker.com/docker-for-mac/)

## AZ cli requirements

1) Azure Login substitute your login_ID and Password
Example(s):
> * You must have at least contributor role to succedd in this tutorial
	`az login -u login_id!! -p Password!!`
	`az login -u  brettb@kainos.com -p Th1s1smySuperSecr3tPassw0rd1999!`

2) Ensure you have configured the minimum variables below in ./create_cluster.sh . Refer to Step 3 for SPN additional information.
	`export PROJECT_NAME=stwks #Change the stwks value to requirements`
	`export PROJECT_CONTAINER_REGISTRY_NAME=streetworksux #Change the streetworksux value to requirements`
	`export PROJECT_REGION=westeurope #Change the westeurope value to requirements`
	`export AKS_VERSION=1.8.2 #Change the 1.8.2 value to requirements`
	`export AKS_NODE_COUNT=3 #Change the 3 value to requirements`
	`export AKS_SPN_ID=b9d8f245-f1ed-4610-bdcb-83337b57a252 #Change the b9d8f245-f1ed-4610-bdcb-83337b57a252 value to requirements`
	`export AKS_SPN_SECRET="_GetFromPasswordSecretLocation" #Change the _GetFromPasswordSecretLocation value to requirements`

3) Azure Service Principal created with the Contributor role.
You must have the Service Principal Name ID and the Service Principal Secret.  Assign these to the in the ./create_cluster.sh script.  
Examples(s):
> *  If you were going to create the Service Principal you may do it such as below.
> *  ... You would need to get the appID and Secret from the output of running the command
> *  ........ and assign them to the AKS_SPN_ID and AKS_SPN_SECRET part of the script ./create_cluster.sh
> * Modify System settings to match project details
`export PROJECT_NAME=stwks #Change this value to requirements`
`export PROJECT_REGION=westeurope #Change this value to requirements`
`export AKS_SPN_SearchIDString="18-00213" #use this to find the SPN appID if you are not sure`

> * Assign Core Variables using Project defined variables above
`export PROJECT_RG=${PROJECT_NAME}RG`
`export AKS_NAME=${PROJECT_NAME}k8s`
`export AKS_RG=${AKS_Name}RG`
`export AKS_REGION=${PROJECT_REGION}`

`az group create -n ${AKS_RG} -l ${PROJECT_REGION}`
`export AKS_RG_SUBSCRIPTION=$(az group list --query "[?starts_with(name, '${AKS_RG}')].{Subscription: id, Location: location, Name: name} | [].Subscription" --output tsv)`
`az ad sp create-for-rbac -name "${AKS_NAME}" -password "${AKS_SPN_SECRET}" --role="Contributor" --scopes="${AKS_RG_Subscription}"`

> * Query for appID of Service Principal is like below if you need confirmation
`export AKS_SPN_SearchIDString="18-00213" #Change this to what you think it may contain`
`export AKS_SPN_ID=$(az ad sp list --query "[?contains(displayName, '${AKS_SPN_SearchIDString}')].{TenantID: additionalProperties.appOwnerTenantId, UserID: appId, DisplayName: displayName, ObjectType: objectType} | [].UserID" --output tsv)`

> * Query for import properties 
`export AKS_SPN_SearchIDString="18-00213" #Change this to what you think it may contain`
`az ad sp list --query "[?contains(displayName, '${AKS_SPN_SearchIDString}')].{TenantID: additionalProperties.appOwnerTenantId, UserID: appId, DisplayName: displayName, ObjectType: objectType} | []" --output jsonc`

## Bootstrap azure components
`./create_cluster.sh`


## Build and publish UX app container
Clone `dft-street-manager-ux`. Go into app directory and checkout to `ops-demo` branch.


1) Login to your Docker hub using the following command. :
`docker login`

2) Login to your Azure cloud cli using the following command. :

--using the following examples login change login_ID!! and Password!! entries as required.
`az login -u login_id!! -p Password!!`

> * The steps below are a manual run through if the './create_cluster.sh' has issues

```
export PROJECT_NAME=stwks #Change the stwks value to requirements
export PROJECT_CONTAINER_REGISTRY_NAME=streetworksux #Change the streetworksux value to requirements
export PROJECT_REGION=westeurope #Change the westeurope value to requirements
export AKS_VERSION=1.8.2 #Change the 1.8.2 value to requirements
export AKS_NODE_COUNT=3 #Change the 3 value to requirements
export AKS_SPN_ID=b9d8f245-f1ed-4610-bdcb-83337b57a252 #Change the b9d8f245-f1ed-4610-bdcb-83337b57a252 value to requirements
export AKS_SPN_SECRET="_GetFromPasswordSecretLocation" #Change the _GetFromPasswordSecretLocation value to requirements
export AKS_SPN_SearchIDString="18-00213" #This will only get the Service Principal ID if you don't know it

# Assign Core Variables using Project defined variables above
export PROJECT_RG=${PROJECT_NAME}RG
export PROJECT_RG_CREATE=$(az group list --query "[?starts_with(name, '${PROJECT_RG}')].{Subscription: id, Location: location, Name: name} | [].Name" --output tsv)
export AKS_NAME=${PROJECT_NAME}k8s
export AKS_RG=${AKS_Name}RG
export AKS_RG_CREATE=$(az group list --query "[?starts_with(name, '${AKS_RG}')].{Subscription: id, Location: location, Name: name} | [].Name" --output tsv)
export AKS_CLUSTER_NAME=${AKS_Name}Cluster
export AKS_REGION=${PROJECT_REGION}
export AZ_CONTAINER_REGISTRY_SERVER=$(az acr list --resource-group ${PROJECT_RG} --query "[].{acrLoginServer:loginServer}" --output tsv)

echo Connecting to resource objects to create

echo az register Container to delete Cluster objects
  az provider register -n Microsoft.ContainerService
echo Register Compute and Network objects for deleting resources
  az provider register -n Microsoft.Compute
  az provider register -n Microsoft.Network


echo Login to the Container Registry
  az acr login --name ${PROJECT_CONTAINER_REGISTRY_NAME}

export AZ_CONTAINER_REGISTRY_SERVER=$(az acr list --resource-group ${PROJECT_RG} --query "[].{acrLoginServer:loginServer}" --output tsv);
echo variable AZ_CONTAINER_REGISTRY_SERVER is now set

echo Setting variable AKS_RG
  az group create -n ${AKS_RG} -l ${PROJECT_REGION}

echo Setting variable AKS_RG_SUBSCRIPTION
export AKS_RG_SUBSCRIPTION=$(az group list --query "[?starts_with(name, '${AKS_RG}')].{Subscription: id, Location: location, Name: name} | [].Subscription" --output tsv)

echo .............................
echo creating Kubernetes Cluster ${AKS_CLUSTER_NAME}
echo ...Please be Patient
echo ......This could take 5 minutes or more
echo .............................
  az aks create --resource-group ${AKS_RG} --name ${AKS_CLUSTER_NAME} --location ${PROJECT_REGION} --service-principal ${AKS_SPN_ID} --client-secret "${AKS_SPN_SECRET}" --kubernetes-version ${AKS_VERSION} --node-count ${AKS_NODE_COUNT} --generate-ssh-keys

echo Set Default Context for ${AKS_CLUSTER_NAME}
  az aks get-credentials ---resource-group ${AKS_RG} --name ${AKS_CLUSTER_NAME}
```
  
--Get the Container Registry DNS entry
`az acr list --resource-group stwksRG --query "[].{acrLoginServer:loginServer}" --output table
AcrLoginServer`
Output Example: `streetworksux.azurecr.io`
--Register the Container Service so that az aks command works
`az provider register -n Microsoft.ContainerService`
--Register Compute and Network objects for deleting resources
`az provider register -n Microsoft.Compute`
`az provider register -n Microsoft.Network`
--Create the required security group for AKS Kubernetes service
`az group create -n strwksk8sRG -l westeurope`
--List Group subscription using [jmespath.org](http://jmespath.org/specification.html#spec) query
`az group list --query "[?starts_with(name, 'strwksk8sRG')].{Subscription: id, Location: location, Name: name}" --output jsonc`
`az group list --query "[?starts_with(name, 'strwksk8sRG')].{Subscription: id, Location: location, Name: name} | [].Subscription" --output tsv`
`az group list --query "[?starts_with(name, 'strwksk8sRG')].{Subscription: id, Location: location, Name: name} | [].Location" --output tsv`
`az ad sp list --query "[?contains(name, 'strwksk8sRG')]" --output jsonc`
--Example(s) Service Principal Name query (Displayname description had '18-00213' in the created SPN)
`az ad sp list --query "[?contains(displayName, '18-00213')]" --output jsonc`
`az ad sp list --query "[?contains(displayName, '18-00213')].{TenantID: additionalProperties.appOwnerTenantId, UserID: appId, DisplayName: displayName, ObjectType: objectType}" --output jsonc`
`az ad sp list --query "[?contains(displayName, '18-00213')].{TenantID: additionalProperties.appOwnerTenantId, UserID: appId, DisplayName: displayName, ObjectType: objectType} | [].TenantID" --output tsv`
`az ad sp list --query "[?contains(displayName, '18-00213')].{TenantID: additionalProperties.appOwnerTenantId, UserID: appId, DisplayName: displayName, ObjectType: objectType} | [].UserID" --output tsv`
--Create Service Principal Name or get Systems to create if you've no access to Azure AD
`az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/2e4c4ac4-8d97-47c6-b3a7-db98b1d102b7/resourceGroups/strwksk8sRG"`
--Create AKS Kubernetes Cluster
--	(Replace 'MySecretPasswordlocatedinPassRepository' with password from Service Principal Secret held in the Pass store
`az aks create --resource-group strwksk8sRG --name StrwksK8sCluster --location westeurope --service-principal b9d8f245-f1ed-4610-bdcb-83337b57a252 --client-secret 'MySecretPasswordlocatedinPassRepository' --kubernetes-version 1.8.2 --node-count 1 --generate-ssh-keys`

--Set Default Context
`az aks get-credentials --resource-group=strwksk8sRG --name=StrwksK8sCluster`
--Check AKS Cluster details

All Properties: `az aks list --query "[?starts_with(name, '${AKS_CLUSTER_NAME}')]|[]" --output jsonc`
Specific Properties: `az aks list --query "[?starts_with(name, '${AKS_CLUSTER_NAME}')].{Subscription: id, Location: location, Name: name, SPN_ID: servicePrincipalProfile.clientId, Version: kubernetesVersion, LoginID: linuxProfile.adminUsername, sshKey: linuxProfile.ssh.publicKeys, Status: provisioningState}" --output jsonc`
AKS Cluster Status: `az aks list --query "[?starts_with(name, '${AKS_CLUSTER_NAME}')]|[].provisioningState" --output tsv`


--Scale to 3 Nodes
`az aks scale --resource-group=strwksk8sRG --name=StrwksK8sCluster --node-count 3`
--Kubernetes-Dashboard can be accessed by
`az aks browse --name StrwksK8sCluster  --resource-group strwksk8sRG`

3) GIT the latest repository and CD into that directory. :

`git clone https://github.com/KainosSoftwareLtd/dft-street-manager-ux.git ~/docker/dft-street-manager-ux`
`cd ~/docker/dft-street-manager-ux`

4) Build your Docker image using the following command. For information on building a Docker file from scratch see the instructions here. You can skip this step if your image is already built:
`docker build -t local/dft-street-manager-ux .`

5) After the build completes, tag your image so you can push the image to this repository:
`docker tag local/dft-street-manager-ux streetworksux.azurecr.io/dft-streetworks-ux:latest`

6) Run the following command to push this image to your newly created Azure repository:
`docker push streetworksux.azurecr.io/dft-streetworks-ux:latest`

6) Repeat this for second API Image as per below
Pull Image
`docker pull schottmichal/go-restful-api-example:latest`
Docker Tag Image
`docker tag schottmichal/go-restful-api-example streetworksux.azurecr.io/go-restful-api-example:latest`
Docker Push Image
`docker push streetworksux.azurecr.io/go-restful-api-example:latest`


## Deploy applications
`cd kubernetes-deployments && ./install.sh; cd ..`

Frontend is available at `kubectl get ing -o yaml |grep hostname |cut -d":" -f2` (give it 5 min to spin up).

To access kubernetes-dashboard, open terminal and type `az aks browse --name StrwksK8sCluster  --resource-group strwksk8sRG`
Dashboard is now available at http://localhost:8001/.

## Demo

### Scale up and down K8S infrastructure
Change number of Worker nodes (maxSize and minSize should be equal) with:

`az aks scale --resource-group=strwksk8sRG --name=StrwksK8sCluster --node-count 3`
`az aks scale --resource-group=strwksk8sRG --name=StrwksK8sCluster --node-count 1`

Check if cluster is up
`kubectl get nodes --show-labels --all-namespaces`

Observe behaviour with:
`kubectl get pod -o wide -w`
`stern dft-street-manager-api-deployment`
`stern dft-street-manager-ux-deployment`

Observe Config YAML with:
`export NAME=streetworks-alfa-poc.k8s.local`
`kubectl get nodes -o yaml`

### Scale up and down applications
Change number of pod replicas (spec.replicas field) with:
`kubectl edit deployment/dft-street-manager-api-deployment`
`kubectl edit deployment/dft-street-manager-ux-deployment`

Observe behaviour with:
`kubectl get pod -o wide -w`
`stern dft-street-manager-api-deployment`
`stern dft-street-manager-ux-deployment`

### Rolling application update
Change application version (spec.template.spec.image field) (ie. latest to 1.0) with:
```
kubectl edit deployment/dft-street-manager-api-deployment
```

Observe behaviour with:
`kubectl get pod -o wide -w`
`stern dft-street-manager-api-deployment`

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


Change Worker nodes specification (machine type from f1micro to f1small, minSize and maxSize to 2)


Deploy changes with:
`kubectl apply -f dft-streetworks-api-deployment.yaml`

Observe behaviour with:
```
kubectl cluster-info
stern dft-street-manager-api-deployment
stern dft-street-manager-ux-deployment
```

### Master Node failure
Terminate random Master instance with:
``
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
`./delete_cluster.sh`

## FAQ:

**Q: Will the 'frontend' and 'backend', connected via a 'Service' object, allow us to deploy apps in a multi-tier fashion?**

A: In short - yes. Until explicity defined, anything by default is not publicly exposed.

**Q: Will the private-via-bastion network layout cause us issues when publishing services to the internet?**

A:

**Q: What technical gaps, limitations or technical challenges were encountered with the technology, tooling or process, during the spike?**

A: None so far.

**Q: How would we automate the testing & deployment of our apps - eg Jenkins hooks, kubectl client?**

A: Testing separate services can be done using `docker-compose` (this will allow us to use mocks, ie. database). Deployment-ready services will be stored in docker-style repositories (ie. ECR). We will use [Semantic Versioning](https://semver.org) if possible. Kubernetes deployments will be done using [Helm](https://github.com/kubernetes/helm).
