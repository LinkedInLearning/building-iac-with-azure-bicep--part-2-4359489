// Test run after rg removal
targetScope = 'subscription'

@description('Azure region location.')
param azureRegion string = 'eastus2'
param resourceGroupName string = 'rg-kineteco-dep1-${azureRegion}'
param projectNameTag string = 'Renewable Energy Path'
param projectEnvTag string = 'Demo'

@allowed([
  'Development'
  'Test'
  'Production'
])
param environmentType string = 'Development'

var environmentConfigurationMap = {
  Development: {
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
  Test: {
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
  Production: {
    appServicePlan: {
      sku: {
        name: 'P2V3'
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
    appServiceAppDevName: 'appDev${uniqueString(kinetecoResourceGroup.id)}'
    appServiceAppTestName: 'appTest${uniqueString(kinetecoResourceGroup.id)}'
    appServicePlanName: 'kineteco-appServicePlan'
    projectEnvTag: projectNameTag
    projectNameTag: projectEnvTag
  }
}

module storageServices '../chapter-4/modules/storage.bicep' = {
  scope: resourceGroup(kinetecoResourceGroup.name)
  name: 'stgDeployment-${uniqueString(kinetecoResourceGroup.id)}'
  params: {
    azureRegion: azureRegion
    accountNamePrefix: 'kstg1001'
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
    prefix: 'kineteco-dev'
  }
}

output appServiceAppHostName string = appServices.outputs.webAppHostTest
