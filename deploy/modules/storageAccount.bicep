param storageAccountName string
param location string
param storageSku string
param deployContainers bool

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageSku
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    accessTier: 'Hot'
  }
  
  resource blobServices 'blobServices' = {
    name: 'default'

    resource blobTriggerContainer 'containers' = {
      name: 'blobtriggercontainer'
    }

    resource eventGridTriggerContainer 'containers' = {
      name: 'eventgridtriggercontainer'
    }
  }
}

