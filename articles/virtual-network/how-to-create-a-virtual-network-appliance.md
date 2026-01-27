---
title: Create a virtual network appliance
description: Create a Virtual Network Appliance in Azure with ease. This guide covers registration, configuration, and troubleshooting for the public preview.
#customer intent: As a network administrator, I want to create a Virtual Network Appliance in the Azure portal so that I can manage network traffic in a non-production environment.
author: asudbring
ms.author: allensu
ms.reviewer: allensu
ms.date: 01/27/2026
ms.topic: concept-article
ms.service: azure-virtual-network
---

# How to Create a Virtual Network Appliance

## Overview

This quick start article explains how to register your subscription for the Virtual Network Appliance public preview and create a Virtual Network Appliance in the Azure portal. The public preview is intended for testing, evaluation, and feedback; production workloads are not supported.

> [!IMPORTANT]
> Azure Virtual Network Appliance is currently in PREVIEW.
> See the [Supplemental Terms of Use for Microsoft Azure Previews](https://azure.microsoft.com/support/legal/preview-supplemental-terms/) for legal terms that apply to Azure features that are in beta, preview, or otherwise not yet released into general availability.

## Prerequisites

### Subscription and workload requirements

• Use a non-production Azure subscription for this public preview.  
• Your subscription must be enabled for the preview via AFEC registration and approval (see Section 2).

### Supported regions (public preview)

Virtual Network Appliance public preview is limited to the following regions:  
• West US  
• East US  
• East Asia  
• North Europe  
• West Europe  
• East US 2  
• West Central US  
• UK South

## Register for the public preview (AFEC) and get approval

### Register your subscription using Azure Feature Exposure Control (AFEC)

Virtual Network Appliance preview access is controlled via AFEC. The AFEC feature name used for enabling the Virtual Network Appliance preview is:  
• Microsoft.network/AllowVirtualNetworkAppliance

Customers register for preview by activating the AFEC flag in the Azure portal.

### Approval process

After you submit AFEC registration for Microsoft.network/AllowVirtualNetworkAppliance, please fill out this preview [sign-up form](https://forms.office.com/r/kqEKRr5mpB). The product team will approve it manually based on availability and capacity. If there is insufficient inventory/capacity in a region, creation requests may be denied during the public preview timeframe.

### Confirm your subscription is enabled

Once the subscription has been authorized, verify enablement by searching "Virtual Network appliance" in the Azure portal search bar. If enabled, you should see "Virtual network appliances" as a selectable service entry.

:::image type="content" source="media/how-to-create-a-virtual-network-appliance/image1.png" alt-text="Screenshot of the Azure portal search bar with Virtual network appliances highlighted.":::

:::image type="content" source="media/how-to-create-a-virtual-network-appliance/image2.png" alt-text="Screenshot of the Virtual network appliances service entry in the Azure portal.":::

## Create a resource group

1. Sign-in to the [Azure Preview portal](https://preview.portal.azure.com).

1. In the search box at the top of the portal enter **Resource group**. Select **Resource groups** in the search results.

1. Select **+ Create**. 

1. In **Create a resource group**, enter or select the following information:

    | Setting | Value |
    | ------- | ----- |
    | Subscription | Select your subscription |
    | Resource group name | Enter **test-rg** |
    | Region | Select **(US) East US** |

1. Select **Review + create**.

1. Select **Create**.


## Create a virtual network

1. In the search box at the top of the portal enter **Virtual network**. Select **Virtual networks** in the search results.

1. Select **+ Create**.

1. In **Create virtual network**, enter or select the following information:

    | Setting | Value |
    | ------- | ----- |
    | **Project details** |  |
    | Subscription | Select your subscription |
    | Resource group | Select **test-rg** |
    |**Instance details** |  |
    | Virtual network name | Enter **vnet-1** |
    | Region | Select **(US) East US** |

1. Select **Next**.

1. Select **Next**. 

1. In ***IP addresses**, select the **default** subnet.

1. In **Edit subnet**, in **Name** enter **VirtualNetworkApplianceSubnet**.

1. Select **Save**.

1. Select **Review + Create**. 

1. Select **Create**.

## Create a Virtual Network Appliance

1. In the search box at the top of the portal, enter **Virtual network appliance**. Select **Virtual network appliances** in the search result.

1. Select **+ Create**.

1. In **Create a virtual network appliance**, enter or select the following information in the **Basics** taB:

    | Setting | Value |
    | ------- | ----- |
    | **Project details** |  |
    | Subscription | Select your subscription |
    | Resource group | Select **test-rg** |
    | **Instance details** |  |
    | Name | Enter **vnet-appliance** |
    | Region | Select **East US** |
    | Capacity | Select **50 Gpbs** |
    | Virtual Network | Select **vnet-1** |


1. Select **Review + create**.

1. Select **Create**.

Virtual Network Appliance is created in a dedicated subnet named VirtualNetworkApplianceSubnet. If you create multiple appliance instances, they are created in the same dedicated subnet.

**Optional**: Configure NSG and Route Table selection during create  
During creation, you can choose Network Security Group and Route Table for the Virtual Network Appliance's dedicated subnet.

## Troubleshoot

### Creation fails because the subscription is not enabled

If you see an error indicating your subscription is not enabled/allowlisted, it typically means your AFEC registration is not yet approved for Microsoft.network/AllowVirtualNetworkAppliance. Register via AFEC and wait for approval.

### Appliance is not getting traffic as expected

• Verify NSGs and route tables attached to the appliance instance (or to the hosting subnet) match your intended routing and security configuration.  
• Use NSG flow logs (if enabled in your environment) to help validate connectivity and rule matches.
