param location string = resourceGroup().location
param acrName string = 'myAcr'
param acrSku string = 'Basic' // Basic, Standard, Premium

module acr 'br/public:avm/res/container-registry/registry:0.6.0' = {
  name: 'deployAcr'
  params: {
    name: acrName
    location: location
    acrSku: acrSku
    publicNetworkAccess: 'Enabled' // or 'Disabled'
    acrAdminUserEnabled: true
    tags: {
    }
  }
}
