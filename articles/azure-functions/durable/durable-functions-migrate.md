---
title: Migrate your Durable Functions app from In-Process to Isolated Worker Model
description: Learn how to migrate your Durable Functions application from the in-process model to the isolated worker model.
author: hhunter-ms
ms.author: hannahhunter
ms.reviewer: azfuncdf
ms.date: 12/02/2025
ms.topic: concept-article
ms.service: azure-functions
ms.subservice: durable
---

# Migrate from In-Process to Isolated Worker model

This guide shows you how to migrate your Durable Functions application from the in-process model to the isolated worker model.

> [!WARNING]
> Support for the in-process model ends on **November 10, 2026**. Migrate to the isolated worker model for continued support and access to new features.

## Why migrate?

### In-process model end of support

Microsoft announced that the in-process model for .NET Azure Functions reaches end of support on November 10, 2026. After this date:

- No security updates are provided
- No bug fixes are released
- New features are only available in the isolated worker model

### Benefits of the isolated worker model

Migrating to the isolated worker model provides the following benefits:

| Benefit | Description |
|---------|-------------|
| **No assembly conflicts** | Your code runs in a separate process, eliminating version conflicts |
| **Full process control** | Control startup, configuration, and middleware via `Program.cs` |
| **Standard DI patterns** | Use familiar .NET dependency injection |
| **.NET version flexibility** | Support for LTS, STS, and .NET Framework |
| **Middleware support** | Full ASP.NET Core middleware pipeline |
| **Better performance** | ASP.NET Core integration for HTTP triggers |
| **Platform support** | Access to Flex Consumption plan and .NET Aspire |

## Prerequisites

Before starting the migration, make sure you have the following prerequisites:

- **Azure Functions Core Tools v4.x** or later
- **.NET 8.0 SDK** (or your target .NET version)
- **Visual Studio 2022** or **VS Code with Azure Functions extension**
- Familiarity with [Durable Functions concepts](./durable-functions-orchestrations.md)

## Migration overview

The migration process involves these main steps:

