@description('Specifies the region of all resources. Defaults to location of resource group')
param location string = resourceGroup().location

@description('Name of the application. Used as a suffix for resources')
param applicationName string = uniqueString(resourceGroup().id)

@description('The SKU for the storage account')
param storageSku string = 'Standard_LRS'

@description('Friendly name for the SQL Role Definition')
param roleDefinitionName string = 'Function Read Write Role'

@description('Data actions required by the Role defintiion')
param dataActions array = [
  'Microsoft.DocumentDB/databaseAccounts/readMetadata'
  'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
]

var storageAccountName = 'fnstor${replace(applicationName, '-', '')}'
var appInsightsName = '${applicationName}-ai'
var appServicePlanName = '${applicationName}-asp'
var eventhubName = 'eh${applicationName}'
var cosmosDbAccountName = '${applicationName}cosmosdb'
var cosmosDbName = 'ReadingsDB'
var cosmosContainerName = 'Readings'
var cosmosThroughput = 400
var functionAppName = '${applicationName}-fa'
var keyVaultName = 'kv${applicationName}'

module storageAccount 'modules/storageAccount.bicep' = {
  name: 'functionstorage'
  params: {
    location: location
    storageAccountName: storageAccountName 
    storageSku: storageSku
  }
}

module appInsights 'modules/appInsights.bicep' = {
  name: 'appinsights'
  params: {
    appInsightsName: appInsightsName
    location: location
  }
}

module appServicePlan 'modules/appServicePlan.bicep' = {
  name: 'appserviceplan'
  params: {
    appServicePlanName: appServicePlanName
    location: location
  }
}

module cosmosDb 'modules/cosmosDB.bicep' = {
  name: 'cosmosdb'
  params: {
    cosmosContainerName: cosmosContainerName
    cosmosDbAccountName: cosmosDbAccountName
    cosmosDbName: cosmosDbName
    cosmosThroughput: cosmosThroughput
    location: location
  }
}

module eventHub 'modules/eventHubs.bicep' = {
  name: 'eventhub'
  params: {
    eventhubName: eventhubName 
    location: location
  }
}

module keyVault 'modules/keyVault.bicep' = {
  name: 'keyvault'
  params: {
    cosmosDbAccountName: cosmosDbAccountName 
    functionAppName: functionAppName
    keyVaultName: keyVaultName
    location: location
  }
}

module functionApp 'modules/functionApp.bicep' = {
  name: 'functionapp'
  params: {
    appInsightsInstrumentationKey: appInsights.outputs.appInsightsInstrumentationKey
    appServicePlanId: appServicePlan.outputs.appServicePlanId
    containerName: cosmosDb.outputs.cosmosContainerName
    cosmosDbEndpoint: cosmosDb.outputs.cosmosDbEndpoint
    databaseName: cosmosDb.outputs.cosmosDbName
    eventhubName: eventHub.outputs.eventHubName
    eventhubNamespace: eventHub.outputs.eventHubNamespace
    functionAppName: functionAppName
    functionAppStorageAccount: storageAccount.name
    location: location
  }
}

module sqlRoles 'modules/sqlRoleDefinition.bicep' = {
  name: 'sqlroles'
  params: {
    cosmosDbAccountName: cosmosDb.outputs.cosmosDbName
    cosmosDbId: cosmosDb.outputs.cosmosAccountId
    dataActions: dataActions
    functionAppPrincipalId: functionApp.outputs.functionAppPrincipalId
    roleDefinitionName: roleDefinitionName
  }
}
