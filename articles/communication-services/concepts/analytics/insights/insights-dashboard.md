---
title: Azure Communication Services Insights dashboard
titleSuffix: An Azure Communication Services concept document
description: Descriptions of data visualizations available from the Insights dashboard.
author:  amagginetti
services: azure-communication-services

ms.author: amagginetti
ms.date: 03/08/2021
ms.topic: conceptual
ms.service: azure-communication-services
ms.subservice: data
---

# Insights dashboard

This article describes insights available from the Insights dashboard. Use these insights to monitor logs and metrics.

## Overview

Each Communications Resource includes an Insights dashboard that displays data visualizations from the Azure Monitor logs and metrics monitored for your Communications Services. The visualizations within Insights are made possible via [Azure Monitor Workbooks](/azure/azure-monitor/visualize/workbooks-overview). In order to take advantage of Workbooks, follow the instructions outlined in [Enable Azure Monitor in Diagnostic Settings](../enable-logging.md). To enable Workbooks, you need to send your logs to a [Log Analytics workspace](/azure/azure-monitor/logs/log-analytics-overview) destination.

:::image type="content" source="..\media\workbooks\insights-overview-2.png" alt-text="Screenshot of Communication Services Insights dashboard.":::

## Prerequisites

- In order to take advantage of Workbooks, follow the instructions outlined in [Enable Logging with Azure Monitor](../enable-logging.md). You need to enable `Operational Authentication Logs`, `Call Summary Logs`, `Call Diagnostic Logs`.
- To use Workbooks, you need to send your logs to a [Log Analytics workspace](/azure/azure-monitor/logs/log-analytics-overview) destination. 

## Accessing Azure Insights for Communication Services

Inside your Azure Communication Services resource, scroll down on the left nav bar to the **Monitor** category and click on the **Insights** tab:

:::image type="content" source="..\media\workbooks\acs-insights-nav.png" alt-text="Screenshot of the Insights navigation blade.":::

## Authentication insights

The **Authentication** tab shows authentication logs, which are created through operations such as issuing an access token or creating an identity. The data displayed includes the types of operations performed and the results of those operations:

:::image type="content" source="..\media\workbooks\auth.png" alt-text="Screenshot of the authentication overview.":::

## More information about workbooks

For an in-depth description of workbooks, refer to the [Azure Monitor Workbooks](/azure/azure-monitor/visualize/workbooks-overview) documentation.

## Editing dashboards

The **Insights** dashboards provided with your **Communication Service** resource can be customized by clicking on the **Edit** button on the top navigation bar:

:::image type="content" source="..\media\workbooks\dashboard-editing.png" alt-text="Screenshot of dashboard editing process.":::

Editing these dashboards doesn't modify the **Insights** tab, but rather creates a separate workbook that can be accessed on your resource’s Workbooks tab:

:::image type="content" source="..\media\workbooks\workbooks-tab.png" alt-text="Screenshot of the workbooks tab.":::

For an in-depth description of workbooks, refer to the [Azure Monitor Workbooks](/azure/azure-monitor/visualize/workbooks-overview) documentation.
