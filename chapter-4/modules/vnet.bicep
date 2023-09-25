// vnet.bicep

param location string
param prefix string
param vnetSettings object = {
  addressPrefixes: [
    '10.0.0.0/16'
  ]
  subnets: [
    { 
      name: 'default'
      addressPrefix: '10.0.0.0/24'
    }
    { 
      name: 'appSubnet'
      addressPrefix: '10.0.8.0/24'
    }
    { 
      name: 'storageSubnet'
      addressPrefix: '10.0.16.0/24'
    }
  ]
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-02-01' = {
  name: '${prefix}-default-nsg'
  location: location
  properties: {
    securityRules: [
    ]
  }
}


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: '${prefix}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: vnetSettings.addressPrefixes
    }
    subnets: [ for subnet in vnetSettings.subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        networkSecurityGroup: {
          id: networkSecurityGroup.id
        }
        privateEndpointNetworkPolicies: 'disabled'
      }
    }]
  }
}
