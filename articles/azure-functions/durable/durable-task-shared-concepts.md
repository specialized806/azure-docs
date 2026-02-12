---
title: Shared concepts between Durable Functions and the Durable Task SDKs
description: Learn about the core concepts and patterns that are shared between Durable Functions and the Durable Task SDKs.
author: hhunter-ms
ms.topic: conceptual
ms.date: 02/12/2026
ms.author: hannahhunter
ms.service: azure-functions
ms.subservice: durable
---

# Shared concepts between Durable Functions and the Durable Task SDKs

In Durable Task, [Durable Functions](durable-functions-overview.md) and the [Durable Task SDKs](durable-task-scheduler/quickstart-portable-durable-task-sdks.md) share a common foundation for building durable, stateful workflows. While Durable Functions is an extension for Azure Functions and the Durable Task SDKs are standalone libraries, they both implement many of the same core concepts and patterns. This article provides an overview of these shared concepts and links to detailed documentation.

> [!TIP]
> The [Azure Durable Task Scheduler](durable-task-scheduler/durable-task-overview.md) is the recommended backend for *both* Durable Functions and the Durable Task SDKs, providing a fully managed, serverless experience for running durable workflows at scale.

## Fundamental concepts

Certain fundamental concepts are shared by both the Durable Functions or Durable Task SDKs approaches in Durable Task.

| Concept | Description | Learn more... |
| --- | --- | --- |
| Orchestrator code constraints | Orchestrators use [event sourcing](/azure/architecture/patterns/event-sourcing) to ensure reliable execution and maintain local variable state. The replay behavior of orchestrator code creates constraints on the type of code you can write. Orchestrators must be *deterministic*: they replay multiple times and must produce the same result each time. | [Orchestrator function code constraints](durable-functions-code-constraints.md) |
| Durable entities | Entities define operations that read and update small pieces of state, called *durable entities*. Unlike orchestrations, entities manage state explicitly instead of representing state through control flow. Entities help you scale out apps by distributing work across many entities, each with modest state. | [Durable entities](durable-functions-entities.md) |

## Advanced features

Both Durable Functions and the Durable Task SDKs share several advanced features.

| Feature | Description | Learn more... |
| --- | --- | --- |
| Instance management | Orchestrations are long-running stateful workflows that can be started, queried, suspended, resumed, and terminated using built-in management APIs. These operations work the same way conceptually across both platforms. | [Manage orchestration instances](durable-functions-instance-management.md) |
| Eternal orchestrations | Eternal orchestrations are orchestrations that never end. They're useful for aggregators and any scenario that requires an infinite loop. Eternal orchestrations use the `continue-as-new` method to reset their history and avoid unbounded history growth. | [Eternal orchestrations](durable-functions-eternal-orchestrations.md) |
| Singleton orchestrators | For background jobs, you often need to ensure that only one instance of a particular orchestrator runs at a time. You can achieve this singleton behavior by assigning a specific instance ID to an orchestrator and checking whether an instance with that ID is already running before starting a new one. | [Singleton orchestrators](durable-functions-singletons.md) |
| External events | Orchestrations can wait and listen for external events. This feature is useful for handling human interaction or other external triggers. External events are one-way asynchronous operations. The *wait-for-external-event* API allows an orchestration to asynchronously wait for an event delivered by an external client. You can listen for multiple events concurrently. | [Handling external events](durable-functions-external-events.md) |
| Durable timers | Durable timers implement delays or set up timeouts on async actions. Use durable timers in orchestrations instead of "sleep" or "delay" APIs that might be built into the language. When you create a timer, the underlying framework enqueues a message that becomes visible only at the specified time. | [Durable timers](durable-functions-timers.md) |
| Custom orchestration status | Custom orchestration status lets you set a custom status value for an orchestration instance. External clients can query this value to track progress or share metadata while the orchestration is running. Common use cases include visualizing progress and sharing metadata. | [Custom orchestration status](durable-functions-custom-orchestration-status.md) |
| Error handling and retries | Both platforms use standard language error-handling features for orchestrations. Unhandled exceptions thrown within activities or sub-orchestrations are marshaled back to the orchestrator, where you can catch and handle them appropriately. Key concepts include exception propagation, compensation, and retry policies. | [Handling errors in orchestrations](durable-functions-error-handling.md) |

## Orchestration patterns

Both platforms support the same workflow patterns for building reliable, scalable applications.

| Pattern | Description | Learn more... |
| --- | --- | --- |
| Function chaining | Function chaining runs a sequence of functions or activities in order, passing the output of one to the input of the next. This is the most common orchestration pattern and serves as the foundation for more complex workflows. | [Function chaining](durable-functions-sequence.md) |
| Fan-out/fan-in | Fan-out/fan-in runs multiple functions or activities in parallel, waits for all to complete, and then aggregates the results. This pattern is useful for processing batches of items concurrently or distributing work across multiple compute resources. | [Fan-out/fan-in scenario](durable-functions-fan-in-fan-out.md) |
| Human interaction | The human interaction pattern describes workflows that pause and wait for input from a person before continuing. This pattern is useful for approval workflows, multifactor authentication, and any scenario requiring a human response within a time limit. | [Human interaction pattern](durable-functions-human-interaction.md) |
| Monitor | The monitor pattern implements a flexible recurring process in a workflow, such as polling until certain conditions are met. Unlike timer-triggered functions, monitors can have dynamic intervals, terminate when conditions are met, and maintain state across iterations. | [Monitor scenario](durable-functions-monitor.md) |

## Next steps

> [!div class="nextstepaction"]
> [Durable Task overview](what-is-durable-task.md)