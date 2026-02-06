---
title: Durable Functions billing
titleSuffix: Durable Task
description: Learn about the internal behaviors of Durable Functions and how they affect billing for Azure Functions.
author: cgillum
reviewer: hhunter-ms
ms.topic: conceptual
ms.date: 01/14/2026
ms.author: azfuncdf
ms.service: azure-functions
ms.subservice: durable
#Customer intent: As a developer, I want to understand how using Durable Functions influences my Azure consumption bill.
---

# Durable Functions billing

Although [Durable Functions](durable-functions-overview.md) follows the same billing model as [Azure Functions](https://azure.microsoft.com/pricing/details/functions/), you need to be aware of some specific billing behaviors when executing orchestrator functions in the Azure Functions [Consumption plan](../consumption-plan.md).

## Orchestrator function replay billing

[Orchestrator functions](durable-functions-orchestrations.md) might replay several times throughout an orchestration's lifetime. The Azure Functions runtime views each replay as a distinct function invocation. For this reason, when you use the Azure Functions Consumption plan, you're billed for each replay of an orchestrator function. Other plan types don't charge for orchestrator function replay.

## Awaiting and yielding in orchestrator functions

When your orchestrator function waits for an asynchronous task to complete, the runtime considers that particular function invocation finished. The billing for your orchestrator function stops at that point. It doesn't resume until the next orchestrator function replay. You aren't billed for any time spent awaiting or yielding in an orchestrator function.

> [!NOTE]
> Some consider functions calling other functions to be a serverless anti-pattern because of a problem known as *double billing*. When a function calls another function directly, both run at the same time. The called function is actively running code while the calling function waits for a response. In this case, you pay for the time the calling function spends waiting for the called function to run.
>
> Orchestrator functions don't have double billing. An orchestrator function's billing stops while it waits for the result of an activity function or suborchestration.

## Durable HTTP polling

Orchestrator functions can make long-running HTTP calls to external endpoints. The *"call HTTP"* APIs might [internally poll an HTTP endpoint](durable-functions-http-features.md) while following the [asynchronous 202 pattern](durable-functions-http-features.md#http-202-handling). 

You currently aren't directly billed for internal HTTP polling operations. However, internal polling might cause your orchestrator function to periodically replay. You're billed standard charges for these internal function replays.

## Azure Storage transactions

By default, Durable Functions uses Azure Storage to keep state persistent, process messages, and manage partitions via blob leases. Since you own this storage account, any transaction costs are billed to your Azure subscription. For more information about the Azure Storage artifacts used by Durable Functions, see the [Task hubs article](durable-functions-task-hubs.md).

Several factors contribute to the actual Azure Storage costs your Durable Functions app incurs:

- A single function app is associated with a single task hub, which shares a set of Azure Storage resources. All Durable Functions in your function app use these resources. The actual number of functions in the function app has no effect on Azure Storage transaction costs.
- Each function app instance internally polls multiple queues in the storage account using an exponential-backoff polling algorithm. An idle app instance polls the queues less often than an active app, which results in fewer transaction costs. [Learn more about Durable Functions queue-polling behavior when using the Azure Storage provider](durable-functions-azure-storage-provider.md#queue-polling).
- When you run in the Azure Functions Consumption or Premium plans, the [Azure Functions scale controller](../event-driven-scaling.md) regularly polls all task-hub queues in the background. If your function app is under light to moderate scale, only a single scale controller instance polls these queues. If your function app scales out to a large number of instances, more scale controller instances might be added. These additional scale controller instances can increase the total queue-transaction costs.
- Each function app instance competes for a set of blob leases. These instances periodically make calls to the Azure Blob service either to renew held leases or to attempt to acquire new leases. The task hub's configured partition count determines the number of blob leases. Scaling out to a larger number of function app instances likely increases the Azure Storage transaction costs associated with these lease operations.

## Next steps

> [!div class="nextstepaction"]
> [Learn more about Azure Functions pricing](https://azure.microsoft.com/pricing/details/functions/)
