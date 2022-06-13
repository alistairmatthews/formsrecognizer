#~!/bin/bash

# Store color codes
NORMAL=$(tput sgr0)
GREEN=$(tput setaf 2)

# Set up the resource group
resourceGroupName=FormsRecognizerResources
printf "${GREEN}Setting up the FormsRecognizerResources resource group. \n"
az group create --location westus --name FormsRecognizerResources

# Create a name for the storage account
storageAccName=formsrecstorage$((10000 + RANDOM % 99999))

# Set up the Azure Storage account
printf "${GREEN}Setting up the $storageAccName storage account. \n"
az storage account create --name $storageAccName --resource-group $resourceGroupName --kind StorageV2 --sku Standard_LRS

# Get the connection string for the new storage account
connectionString=$(az storage account show-connection-string --name $storageAccName --key primary --query connectionString)

# Enable CORS on the storage account
az storage cors add --methods DELETE GET HEAD MERGE OPTIONS POST PUT --origins * --services b --allowed-headers * --max-age 200 --exposed-headers * --connection-string $connectionString

# Create the storage containers
printf "${GREEN}Creating containers for the sample forms. \n"
az storage container create --account-name $storageAccName --name 1040examples --auth-mode login
az storage container create --account-name $storageAccName --name 1099examples --auth-mode login

# Upload the sample data
printf "${GREEN}Uploading the sample forms to the storage account. \n"
az storage blob upload-batch -d 1040examples --account-name $storageAccName --connection-string $connectionString -s "trainingdata/1040examples" --pattern *.pdf
az storage blob upload-batch -d 1099examples --account-name $storageAccName --connection-string $connectionString -s "trainingdata/1099examples" --pattern *.pdf

# Create the Forms Recognizer resource
printf "${GREEN} Setting up the Forms Recognizer resource. \n"
# First, purge it in case there's a recently deleted one
SubID=$(az account show --query id --output tsv)
az resource delete --ids "/subscriptions/${SubID}/providers/Microsoft.CognitiveServices/locations/westus/resourceGroups/${resourceGroupName}/deletedAccounts/FormsRecognizer"
# Now, create the new one
az cognitiveservices account create --kind FormRecognizer --location westus --name FormsRecognizer --resource-group $resourceGroupName --sku F0 --yes
