---
title: How to run Durable Functions as WebJobs - Azure
description: Learn how to code and configure Durable Functions to run in WebJobs by using the WebJobs SDK.
ms.topic: how-to
ms.date: 02/03/2026
ms.author: azfuncdf
ms.devlang: csharp
#Customer intent: As a developer, I want to understand how to use the WebJobs SDK to create, publish, and manage Durable Functions as part of my Web Apps in Azure App Service, not as standalone Azure Functions.
---

# How to run Durable Functions as WebJobs

> [!IMPORTANT]
> The WebJobs SDK approach described in this article is considered legacy. For new projects that require portable, framework-agnostic durable orchestrations, we recommend using the [Durable Task SDKs](durable-task-scheduler/durable-task-overview.md) instead. The Durable Task SDKs provide a modern, cross-platform solution for building durable workflows.

By default, Durable Functions uses the Azure Functions runtime to host orchestrations. However, there might be certain scenarios where you need more control over the code that listens for events, or you have an existing WebJobs-based application. In this guide, you implement your orchestration using the WebJobs SDK. For a more detailed comparison between Functions and WebJobs, see [Compare Functions and WebJobs](../functions-compare-logic-apps-ms-flow-webjobs.md#compare-functions-and-webjobs).

[Azure Functions](../functions-overview.md) and the [Durable Functions](durable-functions-overview.md) extension are built on the [WebJobs SDK](../../app-service/webjobs-sdk-how-to.md). The job host in the WebJobs SDK is the runtime that underlies Azure Functions. If you need to control behavior in ways not possible in Azure Functions, you can develop and run Durable Functions by using the WebJobs SDK directly.

In version 3.x of the WebJobs SDK, the host is an implementation of `IHost`, and in version 2.x you use the `JobHost` object.

The chaining Durable Functions sample is available in a WebJobs SDK 2.x version: download or clone the [Durable Functions repository](https://github.com/azure/azure-functions-durable-extension/), and checkout *v1* branch and go to the *samples\\webjobssdk\\chaining* folder.

## Prerequisites

Before you begin, you should be familiar with the basics of the WebJobs SDK, C# class library development for Azure Functions, and Durable Functions. If you need an introduction to these concepts, see the following resources:

- [Get started with the WebJobs SDK](../../app-service/webjobs-sdk-get-started.md)
- [Create your first function using Visual Studio](../functions-create-your-first-function-visual-studio.md)
- [Durable Functions](durable-functions-sequence.md)

To complete this guide:

- [Install Visual Studio 2022](/visualstudio/install/install-visual-studio) with the **Azure development** workload.

  If you already have Visual Studio, but don't have that workload, add the workload by selecting **Tools** > **Get Tools and Features**.

  (You can use [Visual Studio Code](https://code.visualstudio.com/) instead, but some of the instructions are specific to Visual Studio.)

- Install and run the [Azurite storage emulator](../../storage/common/storage-use-azurite.md). An alternative is to update the *App.config* file with a real Azure Storage connection string.

## WebJobs SDK versions

This guide primarily covers WebJobs SDK 2.x (equivalent to Azure Functions version 1.x), which uses .NET Framework. For modern .NET Core development with WebJobs SDK 3.x, see [WebJobs SDK 3.x](#webjobs-sdk-3x). For new projects, consider using WebJobs SDK 3.x or the [Durable Task SDKs](durable-task-scheduler/durable-task-overview.md).

## Create a console app

To run Durable Functions as WebJobs, you must first create a console app. A WebJobs SDK project is just a console app project with the appropriate NuGet packages installed.

In the Visual Studio **New Project** dialog box, select **Windows Classic Desktop** > **Console App (.NET Framework)**. In the project file, the `TargetFrameworkVersion` should be `v4.6.1`.

Visual Studio also has a WebJob project template, which you can use by selecting **Cloud** > **Azure WebJob (.NET Framework)**. This template installs many packages, some of which you might not need.

## Install NuGet packages

You need NuGet packages for the WebJobs SDK, core bindings, the logging framework, and the Durable Task extension. Here are **Package Manager Console** commands for those packages, with the latest stable version numbers at the time of writing:

```powershell
Install-Package Microsoft.Azure.WebJobs.Extensions -version 2.2.0
Install-Package Microsoft.Extensions.Logging -version 2.0.1
Install-Package Microsoft.Azure.WebJobs.Extensions.DurableTask -version 1.8.7
```

You also need logging providers. The following commands install the Azure Application Insights provider and the `ConfigurationManager`. The `ConfigurationManager` lets you get the Application Insights instrumentation key from app settings.

```powershell
Install-Package Microsoft.Azure.WebJobs.Logging.ApplicationInsights -version 2.2.0
Install-Package System.Configuration.ConfigurationManager -version 4.4.1
```

The following command installs the console provider:

```powershell
Install-Package Microsoft.Extensions.Logging.Console -version 2.0.1
```

## JobHost code

Having created the console app and installed the NuGet packages you need, you're ready to use Durable Functions. You do so by using JobHost code.

To use the Durable Functions extension, call `UseDurableTask` on the `JobHostConfiguration` object in your `Main` method:

```cs
var config = new JobHostConfiguration();
config.UseDurableTask(new DurableTaskExtension
{
    HubName = "MyTaskHub",
};
```

For a list of properties that you can set in the `DurableTaskExtension` object, see [host.json](../functions-host-json.md#durabletask).

The `Main` method is also the place to set up logging providers. The following example configures the console and Application Insights providers.

```cs
static void Main(string[] args)
{
    using (var loggerFactory = new LoggerFactory())
    {
        var config = new JobHostConfiguration();

        config.DashboardConnectionString = "";

        var instrumentationKey =
            ConfigurationManager.AppSettings["APPINSIGHTS_INSTRUMENTATIONKEY"];

        config.LoggerFactory = loggerFactory
            .AddApplicationInsights(instrumentationKey, null)
            .AddConsole();

        config.UseTimers();
        config.UseDurableTask(new DurableTaskExtension
        {
            HubName = "MyTaskHub",
        });
        var host = new JobHost(config);
        host.RunAndBlock();
    }
}
```

## Functions

Durable Functions in the context of WebJobs differs somewhat from Durable Functions in the context of Azure Functions. Be aware of these differences as you write your code.

The WebJobs SDK doesn't support the following Azure Functions features:

- [FunctionName attribute](#functionname-attribute)
- [HTTP trigger](#http-trigger)
- [Durable Functions HTTP management API](#http-management-api)

### FunctionName attribute

In a WebJobs SDK project, the method name of a function is the function name. The `FunctionName` attribute is used only in Azure Functions.

### HTTP trigger

The WebJobs SDK doesn't have an HTTP trigger. The sample project's orchestration client uses a timer trigger:

```cs
public static async Task CronJob(
    [TimerTrigger("0 */2 * * * *")] TimerInfo timer,
    [OrchestrationClient] DurableOrchestrationClient client,
    ILogger logger)
{
  ...
}
```

### HTTP management API

Because it doesn't have an HTTP trigger, the WebJobs SDK has no [HTTP management API](durable-functions-http-api.md).

In a WebJobs SDK project, you can call methods on the orchestration client object, instead of by sending HTTP requests. The following methods correspond to the three tasks you can do with the HTTP management API:

- `GetStatusAsync`
- `RaiseEventAsync`
- `TerminateAsync`

The orchestration client function in the sample project starts the orchestrator function, and then goes into a loop that calls `GetStatusAsync` every 2 seconds:

```cs
string instanceId = await client.StartNewAsync(nameof(HelloSequence), input: null);
logger.LogInformation($"Started new instance with ID = {instanceId}.");

DurableOrchestrationStatus status;
while (true)
{
    status = await client.GetStatusAsync(instanceId);
    logger.LogInformation($"Status: {status.RuntimeStatus}, Last update: {status.LastUpdatedTime}.");

    if (status.RuntimeStatus == OrchestrationRuntimeStatus.Completed ||
        status.RuntimeStatus == OrchestrationRuntimeStatus.Failed ||
        status.RuntimeStatus == OrchestrationRuntimeStatus.Terminated)
    {
        break;
    }

    await Task.Delay(TimeSpan.FromSeconds(2));
}
```

## Run the sample

You've got Durable Functions set up to run as a WebJob, and you now have an understanding of how running it differs from running Durable Functions as standalone Azure Functions. At this point, seeing it work in a sample might be helpful.

Here's an overview of how to run the [sample project](https://github.com/Azure/azure-functions-durable-extension/tree/v1/samples/webjobssdk/chaining). For detailed instructions on running a WebJobs SDK project locally and deploying it to an Azure WebJob, see [Get started with the WebJobs SDK](../../app-service/webjobs-sdk-get-started.md#deploy-as-a-webjob).

### Run locally

1. Make sure the Storage emulator is running (see [Prerequisites](#prerequisites)).

1. If you want to see logs in Application Insights when you run the project locally:

    a. Create an Application Insights resource, and use the **General** app type for it.

    b. Save the instrumentation key in the *App.config* file.

1. Run the project.

### Run in Azure

1. Create a web app and a storage account.

1. In the web app, save the storage connection information in an app setting named `AzureWebJobsStorage`. For improved security, consider using an [identity-based connection](../../app-service/webjobs-sdk-how-to.md#identity-based-connections) with managed identities instead of connection strings.

1. Create an Application Insights resource, and use the **General** app type for it.

1. Save the instrumentation key in an app setting named `APPINSIGHTS_INSTRUMENTATIONKEY`.

1. Deploy as a WebJob.

## WebJobs SDK 3.x

WebJobs SDK 3.x is the modern version that uses .NET Core instead of .NET Framework. If you're starting a new project or migrating from 2.x, use this version. To create a WebJobs SDK 3.x project, follow the same general approach with these differences:

1. Create a .NET Core console app. In the Visual Studio **New Project** dialog box, select **.NET Core** > **Console App (.NET Core)**. The project file specifies that `TargetFramework` is `netcoreapp2.x` or later.

1. Choose the release version WebJobs SDK 3.x of the following packages:

    - `Microsoft.Azure.WebJobs.Extensions`
    - `Microsoft.Azure.WebJobs.Extensions.Storage`
    - `Microsoft.Azure.WebJobs.Logging.ApplicationInsights`
    - `Microsoft.Azure.WebJobs.Host.Storage` (required for identity-based connections)

1. Set the storage connection and the Application Insights instrumentation key in an *appsettings.json* file using the .NET Core configuration framework:

    ```json
    {
        "AzureWebJobsStorage": "<replace with storage connection string>",
        "APPINSIGHTS_INSTRUMENTATIONKEY": "<replace with Application Insights instrumentation key>"
    }
    ```

    > [!TIP]
    > For improved security, use identity-based connections instead of connection strings. With identity-based connections, you configure individual service URIs:
    >
    > ```json
    > {
    >     "AzureWebJobsStorage__blobServiceUri": "https://<storage_account>.blob.core.windows.net",
    >     "AzureWebJobsStorage__queueServiceUri": "https://<storage_account>.queue.core.windows.net"
    > }
    > ```
    >
    > For more information, see [Identity-based connections](../../app-service/webjobs-sdk-how-to.md#identity-based-connections) in the WebJobs SDK documentation.

1. Change the `Main` method code. The `AddAzureStorageCoreServices()` call enables identity-based connections:

   ```cs
   static void Main(string[] args)
   {
        var hostBuilder = new HostBuilder()
            .ConfigureWebJobs(config =>
            {
                config.AddAzureStorageCoreServices();
                config.AddAzureStorage();
                config.AddTimers();
                config.AddDurableTask(options =>
                {
                    options.HubName = "MyTaskHub";
                    options.AzureStorageConnectionStringName = "AzureWebJobsStorage";
                });
            })
            .ConfigureLogging((context, logging) =>
            {
                logging.AddConsole();
                logging.AddApplicationInsights(config =>
                {
                    config.InstrumentationKey = context.Configuration["APPINSIGHTS_INSTRUMENTATIONKEY"];
                });
            })
            .UseConsoleLifetime();

        var host = hostBuilder.Build();

        using (host)
        {
            host.Run();
        }
   }
   ```

## Next steps

- [Durable Task SDKs overview](durable-task-scheduler/durable-task-overview.md) - Learn about the modern, portable approach to durable orchestrations
- [How to use the WebJobs SDK](../../app-service/webjobs-sdk-how-to.md) - Comprehensive WebJobs SDK documentation