1. [Identify apps to migrate](#identify-apps-to-migrate)
1. [Update the project file](#update-the-project-file)
1. [Add Program.cs](#add-programcs)
1. [Update package references](#update-package-references)
1. [Update function code](#update-function-code)
1. [Update local.settings.json](#update-localsettingsjson)
1. [Test locally](#test-locally)
1. [Deploy to Azure](#deploy-to-azure)

## Identify apps to migrate

Use this Azure PowerShell script to find function apps in your subscription that use the in-process model:

```powershell
$FunctionApps = Get-AzFunctionApp

$AppInfo = @{}

foreach ($App in $FunctionApps)
{
     if ($App.Runtime -eq 'dotnet')
     {
          $AppInfo.Add($App.Name, $App.Runtime)
     }
}

$AppInfo
```

Apps that show `dotnet` as the runtime use the in-process model. Apps that use `dotnet-isolated` already use the isolated worker model.

## Update the project file

### Before (In-Process)

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <AzureFunctionsVersion>v4</AzureFunctionsVersion>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Microsoft.NET.Sdk.Functions" Version="4.1.1" />
    <PackageReference Include="Microsoft.Azure.WebJobs.Extensions.DurableTask" Version="2.13.0" />
  </ItemGroup>
</Project>
```

### After (Isolated Worker)

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <AzureFunctionsVersion>v4</AzureFunctionsVersion>
    <OutputType>Exe</OutputType>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>
  <ItemGroup>
    <FrameworkReference Include="Microsoft.AspNetCore.App" />
    <PackageReference Include="Microsoft.Azure.Functions.Worker" Version="1.21.0" />
    <PackageReference Include="Microsoft.Azure.Functions.Worker.Sdk" Version="1.17.2" />
    <PackageReference Include="Microsoft.Azure.Functions.Worker.Extensions.Http.AspNetCore" Version="1.2.1" />
    <PackageReference Include="Microsoft.Azure.Functions.Worker.Extensions.DurableTask" Version="1.1.0" />
    <PackageReference Include="Microsoft.ApplicationInsights.WorkerService" Version="2.22.0" />
    <PackageReference Include="Microsoft.Azure.Functions.Worker.ApplicationInsights" Version="1.2.0" />
  </ItemGroup>
  <ItemGroup>
    <Using Include="System.Threading.ExecutionContext" Alias="ExecutionContext"/>
  </ItemGroup>
</Project>
```

### Key changes

- Add `<OutputType>Exe</OutputType>` - The isolated worker is an executable
- Add `<FrameworkReference Include="Microsoft.AspNetCore.App" />` - For ASP.NET Core integration
- Replace `Microsoft.NET.Sdk.Functions` with `Microsoft.Azure.Functions.Worker.*` packages
- Replace `Microsoft.Azure.WebJobs.Extensions.DurableTask` with `Microsoft.Azure.Functions.Worker.Extensions.DurableTask`

## Add Program.cs

Create a new `Program.cs` file in your project root:

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var host = new HostBuilder()
    .ConfigureFunctionsWebApplication()
    .ConfigureServices(services => {
        services.AddApplicationInsightsTelemetryWorkerService();
        services.ConfigureFunctionsApplicationInsights();
    })
    .Build();

host.Run();
```

### With custom services

If you had a `FunctionsStartup` class, move that configuration to `Program.cs`:

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var host = new HostBuilder()
    .ConfigureFunctionsWebApplication()
    .ConfigureServices(services => {
        // Application Insights
        services.AddApplicationInsightsTelemetryWorkerService();
        services.ConfigureFunctionsApplicationInsights();
        
        // Your custom services (previously in FunctionsStartup)
        services.AddSingleton<IMyService, MyService>();
        services.AddHttpClient<IApiClient, ApiClient>();
    })
    .Build();

host.Run();
```

### Delete FunctionsStartup

If you have a `Startup.cs` with `[assembly: FunctionsStartup(...)]`, delete it after moving the configuration to `Program.cs`.

## Update package references

### Durable Functions package changes

| In-process package | Isolated worker package |
|--------------------|------------------------|
| `Microsoft.Azure.WebJobs.Extensions.DurableTask` | `Microsoft.Azure.Functions.Worker.Extensions.DurableTask` |
| `Microsoft.DurableTask.SqlServer.AzureFunctions` | `Microsoft.Azure.Functions.Worker.Extensions.DurableTask.SqlServer` |
| `Microsoft.Azure.DurableTask.Netherite.AzureFunctions` | `Microsoft.Azure.Functions.Worker.Extensions.DurableTask.Netherite` |

### Common extension package changes

| In-process | Isolated worker |
|------------|-----------------|
| `Microsoft.Azure.WebJobs.Extensions.Storage` | `Microsoft.Azure.Functions.Worker.Extensions.Storage.Blobs`, `.Queues`, `.Tables` |
| `Microsoft.Azure.WebJobs.Extensions.CosmosDB` | `Microsoft.Azure.Functions.Worker.Extensions.CosmosDB` |
| `Microsoft.Azure.WebJobs.Extensions.ServiceBus` | `Microsoft.Azure.Functions.Worker.Extensions.ServiceBus` |
| `Microsoft.Azure.WebJobs.Extensions.EventHubs` | `Microsoft.Azure.Functions.Worker.Extensions.EventHubs` |
| `Microsoft.Azure.WebJobs.Extensions.EventGrid` | `Microsoft.Azure.Functions.Worker.Extensions.EventGrid` |

> [!IMPORTANT]
> Remove any references to `Microsoft.Azure.WebJobs.*` namespaces and `Microsoft.Azure.Functions.Extensions` from your project.

## Update function code

### Namespace changes

```csharp
// Before (In-Process)
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.DurableTask;
using Microsoft.Azure.WebJobs.Extensions.Http;

// After (Isolated Worker)
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.DurableTask;
using Microsoft.DurableTask.Client;
```

### Function attribute changes

```csharp
// Before (In-Process)
[FunctionName("MyOrchestrator")]

// After (Isolated Worker)
[Function(nameof(MyOrchestrator))]
```

### Orchestrator function changes

**Before (In-Process):**

```csharp
[FunctionName("OrderOrchestrator")]
public static async Task<OrderResult> RunOrchestrator(
    [OrchestrationTrigger] IDurableOrchestrationContext context,
    ILogger log)
{
    var order = context.GetInput<Order>();
    
    await context.CallActivityAsync("ValidateOrder", order);
    await context.CallActivityAsync("ProcessPayment", order.Payment);
    await context.CallActivityAsync("ShipOrder", order);
    
    return new OrderResult { Success = true };
}
```

**After (Isolated Worker):**

```csharp
[Function(nameof(OrderOrchestrator))]
public static async Task<OrderResult> OrderOrchestrator(
    [OrchestrationTrigger] TaskOrchestrationContext context)
{
    ILogger logger = context.CreateReplaySafeLogger(nameof(OrderOrchestrator));
    var order = context.GetInput<Order>();
    
    await context.CallActivityAsync("ValidateOrder", order);
    await context.CallActivityAsync("ProcessPayment", order.Payment);
    await context.CallActivityAsync("ShipOrder", order);
    
    return new OrderResult { Success = true };
}
```

### Key differences

| Aspect | In-Process | Isolated Worker |
|--------|------------|-----------------|
| Context type | `IDurableOrchestrationContext` | `TaskOrchestrationContext` |
| Logger | `ILogger` parameter | `context.CreateReplaySafeLogger()` |
| Attribute | `[FunctionName]` | `[Function]` |

### Activity function changes

**Before (In-Process):**

```csharp
[FunctionName("ValidateOrder")]
public static bool ValidateOrder(
    [ActivityTrigger] Order order,
    ILogger log)
{
    log.LogInformation("Validating order {OrderId}", order.Id);
    return order.Items.Any() && order.TotalAmount > 0;
}
```

**After (Isolated Worker):**

```csharp
[Function(nameof(ValidateOrder))]
public static bool ValidateOrder(
    [ActivityTrigger] Order order,
    FunctionContext executionContext)
{
    ILogger logger = executionContext.GetLogger(nameof(ValidateOrder));
    logger.LogInformation("Validating order {OrderId}", order.Id);
    return order.Items.Any() && order.TotalAmount > 0;
}
```

### Client function changes

**Before (In-Process):**

```csharp
[FunctionName("StartOrder")]
public static async Task<IActionResult> StartOrder(
    [HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequest req,
    [DurableClient] IDurableOrchestrationClient client,
    ILogger log)
{
    var order = await req.ReadFromJsonAsync<Order>();
    string instanceId = await client.StartNewAsync("OrderOrchestrator", order);
    
    return client.CreateCheckStatusResponse(req, instanceId);
}
```

**After (Isolated Worker):**

```csharp
[Function("StartOrder")]
public static async Task<HttpResponseData> StartOrder(
    [HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequestData req,
    [DurableClient] DurableTaskClient client,
    FunctionContext executionContext)
{
    ILogger logger = executionContext.GetLogger("StartOrder");
    var order = await req.ReadFromJsonAsync<Order>();
    string instanceId = await client.ScheduleNewOrchestrationInstanceAsync(
        nameof(OrderOrchestrator), 
        order
    );
    
    return await client.CreateCheckStatusResponseAsync(req, instanceId);
}
```

### Client type changes

| In-process | Isolated worker |
|------------|-----------------|
| `IDurableOrchestrationClient` | `DurableTaskClient` |
| `StartNewAsync()` | `ScheduleNewOrchestrationInstanceAsync()` |
| `CreateCheckStatusResponse()` | `CreateCheckStatusResponseAsync()` |
| `HttpRequest` / `IActionResult` | `HttpRequestData` / `HttpResponseData` |

### Entity function changes

**Before (In-Process):**

```csharp
[FunctionName(nameof(Counter))]
public static void Counter([EntityTrigger] IDurableEntityContext ctx)
{
    switch (ctx.OperationName.ToLowerInvariant())
    {
        case "add":
            ctx.SetState(ctx.GetState<int>() + ctx.GetInput<int>());
            break;
        case "get":
            ctx.Return(ctx.GetState<int>());
            break;
    }
}
```

**After (Isolated Worker):**

```csharp
[Function(nameof(Counter))]
public static Task Counter([EntityTrigger] TaskEntityDispatcher dispatcher)
{
    return dispatcher.DispatchAsync<CounterEntity>();
}

public class CounterEntity
{
    public int Value { get; set; }
    
    public void Add(int amount) => Value += amount;
    public int Get() => Value;
}
```

## Update local.settings.json

```json
{
    "IsEncrypted": false,
    "Values": {
        "AzureWebJobsStorage": "UseDevelopmentStorage=true",
        "FUNCTIONS_WORKER_RUNTIME": "dotnet-isolated",
        "DURABLE_TASK_SCHEDULER_CONNECTION_STRING": "Endpoint=http://localhost:8080;Authentication=None"
    }
}
```

The key change is `FUNCTIONS_WORKER_RUNTIME` from `dotnet` to `dotnet-isolated`.

## Test locally

### Start the emulator

```bash
docker run -d -p 8080:8080 -p 8082:8082 mcr.microsoft.com/dts/dts-emulator:latest
```

### Run the function app

```bash
func start
```

### Verify functionality

Test all your orchestrations, activities, and entities to make sure they work correctly:

1. Start an orchestration with an HTTP trigger
1. Monitor the orchestration status
1. Verify the activity execution order
1. Test entity operations if applicable
1. Check Application Insights telemetry

## Deploy to Azure

### Recommended: Use deployment slots

Use deployment slots to minimize downtime:

1. **Create a staging slot** for your function app.
1. **Update staging slot configuration:**
   - Set `FUNCTIONS_WORKER_RUNTIME` to `dotnet-isolated`.
   - Update .NET stack version if needed.
1. **Deploy migrated code** to the staging slot.
1. **Test thoroughly** in the staging slot.
1. **Perform slot swap** to move changes to production.

### Update application settings

In the Azure portal or via CLI:

```bash
az functionapp config appsettings set \
    --name <FUNCTION_APP_NAME> \
    --resource-group <RESOURCE_GROUP> \
    --settings FUNCTIONS_WORKER_RUNTIME=dotnet-isolated
```

### Update stack configuration

If targeting a different .NET version:

```bash
az functionapp config set \
    --name <FUNCTION_APP_NAME> \
    --resource-group <RESOURCE_GROUP> \
    --net-framework-version v8.0
```

## Common migration issues

### Issue: Assembly load errors

**Symptom:** `Could not load file or assembly` errors.

**Solution:** Ensure you remove all `Microsoft.Azure.WebJobs.*` package references and replace them with isolated worker equivalents.

### Issue: Binding attribute not found

**Symptom:** `The type or namespace 'QueueTrigger' could not be found`

**Solution:** Add the appropriate extension package and update using statements:

```csharp
// Add using statement
using Microsoft.Azure.Functions.Worker;

// Install package
// dotnet add package Microsoft.Azure.Functions.Worker.Extensions.Storage.Queues
```

### Issue: IDurableOrchestrationContext not found

**Symptom:** `The type or namespace 'IDurableOrchestrationContext' could not be found`

**Solution:** Replace with `TaskOrchestrationContext`:

```csharp
using Microsoft.DurableTask;

[Function(nameof(MyOrchestrator))]
public static async Task MyOrchestrator([OrchestrationTrigger] TaskOrchestrationContext context)
{
    // ...
}
```

### Issue: JSON serialization differences

**Symptom:** Serialization errors or unexpected data formats

**Solution:** The isolated model uses `System.Text.Json` by default. Configure serialization in `Program.cs`:

```csharp
var host = new HostBuilder()
    .ConfigureFunctionsWebApplication()
    .ConfigureServices(services => {
        services.Configure<JsonSerializerOptions>(options => {
            options.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
        });
    })
    .Build();
```

To use Newtonsoft.Json instead:

```csharp
services.Configure<WorkerOptions>(options => {
    options.Serializer = new NewtonsoftJsonObjectSerializer();
});
```

## Checklist

Use this checklist to ensure a complete migration:

- Updated project file with `<OutputType>Exe</OutputType>`
- Replaced `Microsoft.NET.Sdk.Functions` with worker packages
- Replaced `Microsoft.Azure.WebJobs.Extensions.DurableTask` with isolated package
- Created `Program.cs` with host configuration
- Removed `FunctionsStartup` class (if present)
- Updated all `[FunctionName]` to `[Function]`
- Replaced `IDurableOrchestrationContext` with `TaskOrchestrationContext`
- Replaced `IDurableOrchestrationClient` with `DurableTaskClient`
- Updated logging to use DI or `FunctionContext`
- Updated `local.settings.json` with `dotnet-isolated` runtime
- Removed all `Microsoft.Azure.WebJobs.*` using statements
- Added `Microsoft.Azure.Functions.Worker` using statements
- Tested all functions locally
- Deployed to staging slot and verified
- Swapped to production

## Next steps

- [Learn about the Isolated Worker Model →](../dotnet-isolated-process-guide.md)
- [Explore Durable Functions Patterns →](./durable-functions-sequence.md#application-patterns)
- [Configure Durable Task Scheduler →](./durable-task-scheduler/develop-with-durable-task-scheduler.md)
- [View Code Samples →](/samples/browse/?term=durable%20functions)

## Additional resources

- [Official Microsoft Migration Guide](../migrate-dotnet-to-isolated-model.md)
- [Isolated Worker Model Differences](../dotnet-isolated-in-process-differences.md)
- [Durable Functions for .NET Isolated](./durable-functions-dotnet-isolated-overview.md)