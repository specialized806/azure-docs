---
title: Client functions in Azure Durable
description: Learn about client functions in Azure Durable and how to use the durable client output binding to trigger an event.
author: hhunter-ms
ms.author: hannahhunter
ms.reviewer: azfuncdf
ms.date: 12/02/2025
ms.topic: concept-article
ms.service: azure-functions
ms.subservice: durable
---

# Client functions in Azure Durable

Holder text:
Orchestrator functions are triggered by an orchestration trigger binding and entity functions are triggered by an entity trigger binding. Both of these triggers work by reacting to messages that are enqueued into a task hub. The primary way to deliver these messages is by using an orchestrator client binding or an entity client binding from within a client function. Any non-orchestrator function can be a client function. For example, You can trigger the orchestrator from an HTTP-triggered function, an Azure Event Hub triggered function, etc. What makes a function a client function is its use of the durable client output binding.

## Next steps
