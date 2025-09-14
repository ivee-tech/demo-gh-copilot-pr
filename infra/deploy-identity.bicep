// Deploy User-Assigned Managed Identity
param identityName string
param location string = resourceGroup().location

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

output resourceId string = userAssignedIdentity.id
output principalId string = userAssignedIdentity.properties.principalId
output clientId string = userAssignedIdentity.properties.clientId
output name string = userAssignedIdentity.name
