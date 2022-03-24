@description('The name of the App Insights instnace that will be deployed.')
param appInsightsName string

@description('The location that the App Insights instance will be deployed to.')
param location string

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location 
  kind: 'web'
  properties: {
    Application_Type: 'web'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
