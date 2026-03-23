---
title: include file
description: include file
services: virtual-network-manager
author: mbender-ms
ms.service: azure-virtual-network-manager
ms.topic: include
ms.date: 02/02/2026
ms.author: mbender
ms.custom: include file
---

## Create a Virtual Network Manager instance

Deploy a Virtual Network Manager instance with the defined scope and access that you need using the Azure portal.

1. Sign in to the [Azure portal](https://portal.azure.com/).

1. Select **+ Create a resource** and search for **Network Manager**. Then select **Network Manager** > **Create** to begin setting up Virtual Network Manager.

1. On the **Basics** tab, enter or select the following information:

    | Setting | Value |
    | ------- | ----- |
    | **Subscription** | Select the subscription containing your existing virtual networks. |
    | **Resource group** | Select the existing resource group where you want to deploy Virtual Network Manager. |
    | **Name** | Enter a name for your Virtual Network Manager instance. |
    | **Region** | Select a region for your Virtual Network Manager instance. Virtual Network Manager can manage virtual networks in any region. The selected region is where the Virtual Network Manager instance will be deployed. |
    | **Description** | *(Optional)* Provide a description about this Virtual Network Manager instance and the task it's managing. |
    | [Features](../../../virtual-network-manager/concept-network-manager-scope.md#features) | Select the features you need from the dropdown list: </br> - **Connectivity**: Enables the creation of a full mesh or hub-and-spoke network topology between virtual networks within the scope. </br> - **Security Admin**: Enables the creation of global network security rules. </br> - **Routing**: Enables the creation and management of user-defined routes at scale. |

1. Select the **Management scope** tab or **Next: Management scope** to continue.

1. On the **Management scope** tab, select **+ Add**.

1. In the **Add scopes** pane, select the subscriptions or management groups containing your existing virtual networks, and choose **Select**.

1. Select **Review + create** to validate your configuration.

1. After validation passes, select **Create** to deploy the Virtual Network Manager instance.

> [!IMPORTANT]
> Virtual Network Manager requires specific permissions within the defined scope. Ensure you have the necessary [Azure RBAC roles](../../../virtual-network-manager/concept-network-manager-scope.md#permissions) before creating the instance.

The Virtual Network Manager instance is now created and ready to manage your existing virtual networks within the defined scope.