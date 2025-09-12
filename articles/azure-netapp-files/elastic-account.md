---
title: Create a NetApp account for the Elastic service level in Azure NetApp Files
description: Learn how to access Azure NetApp Files and create a NetApp account so that you can set up a Elastic service level capacity pool and create a volume.
services: azure-netapp-files
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: how-to
ms.date: 06/25/2025
ms.author: anfdocs
# Customer intent: As an IT administrator, I want to create a NetApp account in Azure NetApp Files, so that I can set up a capacity pool and manage storage volumes effectively.
---

# Create a NetApp account for the Elastic service level in Azure NetApp Files

Creating a NetApp account enables you to set up a capacity pool so that you can create a volume. You use the Azure NetApp Files pane to create a new NetApp account.

## Before you begin

* You must register your subscription for using the NetApp Resource Provider. For more information, see [Register the NetApp Resource Provider](azure-netapp-files-register.md).
* NetApp accounts must be dedicated to a service tier. Confirm you understand the difference between [hardwared-based and zone-redundant storage](zone-redundant.md) before creating you create your NetApp account.

[!INCLUDE [Zone-redundant storage preview](includes/elastic-zone-redundant-preview.md)]


## Steps

1. Log into the Azure portal.
1. Access the Azure NetApp Files pane by using one of the following methods:
   * Search for **Azure NetApp Files** in the Azure portal search box.
   * Select **All services** in the navigation, and then filter to Azure NetApp Files.

   To make the Azure NetApp Files pane a favorite, select the star icon next to it.

1. Select **+ Add** to create a new NetApp account.
   The **New NetApp account** window appears.
1. Select the **Subscription** the NetApp account belongs to. 
1. Assign a create the **Resource group**. 
1. Enter a **Name** for the NetApp account. 
1. Select **NetApp Elastic Files** to designate the account for the Elastic service level. 
1. Select the **Region**. 
1. Select **Create**. 

<!-- image -->

## Next steps 

* [Create an Elastic service level capacity pool](elastic-capacity-pool-create-task.md)
