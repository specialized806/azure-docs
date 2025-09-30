---
title: Web Application Firewall Insights Dashboards
description: Learn how to use Azure Application Gateway WAF insights dashboards to monitor, investigate, and report on web application firewall activity.
author: halkazwini
ms.author: halkazwini
ms.service: azure-web-application-firewall
ms.topic: concept-article
ms.date: 09/30/2025

#CustomerIntent: As a developer, I want to secure my containerized applications so that I can protect them from web vulnerabilities.
---

# Azure Application Gateway Web Application Firewall (WAF) insights dashboards

The WAF Insights dashboards for Azure Application Gateway provide a centralized experience for monitoring, investigation, and reporting of WAF activity. They're designed to help security and operations teams:

- Detect attack patterns and malicious traffic trends.
- Validate WAF policy effectiveness.
- Identify misconfigurations and fine-tune rules.
- Accelerate incident response with drill-down forensic capabilities.

By combining high-level visibility with detailed request-level insights, these dashboards support both strategic monitoring and hands-on troubleshooting.

The Insights solution consists of two primary dashboards:

- **Triage Tab** - designed for investigation. It provides drill-down views to identify affected hosts, URLs, requests, and rules involved in a specific security event. This supports root cause analysis and faster incident response.

- **Monitor Tab** - designed for continuous visibility. It surfaces high-level metrics and trends such as total request volumes, managed rule matches, custom rule matches, and JavaScript challenge activity. The Monitor tab helps operators detect anomalies, track the effectiveness of WAF protections, and understand overall application security posture at a glance.

## Prerequisites

To view WAF data in the dashboards, you must enable **Diagnostic settings** for the Application Gateway associations you want to monitor. Without diagnostic logs, no WAF data will be available in the dashboards. To learn more about how to enable diagnostic settings, see [Monitor logs for Azure Web Application Firewall](/azure/web-application-firewall/ag/web-application-firewall-logs?tabs=AppGW) and [Diagnostic logs - Azure Application Gateway](/azure/application-gateway/application-gateway-diagnostics)

## Azure workbooks

The dashboards are workbook-based in Azure Monitor. This provides flexibility to explore, customize, and extend the visualizations according to operational and security needs.

## Data sources and architecture

The dashboards combine **Metrics** and **Logs**, which complement each other:

| Source | Description | Retention | Best for |
|----|----|----|----|
| **Metrics** | Aggregated counters collected at minute intervals. Optimized for trend analysis. | Controlled by Azure Monitor metrics retention settings. | Near real-time anomaly detection, activity trends. |
| **Logs (Azure diagnostics)** | Full per-request event data from WAF diagnostic logging. | Controlled by Log Analytics Workspace retention policy. | Deep forensic investigation, compliance, and auditing. |

> [!IMPORTANT]
> - Metrics are ideal for fast anomaly detection but don't contain full request details.
> - Logs contain full forensic information but may take longer to query for large datasets.

## Dashboard structure

The WAF Insights experience is divided into two main tabs:

- **Triage** - Drill-down investigations of events.

- **Monitor** - High-level reporting and trend tracking.

Each tab offers a different perspective and is often used together: monitor overall health in the **Monitor tab**, then use the **Triage tab** to investigate anomalies.

### Triage Tab

The **Triage tab** is designed for investigation and troubleshooting of WAF events. Data is sourced from **AzureDiagnostics** in Log Analytics Workspace (LAW). It supports two modes:

- **Triage by rule**: start from a rule and drill down.

- **Triage by URL**: start from a URL and drill down.

**Key Behavior**: Except for the first visualization, each component is dynamically filtered based on selections in the previous step. Each component (besides the first visualization) is filtered in real time, depending on the selections from the prior step. This drill-down approach helps narrow down from the overall scope to individual impacted requests.

### Triage by rule

Investigates activity starting from triggered rules.

#### Visuals and flow

- Scope selection: Choose the WAF policy scope (Listener, URI Path, or Global).

- Blocked / Detected / Matched counts: High-level statistics of triggered rules.

- Rules triggered for selected scope: View rule ID, action, ruleset version, scope, and impacted requests.

- Impacted hosts: IP addresses affected by the rule.

- Impacted URLs per host: Drill down to individual URLs and requests.

#### Use cases

- Identify which rules generate the most blocks.

- Investigate false positives or fine-tune custom rules.

- Understand which hosts and URLs are most impacted by a specific rule.

### Triage by URL

Investigates activity starting from a URL path.

#### Visuals and flow

- Scope selection: Select the relevant Application Gateway and policy scope.

- Impacted hosts per URL: Identify clients or attack sources targeting specific URLs.

- Rules triggered for impacted requests: Drill down to rule details and logs.

- Selection summary: Quick overview of what triggered the WAF response.

#### Use cases

- Investigate suspicious traffic against login pages or sensitive endpoints.

- Verify whether blocked requests are legitimate or malicious.

- Map attack patterns across URLs.

### Monitor tab

The Monitor tab is designed for visibility and reporting. It provides both **WAF metrics** and **WAF logs** views.

#### WAF logs

The **WAF logs** view provides a detailed, request-level perspective of WAF activity. Unlike metrics, which focus on aggregated counters, this tab is designed for forensic analysis and auditing. Data is sourced from **AzureDiagnostics** in Log Analytics Workspace (LAW).

#### Visuals and tables

