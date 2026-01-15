---
title: Network Security Perimeter
titleSuffix: Azure Service Bus
description: Overview of Network Security Perimeter feature for Service Bus
ms.reviewer: spelluru
ms.date: 01/15/2026
author: EldertGrootenboer
ms.author: egrootenboer
ms.topic: conceptual
ms.custom:
---


# Network Security Perimeter for Azure Service Bus

[Azure Service Bus](./service-bus-messaging-overview.md) supports integration with [Network Security Perimeter](../private-link/network-security-perimeter-concepts.md).

The Network Security Perimeter safeguards network traffic between Azure Service Bus and other Platform as a Service (PaaS) offerings like Azure Key Vault. By confining communication solely to Azure resources within its boundaries, it blocks unauthorized attempts to access resources beyond its secure perimeter.

Integrating Service Bus within this framework enhances messaging capabilities while ensuring robust security measures. This integration not only provides a reliable and scalable platform but also strengthens data protection strategies, mitigating risks associated with unauthorized access or data breaches.

Operating as a service under Azure Private Link, the Network Security Perimeter facilitates secure communication for PaaS services deployed outside the virtual network. It enables seamless interaction among PaaS services within the perimeter and facilitates communication with external resources through carefully configured access rules. Additionally, it supports outbound resources such as Azure Key Vault for customer-managed keys (CMK), further enhancing its versatility and utility in diverse cloud environments.

> [!NOTE]
> Network Security Perimeter doesn't support [Azure Service Bus Geo-Replication](./service-bus-geo-replication.md).

## Associate Service Bus with a Network Security Perimeter in the Azure portal
1. Search for "Network Security Perimeter" in the portal search bar. Select **Create** to create the resource.
1. Enter a name and region, and choose the subscription.
1. Under the **Resources** section, select **Associate**. Navigate to the Service Bus namespace you want to add. 

## Related content
- For an overview of [Network Security Perimeter](../private-link/network-security-perimeter-concepts.md)
- For monitoring with [diagnostic logs in Network Security Perimeter](../private-link/network-security-perimeter-diagnostic-logs.md)
- For other Service Bus security features, see [Network security for Azure Service Bus](./network-security.md)
- For additional information on using private endpoints, see [Allow access to Azure Service Bus namespaces via private endpoints](./private-link-service.md)
