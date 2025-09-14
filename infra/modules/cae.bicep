param envName string
param location string = resourceGroup().location

module managedEnvironment 'br/public:avm/res/app/managed-environment:0.11.0' = {
  name: 'managedEnvironmentDeployment'
  params: {
    // Required parameters
    name: envName
    // Non-required parameters
    location: location
    dockerBridgeCidr: '172.16.0.1/28'
    // infrastructureResourceGroupName: '<infrastructureResourceGroupName>'
    // infrastructureSubnetResourceId: '<infrastructureSubnetResourceId>'
    internal: false
    zoneRedundant: false
    platformReservedCidr: '172.17.17.0/24'
    platformReservedDnsIP: '172.17.17.17'
    workloadProfiles: [
      {
        maximumCount: 3
        minimumCount: 0
        name: 'wp-d4'
        workloadProfileType: 'D4'
      }
    ]
    publicNetworkAccess: 'Enabled'
  }
}

output resourceId string = managedEnvironment.outputs.resourceId
output name string = managedEnvironment.outputs.name
