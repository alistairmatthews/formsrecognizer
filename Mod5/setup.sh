#~!/bin/bash

# Store color codes
NORMAL=$(tput sgr0)
GREEN=$(tput setaf 2)

# Set up the resource group
resourceGroupName=FormsRecognizerResources
printf "${GREEN}Setting up the $resourceGroupName resource group. \n${NORMAL}"
az group create --location westus --name FormsRecognizerResources

# Create a name for the storage account
storageAccName=skillfuncstorage$((10000 + RANDOM % 99999))

# Set up the Azure Storage account
printf "${GREEN}Setting up the $storageAccName storage account. \n${NORMAL}"
az storage account create --name $storageAccName --resource-group $resourceGroupName --kind StorageV2 --sku Standard_LRS

# Create the Forms Recognizer resource
printf "${GREEN}Setting up the Forms Recognizer resource. \n${NORMAL}"
# First, purge it in case there's a recently deleted one
SubID=$(az account show --query id --output tsv)
az resource delete --ids "/subscriptions/${SubID}/providers/Microsoft.CognitiveServices/locations/westus/resourceGroups/${resourceGroupName}/deletedAccounts/FormsRecognizer"
# Now, create the new one
az cognitiveservices account create --kind FormRecognizer --location westus --name FormsRecognizer --resource-group $resourceGroupName --sku F0 --yes

# Create the Cognitive Search resource
printf "${GREEN}Setting up Azure Cognitive Search. \n${NORMAL}"
# Purge any existing search resource with the same name
az resource delete --ids "/subscriptions/${SubID}/resourceGroups/${resourceGroupName}/providers/Microsoft.Search/searchServices/enrichedcognitivesearch"
# Now, create the new one
az search service create --name enrichedcognitivesearch --location westus --resource-group $resourceGroupName --sku Free --partition-count 1 --replica-count 1

printf "${GREEN}Setup completed. \n${NORMAL}"
