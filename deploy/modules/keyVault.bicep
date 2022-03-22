param keyVaultName string
param location string
param functionAppName string
param cosmosDbAccountName string
param eventHubNamespaceName string
param eventhubName string

resource functionApp 'Microsoft.Web/sites@2021-03-01' existing = {
  name: functionAppName
}

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2021-11-15-preview' existing = {
  name: cosmosDbAccountName
}

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2021-11-01' existing = {
  name: eventHubNamespaceName
}

resource eventHubAuthPolicy 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2021-11-01' existing = {
  name: '${eventHubNamespaceName}/${eventhubName}/ListenSend'
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        objectId: functionApp.identity.principalId
        tenantId: functionApp.identity.tenantId
        permissions: {
          secrets: [
            'list'
            'get'
          ]
        }
      }
    ]
  }
  dependsOn: [
    functionApp
    cosmosAccount
    eventHubNamespace
  ]
}

resource eventHubConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: 'eventhubconnectionstring'
  parent: keyVault
  properties: {
    value: eventHubAuthPolicy.listKeys().primaryConnectionString
  }
}

resource cosmosDbConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: 'cosmosdbconnectionstring'
  parent: keyVault
  properties: {
    value: cosmosAccount.listConnectionStrings().connectionStrings[0].connectionString
  }
}

resource cosmosDbEndpointSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: 'cosmosdbendpoint'
  parent: keyVault
  properties: {
    value: cosmosAccount.properties.documentEndpoint
  }
}

resource cosmosDbPrimaryKeySecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: 'cosmosdbprimarykey'
  parent: keyVault
  properties: {
    value: cosmosAccount.listKeys().primaryMasterKey
  }
}
