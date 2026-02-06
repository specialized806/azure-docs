---
title: "Tutorial: Build an AI image generator with Azure Functions on Container Apps"
description: Learn to deploy Stable Diffusion on serverless GPUs using Azure Functions and Container Apps to create an AI-powered image generation API.
#customer intent: As a developer, I want to deploy an AI-powered image generation API using Stable Diffusion so that I can create images from text descriptions.
services: container-apps
author: craigshoemaker
ms.author: cshoe
ms.reviewer: cshoe
ms.service: azure-container-apps
ms.topic: tutorial
ms.date: 02/06/2026
ms.ai-usage: ai-assisted
zone_pivot_groups: container-apps-cli-portal
---

# Tutorial: Build an AI image generator with Azure Functions on Container Apps

Learn how to deploy a Stable Diffusion-powered image generator by using Azure Functions on Azure Container Apps with serverless GPUs. This tutorial shows you how to create an API that turns text descriptions into AI-generated images.

In this tutorial, you learn to:

> [!div class="checklist"]
> * Deploy Azure Functions with GPU support on Container Apps
> * Configure serverless GPU workload profiles for AI workloads
> * Build and deploy a Stable Diffusion-powered image generation API
> * Test the deployment with API calls
> * Optimize performance and manage costs
> * Clean up resources automatically

## Prerequisites

| Requirement | Notes |
|---|---|
| Azure subscription | [Create a free account](https://azure.microsoft.com/free/) |
| GPU quota access | [Request GPU access](https://aka.ms/aca-gpu-request) - approval takes 1-2 days |
| Azure Developer CLI | [Install Azure Developer CLI](/azure/developer/azure-developer-cli/install-azd) |
| Docker Desktop | Assumed baseline for container development |

> [!IMPORTANT]
> Request GPU access first since it takes time to approve. You can continue with this tutorial while waiting.

## Architecture overview

This solution uses the following Azure services:

- **Azure Functions**: Hosts the image generation API with HTTP triggers.
- **Azure Container Apps**: Provides serverless GPU hosting for Functions.
- **Azure Container Registry**: Stores the custom container image.
- **Azure Storage Account**: Required for Azure Functions runtime.
- **Azure Monitor**: Provides observability and logging.

The request flow is: **Client App → Azure Function → Stable Diffusion (GPU) → Generated Image**.

## Get the sample code

Clone the sample repository from GitHub:

```bash
git clone https://github.com/Azure-Samples/function-on-aca-gpu.git
cd function-on-aca-gpu
```

The project structure includes:

```
gpu-function-image-gen/
├── function_app.py      # HTTP-triggered function for image generation
├── requirements.txt     # Python dependencies including diffusers
├── Dockerfile          # Container image definition
├── host.json           # Azure Functions configuration
└── azure.yaml          # Azure Developer CLI configuration
```

## Understand the Azure integration

The key Azure-specific integrations in this solution include:

### GPU workload profile configuration

Azure Container Apps uses workload profiles to provide GPU access. The deployment automatically configures:

- GPU workload profile with NVIDIA T4 GPUs
- Container warm-up for faster cold starts
- Scaling rules for cost optimization

### Container image optimization

The solution uses Azure Container Apps features for improved performance:

- **Artifact streaming**: Enables faster container startup
- **Container warming**: Keeps instances ready for requests
- **Managed identity**: Secure access to Azure Container Registry

### Azure Functions integration

The HTTP-triggered function includes Azure-specific optimizations:

```python
@app.route(route="generate", methods=["POST"])
def generate_image(req: func.HttpRequest) -> func.HttpResponse:
    # Get prompt from request body
    req_body = req.get_json()
    prompt = req_body.get('prompt', '')
    
    # Load Stable Diffusion pipeline (cached after first use)
    pipe = get_pipeline()
    
    # Generate image using GPU
    result = pipe(prompt=prompt, num_inference_steps=25)
    
    # Convert to base64 for API response
    image = result.images[0]
    # ... encoding logic ...
    
    return func.HttpResponse(json.dumps({
        "success": True, 
        "image": img_base64
    }))
```

The function integrates with Azure through:

- **Azure Storage integration** for model caching
- **Application Insights** for telemetry and monitoring
- **Container Apps scaling** for automatic replica management

## Deploy to Azure

::: zone pivot="container-apps-cli"

Deploy by using Azure Developer CLI for the fastest deployment experience:

```bash
azd up
```

You're prompted for:

- **Environment name**: Unique name for your deployment (for example, `gpufunc-dev`)
- **Azure location**: Select `swedencentral` (has GPU quota availability)  
- **Azure subscription**: Select your subscription

The deployment takes about 15-20 minutes and creates these resources:

| Resource | Purpose |
|----------|---------|
| Resource group | Container for all resources |
| Container Apps environment | Hosts the Function App with GPU profile |
| Container registry | Stores the custom container image |
| Storage account | Required for Azure Functions runtime |
| Application Insights | Monitoring and diagnostics |
| Function App | The deployed image generation API |

When deployment completes, note the endpoint URL for testing.

::: zone-end

::: zone pivot="container-apps-portal"

For portal-based deployment, refer to the [Azure Container Apps quickstart](get-started-existing-container-image-portal.md) and configure:

1. Create Container Apps environment with GPU workload profile
1. Deploy from the sample repository container image  
1. Configure Function App settings with environment variables

::: zone-end

## Test the deployment

### Verify GPU availability

First, check that GPU resources are available:

```bash
curl "https://YOUR-FUNCTION-URL/api/health"
```

Expected response:

```json
{
  "status": "healthy",
  "gpu_available": true,
  "gpu_info": {
    "name": "Tesla T4",
    "memory_total_gb": 15.56
  }
}
```

### Generate your first image

Create an image by using the generation API:

```bash
curl -X POST "https://YOUR-FUNCTION-URL/api/generate" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "A friendly robot chef cooking pasta in a cozy kitchen",
    "num_steps": 25
  }'
```

> [!NOTE]
> The first request takes one to two minutes as the model downloads (approximately 5 GB). Subsequent requests complete in seconds.

The response includes a base64-encoded PNG image that you can decode and save.

## Monitor and optimize

For production scenarios, consider these optimizations:

### Performance monitoring

Azure Application Insights automatically captures:

- Request duration and success rates
- GPU utilization metrics  
- Container startup times
- Function execution telemetry

You can access monitoring data through the [Azure portal monitoring section](monitoring.md).

### Cost optimization

GPU billing is per second when containers are active. To minimize costs:

- Set `minReplicas: 0` for development (scales to zero when idle)
- Configure appropriate scaling rules based on usage patterns
- Monitor costs by using [Microsoft Cost Management](/azure/cost-management-billing/)

For production workloads that require consistent performance, set `minReplicas: 1` to keep one instance warm.

## Clean up resources

Remove all resources when you're finished:

```bash
azd down
```

This command removes the entire resource group and all contained resources.

## Next steps

Now that you have a working AI image generator, consider these next steps:

- **Customize the model**: Experiment with different Stable Diffusion variants.
- **Add authentication**: Secure your API by using [Azure Functions authentication](authentication.md).
- **Scale for production**: Configure [scaling rules](scale-app.md) and set up performance monitoring.
- **Integrate with applications**: Build web interfaces or mobile apps that consume the API.

## Related content

- [Azure Container Apps GPU support](gpu-serverless-overview.md)
- [Azure Functions on Container Apps overview](functions-overview.md)
- [Performance optimization for Container Apps](cold-start.md)
- [Monitoring Azure Container Apps](monitoring.md)