---
title: Choosing an orchestration framework
description: Learn which orchestration framework works for your scenario.
ms.topic: concept-article
ms.date: 10/28/2025
---

# Choosing an orchestration framework

In this article, you learn:

> [!div class="checklist"]
> - The benefits of using an orchestration framework.
> - Which framework works best for your scenario. 

Azure offers two developer-oriented orchestration frameworks you can use to build apps: **Durable Functions** for apps hosted in Azure Functions, and **Durable Task SDKs** for apps hosted on other compute platforms. Orchestrations, also called _workflows_, involve arranging and coordinating multiple (long-running) tasks or processes, often involving multiple systems, to be executed in a certain order. It's important that an orchestration framework guarantees _durable execution_, meaning when there are interruptions or infrastructure failures, execution can continue in another process or machine from the point of failure. The Durable Task SDKs and Durable Functions ensure that orchestrations are executed durably through built-in state persistence and automatic retries, so that you can author orchestrations without the burden of architecting for fault tolerance.

## Scenarios requiring orchestration 

The following scenarios require common orchestration patterns that benefit from the Durable Task SDKs and Durable Functions: 
- **Function chaining:** For scenarios involving sequential steps, where each step might depend on the output of the previous one. 
- **Fan-out/fan-in:** For batch jobs, ETL (extract, transfer, and load), and any scenario that requires parallel processing. 
- **Human interactions:** For two-factor authentication, workflows requiring human intervention. 
- **Asynchronous HTTP APIs:** For any scenario where a client doesn't want to wait for long-running tasks to complete. 

The following two scenarios share the *function chaining* pattern. 

### Processing orders on an e-commerce website

Suppose you create an e-commerce website. Your website likely needs an order processing workflow for any customer purchase. The workflow might include the following sequential steps:
1. Check the inventory
1. Process payment
1. Update the inventory
1. Generate invoice
1. Send order confirmation

### Invoking AI agents for planning a trip

In this scenario, you need to create an intelligent trip planner. The planner goes through a series of known steps:
1. Suggest ideas based on user requirements
1. Get preference confirmation
1. Make required bookings

You can implement an AI agent for each task, then write an orchestration that invokes these agents in a certain order. 

## Orchestration framework options  

Both Durable Functions and Durable Task SDK are available in multiple languages, but some differences exist in how you can use them. 

| Feature | Durable Functions | Durable Task SDKs |
|---------|-------------------|-------------------|
| **Compute Platform** | Azure Functions only | Any (.NET, Python, Java apps) |
| **Scale to Zero** | ✅ Yes | ❌ Minimum 1 instance |
| **Trigger Types** | HTTP, Queue, Timer, etc. | Custom (you implement) |
| **Language Support** | C#, JS, Python, Java, PS | .NET, Python, Java (Preview) |
| **Entity Functions** | ✅ Full support | ✅ .NET only |
| **Deployment** | Function App | Container, VM, any host |
| **Cold Start** | Yes (mitigated with Premium) | No (always running) |
| **Pricing Model** | Pay-per-execution | Pay for compute time |

### Durable Functions
 
As a feature of Azure Functions, [Durable Functions](../what-is-durable-task.md) inherits numerous assets, such as:
- Integrations with other Azure services through the Functions extensions
- Local development experience 
- Serverless pricing model
- Hosting in Azure App Service and Azure Container Apps 

Durable Functions persists states in a [storage backend](../durable-functions-storage-providers.md) and supports:
- Two "bring-your-own" (BYO) backends:
  - Azure Storage 
  - Microsoft SQL 
