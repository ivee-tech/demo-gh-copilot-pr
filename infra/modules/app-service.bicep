param location string = resourceGroup().location
param webAppName string = 'myContainerWebApp'
param acrName string
param imageName string
param imageTag string
param appServicePlanName string = 'myAppServicePlan'
param appKind string = 'app,linux,container'

module appServicePlan 'br/public:avm/res/web/serverfarm:0.5.0' = {
  name: 'serverfarmDeployment'
  params: {
    name: appServicePlanName
    location: location
  }
}

module site 'br/public:avm/res/web/site:0.19.0' = {
  name: 'siteDeployment'
  params: {
    // Required parameters
    kind: appKind
    name: webAppName
    serverFarmResourceId: appServicePlan.outputs.resourceId
    // Non-required parameters
    location: location
    siteConfig: {
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
      ]
      ftpsState: 'FtpsOnly'
      linuxFxVersion: 'DOCKER|${acrName}.azurecr.io/${imageName}:${imageTag}'
      minTlsVersion: '1.2'
    }
  }
}
