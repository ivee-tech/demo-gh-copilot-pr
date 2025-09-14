// Deploy Container App Environment
param envName string
param location string = resourceGroup().location

module cae 'modules/cae.bicep' = {
  name: 'caeDeployment'
  params: {
    envName: envName
    location: location
  }
}

output environmentId string = cae.outputs.resourceId
