---
title: Durable Functions best practices and diagnostic tools
description: Learn about the best practices when using Durable Functions and the various tools available for diagnosing problems.
author: lilyjma
ms.topic: conceptual
ms.date: 02/15/2023
ms.author: azfuncdf
---

# Durable Functions best practices and diagnostic tools

This article describes best practices for using Durable Functions and the tools available to help diagnose problems during development, testing, and production.

## Best practices

### Use the latest version of the Durable Functions extension and SDK

A function app uses two components to execute Durable Functions. One is the Durable Functions SDK, which allows you to write orchestrator, activity, and entity functions using your target programming language. The other is the Durable extension, which is the runtime component that executes the code. Except for .NET in-process apps, the SDK and the extension are versioned independently.
    
Staying up to date with the latest extension and SDK ensures your application gets the latest performance improvements, features, and bug fixes. Upgrading to the latest versions also ensures that Microsoft can collect the latest diagnostic telemetry to help speed up investigations when you open a support case with Azure.
    
* See [Upgrade durable functions extension version](durable-functions-extension-upgrade.md) for instructions on getting the latest extension version.
* To ensure you're using the latest version of the SDK, check the package manager of the language you're using. 

### Adhere to Durable Functions code constraints

The [replay](durable-functions-orchestrations.md#reliability) behavior of orchestrator code creates [constraints](durable-functions-code-constraints.md) on the type of code that you can write in an orchestrator function. For example, your orchestrator function must use deterministic APIs so that each time it replays, it produces the same result.

> [!NOTE]
> The Durable Functions Roslyn Analyzer is a live code analyzer that guides C# users to adhere to Durable Functions specific code constraints. See [Durable Functions Roslyn Analyzer](durable-functions-roslyn-analyzer.md) for instructions on how to enable it on Visual Studio and Visual Studio Code.  

### Familiarize yourself with your programming language's Azure Functions performance settings

Using default settings, the language runtime you select might impose strict concurrency restrictions on your functions. For example, only allowing one function to execute at a time on a given VM. You can usually relax these restrictions by fine-tuning the concurrency and performance settings of your language. If you want to optimize the performance of your Durable Functions application, familiarize yourself with these settings.

The following list shows languages that often benefit from fine-tuning their performance and concurrency settings, and their guidelines.

* [JavaScript](../functions-reference-node.md#scaling-and-concurrency)
* [PowerShell](../functions-reference-powershell.md#concurrency)
* [Python](../python-scale-performance-reference.md)

### Guarantee unique task hub names per app

Multiple Durable Function apps can share the same storage account. By default, the app name is used as the task hub name, which ensures that accidental sharing of task hubs doesn't happen. If you need to explicitly configure task hub names for your apps in host.json, you must ensure that the names are [unique](durable-functions-task-hubs.md#multiple-function-apps). Otherwise, the apps compete for messages, which could result in undefined behavior, including orchestrations getting unexpectedly "stuck" in the Pending or Running state. 

The only exception is if you deploy *copies* of the same app in [multiple regions](durable-functions-disaster-recovery-geo-distribution.md); in this case, you can use the same task hub for the copies. 

### Follow guidance when deploying code changes to running orchestrators

Functions will inevitably be added, removed, and changed over the lifetime of an application. Examples of [common breaking changes](durable-functions-versioning.md) include changing activity or entity function signatures and changing orchestrator logic. These changes can cause problems when they affect orchestrations that are still running. Incorrectly deployed code changes can cause orchestrations to fail with a nondeterministic error, get stuck indefinitely, or experience performance degradation. Refer to recommended [mitigation strategies](durable-functions-versioning.md#mitigation-strategies) when making code changes that might affect running orchestrations. 

### Keep function inputs and outputs as small as possible

You might encounter memory issues if you provide large inputs and outputs to and from Durable Functions APIs. 

Inputs and outputs to Durable Functions APIs are serialized into the orchestration history. Large inputs and outputs can, over time, greatly contribute to an orchestrator history growing unbounded, which risks causing memory exceptions during [replay](durable-functions-orchestrations.md#reliability).

To reduce the effect of large inputs and outputs to APIs, you can delegate some work to sub-orchestrators. This approach helps balance the history memory burden from a single orchestrator to multiple ones, keeping the memory footprint of individual histories small.

That said, the best practice for dealing with large data is to keep it in external storage and to only materialize that data inside activities when needed. With this approach, instead of communicating the data itself as inputs or outputs of Durable Functions APIs, you can pass in a lightweight identifier that allows you to retrieve that data from external storage when needed in your activities.

### Keep entity data small

As with inputs and outputs to Durable Functions APIs, if an entity's explicit state is too large, you might encounter memory issues. An entity's state needs to be serialized and deserialized from storage on any request, so large states add serialization latency to each invocation. If an entity needs to track large data, we recommend that you offload the data to external storage and track a lightweight identifier in the entity that allows you to materialize the data from storage when needed.


### Fine-tune your Durable Functions concurrency settings

A single worker instance can execute multiple work items concurrently to increase efficiency. However, processing too many work items concurrently can exhaust resources like CPU capacity and network connections. In many cases, this isn't a concern because scaling and limiting work items are handled automatically. That said, if you're experiencing performance issues (such as orchestrators taking too long to finish or getting stuck in pending) or are doing performance testing, you can [configure concurrency limits](durable-functions-perf-and-scale.md#configuration-of-throttles) in the host.json file.

> [!NOTE]
> This doesn't replace fine-tuning the performance and concurrency settings of your language runtime in Azure Functions. The Durable Functions concurrency settings only determine how much work can be assigned to a given VM at a time, but they don't determine the degree of parallelism in processing that work inside the VM. The latter requires fine-tuning the language runtime performance settings.

### Use unique names for your external events

As with activity functions, external events have an *at-least-once* delivery guarantee. Under certain rare conditions, such as restarts, scaling, or crashes, your application might receive duplicates of the same external event. We recommend that external events contain an ID that allows them to be manually deduplicated in orchestrators.

> [!NOTE]
> The [MSSQL](./durable-functions-storage-providers.md#mssql) storage provider consumes external events and updates orchestrator state transactionally, so there's no risk of duplicate events with that backend, unlike with the default [Azure Storage storage provider](./durable-functions-storage-providers.md). However, we still recommend that external events have unique names so that code is portable across backends.

### Invest in stress testing

As with anything performance-related, the ideal concurrency settings and architecture of your app ultimately depend on your application's workload. We recommend that you invest in a performance testing harness that simulates your expected workload and use it to run performance and reliability experiments for your app.

### Avoid sensitive data in inputs, outputs, and exceptions

Inputs and outputs (including exceptions) to and from Durable Functions APIs are [durably persisted](./durable-functions-serialization-and-persistence.md) in your [storage provider of choice](./durable-functions-storage-providers.md). If inputs, outputs, or exceptions contain sensitive data (such as secrets, connection strings, or personally identifiable information), anyone with read access to your storage provider's resources can obtain them. To safely handle sensitive data, we recommend that you fetch that data *within activity functions* from either Azure Key Vault or environment variables, and never communicate that data directly to orchestrators or entities. This approach helps prevent sensitive data from leaking into your storage resources.

> [!NOTE]
> This guidance also applies to the `CallHttp` orchestrator API, which persists request and response payloads in storage. If your target HTTP endpoints require authentication that might be sensitive, we recommend that you implement the HTTP call yourself inside an activity, or use the [built-in managed identity support offered by `CallHttp`](./durable-functions-http-features.md#managed-identities), which doesn't persist any credentials to storage.

> [!TIP]
> Similarly, avoid logging data that contains secrets because anyone with read access to your logs (for example, in Application Insights) can obtain those secrets.

## Diagnostic tools

Several tools are available to help you diagnose problems.

### Durable Functions and Durable Task Framework logs

#### Durable Functions extension
The Durable extension emits tracking events that allow you to trace the end-to-end execution of an orchestration. You can find and query these tracking events using the [Application Insights Analytics](/azure/azure-monitor/logs/log-query-overview) tool in the Azure portal. You can configure the verbosity of tracking data emitted in the `logger` (Functions 1.x) or `logging` (Functions 2.0) section of the host.json file. For more information, see [configuration details](durable-functions-diagnostics.md#tracking-data). 
        
#### Durable Task Framework
Starting in v2.3.0 of the Durable extension, logs emitted by the underlying Durable Task Framework (DTFx) are also available for collection. For more information, see [how to enable these logs](durable-functions-diagnostics.md#durable-task-framework-logging).  

### Azure portal

#### Diagnose and solve problems
Azure Function App Diagnostics is a useful resource in the Azure portal for monitoring and diagnosing potential issues in your application. It also provides suggestions to help resolve problems based on the diagnosis. For more information, see [Azure Function App Diagnostics](function-app-diagnostics.md). 

#### Durable Functions orchestration traces
The Azure portal provides orchestration trace details to help you understand the status of each orchestration instance and trace the end-to-end execution. When you look at the list of functions inside your Azure Functions app, you see a **Monitor** column that contains links to the traces. You need to have Application Insights enabled for your app to get this information. 

### Durable Functions Monitor extension

The [Durable Functions Monitor](https://github.com/microsoft/DurableFunctionsMonitor) is a Visual Studio Code extension that provides a UI for monitoring, managing, and debugging your orchestration instances. 

### Roslyn Analyzer

The Durable Functions Roslyn Analyzer is a live code analyzer that guides C# users to adhere to Durable Functions-specific [code constraints](durable-functions-code-constraints.md). For instructions on how to enable it in Visual Studio and Visual Studio Code, see [Durable Functions Roslyn Analyzer](durable-functions-roslyn-analyzer.md). 


## Support

For questions and support, you can open an issue in one of the following GitHub repos. When reporting a bug in Azure, including information such as affected instance IDs, time ranges in UTC showing the problem, the application name (if possible), and deployment region greatly speeds up investigations.
- [Durable Functions extension and .NET in-process SDK](https://github.com/Azure/azure-functions-durable-extension/issues)
- [.NET isolated SDK](https://github.com/microsoft/durabletask-dotnet/issues)
- [Durable Functions for Java](https://github.com/microsoft/durabletask-java/issues)
- [Durable Functions for JavaScript](https://github.com/Azure/azure-functions-durable-js/issues)
- [Durable Functions for Python](https://github.com/Azure/azure-functions-durable-python/issues)
