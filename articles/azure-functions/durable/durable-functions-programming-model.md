---
title: Durable Functions programming model
description: Learn how Durable Functions extends Azure Functions with a stateful programming model.
author: hhunter-ms
ms.author: hannahhunter
ms.reviewer: azfuncdf
ms.date: 12/02/2025
ms.topic: concept-article
ms.service: azure-functions
ms.subservice: durable
---

# Durable Functions programming model

Durable Functions extends Azure Functions with a stateful programming model. This model allows you to write workflows (orchestrations) and stateful entities using code.

> [!WARNING]
> **Important for .NET Developers:** Support for the in-process model ends on **November 10, 2026**. This documentation focuses on the **isolated worker model**, which is the recommended approach for all new and existing .NET projects. If you're using the in-process model, see our [Migration Guide](./migration-guide.md).

## Triggers and bindings

Durable Functions introduces three new trigger types and one output binding.

### Orchestration trigger

The **Orchestration Trigger** enables you to author durable orchestrator functions. This trigger supports starting new orchestrator instances and resuming existing orchestrator instances that are "awaiting" a task.

| Aspect | Details |
|--------|---------|
| **Behavior** | Deterministic replay. The code runs multiple times to rebuild state. |
| **Usage** | Use `[OrchestrationTrigger]` (C#) or `orchestrationTrigger` (JSON) to define an orchestrator function. |

### Activity trigger

The **Activity Trigger** enables you to author activity functions. Activity functions are the basic unit of work in a durable orchestration.

| Aspect | Details |
|--------|---------|
| **Behavior** | Stateless (idempotent recommended). Can perform I/O, database calls, and other operations. |
| **Usage** | Use `[ActivityTrigger]` (C#) or `activityTrigger` (JSON). |

### Entity trigger

The **Entity Trigger** enables you to author durable entity functions. These functions manage the state for a specific entity instance.

| Aspect | Details |
|--------|---------|
| **Behavior** | Operations on a specific entity ID are serialized (executed one at a time). |
| **Usage** | Use `[EntityTrigger]` (C#) or `entityTrigger` (JSON). |

### Durable client binding

The **Durable Client** binding (formerly "Orchestration Client") enables you to interact with the Durable Task framework. Use this binding to:

- Start new orchestration instances
- Query the status of orchestration instances
- Terminate or rewind instances
- Raise events to instances

| Aspect | Details |
|--------|---------|
| **Usage** | Use `[DurableClient]` (C#) or `durableClient` (JSON). |

## Orchestrator constraints

Orchestrator code must be **deterministic**. Because the Durable Task Framework replays the code to restore state, you must avoid:

### ❌ Non-deterministic APIs

Avoid using APIs that produce different results on each call:
- `DateTime.Now` or `DateTime.UtcNow` — Use `context.CurrentUtcDateTime`
- `Guid.NewGuid()` — Call an activity or use `context.NewGuid()`
- `Random` — Call an activity to generate random values

### ❌ Blocking calls

Avoid blocking the orchestrator thread:
- `Thread.Sleep()` — Use `await context.CreateTimer()`
- `Task.Wait()` or `Task.Result` — Use `await`

### ❌ Infinite loops

For eternal orchestrations, use `context.ContinueAsNew()` instead of `while(true)`.

## Activity functions

Activity functions are where the "real work" happens. They aren't restricted like orchestrators:

- ✅ Can make network calls
- ✅ Can use standard libraries
- ✅ Don't need to be deterministic
- ✅ Can use dependency injection

## Durable entities

Entities provide a way to define stateful objects. They're similar to actors in the Actor Model:

- **State** — Persisted automatically between operations
- **Access** — Via signals (one-way) or calls (request-response)
- **Concurrency** — Operations are processed one at a time per entity

## Next steps

- [Learn about Orchestrators →](../../concepts/orchestrators.md)
- [Learn about Activities →](../../concepts/activities.md)
- [Learn about Entities →](../../concepts/entities.md)
- [Explore Patterns →](../../patterns/index.md)