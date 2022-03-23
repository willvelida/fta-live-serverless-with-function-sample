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
var keyVaultName = 'kv${applicationName}'

module storageAccount 'modules/storageAccount.bicep' = {
  name: storageAccountName
  params: {
    location: location
    storageAccountName: storageAccountName 
    storageSku: storageSku
  }
}

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

module keyVault 'modules/keyVault.bicep' = {
  name: keyVaultName
  params: {
    cosmosDbAccountName: cosmosDbAccountName 
    functionAppName: functionAppName
    keyVaultName: keyVaultName
    location: location
  }
}

module functionApp 'modules/functionApp.bicep' = {
  name: functionAppName
  params: {
    appInsightsInstrumentationKey: appInsights.outputs.appInsightsInstrumentationKey
    appServicePlanId: appServicePlan.outputs.appServicePlanId
    cosmosDbAccountName: cosmosDb.name
    containerName: cosmosDb.outputs.cosmosContainerName
    cosmosDbEndpoint: cosmosDb.outputs.cosmosDbEndpoint
    databaseName: cosmosDb.outputs.cosmosDbName
    eventhubNamespace: eventHub.outputs.eventHubNamespace
    functionAppName: functionAppName
    functionAppStorageAccount: storageAccount.name
    location: location
  }
}

module sqlRoles 'modules/sqlRoleDefinition.bicep' = {
  name: 'sqlroles'
  params: {
    cosmosDbAccountName: cosmosDbAccountName
    functionAppPrincipalId: functionApp.outputs.functionAppPrincipalId
  }
}
