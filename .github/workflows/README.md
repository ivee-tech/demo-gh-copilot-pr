# GitHub Actions Workflows Documentation

This repository contains comprehensive GitHub Actions workflows for deploying a Three.js planets application to Azure Container Apps.

## 🚀 Available Workflows

### 1. **Full Deployment Pipeline** (`full-deploy.yml`)
**Trigger:** Manual (workflow_dispatch)

Complete end-to-end deployment including infrastructure provisioning, container build, and application deployment.

**Use Cases:**
- Initial deployment to a new environment
- Complete environment refresh
- Major updates requiring full redeployment

**Inputs:**
- `environment`: Target environment (dev/staging/prod)
- `skip_infrastructure`: Skip infrastructure deployment if already exists
- `custom_image_tag`: Use existing image instead of building new one

### 2. **Deploy Infrastructure** (`deploy-infrastructure.yml`)
**Trigger:** Manual (workflow_dispatch)

Deploys only the Azure infrastructure components using Bicep templates.

**Components Deployed:**
- Resource Group
- User Assigned Managed Identity
- Azure Container Registry (ACR)
- Container App Environment
- RBAC configuration

**Inputs:**
- `environment`: Target environment (dev/staging/prod)
- `validate_only`: Run What-If analysis only without deploying

### 3. **Build and Push Container Image** (`build-container.yml`)
**Trigger:** 
- Push to main/develop branches (when planets/ directory changes)
- Pull requests to main
- Manual trigger

Builds Docker container from the planets app and pushes to Azure Container Registry.

**Features:**
- Multi-platform builds
- Image vulnerability scanning with Docker Scout
- Build caching for faster builds
- Automated tagging based on branch and commit

**Inputs:**
- `tag`: Custom image tag (manual trigger only)

### 4. **Deploy Application Revision** (`deploy-app.yml`)
**Trigger:**
- Automatic after successful container build
- Manual trigger

Deploys a new revision of the container app with updated image.

**Features:**
- Smart deployment detection (only deploys if image changed)
- Health checks after deployment
- Rollback capability
- Deployment verification

**Inputs:**
- `environment`: Target environment
- `image_tag`: Specific image tag to deploy
- `force_deploy`: Force deployment even if no changes detected

### 5. **Main Deployment** (`deploy.yml`)
**Trigger:**
- Push to main branch
- Pull requests to main
- Manual trigger

Comprehensive deployment workflow that handles the complete application lifecycle.

## 🔧 Setup Requirements

### GitHub Secrets
Configure the following secrets in your GitHub repository:

```
AZURE_CLIENT_ID       # Service Principal Client ID
AZURE_TENANT_ID       # Azure Tenant ID
AZURE_SUBSCRIPTION_ID # Azure Subscription ID
```

### Azure Service Principal Setup
1. Create a service principal with necessary permissions:
```bash
az ad sp create-for-rbac \
  --name "github-actions-copilot-demo" \
  --role "Contributor" \
  --scopes "/subscriptions/{subscription-id}" \
  --sdk-auth
```

2. Add additional role assignments as needed:
```bash
# For ACR operations
az role assignment create \
  --assignee <client-id> \
  --role "AcrPush" \
  --scope "/subscriptions/{subscription-id}/resourceGroups/{rg-name}/providers/Microsoft.ContainerRegistry/registries/{acr-name}"

# For Container Apps operations
az role assignment create \
  --assignee <client-id> \
  --role "ContainerApp Contributor" \
  --scope "/subscriptions/{subscription-id}/resourceGroups/{rg-name}"
```

### GitHub Environments (Recommended)
Configure GitHub environments for better security:
- `dev`: Development environment with auto-approval
- `staging`: Staging environment with reviewers
- `prod`: Production environment with protection rules

## 📁 Project Structure

