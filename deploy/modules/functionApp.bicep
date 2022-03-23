param functionAppName string
param location string
param appServicePlanId string
param functionAppStorageAccount string
param appInsightsInstrumentationKey string
param databaseName string
param containerName string
param cosmosDbEndpoint string
param eventhubNamespace string
param cosmosDbAccountName string

var functionRuntime = 'dotnet'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' existing = {
  name: functionAppStorageAccount
}

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2021-11-01' existing = {
  name: eventhubNamespace
}

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts@2021-11-15-preview' existing = {
  name: cosmosDbAccountName

  resource db 'sqlDatabases' existing = {
    name: databaseName

    resource container 'containers' existing = {
      name: containerName
    }
  }
}

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlanId
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
          value: appInsightsInstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: 'InstrumentationKey=${appInsightsInstrumentationKey}'
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
          value: databaseName
        }
        {
          name: 'ContainerName'
          value: containerName
        }
        {
          name: 'CosmosDbEndpoint'
          value: cosmosDbEndpoint
        }
        {
          name: 'EventHubConnection'
          value: eventHubNamespace.properties.serviceBusEndpoint
        }
      ]
    }
    httpsOnly: true
  } 
  identity: {
    type: 'SystemAssigned'
  }
  dependsOn: [
    storageAccount
    cosmosDb
    cosmosDb::db
    cosmosDb::db::container
  ]
}

output functionAppPrincipalId string = functionApp.identity.principalId
