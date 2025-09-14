# Container Apps Deployment Guide

This guide explains how to use the updated deployment script to deploy Container Apps infrastructure.

## Prerequisites

- Azure CLI installed and authenticated
- Docker installed (for building and pushing container images)
- PowerShell 5.1 or PowerShell Core

## Usage

The deployment script now supports deploying individual components using specific templates and parameter files:

### 1. Deploy User-Assigned Managed Identity

```powershell
.\deploy.ps1 -Template identity -ParametersFile dev.identity.parameters.jsonc
```

### 2. Deploy Azure Container Registry (ACR)

```powershell
.\deploy.ps1 -Template acr -ParametersFile dev.acr.parameters.jsonc
```

### 3. Deploy Container App Environment (CAE)

```powershell
.\deploy.ps1 -Template cae -ParametersFile dev.cae.parameters.jsonc
```

### 4. Deploy Container App (CA)

```powershell
.\deploy.ps1 -Template ca -ParametersFile dev.ca.parameters.jsonc
```

## Parameter Files

- `dev.identity.parameters.jsonc` - Parameters for User-Assigned Managed Identity
- `dev.acr.parameters.jsonc` - Parameters for Azure Container Registry
- `dev.cae.parameters.jsonc` - Parameters for Container App Environment  
- `dev.ca.parameters.jsonc` - Parameters for Container App

## Resource Naming

The script validates resource names against Azure naming conventions using the `azureResourceNameValidator.ps1` script. Names follow the pattern:

- User-Assigned Identity: `ua-id-<workload>-<environment>-<instance>` (e.g., ua-id-af65)
- Container Registry: `cr<workload><environment><instance>` (e.g., crghcopilotdev001)
- Container App Environment: `cae-<workload>-<environment>-<instance>` (e.g., cae-gh-copilot-dev-001)
- Container App: `ca-<workload>-<environment>-<instance>` (e.g., ca-gh-copilot-dev-001)

## Deployment Order

1. Deploy User-Assigned Managed Identity first
2. Deploy ACR (if not already deployed)
3. Deploy Container App Environment
4. Deploy Container App

The Container App deployment will automatically assign ACR Pull permissions to the user-assigned managed identity.

## Examples

Complete deployment sequence:

```powershell
# Deploy all components in order
.\deploy.ps1 -Template identity -ParametersFile dev.identity.parameters.jsonc
.\deploy.ps1 -Template acr -ParametersFile dev.acr.parameters.jsonc
.\deploy.ps1 -Template cae -ParametersFile dev.cae.parameters.jsonc
.\deploy.ps1 -Template ca -ParametersFile dev.ca.parameters.jsonc
```

Custom resource group and location:

```powershell
.\deploy.ps1 -ResourceGroupName "rg-custom-dev-001" -Location "eastus2" -Template acr -ParametersFile dev.acr.parameters.jsonc
```