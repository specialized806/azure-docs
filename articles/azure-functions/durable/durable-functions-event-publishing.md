---
title: Durable Functions publishing to Azure Event Grid
description: Learn how to configure automatic Azure Event Grid publishing for Durable Functions.
ms.topic: how-to
ms.date: 01/22/2026
ms.devlang: csharp
# ms.devlang: csharp, javascript
ms.custom: devx-track-azurecli
---

# Durable Functions publishing to Azure Event Grid

Learn how to automatically publish orchestration lifecycle events (such as created, completed, and failed) to a custom [Azure Event Grid topic](../../event-grid/overview.md). This feature is useful for DevOps scenarios (blue/green deployments), advanced monitoring, and tracking long-running background activities.

## Prerequisites

- Install [Microsoft.Azure.WebJobs.Extensions.DurableTask](https://www.nuget.org/packages/Microsoft.Azure.WebJobs.Extensions.DurableTask) in your Durable Functions project.
- Install the [Azurite storage emulator](../../storage/common/storage-use-azurite.md) or use an existing Azure Storage account.
- Install [Azure CLI](/cli/azure/) or use [Azure Cloud Shell](../../cloud-shell/overview.md).

## Create a custom Event Grid topic

Create an Event Grid topic for sending events from Durable Functions by using Azure CLI. You can also create the topic [using PowerShell](../../event-grid/custom-event-quickstart-powershell.md) or [the Azure portal](../../event-grid/custom-event-quickstart-portal.md).

### Create a resource group

Create a resource group with the `az group create` command. Currently, Azure Event Grid doesn't support all regions. For information about which regions are supported, see the [Azure Event Grid overview](../../event-grid/overview.md).

```azurecli
az group create --name eventResourceGroup --location westus2
```
[!INCLUDE [register-provider-cli.md](../../event-grid/includes/register-provider-cli.md)]

### Create a custom topic

An Event Grid topic provides a user-defined endpoint that you post your event to. Replace `<topic_name>` in the following command with a unique name for your topic. The topic name must be unique because it becomes a DNS entry.

```azurecli
az eventgrid topic create --name <topic_name> --location westus2 --resource-group eventResourceGroup
```

## Get the endpoint and key

1. Get the endpoint of the topic. Replace `<topic_name>` in the following commands with the name you chose.

   ```azurecli
   az eventgrid topic show --name <topic_name> --resource-group eventResourceGroup --query "endpoint" --output tsv
   ```

1. Get the topic key if you're using key based authentication. Replace `<topic_name>` with the name you chose.

   ```azurecli
   az eventgrid topic key list --name <topic_name> --resource-group eventResourceGroup --query "key1" --output tsv
   ```

Now you can send events to the topic.

## Configure Event Grid publishing with Managed Identity (recommended)

Managed identities in Azure allow resources to authenticate to Azure services without storing credentials, simplifying security and identity management. 
- [**User-assigned managed identity (recommended):**](#user-assigned-identity-recommended) Created as a standalone Azure resource and can be assigned to multiple resources. It persists independently of any resource, offering flexibility for shared access and centralized identity management. 
- [**System-assigned managed identity:**](#system-assigned-identity) Automatically created when you enable it on an Azure resource and tied to that resource’s lifecycle. If you delete the resource, you also delete the identity. 

For more information, see [Use managed identities for App Service and Azure Functions](../../app-service/overview-managed-identity.md).

### User-assigned identity (recommended)

To configure user-assigned managed identity:

#### Configuration

1. Create a user-assigned managed identity.

    1. In the Azure portal, search for **Managed Identities** in the global search bar. 

    1. Create a user-assigned managed identity and select **Review + create**.
  
      :::image type="content" source="./media/durable-functions-event-publishing/create-user-assigned-managed-identity.png" alt-text="Screenshot of creating user assigned managed identity." border="true":::

1. Attach the user-assigned managed identity to the function app resource.

    1. In your function app, navigate to **Identity** > **User assigned** section. 
    1. Select **Add +**.
  
       :::image type="content" source="./media/durable-functions-event-publishing/function-app-add-user-assigned-managed-identity.png" alt-text="Screenshot of the function app identity section for user assigned managed identity." border="true":::

    1. Choose the user-assigned managed identity created earlier. Select **Add**.

       :::image type="content" source="./media/durable-functions-event-publishing/function-app-add-specific-user-assigned-managed-identity.png" alt-text="Screenshot of selecting specific user assigned managed identity." border="true":::

1. Attach the user-assigned managed identity to the event grid topic resource.
    1. Go to the **Identity** section of the Event Grid topic resource.
    1. Choose the **User assigned** tab. Select **Add +**. 
    1. Choose the user assigned managed identity. Select **Add**.

      :::image type="content" source="./media/durable-functions-event-publishing/add-user-assigned-managed-identity-to-event-grid-topic.png" alt-text="Screenshot of adding a user assigned managed identity to event grid topic." border="true":::

1. Create an Event Grid subscription and select an endpoint.
    1. In the **Overview** tab of the Event Grid Topic resource, select **+ Event Subscription**.
    1. Create the event subscription.
  
      :::image type="content" source="./media/durable-functions-event-publishing/event-subscription.png" alt-text="Screenshot of the + Event Subscription button." border="true":::

    Based on the endpoint you choose in **Endpoint Details**, you see a **Managed Identity for Delivery** section. 
    
    1. Choose **User Assigned** for the **Managed Identity** type.
    1. Select the user-assigned managed identity.
  
      :::image type="content" source="./media/durable-functions-event-publishing/event-subscription-managed-identity.png" alt-text="Screenshot of adding a user assigned managed identity to event grid subscription." border="true":::

1. In the Event Grid topic resource, assign the **EventGrid Data Sender** role to the user-assigned managed identity.

    1. Go to the **Access Control (IAM)** section. Select **+ Add**.

      :::image type="content" source="./media/durable-functions-event-publishing/add-role.png" alt-text="Screenshot of adding a role to an event grid topic resource." border="true":::

    1. Select the **EventGrid Data Sender** role. Select **Next**.

      :::image type="content" source="./media/durable-functions-event-publishing/event-grid-data-sender.png" alt-text="Screenshot of selecting the EventGrid Data Sender Role." border="true":::

    1. In the **Assign access to** section, choose **Managed Identity**.
    1. Select **+ Select Members** in the **Members** section.
    1. Select the user-assigned managed identity.
    1. Select **Review + Assign**.

      :::image type="content" source="./media/durable-functions-event-publishing/select-managed-identity.png" alt-text="Screenshot of selecting a managed identity." border="true":::

#### App Settings

Add the following app settings:
- `EventGrid__topicEndpoint` with the value as the Event Grid topic endpoint.
- `EventGrid__credential` with the value `managedidentity`.
- `EventGrid__clientId` with the value of the user assigned managed identity client ID.

```azurecli
az functionapp config appsettings set --name <function app name> --resource-group <resource group name> --settings EventGrid__topicEndpoint="<topic endpoint>" EventGrid__credential="managedidentity" EventGrid__clientId="<client id>"
```

### System-assigned identity

1. Turn on system-assigned identity for the function app. 
    1. Navigate to the function app's **Identity** > **System Assigned** tab.
    1. Toggle the **Status** switch to **on**.

      :::image type="content" source="./media/durable-functions-event-publishing/enable-system-assigned-identity.png" alt-text="Screenshot of enabling system assigned identity in the function app." border="true":::

1. In the Event Grid topic resource, give the function app the EventGrid Data Sender role.
    1. Go to **Access Control (IAM)** in the left side menu. 
    1. Select **+ Add**.

      :::image type="content" source="./media/durable-functions-event-publishing/add-role.png" alt-text="Screenshot of adding a role to event grid topic resource." border="true":::

    1. Select the **EventGrid Data Sender** role, then select **Next**.

      :::image type="content" source="./media/durable-functions-event-publishing/event-grid-data-sender.png" alt-text="Screenshot of selecting the EventGrid Data Sender Role." border="true":::

    1. Under the **Assign access to** section, choose **Managed Identity**.
    1. Select **+ Select Members** in the **Members** section.
    1. Select the managed identity you wish to assign.
    1. Select **Review + Assign**.

      :::image type="content" source="./media/durable-functions-event-publishing/select-managed-identity.png" alt-text="Screenshot of selecting a managed identity." border="true":::

#### App settings

Add an `EventGrid__topicEndpoint` app setting with the value as the Event Grid topic endpoint.

```azurecli
az functionapp config appsettings set --name <function app name> --resource-group <resource group name> --settings EventGrid__topicEndpoint="<topic endpoint>"
```

## Configure Event Grid publishing with key-based authentication

Configure publishing to your Event Grid topic in several locations of your Durable Functions project.

### `host.json`

You can find the possible Azure Event Grid configuration properties in the [`host.json` documentation](../functions-host-json.md#durabletask). After you configure the `host.json` file, your function app sends lifecycle events to the Event Grid topic both locally and in Azure.

In your Durable Functions project, find the `host.json` file.

**Durable Functions 1.x**

Add `eventGridTopicEndpoint` and `eventGridKeySettingName` in a `durableTask` property.

```json
{
  "durableTask": {
    "eventGridTopicEndpoint": "https://<topic_name>.westus2-1.eventgrid.azure.net/api/events",
    "eventGridKeySettingName": "EventGridKey"
  }
}
```

**Durable Functions 2.x**

Add a `notifications` section to the `durableTask` property of the file, replacing `<topic_name>` with the name you chose. If the `durableTask` or `extensions` properties don't exist, create them like this example:

```json
{
  "version": "2.0",
  "extensions": {
    "durableTask": {
      "notifications": {
        "eventGrid": {
          "topicEndpoint": "https://<topic_name>.westus2-1.eventgrid.azure.net/api/events",
          "keySettingName": "EventGridKey"
        }
      }
    }
  }
}
```

### `local.settings.json`

Set the app setting for the topic key in the Function App and `local.settings.json`. The following JSON is a sample of the `local.settings.json` for local debugging using an Azure Storage emulator. Replace `<topic_key>` with the topic key.  

```json
{
    "IsEncrypted": false,
    "Values": {
        "AzureWebJobsStorage": "UseDevelopmentStorage=true",
        "EventGridKey": "<topic_key>"
    }
}
```

If you use the [Storage Emulator](../../storage/common/storage-use-emulator.md) instead of a real Azure Storage account, make sure it's running. It's a good idea to clear any existing storage data before executing.

If you use a real Azure Storage account, replace `UseDevelopmentStorage=true` in `local.settings.json` with its connection string.

## Create functions that listen for events

Using the Azure portal, create another function app to listen for events published by your Durable Functions app. Locate the new function app in the same region as the Event Grid topic.

### Create an Event Grid trigger function

1. In your function app, select **Functions**, and then select **+ Add**. 

   :::image type="content" source="./media/durable-functions-event-publishing/function-add-function.png" alt-text="Add a function in the Azure portal." border="true":::

1. Search for **Event Grid**, and then select the **Azure Event Grid trigger** template. 

    :::image type="content" source="./media/durable-functions-event-publishing/function-select-event-grid-trigger.png" alt-text="Select the Event Grid trigger template in the Azure portal." border="true":::

1. Name the new trigger, and then select **Create Function**.

    :::image type="content" source="./media/durable-functions-event-publishing/function-name-event-grid-trigger.png" alt-text="Name the Event Grid trigger in the Azure portal." border="true":::


    The portal creates a function with the following code:

    # [C# (.NET isolated)](#tab/csharp-isolated)

    ```csharp
    using Azure.Messaging.EventGrid;
    using Microsoft.Azure.Functions.Worker;
    using Microsoft.Extensions.Logging;

    public class EventGridTrigger
    {
        private readonly ILogger _logger;

        public EventGridTrigger(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<EventGridTrigger>();
        }

        [Function("EventGridTrigger")]
        public void Run(
            [EventGridTrigger] EventGridEvent eventGridEvent)
        {
            _logger.LogInformation("Event Grid trigger function processed an event.");
            _logger.LogInformation($"Event type: {eventGridEvent.EventType}");
            _logger.LogInformation($"Event subject: {eventGridEvent.Subject}");
            _logger.LogInformation($"Event data: {eventGridEvent.Data}");
        }
    }
    ```

    # [C# (.NET in-process)](#tab/csharp-script)

    ```csharp
    #r "Newtonsoft.Json"
    using Newtonsoft.Json;
    using Newtonsoft.Json.Linq;
    using Microsoft.Extensions.Logging;

    public static void Run(JObject eventGridEvent, ILogger log)
    {
        log.LogInformation(eventGridEvent.ToString(Formatting.Indented));
    }
    ```

    # [JavaScript](#tab/javascript)

    ```javascript
    module.exports = async function(context, eventGridEvent) {
        context.log(typeof eventGridEvent);
        context.log(eventGridEvent);
    }
    ```

    # [Python](#tab/python)

    ```python
    import json
    import logging
    import azure.functions as func

    def main(event: func.EventGridEvent) -> None:
        logging.info('Event Grid trigger function processed an event.')
        logging.info(f'Event type: {event.event_type}')
        logging.info(f'Event subject: {event.subject}')
        logging.info(f'Event data: {json.dumps(event.get_json())}')
    ```

    # [Java](#tab/java)

    ```java
    import com.microsoft.azure.functions.*;
    import com.google.gson.Gson;
    import java.util.logging.Logger;

    public class EventGridTrigger {
        public static void run(
                @EventGridTrigger(name = "eventGridEvent") String eventGridEvent,
                final ExecutionContext context) {
            
            Logger logger = context.getLogger();
            logger.info("Event Grid trigger function processed an event.");
            logger.info("Event details: " + eventGridEvent);
        }
    }
    ```

    # [PowerShell](#tab/powershell)

    ```powershell
    param($eventGridEvent, $TriggerMetadata)

    Write-Host "Event Grid trigger function processed an event."
    Write-Host "Event type: $($eventGridEvent.eventType)"
    Write-Host "Event subject: $($eventGridEvent.subject)"
    Write-Host "Event data: $($eventGridEvent.data | ConvertTo-Json)"
    ```

---

### Add an Event Grid subscription

You can now add an Event Grid subscription for the Event Grid topic that you created. For more information, see [Concepts in Azure Event Grid](../../event-grid/concepts.md).

1. In your new function, select **Integration** and then select **Event Grid Trigger (eventGridEvent)**. 

    :::image type="content" source="./media/durable-functions-event-publishing/eventgrid-trigger-link.png" alt-text="Select the Event Grid Trigger link." border="true":::

1. Select **Create Event Grid Description**.

    :::image type="content" source="./media/durable-functions-event-publishing/create-event-grid-subscription.png" alt-text="Create the Event Grid subscription." border="true":::

1. Name your event subscription and select the **Event Grid Topics** topic type. 

1. Select the subscription. 

1. Select the resource group and resource that you created for the Event Grid topic. 

1. Select **Create**.

    :::image type="content" source="./media/durable-functions-event-publishing/event-grid-subscription-details.png" alt-text="Create an Event Grid subscription." border="true":::

Now you're ready to receive lifecycle events.

## Run the Durable Functions app

Start your Durable Functions app to send events to your Event Grid topic. 

1. In the Durable Functions project that you configured earlier, begin debugging on your local machine.
1. Start an orchestration. 

The app publishes Durable Functions lifecycle events to Event Grid. Check its logs in the portal to verify that Event Grid triggers the listener function you created.

```
2019-04-20T09:28:21.041 [Info] Function started (Id=<your_function_id>)
2019-04-20T09:28:21.104 [Info] {
    "id": "<your_event_id>",
    "subject": "durable/orchestrator/Running",
    "data": {
        "hubName": "DurableFunctionsHub",
        "functionName": "Sample",
        "instanceId": "<your_instance_id>",
        "reason": "",
        "runtimeStatus": "Running"
    },
    "eventType": "orchestratorEvent",
    "eventTime": "2019-04-20T09:28:19.6492068Z",
    "dataVersion": "1.0",
    "metadataVersion": "1",
    "topic": "/subscriptions/<your_subscription_id>/resourceGroups/eventResourceGroup/providers/Microsoft.EventGrid/topics/durableTopic"
}

2019-04-20T09:28:21.104 [Info] Function completed (Success, Id=<your_function_id>, Duration=65ms)
2019-04-20T09:28:37.098 [Info] Function started (Id=<your_function_id>)
2019-04-20T09:28:37.098 [Info] {
    "id": "<your_event_id>",
    "subject": "durable/orchestrator/Completed",
    "data": {
        "hubName": "DurableFunctionsHub",
        "functionName": "Sample",
        "instanceId": "<your_instance_id>",
        "reason": "",
        "runtimeStatus": "Completed"
    },
    "eventType": "orchestratorEvent",
    "eventTime": "2019-04-20T09:28:36.5061317Z",
    "dataVersion": "1.0",
    "metadataVersion": "1",
    "topic": "/subscriptions/<your_subscription_id>/resourceGroups/eventResourceGroup/providers/Microsoft.EventGrid/topics/durableTopic"
}
2019-04-20T09:28:37.098 [Info] Function completed (Success, Id=<your_function_id>, Duration=0ms)
```

## Event schema

| Metadata | Description |
| -------- | ----------- |
| `id` | Unique identifier for the Event Grid event. |
| `subject` | Path to the event subject. `durable/orchestrator/{orchestrationRuntimeStatus}`. `{orchestrationRuntimeStatus}` can be `Running`, `Completed`, `Failed`, or `Terminated`. |
| `data` | Durable Functions specific parameters. |
| `data.hubName` | [TaskHub](durable-functions-task-hubs.md) name. |
| `data.functionName` | Orchestrator function name. |
| `data.instanceId` | Durable Functions instance ID. |
| `data.reason` | Additional data associated with the tracking event. For more information, see [Diagnostics in Durable Functions (Azure Functions)](durable-functions-diagnostics.md). |
| `data.runtimeStatus` | Orchestration runtime status. Running, Completed, Failed, Canceled. |
| `eventType` | "orchestratorEvent" |
| `eventTime` | Event time (UTC). |
| `dataVersion` | Version of the lifecycle event schema. |
| `metadataVersion` | Version of the metadata. |
| `topic` | Event Grid topic resource. |

## How to test locally

To test locally, see [Local testing with viewer web app](../event-grid-how-tos.md#local-testing-with-viewer-web-app).

## Next steps

Learn more about:
- [Instance management](durable-functions-instance-management.md)
- [Versioning in Durable Functions](durable-functions-versioning.md)
