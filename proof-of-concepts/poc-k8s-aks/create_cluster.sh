#!/usr/bin/env bash

# Terraform first
#cd terraform; terraform init; terraform apply -auto-approve; cd ..

# Modify System settings to match project details
export PROJECT_NAME=stwks #Change the stwks value to requirements
export PROJECT_CONTAINER_REGISTRY_NAME=streetworksux #Change the streetworksux value to requirements
export PROJECT_REGION=westeurope #Change the westeurope value to requirements
export AKS_VERSION=1.8.2 #Change the 1.8.2 value to requirements
export AKS_NODE_COUNT=3 #Change the 3 value to requirements
export AKS_SPN_ID=b9d8f245-f1ed-4610-bdcb-83337b57a252 #Change the b9d8f245-f1ed-4610-bdcb-83337b57a252 value to requirements
export AKS_SPN_SECRET="mPDkwKNug8F8ik41ZMITj1sRSQYJEUd1Mz6Tz90SLmw=" #Change the _GetFromPasswordSecretLocation value to requirements
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

#az register Container to delete Cluster objects
az provider register -n Microsoft.ContainerService
#Register Compute and Network objects for deleting resources
az provider register -n Microsoft.Compute
az provider register -n Microsoft.Network

#Create the AKS resources

# until $(kops validate cluster 2>/dev/null >/dev/null); do
#   echo "Cluster not ready yet."
#   sleep 60
# done

if [ -z ${PROJECT_NAME} ]
  then
    echo Variable PROJECT_NAME is not set -- Exiting Script
    exit 1
fi

# export PROJECT_RG_CREATE=
if [ -z ${PROJECT_RG_CREATE} ]
  then
    echo variable PROJECT_RG is not set
    az group create -n ${PROJECT_RG} -l ${PROJECT_REGION}
    export PROJECT_RG=$(az group list --query "[?starts_with(name, '${PROJECT_RG}')].{Subscription: id, Location: location, Name: name} | [].Name" --output tsv)
    if [ ${PROJECT_RG_CREATE} ];  then echo variable PROJECT_RG is now set:${PROJECT_RG_CREATE}; fi
  else
    echo variable PROJECT_RG is set:${PROJECT_RG_CREATE}
fi

# export AZ_CONTAINER_REGISTRY_SERVER=
if [ -z ${AZ_CONTAINER_REGISTRY_SERVER} ]
  then
    echo variable AZ_CONTAINER_REGISTRY_SERVER is not set
    echo Login to the Container Registry
    az acr login --name ${PROJECT_CONTAINER_REGISTRY_NAME}
    export AZ_CONTAINER_REGISTRY_SERVER=$(az acr list --resource-group ${PROJECT_RG} --query "[].{acrLoginServer:loginServer}" --output tsv)
    if [ "$AZ_CONTAINER_REGISTRY_SERVER" ];  then
        echo variable AZ_CONTAINER_REGISTRY_SERVER is now set:${AZ_CONTAINER_REGISTRY_SERVER}; else
     export AZ_CONTAINER_REGISTRY_SERVER=$(az acr list --resource-group ${PROJECT_RG} --query "[].{acrLoginServer:loginServer}" --output tsv);
    fi
  else
    echo variable AZ_CONTAINER_REGISTRY_SERVER is set:${AZ_CONTAINER_REGISTRY_SERVER}
fi

# export AKS_RG_CREATE=
if [ -z ${AKS_RG_CREATE} ]
  then
    echo variable AKS_RG is not set
    az group create -n ${AKS_RG} -l ${PROJECT_REGION}
    export AKS_RG_CREATE=$(az group list --query "[?starts_with(name, '${AKS_RG}')].{Subscription: id, Location: location, Name: name} | [].Name" --output tsv)
    if [ ${AKS_RG_CREATE} ];  then echo variable AKS_RG is now set:${AKS_RG_CREATE}; fi
  else
    echo variable AKS_RG is set:${AKS_RG_CREATE}
fi

# export AKS_RG_SUBSCRIPTION=
if [ -z ${AKS_RG_SUBSCRIPTION} ]
  then
    echo variable AKS_RG_SUBSCRIPTION is not set
    export AKS_RG_SUBSCRIPTION=$(az group list --query "[?starts_with(name, '${AKS_RG}')].{Subscription: id, Location: location, Name: name} | [].Subscription" --output tsv)
    if [ ${AKS_RG_SUBSCRIPTION} ];  then echo variable AKS_RG_SUBSCRIPTION is now set:${AKS_RG_SUBSCRIPTION}; fi
  else
    echo variable AKS_RG_SUBSCRIPTION is set:${AKS_RG_SUBSCRIPTION}
fi

# export AKS_SPN_ID=
if [ -z ${AKS_SPN_ID} ]
  then
    echo variable AKS_SPN_ID is not set
    #Note that below was specific to Service Principal for Streetworks
    export AKS_SPN_ID=$(az ad sp list --query "[?contains(displayName, '${AKS_SPN_SearchIDString}')].{TenantID: additionalProperties.appOwnerTenantId, UserID: appId, DisplayName: displayName, ObjectType: objectType} | [].UserID" --output tsv)
    #If you were going to create the Service Principal you may do it such as below.
    # ... You would need to get the appID and Secret from the output of running the command
    # ........ and assign them to the AKS_SPN_ID and AKS_SPN_SECRET part of the script ./create_cluster.sh
    # az ad sp create-for-rbac -name "${AKS_NAME}" -password "${AKS_SPN_SECRET}" --role="Contributor" --scopes="${AKS_RG_Subscription}"
    if [ ${AKS_SPN_ID} ];  then echo variable AKS_SPN_ID is now set:${AKS_SPN_ID}; fi
  else
    echo variable AKS_SPN_ID is set:${AKS_SPN_ID}
fi

if [ ${AKS_CLUSTER_NAME} ]
  then
    echo .............................
    echo creating Kubernetes Cluster ${AKS_CLUSTER_NAME}
    echo ...Please be Patient
    echo ......This could take 5 minutes or more
    echo .............................
    az aks create --resource-group ${AKS_RG} --name ${AKS_CLUSTER_NAME} --location ${PROJECT_REGION} --service-principal ${AKS_SPN_ID} --client-secret "${AKS_SPN_SECRET}" --kubernetes-version ${AKS_VERSION} --node-count ${AKS_NODE_COUNT} --generate-ssh-keys
  else
    echo REVIEW your VARIABLES to be defined
fi

if [ "$(az aks list --query "[?starts_with(name, '${AKS_CLUSTER_NAME}')]|[].provisioningState" --output tsv)" = "_Succeeded" ]
  then
    echo ${AKS_CLUSTER_NAME} is online
  else
    until [ "$(az aks list --query "[?starts_with(name, '${AKS_CLUSTER_NAME}')]|[].provisioningState" --output tsv)" = "Succeeded" ] ; do
      echo ${AKS_CLUSTER_NAME} Cluster not ready yet. Waiting 60 Seconds
      sleep 60
    done
    echo ${AKS_CLUSTER_NAME} is online
fi

echo Set Default Context for ${AKS_CLUSTER_NAME}
az aks get-credentials ---resource-group ${AKS_RG} --name ${AKS_CLUSTER_NAME}
