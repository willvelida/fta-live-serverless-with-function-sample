param appServicePlanName string
param location string

resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appServicePlanName
  location: location
  kind: 'functionapp'
  sku: {
    name: 'Y1'
  }
  properties: {
    
  } 
}

output appServicePlanId string = appServicePlan.id
