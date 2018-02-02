#!/usr/bin/env bash

# Modify System settings to match project details
export PROJECT_NAME=stwks
export PROJECT_REGION=westeurope


# Assign Core Variables using Project defined variables above
export PROJECT_RG=${PROJECT_NAME}RG
export AKS_Name=${PROJECT_NAME}k8s
export AKS_RG=${AKS_Name}RG
export AKS_RG_CREATE=$(az group list --query "[?starts_with(name, '${AKS_RG}')].{Subscription: id, Location: location, Name: name} | [].Name" --output tsv)
export AKS_Cluster_Name=${AKS_Name}Cluster
export AKS_Region=${PROJECT_REGION}
echo Connecting to resource objects to delete

echo az register Container to delete Cluster objects
az provider register -n Microsoft.ContainerService
echo Register Compute and Network objects for deleting resources
az provider register -n Microsoft.Compute
az provider register -n Microsoft.Network

echo Delete the AKS resources
echo ...AKS Cluster and AKS Resource Group
az aks delete  --resource-group ${AKS_RG} --name ${AKS_Cluster_Name} -y
az group delete -n ${AKS_RG} -y

#cd terraform; terraform destroy -force; cd ..
