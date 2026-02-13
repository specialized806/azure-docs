---
title: What is Durable Task?
description: Learn about Durable Task technologies that provide durable execution for your applications, including automatic state persistence, fault tolerance, and horizontal scalability.
author: greenie-msft
ms.author: nigreenf
ms.reviewer: hannahhunter
ms.date: 02/09/2026
ms.topic: overview
ms.service: azure-functions
ms.subservice: durable
titleSuffix: Durable Task
---

# What is Durable Task?

Durable Task is a set of technologies that provide *durable execution* for your applications. Durable execution makes code execution persistent, so that your code recovers automatically from crashes, restarts, and redeployments without losing progress. Behind the scenes, the runtime manages state, checkpoints, and restarts for you, allowing you to focus on your business logic.

## Durable execution

Durable execution is a technique where a process saves its progress at key points, allowing it to pause and later resume exactly where it left off. If a failure occurs, previously completed operations aren't reexecuted. Instead, their results are retrieved from a persistent execution history and replayed, giving you consistent, repeatable outcomes.

This capability is useful in several scenarios:

- **Long-running processes** that might encounter interruptions or errors.
- **Human-in-the-loop workflows** where users inspect, validate, or modify the process before continuing.
- **Distributed systems** where work spans multiple services and machines.
- **Nondeterministic operations** like large language model (LLM) calls, where you need reliable recovery despite probabilistic outputs.

By preserving completed work, durable execution enables a process to resume without reprocessing previous steps, even after a significant delay.

## Key benefits

Durable Task provides four key capabilities:

| Benefit | Description |
| - | - |
| **Durability** | Your code survives crashes, restarts, and redeployments. Execution state is automatically persisted and recovered. |
| **Distributed** | Work scales out across machines with managed infrastructure that handles thousands of concurrent executions. |
| **Determinism** | Execution replays from recorded history with automatic retries, preserving control flow, execution history, and intent. |
| **Debuggability** | Inspect and step through execution using familiar IDE tools. |

Additional capabilities include:

- **Multi-platform flexibility**: Run on Azure Functions, Container Apps, Kubernetes, or VMs.
- **Durable timers**: Timers that survive restarts for long-running processes.

## Components

Durable Task consists of a backend and client SDKs that work together. The backend is responsible for persisting execution state, managing the execution history, and coordinating work across instances. You connect to the backend using either the *Durable Task SDKs* (for any hosting platform) or *Durable Functions* (for Azure Functions). Both options provide the same durable execution capabilities. Choose based on your hosting preference.

### Backends

