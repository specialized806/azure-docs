---
title: Hosting durable orchestrations in Azure Kubernetes Service
description: Learn about hosting durable orchestrations to AKS for full control over scaling, networking, and operations.
author: hhunter-ms
ms.author: hannahhunter
ms.reviewer: azfuncdf
ms.date: 12/02/2025
ms.topic: concept-article
ms.service: azure-functions
ms.subservice: durable
---

# Hosting durable orchestrations in Azure Kubernetes Service

Azure Kubernetes Service (AKS) provides the most flexibility for deploying Durable Task SDK workers. Use AKS when you need fine-grained control over infrastructure, custom scaling, or integration with existing Kubernetes workloads.

```mermaid
flowchart TB
    subgraph AKS["AKS + Durable Task SDK"]
        subgraph Cluster["AKS Cluster"]
            subgraph NS["Namespace: durable-system"]
                API["API Deployment<br/>Pods: 2"]
                Worker["Worker Deployment<br/>(HPA enabled)<br/>Pods: 3-20"]
                Ingress["Ingress<br/>(NGINX/Gateway)"]
                
                API --> Ingress
                Worker --> Ingress
            end
        end
        
        DTS["Durable Task Scheduler"]
        
        NS -->|gRPC| DTS
    end
```

## Key benefits

| Benefit | Description |
|---------|-------------|
| **Full Control** | Complete control over infrastructure, networking, and scaling |
| **Custom Networking** | Advanced networking configurations and policies |
| **HPA & KEDA** | Multiple scaling options including custom metrics |
| **Multi-tenant** | Run multiple task hubs in different namespaces |
| **Existing Investment** | Leverage existing Kubernetes expertise and tools |
| **Observability** | Integration with Prometheus, Grafana, and other K8s tools |

## When to use AKS

### ✅ Great For

- **Existing Kubernetes workloads** — Integrate with existing clusters
- **Advanced networking** — Custom network policies and configurations
- **Multi-tenant scenarios** — Isolate workloads in namespaces
- **Custom scaling** — Complex HPA or KEDA configurations
- **Compliance requirements** — Full control over security configurations
- **GitOps workflows** — Flux, ArgoCD, and other GitOps tools

### ⚠️ Consider Alternatives

- **Simpler deployments** → [Azure Container Apps](./durable-functions-container-apps-hosting.md)
- **Serverless with pay-per-execution** → [Azure Functions with Durable Functions](./durable-functions-overview.md)
- **Quick prototyping** → A[Azure Functions with Durable Functions](./durable-functions-overview.md)

## Architecture patterns

### Standard deployment

Separate API and worker deployments with HPA:

```mermaid
flowchart TB
    subgraph AKS["AKS Cluster"]
        subgraph NS["Namespace: durable-system"]
            Ingress["Ingress Controller"] --> API["API Deployment<br/>replicas: 2"]
            Worker["Worker Deployment<br/>HPA: 3-20 pods"]
        end
    end
    
    API --> DTS["Durable Task Scheduler"]
    Worker --> DTS
```

### Multi-tenant deployment

Multiple task hubs in isolated namespaces:

```mermaid
flowchart TB
    subgraph AKS["AKS Cluster"]
        subgraph Tenant1["Namespace: tenant-a"]
            W1["Worker Pods"]
        end
        subgraph Tenant2["Namespace: tenant-b"]
            W2["Worker Pods"]
        end
    end
    
    W1 --> TH1["Task Hub A"]
    W2 --> TH2["Task Hub B"]
    TH1 --> DTS["Durable Task Scheduler"]
    TH2 --> DTS
```

## Available SDKs

AKS works with the Durable Task SDKs in any language:

| SDK | Package | Status |
|-----|---------|--------|
| **.NET** | `Microsoft.DurableTask.Worker.AzureManaged` | ✅ GA |
| **Python** | `durabletask-azuremanaged` | ✅ GA |
| **Java** | `com.microsoft.durabletask` | ⚠️ Preview |

## Quick start

### Prerequisites

- Azure subscription
- Azure CLI with aks-preview extension
- kubectl configured
- Docker

### 1. Create AKS cluster

```bash
# Variables
RESOURCE_GROUP="rg-durable-aks"
LOCATION="centralus"
CLUSTER_NAME="durable-aks"
SCHEDULER_NAME="my-scheduler"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create AKS cluster with workload identity
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --node-count 3 \
  --enable-oidc-issuer \
  --enable-workload-identity \
  --generate-ssh-keys

# Get credentials
az aks get-credentials \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME
```

### 2. Deploy worker

```bash
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: durable-worker
  namespace: durable-system
spec:
  replicas: 3
  selector:
    matchLabels:
      app: durable-worker
  template:
    metadata:
      labels:
        app: durable-worker
    spec:
      containers:
      - name: worker
        image: myregistry.azurecr.io/durable-worker:latest
        env:
        - name: DTS_ENDPOINT
          value: "https://my-scheduler.centralus.durabletask.io"
        - name: TASKHUB_NAME
          value: "default"
EOF
```

## Comparison with other hosting options

| Feature | AKS | Container Apps | Azure Functions |
|---------|-----|----------------|-----------------|
| **Control** | Full | Medium | Low |
| **Complexity** | High | Medium | Low |
| **Networking** | Full control | Built-in | VNet integration |
| **Scaling** | HPA/KEDA | KEDA/Rules | Automatic |
| **Cost Model** | Node-based | Per vCPU-second | Per execution |
| **Learning Curve** | Steep | Moderate | Gentle |

## In this section

| Guide | Description |
|:------|:------------|
| [Deployment Guide](./durable-task-scheduler/quickstart-aks-durable-task-sdk.md) | Complete AKS deployment walkthrough |
| [Scaling](./durable-task-scheduler/durable-task-scheduler-auto-scaling-aks.md) | Configure HPA and KEDA scaling |

## Next steps

- [Host a Durable Task SDK app on Azure Kubernetes Service](durable-task-scheduler/quickstart-aks-durable-task-sdk.md)
- [Scaling using Durable Task SDKs](durable-task-scheduler/durable-task-scheduler-auto-scaling-aks.md)
- [Host a Durable Task SDK app on Azure Container Apps](durable-task-scheduler/quickstart-container-apps-durable-task-sdk.md)