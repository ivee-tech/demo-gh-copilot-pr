// Parameters used by this template from dev.parameters.jsonc:
// - location, webAppName, acrName, imageName, imageTag, appServicePlanName, appKind
// Other parameters in the file are ignored during deployment

param location string = resourceGroup().location
param webAppName string = 'myContainerWebApp'
param acrName string = 'myAcr'
param imageName string = 'planets-app'
param imageTag string = 'latest'
param appServicePlanName string = 'myAppServicePlan'
param appKind string = 'app,linux,container'

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
