---
title: Choose Azure services for enterprise integration
description: Learn which Azure services or features work best for your enterprise integration scenarios, requirements, and solutions.
services: logic-apps
ms.service: azure-logic-apps
ms.suite: integration
author: kewear
ms.author: kewear
ms.reviewer: estfan, azla
ms.topic: concept-article
ms.date: 07/05/2025
# As an integration solutions developer, I want to better understand which capabilities from Azure Integration Services and other Azure services work best for my integration scenarios.
---

# Choose the best services in Azure for modern enterprise integration scenarios

Azure Logic Apps and other Azure Services offers many capabilities across this collection of integration services, but some overlapping capabilities might exist. This guide provides information to help you choose the best services for your enterprise integration scenarios and requirements. Remember also to consider the full impact of using a particular service, including performance requirements, skill set availability, operational support, and costs.

> [!NOTE]
>
> If you're a BizTalk Server customer looking to move your workloads to Azure Logic Apps, 
> you can get a migration overview and compare the capabilities between these two offerings by reviewing 
> [Why migrate from BizTalk Server to Azure Logic Apps?](biztalk-server-to-azure-integration-services-overview.md)

## When to choose a specific integration service and why

| Service | When to choose | Why |
|---------|----------------|-----|
| Azure Logic Apps | You have business processes to orchestrate across multiple systems that span from legacy systems to artificial intelligence workloads. You need to migrate from Microsoft BizTalk Server or other integration platforms. | - Provides greater developer productivity through the low-code workflow designer. <br><br>- Excels at wiring API calls together quickly using prebuilt, out-of-the-box connectors. <br><br>- Supports both synchronous and asynchronous processing. <br><br>- Offers rich debugging history for stateful workflows. <br><br>- Supports stateless workflows for low latency requirements. <br><br>- Supports creating custom APIs and custom connectors, which let you wrap existing REST APIs or SOAP APIs to access services where no prebuilt connector currently exists. (Consumption workflows only) <br><br> - Supports creating custom built-in connectors based on a service provider. (Standard workflows only) | 
| Azure Service Bus | You need a messaging system that supports the publish-subscribe model, ordered delivery, duplicate detection, message scheduling, and message expiration scenarios. As Service Bus is not available on-premises, you should use RabbitMQ or Kafka. | - Provides a fully managed enterprise message broker with message queues and publish-subscribe topics. <br><br>- By decoupling applications and services from each other, this service provides the following benefits: <br><br>--- Load balancing across competing workers <br>--- Safe message routing, data transfer, and control across service and application boundaries <br>--- Coordinated transactional work that requires a high degree of reliability. <br><br>- Complements Azure Logic Apps and supports scenarios where you want to use SDKs, not connectors, to interact with Service Bus entities. |
| Azure Event Grid | You need an event subscription architecture to stay updated on state changes in one or more applications and systems because your integration solutions depend heavily on events to communicate such changes and make any related data changes. | - Provides a highly scalable, serverless event broker for integrating applications using events. Event Grid delivers events to subscriber destinations such as applications, Azure services, or any endpoint where Event Grid has network access. Event sources can include applications, SaaS services, and Azure services. <br><br>- Increases efficiency by avoiding constant polling to determine state changes. As more underlying services emit events, subscription architecture increases in popularity. |
| Azure API Management | You want to abstract and protect your underlying service implementation in Azure Logic Apps from end users and consumers. | - Provides a hybrid, multi-cloud management platform for APIs across all environments. <br><br>- Offers the capability to reuse central services in a secure way, giving your organization more governance and control over who can call enterprise services and how to call them. You can subsequently call these APIs from Azure Logic Apps after your organization catalogs them in Azure API Management. |

## Next steps

You've now learned more about which offerings in Azure Integration Services best suit specific scenarios and needs. If you're considering moving from BizTalk Server to Azure Logic Apps, learn more about migration approaches, planning considerations, and best practices to help with your migration project.

> [!div class="nextstepaction"]
>
> [Migration approaches for BizTalk Server to Azure Logic Apps](biztalk-server-azure-integration-services-migration-approaches.md)
