---
title: Durable Task SDKs billing
titleSuffix: Durable Task
description: Learn how billing works for applications built with the Durable Task SDKs and the compute services they run on.
author: hhunter-ms
ms.author: hannahhunter
ms.reviewer: azfuncdf
ms.date: 02/06/2026
ms.topic: conceptual
ms.service: azure-functions
ms.subservice: durable
#Customer intent: As a developer, I want to understand how using the Durable Task SDKs influences my Azure consumption bill.
---

# Durable Task SDKs billing

The Durable Task SDKs are open-source libraries that enable you to build durable, stateful workflows in your applications. The SDKs themselves are free to use and don't incur any direct costs. However, when you deploy applications built with the Durable Task SDKs to Azure, you're billed for the compute resources and any backend storage services your application uses.

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

## Storage provider costs

In addition to compute costs, applications built with the Durable Task SDKs require a storage backend to persist orchestration state. If you're using the Durable Task Scheduler as your storage provider, see [Durable Task Scheduler billing](./durable-task-scheduler/durable-task-scheduler-dedicated-sku.md) to understand those costs.

## Next steps

> [!div class="nextstepaction"]
> [Durable Functions billing](durable-functions-billing.md)

> [!div class="nextstepaction"]
> [Quickstart: Host a Durable Task SDK app on Azure Container Apps](./durable-task-scheduler/quickstart-container-apps-durable-task-sdk.md)
