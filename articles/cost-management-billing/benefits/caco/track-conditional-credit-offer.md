---
title: Track Your Conditional Azure Credit Offer
description: Learn how to track your Conditional Azure Credit Offer for a Microsoft Customer Agreement.
author: shrutis06
ms.reviewer: shrshett
ms.service: cost-management-billing
ms.subservice: billing
ms.topic: how-to
ms.date: 02/23/2026
ms.author: shrshett
ms.custom: sfi-image-nochange
---

# Track your Conditional Azure Credit Offer

A Conditional Azure Credit Offer is a contractual agreement in which your organization commits to specific, predefined spending targets within set time periods and receives Azure credits for meeting these targets. A Conditional Azure Credit Offer is composed of multiple milestones with specific spending targets and an associated Azure Credit Offer award at the end of each milestone, allowing your organization to align rewards with your consumption patterns and business goals.

## Prerequisites

To view Conditional Azure Credit Offer details, you must have any of the following roles:

- **Billing Account Access**. Owner, Contributor, or Reader role on the Microsoft Customer Agreement billing account
- **Subscription Access**. Owner, Contributor, or Reader role on the subscription where the Conditional Azure Credit Offer resource is created

> [!NOTE]
> You only need permissions at one of these levels to view Conditional Azure Credit Offer details and track milestone progress.

## Track your Conditional Azure Credit Offer commitment

### [Azure portal](#tab/portal)

