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

## What is durable execution?

Durable execution is a technique where a process saves its progress at key points, allowing it to pause and later resume exactly where it left off. If a failure occurs, previously completed operations aren't reexecuted. Instead, their results are retrieved from a persistent execution history and replayed, giving you consistent, repeatable outcomes.

This capability is useful in several scenarios:

- **Long-running processes** that might encounter interruptions or errors.
- **Human-in-the-loop workflows** where users inspect, validate, or modify the process before continuing.
- **Distributed systems** where work spans multiple services and machines.
- **Nondeterministic operations** like large language model (LLM) calls, where you need reliable recovery despite probabilistic outputs.

By preserving completed work, durable execution enables a process to resume without reprocessing previous steps, even after a significant delay.

## Key benefits

| Benefit | Description |
| - | - |
| **Automatic state persistence** | Execution state is automatically persisted and recovered, surviving crashes and restarts. |
| **Built-in fault tolerance** | Automatic retries with configurable policies and replay on failures. |
| **Horizontal scalability** | Managed infrastructure that scales automatically to handle thousands of concurrent executions. |
| **Multi-platform flexibility** | Run on Azure Functions, Container Apps, Kubernetes, or virtual machines (VMs). |
| **Durable timers** | Timers that survive restarts for long-running processes. |

## The four characteristics of durable execution

Durable Task breaks down durable execution into four key characteristics:

| Characteristic | Description |
| - | - |
| **Durability** | Your code survives crashes, restarts, and redeployments without losing progress. |
| **Distributed** | Work scales out and coordinates across machines. State is managed centrally, so tasks can run anywhere. |
| **Determinism** | Execution is replayed from recorded history instead of rerunning side effects. |
| **Debuggability** | You can inspect and step through execution using familiar IDE tools. |

### More than state persistence

Durable execution is more than state persistence. It persists:

- **Control flow**: Where you are in the process.
- **Execution history**: What happened and in what order.
- **Intent**: Not just data, but what the code is doing and why.

Durable systems don't just remember *what* data was stored. They remember *where* execution was in the process and *why*.

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

# [Durable Functions](#tab/durable-functions)

Durable Functions is best for event-driven workloads with pay-per-execution pricing. Like Azure Functions, you can use templates to develop Durable Functions using [Visual Studio](durable-functions-isolated-create-first-csharp.md?pivots=code-editor-visualstudio) and [Visual Studio Code](quickstart-js-vscode.md).

Behind the scenes, the Durable Functions extension is built on top of the [Durable Task Framework](https://github.com/Azure/durabletask), used to build workflows in code. Durable Functions automates mission-critical processes and is a natural fit for the serverless Azure Functions environment.

For example, you can get started using Durable Functions in a .NET isolated functions project with the following commands:

```bash
func init MyApp --worker-runtime dotnet-isolated
dotnet add package Microsoft.Azure.Functions.Worker.Extensions.DurableTask
```

Continue setting up Durable Functions in this project using the [Quickstart: Create a Durable Functions app](durable-functions-isolated-create-first-csharp.md).

#### Billing

Durable Functions is billed the same as Azure Functions. For more information, see [Azure Functions pricing](https://azure.microsoft.com/pricing/details/functions/). For more information on these behaviors, see the [Durable Functions billing](durable-functions-billing.md) article.

#### Publications

Durable Functions is developed in collaboration with Microsoft Research. As a result, the Durable Functions team actively produces research papers and artifacts; these include:

* [Durable Functions: Semantics for Stateful Serverless](https://www.microsoft.com/research/uploads/prod/2021/10/DF-Semantics-Final.pdf) *(OOPSLA'21)*
* [Serverless Workflows with Durable Functions and Netherite](https://arxiv.org/pdf/2103.00033.pdf) *(preprint)*

#### Video demo

The following video highlights the benefits of Durable Functions:

> [!VIDEO https://learn.microsoft.com/Shows/Azure-Friday/Durable-Functions-in-Azure-Functions/player]

# [Durable Task SDKs](#tab/durable-task-sdks)

The Durable Task SDKs are best for Azure App Service, Azure Container Apps, Azure Kubernetes Service (AKS), or any other hosting platform. They are standalone programming libraries for implementing Durable Task orchestrations, activities, and entities. The Durable Task SDKs are specifically designed to connect to a "sidecar" process, like the [Durable Task Scheduler](./durable-task-scheduler/durable-task-scheduler.md) storage provider.

For example, add the Durable Task SDK to your .NET isolated project using the following command:

```bash
dotnet add package Microsoft.DurableTask.Worker.AzureManaged
```

Get started with the Durable Task SDK using the [Quickstart: Create an app with the Durable Task SDKs](durable-task-scheduler/quickstart-durable-task-scheduler.md).

#### Billing

While the Durable Task SDKs themselves incur no cost, you may be billed depending on your hosting compute. For more information, see the [Durable Task SDK billing](durable-task-billing.md) article.

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