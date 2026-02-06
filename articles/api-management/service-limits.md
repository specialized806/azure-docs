---
title: Understanding Azure API Management Service Limits
description: Learn about service limits in Azure API Management, including their purpose, how they're enforced, and guidelines for managing your service.
author: dlepow
ms.service: azure-api-management
ms.topic: concept-article
ms.date: 02/06/2026
ms.author: danlep
ai-usage: ai-assisted
---

# Understanding Azure API Management service limits

Azure API Management enforces various [limits on resources](/azure/azure-resource-manager/management/azure-subscription-service-limits?toc=%2Fazure%2Fapi-management%2Ftoc.json&bc=%2Fazure%2Fapi-management%2Fbreadcrumb%2Ftoc.json#azure-api-management-limits) such as API operations and other entities. This article explains why these limits exist and how to use the service effectively within these constraints. 

## Why are there service limits?

Azure API Management, like all Azure services, operates on physical infrastructure with finite resources. While Azure provides tremendous scalability and flexibility, the underlying hardware and system architecture have inherent constraints. To ensure reliable performance for all customers, the service manages these constraints.

The service limits in Azure API Management aren't arbitrary constraints. They're calibrated based on:

* Azure platform capacity and performance characteristics
* Service tier capabilities
* Typical customer usage patterns

Resource limits are interrelated and tuned to work together. They prevent any single aspect of the service from disrupting the overall performance of the service.

## Changes to service limits - 2026 update

Azure API Management is phasing in updated resource limits for instances across all tiers. These updates align with each tier's capabilities and help customers choose the right option for their needs.

[!INCLUDE [api-management-service-limits](../../includes/api-management-service-limits.md)]

### What's changing

* Limits in the classic tiers now align with those set in the v2 tiers.
* Limits are defined and enforced for a smaller set of resource types that are directly related to service capacity and performance, such as API operations, tags, products, and subscriptions.

### Rollout process

New limits roll out in a phased approach starting in March 2026 in the Developer, Basic, and Basic v2 tiers, followed later by the Standard, Standard v2, Premium, and Premium v2 tiers. 

### Limits policy for existing classic tier customers

After the new limits take effect, you can continue using your pre-existing API Management resources without interruption. This means:

* Existing classic tier services, where current usage exceeds the new limits, are "grandfathered" when the new limits are introduced. You can continue using these resources at the previous limits. (Customers in the v2 tiers are already subject to the new limits, so no grandfathering is needed for those services.) 
* Grandfathered limits will be set to 10% higher than the customer's current observed usage at the time limits take effect. 
* Grandfathering applies per service and service tier at the time these limits take effect.
* Other existing services and new services are subject to the new limits when they take effect. 

## Strategies to manage resources

If you're approaching or reaching certain resource limits, you might notice impacts such as being unable to create new resources or update existing ones. In some cases, you might also experience degraded performance in some service operations.

Consider the following strategies to manage your resources effectively in these cases.

### Improve resource management

* Implement a regular cleanup process for unused resources.
* Use tags effectively to identify resources that you can consolidate or remove.
* Review [capacity metrics](api-management-capacity.md) to understand resource utilization and identify potential bottlenecks.

### Optimize API and operation organization

When counting the number of API-related resources (such as API operations and tags), API Management also includes API versions and revisions. Consider the following strategies when approaching limits for these resources:

* Remove unused API versions or revisions.
* Consolidate or remove operations where appropriate.
* Use API versions and revisions strategically.

### Evaluate your service tier

If you consistently reach resource limits, evaluate your current service tier. Certain limits, such as those for API operations, vary by service tier.

* Consider options to add units or upgrade your tier. 
* Consider deploying an additional API Management instance in the current tier.

To evaluate the potential costs associated with these options, see [Azure API Management pricing](https://azure.microsoft.com/pricing/details/api-management/).

## Guidelines for limit increases

In some cases, you might want to request an increase to certain service limits. Before doing so, note the following guidelines:

* Explore strategies to address the issue proactively before requesting a limit increase. For more information, see the preceding [Strategies to manage resources](#strategies-to-manage-resources).

* Consider potential impacts of the limit increase on overall service performance and stability. Increasing a limit might affect your service's capacity or cause increased latency in some service operations.

### Requesting a limit increase

The product team considers requests for limit increases only for customers using services in the following tiers that are designed for medium to large production workloads:

* Standard and Standard v2
* Premium and Premium v2

Requests for limit increases are evaluated on a case-by-case basis and aren't guaranteed. The product team prioritizes Premium and Premium v2 tier customers for limit increases.

To request a limit increase, create a support request from the Azure portal. For more information, see [Azure support plans](https://azure.microsoft.com/support/).


## Related content

* [Capacity of an API Management instance](api-management-capacity.md)
* [Upgrade and scale an API Management instance](upgrade-and-scale.md)