- **Total WAF requests by rule group (select to filter)**: Pie charts of total number of requests group by Rule Group.

- **WAF actions (select to filter)**: Pie chart of WAF actions (Blocked, others)

- **Top 50 blocked requests URIs (select to filter)**: Frequent blocked request URIs with counts.

- **Top 50 WAF rules (select to filter)**: Ranked table of rules by trigger count, including Rule ID and description.

- **Rules over time**: Time-series visualization of triggered rules across the selected period.

- **Rules details**: Table of triggered rule events (timestamp, host, AppGW instance, client IP, action).

- **Requests by rule (select to filter)**: Summarized counts of requests per triggered rule.

- **Requests by rule over time**: Trend visualization showing request volumes per rule over time.

- **Filter by tracking ID / Rule for tracking ID**: Linked tables to investigate triggered rules by a tracking ID.

- **Top 10 sources (IPs) (select to filter)**: Bar chart of client IPs with the highest triggered rules.

- **Requests (from selected IPs)**: Table of requests from the top IPs, with host, rule, and URIs.

#### Use cases

- Identify attack sources and top offenders.

- Correlate IPs, hosts, and rules to detect targeted attacks.

- Validate rule effectiveness and tune the WAF policy.

- Support auditing and compliance needs.

### WAF metrics

The **WAF metrics** view provides near real-time visibility into Application Gateway WAF activity using Azure Monitor metrics. It surfaces aggregated counters at minute-level granularity and is optimized for detecting anomalies, monitoring trends, and validating WAF configuration.

#### Visuals

- **WAF total requests**: Displays the total number of requests processed by the WAF across associations.

- **WAF managed rule matches by association**: Shows all managed rule matches, broken down by association.

- **WAF managed rule matches by association - block**: Requests blocked by managed rules, grouped by association.

- **WAF managed rule matches by association - others**: Requests that were evaluated by managed rules but were **not blocked** - including those that were allowed, logged, or challenged, grouped by association.

- **WAF JS challenge request count by association**: Total number of JavaScript (JS) challenges triggered, aggregated per association.

- **WAF custom rules matched by association**: Displays the total number of custom rule matches across associations.

#### Use cases

- Detect traffic surges or anomalies in total requests.

- Understand managed rules behavior across associations.

- Monitor the effectiveness of JS challenge enforcement.

- Track custom rule usage and confirm correct policy configuration.

- Support operational reporting with aggregated counters that complement detailed log data.

## Summary of dashboards

| **Dashboard** | **Purpose** | **Investigation flow** | **Example use cases** |
|----|----|----|----|
| **Triage by rule** | Investigate by rule ID | Scope → Rule → Hosts → URLs → Requests | Identify noisy rules, analyze blocks, fine-tune rules |
| **Triage by URL** | Investigate by URL path | Scope → URL → Hosts → Rules → Requests | Investigate attacks on sensitive endpoints, validate rule effectiveness |
| **WAF logs** | Log-based monitoring | Pulls structured data from LAW | Validate policy effectiveness, perform audits, investigate requests |
| **WAF metrics** | Metric-based monitoring | Uses Azure Monitor metrics | Near real-time monitoring, detect anomalies, track trends |

## Glossary

- **Association**: The binding between a WAF policy and an Application Gateway listener or path.

- **Scope**: The level at which a WAF policy applies (Listener, URI Path, Global).

- **Rule ID**: Identifier of a managed rule triggered by the WAF.

- **LAW (Log Analytics workspace)**: Repository where logs are stored and queried.

- **Metrics**: Aggregated counters optimized for fast monitoring.

## Limitations and considerations

- **Latency:** Metrics are near real-time, but Logs may have ingestion delay (typically 1-5 minutes).

- **Retention:** Ensure Log Analytics retention is configured to match compliance/audit needs.

- **Scale:** Large volumes of diagnostic logs can increase query latency and storage costs.

## Best practices

- Always enable **both metrics and logs** to balance visibility and detail.

- Use the **Monitor tab daily** for operational awareness, and the **Triage tab on demand** during incidents.

- Periodically review *noisy rules* in the **Triage by rule** view to fine-tune WAF configuration.

- Configure alerts on **sudden spikes** in WAF metrics (for example, challenge requests or blocked requests).

- Align dashboard use with **incident response workflows**, ensuring security and networking teams collaborate using the same views.

## Related content

- [Monitor Azure Application Gateway](/azure/application-gateway/monitor-application-gateway)

- [Examining logs using Azure Log Analytics - Azure Application Gateway](/azure/application-gateway/log-analytics)

- [Diagnostic logs - Azure Application Gateway](/azure/application-gateway/application-gateway-diagnostics)

- [Azure Monitor metrics for Application Gateway](/azure/application-gateway/application-gateway-metrics)

- [Azure Monitor metrics for Application Gateway](/azure/application-gateway/application-gateway-metrics)

- [Azure Workbooks overview - Azure Monitor](/azure/azure-monitor/visualize/workbooks-overview)

- [Azure Workbooks overview - Azure Monitor](/azure/azure-monitor/visualize/workbooks-overview)

- [Monitoring metrics for Azure Application Gateway Web Application Firewall](/azure/web-application-firewall/ag/application-gateway-waf-metrics)

- [Monitor logs for Azure Web Application Firewall](/azure/web-application-firewall/ag/web-application-firewall-logs?tabs=AppGW)
