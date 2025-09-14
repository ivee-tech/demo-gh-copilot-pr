param location string = resourceGroup().location
param acrName string = 'myAcr'
param acrSku string = 'Basic'
param webAppName string = 'myContainerWebApp'
param imageName string = 'planets-app'
param imageTag string = 'latest'
param appServicePlanName string = 'myAppServicePlan'
param appKind string = 'app,linux,container'

module acr 'modules/acr.bicep' = {
  name: 'acrDeployment'
  params: {
    location: location
    acrName: acrName
    acrSku: acrSku
  }
}

module appService 'modules/app-service.bicep' = {
  name: 'appServiceDeployment'
  params: {
    location: location
    webAppName: webAppName
    acrName: acrName
    imageName: imageName
    imageTag: imageTag
    appServicePlanName: appServicePlanName
    appKind: appKind
  }
}
