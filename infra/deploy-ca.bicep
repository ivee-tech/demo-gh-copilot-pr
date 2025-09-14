// Deploy Container App
param caName string
param envName string
param location string = resourceGroup().location
param acrName string
param imageName string
param imageTag string
param userAssignedIdentityName string = 'ua-id-af65'

module ca 'modules/ca.bicep' = {
  name: 'caDeployment'
  params: {
    caName: caName
    envName: envName
    location: location
    acrName: acrName
    imageName: imageName
    imageTag: imageTag
    userAssignedIdentityName: userAssignedIdentityName
  }
}

output resourceId string = ca.outputs.resourceId
output name string = ca.outputs.name
output userAssignedIdentityResourceId string = ca.outputs.userAssignedIdentityResourceId