```
.github/
  workflows/
    ├── deploy.yml                    # Main comprehensive deployment
    ├── full-deploy.yml              # Complete pipeline orchestration
    ├── deploy-infrastructure.yml     # Infrastructure-only deployment
    ├── build-container.yml          # Container build and push
    └── deploy-app.yml               # Application revision deployment
infra/
  ├── deploy-*.bicep                 # Bicep deployment templates
  ├── dev.*.parameters.jsonc         # Environment parameter files
  └── modules/                       # Reusable Bicep modules
planets/
  ├── Dockerfile                     # Container definition
  ├── index.html                     # Application entry point
  └── assets/                        # Static assets
```

## 🎯 Usage Examples

### Initial Environment Setup
1. **Deploy Infrastructure:**
   ```
   Run "Deploy Infrastructure" workflow
   - Environment: dev
   - Validate only: false
   ```

2. **Build and Deploy Application:**
   ```
   Run "Full Deployment Pipeline" workflow
   - Environment: dev
   - Skip infrastructure: true (since already deployed)
   ```

### Regular Development Workflow
1. **Code Changes:** Push changes to main branch
2. **Automatic Build:** Container build workflow triggers automatically
3. **Automatic Deploy:** Application deployment triggers after build
4. **Verification:** Check deployment status and application health

### Production Deployment
1. **Infrastructure:** Use "Deploy Infrastructure" with validate_only=true first
2. **Full Deploy:** Use "Full Deployment Pipeline" for complete deployment
3. **Verification:** Perform thorough testing before promoting

### Emergency Rollback
1. **Previous Version:** Use "Deploy Application Revision" with previous image tag
2. **Quick Deploy:** Use force_deploy=true to override change detection
3. **Verify:** Confirm application is working with rolled-back version

## 🔍 Monitoring and Troubleshooting

### Workflow Outputs
Each workflow provides comprehensive summaries including:
- Deployment status for each component
- Resource URLs and identifiers
- Health check results
- Error details and recommendations

### Common Issues

**Authentication Failures:**
- Verify service principal credentials in GitHub secrets
- Check RBAC permissions for the service principal
- Ensure subscription ID is correct

**Container Build Failures:**
- Check Dockerfile syntax and base image availability
- Verify ACR permissions for pushing images
- Review build logs for specific error messages

**Deployment Failures:**
- Validate Bicep templates and parameter files
- Check Azure resource quotas and limits
- Verify resource naming conventions and availability

**Application Not Responding:**
- Check container app logs in Azure portal
- Verify container registry access and image pull
- Review container app configuration and environment variables

### Useful Azure CLI Commands

```bash
# Check deployment status
az deployment group show --resource-group <rg-name> --name <deployment-name>

# View container app logs
az containerapp logs show --name <app-name> --resource-group <rg-name>

# List container app revisions
az containerapp revision list --name <app-name> --resource-group <rg-name>

# Check ACR repositories and tags
az acr repository list --name <acr-name>
az acr repository show-tags --name <acr-name> --repository <repo-name>
```

## 🔐 Security Best Practices

1. **Use Managed Identity:** Container apps use managed identity for ACR access
2. **Least Privilege:** Service principals have minimum required permissions
3. **Environment Protection:** Production environments require manual approval
4. **Secret Management:** Sensitive data stored in GitHub secrets and Azure Key Vault
5. **Image Scanning:** Automated vulnerability scanning with Docker Scout
6. **What-If Analysis:** Infrastructure changes previewed before deployment

## 📊 Performance Optimization

1. **Build Caching:** Docker build cache reduces build times
2. **Parallel Jobs:** Independent jobs run concurrently when possible
3. **Smart Deployment:** Only deploys when changes are detected
4. **Health Checks:** Automated verification prevents failed deployments
5. **Resource Optimization:** Container apps scale based on demand

## 🎛️ Customization

### Environment-Specific Parameters
Create parameter files for each environment:
- `dev.*.parameters.jsonc`: Development settings
- `staging.*.parameters.jsonc`: Staging configuration  
- `prod.*.parameters.jsonc`: Production parameters

### Workflow Modifications
Customize workflows for your specific needs:
- Add approval gates for production deployments
- Integrate with external monitoring systems
- Add custom testing phases
- Configure notification channels

---

For more information about specific Azure services used in this deployment, refer to the official Azure documentation for Container Apps, Container Registry, and Bicep templates.