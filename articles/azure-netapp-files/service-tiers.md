---
title: Understand Azure NetApp Files service tiers
description: Understand the benefits of Azure NetApp Files service tiers and how each type can serve your workloads. 
services: azure-netapp-files
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: conceptual
ms.date: 06/25/2025
ms.author: anfdocs
ms.custom: references-regions 
---

# Understand Azure NetApp Files service tiers


Azure NetApp Files supports two service tiers: hardware-based and zone-redundant (or software-based.)

You must define the service tier of your NetApp account when you create the account. The service tier of an account can't be changed after you create it. 

## Hardwared-based storage

<!-- -->

Hardware-based storage is available in all regions with A

## Zone-redundant service (preview)

Azure NetApp Files zone-redudnant storage is currently in preview. During preview, there you can create snapshots, backups, and enable customer-managed keys. 

Cool access, dual-protocol volume support, cross-region replication, short-term clones, and AzAcSnap aren't currently supported with zone-redundant storage.  



### Register for zone-redundant storage 

Zone-redundant storage is currently in preview. You must register for both the `ANFZoneRedundant` and `ANFScaleOptimized` AFECs before using zone-redundant storage for the first time. 


1.  Register the feature:

    ```azurepowershell-interactive
    Register-AzProviderFeature -ProviderNamespace Microsoft.NetApp -FeatureName ANFZoneRedundant
    ```

        ```azurepowershell-interactive
    Register-AzProviderFeature -ProviderNamespace Microsoft.NetApp -FeatureName ANFScaleOptimized
    ```

2. Check the status of the feature registration: 

    > [!NOTE]
    > The **RegistrationState** may be in the `Registering` state for up to 60 minutes before changing to `Registered`. Wait until the status is `Registered` before continuing.

    ```azurepowershell-interactive
    Get-AzProviderFeature -ProviderNamespace Microsoft.NetApp -FeatureName ANFZoneRedundant
    ```

    ```azurepowershell-interactive
    Get-AzProviderFeature -ProviderNamespace Microsoft.NetApp -FeatureName ANFScaleOptimized
    ```

You can also use [Azure CLI commands](/cli/azure/feature) `az feature register` and `az feature show` to register the feature and display the registration status. 

### Supported regions

* Australia East
* Central US 
* East US
* East US 2 
* North Europe
* South Central US
* West Europe
* West US 2