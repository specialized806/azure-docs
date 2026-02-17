---
title: Different concepts between Durable Functions and the Durable Task SDKs
description: Learn about the key differences between Durable Functions and the Durable Task SDKs, including hosting, triggers, storage providers, and platform-specific features.
author: hhunter-ms
ms.topic: conceptual
ms.date: 02/17/2026
ms.author: hannahhunter
ms.service: azure-functions
ms.subservice: durable
---

# Different concepts between Durable Functions and the Durable Task SDKs

While [Durable Functions](durable-functions-overview.md) and the [Durable Task SDKs](durable-task-scheduler/quickstart-portable-durable-task-sdks.md) share a common foundation for building durable workflows, they differ significantly in hosting, triggering, storage options, and platform-specific features. This article highlights these differences to help you choose the right approach and understand what's unique to each platform.

> [!TIP]
> For concepts that are shared between both platforms, see the [shared concepts](durable-task-shared-concepts.md) article.

## Platform and hosting differences

The most fundamental difference between Durable Functions and the Durable Task SDKs is where and how your workflows run.

| Aspect | Durable Functions | Durable Task SDKs |
| --- | --- | --- |
| **Hosting platform** | Azure Functions only | Any platform (Container Apps, Kubernetes, VMs, on-premises) |
| **Scale to zero** | Yes (Consumption plan) | No (minimum 1 instance) |
| **Cold start** | Yes (mitigated with Premium plan) | No (always running) |
| **Infrastructure control** | Managed by Azure Functions | Full control over hosting and scaling |
| **Pricing model** | Pay-per-execution (Consumption) or reserved (Premium/Dedicated) | Pay for compute time |

### When to use each platform

| Scenario | Recommended approach |
| --- | --- |
| Serverless, pay-per-use workloads | **Durable Functions** |
| Event-driven apps with Azure service integrations | **Durable Functions** |
| Container-based or Kubernetes deployments | **Durable Task SDKs** |
| On-premises or non-Azure cloud hosting | **Durable Task SDKs** |
| Full control over infrastructure | **Durable Task SDKs** |
| Quick prototyping | **Durable Functions** |

Learn more: [Choosing an orchestration framework](durable-task-scheduler/choose-orchestration-framework.md)

## Triggers and bindings

Durable Functions uses the Azure Functions trigger and binding model, while the Durable Task SDKs require you to implement your own entry points.

| Feature | Durable Functions | Durable Task SDKs |
| --- | --- | --- |
| **Orchestration trigger** | `[OrchestrationTrigger]` binding | Register orchestration with worker |
| **Activity trigger** | `[ActivityTrigger]` binding | Register activity with worker |
| **Entity trigger** | `[EntityTrigger]` binding | Register entity with worker (.NET only) |
| **Client binding** | `[DurableClient]` output binding | `DurableTaskClient` class |
| **External triggers** | HTTP, Queue, Timer, Event Grid, Blob, and more | You implement (HTTP endpoints, message handlers, etc.) |

### Durable Functions triggers

Durable Functions provides declarative trigger bindings that integrate with the Azure Functions runtime. These bindings automatically handle message processing, scaling, and lifecycle management.

Learn more: [Bindings for Durable Functions](durable-functions-bindings.md)

### Durable Task SDKs worker registration

The Durable Task SDKs use a worker-based model where you explicitly register orchestrations and activities with a worker that connects to the Durable Task Scheduler.

Learn more: [Durable Task SDK quickstart](durable-task-scheduler/quickstart-portable-durable-task-sdks.md)

## Storage providers

The storage backend options differ significantly between the two platforms.

| Storage provider | Durable Functions | Durable Task SDKs |
| --- | --- | --- |
| **Durable Task Scheduler** | ✅ Supported (recommended) | ✅ Supported (required) |
| **Azure Storage** | ✅ Supported | ❌ Not supported |
| **Microsoft SQL Server (MSSQL)** | ✅ Supported | ❌ Not supported |
| **Netherite** | ✅ Supported (deprecated) | ❌ Not supported |

### Durable Functions storage options

Durable Functions supports multiple "bring your own" storage backends, giving you flexibility to choose based on your requirements for cost, performance, and environment constraints.

Learn more: [Manage orchestration data using storage providers](durable-functions-storage-providers.md)

### Durable Task SDKs storage

The Durable Task SDKs exclusively use the Durable Task Scheduler as their backend, providing a fully managed experience with built-in high performance and observability.

Learn more: [Durable Task Scheduler overview](durable-task-scheduler/durable-task-scheduler.md)

## Built-in HTTP APIs

Durable Functions exposes built-in HTTP APIs for orchestration management that aren't available in the Durable Task SDKs.

| Feature | Durable Functions | Durable Task SDKs |
| --- | --- | --- |
| **Built-in HTTP management APIs** | ✅ Yes | ❌ No (use client APIs) |
| **Automatic status URLs** | ✅ `CreateCheckStatusResponse()` | ❌ Implement your own |
| **Webhook-based management** | ✅ Yes | ❌ No |

### Durable Functions HTTP features

Durable Functions automatically exposes HTTP endpoints for starting orchestrations, querying status, raising events, and terminating instances. These APIs follow the async HTTP polling pattern, making it easy to integrate with external systems.

Learn more: [HTTP features in Durable Functions](durable-functions-http-features.md) | [HTTP API reference](durable-functions-http-api.md)

### Durable Task SDKs management

With the Durable Task SDKs, you use the `DurableTaskClient` class directly to manage orchestration instances. If you need HTTP endpoints, you implement them yourself using your preferred web framework.

