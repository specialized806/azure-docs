---
title: Enable Marketplace Purchases in Azure
description: This article shows you how to enable marketplace private offer purchases.
author: echung
ms.reviewer: echung
ms.service: cost-management-billing
ms.subservice: microsoft-customer-agreement
ms.topic: conceptual
ms.date: 01/22/2025
ms.author: nicholak
ms.custom: sfi-ga-nochange
---

# Enable marketplace purchases in Azure

You can use the Azure portal to buy non-Microsoft software to use with Azure in the Microsoft commercial marketplace.

To use the marketplace, you need to set up and configure marketplace policy settings. Then, you assign the required user access permissions to billing accounts and subscriptions.

This article explains how to set up and enable marketplace purchases, and specifically how to enable marketplace private offer purchases.

To enable marketplace private offer purchase, first:

1. Enable Azure Marketplace in the Azure portal.
1. Set user permissions to allow individuals to make Marketplace purchases.
1. Set user permissions to allow individuals to accept Marketplace private offers.
1. Optionally, if you have private marketplace enabled, then you can enable private offer purchases in the private marketplace.

## Prerequisites

Before you begin, make sure you know your billing account type. There are different steps to enable marketplace purchases depending on your account type.

You can [determine your billing account type](manage-billing-access.md#check-the-type-of-your-billing-account).

## Enable marketplace purchase

To enable marketplace purchases, you need to enable the marketplace policy setting.

Depending on your billing account type, this process and the permissions you need varies.

You can enable Marketplace purchases with the following account types:

- [Microsoft Customer Agreement](#mca--enable-the-marketplace-policy-setting)
- [Enterprise Agreement](#ea--enable-the-marketplace-policy-setting)

At a high level, here's how the process works.

:::image type="content" source="./media/enable-marketplace-purchases/diagram-steps-enable-purchases.svg" alt-text="Diagram showing the enable purchase steps." border="false" lightbox="./media/enable-marketplace-purchases/diagram-steps-enable-purchases.svg":::

### <a name = "mca--enable-the-marketplace-policy-setting"></a> Enable the marketplace policy setting with a Microsoft Customer Agreement account

Users with the following permissions can enable the policy setting:

- **Billing Account owner** or **Billing Account contributor**
- **Billing Profile owner** or **Billing Profile contributor**

The policy setting applies to all users with access to all Azure subscriptions under the billing account's billing profile.

To enable the policy setting on the Billing Account Profile:

1. Sign in to the Azure portal.
1. Go to or search for **Cost Management + Billing**.
1. On the left menu, select **Billing scopes**.
1. Select the appropriate billing account scope.
1. On the left menu, select **Billing profile**.
1. On the left menu, select **Policies**.
1. Set Azure Marketplace policy to **On**.
1. Select the **Save** option.

For more information about Azure Marketplace policy setting, see [purchase control through the billing profile under a Microsoft Customer Agreement](/marketplace/purchase-control-options#purchase-control-through-the-billing-profile) .

### <a name = "ea--enable-the-marketplace-policy-setting"></a> Enable the marketplace policy setting with an Enterprise Agreement account

Only users with the **Enterprise administrator** role can enable the policy setting. Users with **Enterprise administrator** role who have read-only permissions can't enable the proper policies to buy from the marketplace.

The policy setting applies to all users with access to the Azure subscriptions in the billing account (Enterprise Agreement enrollment).

To enable the policy setting on the billing account (Enterprise Agreement enrollment):

1. Sign in to the Azure portal.
1. Go to or search for **Cost Management + Billing**.
1. On the left menu, select **Billing scopes**.
1. Select the billing account scope.
1. On the left menu, select **Policies**.
1. Under Azure Marketplace, set the policy to **On**.
1. Select **Save**.

For more information about Azure Marketplace policy setting, see [Purchase control through Enterprise Agreement billing administration under an Enterprise Agreement](/marketplace/purchase-control-options#purchase-control-through-ea-billing-administration-under-an-enterprise-agreement-ea).

## Set user permissions on the Azure subscription

In order for customers (both Enterprise Agreement and Microsoft Customer Agreement) to purchase a marketplace private offer, a private plan, or a public plan, they need to set user permissions on their Azure subscription.

When you grant permission, it applies only to the individual users that you select.

To set permission for a subscription:

1. Sign in to the Azure portal.
1. Go to **Subscriptions** and then search for the name of the subscription.
1. Search for and then select the subscription that you want to manage access for.
1. Select **Access control (IAM)** from the left menu.
1. To give a user access, select **Add** from the top of the page.
1. In the **Role** dropdown list, select the owner or contributor role.
1. Enter the email address of the user to whom you want to give access.
1. Select **Save** to assign the role.

For more information about assigning roles, see [Assign Azure roles by using the Azure portal](/azure/role-based-access-control/role-assignments-portal) and [Privileged administrator roles](../../role-based-access-control/role-assignments-steps.md#privileged-administrator-roles).

## Set user permission to accept private offers

The permission (billing role) that you need to accept private offers and how you grant the permission varies, based on your agreement type.

### Set permission to accept private offers with a Microsoft Customer Agreement account

Only the billing account owner can set user permission. The permission granted applies to only the individual users that you select.

To set user permission for a user:

1. Sign in to the Azure portal.
1. Go to or search for **Cost Management + Billing**.
1. Select the billing account that you want to manage access for.
1. Select **Access control (IAM)** from the left-hand pane.
1. To give access to a user, select **Add** from the top of the page.
1. In the **Role** list, select either **Billing account owner** or **contributor**.
1. Enter the email address of the user to whom you want to give access.
1. Select **Save** to assign the role.

For more information about setting user permission for a billing role, see [Manage billing roles in the Azure portal](understand-mca-roles.md#manage-billing-roles-in-the-azure-portal).

### Set permission to accept private offers with an Enterprise Agreement account

Only Enterprise Agreement administrators can set user permission. Enterprise administrators with read-only permissions can't set user permission. The permission granted applies to only the individual users that you select.

To set user permission for a user:

1. Sign in to the Azure portal.
1. Go to or search for **Cost Management + Billing**.
1. On the left menu, select **Billing scopes** and then select the billing account that contains the Azure subscription that you want to use for Marketplace purchase.
1. On the left menu, select **Access Control (IAM)**.
1. On the top menu, select **+ Add**, and then select **Enterprise administrator**.
1. Complete the **Add role assignment** form, and then select **Add**.

For more information about how to add another enterprise administrator, see [Add another enterprise administrator](direct-ea-administration.md#add-another-enterprise-administrator).

## (Optional) Enable private offer purchases in the private Azure Marketplace

If the private Azure Marketplace is enabled, you need a private Marketplace admin to enable and configure the private Marketplace. To enable Azure private Marketplace in the Azure portal, a global administrator assigns the **Marketplace admin** role to specific users. The process to assign the **Marketplace** admin role is the same for Enterprise Agreement and Microsoft Customer Agreement customers.

To assign the **Marketplace admin** role:

1. Sign in to the Azure portal.
1. Go to or search for **Marketplace**.
1. Select **Private Marketplace** from the left menu.
1. Select **Access control (IAM)**.
1. Select **+ Add** > **Add role assignment**.
1. Under **Role**, select **Marketplace Admin**.
1. Select the desired user from the dropdown list, and then select **Done**.

For more information about assigning the Marketplace admin role, see [Assign the Marketplace admin role](/marketplace/create-manage-private-azure-marketplace-new#assign-the-marketplace-admin-role).

### Enable the private offer purchase in the private Marketplace

Users with the **Marketplace admin** role can enable private offer and private plan purchases in the private Marketplace. The Marketplace admin can also enable individual private offers or private plans.

After private offer purchase is enabled in the private Marketplace, all users in the organization (the Microsoft Entra tenant) can purchase products in enabled collections.

#### Enable private offers and private plans

1. Sign in to the Azure portal.
1. Go to or search for **Marketplace**.
1. Select **Private Marketplace** from the left menu.
1. Select **Get Started** to create the private Azure Marketplace. You only have to do this action once.
1. Select **Settings** from the left menu.
1. Select the radio button for the desired status (Enabled or Disabled).
1. Select **Apply** on the bottom of the page.
1. Update the Private Marketplace **Rules** to enable private offers and private plans.

#### Add individual private products to a private Marketplace collection

We generally recommend that a Marketplace admin should enable private offers in the Private Marketplace for all users in the organization by using the previous procedure.

We don't recommend it, but if necessary, users with the Marketplace admin role can use the following procedures to avoid enabling private offers in the Private Marketplace for all users in the organization. The Marketplace admin can add individual private offers on a purchase-by-purchase basis.

#### Set up a collection

1. Sign in to the Azure portal.
1. Go to or search for **Marketplace**.
1. Select **Private Marketplace** from the left menu.
1. If no collections were created, select **Get started**.
1. If collections exist, select an existing collection or add a new collection.

#### Add a private offer or a private plan to a collection

1. Select the collection name.
1. Select **Add items**.
1. Browse the gallery or use the search field to find the item you want.
1. Select **Done**.

For more information about setting up and configuring Marketplace product collections, see [Collections overview](/marketplace/create-manage-private-azure-marketplace-new#collections-overview).

:::image type="content" source="./media/enable-marketplace-purchases/azure-portal-private-marketplace-manage-collection-rules-select.png" alt-text="Screenshot that shows collection items." lightbox="./media/enable-marketplace-purchases/azure-portal-private-marketplace-manage-collection-rules-select.png" :::

## Related content

- To learn more about creating a private marketplace, see [Create a private Azure Marketplace](/marketplace/create-manage-private-azure-marketplace-new#create-private-azure-marketplace).
- To learn more about setting up and configuring Marketplace product collections, see [Collections overview](/marketplace/create-manage-private-azure-marketplace-new#collections-overview).
- Read more about the Marketplace in [Microsoft commercial marketplace customer documentation](/marketplace/).
