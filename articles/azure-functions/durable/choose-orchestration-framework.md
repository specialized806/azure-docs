---
title: Choose your orchestration framework
description: Learn the differences between Durable Functions and Durable Task SDKs, and which framework works best for your development needs and application scenarios.
author: greenie-msft
ms.author: nigreenf
ms.reviewer: hannahhunter
ms.date: 02/09/2026
ms.topic: concept-article
ms.service: azure-functions
ms.subservice: durable
titleSuffix: Durable Task
---

# Choose your orchestration framework

Azure provides two developer orchestration frameworks for building durable, fault-tolerant applications:

| Framework | Description |
| - | - |
| **Durable Functions** | An extension of Azure Functions for building serverless orchestrations. |
| **Durable Task SDKs** | Lightweight, portable client libraries for building orchestrations outside of Azure Functions, including Azure Container Apps, AKS, Azure App Service, and VMs. |

Both frameworks enable you to author stateful orchestrations without architecting for fault tolerance. The key difference is *where* your app runs. 

In this article, you learn:

> [!div class="checklist"]
> - The differences between Durable Functions and Durable Task SDKs.
> - Which framework works best for your development needs and your application scenarios.

## Choose the right framework

Not sure which framework fits your scenario? Start with the following rules to quickly identify the best option based on your target platform and existing codebase.

1. **If the target platform is Azure Functions**: Use *Durable Functions*.
1. **If the target platform is AKS, Azure App Service, VMs, or other containers**: Use *Durable Task SDKs*.
1. **If the target platform is Azure Container Apps**: Either framework works. See decision factors in [Which should I choose on Azure Container Apps?](#which-should-i-choose-on-azure-container-apps)
1. **If you have existing Azure Functions code**: Use *Durable Functions* for consistency.
1. **If you have existing non-Functions application code**: Use *Durable Task SDKs*.
1. **If compute portability is required** (same code on different container platforms): Use *Durable Task SDKs*.
1. **If backend flexibility is required** (ability to switch between storage backends): Use *Durable Functions*.

### Choose based on hosting platform

Use this decision tree to find the right framework for your hosting platform:

| Hosting platform | Recommended framework |
| - | - |
| Azure Functions | Durable Functions |
| Azure Container Apps | Either framework works |
| Azure Kubernetes Service (AKS) | Durable Task SDKs |
| Azure App Service | Durable Task SDKs |
| Virtual machines or other containers | Durable Task SDKs |

### Which should I choose on Azure Container Apps?

Azure Container Apps supports both frameworks. Consider:

| Choose Durable Functions if | Choose Durable Task SDKs if |
| - | - |
| You need built-in triggers (HTTP, Queue, Timer). | You want full control over your container. |
| You're already familiar with Azure Functions. | You prefer a lightweight SDK without runtime overhead. |
| You want deep Azure portal integration. | You want portability across container platforms. |
| You prefer the Functions programming model. | You have existing non-Functions code to integrate. |

## Learn more about each framework

# [Durable Functions](#tab/durable-functions)

Durable Functions is an extension of Azure Functions that adds durable execution capabilities. When configured with a durable backend, it provides an integrated experience for building event-driven workflows with minimal infrastructure management.

### Key characteristics

- **Serverless execution**: Runs on Azure Functions with automatic scaling, including scale-to-zero.
- **Event-driven triggers**: Native support for HTTP, Queue, Timer, Event Grid, and other Azure Functions triggers.
- **Azure integrations**: Access to Azure Functions extensions for seamless connectivity with Azure services.
- **Entity functions**: Full support for stateful entities across all supported languages.
- **Familiar model**: If you already use Azure Functions, the programming model is consistent.

### Supported languages and packages

| Language | Package |
| - | - |
| C# | `Microsoft.Azure.WebJobs.Extensions.DurableTask` |
| JavaScript/TypeScript | `durable-functions` |
| Python | `azure-functions-durable` |
| Java | `com.microsoft:durabletask-azure-functions` |
| PowerShell | Built into Azure Functions runtime |

### Hosting options

- All Azure Functions plans (Consumption, Flex Consumption, Premium, Dedicated)
- Azure Container Apps (with Functions runtime)

# [Durable Task SDKs](#tab/durable-task-sdks)

The Durable Task SDKs are lightweight client libraries that bring durable orchestration capabilities to any compute platform. They connect to a durable backend service (Durable Task Scheduler) to provide fault tolerance and state management.

### Key characteristics

- **Platform flexibility**: Run on any compute platform including containers, VMs, Kubernetes, or your local machine.
- **Lightweight**: Minimal dependencies and small footprint.
- **Portable**: Same code runs anywhere with no platform lock-in.
- **Direct control**: Full control over hosting, scaling, and deployment.
- **Modern SDKs**: Purpose-built for cloud-native development patterns.

### Supported languages and packages

| Language | Worker package | Client package |
| - | - | - |
| .NET | `Microsoft.DurableTask.Worker` | `Microsoft.DurableTask.Client` |
| Python | `durabletask` | `durabletask` |
| Java | `com.microsoft:durabletask-client` | `com.microsoft:durabletask-client` |
| Go | `github.com/microsoft/durabletask-go` (community) | Same |

### Hosting options

- Azure Container Apps
- Azure Kubernetes Service (AKS)
- Azure App Service
- Virtual machines

---

## Backend options

While Durable Functions can use any of the following available storage providers, the Durable Task Scheduler is the recommended choice for both Durable Functions and the Durable Task SDKs.

| Backend | Durable Functions | Durable Task SDKs |
| - | - | - |
| [**Durable Task Scheduler** (recommended)](./durable-task-scheduler/durable-task-scheduler.md) | ✅ | ✅ |
| [**Azure Storage**](./durable-functions-azure-storage-provider.md) | ✅ | ❌ |
| [**Microsoft SQL Server**](./durable-functions-storage-providers.md#mssql) | ✅ | ❌ |
| [**Netherite**](./durable-functions-storage-providers.md#netherite) | ✅ | ❌ |

## Next steps

> [!div class="nextstepaction"]
> [Quickstart: Create a Durable Functions app](durable-functions-isolated-create-first-csharp.md)

> [!div class="nextstepaction"]
> [Quickstart: Create an app with the Durable Task SDKs](durable-task-scheduler/quickstart-durable-task-scheduler.md)