Learn more: [Manage orchestration instances](durable-functions-instance-management.md)

## Task hubs

The configuration and management of task hubs differs between the two platforms.

| Feature | Durable Functions | Durable Task SDKs |
| --- | --- | --- |
| **Configuration location** | `host.json` file | Code (connection string/endpoint) |
| **Multiple task hubs per app** | Supported via configuration | Supported via multiple workers |
| **Task hub creation** | Automatic or via portal | Azure portal or CLI |

### Durable Functions task hubs

In Durable Functions, task hubs are configured in the `host.json` file and managed through the Azure Functions infrastructure.

Learn more: [Task hubs in Durable Functions](durable-functions-task-hubs.md)

### Durable Task SDKs task hubs

With the Durable Task SDKs, you specify the task hub when creating the worker connection, typically through environment variables or configuration.

Learn more: [Durable Task Scheduler](durable-task-scheduler/durable-task-scheduler.md)

## Language and SDK support

Both platforms support multiple languages, but availability and features vary.

| Language | Durable Functions | Durable Task SDKs |
| --- | --- | --- |
| **C# / .NET** | ✅ GA (In-process and Isolated) | ✅ GA |
| **Python** | ✅ GA | ✅ GA |
| **JavaScript/TypeScript** | ✅ GA | 🔜 Coming soon |
| **Java** | ✅ Preview | ✅ Preview |
| **PowerShell** | ✅ GA | ❌ Not available |

### Durable Functions language support

Durable Functions supports a wide range of languages through the Azure Functions runtime, including PowerShell for automation scenarios.

Learn more: [Durable Functions overview](durable-functions-overview.md#language-support)

### Durable Task SDKs language support

The Durable Task SDKs are available as standalone packages for .NET, Python, and Java, with JavaScript/TypeScript support coming soon.

Learn more: [Durable Task SDK overview](durable-task-scheduler/durable-task-overview.md)

## Entity functions

Support for durable entities varies between platforms.

| Feature | Durable Functions | Durable Task SDKs |
| --- | --- | --- |
| **Entity functions** | ✅ All languages | ✅ .NET only |
| **Entity trigger** | `[EntityTrigger]` binding | Worker registration |
| **Entity client** | `[DurableClient]` binding | `DurableTaskClient` |

### Durable Functions entities

Durable Functions provides full entity support across all supported languages, with entity triggers and client bindings integrated into the Azure Functions model.

Learn more: [Durable entities](durable-functions-entities.md)

### Durable Task SDKs entities

Entity support in the Durable Task SDKs is currently limited to .NET. Other language SDKs don't yet support entities.

Learn more: [Durable entities](durable-functions-entities.md)

## Diagnostics and monitoring

Both platforms offer monitoring capabilities, but through different mechanisms.

| Feature | Durable Functions | Durable Task SDKs |
| --- | --- | --- |
| **Durable Task Scheduler dashboard** | ✅ Yes (when using Durable Task Scheduler) | ✅ Yes |
| **Application Insights integration** | ✅ Built-in | ✅ Manual setup |
| **Azure Functions monitoring** | ✅ Yes | ❌ Not applicable |
| **Custom telemetry** | Via Functions SDK | Via your hosting platform |

### Durable Functions diagnostics

Durable Functions integrates with Azure Functions monitoring and Application Insights, providing automatic telemetry for orchestrations, activities, and entities.

Learn more: [Diagnostics in Durable Functions](durable-functions-diagnostics.md)

### Durable Task SDKs diagnostics

The Durable Task SDKs rely on the Durable Task Scheduler dashboard for orchestration monitoring. Additional telemetry requires manual integration with your observability platform.

Learn more: [Durable Task Scheduler dashboard](durable-task-scheduler/durable-task-scheduler-dashboard.md)

## Versioning and deployment

Deployment strategies differ based on the hosting model.

| Feature | Durable Functions | Durable Task SDKs |
| --- | --- | --- |
| **Zero-downtime deployment** | Built-in strategies | Standard container/VM practices |
| **Orchestration versioning** | Side-by-side versioning patterns | Standard application versioning |
| **Slot deployments** | ✅ Azure Functions slots | Your platform's mechanisms |

### Durable Functions versioning

Durable Functions provides specific guidance for versioning orchestrations and achieving zero-downtime deployments using Azure Functions deployment slots.

Learn more: [Versioning in Durable Functions](durable-functions-versioning.md) | [Zero-downtime deployment](durable-functions-zero-downtime-deployment.md)

### Durable Task SDKs versioning

With the Durable Task SDKs, you use standard versioning practices for your hosting platform, whether that's container image tags, Kubernetes rollouts, or VM deployment strategies.

Learn more: [Durable Task Scheduler versioning](durable-task-scheduler/durable-task-scheduler-versioning.md)

## Summary comparison

| Aspect | Durable Functions | Durable Task SDKs |
| --- | --- | --- |
| **Best for** | Serverless, event-driven apps on Azure | Container-based or custom-hosted apps |
| **Hosting** | Azure Functions only | Any platform |
| **Triggers** | Declarative bindings | Custom implementation |
| **Storage options** | Multiple (Azure Storage, MSSQL, Durable Task Scheduler) | Durable Task Scheduler only |
| **HTTP APIs** | Built-in | Implement your own |
| **Scale to zero** | Yes | No |
| **Language support** | C#, JS, Python, Java, PowerShell | C#, Python, Java (JS coming) |
| **Entity support** | All languages | .NET only |

## Next steps

> [!div class="nextstepaction"]
> [Durable Task overview](durable-overview.md)
