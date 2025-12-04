---
title: Choose an orchestration framework
description: Comprehensive guide comparing Azure Durable Functions and Durable Task SDKs, including decision frameworks, scenario-based recommendations, feature comparisons, and migration strategies for building resilient workflows.
author: cgillum
ms.topic: conceptual
ms.date: 12/04/2024
ms.author: cgillum
ms.reviewer: azfuncdf, hhunter
zone_pivot_groups: durable-task-scheduler-versions
---

# Choose an orchestration framework: Durable Functions vs. Durable Task SDKs

Azure provides two orchestration frameworks for building resilient, long-running workflows: **Azure Durable Functions** and the **Durable Task SDKs**. Both are built on the same underlying Durable Task Framework engine, providing durable execution—the ability to write code that survives process restarts, maintains state automatically, and coordinates complex workflows. However, they target different deployment models and development scenarios.

While both frameworks are suitable for experienced developers familiar with Azure Functions, this guide provides detailed explanations and examples to ensure clarity regardless of your background with Azure orchestrations. The frameworks differ primarily in how you deploy and manage your orchestrations: Durable Functions runs on the managed Azure Functions platform, while Durable Task SDKs runs in your own containerized environments (Container Apps, AKS, or elsewhere).

While both frameworks are suitable for experienced developers familiar with Azure Functions, this guide provides detailed explanations and examples to ensure clarity regardless of your background with Azure orchestrations. The frameworks differ primarily in how you deploy and manage your orchestrations: Durable Functions runs on the managed Azure Functions platform, while Durable Task SDKs runs in your own containerized environments (Container Apps, AKS, or elsewhere).

## Quick decision flowchart

Use this flowchart to quickly narrow your choice:

```
Start: I need durable orchestrations
│
├─ Do you need non-.NET languages (Python, JavaScript, Java, PowerShell)?
│  └─ YES → Choose Durable Functions
│  └─ NO → Continue
│
├─ Do you need zero infrastructure management and serverless deployment?
│  └─ YES → Choose Durable Functions
│  └─ NO → Continue
│
├─ Do you already have Kubernetes or container-based infrastructure?
│  └─ YES → Consider Durable Task SDKs
│  └─ NO → Continue
│
├─ Is this a production-critical workload requiring maximum stability today?
│  └─ YES → Choose Durable Functions (GA since 2018)
│  └─ NO → Continue
│
├─ Do you need custom container configurations, Kubernetes orchestration, or full hosting control?
│  └─ YES → Choose Durable Task SDKs
│  └─ NO → Choose Durable Functions (recommended default)
│
└─ Default recommendation: Start with Durable Functions
   (Migrate to Durable Task SDKs later if containerization needs emerge)
```

## Framework comparison at a glance

| Consideration | Durable Functions | Durable Task SDKs |
|--------------|------------------|-------------------|
| **Hosting model** | Managed serverless (Azure Functions) | Self-hosted containers (AKS, Container Apps) |
| **Infrastructure** | Fully managed, auto-scaling | You manage containers and scaling |
| **Language support** | C#, JavaScript, TypeScript, Python, Java, PowerShell | C# only |
| **Production status** | GA (Generally Available since 2018) | Preview |
| **Deployment complexity** | Low (push code, Functions handles rest) | Medium-High (containerization, Kubernetes) |
| **Cost model** | Pay-per-execution (Consumption) or reserved (Premium) | Pay for container compute resources |
| **Customization** | Limited to Functions capabilities | Full control over hosting environment |
| **Best for** | Event-driven workflows, variable loads, rapid development | Microservices, Kubernetes ecosystems, on-premises |

## Detailed decision framework

### 1. Language requirements

**Choose Durable Functions if**:
- You need **JavaScript/TypeScript**, **Python**, **Java**, or **PowerShell** support
- Your team has expertise in non-.NET languages
- You want language flexibility for different components

**Choose Durable Task SDKs if**:
- Your application is already written in **C#**
- You're comfortable with .NET-only constraints
- You need direct access to lower-level Durable Task Framework APIs

### 2. Hosting and infrastructure control

**Choose Durable Functions if**:
- You want **zero infrastructure management**
- You need **automatic scaling** based on workload
- You prefer **serverless deployment** models
- You want fast time-to-production without DevOps overhead

