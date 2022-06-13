#~!/bin/bash

# Set up the resource group
resourceGroupName=FormsRecognizerResources
printf "Setting up the FormsRecognizerResources resource group."
az group create --location westus --name FormsRecognizerResources

# Create a name for the storage account
storageAccName=formsrecstorage$((10000 + RANDOM % 99999))

# Set up the Azure Storage account

printf "Setting up the $storageAccName storage account. \n\n"
az storage account create --name $storageAccName --resource-group $resourceGroupName --kind StorageV2 --sku Standard_LRS

# Get the connection string for the new storage account
connectionString=$(az storage account show-connection-string --name $storageAccName --key primary --query connectionString)

# Enable CORS on the storage account
az storage cors add --methods DELETE GET HEAD MERGE OPTIONS POST PUT --origins * --services b --allowed-headers * --max-age 200 --exposed-headers * --connection-string $connectionString

# Create the storage containers

az storage container create --account-name $storageAccName --name 1040examples --auth-mode login
az storage container create --account-name $storageAccName --name 1099examples --auth-mode login

# Upload the sample data

az storage blob upload-batch -d 1040examples --account-name $storageAccName --connection-string $connectionString -s "trainingdata/1040examples" --pattern *.pdf
az storage blob upload-batch -d 1099examples --account-name $storageAccName --connection-string $connectionString -s "trainingdata/1099examples" --pattern *.pdf

# Create the Forms Recognizer resource
printf "Setting up the Forms Recognizer resource. \n\n"
az cognitiveservices account create --kind FormRecognizer --location westus --name FormsRecognizer --resource-group $resourceGroupName --sku F0 --yes
