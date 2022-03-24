@description('Specifies the region of all resources. Defaults to location of resource group')
param location string = resourceGroup().location

@description('Name of the application. Used as a suffix for resources')
param applicationName string = uniqueString(resourceGroup().id)

@description('The SKU for the storage account')
param storageSku string = 'Standard_LRS'

var storageAccountName = 'fnstor${replace(applicationName, '-', '')}'
var appInsightsName = '${applicationName}-ai'
var appServicePlanName = '${applicationName}-asp'
var eventhubName = 'eh${applicationName}'
var cosmosDbAccountName = '${applicationName}cosmosdb'
var cosmosDbName = 'ReadingsDB'
var cosmosContainerName = 'Readings'
var cosmosThroughput = 400
var functionAppName = '${applicationName}-fa'
var functionRuntime = 'dotnet'

module appInsights 'modules/appInsights.bicep' = {
  name: appInsightsName
  params: {
    appInsightsName: appInsightsName
    location: location
  }
}

module appServicePlan 'modules/appServicePlan.bicep' = {
  name: appServicePlanName
  params: {
    appServicePlanName: appServicePlanName
    location: location
  }
}

module cosmosDb 'modules/cosmosDB.bicep' = {
  name: cosmosDbAccountName
  params: {
    cosmosContainerName: cosmosContainerName
    cosmosDbAccountName: cosmosDbAccountName
    cosmosDbName: cosmosDbName
    cosmosThroughput: cosmosThroughput
    location: location
  }
}

module eventHub 'modules/eventHubs.bicep' = {
  name: eventhubName
  params: {
    eventhubName: eventhubName 
    location: location
    functionAppName: functionAppName
  }
}

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

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.outputs.appServicePlanId
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.outputs.appInsightsInstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: 'InstrumentationKey=${appInsights.outputs.appInsightsInstrumentationKey}'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionRuntime
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'DatabaseName'
          value: cosmosDb.outputs.cosmosDbName
        }
        {
          name: 'ContainerName'
          value: cosmosDb.outputs.cosmosContainerName
        }
        {
          name: 'CosmosDbEndpoint'
          value: cosmosDb.outputs.cosmosDbEndpoint
        }
        {
          name: 'EventHubConnection__fullyQualifiedNamespace'
          value: '${eventhubName}.servicebus.windows.net'
        }
      ]
    }
    httpsOnly: true
  } 
  identity: {
    type: 'SystemAssigned'
  }
}

module sqlRoles 'modules/sqlRoleDefinition.bicep' = {
  name: 'sqlroles'
  params: {
    cosmosDbAccountName: cosmosDbAccountName
    functionAppPrincipalId: functionApp.identity.principalId
  }
  dependsOn: [
    cosmosDb
  ]
}
