// Parameters used by this template from dev.parameters.jsonc:
// - location, acrName, acrSku
// Other parameters in the file are ignored during deployment

param location string = resourceGroup().location
param acrName string = 'myAcr'
param acrSku string = 'Basic'

module acr 'modules/acr.bicep' = {
  name: 'acrDeployment'
  params: {
    location: location
    acrName: acrName
    acrSku: acrSku
  }
}
