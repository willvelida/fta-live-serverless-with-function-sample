param keyVaultName string
param location string
param functionAppName string
param cosmosDbAccountName string

resource functionApp 'Microsoft.Web/sites@2021-03-01' existing = {
  name: functionAppName
}

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2021-11-15-preview' existing = {
  name: cosmosDbAccountName
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
  ]
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
