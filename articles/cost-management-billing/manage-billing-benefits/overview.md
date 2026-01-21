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

Billing benefits are a set of offers - such as discounts, credits, and cost-optimizing commitments that provide customers with financial advantages. These billing benefits can help customers reduce spend, plan capacity confidently, and align purchasing with business needs

Azure models billing benefits as **Azure Resource Manager (ARM) resources**, enabling consistent lifecycle management across the Azure portal, APIs, and SDKs. For more information, see: [What is a cloud subscription?](../../cost-management-billing/manage/cloud-subscription.md)

***

## What Are Billing Benefits?

A *billing benefit* is any offer that changes the effective cost associated with service usage or purchases. These benefits typically fall into one of four categories:


### 1. Commitments

Long-term agreements where customers commit to spending a certain amount or using certain resource types in exchange for lower prices or optimized billing.  

Examples:

*   [Microsoft Azure Consumption Commitment (MACC)](../../marketplace/azure-consumption-commitment-benefit.md#determine-which-offers-are-eligible-for-azure-consumption-commitments-maccctc)
*   [Reservations](../reservations/save-compute-costs-reservations.md)
*   [Savings plan](../savings-plan/savings-plan-compute-overview.md)


### 2. Credits

Credits act like a monetary balance applied toward applicable Azure usage.  

Examples:

*   Promotional credits
*   [Azure Credit Offers (ACO)](credits/mca-check-azure-credits-balance.md)
*   Other credit-based incentives


### 3. Discounts

Discounts lower the purchase price or usage charges of eligible resources. Certain discounts, such as commitment-based reductions, are also applied during charge rating 


### 4. Free Azure Services

Azure provides a selection of free services each month, enabling the ability to explore, develop, and test solutions without incurring any charges.

For more information, see: [Create Your Azure Free Account Or Pay As You Go](https://azure.microsoft.com/pricing/purchase-options/azure-account)

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

See: [Azure PowerShell Billing Benefits Module](https://learn.microsoft.com/powershell/module/az.billingbenefits/)

***

## Related Documentation

*   [What are Azure Reservations?](../reservations/save-compute-costs-reservations.md)
*   [What is Azure savings plans for compute?](../savings-plan/savings-plan-compute-overview.md)
*   [Azure Consumption Commitment Benefit](../../marketplace/azure-consumption-commitment-benefit.md#determine-which-offers-are-eligible-for-azure-consumption-commitments-maccctc)
*   [Azure Billing Benefits REST API](https://learn.microsoft.com/rest/api/billingbenefits/operation-groups)
*   [Resource Provider: Microsoft.BillingBenefits (ARM reference)](https://learn.microsoft.com/azure/templates/microsoft.billingbenefits/allversions)


***

