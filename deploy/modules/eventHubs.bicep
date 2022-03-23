param eventhubName string
param location string
param functionAppName string

var eventHubsDataReceiverRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '2b629674-e913-4c01-ae53-ef4638d8f975')
var eventHubsDataSenderRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'a638d3c7-ab3a-418d-83e6-5f17a39d4fde')

resource functionApp 'Microsoft.Web/sites@2021-03-01' existing = {
  name: functionAppName
}

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: eventhubName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' = {
  name: 'readings'
  parent: eventHubNamespace
  properties: {
    messageRetentionInDays: 1
  }
}

resource eventHubAuthPolicy 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2021-11-01' = {
  name: 'ListenSend'
  parent: eventHub
  properties: {
    rights: [
      'Listen'
      'Send'
    ]
  }
}

resource eventHubsDataReceiverRole 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  scope: eventHub
  name: guid(eventHub.id, functionApp.id, eventHubsDataReceiverRoleId)
  properties: {
    principalId: functionApp.identity.principalId
    roleDefinitionId: eventHubsDataReceiverRoleId
    principalType: 'ServicePrincipal'
  }
}

resource eventHubsDataSenderRole 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(eventHub.id, functionApp.id, eventHubsDataSenderRoleId)
  scope: eventHub
  properties: {
    principalId: functionApp.identity.principalId 
    roleDefinitionId: eventHubsDataSenderRoleId
    principalType: 'ServicePrincipal'
  }
}

output eventHubNamespace string = eventHubNamespace.name
output eventHubName string = eventHub.name
