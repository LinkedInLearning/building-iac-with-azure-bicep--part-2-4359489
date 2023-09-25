// Test run after rg removal
targetScope = 'subscription'

@description('Azure region location.')
param azureRegion string = 'eastus2'
param projectNameTag string = 'Renewable Energy Path'
param projectEnvTag string = 'Demo'

@allowed([
  'dev'
  'test'
  'prod'
])
param environmentType string = 'dev'

param resourceGroupName string = 'rg-kineteco-${environmentType}-${azureRegion}'

var environmentConfigurationMap = {
  dev: {
    appServicePlan: {
      sku: {
        name: 'F1'
        capacity: 0
      }
    }
    appServiceApp: {
      alwaysOn: false
    }
    storageAccount: {
      sku: {
        name: 'Standard_LRS'
      }
    }
  }
  test: {
    appServicePlan: {
      sku: {
        name: 'F1'
        capacity: 0
      }
    }
    appServiceApp: {
      alwaysOn: false
    }
    storageAccount: {
      sku: {
        name: 'Standard_LRS'
      }
    }
  }
  prod: {
    appServicePlan: {
      sku: {
        name: 'S1'
        capacity: 3
      }
    }
    appServiceApp: {
      alwaysOn: false
    }
    storageAccount: {
      sku: {
        name: 'Standard_ZRS'
      }
    }
  }
}

@description('Resource Group for Application workloads.')
resource kinetecoResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: azureRegion
  tags: {
    Project: projectNameTag
    Environment: projectEnvTag
  }
}

module appServices '../chapter-4/modules/web-app.bicep' = {
  scope: resourceGroup(kinetecoResourceGroup.name)
  name: 'appDeployment-${uniqueString(kinetecoResourceGroup.id)}'
  params: {
    azureRegion: azureRegion
    appServicePlanSKU: environmentConfigurationMap[environmentType].appServicePlan.sku
    appServiceAppDevName: 'appDev${uniqueString(kinetecoResourceGroup.id)}-${environmentType}'
    appServiceAppTestName: 'appTest${uniqueString(kinetecoResourceGroup.id)}-${environmentType}'
    appServicePlanName: 'kineteco-appServicePlan-${environmentType}'
    projectEnvTag: projectNameTag
    projectNameTag: projectEnvTag
  }
}

module storageServices '../chapter-4/modules/storage.bicep' = {
  scope: resourceGroup(kinetecoResourceGroup.name)
  name: 'stgDeployment-${uniqueString(kinetecoResourceGroup.id)}'
  params: {
    azureRegion: azureRegion
    accountNamePrefix: 'k101${environmentType}'
    storageSkuName: environmentConfigurationMap[environmentType].storageAccount.sku.name
    projectEnvTag: projectNameTag
    projectNameTag: projectEnvTag
  }
}

module networkService '../chapter-4/modules/vnet.bicep' = {
  scope: resourceGroup(kinetecoResourceGroup.name)
  name: 'vnetDeployment-${uniqueString(kinetecoResourceGroup.id)}'
  params: {
    location: azureRegion
    prefix: 'kineteco-${environmentType}'
  }
}

output appServiceAppHostName string = appServices.outputs.webAppHostTest