1. Sign in to the [Azure portal](https://portal.azure.com).

2. Search for **Cost Management + Billing**.

    :::image type="content" source="../../manage/media/conditional-credit-offer/cost-management-billing-search.png" alt-text="Screenshot showing search in portal for Cost Management + Billing." lightbox="../../manage/media/conditional-credit-offer/cost-management-billing-search.png" :::

3. In the billing scopes page, select the billing account for which you want to track the commitment.

    :::image type="content" source="../../manage/media/conditional-credit-offer/billing-scopes-list.png" alt-text="Screenshot that shows Billing Scopes." lightbox="../../manage/media/conditional-credit-offer/billing-scopes-list.png" :::

4. Select **Benefits** from the left-hand side and then select the **Conditional Azure Credit Offer (CACO)** tile.  

    :::image type="content" source="../../manage/media/conditional-credit-offer/benefits-page.png" alt-text="Screenshot that shows selecting the Conditional Azure Credit Offer tab for a Microsoft Customer Agreement." lightbox="../../manage/media/conditional-credit-offer/benefits-page.png" :::

## Conditional Azure Credit Offer page overview

The **Conditional Azure Credit Offer (CACO)** tab has the following sections.

### Overall commitment

:::image type="content" source="../../manage/media/conditional-credit-offer/conditional-credit-offer-page.png" alt-text="Screenshot of the Conditional Azure Credit Offer page." lightbox="../../manage/media/conditional-credit-offer/conditional-credit-offer-page.png" :::

The overall commitment displays the total commitment amount for your Conditional Azure Credit Offer, across milestones.

### Details

The Details section displays other important aspects of your commitment.

| Term | Definition |
| ---- | ---------- |
| ID | An identifier that uniquely identifies your Conditional Azure Credit Offer. |
| Start date | The date when the commitment becomes effective. |
| End date | The date when the commitment expires, which is the end date of the last milestone. |
| Commitment amount | The aggregated amount you commit to spend on Conditional Azure Credit Offer-eligible products/services across milestones. |
| Status | The status of your commitment. |

Your Conditional Azure Credit Offer can have one of the following statuses:

- **Scheduled:** The Conditional Azure Credit Offer has a future start date and isn't yet active. No eligible Azure spending contributes toward your commitment until the start date is reached.
- **Active:** The Conditional Azure Credit Offer is currently in effect. Eligible Azure spending contributes toward fulfilling your commitment.
- **Completed:** The Conditional Azure Credit Offer commitment amount is fully met. No further action is required.
- **Expired:** The Conditional Azure Credit Offer end date passes without the commitment being fully met. Contact your Microsoft Account team for more information.
- **Canceled:** The Conditional Azure Credit Offer is terminated before the end date. New Azure spending doesn't contribute toward your Conditional Azure Credit Offer commitment. Contact your Microsoft Account team for more information.

### Upcoming Milestone

The Upcoming Milestone section displays the next milestone that needs to be achieved to earn the associated Azure Credit Offer award.

| Term | Definition |
| --- | ----------- |
| Start Date | The date when the milestone period begins |
| End Date | The date by which the milestone must be met |
| Consumption target | The spending amount required to achieve this milestone |
| Target ACO | The Azure Credit Offer award amount you receive for meeting this milestone |
| Status | Whether the milestone is active, pending, met, or missed |

You can select **Show all Milestones** to view the complete list of milestones for your Conditional Azure Credit Offer commitment.

### Transactions

This section displays transactions that decremented your Conditional Azure Credit Offer commitment.

| Term | Definition |
| --- | ----------- |
| Date | The date when the event happened |
| Description | A description of the event |
| Billing profile | The billing profile for which the event happened. The billing profile only applies to Microsoft Customer Agreements. |
| CACO decrement | The amount of Conditional Azure Credit Offer decrement from the event |
| Remaining commitment | The remaining Conditional Azure Credit Offer commitment after the event |

## Conditional Azure Credit Offer milestones

Every Conditional Azure Credit Offer offer consists of one or many milestones with a target amount, date, and corresponding credit award for meeting the milestone amount.

- **Met milestone:** If you meet a milestone by its due date, you receive the corresponding Azure Credit Offer award associated with that milestone.
- **Missed milestone:** If you don't meet a milestone by its due date, the system forfeits the Azure Credit Offer award corresponding to that milestone.

### All Milestones

When you select **Show all Milestones**, you can view a comprehensive list of all milestones associated with your Conditional Azure Credit Offer commitment. This view provides detailed information about each milestone's progress and status.

:::image type="content" source="../../manage/media/conditional-credit-offer/conditional-credit-offer-milestones.png" alt-text="Screenshot of all Conditional Azure Credit Offer milestones." lightbox="../../manage/media/conditional-credit-offer/conditional-credit-offer-milestones.png" :::

| Column | Definition |
| ------ | ---------- |
| ID | The unique identifier for each milestone (for example, Milestone1, Milestone2, Milestone3) |
| End Date | The deadline by which the milestone must be achieved |
| Consumption target | The total spending amount required to meet this milestone |
| Progress% | The current progress percentage toward achieving the milestone consumption target |
| ACO award | The Azure Credit Offer amount you receive if the milestone is met |
| Status | The current status of the milestone |

The milestone statuses are:

| Status | Description |
| ------ | ----------- |
| Scheduled | The milestone has a future start date and isn't yet active. |
| Active | The milestone is currently in progress and eligible Azure spending contributes toward fulfilling the milestone target. |
| Pending | The milestone is pending evaluation. |
| Completed | The milestone target is successfully met within the specified timeframe and the system grants the associated Azure Credit Offer award. |
| Missed | The milestone deadline passes without meeting the consumption target. The system forfeits the Azure Credit Offer award corresponding to this milestone. |
| Canceled | The system cancels the milestone before completion. This situation may occur when you modify or terminate the overall Conditional Azure Credit Offer commitment. |
| Removed | The system removes the milestone from the Conditional Azure Credit Offer commitment. This status typically occurs when you renegotiate commitment terms. |

## Conditional Azure Credit Offer alerts

Microsoft sends email notifications to Billing Account Admins to help ensure Conditional Azure Credit Offer commitments and milestones are met on time to receive Azure Credit Offer awards. These alerts provide advance notice so you can take action before forfeiting Azure Credit Offer awards.

### Conditional Azure Credit Offer expiry alerts

If your Conditional Azure Credit Offer target isn't reached, email notifications are sent to Billing Account Admins at the following intervals before the Conditional Azure Credit Offer end date:

- 90 days before expiry
- 60 days before expiry
- 30 days before expiry

### Milestone alerts

Email alerts are sent to Billing Account Admins at the following intervals before each milestone due date if the milestone target isn't met:

- 90 days before milestone due date
- 60 days before milestone due date
- 30 days before milestone due date

---

## Azure services eligible for a Conditional Azure Credit Offer

Conditional Azure Credit Offer spending eligibility differs from traditional Azure Consumption Commitment in several key areas. The following table outlines which Azure services and purchases are eligible for tracking Conditional Azure Credit Offer spending:

| Service/Purchase type | Conditional Azure Credit Offer eligibility | Azure Consumption Commitment eligibility | Notes |
| --------------------- | ---------------- | ---------------- | ----- |
| **All consumption pay-as-you-go charges** | ✅ | ✅ | Standard consumption charges count toward Conditional Azure Credit Offer milestones |
| **Azure 1st party entitlement purchases (Reserved Instances/Azure Savings Plans)** | | | |
| - Upfront/Monthly Billing | ✅ | ✅ | Initial purchase or monthly payments count toward milestones |
| - Monthly Usage | ❌ | ❌ | Usage covered by these purchases doesn't count |
| **Azure Pre-payments (Monetary Credits)** | | | |
| - Purchase | ❌ | ✅ | **Key Difference**: Conditional Azure Credit Offer doesn't count prepayment purchases |
| - Prepayment Spend | ✅ | ❌ | **Key Difference**: Conditional Azure Credit Offer counts spending of prepayment credits |
| **MACC Milestone Shortfall Credit** | | | |
| - Purchase | ❌ | ✅ | Milestone shortfall credit purchase doesn't count toward Conditional Azure Credit Offer |
| - Credit Applied | ✅ | ❌ | Milestone shortfall credit use goes toward Conditional Azure Credit Offer |
| **MACC Shortfall Charge (Credit)** | | | |
| - Purchase | ❌ | ✅ | Azure Consumption Commitment shortfall credit purchase doesn't count toward Conditional Azure Credit Offer |
| - Credit Applied | ❌ | ❌ | Azure Consumption Commitment shortfall credit use doesn't go toward Conditional Azure Credit Offer as it's the penalty charge for not fulfilling Azure Consumption Commitment commitment |
| **Awarded Credits (ACO, Outage, Goodwill)** | | | |
| - Awarded Amount | ❌ | ❌ | Any credits that aren't purchased don't count toward commitments |
| - Credit Applied | ❌ | ❌ | Consumption covered by awarded credits doesn't count |
| **Azure Marketplace** | ❌ | ✅ | **Key Difference**: Marketplace purchases don't count toward Conditional Azure Credit Offer milestones |

### Key differences from Azure Consumption Commitment

Conditional Azure Credit Offer focuses on actual consumption rather than purchases:

- **Azure Prepayments**: Unlike Azure Consumption Commitment where prepayment purchases count toward commitment but prepayment spending doesn't, Conditional Azure Credit Offer operates on the opposite principle - prepayment purchases don't count toward milestones, but spending those prepayment credits does count toward your Conditional Azure Credit Offer commitment
- **Marketplace purchases**: Not eligible for Conditional Azure Credit Offer milestone tracking (unlike Azure Consumption Commitment)

This consumption-focused approach ensures that ACO awards are based on genuine Azure service consumption rather than upfront credit purchases, regardless of the payment method used to cover that consumption.

## Contact support

If you need help, [contact support](https://portal.azure.com/?#blade/Microsoft_Azure_Support/HelpAndSupportBlade) to get your issue resolved quickly.
