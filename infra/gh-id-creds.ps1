# Set your variables
$subscriptionId = $env:MNGENV_SUBSCRIPTION_ID
# az account set --subscription $subscriptionId
$rgName = "rg-ghcopilot-dev-001"
$githubOrg = "ivee-tech"
$githubRepo = "demo-gh-copilot-pr"

# user assigned identity name
$uaIdName = "ua-id-ghcopilot-dev-002" 
az identity create --name $uaIdName --resource-group $rgName --location $location

$issuer = "https://token.actions.githubusercontent.com"
$audience = "api://AzureADTokenExchange"
# Create federated credential for main branch
$ficIdName = "fic-repo-$uaIdName"
$mainBranchSubject = "repo:$($githubOrg)/$($githubRepo):ref:refs/heads/main"
az identity federated-credential create --name $ficIdName --identity-name $uaIdName --resource-group $rgName --issuer $issuer --subject $mainBranchSubject --audiences $audience

# Create federated credential for pull requests
$ficIdName = "fic-pr-$uaIdName"
$prSubject = "repo:$($githubOrg)/$($githubRepo):pull_request"
az identity federated-credential create --name $ficIdName --identity-name $uaIdName --resource-group $rgName --issuer $issuer --subject $prSubject --audiences $audience

# Create federated credential for environment (optional)
$ficIdName = "fic-env-dev-$uaIdName"
$envSubject = "repo:$($githubOrg)/$($githubRepo):environment:dev"
az identity federated-credential create --name $ficIdName --identity-name $uaIdName --resource-group $rgName --issuer $issuer --subject $envSubject --audiences $audience
