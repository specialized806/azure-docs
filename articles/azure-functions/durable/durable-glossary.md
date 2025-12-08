---
title: Glossary for Azure Durable
description: Glossary of terms typically used when discussing Azure Durable concepts around Durable Functions and Durable Task SDKs or Scheduler.
#customer intent: As an Azure developer, I'd like to understand terminology used for Azure Durable concepts.
author: hhunter-ms
ms.author: hannahhunter
ms.reviewer: azfuncdf
ms.date: 12/08/2025
ms.topic: glossary
ms.service: azure-functions
ms.subservice: durable
---

# Glossary for Azure Durable

A comprehensive reference of terms used throughout the Azure Durable documentation.

## A

### Activity Function

A function that performs the actual work in a durable orchestration. Activities are where you execute business logic, make API calls, access databases, and perform other I/O operations. Unlike orchestrators, activities do not need to be deterministic.

**See also**: [Activity](#activity)

### Activity

See [Activity Function](#activity-function).

### Azure Durable

An umbrella term for Microsoft's durable execution platform, encompassing Durable Functions, Durable Task Scheduler, and Durable Task SDKs.

### Azure Durable Functions

An extension of Azure Functions that enables writing stateful workflows in a serverless environment.

**See also**: [Durable Functions Overview](./durable-functions-overview.md)

## B

### Backend Provider

The storage system that persists orchestration state and history. Options include the Durable Task Scheduler (recommended), Azure Storage, MSSQL, and Netherite.

**See also**: [Storage Providers](./durable-functions-storage-providers.md)

## C

### Checkpoint

A point where the orchestration state is saved to durable storage. Checkpoints occur automatically when an orchestrator awaits an activity, timer, or external event. The framework uses checkpoints to recover orchestrations after failures.

### Client Function

A function that starts, queries, or manages orchestration instances. Client functions use the `DurableTaskClient` to interact with the Durable Task framework.

### ContinueAsNew

A method that restarts an orchestration with new input and a fresh history. Use this for eternal/long-running orchestrations to prevent unbounded history growth.

**See also**: [Eternal orchestrations](#eternal-orchestrations)

## D

### Determinism

The property of producing the same output given the same input. Orchestrator functions must be deterministic because they are replayed to recover state. Avoid using `DateTime.Now`, `Guid.NewGuid()`, `Random`, or direct I/O in orchestrators.

**See also**: [Replay](#replay)

### Durable Entity

A stateful object that manages a small piece of state with explicit operations. Entities process operations one at a time, avoiding concurrency issues.

**See also**: [Entity Function](#entity-function), [Entities](./durable-functions-entities.md)

### Durable Task Framework (DTFx)

The open-source framework that powers all Azure Durable technologies. It implements event sourcing, replay, and durable timers.

**See also**: [GitHub](https://github.com/Azure/durabletask)

### Durable Task Scheduler (DTS)

A fully managed Azure service that serves as the orchestration engine and state store for durable workloads. It provides the best performance and includes a built-in monitoring dashboard.

**See also**: [Durable Task Scheduler quickstart](./durable-task-scheduler/quickstart-durable-task-scheduler.md)

### Durable Task SDKs

Portable client libraries (.NET, Python, Java) for building durable orchestrations that can run on any compute platform, not just Azure Functions.

**See also**: [SDKs overview](./durable-task-scheduler/durable-task-overview.md)

### Durable Timer

A timer created via the orchestration context that survives process restarts. Unlike `Thread.Sleep()` or `Task.Delay()`, durable timers are persisted and will fire even if the host restarts.

**See also**: [Timers](./durable-functions-timers.md)

## E

### Entity Function

See [Durable Entity](#durable-entity).

### Entity ID

A unique identifier for an entity instance, consisting of an entity name (the function name) and an entity key (a unique string).

**See also**: [Durable Entity](#durable-entity)

### Eternal orchestrations

Long-running or infinite orchestrations that use ContinueAsNew to prevent unbounded history growth.

**See also**: [ContinueAsNew](#continueasnew), [Eternal orchestrations](./durable-functions-eternal-orchestrations.md)

### Event Sourcing

A pattern where state changes are stored as a sequence of events rather than as the current state. The Durable Task Framework uses event sourcing to record orchestration history and replay it for recovery.

**See also**: [History](#history), [Replay](#replay)

### External Event

An event sent to a running orchestration from outside the orchestration context. Use `WaitForExternalEvent` in orchestrators and `RaiseEventAsync` from clients.

**See also**: [External events](./durable-functions-external-events.md)

## F

### Fan-Out/Fan-In

An orchestration pattern where multiple activities are executed in parallel (fan-out) and then aggregated (fan-in).

### Function Chaining

An orchestration pattern where activities are executed in sequence, with the output of one becoming the input of the next.

## G

### gRPC

A high-performance RPC framework used by the Durable Task Scheduler for communication. gRPC provides persistent connections, binary encoding, and lower latency compared to HTTP.

## H

### History

The sequence of events recorded for an orchestration instance. The history is used during replay to reconstruct the orchestration state without re-executing completed work.

**See also**: [Replay](#replay), [Event Sourcing](#event-sourcing)

### Human Interaction

An orchestration pattern that waits for human input (e.g., approval) before continuing.

**See also**: [External Event](#external-event)

## I

### Instance ID

A unique identifier for an orchestration instance. You can specify a custom instance ID or let the framework generate one. Instance IDs are used to query status, send events, and terminate orchestrations.

**See also**: [Instance management](./durable-functions-instance-management.md)

### Isolated Worker Model

The recommended hosting model for .NET Azure Functions, where the function code runs in a separate process from the Functions host. This model provides better dependency management and .NET version flexibility.

**See also**: [.NET isolated](./durable-functions-dotnet-isolated-overview.md)

## M

### Managed Identity

An Azure Active Directory identity automatically managed by Azure. Used to authenticate to the Durable Task Scheduler without secrets. Can be system-assigned (tied to a resource) or user-assigned (independent resource).

**See also**: [Configure managed identity](./durable-functions-configure-managed-identity.md)

## N

### Non-Deterministic Exception

An exception thrown when the orchestrator code produces different results during replay than during the original execution. This typically happens when using non-deterministic APIs like `DateTime.Now` or `Random`.

**See also**: [Determinism](#determinism), [Code constraints](./durable-functions-code-constraints.md)

## O

### Orchestration

A workflow defined by an orchestrator function. An orchestration coordinates the execution of activities, sub-orchestrations, timers, and external events.

**See also**: [Orchestrator Function](#orchestrator-function)

### Orchestration Context

The context object passed to orchestrator functions (`TaskOrchestrationContext`). It provides methods for calling activities, creating timers, waiting for events, and accessing orchestration metadata.

**See also**: [Orchestrator functions](./durable-functions-orchestrations.md)

### Orchestration Status

The current state of an orchestration instance: Pending, Running, Completed, Failed, Suspended, or Terminated.

**See also**: [Instance management](./durable-functions-instance-management.md)

### Orchestrator Function

A function that defines the workflow logic. Orchestrators coordinate activities and must be deterministic.

**See also**: [Orchestrator functions](./durable-functions-orchestrations.md)

## R

### Replay

The process of re-executing orchestrator code using stored history to reconstruct state. During replay, completed activities return their stored results instead of re-executing.

**See also**: [Determinism](#determinism), [History](#history)

### Retry Policy

Configuration for automatic retries of failed activities. Includes settings for maximum attempts, retry interval, backoff coefficient, and retry timeout.

**See also**: [Error handling](./durable-functions-error-handling.md)

## S

### Saga Pattern

A pattern for managing distributed transactions using compensation. If a step fails, previously completed steps are "undone" by executing compensating actions.

**See also**: [Error handling](./durable-functions-error-handling.md)

### Sub-Orchestration

An orchestration called from within another orchestration. Useful for composing complex workflows from reusable components.

**See also**: [Sub-orchestrations](./durable-functions-sub-orchestrations.md)

## T

### Task Hub

A logical container for orchestration and entity instances. Task hubs provide isolation between different workloads or environments. All instances in a task hub share the same history storage and work queues.

**See also**: [Task hubs](./durable-functions-task-hubs.md)

## V

### Versioning

Strategies for updating orchestrator code while instances are in flight. Options include side-by-side deployment (new task hub) or in-code versioning (version flag in input).

**See also**: [Versioning](./durable-functions-versioning.md)

## W

### Worker

A process that hosts and executes orchestrators and activities. In Durable Functions, the Azure Functions host is the worker. With Durable Task SDKs, you create your own worker process.

## Next steps

- [Functions types and features overview](./durable-functions-types-features-overview.md)
- [Orchestrator functions overview](./durable-functions-orchestrations.md)
- [Choose your hosting option](./durable-functions-hosting-options.md)