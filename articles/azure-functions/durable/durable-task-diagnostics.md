---
title: Diagnostics in Durable Task SDKs
description: Learn how to diagnose problems with the Durable Task SDKs.
author: cgillum
ms.topic: conceptual
ms.date: 02/02/2026
ms.author: azfuncdf
ms.devlang: csharp
# ms.devlang: csharp, java, javascript, python
---

# Diagnostics in Durable Task SDKs

There are several options for diagnosing issues with the Durable Task SDKs. In this article, you learn about the diagnostic tools and techniques available for troubleshooting orchestrations.

## Application Insights

[Application Insights](/azure/azure-monitor/app/app-insights-overview) is the recommended way to do diagnostics and monitoring with the Durable Task SDKs.

The Durable Task SDKs emit *tracking events* that allow you to trace the end-to-end execution of an orchestration. These tracking events can be found and queried using the [Application Insights Analytics](/azure/azure-monitor/logs/log-query-overview) tool in the Azure portal.

### Tracking data

Each lifecycle event of an orchestration instance causes a tracking event to be written to the **traces** collection in Application Insights. This event contains a **customDimensions** payload with several fields. Field names are all prepended with `prop__`.

* **hubName**: The name of the task hub in which your orchestrations are running.
* **appName**: The name of the application. This field is useful when you have multiple apps sharing the same Application Insights instance.
* **functionName**: The name of the orchestrator or activity.
* **functionType**: The type of the function, such as **Orchestrator** or **Activity**.
* **instanceId**: The unique ID of the orchestration instance.
* **state**: The lifecycle execution state of the instance. Valid values include:
  * **Scheduled**: The function was scheduled for execution but hasn't started running yet.
  * **Started**: The function started running but has not yet awaited or completed.
  * **Awaited**: The orchestrator has scheduled some work and is waiting for it to complete.
  * **Listening**: The orchestrator is listening for an external event notification.
  * **Completed**: The function completed successfully.
  * **Failed**: The function failed with an error.
* **reason**: Additional data associated with the tracking event. For example, if an instance is waiting for an external event notification, this field indicates the name of the event it is waiting for. If a function fails, this field contains the error details.
* **isReplay**: Boolean value indicating whether the tracking event is for replayed execution.
* **extensionVersion**: The version of the Durable Task SDK. The version information is especially important data when reporting possible bugs. Long-running instances may report multiple versions if an update occurs while it is running.
* **sequenceNumber**: Execution sequence number for an event. Combined with the timestamp helps to order the events by execution time. *Note that this number resets to zero if the host restarts while the instance is running, so it's important to always sort by timestamp first, then sequenceNumber.*

### Single instance query

The following query shows historical tracking data for a single orchestration instance. It's written using the [Kusto Query Language](/azure/data-explorer/kusto/query/). It filters out replay execution so that only the *logical* execution path is shown. Events can be ordered by sorting by `timestamp` and `sequenceNumber` as shown in the query below:

```kusto
let targetInstanceId = "ddd1aaa685034059b545eb004b15d4eb";
let start = datetime(2018-03-25T09:20:00);
traces
| where timestamp > start and timestamp < start + 30m
| where customDimensions.Category == "Host.Triggers.DurableTask"
| extend functionName = customDimensions["prop__functionName"]
| extend instanceId = customDimensions["prop__instanceId"]
| extend state = customDimensions["prop__state"]
| extend isReplay = tobool(tolower(customDimensions["prop__isReplay"]))
| extend sequenceNumber = tolong(customDimensions["prop__sequenceNumber"])
| where isReplay != true
| where instanceId == targetInstanceId
| sort by timestamp asc, sequenceNumber asc
| project timestamp, functionName, state, instanceId, sequenceNumber, appName = cloud_RoleName
```

The result is a list of tracking events that shows the execution path of the orchestration, including any activity functions ordered by the execution time in ascending order.

### Instance summary query

The following query displays the status of all orchestration instances that were run in a specified time range.

```kusto
let start = datetime(2017-09-30T04:30:00);
traces
| where timestamp > start and timestamp < start + 1h
| where customDimensions.Category == "Host.Triggers.DurableTask"
| extend functionName = tostring(customDimensions["prop__functionName"])
| extend instanceId = tostring(customDimensions["prop__instanceId"])
| extend state = tostring(customDimensions["prop__state"])
| extend isReplay = tobool(tolower(customDimensions["prop__isReplay"]))
| extend output = tostring(customDimensions["prop__output"])
| where isReplay != true
| summarize arg_max(timestamp, *) by instanceId
| project timestamp, instanceId, functionName, state, output, appName = cloud_RoleName
| order by timestamp asc
```

The result is a list of instance IDs and their current runtime status.

## Durable Task Scheduler monitoring dashboard

When using the [Durable Task Scheduler](durable-task-scheduler/durable-task-scheduler-overview.md), you can observe, manage, and debug your orchestrations using the Durable Task Scheduler dashboard. The dashboard is available when you run the [Durable Task Scheduler emulator](durable-task-scheduler/durable-task-scheduler.md#emulator-for-local-development) locally or create a scheduler resource on Azure.

### Accessing the dashboard

Running the emulator locally doesn't require authentication.

For Azure-hosted schedulers, you need to [assign the *Durable Task Data Contributor* role to your identity](durable-task-scheduler/durable-task-scheduler-identity.md). You can then access the dashboard via either:

- The task hub's dashboard endpoint URL in the Azure portal
- Navigate to `https://dashboard.durabletask.io/` combined with your task hub endpoint

### Dashboard capabilities

The dashboard provides the following monitoring and management features:

- **Monitor orchestration progress**: View orchestration status, filter by metadata such as state and timestamps, and review execution history.
- **View inputs and outputs**: Inspect orchestration and activity inputs and outputs.
- **Timeline view**: Visualize orchestration execution as a timeline, including activity retries and timing.
- **History view**: See detailed event sequence, timestamps, and payloads.
- **Sequence view**: Get another way of visualizing event sequence.
- **Orchestration management**: Start, pause, resume, and terminate orchestrations on demand.

For detailed instructions on setting up access and using the dashboard, see [Debug and manage orchestrations using the Durable Task Scheduler dashboard](durable-task-scheduler/durable-task-scheduler-dashboard.md).

## Next steps

> [!div class="nextstepaction"]
> [Learn more about the Durable Task Scheduler](durable-task-scheduler/durable-task-scheduler-overview.md)
