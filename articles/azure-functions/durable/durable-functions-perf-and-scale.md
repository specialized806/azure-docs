---
title: Performance and scale in Durable Functions - Azure
description: Learn about the unique scaling characteristics of the Durable Functions extension for Azure Functions.
author: cgillum
ms.topic: conceptual
ms.date: 02/03/2026
ms.author: azfuncdf
---

# Performance and scale in Durable Functions (Azure Functions)

To optimize performance and scalability, it's important to understand the unique scaling characteristics of [Durable Functions](durable-functions-overview.md). This article explains how workers scale based on load, and how you can tune the various parameters.

## Worker scaling

A fundamental benefit of the [task hub concept](durable-functions-task-hubs.md) is that the number of workers that process task hub work items can be continuously adjusted. Applications can add more workers (*scale out*) if the work needs to be processed more quickly, and can remove workers (*scale in*) if there isn't enough work to keep the workers busy.
You can even *scale to zero* if the task hub is completely idle. When scaled to zero, there are no workers at all; only the scale controller and the storage need to remain active.

The following diagram illustrates this concept:

![Diagram that shows workers scaling out, scaling in, and scaling to zero for a task hub.](./media/durable-functions-perf-and-scale/worker-scaling.png)

### Automatic scaling

As with all Azure Functions running in the Consumption and Elastic Premium plans, Durable Functions supports auto-scale via the [Azure Functions scale controller](../event-driven-scaling.md#runtime-scaling). The scale controller monitors how long messages and tasks wait before they're processed. Based on these latencies, it decides whether to add or remove workers.

> [!NOTE]
> Starting with Durable Functions 2.0, you can configure function apps to run in VNet-protected service endpoints in the Elastic Premium plan. In this configuration, the Durable Functions triggers start scale requests instead of the scale controller. For more information, see [Runtime scale monitoring](../functions-networking-options.md#elastic-premium-plan-with-virtual-network-triggers).

On the Premium plan, automatic scaling keeps the number of workers (and operating cost) roughly proportional to the application's load.

### CPU usage

**Orchestrator functions** run their logic multiple times due to their replaying behavior. It's therefore important that orchestrator function threads don't perform CPU-intensive tasks, do I/O, or block for any reason. Any work that might require I/O, blocking, or multiple threads should be moved into activity functions.

**Activity functions** have all the same behaviors as regular queue-triggered functions. They can safely do I/O, execute CPU-intensive operations, and use multiple threads. Because activity triggers are stateless, they can freely scale out to an unbounded number of VMs.

**Entity functions** are also executed on a single thread and operations are processed one-at-a-time. However, entity functions don't have any restrictions on the type of code that can be executed.

### Function timeouts

Activity, orchestrator, and entity functions are subject to the same [function timeouts](../functions-scale.md#timeout) as other Azure Functions. Durable Functions treats a function timeout like an unhandled exception in your code.

For example, when an activity times out, Durable Functions records the execution as failed and notifies the orchestrator. The orchestrator handles the timeout like any other exception: the runtime retries if the call specifies retries, or it runs an exception handler.

### Entity operation batching

To improve performance and reduce cost, a single work item can execute a batch of entity operations. On the Consumption plan, each batch is billed as a single function execution.

By default, the maximum batch size is 50 for consumption plans and 5000 for all other plans. You can also configure the maximum batch size in the [host.json](durable-functions-bindings.md#host-json) file. If the maximum batch size is 1, batching is effectively disabled.

> [!NOTE]
> If individual entity operations take a long time to execute, consider limiting the maximum batch size to reduce the risk of [function timeouts](#function-timeouts), especially on consumption plans.

## Instance caching

Generally, to process an [orchestration work item](durable-functions-task-hubs.md#work-items), a worker must:

1. Fetch the orchestration history.
1. Replay the orchestrator code by using the history.

If the same worker processes multiple work items for the same orchestration, the storage provider can optimize this process by caching the history in the worker's memory, which eliminates the first step. It can also cache the mid-execution orchestrator, which eliminates the history replay as well.

Caching typically reduces I/O to the underlying storage service and improves throughput and latency. But it also increases worker memory use.

The Azure Storage provider and the Netherite storage provider support instance caching. The table compares providers.

|| Azure Storage provider | Netherite storage provider | MSSQL storage provider |
|----|----|----|----|
| **Instance caching**    | Supported<br/>(.NET in-process worker only)       | Supported          | Not supported |
| **Default setting**      | Disabled       | Enabled   | n/a |
| **Mechanism**        | Extended Sessions       | Instance Cache   | n/a |
| **Documentation**  |  See [Extended sessions](durable-functions-azure-storage-provider.md#extended-sessions) | See [Instance cache](https://microsoft.github.io/durabletask-netherite/#/caching) | n/a |

> [!TIP]
> Caching can reduce how often histories are replayed, but it can't eliminate replay altogether. When developing orchestrators, we highly recommend testing them on a configuration that disables caching. This forced-replay behavior is useful for detecting [orchestrator function code constraints](durable-functions-code-constraints.md) violations at development time.  

### Comparison of caching mechanisms

The providers use different mechanisms to implement caching and offer different parameters to configure the caching behavior.

* **Extended sessions**, as used by the Azure Storage provider, keep mid-execution orchestrators in memory until they're idle for some time. The parameters to control this mechanism are `extendedSessionsEnabled` and `extendedSessionIdleTimeoutInSeconds`. For more information, see [Extended sessions](durable-functions-azure-storage-provider.md#extended-sessions) in the Azure Storage provider documentation.

> [!NOTE]
> Extended sessions are supported only in the .NET in-process worker.

* The **Instance cache**, as used by the Netherite storage provider, keeps the state of all instances, including their histories, in the worker's memory while tracking the total memory used. If the cache size exceeds the limit configured by `InstanceCacheSizeMB`, the least recently used instance data is evicted. If `CacheOrchestrationCursors` is set to true, the cache also stores the mid-execution orchestrators along with the instance state.
 For more information, see [Instance cache](https://microsoft.github.io/durabletask-netherite/#/caching) in the Netherite storage provider documentation.

> [!NOTE]
> Instance caches work with all language SDKs, but the `CacheOrchestrationCursors` option is available only for the .NET in-process worker.


## Concurrency throttles

A single worker instance can execute multiple [work items](durable-functions-task-hubs.md#work-items) concurrently. This helps increase parallelism and more efficiently utilize the workers.
However, if a worker attempts to process too many work items at the same time, it might exhaust its available resources, such as the CPU load, the number of network connections, or the available memory.

To ensure that an individual worker doesn't overcommit, you might need to throttle the per-instance concurrency. By limiting the number of functions that run concurrently on each worker, you can avoid exhausting the resource limits on that worker.

> [!NOTE]
> The concurrency throttles only apply locally, to limit what's currently being processed **per worker**. These throttles don't limit the total throughput of the system.

> [!TIP]
> In some cases, throttling the per-worker concurrency can actually *increase* the total throughput of the system. This can occur when each worker takes less work, causing the scale controller to add more workers to keep up with the queues, which then increases the total throughput.

### Configure throttles

Configure activity, orchestrator, and entity function concurrency limits in the *host.json* file. Use `durableTask/maxConcurrentActivityFunctions` for activity functions and `durableTask/maxConcurrentOrchestratorFunctions` for orchestrator and entity functions. These settings limit how many orchestrator, entity, and activity functions a worker loads into memory.

> [!NOTE]
> Orchestrations and entities are only loaded into memory when they're actively processing events or operations, or if [instance caching](durable-functions-perf-and-scale.md#instance-caching) is enabled. After executing their logic and awaiting (for example, hitting an `await` (C#) or `yield` (JavaScript, Python) statement in the orchestrator function code), they can be unloaded from memory. Orchestrations and entities that are unloaded from memory don't count towards the `maxConcurrentOrchestratorFunctions` throttle. Even if millions of orchestrations or entities are in the "Running" state, they only count towards the throttle limit when they're loaded into active memory. An orchestration that schedules an activity function similarly doesn't count towards the throttle if the orchestration is waiting for the activity to finish executing.

#### Functions 2.0

```json
{
  "extensions": {
    "durableTask": {
      "maxConcurrentActivityFunctions": 10,
      "maxConcurrentOrchestratorFunctions": 10
    }
  }
}
```

#### Functions 1.x

```json
{
  "durableTask": {
    "maxConcurrentActivityFunctions": 10,
    "maxConcurrentOrchestratorFunctions": 10
  }
}
```

### Language runtime considerations

The language runtime you select might impose strict concurrency restrictions on your functions. For example, Durable Functions apps written in Python or PowerShell might only support running a single function at a time on a single VM. This can result in significant performance problems if not carefully accounted for. For example, if an orchestrator fans out to 10 activities but the language runtime restricts concurrency to just one function, then 9 of the 10 activity functions are stuck waiting for a chance to run. Furthermore, these 9 stuck activities can't be load balanced to any other workers because the Durable Functions runtime has already loaded them into memory. This becomes especially problematic if the activity functions are long-running.

If the language runtime you're using places a restriction on concurrency, update the Durable Functions concurrency settings to match the concurrency settings of your language runtime. This ensures that the Durable Functions runtime doesn't attempt to run more functions concurrently than the language runtime allows, letting any pending activities be load balanced to other VMs. For example, if you have a Python app that restricts concurrency to 4 functions (perhaps it's only configured with 4 threads on a single language worker process or 1 thread on 4 language worker processes), configure both `maxConcurrentOrchestratorFunctions` and `maxConcurrentActivityFunctions` to 4.


## Partition count

Some storage providers use a *partitioning* mechanism and allow specifying a `partitionCount` parameter.

When using partitioning, workers don't directly compete for individual work items. Instead, work items are first grouped into `partitionCount` partitions. These partitions are then assigned to workers. This partitioned approach to load distribution can help reduce the total number of storage accesses required. It can also enable [instance caching](durable-functions-perf-and-scale.md#instance-caching) and improve locality because it creates *affinity*: all work items for the same instance are processed by the same worker.

> [!NOTE]
> Partitioning limits scale out because only `partitionCount` workers can process work items from a partitioned queue.

The following table shows which queues each storage provider partitions and the allowed range and default values for `partitionCount`.

|| Azure Storage provider | Netherite storage provider | MSSQL storage provider |
|----|----|----|----|
| **Instance messages**| Partitioned        | Partitioned          | Not partitioned     |
| **Activity messages**   | Not partitioned      | Partitioned          | Not partitioned    |
| **Default `partitionCount`**    | 4        | 12          | n/a    |
| **Maximum `partitionCount`**    | 16       | 32          | n/a     |
| **Documentation**  |  See [Orchestrator scale-out](durable-functions-azure-storage-provider.md#orchestrator-scale-out) | See [Partition count considerations](https://microsoft.github.io/durabletask-netherite/#/settings?id=partition-count-considerations) | n/a |

> [!WARNING]
> You can't change the partition count after a task hub is created. We recommend setting it to a large enough value to accommodate future scale-out requirements for the task hub instance.

### Configure partition count

Specify `partitionCount` in the *host.json* file. The following *host.json* snippet sets `durableTask/storageProvider/partitionCount` (or `durableTask/partitionCount` in Durable Functions 1.x) to `3`.

#### Durable Functions 2.x

```json
{
  "extensions": {
    "durableTask": {
      "storageProvider": {
        "partitionCount": 3
      }
    }
  }
}
```

#### Durable Functions 1.x

```json
{
  "extensions": {
    "durableTask": {
      "partitionCount": 3
    }
  }
}
```

## Minimize invocation latency

Under normal circumstances, invocation requests (to activities, orchestrators, entities, etc.) should be processed rather quickly. However, there's no guarantee on the maximum latency of any invocation request as it depends on factors such as: the type of scale behavior your App Service Plan, your concurrency settings, and the size of your application's backlog. As such, we recommend investing in stress testing to measure and optimize your application's tail latencies.

### Stress testing recommendations

The ideal concurrency settings and architecture of your app ultimately depends on your application's workload. Invest in a performance testing harness that simulates your expected workload and use it to run performance and reliability experiments for your app.

### Language runtime performance settings

Using default settings, the language runtime you select might impose strict concurrency restrictions on your functions. For example, the runtime might only allow one function to execute at a time on a given VM. These restrictions can usually be relaxed by fine tuning the concurrency and performance settings of your language. If you're looking to optimize the performance of your Durable Functions application, familiarize yourself with these settings.

The following languages often benefit from fine tuning their performance and concurrency settings:

* [JavaScript/Node.js](../functions-reference-node.md#scaling-and-concurrency)
* [PowerShell](../functions-reference-powershell.md#concurrency)
* [Python](../python-scale-performance-reference.md)

> [!NOTE]
> The Durable Functions concurrency settings control how much work can be assigned to a given VM at a time, but they don't control the degree of parallelism in processing that work inside the VM. The latter requires fine-tuning the language runtime performance settings.

## Performance targets

When planning to use Durable Functions for a production application, consider the performance requirements early in the planning process. Some basic usage scenarios include:

* **Sequential activity execution**: This scenario describes an orchestrator function that runs a series of activity functions one after the other. It most closely resembles the [Function Chaining](durable-functions-sequence.md) sample.
* **Parallel activity execution**: This scenario describes an orchestrator function that executes many activity functions in parallel using the [Fan-out, Fan-in](durable-functions-monitor.md) pattern.
* **Parallel response processing**: This scenario is the second half of the [Fan-out, Fan-in](durable-functions-monitor.md) pattern. It focuses on the performance of the fan-in. It's important to note that unlike fan-out, fan-in is done by a single orchestrator function instance, and therefore can only run on a single VM.
* **External event processing**: This scenario represents a single orchestrator function instance that waits on [external events](durable-functions-external-events.md), one at a time.
* **Entity operation processing**: This scenario tests how quickly a _single_ [Counter entity](durable-functions-entities.md) can process a constant stream of operations.

Throughput numbers for these scenarios are in the storage provider documentation. In particular:

* For the Azure Storage provider, see [Performance targets](durable-functions-azure-storage-provider.md#performance-targets).
* For the Netherite storage provider, see [Basic scenarios](https://microsoft.github.io/durabletask-netherite/#/scenarios).
* For the MSSQL storage provider, see [Orchestration throughput benchmarks](https://microsoft.github.io/durabletask-mssql/#/scaling?id=orchestration-throughput-benchmarks).

> [!TIP]
> Unlike fan-out, fan-in operations are limited to a single VM. If your application uses the fan-out, fan-in pattern and you're concerned about fan-in performance, consider subdividing the activity function fan-out across multiple [sub-orchestrations](durable-functions-sub-orchestrations.md).

## Next steps

> [!div class="nextstepaction"]
> [Azure Storage provider](durable-functions-azure-storage-provider.md)
