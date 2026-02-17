---
title: Choose your programming model
description: Learn how your hosting platform determines whether to use Durable Functions for Azure Functions or the standalone Durable Task SDKs for self-hosted scenarios.
author: cgillum
ms.author: cgillum
ms.reviewer: hannahhunter
ms.date: 02/14/2026
ms.topic: concept-article
ms.service: azure-functions
ms.subservice: durable
titleSuffix: Durable Task
#Customer intent: As a developer, I want to understand which Durable Task programming model to use based on my hosting platform.
---

# Choose your programming model

As described in [What is Durable Task?](what-is-durable-task.md), the Durable Task framework supports two hosting models: **Azure Functions** (via Durable Functions) and **self-hosted** (via the standalone Durable Task SDKs). Both hosting models provide the same core durable execution capabilities (orchestrations, activities, timers, external events, and more) but differ in how your application is hosted, scaled, and deployed.

In general, where your application runs determines which programming model you use. If you're building on Azure Functions, you use Durable Functions. If you're building on any other compute platform, you use the standalone Durable Task SDKs.

## Choosing based on hosting platform

If you already know your application's hosting platform, the following table can help you determine which programming model to use:

| Hosting platform | Programming model |
| - | - |
| **Azure Functions** (Consumption, Flex Consumption, Premium) | Durable Functions |
| **Azure Container Apps** (with Azure Functions runtime) | Either |
| **Azure App Service** (with Azure Functions runtime) | Either |
| **Azure Kubernetes Service (AKS)** | Standalone Durable Task SDKs |
| **Virtual machines or on-premises** | Standalone Durable Task SDKs |

> [!NOTE]
> Azure App Service and Azure Container Apps can both host the Azure Functions runtime, either through [fully managed Azure Functions integration](../functions-scale.md#overview-of-plans) or by deploying the Functions runtime directly. Thus, both platforms support either programming model. For more information on Azure Functions hosting options, see [Azure Functions hosting plans](../functions-scale.md).

## Comparing the programming models

The following table summarizes the key differences between the two programming models:

| | Durable Functions (Azure Functions) | Standalone Durable Task SDKs (self-hosted) |
| - | - | - |
| **Hosting** | Azure Functions (Consumption, Flex Consumption, Premium), App Service, and Container Apps (with Functions runtime) | Any platform: Azure Container Apps, AKS, App Service, VMs, on-premises |
| **Scaling** | Automatic, managed by the Azure Functions managed scale infrastructure | You manage scaling yourself, or use platform-native autoscaling (for example, [KEDA](https://keda.sh/) on Kubernetes) |
| **Triggers** | Built-in support for HTTP, Queue, Timer, Event Grid, and [other Azure Functions triggers](../functions-triggers-bindings.md) | You define your own entry points (for example, HTTP endpoints, message consumers, etc.) |
| **State storage** | [Durable Task Scheduler](./durable-task-scheduler/durable-task-scheduler.md) (recommended), [Azure Storage](./durable-functions-azure-storage-provider.md), [MSSQL](./durable-functions-storage-providers.md#mssql), [Netherite](./durable-functions-storage-providers.md#netherite) | [Durable Task Scheduler](./durable-task-scheduler/durable-task-scheduler.md) |
| **Languages** | .NET (C#/F#), JavaScript/TypeScript, Python, Java, PowerShell | .NET (C#/F#), JavaScript/TypeScript, Python, Java |
| **Monitoring** | Built-in integration with Azure portal, Application Insights | You set up your own monitoring solution (for example, Azure Monitor, Prometheus, or Grafana) |

Both programming models support the **[Durable Task Scheduler](./durable-task-scheduler/durable-task-scheduler.md)** as a state storage backend, which provides both state storage and extra monitoring capabilities. Durable Functions also supports several bring-your-own (BYO) storage options for scenarios that require them. For more information, see [Storage providers](durable-functions-storage-providers.md).

## More considerations

When choosing between the two programming models, consider the following factors:

| Choose Durable Functions if... | Choose standalone Durable Task SDKs if... |
| - | - |
| You want built-in Azure Functions triggers (HTTP, Queue, Timer, etc.). | You want full control over your container and its entry points. |
| You're already familiar with the Azure Functions programming model. | You prefer a lightweight SDK without the Azure Functions runtime overhead. |
| You want Azure portal integration for function management. | You want the same code to be portable across container platforms (AKS, App Service, etc.). |
| You need to choose from [multiple storage backends](durable-functions-storage-providers.md). | You have existing non-Functions application code to integrate with. |

## Unsupported Durable Task SDKs

All Durable Task SDKs are open source and available on GitHub. However, some SDKs aren't officially supported by Microsoft or are still in experimental stages. The following SDKs are currently unsupported:

### Durable Task Framework (Legacy)

The [Durable Task Framework](https://github.com/Azure/durabletask) (DTFx) is an older, open-source .NET Durable Task library. While it provides similar orchestration primitives, it predates the modern Durable Task SDKs and doesn't include official Microsoft support or the latest features. It also requires you to manage hosting, operational infrastructure, and long-term maintenance themselves.

If you're starting a new project, we recommend using the modern Durable Task SDKs or Durable Functions instead.

### Durable Task SDK for Go

The [Durable Task SDK for Go](https://github.com/Azure/durabletask-go) is a community-supported, open-source library that enables durable orchestration capabilities in Go applications. It's currently in experimental stages, doesn't work with any of the supported Durable Task state storage backends, and isn't recommended for production use.

> [!NOTE]
> If you're interested in using Durable Task with Go with formal support from Microsoft, consider providing feedback by opening an issue in the [durabletask-go GitHub repository](https://github.com/Azure/durabletask-go/issues).

## Next steps

> [!div class="nextstepaction"]
> [Quickstart: Create a Durable Functions app](durable-functions-isolated-create-first-csharp.md)

> [!div class="nextstepaction"]
> [Quickstart: Create a self-hosted app with the Durable Task SDKs](durable-task-scheduler/quickstart-durable-task-scheduler.md)