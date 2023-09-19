targetScope = 'subscription'

@description('Azure region location.')
param azureRegion string = 'eastus2'
param resourceGroupName string = 'rg-kineteco-dep1-${azureRegion}'
param projectNameTag string = 'Renewable Energy Path'
param projectEnvTag string = 'Demo'

@description('Resource Group for Application workloads.')
resource kinetecoResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: azureRegion
  tags: {
    Project: projectNameTag
    Environment: projectEnvTag
  }
}

module appServices 'modules/web-app.bicep' = {
  scope: resourceGroup(kinetecoResourceGroup.name)
  name: 'appDeployment-${uniqueString(kinetecoResourceGroup.id)}'
  params: {
    azureRegion: azureRegion
    appServiceAppDevName: 'appDev${uniqueString(kinetecoResourceGroup.id)}'
    appServiceAppTestName: 'appTest${uniqueString(kinetecoResourceGroup.id)}'
    appServicePlanName: 'kineteco-appServicePlan'
    projectEnvTag: projectNameTag
    projectNameTag: projectEnvTag
  }
}

module storageServices 'modules/storage.bicep' = {
  scope: resourceGroup(kinetecoResourceGroup.name)
  name: 'stgDeployment-${uniqueString(kinetecoResourceGroup.id)}'
  params: {
    azureRegion: azureRegion
    accountNamePrefix: 'kstg1001'
    projectEnvTag: projectNameTag
    projectNameTag: projectEnvTag
  }
}

module networkService 'modules/vnet.bicep' = {
  scope: resourceGroup(kinetecoResourceGroup.name)
  name: 'vnetDeployment-${uniqueString(kinetecoResourceGroup.id)}'
  params: {
    location: azureRegion
    prefix: 'kineteco-dev'
  }
}
