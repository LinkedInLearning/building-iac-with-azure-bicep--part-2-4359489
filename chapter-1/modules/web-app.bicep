// web-app.bicep

@description('Provide a Azure deployment region/location for the registry.')
param azureRegion string = resourceGroup().location

@description('App service name for Dev env.')
param appServiceAppDevName string

@description('App service name for Test env.')
param appServiceAppTestName string

@description('App service plan name.')
param appServicePlanName string

param projectNameTag string
param projectEnvTag string

resource appServicePlan 'Microsoft.Web/serverFarms@2020-06-01' = {
  name: appServicePlanName
  location: azureRegion
  sku: {
    name: 'F1'
    tier: 'Free'
  }
  tags:{
    Project: projectNameTag
    Environment: projectEnvTag
  }
}

resource appServiceAppDev 'Microsoft.Web/sites@2020-06-01' = {
  name: appServiceAppDevName
  location: azureRegion
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
  tags:{
    Project: projectNameTag
    Environment: projectEnvTag
  }
}

resource appServiceAppTest 'Microsoft.Web/sites@2020-06-01' = {
  name: appServiceAppTestName
  location: azureRegion
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
  tags:{
    Project: projectNameTag
    Environment: projectEnvTag
  }
}

@description('Provides a deployed dev apps host name.')
output webAppHostDev string = appServiceAppDev.properties.defaultHostName

@description('Provides a deployed test apps host name.')
output webAppHostTest string = appServiceAppDev.properties.defaultHostName
