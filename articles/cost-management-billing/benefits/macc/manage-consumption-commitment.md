---
title: Manage an Azure Consumption Commitment Resource
description: Learn how to manage your Azure Consumption Commitment resource, including moving it across resource groups or subscriptions.
author: dekadays
ms.reviewer: liuyizhu
ms.service: cost-management-billing
ms.subservice: billing
ms.topic: how-to
ms.date: 2/4/2026
ms.author: liuyizhu
ms.custom:
- sfi-image-nochange
- build-2025
#customer intent: As a Microsoft Customer Agreement billing owner, I want to learn about managing an Azure Consumption Commitment so that I can move it when necessary.

service.tree.id: b69a7832-2929-4f60-bf9d-c6784a865ed8
---

# Manage an Azure Consumption Commitment resource under a subscription

When you accept an Azure Consumption Commitment in a Microsoft Customer Agreement, the Azure Consumption Commitment resource is placed in a subscription and a resource group. The resource contains the metadata for the Azure Consumption Commitment. This metadata includes the status of the commitment, commitment amount, start date, end date, and system ID. You can view the metadata in the Azure portal.

:::image type="content" source="../../manage/media/benefits/azure-consumption-commitment/consumption-commitment-overview.png" border="true" alt-text="Screenshot that shows the Azure Consumption Commitment overview pane." lightbox="../../manage/media/benefits/azure-consumption-commitment/consumption-commitment-overview.png" :::

## Move an Azure Consumption Commitment resource across resource groups or subscriptions

You can move an Azure Consumption Commitment resource to another resource group or subscription. Moving it works the same way as moving other Azure resources.

Moving an Azure Consumption Commitment resource to another subscription or resource group is a metadata change. The move doesn't affect the commitment. The destination resource group or subscription must be within the same billing profile that contains the Azure Consumption Commitment.

### Move an Azure Consumption Commitment resource

Here are the high-level steps to move an Azure Consumption Commitment resource. For more information about moving an Azure resource, see [Move Azure resources to a new resource group or subscription](../../../azure-resource-manager/management/move-resource-group-and-subscription.md).

1. In the [Azure portal](https://portal.azure.com), go to **Resource groups**.

2. Select the resource group that contains the Azure Consumption Commitment resource.

3. Select the resource.

4. At the top of the pane, select **Move**, and then select **Move to another subscription** or **Move to another resource group**.

5. Follow the instructions to move the resource.

6. After the move is complete, verify that the resource is in the new resource group or subscription.

After an Azure Consumption Commitment resource moves, its URI changes to reflect the new location.

### View the Azure Consumption Commitment resource URI

1. In the [Azure portal](https://portal.azure.com), enter **Azure Consumption Commitments** in the search box.

2. Under **Services**, select **Microsoft Azure Consumption Commitments**.

3. Select the Azure Consumption Commitment resource.

4. On the left pane, expand **Settings**, and then select **Properties**.

5. The Azure Consumption Commitment resource URI is the **Id** value.

:::image type="content" source="../../manage/media/benefits/azure-consumption-commitment/consumption-commitment-uri.png" border="true" alt-text="Screenshot that shows an example Azure Consumption Commitment resource URI on the Properties pane." lightbox="../../manage/media/benefits/azure-consumption-commitment/consumption-commitment-uri.png" :::

## Rename an Azure Consumption Commitment resource

The name of an Azure Consumption Commitment resource is part of its URI and can't be changed. However, you can use [tags](../../../azure-resource-manager/management/tag-resources.md) to help identify the Azure Consumption Commitment resource based on a nomenclature that's relevant to your organization.

## Delete an Azure Consumption Commitment resource

You can delete an Azure Consumption Commitment resource only if its status is **Failed** or **Canceled**. Deletion of an Azure Consumption Commitment resource is a permanent action and can't be undone.  

## Cancel an Azure Consumption Commitment

If you have questions about canceling your Azure Consumption Commitment, contact your Microsoft account team.

## Track your Azure Consumption Commitment

If your organization has an Azure Consumption Commitment associated with a Microsoft Customer Agreement or Enterprise Agreement billing account, you can track key details through the Azure portal or REST APIs. These details include start and end dates, remaining balance, and eligible spending. For more information, see [Track your Azure Consumption Commitment](track-consumption-commitment.md).

### View Azure Consumption Commitment milestones

If your Azure Consumption Commitment includes milestones, you can view milestone details in the Azure portal. Go to your Azure Consumption Commitment resource and select the **Milestones** tab. For more information about milestones, see [Azure Consumption Commitment milestones](track-consumption-commitment.md#azure-consumption-commitment-milestones).

The **Milestones** tab displays the following information for each milestone:

- **End Date**: Deadline for reaching the milestone commitment amount.
- **Commitment amount**: Amount that needs to be consumed by the end date.
- **Status**: Current status of the milestone (such as **Active**, **Completed**, or **Failed**).
- **Automatic Shortfall**: Indicator of whether automatic shortfall is applicable for the milestone.
- **Shortfall Amount**: Any shortfall amount if the commitment isn't met (appears when applicable).

:::image type="content" source="../../manage/media/benefits/azure-consumption-commitment/manage-consumption-commitment-milestones.png" border="true" alt-text="Screenshot that shows Azure Consumption Commitment milestones and progress tracking." lightbox="../../manage/media/benefits/azure-consumption-commitment/manage-consumption-commitment-milestones.png" :::

## Related content

- [Track your Azure Consumption Commitment](track-consumption-commitment.md)
- [Move Azure resources to a new resource group or subscription](../../../azure-resource-manager/management/move-resource-group-and-subscription.md)
