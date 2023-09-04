// storage.bicep

@description('The Azure region for the deployment')
param azureRegion string = resourceGroup().location

@maxLength(8)
@minLength(3)
param accountNamePrefix string = 'kg1001'

param projectNameTag string
param projectEnvTag string

// Note: Kineteco name prefix + department name should be less than 24 characters
param storageConfig object = {
  marketing: {
    name: '${accountNamePrefix}marketing'
    skuName: 'Standard_LRS'
  }
  accounting: {
    name: '${accountNamePrefix}accounting'
    skuName: 'Premium_LRS'
  }
  itoperations: {
    name: '${accountNamePrefix}itoperations'
    skuName: 'Premium_LRS'
  }
}

resource createKinetEcoStorages 'Microsoft.Storage/storageAccounts@2021-02-01' = [for config in items(storageConfig): {
  name: '${config.value.name}'
  location: azureRegion
  sku: {
    name: config.value.skuName
  }
  kind: 'StorageV2'
  tags:{
    Project: projectNameTag
    Environment: projectEnvTag
  }
}]
