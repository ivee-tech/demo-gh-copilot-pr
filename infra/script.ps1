$w = 'ghcopilot'
$env = 'dev'
$rgName = "rg-$w-$env-001"
$location = 'australiaeast'
$acrName = "cr$($w)$($env)001" 
az acr import --name $acrName --resource-group $rgName --source "mcr.microsoft.com/dotnet/samples:aspnetapp" --image "dotnet/samples:aspnetapp" --force


# .\deploy.ps1 -ResourceGroupName $rgName -Location $location -Workload $w -Environment $env


# Deploy User Managed Identity
.\deploy.ps1 -Template identity -ParametersFile dev.identity.parameters.jsonc

# Deploy ACR
.\deploy.ps1 -Template acr -ParametersFile dev.acr.parameters.jsonc

# Deploy Container App Environment  
.\deploy.ps1 -Template cae -ParametersFile dev.cae.parameters.jsonc

$idName = 'ua-id-af65'
$principalId = az identity show --name $idName --resource-group $rgName --query principalId -o tsv
$acrId = $(az acr show --name $acrName --resource-group $rgName --query id -o tsv)
az role assignment create `
  --assignee $principalId `
  --scope $acrId `
  --role AcrPull

# Deploy Container App
.\deploy.ps1 -Template ca -ParametersFile dev.ca.parameters.jsonc
