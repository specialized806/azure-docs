---
title: Create a NetApp Elastic account in Azure NetApp Files
description: Learn how to access Azure NetApp Files and create a NetApp account so that you can set up an Elastic service level capacity pool and create a volume.
services: azure-netapp-files
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: how-to
ms.date: 06/25/2025
ms.author: anfdocs
# Customer intent: As an IT administrator, I want to create an Elastic zone-redundant NetApp account in Azure NetApp Files, so that I can set up a capacity pool and manage storage volumes effectively.
---

# Create a NetApp Elastic account in Azure NetApp Files (preview)

Creating a NetApp account enables you to set up a capacity pool so that you can create a volume. You use the Azure NetApp Files pane to create a new NetApp account.

## Before you begin

* You must register your subscription for using the NetApp Resource Provider. For more information, see [Register the NetApp Resource Provider](azure-netapp-files-register.md).
* There are two types of NetApp accounts. If you plan to use Elastic zone-redundant storage, you must use a [NetApp Elastic account](elastic-zone-redundant-concept.md).

## Register for the Elastic zone-redundant storage

Elastic zone-redundant storage is currently in preview. You must register for the `ANFElasticZRS` AFEC before using zone-redundant storage for the first time. 

1.  Register the feature:

    ```azurepowershell-interactive
    Register-AzProviderFeature -ProviderNamespace Microsoft.NetApp -FeatureName ANFElasticZRS
    ```

2. Check the status of the feature registration: 

    > [!NOTE]
    > The **RegistrationState** may be in the `Registering` state for up to 60 minutes before changing to `Registered`. Wait until the status is `Registered` before continuing.

    ```azurepowershell-interactive
    Get-AzProviderFeature -ProviderNamespace Microsoft.NetApp -FeatureName ANFElasticZRS
    ```
You can also use [Azure CLI commands](/cli/azure/feature) `az feature register` and `az feature show` to register the feature and display the registration status. 

## Steps

[!INCLUDE [Create an Elastic zone-redundant account.](includes/elastic-account-create.md)]

## Next steps 

* [Understand the Elastic zone-redundant storage](elastic-zone-redundant-concept.md)
* [Create an Elastic service level capacity pool](elastic-capacity-pool-task.md)
