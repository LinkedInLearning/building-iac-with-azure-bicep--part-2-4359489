using './deploy-config-map.bicep'

param azureRegion = 'eastus2'
param projectNameTag = 'Renewable Energy Path'
param projectEnvTag = 'Test2'
param environmentType = 'dev'
param resourceGroupName = 'rg-kineteco-${environmentType}-${azureRegion}'
