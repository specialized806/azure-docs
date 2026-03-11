---
title: Azure Functions Consumption plan hosting
description: Learn about how Azure Functions Consumption plan hosting lets you run your code in an environment that scales dynamically.
ms.date: 09/23/2025
ms.topic: concept-article
ms.custom:
  - build-2024
# Customer intent: As a developer, I want to understand the benefits of using the Consumption plan so I can get the scalability benefits of Azure Functions without having to pay for resources I don't need.
---

# Azure Functions Consumption plan hosting

When you're using the Consumption plan, instances of the Azure Functions host are dynamically added and removed based on the number of incoming events. 

[!INCLUDE [functions-linux-consumption-retirement](../../includes/functions-linux-consumption-retirement.md)]
The Consumption plan scales automatically in response to demand. With this plan, you're billed only for the compute resources used while your functions are running, and function execution times out after a configurable period.

> [!TIP]  
> [!INCLUDE [functions-flex-consumption-recommended-serverless](../../includes/functions-flex-consumption-recommended-serverless.md)]

## Billing

Billing is based on number of executions, execution time, and memory used. Usage is aggregated across all functions within a function app. For more information, see [Azure Functions pricing](https://azure.microsoft.com/pricing/details/functions/).

To learn more about how to estimate costs when running in a Consumption plan, see [Understanding Consumption plan costs](functions-consumption-costs.md).

## Multiple apps in the same plan

The general recommendation is for each function app to have its own Consumption plan. However, if needed, function apps in the same region can be assigned to the same Consumption plan. Keep in mind that there's a [limit to the number of function apps that can run in a Consumption plan](functions-scale.md#service-limits). Function apps in the same plan still scale independently of each other.

## Next steps

- [Azure Functions hosting options](functions-scale.md)
- [Event-driven scaling in Azure Functions](event-driven-scaling.md)
