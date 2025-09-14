param caName string 
param envName string
param location string = resourceGroup().location
param acrName string
param imageName string
param imageTag string
param userAssignedIdentityName string = 'ua-id-af65'

var environmentResourceId = resourceId('Microsoft.App/managedEnvironments', envName)
var userAssignedResourceId = resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', userAssignedIdentityName)

module containerApp 'br/public:avm/res/app/container-app:0.18.0' = {
  name: 'containerAppDeployment'
  params: {
    // Required parameters
    containers: [
      {
        image: '${acrName}.azurecr.io/${imageName}:${imageTag}'
        name: 'planets-app-container'
        resources: {
          cpu: '0.25'
          memory: '0.5Gi'
        }
      }
    ]
    environmentResourceId: environmentResourceId
    name: caName
    // Non-required parameters
    location: location
    managedIdentities: {
      userAssignedResourceIds: [
        userAssignedResourceId
      ]
    }
    registries: [
      {
        server: '${acrName}.azurecr.io'
        identity: userAssignedResourceId
      }
    ]
  }
}

output resourceId string = containerApp.outputs.resourceId
output name string = containerApp.outputs.name
output userAssignedIdentityResourceId string = userAssignedResourceId
