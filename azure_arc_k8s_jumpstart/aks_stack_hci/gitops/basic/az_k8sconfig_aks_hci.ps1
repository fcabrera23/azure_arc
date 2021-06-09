# <--- Change the following environment variables according to your Azure service principal name --->

Write-Host "Exporting environment variables"
$appId ='<Your Azure service principal name>'
$password ='<Your Azure service principal password>'
$tenant ='<Your Azure tenant ID>'
$resourceGroup ='<Azure resource group name>'
$ClusterName ='<The name of your AKS cluster running on Azure Stack HCI>'
$appClonedRepo ='<The URL for the "Hello Arc" cloned GitHub repository>'
$subscriptionId ='<Your subscription ID>'


# Connect to Azure
Write-Host "Log in to Azure with Service Principal & Getting AKS credentials (kubeconfig)"
az login --service-principal --username $appId --password $password --tenant $tenant
az account set --subscription $subscriptionId

#Configure Extension install
az config set extension.use_dynamic_install=yes_without_prompt

#Get AKS on Azure Stack HCI cluster credentials
Get-AksHciCredential -Name $ClusterName -Confirm:$false

# Create a namespace for your ingress resources
kubectl create ns cluster-mgmt

# Helm Install 

choco install kubernetes-helm

# Add the official stable repo
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Use Helm to deploy an NGINX ingress controller
helm install nginx ingress-nginx/ingress-nginx -n cluster-mgmt

az k8s-configuration create `
--name hello-arc `
--cluster-name $ClusterName --resource-group $resourceGroup `
--operator-instance-name hello-arc --operator-namespace prod `
--enable-helm-operator `
--helm-operator-params='--set helm.versions=v3' `
--repository-url $appClonedRepo `
--scope namespace --cluster-type connectedClusters `
--operator-params="--git-poll-interval 3s --git-readonly --git-path=releases/prod"