**Choose Durable Task SDKs if**:
- You need **full control** over the hosting environment
- You require **custom container configurations** (GPU nodes, specialized hardware)
- You have existing **Kubernetes (AKS) or Container Apps** infrastructure
- You need **on-premises deployment** or edge computing scenarios
- You want **custom autoscaling rules** beyond Functions capabilities

### 3. Production maturity and support

**Choose Durable Functions if**:
- You need **maximum production stability** right now
- You require **extensive documentation** and community support
- You want **battle-tested technology** (GA since 2018, thousands of deployments)
- You need **enterprise SLAs** and proven reliability

**Choose Durable Task SDKs if**:
- You're comfortable with **preview technology** that's rapidly evolving
- You're building forward-looking projects with longer timelines
- You can absorb potential breaking changes as the SDK matures
- You need cutting-edge features not yet available in Durable Functions

### 4. Development and deployment experience

**Choose Durable Functions if**:
- You want **rapid development cycles** with minimal boilerplate
- You need **integrated monitoring** through Application Insights
- You prefer **simple deployment** via Azure Portal, CLI, or GitHub Actions
- You want **built-in triggers and bindings** (HTTP, Timer, Queue, Event Grid, etc.)

**Choose Durable Task SDKs if**:
- You need **container-native deployment** (Docker, Helm charts)
- You want **custom observability** solutions (Prometheus, Grafana, Jaeger)
- You require **service mesh integration** (Istio, Linkerd)
- You prefer **GitOps workflows** and Kubernetes-native CI/CD 

- You prefer **GitOps workflows** and Kubernetes-native CI/CD

## Scenario-based recommendations

### E-commerce order processing

**Recommended: Durable Functions**

E-commerce workloads thrive with serverless characteristics:

- **Variable traffic patterns**: Handle flash sales, seasonal peaks, and off-peak troughs automatically
- **Event-driven architecture**: Respond to orders, payments, inventory changes, and shipping updates
- **Cost optimization**: Pay only for order processing executions
- **Built-in reliability**: Automatic retries for payment gateway timeouts, inventory checks, and notification failures

**Typical workflow**: Order Received → Payment Processing → Inventory Reservation → Fulfillment Request → Shipping Notification → Customer Confirmation

**Example orchestration**:

```csharp
[Function(nameof(OrderOrchestration))]
public async Task<OrderResult> RunOrchestrator(
    [OrchestrationTrigger] TaskOrchestrationContext context)
{
    var order = context.GetInput<Order>();
    
    // Sequential processing with automatic state management
    var paymentResult = await context.CallActivityAsync<PaymentResult>(
        nameof(ProcessPayment), order.Payment);
    
    var inventoryResult = await context.CallActivityAsync<InventoryResult>(
        nameof(ReserveInventory), order.Items);
    
    var shipmentResult = await context.CallActivityAsync<ShipmentResult>(
        nameof(CreateShipment), (order, inventoryResult));
    
    await context.CallActivityAsync(
        nameof(SendConfirmation), (order, shipmentResult));
    
    return new OrderResult(order.Id, shipmentResult.TrackingNumber);
}
```