- An Azure managed backend:
  - [Durable Task Scheduler](#durable-task-sdks-with-durable-task-scheduler) 

#### When to use Durable Functions

Consider using Durable Functions if you need to build event-driven apps with workflows. The Azure Functions extensions provide integrations with other Azure services, which make building event-driven scenarios easy. For example, with Durable Functions, you can:

- Start an orchestration when a message comes into your Azure Service Bus or a file uploads to Azure Blob Storage. 
- Build an orchestration that runs periodically or in response to an HTTP request with the Azure Functions timer and HTTP trigger, respectively. 
- Accelerate workflow development for your Azure Function apps, since Durable Functions programming model is similar to Azure Functions.

#### Example

# [C#](#tab/csharp)

```csharp
public class OrderFunctions
{
    [Function("StartOrder")]
    public async Task<IActionResult> StartOrder(
        [HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequest req,
        [DurableClient] DurableTaskClient client)
    {
        var order = await req.ReadFromJsonAsync<Order>();
        var instanceId = await client.ScheduleNewOrchestrationInstanceAsync(
            nameof(ProcessOrder), order);
        return new OkObjectResult(new { instanceId });
    }
    
    [Function(nameof(ProcessOrder))]
    public async Task<OrderResult> ProcessOrder(
        [OrchestrationTrigger] TaskOrchestrationContext context)
    {
        // Orchestration logic
    }
}
```

# [Python](#tab/python)

```python
@app.route(route="StartOrder", methods=["POST"])
@app.durable_client_input(client_name="client")
async def start_order(req: func.HttpRequest, client) -> func.HttpResponse:
    order = req.get_json()
    instance_id = await client.schedule_new_orchestration_instance(
        "ProcessOrder", order)
    return func.HttpResponse(f'{{"instanceId": "{instance_id}"}}')

@app.orchestration_trigger(context_name="context")
def process_order(context):
    # Orchestration logic
    pass
```

# [Java](#tab/java)

```java
public class OrderFunctions {
    @FunctionName("StartOrder")
    public HttpResponseMessage startOrder(
            @HttpTrigger(name = "req", methods = {HttpMethod.POST}, 
                authLevel = AuthorizationLevel.FUNCTION) HttpRequestMessage<Order> req,
            @DurableClientInput(name = "durableContext") DurableClientContext durableContext) {
        
        Order order = req.getBody();
        DurableTaskClient client = durableContext.getClient();
        String instanceId = client.scheduleNewOrchestrationInstance("ProcessOrder", order);
        return req.createResponseBuilder(HttpStatus.OK)
            .body(new InstanceResponse(instanceId))
            .build();
    }
    
    @FunctionName("ProcessOrder")
    public OrderResult processOrder(
            @DurableOrchestrationTrigger(name = "context") TaskOrchestrationContext context) {
        // Orchestration logic
        return new OrderResult();
    }
}
```

---

#### Try it out

Walk through one of the following quickstarts or samples to learn more about Durable Functions.

##### Quickstarts

|   | Quickstart | Description |
| - | ---------- | ----------- |
| **Durable Task Scheduler** | [Create a Durable Functions app with Durable Task Scheduler](./quickstart-durable-task-scheduler.md) | Create a "hello world" Durable Functions app that uses the Durable Task Scheduler as the backend, test locally, and publish to Azure. |
| **Azure Storage** | Create a Durable Functions app with the Azure Storage backend:<br>- [.NET](../durable-functions-isolated-create-first-csharp.md)<br>- [Python](../quickstart-python-vscode.md)<br>- [JavaScript/TypeScript](../quickstart-js-vscode.md)<br>- [Java](../quickstart-java.md)<br>- [PowerShell](../quickstart-powershell-vscode.md) | Create a "hello world" Durable Functions app that uses Azure Storage as the backend, test locally, and publish to Azure. |
| **MSSQL** | [Create a Durable Functions app with MSSQL](../quickstart-mssql.md) | Create a "hello world" Durable Functions app that uses MSSQL as the backend, test locally, and publish to Azure. |
 
##### Samples

|   | Sample | Description |
| - | ---------- | ----------- |
| **Order processing workflow** | Create an order processing workflow with Durable Functions:<br>- [.NET](/samples/azure-samples/durable-functions-order-processing/durable-func-order-processing/)<br>- [Python](/samples/azure-samples/durable-functions-order-processing-python/durable-func-order-processing-py/) | This sample implements an order processing workflow that includes checking inventory, processing payment, updating inventory, and notifying customer. |
| **Intelligent PDF summarizer** | Create an app that processes PDFs with Durable Functions:<br>- [.NET](/samples/azure-samples/intelligent-pdf-summarizer-dotnet/durable-func-pdf-summarizer-csharp/)<br>- [Python](/samples/azure-samples/intelligent-pdf-summarizer/durable-func-pdf-summarizer/) | This sample demonstrates using Durable Functions to coordinate the steps for processing and summarizing PDFs using Azure Cognitive Services and Azure OpenAI. |

### Durable Task SDKs with Durable Task Scheduler

The Durable Task SDKs are client SDKs that you use with the Durable Task Scheduler. The Durable Task SDKs connect the orchestrations you write to the Durable Task Scheduler orchestration engine in Azure. You can run apps that use the Durable Task SDKs on any compute platform, including:
- Azure Kubernetes Service
- Azure Container Apps
- Azure App Service
- Virtual Machines (VMs) on-premises

The [Durable Task Scheduler](./durable-task-scheduler.md) (Java SDK currently in preview) acts as both the orchestration engine and the storage backend for orchestration state persistence. The Durable Task Scheduler:
- Is fully managed by Azure, so it removes management overhead
- Provides high orchestration throughput
- Offers an out-of-the-box dashboard for orchestration monitoring and debugging
- Includes a local emulator

#### When to use Durable Task SDKs

If you don't want to use the Azure Functions programming model, the Durable Task SDKs provide a lightweight and relatively unopinionated programming model for authoring workflows. 

When you need to run apps on Azure Kubernetes Services or VMs on-premises with official Microsoft support, consider using the Durable Task SDKs. While you can run Durable Functions on these platforms, there's no official support.

#### Example

# [C#](#tab/csharp)

```csharp
// Durable Task SDK style - as a background service
var builder = Host.CreateApplicationBuilder(args);

builder.Services.AddDurableTaskWorker(options =>
{
    options.AddOrchestrator<OrderProcessingOrchestrator>();
    options.AddActivity<ValidateOrderActivity>();
})
.UseDurableTaskScheduler(endpoint, taskHub);

// Also add your API layer
builder.Services.AddControllers();

var host = builder.Build();
await host.RunAsync();
```

# [Python](#tab/python)

```python
def order_processing_orchestrator(ctx, order):
    yield ctx.call_activity("ValidateOrder", input=order)
    return {"status": "processed"}

def validate_order_activity(ctx, order):
    return True

with DurableTaskSchedulerWorker(endpoint, task_hub, DefaultAzureCredential()) as worker:
    worker.add_orchestrator(order_processing_orchestrator)
    worker.add_activity(validate_order_activity)
    worker.start()
    
    # Your API layer runs here alongside the worker
```

# [Java](#tab/java)

```java
@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        DurableTaskGrpcWorkerBuilder workerBuilder = new DurableTaskGrpcWorkerBuilder();
        
        workerBuilder.addOrchestration(new TaskOrchestrationFactory() {
            public String getName() { return "OrderProcessingOrchestration"; }
            public TaskOrchestration create() {
                return ctx -> {
                    String order = ctx.getInput(String.class);
                    ctx.callActivity("ValidateOrder", order, Boolean.class).await();
                    ctx.complete("processed");
                };
            }
        });
        
        workerBuilder.addActivity(new TaskActivityFactory() {
            public String getName() { return "ValidateOrder"; }
            public TaskActivity create() { return ctx -> true; }
        });
        
        DurableTaskGrpcWorker worker = workerBuilder.build();
        worker.start();
        
        SpringApplication.run(Application.class, args);
    }
}
```

---

#### Try it out

Walk through one of the following quickstarts to configure your applications to use the Durable Task Scheduler with the Durable Task SDKs.

|   | Quickstart | Description |
| - | ---------- | ----------- |
| **Local development quickstart** | [Create an app with Durable Task SDKs and Durable Task Scheduler](./quickstart-portable-durable-task-sdks.md) using either the .NET, Python, or Java SDKs. | Run a fan-in/fan-out orchestration locally using the Durable Task Scheduler emulator and review orchestration history using the dashboard. |
| **Hosting in Azure Container Apps** | [Deploy a Durable Task SDK app to Azure Container Apps](./quickstart-container-apps-durable-task-sdk.md) | Quickly deploy a "hello world" Durable Task SDK app to Azure Container Apps using the Azure Developer CLI. |

### Considerations

#### Support

Knowing which orchestration framework is recommended for production helps you decide which option works best for your project. While the Durable Task backend is fully managed and supported, the Durable Functions extension and Durable Task SDKs vary in stability depending on [the pricing model](./durable-task-scheduler-dedicated-sku.md) and the language SDK you use.

The following table shows what client experience is fit for production use. 

| Experience | Dedicated SKU | Consumption SKU |
| ---------- | ------------- | --------------- |
| **Durable Functions extension in all languages** | Generally available | Preview |
| **Durable Task .NET SDK** | Generally available | Preview |
| **Durable Task Python SDK** | Generally available | Preview |
| **Durable Task Java SDK** | Preview | Preview |

> [!NOTE]
> The Durable Task Framework (DTFx) is an open-source .NET orchestration framework similar to the .NET Durable Task SDK. While you *can* use it to build apps that run on platforms like Azure Kubernetes Services, **DTFx doesn't receive official Microsoft support**.

#### Cost

| Aspect | Durable Functions | Durable Task SDKs |
|--------|-------------------|-------------------|
| **Idle Cost** | $0 (Consumption) | Compute costs |
| **Per-Execution** | Small cost per execution | Included in compute |
| **Predictable Load** | May cost more | Usually cheaper |
| **Burst Traffic** | Scales automatically | Need over-provision |
| **Durable Task Scheduler** | Same pricing | Same pricing |

## Migrate from Durable Functions to Durable Task SDK

The following examples demonstrate how you can migrate your solution from using Durable Functions to using the Durable Task SDKs.

# [.NET](#tab/csharp)

```csharp
// Before (Durable Functions)
[Function(nameof(ProcessOrder))]
public async Task<OrderResult> ProcessOrder(
    [OrchestrationTrigger] TaskOrchestrationContext context)
{
    var order = context.GetInput<Order>();
    await context.CallActivityAsync("Validate", order);
    return new OrderResult();
}

// After (Durable Task SDK) - Very similar!
public class ProcessOrderOrchestrator : TaskOrchestrator<Order, OrderResult>
{
    public override async Task<OrderResult> RunAsync(
        TaskOrchestrationContext context, Order order)
    {
        await context.CallActivityAsync("Validate", order);
        return new OrderResult();
    }
}
```

# [Python](#tab/python)

```python
# Before (Durable Functions)
@myApp.orchestration_trigger(context_name="context")
def process_order(context: df.DurableOrchestrationContext):
    order = context.get_input()
    yield context.call_activity("Validate", order)
    return {"status": "completed"}

# After (Durable Task SDK) - Very similar!
def process_order(ctx: task.OrchestrationContext, order: dict):
    yield ctx.call_activity("Validate", input=order)
    return {"status": "completed"}
```

# [Java](#tab/java)

```java
// Before (Durable Functions)
@FunctionName("ProcessOrder")
public OrderResult processOrder(
        @DurableOrchestrationTrigger(name = "ctx") TaskOrchestrationContext ctx) {
    Order order = ctx.getInput(Order.class);
    ctx.callActivity("Validate", order).await();
    return new OrderResult();
}

// After (Durable Task SDK) - Very similar!
TaskOrchestration processOrder = ctx -> {
    Order order = ctx.getInput(Order.class);
    ctx.callActivity("Validate", order).await();
    ctx.complete(new OrderResult());
};
```

---

## Summary

| Requirement | Recommendation |
|-------------|----------------|
| Serverless, pay-per-use | Durable Functions |
| Always-on worker | Durable Task SDKs |
| Container-based | Durable Task SDKs |
| Quick start/prototype | Durable Functions |
| Full host control | Durable Task SDKs |
| Event Grid/Queue triggers | Durable Functions |
| Kubernetes deployment | Durable Task SDKs |
| Both options work | Choose based on team skills |

## Next steps

- [Durable Functions overview](../what-is-durable-task.md)
- [Durable Functions types and features](../durable-functions-types-features-overview.md)
- [Durable Task Scheduler overview](./durable-task-scheduler.md)
- [Configure managed identity for Durable Task Scheduler](./durable-task-scheduler-identity.md)

