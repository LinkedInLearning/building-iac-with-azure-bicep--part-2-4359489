// storage.bicep

@description('The Azure region for the deployment')
param azureRegion string = resourceGroup().location

@maxLength(8)
@minLength(3)
param accountNamePrefix string = 'kg1001'

param projectNameTag string
param projectEnvTag string
param storageSkuName string

// Note: Kineteco name prefix + department name should be less than 24 characters
param storageConfig object = {
  marketing: {
    name: '${accountNamePrefix}marketing'
  }
  accounting: {
    name: '${accountNamePrefix}accounting'
  }
  itoperations: {
    name: '${accountNamePrefix}itoperations'
  }
}

resource createKinetEcoStorages 'Microsoft.Storage/storageAccounts@2021-02-01' = [for config in items(storageConfig): {
  name: '${config.value.name}'
  location: azureRegion
  sku: {
    name: storageSkuName
  }
  kind: 'StorageV2'
  tags:{
    Project: projectNameTag
    Environment: projectEnvTag
  }
}]