| Backend | Description | Best for | Durable Functions support | Durable Task SDKs support |
| - | - | - | :-: | :-: |
| [**Durable Task Scheduler** (recommended)](./durable-task-scheduler/durable-task-scheduler.md) | Fully managed orchestration backend | Production workloads requiring high performance and reliability | ✅ | ✅ |
| [**Azure Storage**](./durable-functions-azure-storage-provider.md) | Uses Azure Storage queues and tables | Default backend for Durable Functions | ✅ | ❌ |
| [**Microsoft SQL Server**](./durable-functions-storage-providers.md#mssql) | Uses Microsoft SQL Server or Azure SQL | Scenarios requiring SQL-based storage | ✅ | ❌ |
| [**Netherite**](./durable-functions-storage-providers.md#netherite) | High-performance backend using Azure Event Hubs and Azure Page Blobs | High-throughput, low-latency workloads | ✅ | ❌ |

### Client SDKs

Durable Functions and the Durable Task SDKs are two ways to achieve durable execution. Both options connect to the Durable Task Scheduler backend. Choose which to use depending on how and where your code runs.

| Component | Description | Best for |
| - | - | - |
| [**Durable Task SDK**](./durable-task-scheduler/quickstart-durable-task-scheduler.md) | SDKs for .NET, Python, and Java | Building orchestrations in your preferred language |
| [**Durable Functions**](./durable-functions-isolated-create-first-csharp.md) | Serverless integration with Azure Functions | Event-driven, pay-per-execution workloads |

# [Durable Task SDKs](#tab/durable-task-sdks)

The Durable Task SDKs are standalone programming libraries for implementing Durable Task orchestrations, activities, and entities. They bring durable orchestration capabilities to any compute platform. The Durable Task SDKs are specifically designed to connect to a "sidecar" process, like the [Durable Task Scheduler](./durable-task-scheduler/durable-task-scheduler.md) storage provider.

For example, add the Durable Task SDK to your .NET isolated project using the following command:

```bash
dotnet add package Microsoft.DurableTask.Worker.AzureManaged
```

Get started with the Durable Task SDK using the [Quickstart: Create an app with the Durable Task SDKs](durable-task-scheduler/quickstart-durable-task-scheduler.md).

#### Key characteristics

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
| Go | `github.com/microsoft/durabletask-go` (open source) | `durabletask-go` |

#### Billing

While the Durable Task SDKs themselves incur no cost, you may be billed depending on your hosting compute. For more information, see the [Durable Task SDK billing](durable-task-billing.md) article.

# [Durable Functions](#tab/durable-functions)

Durable Functions is an extension of Azure Functions that adds durable execution capabilities. When configured with a durable backend, it provides an integrated experience for building event-driven workflows with minimal infrastructure management. Durable Functions automates mission-critical processes and is a natural fit for the serverless Azure Functions environment.

Like Azure Functions, you can use templates to develop Durable Functions using [Visual Studio](durable-functions-isolated-create-first-csharp.md?pivots=code-editor-visualstudio) and [Visual Studio Code](quickstart-js-vscode.md).

For example, you can get started using Durable Functions in a .NET isolated functions project with the following commands:

```bash
func init MyApp --worker-runtime dotnet-isolated
dotnet add package Microsoft.Azure.Functions.Worker.Extensions.DurableTask
```

Continue setting up Durable Functions in this project using the [Quickstart: Create a Durable Functions app](durable-functions-isolated-create-first-csharp.md).

### Key characteristics

- **Serverless execution**: Runs on Azure Functions with automatic scaling, including scale-to-zero.
- **Event-driven triggers**: Native support for HTTP, Queue, Timer, Event Grid, and other Azure Functions triggers.
- **Azure integrations**: Access to Azure Functions extensions for seamless connectivity with Azure services.
- **Entity functions**: Full support for stateful entities across all supported languages.
- **Familiar model**: If you already use Azure Functions, the programming model is consistent.

#### Supported languages and packages

| Language | Package |
| - | - |
| C# | `Microsoft.Azure.WebJobs.Extensions.DurableTask` |
| JavaScript/TypeScript | `durable-functions` |
| Python | `azure-functions-durable` |
| Java | `com.microsoft:durabletask-azure-functions` |
| PowerShell | Built into Azure Functions runtime |

#### Billing

Durable Functions is billed the same as Azure Functions. For more information, see [Azure Functions pricing](https://azure.microsoft.com/pricing/details/functions/). For more information on these behaviors, see the [Durable Functions billing](durable-functions-billing.md) article.

#### Publications

Durable Functions is developed in collaboration with Microsoft Research. As a result, the Durable Functions team actively produces research papers and artifacts; these include:

* [Durable Functions: Semantics for Stateful Serverless](https://www.microsoft.com/research/uploads/prod/2021/10/DF-Semantics-Final.pdf) *(OOPSLA'21)*
* [Serverless Workflows with Durable Functions and Netherite](https://arxiv.org/pdf/2103.00033.pdf) *(preprint)*

#### Video demo

The following video highlights the benefits of Durable Functions:

> [!VIDEO https://learn.microsoft.com/Shows/Azure-Friday/Durable-Functions-in-Azure-Functions/player]

---

## Quick navigation

| To learn about | Go to |
| - | - |
| Core concepts | [Durable Functions overview](what-is-durable-task.md) |
| Building serverless workflows | [Quickstart: Create a Durable Functions app](durable-functions-isolated-create-first-csharp.md) |
| Running using the Durable Task SDKs | [Quickstart: Create an app with the Durable Task SDKs](durable-task-scheduler/quickstart-durable-task-scheduler.md) |
| Orchestration patterns | [Function chaining](durable-functions-sequence.md) |
| Setting up the Azure-managed backend | [Durable Task Scheduler overview](durable-task-scheduler/durable-task-scheduler.md) |

## Next steps

> [!div class="nextstepaction"]
> [Choose your orchestration framework](./choose-orchestration-framework.md)