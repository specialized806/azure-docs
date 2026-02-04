---
title: Durable entities
description: Learn what durable entities are and how to use them in Durable Functions and Durable Task SDKs.
author: cgillum
ms.topic: overview
ms.date: 02/04/2026
ms.author: azfuncdf
ms.devlang: csharp
# ms.devlang: csharp, java, javascript, python
ms.custom: devx-track-extended-java, devx-track-js, devx-track-python
zone_pivot_groups: azure-durable-approach
#Customer intent: As a developer, I want to learn what durable entities are and how to use them to solve distributed, stateful problems in my applications.
---

# Durable entities

::: zone pivot="durable-functions"

Entity functions define operations that read and update a small, named state object called a *durable entity*. Like orchestrator functions, they use a trigger type called the *entity trigger*. Unlike orchestrator functions, they manage entity state explicitly instead of representing state through control flow.
Entities help you scale out an app by distributing work across many entities, each with a small amount of state.

> [!NOTE]
> Use entity functions in [Durable Functions 2.0](durable-functions-versions.md#migrate-from-1x-to-2x) and later. They're supported in .NET in-proc, .NET isolated worker, JavaScript, and Python, but they aren't supported in PowerShell or Java.

::: zone-end

::: zone pivot="durable-task-sdks"

Entities define operations that read and update state for a *durable entity*. Unlike orchestrators, they manage state explicitly instead of representing state through control flow. Entities help you scale out an app by distributing work across many entities, each with a small amount of state.

> [!NOTE]
> Durable entities are supported in the .NET and Python Durable Task SDKs. The Java Durable Task SDK doesn't support durable entities.

::: zone-end



## General concepts

Entities are small services that communicate using messages. Each entity has a unique identity and, if needed, internal state. When prompted, an entity runs an operation that might update state, call external services, or wait for a response. The runtime sends messages through reliable queues.

To prevent conflicts, each entity runs one operation at a time.

> [!NOTE]
> When you invoke an entity, it processes the payload to completion, and then schedules another execution that runs when new input arrives. As a result, your entity execution logs might show an extra execution after each invocation. That extra execution is expected.

### Entity ID

Use the *entity ID* to target an entity. An entity ID is a pair of strings that uniquely identifies an entity instance. It includes:

* **Entity name**, which identifies the entity type. For example, `Counter`. This name matches the name of the entity function that implements the entity. It isn't case sensitive.
* **Entity key**, which uniquely identifies the entity among all other entities with the same name. For example, a GUID.

For example, use a `Counter` entity function to keep score in an online game. Each game instance has a unique entity ID, like `@Counter@Game1` and `@Counter@Game2`. To target an entity, specify its entity ID.

### Entity operations

To invoke an operation on an entity, specify:

* **Entity ID** of the target entity.
* **Operation name**, which is a string that specifies the operation to perform. For example, the `Counter` entity could support `add`, `get`, or `reset` operations.
* **Operation input**, which is an optional parameter for the operation. For example, the `add` operation takes an integer amount as input.
* **Scheduled time**, which is an optional parameter to specify the delivery time of the operation. For example, schedule an operation to run several days later.

::: zone pivot="durable-functions"

Operations can return a value or an error, such as a JavaScript error or a .NET exception. The calling orchestration receives the value or error.

::: zone-end

::: zone pivot="durable-task-sdks"

Operations can return a value or an error, such as a .NET exception or a Python exception. The caller receives the value or error.

::: zone-end

An entity operation can also create, read, update, and delete the state of the entity. The runtime always persists the entity state in storage.

## Define entities

::: zone pivot="durable-functions"

# [C#](#tab/csharp)

Use one of these two APIs to define entities in .NET:

**Function-based syntax**: In function-based syntax, you write each entity as a function and dispatch operations. This syntax works well for entities with simple state, few operations, or a dynamic set of operations, like app frameworks. But it doesn't catch type errors at compile time, so it's harder to maintain.

**Class-based syntax**: In class-based syntax, .NET classes and methods model entities and operations. This syntax makes code easier to read and lets you invoke operations in a type-safe way. It's a thin layer on top of the function-based syntax, so you can mix both variants in the same app.

The APIs you use depend on where your C# functions run. Run your C# functions in an _isolated worker process_. You can also run them in the host process.

**In-process function-based example:**

This example shows a simple `Counter` entity implemented as a durable function. It defines three operations—`add`, `reset`, and `get`—that use an integer state.

```csharp
[FunctionName("Counter")]
public static void Counter([EntityTrigger] IDurableEntityContext ctx)
{
    switch (ctx.OperationName.ToLowerInvariant())
    {
        case "add":
            ctx.SetState(ctx.GetState<int>() + ctx.GetInput<int>());
            break;
        case "reset":
            ctx.SetState(0);
            break;
        case "get":
            ctx.Return(ctx.GetState<int>());
            break;
    }
}
```

For more information, see [Function-based syntax](durable-functions-dotnet-entities.md#function-based-syntax).

**In-process class-based example:**

This example shows the same `Counter` entity implemented by using classes and methods.

```csharp
[JsonObject(MemberSerialization.OptIn)]
public class Counter
{
    [JsonProperty("value")]
    public int CurrentValue { get; set; }

    public void Add(int amount) => this.CurrentValue += amount;

    public void Reset() => this.CurrentValue = 0;

    public int Get() => this.CurrentValue;

    [FunctionName(nameof(Counter))]
    public static Task Run([EntityTrigger] IDurableEntityContext ctx)
        => ctx.DispatchAsync<Counter>();
}
```

This entity stores state in a `Counter` object that holds the current counter value. Durable Functions serializes and deserializes this object using the [Json.NET](https://www.newtonsoft.com/json) library.

For more information, see [Defining entity classes](durable-functions-dotnet-entities.md#defining-entity-classes).

**Isolated worker process function-based example:**

This example shows a function-based `Counter` entity in an isolated worker process. It supports `add`, `reset`, `get`, and `delete`.

```csharp
[Function(nameof(Counter))]
public static Task Counter([EntityTrigger] TaskEntityDispatcher dispatcher)
{
    return dispatcher.DispatchAsync(operation =>
    {
        if (operation.State.GetState(typeof(int)) is null)
        {
            operation.State.SetState(0);
        }

        switch (operation.Name.ToLowerInvariant())
        {
            case "add":
                int state = operation.State.GetState<int>();
                state += operation.GetInput<int>();
                operation.State.SetState(state);
                return new(state);
            case "reset":
                operation.State.SetState(0);
                break;
            case "get":
                return new(operation.State.GetState<int>());
            case "delete":
                operation.State.SetState(null);
                break;
        }

        return default;
    });
}
```

**Isolated worker process class-based example:**

The following example shows the implementation of the `Counter` entity using classes and methods.

```csharp
public class Counter : TaskEntity<int>
{
    readonly ILogger logger;

    public Counter(ILogger<Counter> logger)
    {
        this.logger = logger;
    }

    public void Add(int amount) => this.State += amount;

    public void Reset() => this.State = 0;

    public int Get() => this.State;

    [Function(nameof(Counter))]
    public Task RunEntityAsync([EntityTrigger] TaskEntityDispatcher dispatcher)
    {
        return dispatcher.DispatchAsync(this);
    }
}
```

# [JavaScript](#tab/javascript)

Durable entities are available in JavaScript starting in version `1.3.0` of the `durable-functions` npm package. This example shows the `Counter` entity implemented as a durable function in JavaScript.

**Counter/function.json**

```json
{
  "bindings": [
    {
      "name": "context",
      "type": "entityTrigger",
      "direction": "in"
    }
  ],
  "disabled": false
}
```

**Counter/index.js**

```javascript
const df = require("durable-functions");

module.exports = df.entity(function(context) {
    const currentValue = context.df.getState(() => 0);
    switch (context.df.operationName) {
        case "add": {
            const amount = context.df.getInput();
            context.df.setState(currentValue + amount);
            break;
        }
        case "reset":
            context.df.setState(0);
            break;
        case "get":
            context.df.return(currentValue);
            break;
    }
});
```

# [Python](#tab/python)

The following code is the `Counter` entity implemented as a durable function written in Python.

```python
import azure.functions as func
import azure.durable_functions as df

# Entity function called counter
@myApp.entity_trigger(context_name="context")
def Counter(context):
    current_value = context.get_state(lambda: 0)
    operation = context.operation_name
    if operation == "add":
        amount = context.get_input()
        current_value += amount
    elif operation == "reset":
        current_value = 0
    elif operation == "get":
        context.set_result(current_value)
    context.set_state(current_value)
```

# [PowerShell](#tab/powershell)

Entity functions aren't currently supported in PowerShell.

# [Java](#tab/java)

Entity functions aren't currently supported in Java.

---

::: zone-end

::: zone pivot="durable-task-sdks"

# [C#](#tab/csharp)

The Durable Task SDK for .NET supports defining entities using a class-based syntax. Implement the `TaskEntity<TState>` base class to define your entity.

The following example shows an `Account` entity implemented using the Durable Task SDK:

```csharp
using Microsoft.DurableTask.Entities;

public class Account : TaskEntity<int>
{
    public void Deposit(int amount) => this.State += amount;

    public void Withdraw(int amount) => this.State -= amount;

    public int GetBalance() => this.State;
}
```

Register the entity with the worker:

```csharp
builder.Services.AddDurableTaskWorker()
    .AddTasks(registry =>
    {
        registry.AddEntity<Account>();
    })
    .UseDurableTaskScheduler(connectionString);
```

# [JavaScript](#tab/javascript)

This sample is available in .NET and Python.

# [Python](#tab/python)

The Durable Task SDK for Python supports defining entities using either a function-based syntax or a class-based syntax.

**Class-based syntax** (recommended for entity locking):

```python
from durabletask import entities

class Counter(entities.DurableEntity):
    def set(self, value: int):
        self.set_state(value)

    def add(self, amount: int):
        current = self.get_state(int, 0)
        new_value = current + (amount or 1)
        self.set_state(new_value)
        return new_value

    def get(self):
        return self.get_state(int, 0)
```

**Function-based syntax**:

```python
from durabletask import entities

def counter(ctx: entities.EntityContext, input: int):
    """Function-based entity that maintains a counter state."""
    state = ctx.get_state(int, 0)

    if ctx.operation == "add":
        state += input
        ctx.set_state(state)
    elif ctx.operation == "get":
        return state
    elif ctx.operation == "reset":
        ctx.set_state(0)
```

To register the entity with the worker:

```python
with DurableTaskSchedulerWorker(
    host_address=endpoint,
    secure_channel=secure_channel,
    taskhub=taskhub,
    token_credential=credential
) as worker:
    worker.add_entity(Counter)  # Class-based
    # or: worker.add_entity(counter)  # Function-based
    worker.start()
```

# [PowerShell](#tab/powershell)

This sample is available in .NET and Python.

# [Java](#tab/java)

Entities aren't currently supported in the Java Durable Task SDK.

---

::: zone-end

## Access entities

::: zone pivot="durable-functions"

Use one-way or two-way communication to work with entities:

* **Calling** an entity uses two-way (round-trip) communication. Send an operation message to the entity, wait for the response message, and then continue. The response message provides a result value or an error (for example, a JavaScript error or a .NET exception)..
* **Signaling** an entity uses one-way (fire and forget) communication. Send an operation message but don't wait for a response. The runtime guarantees delivery, but the sender can't observe result values or errors.

Use entities from client functions, orchestrator functions, or entity functions. Not every context supports both communication types:

* Client functions support signaling entities and reading entity state.
* Orchestrator functions support signaling and calling entities.
* Entity functions support signaling entities.

::: zone-end

::: zone pivot="durable-task-sdks"

Use one-way or two-way communication to work with entities:

* **Calling** an entity uses two-way (round-trip) communication. Send an operation message to the entity, and then wait for the response message before you continue. The response message provides a result value or an error.
* **Signaling** an entity uses one-way (fire and forget) communication. Send an operation message but don't wait for a response. The runtime guarantees delivery, but the sender can't observe result values or errors.

Use entities from clients or orchestrators. Not every context supports both communication types:

* Clients support signaling entities and reading entity state.
* Orchestrators support signaling and calling entities.

::: zone-end

The following examples show how to use entities.

### Example: client signals an entity

::: zone pivot="durable-functions"

To use entities from a client function, use the [entity client binding](durable-functions-bindings.md#entity-client). This example shows a queue-triggered function that signals an entity by using this binding.

# [C#](#tab/csharp)

> [!NOTE]
> For simplicity, the following examples show the loosely typed syntax for accessing entities. In general, [access entities through interfaces](durable-functions-dotnet-entities.md#accessing-entities-through-interfaces) because they provide more type checking.

**In-process:**

```csharp
[FunctionName("AddFromQueue")]
public static Task Run(
    [QueueTrigger("durable-function-trigger")] string input,
    [DurableClient] IDurableEntityClient client)
{
    // Entity operation input comes from the queue message content.
    var entityId = new EntityId(nameof(Counter), "myCounter");
    int amount = int.Parse(input);
    return client.SignalEntityAsync(entityId, "Add", amount);
}
```

**Isolated worker process:**

```csharp
[Function("AddFromQueue")]
public static Task Run(
    [QueueTrigger("durable-function-trigger")] string input,
    [DurableClient] DurableTaskClient client)
{
    // Entity operation input comes from the queue message content.
    var entityId = new EntityInstanceId(nameof(Counter), "myCounter");
    int amount = int.Parse(input);
    return client.Entities.SignalEntityAsync(entityId, "Add", amount);
}
```

# [JavaScript](#tab/javascript)

```javascript
const df = require("durable-functions");

module.exports = async function (context) {
    const client = df.getClient(context);
    const entityId = new df.EntityId("Counter", "myCounter");
    await client.signalEntity(entityId, "add", 1);
};
```

# [Python](#tab/python)

```python
import azure.functions as func
import azure.durable_functions as df

# An HTTP-Triggered Function with a Durable Functions Client to set a value on a durable entity
@myApp.route(route="entitysetvalue")
@myApp.durable_client_input(client_name="client")
async def http_set(req: func.HttpRequest, client):
    entityId = df.EntityId("Counter", "myCounter")
    await client.signal_entity(entityId, "add", 1)
    return func.HttpResponse("Done", status_code=200)
```

# [PowerShell](#tab/powershell)

Entity functions aren't currently supported in PowerShell.

# [Java](#tab/java)

Entity functions aren't currently supported in Java.

---

A *signal* is a one-way, asynchronous entity API invocation. A client function doesn't know when the entity processes the operation, and it can't observe return values or exceptions.

::: zone-end

::: zone pivot="durable-task-sdks"

To use entities from a client, use `DurableTaskClient` to signal entities or read entity state.

# [C#](#tab/csharp)

```csharp
using Microsoft.DurableTask.Client;
using Microsoft.DurableTask.Entities;

// Signal an entity
var entityId = new EntityInstanceId(nameof(Account), "myAccount");
await client.Entities.SignalEntityAsync(entityId, nameof(Account.Deposit), 100);
```

# [JavaScript](#tab/javascript)

This sample is shown for .NET and Python.

# [Python](#tab/python)

```python
from durabletask import entities

# Signal an entity
entity_id = entities.EntityInstanceId("counter", "my-counter")
client.signal_entity(entity_id, "add", input=100)
```

# [PowerShell](#tab/powershell)

This sample is shown for .NET and Python.

# [Java](#tab/java)

Entities aren't currently supported in the Java Durable Task SDK.

---

A *signal* is a one-way, asynchronous entity API invocation. A client doesn't know when the entity processes the operation.

::: zone-end

### Example: client reads an entity state

::: zone pivot="durable-functions"

Query an entity state from a client function:

# [C#](#tab/csharp)

**In-process:**

```csharp
[FunctionName("QueryCounter")]
public static async Task<HttpResponseMessage> Run(
    [HttpTrigger(AuthorizationLevel.Function)] HttpRequestMessage req,
    [DurableClient] IDurableEntityClient client)
{
    var entityId = new EntityId(nameof(Counter), "myCounter");
    EntityStateResponse<JObject> stateResponse = await client.ReadEntityStateAsync<JObject>(entityId);
    return req.CreateResponse(HttpStatusCode.OK, stateResponse.EntityState);
}
```

**Isolated worker process:**

```csharp
[Function("QueryCounter")]
public static async Task<HttpResponseData> Run(
    [HttpTrigger(AuthorizationLevel.Function)] HttpRequestData req,
    [DurableClient] DurableTaskClient client)
{
    var entityId = new EntityInstanceId(nameof(Counter), "myCounter");
    EntityMetadata<int>? entity = await client.Entities.GetEntityAsync<int>(entityId);

    if (entity is null)
    {
        return req.CreateResponse(HttpStatusCode.NotFound);
    }

    HttpResponseData response = req.CreateResponse(HttpStatusCode.OK);
    await response.WriteAsJsonAsync(entity);

    return response;
}
```

# [JavaScript](#tab/javascript)

```javascript
const df = require("durable-functions");

module.exports = async function (context) {
    const client = df.getClient(context);
    const entityId = new df.EntityId("Counter", "myCounter");
    const stateResponse = await client.readEntityState(entityId);
    return stateResponse.entityState;
};
```

# [Python](#tab/python)

```python
# An HTTP-Triggered Function with a Durable Functions Client to retrieve the state of a durable entity
@myApp.route(route="entityreadvalue")
@myApp.durable_client_input(client_name="client")
async def http_read(req: func.HttpRequest, client):
    entityId = df.EntityId("Counter", "myCounter")
    entity_state_result = await client.read_entity_state(entityId)
    entity_state = "No state found"
    if entity_state_result.entity_exists:
      entity_state = str(entity_state_result.entity_state)
    return func.HttpResponse(entity_state)
```

# [PowerShell](#tab/powershell)

Entity functions aren't currently supported in PowerShell.

# [Java](#tab/java)

Entity functions aren't currently supported in Java.

---

::: zone-end

::: zone pivot="durable-task-sdks"

Clients can query the state of an entity:

# [C#](#tab/csharp)

```csharp
using Microsoft.DurableTask.Client;
using Microsoft.DurableTask.Entities;

var entityId = new EntityInstanceId(nameof(Account), "myAccount");
EntityMetadata<int>? entity = await client.Entities.GetEntityAsync<int>(entityId);

if (entity != null)
{
    Console.WriteLine($"Current balance: {entity.State}");
}
```

# [JavaScript](#tab/javascript)

This sample is shown for .NET and Python.

# [Python](#tab/python)

```python
from durabletask import entities

entity_id = entities.EntityInstanceId("counter", "my-counter")
state = client.get_entity_state(entity_id)
if state is not None:
    print(f"Current value: {state}")
```

# [PowerShell](#tab/powershell)

This sample is shown for .NET and Python.

# [Java](#tab/java)

Entities aren't currently supported in the Java Durable Task SDK.

---

::: zone-end

The Durable Functions runtime sends entity state queries to the durable tracking store and returns the entity's most recently persisted state. The returned state is always committed. It isn't a temporary intermediate state during an operation. But the returned state can be stale compared to the entity's in-memory state. Only orchestrations can read an entity's in-memory state, as described in the next section.

### Example: orchestration signals and calls an entity

::: zone pivot="durable-functions"

Orchestrator functions can access entities by using APIs on the [orchestration trigger binding](durable-functions-bindings.md#orchestration-trigger). The following example code shows an orchestrator function calling and signaling a `Counter` entity.

# [C#](#tab/csharp)

**In-process:**

```csharp
[FunctionName("CounterOrchestration")]
public static async Task Run(
    [OrchestrationTrigger] IDurableOrchestrationContext context)
{
    var entityId = new EntityId(nameof(Counter), "myCounter");

    // Two-way call to the entity which returns a value - awaits the response
    int currentValue = await context.CallEntityAsync<int>(entityId, "Get");
    if (currentValue < 10)
    {
        // One-way signal to the entity which updates the value - does not await a response
        context.SignalEntity(entityId, "Add", 1);
    }
}
```

**Isolated worker process:**

```csharp
[Function("CounterOrchestration")]
public static async Task Run([OrchestrationTrigger] TaskOrchestrationContext context)
{
    var entityId = new EntityInstanceId(nameof(Counter), "myCounter");

    // Two-way call to the entity which returns a value - awaits the response
    int currentValue = await context.Entities.CallEntityAsync<int>(entityId, "Get");

    if (currentValue < 10)
    {
        // One-way signal to the entity which updates the value - does not await a response
        await context.Entities.SignalEntityAsync(entityId, "Add", 1);
    }
}
```

# [JavaScript](#tab/javascript)

```javascript
const df = require("durable-functions");

module.exports = df.orchestrator(function* (context) {
    const entityId = new df.EntityId("Counter", "myCounter");

    // Two-way call to the entity which returns a value - awaits the response
    const currentValue = yield context.df.callEntity(entityId, "get");
    return currentValue;
});
```

> [!NOTE]
> JavaScript doesn't support signaling an entity from an orchestrator. Use `callEntity` instead.

# [Python](#tab/python)

```python
@myApp.orchestration_trigger(context_name="context")
def orchestrator(context: df.DurableOrchestrationContext):
    entityId = df.EntityId("Counter", "myCounter")
    context.signal_entity(entityId, "add", 3)
    state = yield context.call_entity(entityId, "get")
    return state
```

# [PowerShell](#tab/powershell)

Entity functions aren't currently supported in PowerShell.

# [Java](#tab/java)

Entity functions aren't currently supported in Java.

---

Only orchestrations can call entities and get a response, which can be a return value or an exception. Client functions that use the [client binding](durable-functions-bindings.md#entity-client) can only signal entities.

::: zone-end

::: zone pivot="durable-task-sdks"

Orchestrators can access entities using the context's Entities API:

# [C#](#tab/csharp)

```csharp
using Microsoft.DurableTask;
using Microsoft.DurableTask.Entities;

[DurableTask]
public class AccountOrchestration : TaskOrchestrator<string, int>
{
    public override async Task<int> RunAsync(TaskOrchestrationContext context, string entityKey)
    {
        var entityId = new EntityInstanceId(nameof(Account), entityKey);

        // Two-way call to the entity which returns a value - awaits the response
        int currentBalance = await context.Entities.CallEntityAsync<int>(entityId, nameof(Account.GetBalance));

        if (currentBalance < 100)
        {
            // One-way signal to the entity - does not await a response
            await context.Entities.SignalEntityAsync(entityId, nameof(Account.Deposit), 50);
        }

        return currentBalance;
    }
}
```

# [JavaScript](#tab/javascript)

This sample is shown for .NET and Python.

# [Python](#tab/python)

```python
from durabletask import task, entities

def counter_workflow(ctx: task.OrchestrationContext, entity_key: str):
    """Orchestration that demonstrates entity interactions."""
    entity_id = entities.EntityInstanceId("counter", entity_key)

    # Signal entity operations (fire and forget)
    ctx.signal_entity(entity_id=entity_id, operation_name="add", input=10)
    ctx.signal_entity(entity_id=entity_id, operation_name="add", input=5)
    ctx.signal_entity(entity_id=entity_id, operation_name="subtract", input=3)

    # Call entity and wait for result
    value = yield ctx.call_entity(entity=entity_id, operation="get")

    return f"Counter '{entity_key}' final value: {value}"
```

# [PowerShell](#tab/powershell)

This sample is shown for .NET and Python.

# [Java](#tab/java)

Entities aren't currently supported in the Java Durable Task SDK.

---

Only orchestrators can call entities and get a response, which can be a return value or an exception. Clients can only signal entities.

::: zone-end

> [!NOTE]
> Calling an entity from an orchestrator is similar to calling an activity. The main difference is that entities are durable objects with an address (the entity ID) and support specifying an operation name. Activities are stateless and don't have the concept of operations.

::: zone pivot="durable-functions"

### Example: entity signals an entity

An entity function can signal other entities, or even itself, while it executes an operation.
For example, modify the previous `Counter` entity example to send a "milestone-reached" signal to a monitor entity when the counter reaches 100.

# [C#](#tab/csharp)

**In-process:**

```csharp
   case "add":
        var currentValue = ctx.GetState<int>();
        var amount = ctx.GetInput<int>();
        if (currentValue < 100 && currentValue + amount >= 100)
        {
            ctx.SignalEntity(new EntityId("MonitorEntity", ""), "milestone-reached", ctx.EntityKey);
        }

        ctx.SetState(currentValue + amount);
        break;
```

**Isolated worker process:**

```csharp
case "add":
    var currentValue = operation.State.GetState<int>();
    var amount = operation.GetInput<int>();
    if (currentValue < 100 && currentValue + amount >= 100)
    {
        operation.Context.SignalEntity(new EntityInstanceId("MonitorEntity", ""), "milestone-reached", operation.Context.EntityInstanceId);
    }

    operation.State.SetState(currentValue + amount);
    break;
```

# [JavaScript](#tab/javascript)

```javascript
    case "add":
        const amount = context.df.getInput();
        if (currentValue < 100 && currentValue + amount >= 100) {
            const entityId = new df.EntityId("MonitorEntity", "");
            context.df.signalEntity(entityId, "milestone-reached", context.df.instanceId);
        }
        context.df.setState(currentValue + amount);
        break;
```

# [Python](#tab/python)

> [!NOTE]
> Python doesn't support entity-to-entity signals. Use an orchestrator to signal entities instead.

# [PowerShell](#tab/powershell)

Entity functions aren't currently supported in PowerShell.

# [Java](#tab/java)

Entity functions aren't currently supported in Java.

---

::: zone-end

::: zone pivot="durable-task-sdks"

### Example: entity signals an entity

Entity-to-entity signaling isn't currently supported in the Durable Task SDKs. Use an orchestrator to coordinate communication between entities instead.

::: zone-end

## Entity coordination

::: zone pivot="durable-functions"

Sometimes you need to coordinate operations across multiple entities. For example, in a banking application, entities can represent individual bank accounts. When you transfer funds from one account to another, you need to make sure the source account has enough funds. You also need to update both accounts as one consistent operation.

### Example: Transfer funds (C#)

The following example code transfers funds between two account entities by using an orchestrator function. To coordinate entity updates, use the `LockAsync` method to create a _critical section_ in the orchestration.

> [!NOTE]
> For simplicity, this example reuses the `Counter` entity defined previously. In a real application, it's better to define a more detailed `BankAccount` entity.

```csharp
// This is a method called by an orchestrator function
public static async Task<bool> TransferFundsAsync(
    string sourceId,
    string destinationId,
    int transferAmount,
    IDurableOrchestrationContext context)
{
    var sourceEntity = new EntityId(nameof(Counter), sourceId);
    var destinationEntity = new EntityId(nameof(Counter), destinationId);

    // Create a critical section to avoid race conditions.
    // No operations can be performed on either the source or
    // destination accounts until the locks are released.
    using (await context.LockAsync(sourceEntity, destinationEntity))
    {
        ICounter sourceProxy =
            context.CreateEntityProxy<ICounter>(sourceEntity);
        ICounter destinationProxy =
            context.CreateEntityProxy<ICounter>(destinationEntity);

        int sourceBalance = await sourceProxy.Get();

        if (sourceBalance >= transferAmount)
        {
            await sourceProxy.Add(-transferAmount);
            await destinationProxy.Add(transferAmount);

            // the transfer succeeded
            return true;
        }
        else
        {
            // the transfer failed due to insufficient funds
            return false;
        }
    }
}
```

In .NET, `LockAsync` returns `IDisposable`. Disposing it ends the critical section. Use it with a `using` block to represent the critical section.

In this example, an orchestrator function transfers funds from a source entity to a destination entity. The `LockAsync` method locks both the source and destination account entities. This locking ensures that no other client can query or modify the state of either account until the orchestration logic exits the critical section at the end of the `using` statement. This behavior prevents overdrafts on the source account.

> [!NOTE]
> When an orchestration ends, either normally or with an error, any critical sections in progress end implicitly, and the system releases all locks.

### Critical section behavior

The `LockAsync` method creates a critical section in an orchestration. These critical sections prevent other orchestrations from making overlapping changes to a specified set of entities. Internally, the `LockAsync` API sends "lock" operations to the entities and returns after it receives a "lock acquired" response from each entity. Both lock and unlock are built-in operations supported by all entities.

Other clients can't run operations on an entity while it's locked. This behavior ensures that only one orchestration instance can lock an entity at a time. If a caller tries to invoke an operation on an entity while it's locked by an orchestration, the system places that operation in a pending operation queue. The system doesn't process pending operations until the holding orchestration releases its lock.

> [!NOTE]
> This behavior is slightly different from synchronization primitives used in most programming languages, such as the `lock` statement in C#. For example, in C#, all threads need to use the `lock` statement to ensure proper synchronization. Entities, however, don't require all callers to explicitly lock an entity. If any caller locks an entity, all other operations on that entity are blocked and queued behind that lock.

Locks on entities are durable, so they persist even if the executing process is recycled. The system persists locks as part of an entity's durable state.

Unlike transactions, critical sections don't automatically roll back changes when errors occur. Instead, write error handling, such as rollback or retry, for example by catching errors or exceptions. This design choice is intentional. Automatically rolling back all the effects of an orchestration is difficult or impossible in general, because orchestrations might run activities and make calls to external services that can't be rolled back. Also, attempts to roll back might themselves fail and require further error handling.

### Critical section rules

Unlike low-level locking primitives in most programming languages, critical sections are *guaranteed not to deadlock*. To prevent deadlocks, we enforce the following restrictions:

* Critical sections can't be nested.
* Critical sections can't create suborchestrations.
* Critical sections can call only the entities they lock.
* Critical sections can't call the same entity using multiple parallel calls.
* Critical sections can signal only entities outside the lock set.

Any violations of these rules cause a runtime error, such as `LockingRulesViolationException` in .NET, which includes a message that explains what rule was broken.

::: zone-end

::: zone pivot="durable-task-sdks"

Sometimes you need to coordinate operations across multiple entities. For example, in a banking application, entities can represent individual bank accounts. When you transfer funds from one account to another, you need to make sure the source account has enough funds. You also need to update both accounts in a single, consistent transaction.

### Example: Transfer funds

The following example code transfers funds between two account entities by using an orchestrator. To coordinate entity updates, use the `LockEntitiesAsync` method to create a _critical section_ in the orchestration.

# [C#](#tab/csharp)

```csharp
using Microsoft.DurableTask;
using Microsoft.DurableTask.Entities;

[DurableTask]
public class TransferFundsOrchestration : TaskOrchestrator<TransferRequest, bool>
{
    public override async Task<bool> RunAsync(TaskOrchestrationContext context, TransferRequest request)
    {
        // The source and destination accounts are both entities identified by their account ID.
        EntityInstanceId sourceAccount = new(nameof(Account), request.SourceId);
        EntityInstanceId destinationAccount = new(nameof(Account), request.DestinationId);

        // Create a critical section that locks these entities and prevents
        // any other caller from changing their state until our locks are released.
        await using (await context.Entities.LockEntitiesAsync(sourceAccount, destinationAccount))
        {
            // Check the balance of the source account to ensure it has enough funds.
            int sourceBalance = await context.Entities.CallEntityAsync<int>(
                id: sourceAccount,
                operationName: nameof(Account.GetBalance));

            if (sourceBalance >= request.Amount)
            {
                // Withdraw from the source account.
                await context.Entities.CallEntityAsync(
                    id: sourceAccount,
                    operationName: nameof(Account.Withdraw),
                    input: request.Amount);

                // Deposit into the destination account.
                await context.Entities.CallEntityAsync(
                    id: destinationAccount,
                    operationName: nameof(Account.Deposit),
                    input: request.Amount);

                // The transfer succeeded!
                return true;
            }
            else
            {
                // The transfer failed due to insufficient funds.
                return false;
            }
        }
    }
}
```

The `LockEntitiesAsync` method returns an `IAsyncDisposable` object. Disposing it ends the critical section. Use it with an `await using` block to represent the critical section.

This locking ensures that no other client can query or modify the state of either account until the orchestration logic exits the critical section at the end of the `await using` statement. This behavior prevents overdrafts on the source account.

# [JavaScript](#tab/javascript)

Entity coordination with critical sections isn't currently supported in the JavaScript SDK.

# [Python](#tab/python)

```python
from durabletask import task, entities

class Account(entities.DurableEntity):
    def deposit(self, amount: int):
        current = self.get_state(int, 0)
        self.set_state(current + amount)

    def withdraw(self, amount: int):
        current = self.get_state(int, 0)
        self.set_state(current - amount)

    def get_balance(self):
        return self.get_state(int, 0)


def transfer_funds_orchestrator(ctx: task.OrchestrationContext, request: dict):
    """Orchestrator that transfers funds between two accounts using entity locking."""
    source_id = entities.EntityInstanceId("Account", request["source_id"])
    destination_id = entities.EntityInstanceId("Account", request["destination_id"])
    amount = request["amount"]

    # Lock both entities to prevent concurrent modifications
    with (yield ctx.lock_entities([source_id, destination_id])):
        # Check source balance
        source_balance = yield ctx.call_entity(source_id, "get_balance")

        if source_balance >= amount:
            # Withdraw from source
            yield ctx.call_entity(source_id, "withdraw", amount)
            # Deposit to destination
            yield ctx.call_entity(destination_id, "deposit", amount)
            return True
        else:
            # Insufficient funds
            return False
```

Use `ctx.lock_entities()` to create a critical section. The `with (yield ctx.lock_entities([...]))` syntax ensures locks are released when the block exits.

# [PowerShell](#tab/powershell)

Entity coordination with critical sections isn't currently supported in the PowerShell SDK.

# [Java](#tab/java)

Entities aren't currently supported in the Java Durable Task SDK.

---

### Critical section behavior

The `LockEntitiesAsync` method creates a critical section in an orchestration. These critical sections prevent other orchestrations from making overlapping changes to a specified set of entities. Internally, the API sends "lock" operations to the entities and returns after it receives a "lock acquired" response from each entity.

Other clients can't run operations on an entity while it's locked. This behavior ensures that only one orchestration instance can lock an entity at a time. If a caller tries to invoke an operation on an entity while it's locked by an orchestration, that operation is placed in a pending operation queue. No pending operations are processed until after the holding orchestration releases its lock.

Locks on entities are durable, so they persist even if the executing process is recycled. The system persists locks as part of an entity's durable state.

Unlike transactions, critical sections don't automatically roll back changes when errors occur. Instead, write error handling, such as rollback or retry, for example by catching errors or exceptions.

::: zone-end

## Comparison with virtual actors

Durable entities use ideas from the [actor model](https://en.wikipedia.org/wiki/Actor_model). If you're familiar with actors, some concepts in this article look familiar. Durable entities are similar to [virtual actors](https://research.microsoft.com/projects/orleans/), also called grains, from the [Orleans project](http://dotnet.github.io/orleans/). For example:

* You address durable entities by using an entity ID.
* Durable entity operations run serially to prevent race conditions.
* Calling or signaling an entity creates it implicitly.
* The runtime unloads entities from memory when they aren't running operations.

Key differences include:

* Durable entities prioritize durability over latency, so they might not meet strict latency requirements.
* Durable entities don't time out messages. Orleans times out messages after a configurable period (30 seconds by default).
* Durable entities deliver messages reliably and in order. Orleans supports reliable, ordered delivery for stream messages, but it doesn't guarantee ordered delivery for all messages between grains.
* Only orchestrations support request-response calls to entities. Inside an entity, use one-way messaging (signaling), like in the original actor model.
* Durable entities don't deadlock. Orleans can deadlock, and deadlocks persist until messages time out.
* Durable entities work with durable orchestrations and support distributed locks.

## Next steps

::: zone pivot="durable-functions"

> [!div class="nextstepaction"]
> [Read the developer guide to durable entities in .NET](durable-functions-dotnet-entities.md)

> [!div class="nextstepaction"]
> [Learn about task hubs](durable-functions-task-hubs.md)

::: zone-end

::: zone pivot="durable-task-sdks"

> [!div class="nextstepaction"]
> [Get started with Durable Task SDKs](durable-task-scheduler/quickstart-portable-durable-task-sdks.md)

::: zone-end
