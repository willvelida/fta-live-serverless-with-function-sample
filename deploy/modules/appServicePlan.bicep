@description('The name of the App Service Plan that will be deployed.')
param appServicePlanName string

@description('The location that the App Service Plan will be deployed to.')
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
