# Set your variables
$subscriptionId = $env:MNGENV_SUBSCRIPTION_ID
$rgName = "rg-ghcopilot-dev-001"
$githubOrg = "ivee-tech"
$githubRepo = "demo-gh-copilot-pr"

# user assigned identity name
$uaIdName = "ua-id-ghcopilot-dev-002" 

# federated identity credential name
$ficIdName = "fic-$uaIdName"

# create prerequisites if required.
# otherwise make sure that existing resources names are set in variables above
# az account set --subscription $subscriptionId
az identity create --name $uaIdName --resource-group $rgName --location $location

# Create federated credential for main branch
$mainBranchSubject = "repo:$($githubOrg)/$($githubRepo):ref:refs/heads/main"
$issuer = "https://token.actions.githubusercontent.com"
az identity federated-credential create --name $ficIdName --identity-name $uaIdName --resource-group $rgName --issuer $issuer --subject $mainBranchSubject --audiences 'api://AzureADTokenExchange'
#
az identity federated-credential create --name $ficId --identity-name $uaId --resource-group $rg --issuer 'https://aks.azure.com/issuerGUID' --subject 'system:serviceaccount:ns:svcaccount' --audiences 'api://AzureADTokenExchange'

Remove-Item "main-cred.json" -Force

<#
# Create federated credential for pull requests
$prSubject = "repo:$githubOrg/$githubRepo:pull_request"
$prJson = @"
{
  "name": "github-pr",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "$prSubject",
  "audiences": ["api://AzureADTokenExchange"]
}
"@

$prJson | Out-File -FilePath "pr-cred.json" -Encoding utf8
az ad app federated-credential create --id $appObjectId --parameters "@pr-cred.json"
Remove-Item "pr-cred.json" -Force

# Create federated credential for environment (optional)
$envSubject = "repo:$githubOrg/$githubRepo:environment:dev"
$envJson = @"
{
  "name": "github-env-dev",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "$envSubject",
  "audiences": ["api://AzureADTokenExchange"]
}
"@

$envJson | Out-File -FilePath "env-cred.json" -Encoding utf8
az ad app federated-credential create --id $appObjectId --parameters "@env-cred.json"
Remove-Item "env-cred.json" -Force
#>