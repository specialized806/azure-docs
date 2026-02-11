---
title: Durable Task SDKs billing
titleSuffix: Durable Task
description: Learn how billing works for applications built with the Durable Task SDKs, including compute costs and Durable Task Scheduler pricing.
author: hhunter-ms
ms.author: hannahhunter
ms.reviewer: azfuncdf
ms.date: 02/06/2026
ms.topic: conceptual
ms.service: azure-functions
ms.subservice: durable
ai-usage: ai-generated
#Customer intent: As a developer, I want to understand how using the Durable Task SDKs influences my Azure consumption bill.
---

# Durable Task SDKs billing

The Durable Task SDKs are open-source libraries that enable you to build durable, stateful workflows in your applications. The SDKs themselves are free to use and don't incur any direct costs. However, when you deploy applications built with the Durable Task SDKs to Azure, you're billed for the compute resources and the Durable Task Scheduler.

## Compute costs

The Durable Task SDKs are platform-agnostic and can run on various compute platforms. Your billing depends on which hosting option you choose:

| Compute platform | Description |
|---|---|
| **Azure Container Apps** | Serverless container hosting with consumption-based or dedicated pricing. You're billed for vCPU and memory usage. |
| **Azure Kubernetes Service (AKS)** | Managed Kubernetes clusters where you pay for the virtual machines (nodes) in your cluster. |
| **Azure App Service** | Fully managed platform for hosting web applications with various pricing tiers based on features and scale. |

For detailed pricing information, see the billing documentation for each compute service:

- [Azure Container Apps billing](../../container-apps/billing.md)
- [Understand Azure Kubernetes Service costs](/azure/aks/understand-aks-costs)
- [Plan and manage costs for Azure App Service](../../app-service/overview-manage-costs.md)

## Durable Task Scheduler transactions

The [Durable Task Scheduler](durable-task-scheduler/durable-task-scheduler.md) is a purpose-built backend-as-a-service that persists orchestration state for your Durable Task SDK applications. The Durable Task Scheduler offers two pricing models:

| SKU | Description |
| --- | --- |
| **Dedicated** | Fixed monthly cost per Capacity Unit (CU). Each CU supports up to 2,000 actions per second and 50 GB of orchestration data storage. |
| **Consumption (preview)** | Pay-per-use model where you only pay for actions dispatched. Ideal for variable workloads and development scenarios. |

An *action* is a message dispatched by the Durable Task Scheduler to your application, triggering the execution of an orchestrator, activity, or entity function. Actions include starting orchestrations, scheduling activities, completing timers, and processing results.

For detailed pricing information, SKU comparisons, and capacity planning examples, see [Durable Task Scheduler pricing and SKU options](durable-task-scheduler/durable-task-scheduler-dedicated-sku.md).

## Next steps

> [!div class="nextstepaction"]
> [Quickstart: Host a Durable Task SDK app on Azure Container Apps](./durable-task-scheduler/quickstart-container-apps-durable-task-sdk.md)
