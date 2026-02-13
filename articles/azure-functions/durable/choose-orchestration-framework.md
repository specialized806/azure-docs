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

- Durable Task SDKs 
- Durable Functions 

Both frameworks enable you to author stateful orchestrations without architecting for fault tolerance. The key difference is *where* your app runs. In this article, you learn:

> [!div class="checklist"]
> - The differences between Durable Functions and Durable Task SDKs.
> - Which framework works best for your development needs and your application scenarios.

## Choose the right framework

Not sure which framework fits your scenario? Start with the following rules to quickly identify the best option based on your target platform and existing codebase.

1. **If the target platform is Azure Functions** → Use *Durable Functions*.
1. **If the target platform is AKS, Azure App Service, VMs, or other containers** → Use *Durable Task SDKs*.
1. **If the target platform is Azure Container Apps** → Either framework works. 
1. **If you have existing Azure Functions code** → Use *Durable Functions* for consistency.
1. **If you have existing non-Functions application code** → Use *Durable Task SDKs*.
1. **If compute portability is required** (same code on different container platforms) → Use *Durable Task SDKs*.
1. **If backend flexibility is required** (ability to switch between storage backends) → Use *Durable Functions*.

# [Durable Task SDKs](#tab/durable-task-sdks)

The Durable Task SDKs are best for bringing durable orchestration capabilities to any hosting platform, like Azure App Service, Azure Container Apps, Azure Kubernetes Service (AKS), and Virtual Machines. They connect to the [Durable Task Scheduler](./durable-task-scheduler/durable-task-scheduler.md) backend service. 

### Hosting options

- Azure Container Apps
- Azure Kubernetes Service (AKS)
- Azure App Service
- Virtual machines

### Backend options

The Durable Task SDKs connect to the Azure-managed [Durable Task Scheduler](./durable-task-scheduler/durable-task-scheduler.md) backend provider. 

# [Durable Functions](#tab/durable-functions)

Durable Functions is an extension of Azure Functions for building serverless orchestrations. It's best for event-driven workloads with pay-per-execution pricing. 

### Hosting options

- [All Azure Functions plans (Consumption, Flex Consumption, Premium, Dedicated)]
- [Azure Container Apps (with Functions runtime)](../../container-apps/functions-overview.md)

### Backend options

While Durable Functions can use any of the following available storage providers, the Durable Task Scheduler is recommended.

- [**Durable Task Scheduler** (recommended)](./durable-task-scheduler/durable-task-scheduler.md) 
- [**Azure Storage**](./durable-functions-azure-storage-provider.md) 
- [**Microsoft SQL Server**](./durable-functions-storage-providers.md#mssql) 
- [**Netherite**](./durable-functions-storage-providers.md#netherite) 

---

### Azure Container Apps options

Azure Container Apps supports both Durable Functions and Durable Task SDK frameworks. When deciding which framework to use with your container apps, consider the following scenarios.

| Choose Durable Functions if... | Choose Durable Task SDKs if... |
| - | - |
| You need built-in triggers (HTTP, Queue, Timer). | You want full control over your container. |
| You're already familiar with Azure Functions. | You prefer a lightweight SDK without runtime overhead. |
| You want deep Azure portal integration. | You want portability across container platforms. |
| You prefer the Functions programming model. | You have existing non-Functions code to integrate. |

## Durable Task Framework (DTFx)

The Durable Task Framework (DTFx) is an open-source .NET orchestration framework intended for bring-your-own compute environments. While it can be used to build distributed applications, it does not come with official Microsoft support and requires users to manage hosting, operations, and long-term maintenance themselves.

[Learn more from the DTFx GitHub repo.](https://github.com/Azure/durabletask)
 
## Next steps

> [!div class="nextstepaction"]
> [Quickstart: Create a Durable Functions app](durable-functions-isolated-create-first-csharp.md)

> [!div class="nextstepaction"]
> [Quickstart: Create an app with the Durable Task SDKs](durable-task-scheduler/quickstart-durable-task-scheduler.md)