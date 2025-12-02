---
title: Hosting durable orchestrations in Azure Container Apps
description: Learn about deploying durable orchestrations to Azure Container Apps.
author: hhunter-ms
ms.author: hannahhunter
ms.reviewer: azfuncdf
ms.date: 12/02/2025
ms.topic: concept-article
ms.service: azure-functions
ms.subservice: durable
---

# Hosting durable orchestrations in Azure Container Apps

Azure Container Apps provides a fully managed serverless container platform that's ideal for running Durable Task SDK workers. It offers automatic scaling, built-in HTTPS, and simplified deployment without needing to manage Kubernetes directly.

```mermaid
flowchart TB
    subgraph ACA["Azure Container Apps + Durable Task SDK"]
        subgraph ENV["Container Apps Environment"]
            API["API App<br/>- HTTP APIs<br/>- Start/Query"]
            Worker["Worker App<br/>- Orchestrators<br/>- Activities<br/>- Background process"]
            API --> Worker
        end
        
        subgraph DTS["Durable Task Scheduler"]
            TaskHub["Task Hub<br/>State"]
            Dashboard["Dashboard"]
        end
        
        Worker -->|gRPC| DTS
    end
```

## Key benefits

| Benefit | Description |
|---------|-------------|
| **Serverless Containers** | Run containers without managing infrastructure |
| **Built-in Autoscaling** | Scale based on HTTP traffic, events, or custom metrics |
| **KEDA Support** | Native KEDA integration for event-driven scaling |
| **Simplified Networking** | Built-in VNet integration and ingress |
| **Cost Efficient** | Pay only for resources consumed |
| **Microservices Ready** | Service discovery and Dapr integration |

## When to use Container Apps

### ✅ Great for

- **Containerized microservices** — Running multiple services in containers
- **Event-driven workloads** — Auto-scale based on queue depth or events
- **Simplified Kubernetes** — Kubernetes-like features without complexity
- **Background workers** — Long-running background processing
- **API + Worker patterns** — Separate API and worker containers

### ⚠️ Consider alternatives

- **Scale to zero with pay-per-execution** → [Azure Functions](../azure-functions/)
- **Full Kubernetes control** → [Azure Kubernetes Service](../kubernetes/)
- **Legacy VM-based workloads** → Virtual Machines with Durable Task SDK

## Architecture patterns

### Single container (Worker + Client)

For simpler applications where the worker and client run in the same container:

```mermaid
flowchart TB
    subgraph SingleApp["Container App"]
        Combined["Worker + Client<br/>- HTTP APIs<br/>- Orchestrators<br/>- Activities"]
    end
    
    SingleApp --> DTS["Durable Task Scheduler"]
```

### Separate containers (Recommended)

For production workloads, separate API and worker containers:

```mermaid
flowchart TB
    subgraph ACA["Container Apps Environment"]
        API["API Container<br/>- HTTP triggers<br/>- Client operations"]
        Worker["Worker Container<br/>- Orchestrators<br/>- Activities"]
    end
    
    API --> DTS["Durable Task Scheduler"]
    Worker --> DTS
```

## Available SDKs

Container Apps work with the Durable Task SDKs in any language:

| SDK | Package | Status |
|-----|---------|--------|
| **.NET** | `Microsoft.DurableTask.Worker.AzureManaged` | ✅ GA |
| **Python** | `durabletask-azuremanaged` | ✅ GA |
| **Java** | `com.microsoft.durabletask` | ⚠️ Preview |

## Quick start

### Prerequisites

- Azure subscription
- Azure CLI with containerapp extension
- Docker (for building images)
- Durable Task Scheduler resource

### 1. Create infrastructure

```bash
# Variables
RESOURCE_GROUP="rg-durable-aca"
LOCATION="centralus"
SCHEDULER_NAME="my-scheduler"
ENVIRONMENT_NAME="durable-env"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create Durable Task Scheduler
az durabletask scheduler create \
  --resource-group $RESOURCE_GROUP \
  --name $SCHEDULER_NAME \
  --location $LOCATION \
  --sku dedicated

# Create Container Apps Environment
az containerapp env create \
  --resource-group $RESOURCE_GROUP \
  --name $ENVIRONMENT_NAME \
  --location $LOCATION
```

### 2. Deploy worker container

```bash
az containerapp create \
  --resource-group $RESOURCE_GROUP \
  --name durable-worker \
  --environment $ENVIRONMENT_NAME \
  --image myregistry.azurecr.io/durable-worker:latest \
  --min-replicas 1 \
  --max-replicas 10 \
  --env-vars \
    "DTS_ENDPOINT=https://$SCHEDULER_NAME.$LOCATION.durabletask.io" \
    "TASKHUB_NAME=default"
```

## Comparison with other hosting options

| Feature | Container Apps | Azure Functions | AKS |
|---------|----------------|-----------------|-----|
| **Container Support** | ✅ Native | ⚠️ Limited | ✅ Full |
| **Scale to Zero** | ✅ Yes | ✅ Yes | ⚠️ With KEDA |
| **Complexity** | Medium | Low | High |
| **Networking** | Built-in VNet | VNet integration | Full control |
| **Cost Model** | Per vCPU-second | Per execution | Node-based |
| **Scaling** | KEDA/Rules | Automatic | HPA/KEDA |

## In this section

| Guide | Description |
|:------|:------------|
| [Deployment Guide](deployment.md) | Complete deployment walkthrough |
| [Scaling](scaling.md) | Configure autoscaling with KEDA |

## Next steps

- [Deploy to Container Apps →](./deployment.md)
- [Configure Scaling →](./scaling.md)
- [Explore Developer Guide →](../../developer-guide/)