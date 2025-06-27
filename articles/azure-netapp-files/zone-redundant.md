---
title: Understand Azure NetApp Files zone-redundant storage
description: Understand the difference between hardware-based and zone-redundant storage. 
services: azure-netapp-files
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: conceptual
ms.date: 06/25/2025
ms.author: anfdocs
ms.custom: references-regions 
---

# Understand Azure NetApp Files zone-redundant storage (preview)

Azure NetApp Files zone-redundant storage is a software-based alternative to hardware-based Azure NetApp Files 

When creating your NetApp account, you must designate that the account is for zone-redundant storage. A NetApp account configured for zone-redundant storage can't be converted to use another service level after it's created. 

## Zone-redundant service

In comparison to existing Azure NetApp Files service levels, zone-redundant storage offers:  

- Zone redundancy that can persist if a zonal outage occurs in a single region 
- Transparent failover in case of a zonal outage 
- Seamless growth from 1 GiB without specialized hardware 

create snapshots, backups, and enable customer-managed keys. 

Zone-redundant storage is design for small workloads, offering capacity pools that scale from 512 GiB to 16 TiB. Volumes can scale from 1 GiB to the maximum size of the capacity pool. 

<!-- short-term clone timing -->
Cool access, dual-protocol volume support, cross-region replication, short-term clones, and AzAcSnap aren't currently supported with zone-redundant storage.  

If you're using custom RBAC roles, ensure you've configure the [correct permissions](manage-availability-zone-volume-placement.md#configure-custom-rbac-roles).

## Zone-redundant storage and hardware-based storage

Review the following table to weigh the benefits of zone-redundant storage in contrast to Azure NetApp Files hardware-based storage. 

## Register for zone-redundant storage 

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

## Supported regions

* Australia East
* Central US 
* East US
* East US 2 
* North Europe
* South Central US
* West Europe
* West US 2

## Best practices

* Because some regions only have two availability zones, confirm supported availability zones in the region before deplying zone-redundant storage. Use the Azure CLI command `az netappfiles resource query-region-info` or the REST API call: 

```https
GET https://management.azure.com/subscriptions/{subscriptionId}/providers/Microsoft.NetApp/locations/{location}/regionInfo?api-version=2025-03-01
```

## Next steps 

- [Storage hierarchy of Azure NetApp Files](azure-netapp-files-understand-storage-hierarchy.md)
- [Create a NetApp account](azure-netapp-files-create-netapp-account.md)
- [Set up a capacity pool](azure-netapp-files-set-up-capacity-pool.md)
- [Azure NetApp Files resource limits](azure-netapp-files-resource-limits.md)