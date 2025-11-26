---
title: Monitoring Azure App Configuration data reference
description: Important Reference material needed when you monitor App Configuration
services: azure-app-configuration
author: maud-lv
ms.author: malev
ms.service: azure-app-configuration
ms.topic: reference
ms.date: 05/05/2021
ms.custom: horz-monitor
---


# Monitoring App Configuration data reference

This article is a reference for the monitoring data collected by App Configuration. See [Monitoring App Configuration](monitor-app-configuration.md) for how to collect and analyze monitoring data for App Configuration.

## Metrics
[App Configuration Metrics](/azure/azure-monitor/reference/supported-metrics/microsoft-appconfiguration-configurationstores-metrics)

| Metric | Unit | Description |
|-------|-----| ----- |
| HTTP Incoming Request Count	| Count	| Total number of incoming HTTP requests |
| HTTP Incoming Request Duration | Milliseconds | Server side duration of an HTTP Request |
| Throttled HTTP Request Count | Count |	Throttled requests are HTTP requests that receive a response with a status code of 429 |
| Daily Storage Usage | Percent |	Represents the amount of storage in use as a percentage of the maximum allowance. This metric is updated at least once daily. |
| Request Quota Usage | Percent |	Represents the current total request usage in percentage. |
| Replication Latency | Milliseconds |	Represents the average time it takes for a replica to be consistent with current state. |
| Snapshot Storage Size | Count | Represents the total storage usage of configuration snapshots in bytes. |

For more information, see a list of [all platform metrics supported in Azure Monitor](/azure/azure-monitor/essentials/metrics-supported).

## Metric Dimensions
App Configuration has the following dimensions associated with its metrics.

| Metric Name | Dimension description |
|-------|-----|
| HTTP Incoming Request Count | The supported dimensions are the **HttpStatusCode**, **AuthenticationScheme**, and **Endpoint** of each request. **AuthenticationScheme** can be filtered by "AAD" or "HMAC" authentication.   |
| HTTP Incoming Request Duration | The supported dimensions are the **HttpStatusCode**, **AuthenticationScheme**, and **Endpoint** of each request. **AuthenticationScheme** can be filtered by "AAD" or "HMAC" authentication. |
| Throttled HTTP Request Count | The **Endpoint** of each request is included as a dimension.  |
| Daily Storage Usage | This metric doesn't have any dimensions.  |
| Request Quota Usage | The supported dimensions are the **OperationType** ("Read"or "Write") and **Endpoint** of each request.  |
| Replication Latency | This metric includes an **Endpoint** dimension that identifies the replica to which data was replicated.  |
| Snapshot Storage Size | This metric doesn't have any dimensions.  |

 For more information on what metric dimensions are, see [Multi-dimensional metrics](/azure/azure-monitor/essentials/data-platform-metrics#multi-dimensional-metrics).

## Resource logs
This section lists the category types of resource log collected for App Configuration. 

| Resource log type | Further information|
|-------|-----|
| [AACHttpRequest](/azure/azure-monitor/reference/tables/AACHttpRequest) | [App Configuration resource log category information](/azure/azure-monitor/essentials/resource-logs-categories) |
| [AACAudit](/azure/azure-monitor/reference/tables/AACAudit) | [App Configuration resource log category information](/azure/azure-monitor/essentials/resource-logs-categories) |

For more schema information, see a list of [Common and service-specific schemas for Azure resource logs](/azure/azure-monitor/essentials/resource-logs-schema).
 
## Azure Monitor Logs tables

This section refers to all of the Azure Monitor Logs Kusto tables relevant to App Configuration and available for query by Log Analytics.

|Resource type | Notes |
|-------|-----|
| [AACAudit](/azure/azure-monitor/reference/tables/AACAudit) | Azure App Configuration audit logs. |
| [AACHttpRequest](/azure/azure-monitor/reference/tables/AACHttpRequest) | Entries of every HTTP request sent to a selected app configuration resource. |
| [AzureActivity](/azure/azure-monitor/reference/tables/AzureActivity) | Entries from the Azure Activity log that provide insight into any subscription-level or management group level events that have occurred in Azure. |

For a reference of all Azure Monitor Logs / Log Analytics tables for App Configuration, see the [Log Analytics tables for microsoft.appconfiguration/configurationstores](/azure/azure-monitor/reference/tables/microsoft-appconfiguration_configurationstores).

## See Also

* See [Monitoring Azure App Configuration](monitor-app-configuration.md) for a description of monitoring Azure App Configuration.
* See [Monitoring Azure resources with Azure Monitor](/azure/azure-monitor/essentials/monitor-azure-resource) for details on monitoring Azure resources.
