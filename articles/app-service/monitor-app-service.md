---
title: Monitor Azure App Service
description: Learn about options in Azure App Service for monitoring resources for availability, performance, and operation.
ms.date: 04/18/2025
ms.custom: horz-monitor
ms.topic: conceptual
author: msangapu-msft
ms.author: msangapu
ms.service: azure-app-service
---

# Monitor Azure App Service

[!INCLUDE [horz-monitor-intro](~/reusable-content/ce-skilling/azure/includes/azure-monitor/horizontals/horz-monitor-intro.md)]

## App Service monitoring

Azure App Service provides several options for monitoring resources for availability, performance, and operation. Options include diagnostic settings, Application Insights, log stream, metrics, quotas and alerts, and activity logs.

On the Azure portal page for your web app, you can select **Diagnose and solve problems** from the left navigation to access complete App Service diagnostics for your app. For more information about the App Service diagnostics tool, see [Azure App Service diagnostics overview](overview-diagnostics.md).

App Service provides built-in diagnostics logging to assist with debugging apps. For more information about the built-in logs, see [Stream diagnostics logs](troubleshoot-diagnostic-logs.md#stream-logs).

You can also use Azure Health check to monitor App Service instances. For more information, see [Monitor App Service instances using Health check](monitor-instances-health-check.md).

If you're using ASP.NET Core, ASP.NET, Java, Node.js, or Python, we recommend [enabling observability with Application Insights](/azure/azure-monitor/app/opentelemetry-enable). To learn more about observability experiences offered by Application Insights, see [Application Insights overview](/azure/azure-monitor/app/app-insights-overview).

### Monitoring scenarios

The following table lists monitoring methods to use for different scenarios.

|Scenario|Monitoring method |
|----------|-----------|
|I want to monitor platform metrics and logs | [Azure Monitor platform metrics](#platform-metrics)|
|I want to monitor application performance and usage | (Azure Monitor) [Application Insights](#application-insights)|
|I want to monitor built-in logs for testing and development|[Log stream](troubleshoot-diagnostic-logs.md#stream-logs)|
|I want to monitor resource limits and configure alerts|[Quotas and alerts](web-sites-monitor.md)|
|I want to monitor web app resource events|[Activity logs](#activity-log)|
|I want to monitor metrics visually|[Metrics](web-sites-monitor.md#metrics-granularity-and-retention-policy)|

[!INCLUDE [horz-monitor-insights](~/reusable-content/ce-skilling/azure/includes/azure-monitor/horizontals/horz-monitor-insights.md)]

### Application Insights

Application Insights is an Azure Monitor feature that helps you monitor availability, performance, and usage for your web app. For supported App Service stacks, you can enable Application Insights from the Azure portal without changing your code. If you need custom telemetry, unsupported hosting scenarios, or more control over configuration, [instrument through code](/azure/azure-monitor/app/opentelemetry-enable). For more information about Application Insights, see [Application Insights overview](/azure/azure-monitor/app/app-insights-overview).

> [!NOTE]
> Use a connection string to connect your app to Application Insights. For more information, see [Connection strings in Application Insights](/azure/azure-monitor/app/connection-strings).

> [!IMPORTANT]
> If App Service autoinstrumentation and code-based instrumentation are both enabled, the app uses the code-based instrumentation settings. Use one instrumentation method to avoid duplicate telemetry.

Open your app in the Azure portal, select **Application Insights** > **Enable**, create or select an Application Insights resource, and then select **Apply monitoring settings**. App Service restarts the app.

For infrastructure as code, include the Application Insights resource or connection string that your monitoring approach requires, and add the App Service settings in the following tabs. The examples in each tab show only the `siteConfig.appSettings` entries. Keep any other app settings that your app already uses. For more information about managing app settings, see [Configure App Service app settings](configure-common.md#configure-app-settings).

#### [ASP.NET Core](#tab/aspnetcore)

##### Support and requirements

Use App Service autoinstrumentation with supported .NET [Long Term Support](https://dotnet.microsoft.com/platform/support/policy/dotnet-core) releases. [Trim self-contained deployments](/dotnet/core/deploying/trimming/trim-self-contained) aren't supported. For unsupported scenarios or advanced customization, [instrument through code](/azure/azure-monitor/app/opentelemetry-enable?tabs=aspnetcore).

##### Enable in the Azure portal

After you create or select an Application Insights resource, choose **Recommended** to collect telemetry or **Disabled** to turn off App Service autoinstrumentation.

##### Configure monitoring

To customize sampling, telemetry enrichment, or instrumentation beyond the built-in experience, [instrument through code](/azure/azure-monitor/app/opentelemetry-enable?tabs=aspnetcore).

##### Client-side monitoring

Client-side monitoring is enabled by default when you use **Recommended**. To turn it off, add the `APPINSIGHTS_JAVASCRIPT_ENABLED` app setting and set it to `false`, then restart the app.

##### Deploy at scale

Add these app settings to your deployment:

| App setting | Value | Purpose |
|---|---|---|
| `ApplicationInsightsAgent_EXTENSION_VERSION` | `~2` on Windows or `~3` on Linux | Turns on runtime monitoring. |
| `XDT_MicrosoftApplicationInsights_Mode` | `recommended` or `disabled` | Sets the collection mode. |
| `XDT_MicrosoftApplicationInsights_PreemptSdk` | `1` | Enables App Service interop with the Application Insights SDK for ASP.NET Core. |

The following example uses Linux. Use `~2` on Windows.

<details>
<summary>Example template snippet</summary>

```json
"siteConfig": {
  "appSettings": [
    {
      "name": "ApplicationInsightsAgent_EXTENSION_VERSION",
      "value": "~3"
    },
    {
      "name": "XDT_MicrosoftApplicationInsights_Mode",
      "value": "recommended"
    },
    {
      "name": "XDT_MicrosoftApplicationInsights_PreemptSdk",
      "value": "1"
    }
  ]
}
```

</details>

#### [.NET](#tab/net)

##### Support and requirements

Use **Recommended** or **Basic** for ASP.NET apps.

##### Enable in the Azure portal

After you create or select an Application Insights resource, choose a collection level for ASP.NET monitoring.

| Collection level | Description |
|---|---|
| **Basic** | Collects usage trends and correlates availability results to transactions. Collects host-process unhandled exceptions. Improves application performance monitoring (APM) metrics under load when sampling is enabled. |
| **Recommended** | Collects everything in **Basic** and adds CPU, memory, and I/O trends plus correlation across request and dependency boundaries. |

##### Configure monitoring

To configure adaptive sampling through App Service app settings, use the `MicrosoftAppInsights_AdaptiveSamplingTelemetryProcessor_*` prefix. Common settings include:

- `MicrosoftAppInsights_AdaptiveSamplingTelemetryProcessor_InitialSamplingPercentage`
- `MicrosoftAppInsights_AdaptiveSamplingTelemetryProcessor_MinSamplingPercentage`
- `MicrosoftAppInsights_AdaptiveSamplingTelemetryProcessor_EvaluationInterval`
- `MicrosoftAppInsights_AdaptiveSamplingTelemetryProcessor_MaxTelemetryItemsPerSecond`

For more information, see [Configure adaptive sampling for ASP.NET applications](/azure/azure-monitor/app/sampling#configuring-adaptive-sampling-for-aspnet-applications).

##### Client-side monitoring

Client-side monitoring is off by default. To turn it on, add the `APPINSIGHTS_JAVASCRIPT_ENABLED` app setting and set it to `true`, then restart the app. To turn it off, remove the app setting or set it to `false`. Don't use `APPINSIGHTS_JAVASCRIPT_ENABLED` with `urlCompression`.

##### Deploy at scale

Add these app settings to your deployment:

| App setting | Value | Purpose |
|---|---|---|
| `ApplicationInsightsAgent_EXTENSION_VERSION` | `~2` | Turns on runtime monitoring. |
| `XDT_MicrosoftApplicationInsights_Mode` | `default` or `recommended` | Sets the collection mode. `default` maps to **Basic**. |
| `InstrumentationEngine_EXTENSION_VERSION` | `~1` | Turns on the binary rewrite engine. This setting can increase cold start time. |
| `XDT_MicrosoftApplicationInsights_BaseExtensions` | `~1` | Captures SQL and Azure Table text with dependency calls. This setting requires `InstrumentationEngine_EXTENSION_VERSION` and can increase cold start time. |

<details>
<summary>Example template snippet</summary>

```json
"siteConfig": {
  "appSettings": [
    {
      "name": "ApplicationInsightsAgent_EXTENSION_VERSION",
      "value": "~2"
    },
    {
      "name": "XDT_MicrosoftApplicationInsights_Mode",
      "value": "recommended"
    },
    {
      "name": "InstrumentationEngine_EXTENSION_VERSION",
      "value": "~1"
    },
    {
      "name": "XDT_MicrosoftApplicationInsights_BaseExtensions",
      "value": "~1"
    }
  ]
}
```

</details>

#### [Java](#tab/java)

##### Support and requirements

App Service adds the Application Insights Java 3.x agent and starts collecting telemetry. For Spring Boot native image apps, use the [Azure Monitor OpenTelemetry Distro / Application Insights in Spring Boot native image Java application](https://aka.ms/AzMonSpringNative) instead.

##### Enable in the Azure portal

After you create or select an Application Insights resource, App Service starts collecting telemetry with the attached Java agent.

##### Configure monitoring

If you don't provide Java agent configuration, App Service uses the default configuration. To customize the agent, paste valid JSON into the Azure portal. Exclude the connection string and preview settings. After you save the configuration, App Service stores it in the `APPLICATIONINSIGHTS_CONFIGURATION_FILE` app setting.

For supported settings, see [Configuration options: Azure Monitor Application Insights for Java](/azure/azure-monitor/app/java-standalone-config). To add custom telemetry, see [Add, modify, and filter telemetry](/azure/azure-monitor/app/opentelemetry-add-modify?tabs=java#modify-telemetry).

##### Client-side monitoring

To enable client-side monitoring, use the [Browser SDK Loader (Preview)](/azure/azure-monitor/app/javascript-sdk?tabs=javascriptwebsdkloaderscript#add-the-javascript-code) with the Java agent. For more information, see [Configuration options: Azure Monitor Application Insights for Java](/azure/azure-monitor/app/java-standalone-config#browser-sdk-loader-preview).

##### Deploy at scale

Add these app settings to your deployment:

| App setting | Value | Purpose |
|---|---|---|
| `ApplicationInsightsAgent_EXTENSION_VERSION` | `~2` on Windows or `~3` on Linux | Turns on runtime monitoring. |
| `XDT_MicrosoftApplicationInsights_Java` | `0` or `1` | Turns the Java agent on or off on Windows. |

If you deploy custom Java agent configuration, also add `APPLICATIONINSIGHTS_CONFIGURATION_FILE` with the agent JSON. The following example uses Linux. On Windows, also set `XDT_MicrosoftApplicationInsights_Java` to `1`.

<details>
<summary>Example template snippet</summary>

```json
"siteConfig": {
  "appSettings": [
    {
      "name": "ApplicationInsightsAgent_EXTENSION_VERSION",
      "value": "~3"
    },
    {
      "name": "APPLICATIONINSIGHTS_CONFIGURATION_FILE",
      "value": "<valid Java agent JSON>"
    }
  ]
}
```

</details>

#### [Node.js](#tab/nodejs)

##### Support and requirements

App Service supports Node.js autoinstrumentation on Linux for code-based apps and custom containers, and on Windows for code-based apps. This integration is in public preview.

##### Enable in the Azure portal

After you create or select an Application Insights resource, App Service starts collecting telemetry with the attached Node.js agent.

##### Configure monitoring

Set `APPLICATIONINSIGHTS_CONFIGURATION_CONTENT` to a JSON string or set `APPLICATIONINSIGHTS_CONFIGURATION_FILE` to a file path that contains valid JSON.

```json
{
  "samplingPercentage": 80,
  "enableAutoCollectExternalLoggers": true,
  "enableAutoCollectExceptions": true,
  "enableAutoCollectHeartbeat": true,
  "enableSendLiveMetrics": true
}
```

For supported options, see [Node.js configuration](https://github.com/microsoft/ApplicationInsights-node.js#configuration).

##### Client-side monitoring

To enable client-side monitoring, [add the JavaScript SDK to your application](/azure/azure-monitor/app/javascript-sdk?tabs=javascriptwebsdkloaderscript#add-the-javascript-code).

##### Deploy at scale

Add these app settings to your deployment:

| App setting | Value | Purpose |
|---|---|---|
| `ApplicationInsightsAgent_EXTENSION_VERSION` | `~2` on Windows or `~3` on Linux | Turns on runtime monitoring. |
| `XDT_MicrosoftApplicationInsights_NodeJS` | `0` or `1` | Turns the Node.js agent on or off on Windows. |

If you want to deploy agent configuration with the app, add `APPLICATIONINSIGHTS_CONFIGURATION_CONTENT` or `APPLICATIONINSIGHTS_CONFIGURATION_FILE` too. The following example uses Linux. On Windows, also set `XDT_MicrosoftApplicationInsights_NodeJS` to `1`.

<details>
<summary>Example template snippet</summary>

```json
"siteConfig": {
  "appSettings": [
    {
      "name": "ApplicationInsightsAgent_EXTENSION_VERSION",
      "value": "~3"
    },
    {
      "name": "APPLICATIONINSIGHTS_CONFIGURATION_CONTENT",
      "value": "{ \"samplingPercentage\": 80 }"
    }
  ]
}
```

</details>

#### [Python](#tab/python)

##### Support and requirements

Python autoinstrumentation is supported for Python 3.9 through 3.13 on Linux App Service apps that are deployed as code. Custom containers aren't supported.

Don't use App Service autoinstrumentation if your app already uses manual OpenTelemetry instrumentation, such as the [Azure Monitor OpenTelemetry Distro](/azure/azure-monitor/app/opentelemetry-enable?tabs=python) or the [Azure Monitor OpenTelemetry Exporter](/python/api/overview/azure/monitor-opentelemetry-exporter-readme). This setup sends duplicate telemetry.

Live Metrics isn't available for App Service Python autoinstrumentation. If you need Live Metrics, use the [Azure Monitor OpenTelemetry Distro](/azure/azure-monitor/app/opentelemetry-enable?tabs=python).

##### Enable in the Azure portal

After you create or select an Application Insights resource, App Service starts collecting telemetry for your Python app.

##### Configure monitoring

App Service collects logs from the root logger and autoinstruments common libraries, including `Django`, `FastAPI`, `Flask`, `psycopg2`, `requests`, `urllib`, and `urllib3`.

For Django apps, set `DJANGO_SETTINGS_MODULE` in your App Service app settings.

To collect telemetry from other libraries, add supported OpenTelemetry community instrumentation packages to your app's `requirements.txt` file. App Service detects installed instrumentations automatically. For more information, see [OpenTelemetry community instrumentations](https://github.com/open-telemetry/opentelemetry-python-contrib/tree/main/instrumentation).

You can configure Python autoinstrumentation with OpenTelemetry environment variables. Common settings include:

| App setting | Use |
|---|---|
| `OTEL_SERVICE_NAME` or `OTEL_RESOURCE_ATTRIBUTES` | Sets the service name or other resource attributes. |
| `OTEL_TRACES_SAMPLER_ARG` | Sets the trace sampling ratio from `0` to `1`. |
| `OTEL_PYTHON_DISABLED_INSTRUMENTATIONS` | Disables specific instrumentations with a comma-separated list. |
| `OTEL_LOGS_EXPORTER`, `OTEL_METRICS_EXPORTER`, `OTEL_TRACES_EXPORTER` | Turns off signal export when you set the value to `None`. |

For the full list, see [OpenTelemetry environment variables](https://opentelemetry.io/docs/reference/specification/sdk-environment-variables/).

##### Client-side monitoring

To enable client-side monitoring, [add the JavaScript SDK to your application](/azure/azure-monitor/app/javascript-sdk?tabs=javascriptwebsdkloaderscript#add-the-javascript-code).

##### Deploy at scale

Add these app settings to your deployment:

| App setting | Value | Purpose |
|---|---|---|
| `APPLICATIONINSIGHTS_CONNECTION_STRING` | Your Application Insights connection string | Connects the app to your Application Insights resource. |
| `ApplicationInsightsAgent_EXTENSION_VERSION` | `~3` | Turns on runtime monitoring on Linux App Service. |

Add optional OpenTelemetry app settings, such as `OTEL_SERVICE_NAME`, `OTEL_RESOURCE_ATTRIBUTES`, `OTEL_TRACES_SAMPLER_ARG`, or `OTEL_PYTHON_DISABLED_INSTRUMENTATIONS`, if your deployment needs them.

<details>
<summary>Example template snippet</summary>

```json
"siteConfig": {
  "appSettings": [
    {
      "name": "APPLICATIONINSIGHTS_CONNECTION_STRING",
      "value": "<connection string>"
    },
    {
      "name": "ApplicationInsightsAgent_EXTENSION_VERSION",
      "value": "~3"
    },
    {
      "name": "OTEL_SERVICE_NAME",
      "value": "<service name>"
    }
  ]
}
```

</details>

---

If you run into issues, use [Troubleshoot Application Insights integration with Azure App Service](/troubleshoot/azure/azure-monitor/app-insights/telemetry/troubleshoot-app-service-issues).

[!INCLUDE [horz-monitor-resource-types](~/reusable-content/ce-skilling/azure/includes/azure-monitor/horizontals/horz-monitor-resource-types.md)]
For more information about the resource types for App Service, see [App Service monitoring data reference](monitor-app-service-reference.md).

[!INCLUDE [horz-monitor-data-storage](~/reusable-content/ce-skilling/azure/includes/azure-monitor/horizontals/horz-monitor-data-storage.md)]

<a name="platform-metrics"></a>
[!INCLUDE [horz-monitor-platform-metrics](~/reusable-content/ce-skilling/azure/includes/azure-monitor/horizontals/horz-monitor-platform-metrics.md)]
For a list of available metrics for App Service, see [App Service monitoring data reference](monitor-app-service-reference.md#metrics).

For help understanding metrics in App Service, see [Metrics](web-sites-monitor.md#understand-metrics). View metrics by aggregate (such as average, max, or min), instance, time range, and other filters. Metrics can monitor performance, memory, CPU, and other attributes.

[!INCLUDE [horz-monitor-resource-logs](~/reusable-content/ce-skilling/azure/includes/azure-monitor/horizontals/horz-monitor-resource-logs.md)]
For the available resource log categories, their associated Log Analytics tables, and the schemas for App Service, see [App Service monitoring data reference](monitor-app-service-reference.md#resource-logs).

[!INCLUDE [audit log categories tip](./includes/azure-monitor-log-category-groups-tip.md)]

<a name="activity-log"></a>
[!INCLUDE [horz-monitor-activity-log](~/reusable-content/ce-skilling/azure/includes/azure-monitor/horizontals/horz-monitor-activity-log.md)]

### Azure activity logs for App Service

Azure activity logs for App Service include details such as:

- What operations were taken on the resources (for example, App Service plans)
- Who started the operation
- When the operation occurred
- Status of the operation
- Property values to help you research the operation

Azure activity logs can be queried using the Azure portal, PowerShell, REST API, or CLI.

### Ship activity logs to Event Grid

While activity logs are user-based, there's a new [Azure Event Grid](../event-grid/index.yml) integration with App Service (preview) that logs both user actions and automated events. With Event Grid, you can configure a handler to react to the said events. For example, use Event Grid to instantly trigger a serverless function to run image analysis each time a new photo is added to a blob storage container.

Alternatively, you can use Event Grid with Logic Apps to process data anywhere, without writing code. Event Grid connects data sources and event handlers.

To view the properties and schema for App Service events, see [Azure App Service as an Event Grid source](../event-grid/event-schema-app-service.md).

## Log stream (via App Service Logs)

Azure provides built-in diagnostics to assist during testing and development to debug an App Service app. [Log stream](troubleshoot-diagnostic-logs.md#stream-logs) can be used to get quick access to output and errors written by your application, and logs from the web server. This data contains standard output/error logs in addition to web server logs.

[!INCLUDE [horz-monitor-analyze-data](~/reusable-content/ce-skilling/azure/includes/azure-monitor/horizontals/horz-monitor-analyze-data.md)]

[!INCLUDE [horz-monitor-external-tools](~/reusable-content/ce-skilling/azure/includes/azure-monitor/horizontals/horz-monitor-external-tools.md)]

[!INCLUDE [horz-monitor-kusto-queries](~/reusable-content/ce-skilling/azure/includes/azure-monitor/horizontals/horz-monitor-kusto-queries.md)]

The following sample query can help you monitor app logs using `AppServiceAppLogs`:

```Kusto
AppServiceAppLogs 
| project CustomLevel, _ResourceId
| summarize count() by CustomLevel, _ResourceId
```

The following sample query can help you monitor HTTP logs using `AppServiceHTTPLogs` where the `HTTP response code` is `500` or higher:

```Kusto
AppServiceHTTPLogs 
//| where ResourceId = "MyResourceId" // Uncomment to get results for a specific resource Id when querying over a group of Apps
| where ScStatus >= 500
| reduce by strcat(CsMethod, ':\\', CsUriStem)
```

The following sample query can help you monitor HTTP 500 errors by joining `AppServiceConsoleLogs` and `AppserviceHTTPLogs`:

```Kusto
let myHttp = AppServiceHTTPLogs | where  ScStatus == 500 | project TimeGen=substring(TimeGenerated, 0, 19), CsUriStem, ScStatus;  

let myConsole = AppServiceConsoleLogs | project TimeGen=substring(TimeGenerated, 0, 19), ResultDescription;

myHttp | join myConsole on TimeGen | project TimeGen, CsUriStem, ScStatus, ResultDescription;   
```

See [Azure Monitor queries for App Service](https://github.com/microsoft/AzureMonitorCommunity/tree/master/Azure%20Services/App%20Services/Queries) for more sample queries.

[!INCLUDE [horz-monitor-alerts](~/reusable-content/ce-skilling/azure/includes/azure-monitor/horizontals/horz-monitor-alerts.md)]

[!INCLUDE [horz-monitor-insights-alerts](~/reusable-content/ce-skilling/azure/includes/azure-monitor/horizontals/horz-monitor-insights-alerts.md)]

### Quotas and alerts

Apps that are hosted in App Service are subject to certain limits on the resources they can use. The App Service plan associated with the app defines these limits. Metrics for an app or an App Service plan can be hooked up to alerts. To learn more, see [Quotas](web-sites-monitor.md#understand-quotas).

### App Service alert rules

The following table lists common and recommended alert rules for App Service.

| Alert type | Condition | Examples  |
|:---|:---|:---|
| Metric | Average connections| When number of connections exceed a set value|
| Metric | HTTP 404| When HTTP 404 responses exceed a set value|
| Metric | HTTP server errors| When HTTP 5xx errors exceed a set value|
| Activity log | Create or update web app | When app is created or updated|
| Activity log | Delete web app | When app is deleted|
| Activity log | Restart web app| When app is restarted|
| Activity log | Stop web app| When app is stopped|

[!INCLUDE [horz-monitor-advisor-recommendations](~/reusable-content/ce-skilling/azure/includes/azure-monitor/horizontals/horz-monitor-advisor-recommendations.md)]

## Related content

- [Azure App Service monitoring data reference](monitor-app-service-reference.md)
- [Monitor Azure resources with Azure Monitor](/azure/azure-monitor/essentials/monitor-azure-resource)