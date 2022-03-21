param eventhubName string
param location string

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

output eventHubNamespace string = eventHubNamespace.name
output eventHubName string = eventHub.name
