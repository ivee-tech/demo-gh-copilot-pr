# Deploy Container Apps using Azure CLI
# Usage: .\deploy.ps1 -ResourceGroupName <name> -Location <location> -Template <template> -ParametersFile <parameters>
param(
    [string]$ResourceGroupName = "rg-ghcopilot-dev-001",
    [string]$Location = "australiaeast",
    [string]$Workload = 'ghcopilot',
    [string]$Environment = 'dev',
    [Parameter(Mandatory)]
    [ValidateSet('cae', 'ca', 'acr', 'identity')]
    [string]$Template,
    [Parameter(Mandatory)]
    [string]$ParametersFile
)

$ErrorActionPreference = "Stop"

# Validate template and parameters file exist
$templateFile = Join-Path $PSScriptRoot "deploy-$Template.bicep"
$parametersFilePath = Join-Path $PSScriptRoot $ParametersFile

if (-not (Test-Path $templateFile)) {
    Write-Error "Template file not found: $templateFile"
    exit 1
}

if (-not (Test-Path $parametersFilePath)) {
    Write-Error "Parameters file not found: $parametersFilePath"
    exit 1
}

# Load parameters from JSON file
$parametersJson = Get-Content $parametersFilePath -Raw | ConvertFrom-Json
$resourceParams = $parametersJson.parameters

# Resource name definitions for validation based on template type
$resourceNames = @()

switch ($Template) {
    'acr' {
        $resourceNames += @{ Name = $resourceParams.acrName.value; Type = 'containerRegistry'; Workload = $Workload; Environment = $Environment; Instance = '001' }
    }
    'cae' {
        $resourceNames += @{ Name = $resourceParams.envName.value; Type = 'containerAppEnvironment'; Workload = $Workload; Environment = $Environment; Instance = '001' }
    }
    'ca' {
        $resourceNames += @{ Name = $resourceParams.caName.value; Type = 'containerApp'; Workload = $Workload; Environment = $Environment; Instance = '001' }
        $resourceNames += @{ Name = $resourceParams.envName.value; Type = 'containerAppEnvironment'; Workload = $Workload; Environment = $Environment; Instance = '001' }
    }
    'identity' {
        $resourceNames += @{ Name = $resourceParams.identityName.value; Type = 'userAssignedIdentity'; Workload = $Workload; Environment = $Environment; Instance = 'af65' }
    }
}

# Always validate resource group name
$resourceNames += @{ Name = $ResourceGroupName; Type = 'resourceGroup'; Workload = $Workload; Environment = $Environment; Instance = '001' }

# Validate resource names
$validatorPath = Join-Path $PSScriptRoot 'azureResourceNameValidator.ps1'

$resourceNames | ForEach-Object {
    $res = $_
    Write-Host "Validating $($res.Type) name: $($res.Name) ..."
    & $validatorPath -Name $res.Name -Type $res.Type -Workload $res.Workload -Environment $res.Environment -Instance $res.Instance
    if ($LASTEXITCODE -ne 0) {
        Write-Error "$($res.Type) name validation failed for $($res.Name)."
        exit 2
    }
}

Write-Host "All resource names validated successfully."

# Create resource group if it doesn't exist
Write-Host "Ensuring resource group $ResourceGroupName exists in $Location..."
az group create --name $ResourceGroupName --location $Location --only-show-errors

# Deploy the template
Write-Host "Deploying $Template template with parameters from $ParametersFile..."

$deploymentName = "$Template-deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

az deployment group create `
    --resource-group $ResourceGroupName `
    --template-file $templateFile `
    --parameters "@$parametersFilePath" `
    --name $deploymentName `
    --only-show-errors

if ($LASTEXITCODE -ne 0) {
    Write-Error "$Template deployment failed."
    exit 1
}

Write-Host "$Template deployment completed successfully."

# Special handling for Container App - assign ACR Pull permissions
if ($Template -eq 'ca') {
    Write-Host "Assigning ACR Pull permissions to Container App user-assigned managed identity..."
    
    # Get the deployment outputs
    $deploymentOutputs = az deployment group show `
        --resource-group $ResourceGroupName `
        --name $deploymentName `
        --query 'properties.outputs' -o json | ConvertFrom-Json
    
    if ($deploymentOutputs -and $deploymentOutputs.userAssignedIdentityResourceId) {
        $userIdentityResourceId = $deploymentOutputs.userAssignedIdentityResourceId.value
        $acrName = $resourceParams.acrName.value
        
        Write-Host "User-Assigned Identity Resource ID: $userIdentityResourceId"
        Write-Host "ACR Name: $acrName"
        
        # Get the principal ID of the user-assigned managed identity
        $principalId = az identity show --ids $userIdentityResourceId --query principalId -o tsv
        
        if ($LASTEXITCODE -eq 0 -and $principalId) {
            Write-Host "Principal ID: $principalId"
            
            # Get the ACR resource ID
            $acrResourceId = az acr show --name $acrName --query id -o tsv
            
            if ($LASTEXITCODE -eq 0 -and $acrResourceId) {
                # Assign AcrPull role to the managed identity
                Write-Host "Assigning AcrPull role to user-assigned managed identity..."
                az role assignment create `
                    --assignee $principalId `
                    --role "AcrPull" `
                    --scope $acrResourceId `
                    --only-show-errors
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "ACR Pull permissions assigned successfully."
                } else {
                    Write-Warning "Failed to assign ACR Pull permissions. You may need to assign them manually."
                }
            } else {
                Write-Warning "Could not find ACR resource. Please verify ACR deployment and assign permissions manually."
            }
        } else {
            Write-Warning "Could not retrieve principal ID from user-assigned managed identity."
        }
    } else {
        Write-Warning "Could not retrieve user-assigned identity resource ID from deployment outputs."
    }
}

# Special handling for ACR - build and push image after deployment
if ($Template -eq 'acr') {
    $acrName = $resourceParams.acrName.value
    
    # Check if we have image parameters in a separate CA parameters file
    $caParamsFile = Join-Path $PSScriptRoot "dev.ca.parameters.jsonc"
    if (Test-Path $caParamsFile) {
        $caParamsJson = Get-Content $caParamsFile -Raw | ConvertFrom-Json
        $imageName = $caParamsJson.parameters.imageName.value
        $imageTag = $caParamsJson.parameters.imageTag.value
        
        if ($imageName -and $imageTag) {
            $dockerImagePath = "../planets"  # Path to Dockerfile directory
            
            Write-Host "Building and pushing image to ACR..."
            Write-Host "ACR Name: $acrName"
            Write-Host "Image: $imageName`:$imageTag"
            
            # Login to ACR
            az acr login --name $acrName
            
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Failed to login to ACR $acrName."
                exit 1
            }
            
            # Build and push the image
            $fullImageName = "$acrName.azurecr.io/$imageName`:$imageTag"
            Write-Host "Building image: $fullImageName"
            
            Push-Location $dockerImagePath
            try {
                docker build -t $fullImageName .
                if ($LASTEXITCODE -ne 0) {
                    Write-Error "Docker build failed."
                    exit 1
                }
                
                docker push $fullImageName
                if ($LASTEXITCODE -ne 0) {
                    Write-Error "Docker push failed."
                    exit 1
                }
                
                Write-Host "Image successfully pushed to ACR."
            }
            finally {
                Pop-Location
            }
        }
    }
}
