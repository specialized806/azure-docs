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

Hardware-based storage is available in all regions enabled for Azure NetApp Files. 

## Zone-redundant service (preview)

The purpose of this private preview program is to provide users of Azure NetApp Files early access to the Zone-redundant service level. In comparison to existing Azure NetApp Files service levels, zone-redundant service level offers:  

- Zone redundancy that can persist if a zonal outage occurs in a single region 
- Transparent failover in case of a zonal outage 
- Seamless growth from 1 GiB without specialized hardware 

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

## Next steps 

- [Storage hierarchy of Azure NetApp Files](azure-netapp-files-understand-storage-hierarchy.md)
- [Create a NetApp account](azure-netapp-files-create-netapp-account.md)
- [Set up a capacity pool](azure-netapp-files-set-up-capacity-pool.md)