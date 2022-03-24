@description('The name of the App Service Plan that will be deployed.')
param appServicePlanName string

@description('The location that the App Service Plan will be deployed to.')
param location string

resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appServicePlanName
  location: location
  kind: 'elastic'
  sku: {
    name: 'EP1'
    tier: 'ElasticPremium'
  }
  properties: {
    maximumElasticWorkerCount: 20
  } 
}

output appServicePlanId string = appServicePlan.id
