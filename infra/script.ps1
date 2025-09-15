$w = 'ghcopilot'
$env = 'dev'
$rgName = "rg-$w-$env-001"
$location = 'australiaeast'
$acrName = "cr$($w)$($env)002" 
az acr import --name $acrName --resource-group $rgName --source "mcr.microsoft.com/dotnet/samples:aspnetapp" --image "dotnet/samples:aspnetapp" --force


# .\deploy.ps1 -ResourceGroupName $rgName -Location $location -Workload $w -Environment $env


# Deploy User Managed Identity
.\deploy.ps1 -Template identity -ParametersFile dev.identity.parameters.jsonc

# check ACR name availability
$subscriptionId = az account show --query id -o tsv
$accessToken = az account get-access-token --query accessToken -o tsv
$url = "https://management.azure.com/subscriptions/$subscriptionId/providers/Microsoft.ContainerRegistry/checkNameAvailability?api-version=2023-01-01-preview" 
$body = @{
    name = $acrName
    type = "Microsoft.ContainerRegistry/registries"
} | ConvertTo-Json

$headers = @{
    'Authorization' = "Bearer $accessToken"
    'Content-Type' = 'application/json'
}
$response = Invoke-RestMethod -Method Post -Uri $url -Body $body -Headers $headers
$response

# Deploy ACR
.\deploy.ps1 -Template acr -ParametersFile dev.acr.parameters.jsonc

# Deploy Container App Environment  
.\deploy.ps1 -Template cae -ParametersFile dev.cae.parameters.jsonc

$idName = 'ua-id-ghcopilot-dev-001'
$principalId = az identity show --name $idName --resource-group $rgName --query principalId -o tsv
$acrId = $(az acr show --name $acrName --resource-group $rgName --query id -o tsv)
az role assignment create `
  --assignee $principalId `
  --scope $acrId `
  --role AcrPull

# Deploy Container App
.\deploy.ps1 -Template ca -ParametersFile dev.ca.parameters.jsonc


# configure APp
$appId = ''
$tenantId = ''
$subscriptionId = ''
az ad app create --display-name "app-ghcopilot-dev" --query "appId" --output tsv