<#
.SYNOPSIS
Validates Azure resource names against best practices.

.DESCRIPTION
Checks abbreviation, pattern, and length for resource names.

.EXAMPLE
./azureResourceNameValidator.ps1 -Name "acr-demo-dev-01" -Type "containerRegistry" -Workload "demo" -Environment "dev" -Instance "01"
#>
param(
    [Parameter(Mandatory)] [string]$Name,
    [Parameter(Mandatory)] [string]$Type,
    [Parameter(Mandatory)] [string]$Workload,
    [Parameter(Mandatory)] [string]$Environment,
    [Parameter(Mandatory)] [string]$Instance
)

$abbreviations = @{
    resourceGroup      = 'rg'
    virtualNetwork     = 'vnet'
    containerRegistry  = 'cr'
    appService         = 'app'
    appServicePlan     = 'asp'
    storageAccount     = 'st'
    keyVault           = 'kv'
    containerAppEnvironment = 'cae'
    containerApp       = 'ca'
    userAssignedIdentity = 'ua-id'
    # Add more as needed
}

$lengthLimits = @{
    resourceGroup      = 90
    virtualNetwork     = 64
    containerRegistry  = 50
    appService         = 60
    appServicePlan     = 60
    storageAccount     = 24
    keyVault           = 24
    containerAppEnvironment = 32
    containerApp       = 32
    userAssignedIdentity = 128
    # Add more as needed
}

$patternDash = '^[a-z0-9\-]+$'
$patternConcat = '^[a-z0-9]+$'

$concatTypes = @('storageAccount','keyVault','containerRegistry')

if (-not $abbreviations.ContainsKey($Type)) {
    Write-Error "Unknown resource type: $Type"
    exit 2
}

$maxLength = $lengthLimits[$Type]
$abbr = $abbreviations[$Type]

if ($concatTypes -contains $Type) {
    # Pattern: <type><workload><environment><instance>
    $expected = "$abbr$Workload$Environment$Instance"
    if ($Name -ne $expected) {
        Write-Error "$Name - should follow pattern: $expected"
        exit 2
    }
    if ($Name -notmatch $patternConcat) {
        Write-Error "$Name - invalid characters (only lowercase letters and numbers allowed)"
        exit 2
    }
} else {
    # Pattern: <type>-<workload>-<environment>-<instance>
    $expected = "$abbr-$Workload-$Environment-$Instance"
    if ($Name -ne $expected) {
        Write-Error "$Name - name should follow pattern: $expected"
        exit 2
    }
    if ($Name -notmatch $patternDash) {
        Write-Error "$Name - invalid characters (only lowercase, numbers, dashes allowed)"
        exit 2
    }
}

if ($Name.Length -gt $maxLength) {
    Write-Error "$Name - name too long (max $maxLength)"
    exit 2
}

Write-Host "Valid Azure resource name."
exit 0