[View full e-commerce order processing sample →](https://github.com/Azure/azure-functions-durable-extension/tree/main/samples/ecommerce-sample)

### AI agent orchestration with GPU workloads

**Recommended: Durable Task SDKs on AKS**

AI and machine learning workloads benefit from container-based hosting:

- **GPU-enabled nodes**: Schedule orchestrations on nodes with GPU acceleration for model inference
- **Long-running conversations**: Maintain agent state across multiple user interactions
- **Custom resource allocation**: Fine-tune CPU, memory, and GPU requirements per orchestration
- **ML pipeline integration**: Connect to model registries, vector databases, and training infrastructure

**Typical workflow**: User Query → Intent Classification → Context Retrieval → LLM Inference → Response Generation → State Persistence

**Example orchestration**:

```csharp
[Orchestration]
public async Task<AgentResponse> ProcessUserQuery(
    TaskOrchestrationContext context, UserQuery query)
{
    // Classify user intent (lightweight, CPU-only)
    var intent = await context.CallActivityAsync<Intent>(
        "ClassifyIntent", query);
    
    // Retrieve relevant context from vector database
    var relevantContext = await context.CallActivityAsync<Context>(
        "RetrieveContext", intent);
    
    // Call LLM with GPU acceleration (scheduled on GPU node pool)
    var llmResponse = await context.CallActivityAsync<string>(
        "CallLLM", new { intent, context = relevantContext });
    
    // Format and return response
    return await context.CallActivityAsync<AgentResponse>(
        "FormatResponse", llmResponse);
}
```

[View AI agent sample with AKS deployment →](https://github.com/microsoft/durabletask-dotnet/tree/main/samples)

### Distributed microservices saga pattern

**Recommended: Durable Task SDKs on Container Apps or AKS**

Microservices architectures implementing sagas need tight integration with containerized services:

- **Co-location**: Deploy orchestrations alongside microservices in the same cluster
- **Compensation logic**: Implement complex rollback sequences when distributed transactions fail
- **Service mesh integration**: Leverage Istio or Linkerd for observability and resilience
- **Custom tracing**: Integrate with existing OpenTelemetry or Jaeger implementations

**Typical workflow**: Begin Transaction → Service A → Service B → Service C → [Compensate A, B, C on failure]

**Example saga orchestration**:

```csharp
[Orchestration]
public async Task<SagaResult> ExecuteOrderSaga(
    TaskOrchestrationContext context, OrderRequest request)
{
    var completedSteps = new List<string>();
    
    try 
    {
        // Forward phase: execute saga steps
        await context.CallActivityAsync("CreateOrder", request.Order);
        completedSteps.Add("CreateOrder");
        
        await context.CallActivityAsync("ReserveInventory", request.Items);
        completedSteps.Add("ReserveInventory");
        
        await context.CallActivityAsync("ChargePayment", request.Payment);
        completedSteps.Add("ChargePayment");
        
        await context.CallActivityAsync("InitiateShipping", request.Shipping);
        completedSteps.Add("InitiateShipping");
        
        return SagaResult.Success();
    }
    catch (Exception ex)
    {
        // Compensating phase: undo completed steps in reverse order
        foreach (var step in completedSteps.Reverse<string>())
        {
            await context.CallActivityAsync($"Compensate{step}", request);
        }
        
        return SagaResult.Failed(ex.Message);
    }
}
```

[Learn more about saga pattern implementation →](https://learn.microsoft.com/azure/architecture/reference-architectures/saga/saga)

### Scheduled batch processing and data pipelines

**Recommended: Durable Functions**

Batch processing workloads leverage Functions' built-in capabilities:

- **Timer triggers**: Schedule daily, hourly, or custom cron-based processing
- **Fan-out/fan-in**: Process thousands of items in parallel, then aggregate results
- **Cost efficiency**: Run during off-peak hours on Consumption Plan for minimal cost
- **Automatic retry**: Handle transient failures in data sources or downstream systems

**Typical workflow**: Timer Trigger → Fetch Data Source List → Process Each Source (parallel) → Aggregate Results → Write to Destination

**Example batch orchestration**:

```csharp
[Function(nameof(DailyReportOrchestration))]
public async Task<ReportResult> RunOrchestrator(
    [OrchestrationTrigger] TaskOrchestrationContext context)
{
    var dataSources = await context.CallActivityAsync<List<string>>(
        nameof(GetDataSources));
    
    // Fan-out: process all sources in parallel
    var tasks = dataSources.Select(source => 
        context.CallActivityAsync<DataResult>(nameof(ProcessSource), source));
    
    var results = await Task.WhenAll(tasks);
    
    // Fan-in: aggregate all results
    return await context.CallActivityAsync<ReportResult>(
        nameof(AggregateResults), results);
}
```

[View batch processing patterns →](https://learn.microsoft.com/azure/azure-functions/durable/durable-functions-overview#pattern-5-fan-outfan-in)

### IoT device management and edge orchestration

**Recommended: Durable Task SDKs on AKS**

IoT platforms require deep integration with containerized infrastructure:

- **Edge deployment**: Run orchestrations on Azure IoT Edge or on-premises Kubernetes
- **Custom protocol handlers**: Integrate MQTT, AMQP, or proprietary protocols
- **High-volume processing**: Handle thousands of concurrent device orchestrations
- **Hybrid cloud-edge**: Coordinate workflows between cloud and edge locations

**Use case**: Device firmware updates, telemetry aggregation, command orchestration

### Business process automation with human approvals

**Recommended: Durable Functions**

Workflow automation benefits from Functions' integration capabilities:

- **Human-in-the-loop**: Use durable timers and external events for approval workflows
- **Easy integrations**: Connect to Power Platform, SharePoint, Microsoft 365
- **Webhook support**: Expose HTTP-triggered orchestrations for third-party systems
- **Rapid iteration**: Quickly modify business rules without redeploying containers

**Typical workflow**: Request Submitted → Manager Approval (with timeout) → Execute Action → Notify Stakeholders 

The following table shows what client experience is fit for production use. 

| Experience | Dedicated SKU | Consumption SKU |
| ---------- | ------------- | --------------- |
| Durable Functions extension in all languages | Generally available | Preview |
| Durable Task .NET SDK | Generally available | Preview |
| Durable Task Python SDK | Generally available | Preview |
| Durable Task Java SDK | Preview | Preview |

### Durable Functions
 
As a feature of Azure Functions, [Durable Functions](../durable-functions-overview.md) inherits numerous assets, such as:
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

Consider using Durable Functions if you need to build event-driven apps with workflows. The Azure Functions extensions provide integrations with other Azure services, which make building event-driven scenarios easy. For example, with Durable Functions:

- You can easily start an orchestration when a message comes into your Azure Service Bus or a file uploads to Azure Blob Storage. 
- You can easily build an orchestration that runs periodically or in response to an HTTP request with the Azure Functions timer and HTTP trigger, respectively. 

Another reason to consider Durable Functions is if you're already writing Azure Function apps and realized that you need workflow. Since Durable Functions programming model is similar to Function's, you can accelerate your development.

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

The Durable Task SDKs are client SDKs that must be used with the Durable Task Scheduler. The Durable Task SDKs connect the orchestrations you write to the Durable Task Scheduler orchestration engine in Azure. Apps that use the Durable Task SDKs can be run on any compute platform, including:
- Azure Kubernetes Service
- Azure Container Apps
- Azure App Service
- Virtual Machines (VMs) on-premises

The [Durable Task Scheduler](./durable-task-scheduler.md) (Java SDK currently in preview) plays the role of both the orchestration engine and the storage backend for orchestration state persistence. The Durable Task Scheduler:
- Is fully managed by Azure, thus removing management overhead
- Provides high orchestration throughput
- Offers an out-of-the-box dashboard for orchestration monitoring and debugging
- Includes a local emulator

#### When to use Durable Task SDKs

If you don't want to use the Azure Functions programming model, the Durable Task SDKs provide a lightweight and relatively unopinionated programming model for authoring workflows. 

When you need to run apps on Azure Kubernetes Services or VMs on-premises with official Microsoft support, you should consider using the Durable Task SDKs. While Durable Functions can be run on these platforms as well, there's no official support. 

#### Try it out

Walk through one of the following quickstarts to configure your applications to use the Durable Task Scheduler with the Durable Task SDKs.

|   | Quickstart | Description |
| - | ---------- | ----------- |
| **Local development quickstart** | [Create an app with Durable Task SDKs and Durable Task Scheduler](./quickstart-portable-durable-task-sdks.md) using either the .NET, Python, or Java SDKs. | Run a fan-in/fan-out orchestration locally using the Durable Task Scheduler emulator and review orchestration history using the dashboard. |
| **Hosting in Azure Container Apps** | [Deploy a Durable Task SDK app to Azure Container Apps](./quickstart-container-apps-durable-task-sdk.md) | Quickly deploy a "hello world" Durable Task SDK app to Azure Container Apps using the Azure Developer CLI. |


> [!NOTE]
> The Durable Task Framework (DTFx) is an open-source .NET orchestration framework similar to the .NET Durable Task SDK. While it *can* be used to build apps that run on platforms like Azure Kubernetes Services, **DTFx doesn't receive official Microsoft support**.

## Next steps

- [Durable Functions overview](../durable-functions-overview.md)
- [Durable Functions types and features](../durable-functions-types-features-overview.md)
- [Durable Task Scheduler overview](./durable-task-scheduler.md)
- [Configure managed identity for Durable Task Scheduler](./durable-task-scheduler-identity.md)