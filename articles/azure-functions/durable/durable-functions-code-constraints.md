---
title: Durable orchestrator code constraints
description: Orchestration function replay and code constraints for Azure Durable Functions.
author: cgillum
ms.topic: conceptual
ms.date: 01/15/2026
ms.author: azfuncdf
ms.service: azure-functions
ms.subservice: durable
#Customer intent: As a developer, I want to learn what coding restrictions exist for durable orchestrations and why they exist so that I can avoid introducing bugs in my app logic.
---

# Orchestrator function code constraints

Durable Functions is an extension of [Azure Functions](../functions-overview.md) that lets you build stateful apps. You can use an [orchestrator function](durable-functions-orchestrations.md) to orchestrate the execution of other Durable Functions within a function app. Orchestrator functions are stateful, reliable, and potentially long-running.

## Orchestrator code constraints

Orchestrator functions use [event sourcing](/azure/architecture/patterns/event-sourcing) to ensure reliable execution and to maintain local variable state. The [replay behavior](durable-functions-orchestrations.md#reliability) of orchestrator code creates constraints on the type of code you can write in an orchestrator function. For example, orchestrator functions must be *deterministic*: an orchestrator function replays multiple times, and it must produce the same result each time.

### Using deterministic APIs

Here are some simple guidelines to help ensure your code is deterministic.

You can call any API in your target languages from orchestrator functions. However, it's important that your orchestrator functions call only deterministic APIs. A *deterministic API* is an API that always returns the same value given the same input, no matter when or how often it's called.

The following sections provide guidance on APIs and patterns you should avoid because they're *not* deterministic. These restrictions apply only to orchestrator functions. Other function types don't have such restrictions.

> [!NOTE]
> We describe several types of code constraints in this article. Unfortunately, this list isn't comprehensive and some use cases might not be covered. The most important thing to consider when writing orchestrator code is whether an API you're using is deterministic. Once you're comfortable thinking this way, it's easy to understand which APIs are safe to use and which aren't without needing to refer to this list.

#### Dates and times

Time-based APIs are nondeterministic and should never be used in orchestrator functions. Each orchestrator function replay produces a different value. Instead, use the Durable Functions equivalent API for getting the current date or time, which remains consistent across replays.

# [C#](#tab/csharp)

Don't use `DateTime.Now`, `DateTime.UtcNow`, or equivalent APIs for getting the current time. Classes such as [`Stopwatch`](/dotnet/api/system.diagnostics.stopwatch) should also be avoided. For .NET in-process orchestrator functions, use the `IDurableOrchestrationContext.CurrentUtcDateTime` property to get the current time. For .NET isolated orchestrator functions, use the `TaskOrchestrationContext.CurrentDateTimeUtc` property to get the current time.

```csharp
DateTime startTime = context.CurrentUtcDateTime;
// do some work
TimeSpan totalTime = context.CurrentUtcDateTime.Subtract(startTime);
```

# [JavaScript](#tab/javascript)

Don't use APIs like `new Date()` or `Date.now()` to get the current date and time. Instead, use `DurableOrchestrationContext.currentUtcDateTime`.

```javascript
// create a timer that expires 2 minutes from now
const expiration = moment.utc(context.df.currentUtcDateTime).add(2, "m");
const timeoutTask = context.df.createTimer(expiration.toDate());
```

# [Python](#tab/python)

Don't use `datetime.now()`, `gmtime()`, or similar APIs to get the current time. Instead, use `DurableOrchestrationContext.current_utc_datetime`.

```python
# create a timer that expires 2 minutes from now
expiration = context.current_utc_datetime + timedelta(seconds=120)
timeout_task = context.create_timer(expiration)
```

# [PowerShell](#tab/powershell)

Don't use cmdlets like `Get-Date` or .NET APIs like `[System.DateTime]::Now` to get the current time. Instead, use `$Context.CurrentUtcDateTime`.

```powershell
$expiryTime = $Context.Input.ExpiryTime
while ($Context.CurrentUtcDateTime -lt $expiryTime) {
    # do work
}
```

# [Java](#tab/java)

Don't use APIs like `LocalDateTime.now()` or `Instant.now()` to get the current date and time. Instead, use `TaskOrchestrationContext.getCurrentInstant()`.

```java
Instant startTime = ctx.getCurrentInstant();
// do some work
Duration totalTime  = Duration.between(startTime, ctx.getCurrentInstant());
```

---

#### GUIDs and UUIDs

APIs that return a random GUID or UUID are nondeterministic because the generated value is different for each replay. Depending on your language, a built-in API for generating deterministic GUIDs or UUIDs may be available. Otherwise, use an activity function to return a randomly generated GUID or UUID.

# [C#](#tab/csharp)

Instead of APIs like `Guid.NewGuid()`, use the context object's `NewGuid()` API to generate a random GUID that's safe for orchestrator replay.

```csharp
Guid randomGuid = context.NewGuid();
```

> [!NOTE]
> GUIDs generated with orchestration context APIs are [Type 5 UUIDs](https://en.wikipedia.org/wiki/Universally_unique_identifier#Versions_3_and_5_(namespace_name-based)).


# [JavaScript](#tab/javascript)

Instead of the `uuid` module or the `crypto.randomUUID()` function, use the context object's built-in `newGuid()` method to generate a random GUID that's safe for orchestrator replay.

```javascript
const randomGuid = context.df.newGuid();
```

> [!NOTE]
> UUIDs generated with orchestration context APIs are [Type 5 UUIDs](https://en.wikipedia.org/wiki/Universally_unique_identifier#Versions_3_and_5_(namespace_name-based)).


# [Python](#tab/python)

Instead of the `uuid` module, use the context object's built-in `new_guid()` method to generate a random UUID that's safe for orchestrator replay.

```python
randomGuid = context.new_guid()
```

> [!NOTE]
> UUIDs generated with orchestration context APIs are [Type 5 UUIDs](https://en.wikipedia.org/wiki/Universally_unique_identifier#Versions_3_and_5_(namespace_name-based)).

# [PowerShell](#tab/powershell)

Generate random GUIDs in activity functions and return them to the orchestrator functions, instead of generating cmdlets like `New-Guid` or .NET APIs like `[System.Guid]::NewGuid()` directly in orchestrator functions.

# [Java](#tab/java)

Instead of `java.util.UUID.randomUUID()` or similar methods, generate random UUIDs in activity functions and return them to the orchestrator functions.

---

#### Random numbers

Use an activity function to return random numbers to an orchestrator function. The return values of activity functions are always safe for replay because they're saved into the orchestration history.

Alternatively, you can use a random number generator with a fixed seed value directly in an orchestrator function. This approach is safe as long as the same sequence of numbers is generated for each orchestration replay.

#### Bindings

An orchestrator function must not use any bindings, including even the [orchestration client](durable-functions-bindings.md#orchestration-client) and [entity client](durable-functions-bindings.md#entity-client) bindings. Always use input and output bindings from within a client or activity function. Orchestrator functions may be replayed multiple times, causing nondeterministic and duplicate I/O with external systems.

#### Static variables

Static variables can change over time, making them unsafe for orchestrator functions. Avoid using static variables in orchestrator functions because their values can change over time, resulting in nondeterministic runtime behavior. Instead, use constants, or limit the use of static variables to activity functions.

> [!NOTE]
> Even outside of orchestrator functions, using static variables in Azure Functions can be problematic for various reasons since there's no guarantee that static state persists across multiple function executions. You should avoid static variables except in specific use cases, such as best-effort in-memory caching in activity or entity functions.

#### Environment variables

Environment variables in orchestrator functions can change over time, resulting in nondeterministic runtime behavior. If an orchestrator function needs configuration defined in an environment variable, you must pass the configuration value into the orchestrator function as an input or as the return value of an activity function.

#### Network and HTTP

Use activity functions to make outbound network calls. If you need to make an HTTP call from your orchestrator function, you also can use the [durable HTTP APIs](durable-functions-http-features.md#consuming-http-apis).

#### Thread-blocking APIs

Blocking APIs like "sleep" can cause performance and scale problems for orchestrator functions and should be avoided. In the Azure Functions Consumption plan, they can even result in unnecessary execution time charges. Use alternatives to blocking APIs when they're available. For example, use [Durable timers](durable-functions-timers.md) to create delays that are safe for replay and don't count towards the execution time of an orchestrator function.

#### Async APIs

Orchestrator code must never start any async operation, except operations defined by the orchestration trigger's context object. For example, never use `Task.Run`, `Task.Delay`, and `HttpClient.SendAsync` in .NET or `setTimeout` and `setInterval` in JavaScript. An orchestrator function should only schedule async work using Durable SDK APIs, like scheduling activity functions. Any other type of async invocations should be done inside activity functions.

#### Async JavaScript functions

Always declare JavaScript orchestrator functions as synchronous generator functions. You must not declare JavaScript orchestrator functions as `async` because the Node.js runtime doesn't guarantee that asynchronous functions are deterministic.

#### Python coroutines

You must not declare Python orchestrator functions as coroutines. In other words, never declare Python orchestrator functions with the `async` keyword because coroutine semantics don't align with the Durable Functions replay model. You must always declare Python orchestrator functions as generators, meaning that you should expect the `context` API to use `yield` instead of `await`.

#### .NET threading APIs

The Durable Task Framework runs orchestrator code on a single thread and can't interact with any other threads. Running async continuations on a worker pool thread in an orchestration's execution can result in nondeterministic execution or deadlocks. For this reason, your orchestrator functions should almost never use threading APIs. For example, never use `ConfigureAwait(continueOnCapturedContext: false)` in an orchestrator function to ensure task continuations run on the orchestrator function's original `SynchronizationContext`.

> [!NOTE]
> The Durable Task Framework attempts to detect accidental use of nonorchestrator threads in orchestrator functions. If it finds a violation, the framework throws a **NonDeterministicOrchestrationException** exception. However, this detection behavior won't catch all violations, and you shouldn't depend on it.

## Versioning

A durable orchestration might run continuously for days, months, years, or even [eternally](durable-functions-eternal-orchestrations.md). Any code updates made to Durable Functions apps that affect unfinished orchestrations might break the orchestrations' replay behavior. That's why it's important to plan carefully when making updates to code. For a more detailed description of how to version your code, see the [versioning article](durable-functions-versioning.md).

## Durable tasks

> [!NOTE]
> This section describes internal implementation details of the Durable Task Framework. You don't need to know this information to use Durable Functions, but it helps explain the replay behavior.

Tasks that can safely wait in orchestrator functions are occasionally referred to as *durable tasks*. The Durable Task Framework creates and manages these tasks. Examples are the tasks returned by `CallActivityAsync`, `WaitForExternalEvent`, and `CreateTimer` in .NET orchestrator functions.

A list of `TaskCompletionSource` objects in .NET manage these durable tasks internally. During replay, these tasks are created as part of orchestrator code execution. They're finished as the dispatcher enumerates the corresponding history events.

The tasks are executed synchronously using a single thread until the history is replayed. Durable tasks that aren't finished by the end of history replay have appropriate actions carried out. For example, a message might be enqueued to call an activity function.

Understanding this runtime behavior helps explain why your orchestrator function can't use `await` or `yield` in a nondurable task. There are two reasons: the dispatcher thread can't wait for the task to finish, and any callback by that task might potentially corrupt the tracking state of the orchestrator function. Some runtime checks are in place to help detect these violations.

To learn more about how the Durable Task Framework executes orchestrator functions, consult the [Durable Task source code on GitHub](https://github.com/Azure/durabletask). In particular, see [TaskOrchestrationExecutor.cs](https://github.com/Azure/durabletask/blob/master/src/DurableTask.Core/TaskOrchestrationExecutor.cs) and [TaskOrchestrationContext.cs](https://github.com/Azure/durabletask/blob/master/src/DurableTask.Core/TaskOrchestrationContext.cs).

## Next steps

> [!div class="nextstepaction"]
> [Learn how to invoke suborchestrations](durable-functions-sub-orchestrations.md)

> [!div class="nextstepaction"]
> [Learn how to handle versioning](durable-functions-versioning.md)
