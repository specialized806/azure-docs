---
title: Azure Functions Consumption plan hosting (legacy)
description: Learn about Azure Functions Consumption plan hosting, a legacy serverless hosting option. We recommend the Flex Consumption plan for new serverless function apps.
ms.date: 03/13/2026
ms.topic: concept-article
ms.custom:
  - build-2024
# Customer intent: As a developer, I want to understand the Consumption plan and how to migrate to the Flex Consumption plan.
---

# Azure Functions Consumption plan hosting (legacy)

[!INCLUDE [functions-consumption-legacy-banner](../../includes/functions-consumption-legacy-banner.md)]

When you're using the Consumption plan, instances of the Azure Functions host are dynamically added and removed based on the number of incoming events. 

[!INCLUDE [functions-linux-consumption-retirement](../../includes/functions-linux-consumption-retirement.md)]

The Consumption plan scales automatically, even during periods of high load. When running functions in a Consumption plan, you're charged for compute resources only when your functions are running. On a Consumption plan, a function execution times out after a configurable period of time.

> [!TIP]  
> [!INCLUDE [functions-flex-consumption-recommended-serverless](../../includes/functions-flex-consumption-recommended-serverless.md)]

## Billing

Billing is based on number of executions, execution time, and memory used. Usage is aggregated across all functions within a function app. For more information, see [Azure Functions pricing](https://azure.microsoft.com/pricing/details/functions/).

To learn more about how to estimate costs when running in a Consumption plan, see [Understanding Consumption plan costs](functions-consumption-costs.md).

## Create a legacy Consumption plan function app

> [!TIP]
> For new function apps, consider using the [Flex Consumption plan](flex-consumption-plan.md), which offers faster scaling, virtual network integration, and configurable instance sizes.

When you create a function app in the Azure portal, the Consumption plan is the default. When using APIs to create your function app, you don't have to first create an App Service plan as you do with Premium and Dedicated plans.

In Consumption plan hosting, each function app typically runs in its own plan. In the Azure portal or in code, you might also see the Consumption plan referred to as `Dynamic` or `Y1`.

Use the following links to learn how to create a serverless function app in a Consumption plan, either programmatically or in the Azure portal:

- [Azure CLI](functions-cli-samples.md#create)
- [Azure portal](./functions-get-started.md)
- [Azure Resource Manager template](functions-create-first-function-resource-manager.md)

You can also create function apps in a Consumption plan when you publish a Functions project from [Visual Studio Code](./how-to-create-function-vs-code.md#create-the-function-app-in-azure) or [Visual Studio](functions-create-your-first-function-visual-studio.md#publish-the-project-to-azure).

## Multiple apps in the same plan

The general recommendation is for each function app to have its own Consumption plan. However, if needed, function apps in the same region can be assigned to the same Consumption plan. Keep in mind that there's a [limit to the number of function apps that can run in a Consumption plan](functions-scale.md#service-limits). Function apps in the same plan still scale independently of each other.

## Migrate to Flex Consumption

If you have existing function apps running on the Consumption plan, we recommend that you migrate them to the Flex Consumption plan. The Flex Consumption plan provides faster scaling, reduced cold starts, virtual network integration, and configurable instance sizes. Because the Flex Consumption plan is Linux-only, Windows Consumption plan apps must also migrate to Linux as part of this process. For step-by-step instructions, including Windows-specific guidance, see [Migrate Consumption plan apps to the Flex Consumption plan](migration/migrate-plan-consumption-to-flex.md).

## Next steps

- [Migrate Consumption plan apps to the Flex Consumption plan](migration/migrate-plan-consumption-to-flex.md)
- [Azure Functions hosting options](functions-scale.md)
- [Event-driven scaling in Azure Functions](event-driven-scaling.md)
