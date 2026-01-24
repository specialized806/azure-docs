---
title: Handling external events in Durable Functions - Azure
description: Learn how to handle external events in the Durable Functions extension for Azure Functions.
ms.topic: conceptual
ms.date: 01/23/2026
ms.author: azfuncdf
# ms.devlang: csharp, javascript, powershell, python, java
---

# Handling external events in Durable Functions (Azure Functions)

Orchestrator functions have the ability to wait and listen for external events. This feature of [Durable Functions](durable-functions-overview.md) is often useful for handling human interaction or other external triggers.

> [!NOTE]
> External events are one-way asynchronous operations. They are not suitable for situations where the client sending the event needs a synchronous response from the orchestrator function.

## Wait for events

The *"wait-for-external-event"* API of the [orchestration trigger binding](durable-functions-bindings.md#orchestration-trigger) allows an orchestrator function to asynchronously wait and listen for an event delivered by an external client. The listening orchestrator function declares the *name* of the event and the *shape of the data* it expects to receive.

# [C# (.NET isolated)](#tab/csharp-isolated)

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.DurableTask;
using Microsoft.Extensions.Logging;

public class BudgetApproval
{
    private readonly ILogger _logger;

    public BudgetApproval(ILoggerFactory loggerFactory)
    {
        _logger = loggerFactory.CreateLogger<BudgetApproval>();
    }

    [Function("BudgetApproval")]
    public async Task Run(
        [OrchestrationTrigger] TaskOrchestrationContext context)
    {
        bool approved = await context.WaitForExternalEventAsync<bool>("Approval");
        if (approved)
        {
            // approval granted - do the approved action
        }
        else
        {
            // approval denied - send a notification
        }
    }
}
```

# [C# (.NET in-process)](#tab/csharp-script)

```csharp
[FunctionName("BudgetApproval")]
public static async Task Run(
    [OrchestrationTrigger] IDurableOrchestrationContext context)
{
    bool approved = await context.WaitForExternalEvent<bool>("Approval");
    if (approved)
    {
        // approval granted - do the approved action
    }
    else
    {
        // approval denied - send a notification
    }
}
```

> [!NOTE]
> If you're using Durable Functions 1.x, use `DurableOrchestrationContext` instead of `IDurableOrchestrationContext`. Check out the [Durable Functions versions](durable-functions-versions.md) article for more version-specific details.

# [JavaScript](#tab/javascript)

```javascript
const df = require("durable-functions");

module.exports = df.orchestrator(function*(context) {
    const approved = yield context.df.waitForExternalEvent("Approval");
    if (approved) {
        // approval granted - do the approved action
    } else {
        // approval denied - send a notification
    }
});
```

# [Python](#tab/python)

```python
import azure.functions as func
import azure.durable_functions as df

def orchestrator_function(context: df.DurableOrchestrationContext):
    approved = yield context.wait_for_external_event('Approval')
    if approved:
        # approval granted - do the approved action
    else:
        # approval denied - send a notification

main = df.Orchestrator.create(orchestrator_function)
```

# [Java](#tab/java)

```java
@FunctionName("WaitForExternalEvent")
public void waitForExternalEvent(
        @DurableOrchestrationTrigger(name = "ctx") TaskOrchestrationContext ctx) {
    boolean approved = ctx.waitForExternalEvent("Approval", boolean.class).await();
    if (approved) {
        // approval granted - do the approved action
    } else {
        // approval denied - send a notification
    }
}
```

# [PowerShell](#tab/powershell)

```powershell
param($Context)

$approved = Start-DurableExternalEventListener -EventName "Approval"

if ($approved) {
    # approval granted - do the approved action
} else {
    # approval denied - send a notification
}
```

---

The code above waits for a single event and responds to it. Now let's look at handling multiple events at once.

# [C# (.NET isolated)](#tab/csharp-isolated)

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.DurableTask;

public class SelectOrchestrator
{
    [Function("Select")]
    public async Task Run(
        [OrchestrationTrigger] TaskOrchestrationContext context)
    {
        var event1 = context.WaitForExternalEventAsync<float>("Event1");
        var event2 = context.WaitForExternalEventAsync<bool>("Event2");
        var event3 = context.WaitForExternalEventAsync<int>("Event3");

        var winner = await Task.WhenAny(event1, event2, event3);
        if (winner == event1)
        {
            // ...
        }
        else if (winner == event2)
        {
            // ...
        }
        else if (winner == event3)
        {
            // ...
        }
    }
}
```

# [C# (.NET in-process)](#tab/csharp-script)

```csharp
[FunctionName("Select")]
public static async Task Run(
    [OrchestrationTrigger] IDurableOrchestrationContext context)
{
    var event1 = context.WaitForExternalEvent<float>("Event1");
    var event2 = context.WaitForExternalEvent<bool>("Event2");
    var event3 = context.WaitForExternalEvent<int>("Event3");

    var winner = await Task.WhenAny(event1, event2, event3);
    if (winner == event1)
    {
        // ...
    }
    else if (winner == event2)
    {
        // ...
    }
    else if (winner == event3)
    {
        // ...
    }
}
```

> [!NOTE]
> Using Durable Functions 1.x? Swap in `DurableOrchestrationContext` instead of `IDurableOrchestrationContext`. See the [Durable Functions versions](durable-functions-versions.md) article to learn about other version differences.

# [JavaScript](#tab/javascript)

```javascript
const df = require("durable-functions");

module.exports = df.orchestrator(function*(context) {
    const event1 = context.df.waitForExternalEvent("Event1");
    const event2 = context.df.waitForExternalEvent("Event2");
    const event3 = context.df.waitForExternalEvent("Event3");

    const winner = yield context.df.Task.any([event1, event2, event3]);
    if (winner === event1) {
        // ...
    } else if (winner === event2) {
        // ...
    } else if (winner === event3) {
        // ...
    }
});
```

# [Python](#tab/python)

```python
import azure.functions as func
import azure.durable_functions as df

def orchestrator_function(context: df.DurableOrchestrationContext):
    event1 = context.wait_for_external_event('Event1')
    event2 = context.wait_for_external_event('Event2')
    event3 = context.wait_for_external_event('Event3')

    winner = yield context.task_any([event1, event2, event3])
    if winner == event1:
        # ...
    elif winner == event2:
        # ...
    elif winner == event3:
        # ...

main = df.Orchestrator.create(orchestrator_function)
```

# [Java](#tab/java)

```java
@FunctionName("Select")
public void selectOrchestrator(
        @DurableOrchestrationTrigger(name = "ctx") TaskOrchestrationContext ctx) {
    Task<Void> event1 = ctx.waitForExternalEvent("Event1");
    Task<Void> event2 = ctx.waitForExternalEvent("Event2");
    Task<Void> event3 = ctx.waitForExternalEvent("Event3");

    Task<?> winner = ctx.anyOf(event1, event2, event3).await();
    if (winner == event1) {
        // ...
    } else if (winner == event2) {
        // ...
    } else if (winner == event3) {
        // ...
    }
}
```

# [PowerShell](#tab/powershell)

```powershell
param($Context)

$event1 = Start-DurableExternalEventListener -EventName "Event1" -NoWait
$event2 = Start-DurableExternalEventListener -EventName "Event2" -NoWait
$event3 = Start-DurableExternalEventListener -EventName "Event3" -NoWait

$winner = Wait-DurableTask -Task @($event1, $event2, $event3) -Any

if ($winner -eq $event1) {
    # ...
} else if ($winner -eq $event2) {
    # ...
} else if ($winner -eq $event3) {
    # ...
}
```

---

The pattern above waits for *any one* of multiple events to arrive. You can also wait for *all* of them to complete before proceeding.

# [C# (.NET isolated)](#tab/csharp-isolated)

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.DurableTask;

public class NewBuildingPermit
{
    [Function("NewBuildingPermit")]
    public async Task Run(
        [OrchestrationTrigger] TaskOrchestrationContext context)
    {
        string applicationId = context.GetInput<string>();

        var gate1 = context.WaitForExternalEventAsync("CityPlanningApproval");
        var gate2 = context.WaitForExternalEventAsync("FireDeptApproval");
        var gate3 = context.WaitForExternalEventAsync("BuildingDeptApproval");

        // all three departments must grant approval before a permit can be issued
        await Task.WhenAll(gate1, gate2, gate3);

        await context.CallActivityAsync("IssueBuildingPermit", applicationId);
    }
}
```

# [C# (.NET in-process)](#tab/csharp-script)

```csharp
[FunctionName("NewBuildingPermit")]
public static async Task Run(
    [OrchestrationTrigger] IDurableOrchestrationContext context)
{
    string applicationId = context.GetInput<string>();

    var gate1 = context.WaitForExternalEvent("CityPlanningApproval");
    var gate2 = context.WaitForExternalEvent("FireDeptApproval");
    var gate3 = context.WaitForExternalEvent("BuildingDeptApproval");

    // all three departments must grant approval before a permit can be issued
    await Task.WhenAll(gate1, gate2, gate3);

    await context.CallActivityAsync("IssueBuildingPermit", applicationId);
}
```

> [!NOTE]
> If you're running Durable Functions 1.x, use `DurableOrchestrationContext` instead of `IDurableOrchestrationContext`. Head over to [Durable Functions versions](durable-functions-versions.md) for a full breakdown of version differences.

In .NET, if the event payload cannot be converted into the expected type `T`, an exception is thrown.

# [JavaScript](#tab/javascript)

```javascript
const df = require("durable-functions");

module.exports = df.orchestrator(function*(context) {
    const applicationId = context.df.getInput();

    const gate1 = context.df.waitForExternalEvent("CityPlanningApproval");
    const gate2 = context.df.waitForExternalEvent("FireDeptApproval");
    const gate3 = context.df.waitForExternalEvent("BuildingDeptApproval");

    // all three departments must grant approval before a permit can be issued
    yield context.df.Task.all([gate1, gate2, gate3]);

    yield context.df.callActivity("IssueBuildingPermit", applicationId);
});
```

# [Python](#tab/python)

```python
import azure.functions as func
import azure.durable_functions as df

def orchestrator_function(context: df.DurableOrchestrationContext):
    application_id = context.get_input()
    
    gate1 = context.wait_for_external_event('CityPlanningApproval')
    gate2 = context.wait_for_external_event('FireDeptApproval')
    gate3 = context.wait_for_external_event('BuildingDeptApproval')

    yield context.task_all([gate1, gate2, gate3])
    yield context.call_activity('IssueBuildingPermit', application_id)

main = df.Orchestrator.create(orchestrator_function)
```

# [Java](#tab/java)

```java
@FunctionName("NewBuildingPermit")
public void newBuildingPermit(
        @DurableOrchestrationTrigger(name = "ctx") TaskOrchestrationContext ctx) {
    String applicationId = ctx.getInput(String.class);

    Task<Void> gate1 = ctx.waitForExternalEvent("CityPlanningApproval");
    Task<Void> gate2 = ctx.waitForExternalEvent("FireDeptApproval");
    Task<Void> gate3 = ctx.waitForExternalEvent("BuildingDeptApproval");

    // all three departments must grant approval before a permit can be issued
    ctx.allOf(List.of(gate1, gate2, gate3)).await();

    ctx.callActivity("IssueBuildingPermit", applicationId).await();
}
```

# [PowerShell](#tab/powershell)

```powershell
param($Context)

$applicationId = $Context.Input
$gate1 = Start-DurableExternalEventListener -EventName "CityPlanningApproval" -NoWait
$gate2 = Start-DurableExternalEventListener -EventName "FireDeptApproval" -NoWait
$gate3 = Start-DurableExternalEventListener -EventName "BuildingDeptApproval" -NoWait

Wait-DurableTask -Task @($gate1, $gate2, $gate3)

Invoke-ActivityFunction -FunctionName 'IssueBuildingPermit' -Input $applicationId
```

---

The *"wait-for-external-event"* API waits indefinitely for some input. The function app can be safely unloaded while waiting. If and when an event arrives for the orchestration instance, it's awakened automatically and immediately processes the event.

> [!NOTE]
> If your function app uses the Consumption Plan, no billing charges are incurred while an orchestrator function is awaiting an external event task, no matter how long it waits.

As with [Activity Functions](./durable-functions-types-features-overview.md#activity-functions), external events have an `at-least-once` delivery guarantee. Under certain conditions (like restarts, scaling, crashes, etc.), your application may receive duplicates of the same external event. We recommend external events contain some kind of ID that allows them to be manually de-duplicated in orchestrators.

## Send events

You can use the `raise-event` API defined by the [orchestration client](durable-functions-bindings.md#orchestration-client) binding to send an external event to an orchestration. You can also use the built-in [raise event HTTP API](durable-functions-http-api.md#raise-event) to send an external event to an orchestration.

A raised event includes an `instanceID`, an `eventName`, and `eventData` as parameters. Orchestrator functions handle these events using the [`wait-for-external-event`](#wait-for-events) APIs. The `eventName` must match on both the *sending* and *receiving* ends in order for the event to be processed. The event data must also be JSON-serializable.

Internally, the `raise-event` mechanisms enqueue a message that the waiting orchestrator function picks up. If the instance isn't waiting on the specified `eventName`, the system adds the event message to an in-memory queue. If the orchestration instance later begins listening for that `eventName`, it checks the queue for event messages.

> [!NOTE]
> If there is no orchestration instance with the specified `instanceID`, the event message is discarded.

Below is an example queue-triggered function that sends an `Approval` event to an orchestrator function instance. The orchestration instance ID comes from the body of the queue message.

# [C# (.NET isolated)](#tab/csharp-isolated)

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.DurableTask.Client;

public class ApprovalQueueProcessor
{
    [Function("ApprovalQueueProcessor")]
    public async Task Run(
        [QueueTrigger("approval-queue")] string instanceId,
        [DurableClient] DurableTaskClient client)
    {
        await client.RaiseEventAsync(instanceId, "Approval", true);
    }
}
```

# [C# (.NET in-process)](#tab/csharp-script)

```csharp
[FunctionName("ApprovalQueueProcessor")]
public static async Task Run(
    [QueueTrigger("approval-queue")] string instanceId,
    [DurableClient] IDurableOrchestrationClient client)
{
    await client.RaiseEventAsync(instanceId, "Approval", true);
}
```

> [!NOTE]
> For Durable Functions 1.x, use the `OrchestrationClient` attribute and `DurableOrchestrationClient` parameter type instead. Check the [Durable Functions versions](durable-functions-versions.md) article for all version-specific changes.

# [JavaScript](#tab/javascript)

```javascript
const df = require("durable-functions");

module.exports = async function(context, instanceId) {
    const client = df.getClient(context);
    await client.raiseEvent(instanceId, "Approval", true);
};
```

# [Python](#tab/python)

```python
import azure.functions as func
import azure.durable_functions as df

async def main(instance_id:str, starter: str) -> func.HttpResponse:
    client = df.DurableOrchestrationClient(starter)
    await client.raise_event(instance_id, 'Approval', True)
```

# [Java](#tab/java)

```java
@FunctionName("ApprovalQueueProcessor")
public void approvalQueueProcessor(
        @QueueTrigger(name = "instanceID", queueName = "approval-queue") String instanceID,
        @DurableClientInput(name = "durableContext") DurableClientContext durableContext) {
    durableContext.getClient().raiseEvent(instanceID, "Approval", true);
}
```

# [PowerShell](#tab/powershell)

```powershell
param($instanceId)

Send-DurableExternalEvent -InstanceId $InstanceId -EventName "Approval"
```

---

Internally, the `raise-event` API enqueues a message that the waiting orchestrator function picks up. If the instance isn't waiting on the specified `eventName`, the system adds the event message to an in-memory buffer. If the orchestration instance later begins listening for that `eventName`, it checks the buffer for event messages and triggers the task that was waiting for it.

> [!NOTE]
> If there is no orchestration instance with the specified `instanceID`, the event message is discarded.

### HTTP

The following is an example of an HTTP request that raises an `Approval` event to an orchestration instance.

```http
POST /runtime/webhooks/durabletask/instances/MyInstanceId/raiseEvent/Approval&code=XXX
Content-Type: application/json

"true"
```

In this case, the instance ID is hardcoded as *MyInstanceId*.

## Next steps

- [Implement error handling](durable-functions-error-handling.md)
- [Run a sample that waits for human interaction](durable-functions-phone-verification.md)