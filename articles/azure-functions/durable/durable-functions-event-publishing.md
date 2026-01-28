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

- A [running Durable Functions project](./durable-functions-isolated-create-first-csharp.md) deployed to Azure with:
  - [`Microsoft.Azure.WebJobs.Extensions.DurableTask`](https://www.nuget.org/packages/Microsoft.Azure.WebJobs.Extensions.DurableTask) installed.
  - Managed identity [enabled](../../app-service/overview-managed-identity.md) and [configured](./durable-functions-configure-managed-identity.md)
  - A [running storage provider](./durable-functions-storage-providers.md) or the local [Azurite storage emulator](../../storage/common/storage-use-azurite.md).
- Install [Azure CLI](/cli/azure/) or use [Azure Cloud Shell](../../cloud-shell/overview.md).

In this guide, you'll set up end-to-end event publishing from a Durable Functions app to Azure Event Grid.

> [!div class="checklist"]
> - Configure your Durable Functions **publisher** app  to automatically publish lifecycle events (Created, Running, Completed, Failed, Terminated) to an Event Grid custom topic whenever orchestration state changes.
> - Create an Event Grid custom topic that acts as the central hub for routing events using credentials from your configured managed identity.
> - Create a listener (**subscriber**) function app with an Event Grid trigger to receive events from the topic and process them.
> - Deploy your project to Azure, where the Durable Functions app publishes events automatically.
> - Verify Event Grid handles the routing and delivery to the subscribed functions.

## Verify the Durable Functions extension

Before proceeding, make sure you have the latest `Microsoft.Azure.WebJobs.Extensions.DurableTask` extenstion version used by your Durable Functions project.

```bash
func extensions install --package Microsoft.Azure.WebJobs.Extensions.DurableTask --version 2.7.0
```

## Create a custom Event Grid topic

You can create an Event Grid topic for sending events from Durable Functions by using [the Azure CLI](../../event-grid/custom-event-quickstart.md), [PowerShell](../../event-grid/custom-event-quickstart-powershell.md), or [the Azure portal](../../event-grid/custom-event-quickstart-portal.md). 

This guide uses the Azure CLI.

### Create a resource group

Create a resource group with the `az group create` command. Pick a location that matches your existing Durable Functions app and that you can use for all the resources you create later.

> [!NOTE]
> Currently, Azure Event Grid doesn't support all regions. For information about which regions are supported, see the [Azure Event Grid overview](../../event-grid/overview.md).

```azurecli
az group create --name <resource_group_name> --location <location>
```

[!INCLUDE [register-provider-cli.md](../../event-grid/includes/register-provider-cli.md)]

### Create a custom topic

An Event Grid topic provides a user-defined endpoint that you post your event to. Replace `<topic_name>` in the following command with a unique name for your topic. The topic name must be unique because it becomes a DNS entry.

```azurecli
az eventgrid topic create --name <topic_name> --location westus2 --resource-group eventResourceGroup
```

## Get the topic endpoint

Get the endpoint of the topic. Replace `<topic_name>` in the following commands with the name you chose.

```azurecli
az eventgrid topic show --name <topic_name> --resource-group eventResourceGroup --query "endpoint" --output tsv
```

Save this endpoint for later.

## Configure Event Grid publishing with Managed Identity (recommended)

Managed identities in Azure allow resources to authenticate to Azure services without storing credentials, simplifying security and identity management. [Assign the managed identity associated with your Durable Function app to your Event Grid custom topic.](../../event-grid/enable-identity-custom-topics-domains.md#enable-identity-for-an-existing-custom-topic-or-domain)

### Configure the Durable Functions publisher app

Although your Durable Functions app automatically publishes orchestration lifecycle events to Event Grid, you need to configure the following settings and `host.json` entries. Use the Event Grid endpoint you saved earlier.

# [Durable Functions 2.x](#tab/durable-functions-2)

```json
{
  "version": "2.0",
  "logging": {
    "logLevel": {
      "default": "Information"
    }
  },
  "extensions": {
    "durableTask": {
      "tracing": {
        "traceInputsAndOutputs": false
      },
      "eventGridTopicEndpoint": "%EventGrid__topicEndpoint%",
      "eventGridKeySettingName": "EventGrid__credential"
    }
  }
}
```

# [Durable Functions 1.x](#tab/durable-functions-1)

```json
{
  "version": "1.0",
  "logging": {
    "logLevel": {
      "default": "Information"
    }
  },
  "extensions": {
    "durableTask": {
      "tracing": {
        "traceInputsAndOutputs": false
      },
      "eventGridTopicEndpoint": "%EventGrid__topicEndpoint%",
      "eventGridKeySettingName": "EventGrid__credential"
    }
  }
}
```

---

> [!NOTE]
> The `eventGridTopicEndpoint` setting references the Event Grid custom topic endpoint you saved earlier. The credential setting handles both managed identity and connection string scenarios.

### Assign Event Grid Data Sender role

Grant your [managed identity](../../app-service/overview-managed-identity.md) permission to publish events to the Event Grid topic.

# [User-assigned managed identity](#tab/user-assigned-role)

```azurecli
az role assignment create \
  --assignee <client-id-of-managed-identity> \
  --role "Event Grid Data Sender" \
  --scope /subscriptions/<subscription-id>/resourceGroups/eventResourceGroup/providers/Microsoft.EventGrid/topics/<topic-name>
```

Replace the following values:
- `<client-id-of-managed-identity>`: The client ID of your user-assigned managed identity
- `<subscription-id>`: Your Azure subscription ID
- `<topic-name>`: The name of your Event Grid topic

# [System-assigned managed identity](#tab/system-assigned-role)

```azurecli
az role assignment create \
  --assignee-object-id <object-id-of-function-app-identity> \
  --role "Event Grid Data Sender" \
  --scope /subscriptions/<subscription-id>/resourceGroups/eventResourceGroup/providers/Microsoft.EventGrid/topics/<topic-name>
```

To get the `<object-id-of-function-app-identity>`:

```azurecli
az functionapp identity show \
  --name <function-app-name> \
  --resource-group eventResourceGroup \
  --query principalId --output tsv
```

---

> [!NOTE]
> Role assignments can take 5-10 minutes to propagate. You may see authentication errors if you proceed immediately after assignment.

### Configure app settings

Once you've enabled managed identity for your function app and topic, configure the Event Grid app settings on your Durable Functions function app.

#### If using user-assigned managed identity (recommended)

Add the following app settings:
- `EventGrid__topicEndpoint` with the value as the Event Grid topic endpoint.
- `EventGrid__credential` with the value `managedidentity`.
- `EventGrid__clientId` with the value of the user assigned managed identity client ID.

```azurecli
az functionapp config appsettings set --name <function app name> --resource-group <resource group name> --settings EventGrid__topicEndpoint="<topic endpoint>" EventGrid__credential="managedidentity" EventGrid__clientId="<client id>"
```

#### If using system-assigned managed identity

Add an `EventGrid__topicEndpoint` app setting with the value as the Event Grid topic endpoint.

```azurecli
az functionapp config appsettings set --name <function app name> --resource-group <resource group name> --settings EventGrid__topicEndpoint="<topic endpoint>"
```

## Create functions that listen for events

Create another function app to listen for events published by your Durable Functions app. The listener function app must be in the same region as the Event Grid topic.

### Create the listener function app

1. Create a resource group for the listener function app.

    ```azurecli
    az group create --name eventListenerResourceGroup --location westus2
    ```

1. Create a storage account for the listener function app.

    ```azurecli
    az storage account create \
      --name <storage-account-name> \
      --resource-group eventListenerResourceGroup \
      --location westus2 \
      --sku Standard_LRS \
      --allow-blob-public-access false
    ```

1. Create the function app.

    ```azurecli
    az functionapp create \
      --resource-group eventListenerResourceGroup \
      --consumption-plan-location westus2 \
      --runtime <preferred-runtime> \
      --runtime-version <runtime-version> \
      --functions-version 4 \
      --name <listener-function-app-name> \
      --storage-account <storage-account-name>
    ```

Replace the placeholder values:
- `<storage-account-name>`: A globally unique name for your storage account (3-24 characters, lowercase and numbers only)
- `<listener-function-app-name>`: A globally unique name for your listener function app
- `<preferred-runtime>`: The programming runtime of your project. For example, `dotnet-isolated`.
- `<runtime-version>`: The version of the runtime you're using. For example, for `dotnet-isolated` runtime, you could specify `8.0`.

### Create an Event Grid trigger function locally

1. Create a local directory for your listener function project:

```bash
mkdir EventGridListenerFunction
cd EventGridListenerFunction
```

1. Initialize a new Functions project. For example, if using the `dotnet-isolated` runtime:

```bash
func init --name EventGridListener --runtime dotnet-isolated --model V1
```

1. Create a new Event Grid trigger function:

```bash
func new --template "Event Grid trigger" --name EventGridTrigger
```

1. Open the generated Event Grid trigger file and review the code. The template provides a basic implementation that logs event information.

### Publish the function to Azure

Publish your locally created function to the listener function app you created earlier:

```bash
func azure functionapp publish <listener-function-app-name>
```

> [!NOTE]
> For detailed deployment instructions, see [Deploy local Python/C# functions to Azure Functions using the Azure Functions Core Tools](/azure/azure-functions/functions-run-local#publish).

### Create an Event Grid subscription using CLI

You can now create an Event Grid subscription that connects the Event Grid topic to your listener function. For more information, see [Concepts in Azure Event Grid](../../event-grid/concepts.md).

1. Get your listener function's webhook URL:

    ```azurecli
    az functionapp function show \
      --resource-group eventListenerResourceGroup \
      --name <listener-function-app-name> \
      --function-name EventGridTrigger \
      --query "invokeUrlTemplate" \
      --output tsv
    ```

1. Create the Event Grid subscription:

    ```azurecli
    az eventgrid event-subscription create \
      --name <subscription-name> \
      --source-resource-id /subscriptions/<subscription-id>/resourceGroups/eventResourceGroup/providers/Microsoft.EventGrid/topics/<topic-name> \
      --endpoint <function-webhook-url> \
      --endpoint-type webhook
    ```

Replace the placeholder values:
- `<subscription-name>`: A name for your Event Grid subscription (for example, `DurableFunctionsEventSub`)
- `<subscription-id>`: Your Azure subscription ID
- `<topic-name>`: The name of your Event Grid topic
- `<function-webhook-url>`: The webhook URL from the previous step

> [!NOTE]
> Make sure the webhook URL includes the `code` parameter for authentication. If it's missing from the output, you can append it manually or retrieve it using the Azure portal.

Now you're ready to receive lifecycle events.

## Deploy and verify the setup

### Deploy the Durable Functions app

Before running the end-to-end flow, ensure your Durable Functions app is deployed to Azure:

1. In your Durable Functions project, [publish the function code to Azure](../functions-develop-vs-code.md#publish-to-azure).
1. Verify deployment by navigating to your function app in the Azure portal and checking that it shows a "Running" status.

### Verify Event Grid configuration

Before starting an orchestration, verify that Event Grid publishing is properly configured:

1. In the Azure portal, navigate to your Event Grid custom topic.
1. Select **Metrics** and check for **Published Events** or **Dropped Events** to verify the topic is accessible.
1. In your Durable Functions function app, verify the app settings appear under **Settings** > **Environment variables**:
   - `EventGrid__topicEndpoint` should be set
   - `EventGrid__credential` should be set to `managedidentity` (if using managed identity)

### Run an orchestration and monitor events

With the setup verified, trigger an orchestration and monitor the event flow:

1. In the Azure portal, navigate to your Durable Functions function app.
1. Select **Functions** and locate your HTTP-triggered orchestration starter function (for example, `HelloOrchestration_HttpStart`).
1. Select **Code + Test** and select **Get function URL**.
1. Use an HTTP client (such as Postman or curl) to send a POST request to the function URL. For example:

   ```bash
   curl -X POST https://<function_app_name>.azurewebsites.net/api/HelloOrchestration_HttpStart
   ```
1. The orchestration starts, and the Durable Functions runtime publishes lifecycle events to Event Grid.

### Verify events in the listener function

Check the listener function app to confirm it received events:

1. In the Azure portal, navigate to your **listener function app** (the one with the Event Grid trigger).
1. Select the Event Grid trigger function (for example, `EventGridTrigger`).
1. Select **Monitor** to view recent executions.
1. Select an execution to view the event details.

You should see output similar to the following when the listener function processes an orchestration lifecycle event:

```
2026-01-27T14:32:15.847 [Info] Event Grid trigger function processed an event.
2026-01-27T14:32:15.848 [Info] Event type: orchestratorEvent
2026-01-27T14:32:15.849 [Info] Event subject: durable/orchestrator/Running
2026-01-27T14:32:15.850 [Info] Event data: {"hubName":"DurableFunctionsHub","functionName":"HelloOrchestration","instanceId":"<your_instance_id>","reason":"","runtimeStatus":"Running"}
2026-01-27T14:32:32.114 [Info] Event Grid trigger function processed an event.
2026-01-27T14:32:32.115 [Info] Event type: orchestratorEvent
2026-01-27T14:32:32.116 [Info] Event subject: durable/orchestrator/Completed
2026-01-27T14:32:32.117 [Info] Event data: {"hubName":"DurableFunctionsHub","functionName":"HelloOrchestration","instanceId":"<your_instance_id>","reason":"","runtimeStatus":"Completed"}
```

### Verify in Application Insights (optional)

For a more comprehensive view of events:

1. In the Azure portal, navigate to your Durable Functions function app.
1. Select **Application Insights** from the left menu.
1. Select **Logs** and run this KQL query to view all processed events:
   ```kusto
   traces
   | where message contains "Event type" or message contains "Event subject"
   | project timestamp, message
   | order by timestamp desc
   ```

## Event schema

When a Durable Functions orchestration state changes, Event Grid publishes an event with the following structure:

| Metadata | Description |
| -------- | ----------- |
| `id` | Unique identifier for the Event Grid event. |
| `subject` | Path to the event subject. Format: `durable/orchestrator/{orchestrationRuntimeStatus}`. The status can be `Running`, `Completed`, `Failed`, or `Terminated`. |
| `data` | Durable Functions specific parameters. |
| `data.hubName` | [TaskHub](durable-functions-task-hubs.md) name. |
| `data.functionName` | Orchestrator function name. |
| `data.instanceId` | Durable Functions instance ID. This ID is unique per orchestration execution. |
| `data.reason` | Additional data associated with the tracking event. For more information, see [Diagnostics in Durable Functions (Azure Functions)](durable-functions-diagnostics.md). |
| `data.runtimeStatus` | Orchestration runtime status. Possible values: `Running`, `Completed`, `Failed`, `Canceled`. |
| `eventType` | Always "orchestratorEvent" for Durable Functions events. |
| `eventTime` | Event time (UTC). |
| `dataVersion` | Version of the lifecycle event schema. |
| `metadataVersion` | Version of the metadata. |
| `topic` | Event Grid topic resource identifier. |

### Understanding event flow

Events are published automatically by the Durable Functions runtime for each orchestration state transition. You don't need to add code to emit events—they're generated automatically. Event Grid ensures at-least-once delivery to all subscribers, so you may receive duplicate events in rare failure scenarios. Consider adding deduplication logic using the `instanceId` if needed.

## Troubleshooting

### Events are not being published to Event Grid

**Problem**: The listener function is not receiving events.

**Solutions**:
- Verify the Durable Functions function app has the correct app settings:
  - `EventGrid__topicEndpoint` must point to your custom topic endpoint
  - `EventGrid__credential` must be set to `managedidentity`
  - `EventGrid__clientId` must be set if using a user-assigned identity
- Verify the managed identity has the **Event Grid Data Sender** role assigned to the Event Grid custom topic.
- Check the Durable Functions function app logs in Application Insights for errors.
- Verify the Event Grid topic exists and is accessible in the same subscription.

### Listener function is not being triggered

**Problem**: The listener function exists but isn't executing when events are published.

**Solutions**:
- Verify the Event Grid subscription was created and is enabled:
  - In the Azure portal, navigate to your Event Grid topic → **Subscriptions**
  - Confirm your listener function's subscription is listed with status **Enabled**
- Verify the listener function's endpoint URL is correct in the subscription details.
- Check the listener function app logs for errors or delivery issues.
- In the Event Grid topic → **Metrics**, check for **Dropped Events** which may indicate delivery failures.

### "Forbidden" or authentication errors in logs

**Problem**: Authentication errors when publishing to Event Grid.

**Solutions**:
- Verify the managed identity is properly configured and enabled on the Durable Functions function app:
  - In the Azure portal, navigate to your function app → **Identity**
  - Confirm "Status" shows **On** for either system-assigned or user-assigned identity
- Verify the role assignment is correct:
  - Navigate to your Event Grid topic → **Access Control (IAM)**
  - Confirm your managed identity has the **Event Grid Data Sender** role
  - The role assignment may take a few minutes to propagate

### "Connection refused" or "endpoint not found" errors

**Problem**: Connection errors to the Event Grid topic.

**Solutions**:
- Verify the Event Grid topic endpoint in your app settings is correct and includes the full URL (for example, `https://my-topic.eventgrid.azure.net/api/events`)
- Verify the Event Grid topic resource exists in the same subscription and region
- Check that your Durable Functions app has network access to the Event Grid endpoint

### Test locally

To test locally, see [Local testing with viewer web app](../event-grid-how-tos.md#local-testing-with-viewer-web-app). When testing locally with managed identity, use your developer credentials to authenticate against the Event Grid topic. See [Configure Durable Functions with managed identity - Local development](durable-functions-configure-managed-identity.md#local-development) for details.

## Next steps

Learn more about:
- [Instance management](durable-functions-instance-management.md)
- [Versioning in Durable Functions](durable-functions-versioning.md)
