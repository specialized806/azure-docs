---
title: Billing Benefits Overview
description: Quick primer to learn how about the different types of billing benefits offered by Microsoft 
author: benshy
ms.reviewer: benshy
ms.service: cost-management-billing
ms.subservice: billing
ms.topic: how-to
ms.date: 01/08/2026
ms.author: benshy
#customer intent: As a Microsoft Customer Agreement billing owner, I want to learn about the different types billing benefits offered 
service.tree.id: cf90d1aa-e8ca-47a9-a6d0-bc69c7db1d52
---

# Billing Benefits Overview

Billing benefits are a set of Azure capabilities that provide customers with financial advantages such as discounted prices, credits, and long-term cost optimization options. These benefits help organizations reduce cloud spend, plan capacity confidently, and align purchasing with business needs.

Azure models billing benefits as **Azure Resource Manager (ARM) resources**, enabling consistent lifecycle management across the Azure portal, APIs, and SDKs. For more information, see: [What is a cloud subscription?](../../cost-management-billing/manage/cloud-subscription.md)

***

## What Are Billing Benefits?

A *billing benefit* is any offer that changes the effective cost of using Azure services. These benefits typically fall into one of four categories:

### 1. Commitments

Long-term agreements where customers commit to spending a certain amount or using certain resource types in exchange for lower prices or optimized billing.  

Examples:

*   [Microsoft Azure Consumption Commitment (MACC)](../../marketplace/azure-consumption-commitment-benefit.md#determine-which-offers-are-eligible-for-azure-consumption-commitments-maccctc)
*   [Reservations](../reservations/save-compute-costs-reservations.md)
*   [Savings plan](../savings-plan/savings-plan-compute-overview.md)
*   Commitment-based spend programs

### 2. Credits

Credits act like a monetary balance applied toward applicable Azure usage.  
Examples:

*   Promotional credits
*   Azure Credit Offers (ACO)
*   Other credit-based incentives

Credits are applied before invoices are generated.


### 3. Discounts

Discounts reduce the purchase price or usage charges of eligible Azure resources. Azure also applies certain discounts—such as commitment-based reductions—during charge rating.

> **Note:** Credits are applied like a gift card or other payment instrument before the invoice is generated. While credit status is tracked as new charges flow into the data pipeline, credits aren't explicitly applied to these charges until the end of the month.

### 4. Free Azure Services

Azure provides a comprehensive set of free services to help you explore, build, and test solutions at no cost. These benefits include:

* $200 credit for 30 days (new customers only)
* 12-months of free usage for a curated set of popular services
* 65+ services that are Always Free, with monthly usage limits

Azure’s free services are designed to reduce the barrier to entry, support experimentation, and help new customers get started with cloud development safely and cost-effectively.  

For more information, see: [Create Your Azure Free Account Or Pay As You Go](https://azure.microsoft.com/en-us/pricing/purchase-options/azure-account)

***

## Managing Billing Benefits in Azure

Billing benefits can be viewed and managed through multiple supported interfaces:

### Azure Portal

Customers can view and manage billing benefits—including credits and discounts—in dedicated experiences within **Cost Management + Billing** and dedicated **Credits**, **Discounts**, and **Microsoft Azure Consumption Commitments** service views. The portal views summarize benefit metadata, balance (for credits), and usage impact.

### Azure Resource Manager (ARM)

Most billing benefit types are implemented as ARM resource types under the Microsoft.BillingBenefits provider.  
Examples:

*   `Microsoft.BillingBenefits/discounts`
*   `Microsoft.BillingBenefits/credits`
*   `Microsoft.BillingBenefits/savingsPlanOrders/savingsPlans`

### REST APIs

Developers can programmatically interact with billing benefits using the **Azure Billing Benefits REST API**, which provides operations for managing benefits such as savings plans and discount-related resources.

### SDKs & CLI

Azure SDKs (.NET, Python, JavaScript) and the Azure CLI (`az billingbenefits`) support reading or managing billing benefits programmatically.  

See: [Azure PowerShell Billing Benefits Module](../../../powershell/module/az.billingbenefits/)

***

## Why Billing Benefits Matter

Billing benefits help organizations:

*   **Optimize cloud spend** by leveraging the right mix of discounts, credits, and commitments.
*   **Improve cost predictability** by aligning long-term commitments with planned usage.
*   **Centralize management** with ARM-based resources, enabling consistent RBAC, activity logs, tagging, and automation.

***

## Common Scenarios

*   **Verify costs reflect the discounted price:**  
    A negotiated Azure discount reduces rates applied to eligible usage during billing. The discount appears as an ARM resource and is also reflected in the price sheet and invoice. You can utilize the discount information displayed on the discount resource to verify applicability of the discount on your price sheet or downloaded usage.

*   **Track credit usage:**  
    Promotional or commitment credits are consumed automatically as new usage is rated, and customers track credit burndown in the portal.

*   **Manage long-term commitments:**  
    Customers with enterprise agreements or cloud spend commitments can monitor fulfillment and benefit application in Cost Management and through the corresponding billing benefit resources.

***

## Related Documentation

*   [What are Azure Reservations?](../reservations/save-compute-costs-reservations.md)
*   [What is Azure savings plans for compute?](../savings-plan/savings-plan-compute-overview.md)
*   [Azure Consumption Commitment Benefit](../../marketplace/azure-consumption-commitment-benefit.md#determine-which-offers-are-eligible-for-azure-consumption-commitments-maccctc)
*   [Azure Billing Benefits REST API](../../rest/api/billingbenefits/)
*   [Resource Provider: Microsoft.BillingBenefits (ARM reference)](../../../azure/templates/microsoft.billingbenefits/allversions)

***

