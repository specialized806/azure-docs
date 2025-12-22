---
title: Create a capacity pool for Elastic zone-redundant service in Azure NetApp Files
description: Learn how to create a capacity pool for Elastic zone-redundant storage so that you can create volumes within it.
services: azure-netapp-files
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: how-to
ms.date: 08/14/2025
ms.author: anfdocs
ms.custom:
  - build-2025
# Customer intent: "As a cloud storage administrator, I want to create a capacity pool for Azure NetApp Files so that I can manage the storage volumes and configure their performance requirements effectively."
---
# Create a capacity pool for Elastic zone-redundant service in Azure NetApp Files

You must create a capacity pool before you can create volumes in Azure NetApp Files. Capacity pools determine quota and throughput for volumes. 

>[!IMPORTANT]
>To create a capacity pool for the Flexible, Standard, Premium, or Ultra service level, see [Set up a capacity pool](azure-netapp-files-set-up-capacity-pool.md).

## Before you begin 

* You must have a NetApp account designated for use with Elastic zone-redundant storage. 
* If you're using Azure CLI, ensure that you're using the latest version.
* If you're using PowerShell, ensure that you're using the latest version of the Az.NetAppFiles module. To update to the latest version, use the `Update-Module Az.NetAppFiles` command. For more information, see [Update-Module](/powershell/module/powershellget/update-module).
* If you're using customer-managed keys, ensure you've configured encryption before creating the capacity pool. For more information, see [Configure customer-managed keys for Elastic zone-redundant storage](elastic-customer-managed-keys.md).
* If you're using the Azure REST API, ensure that you specify the latest version.
* Elastic capacity pools enable you to create a failover preference order of three availability zones. Some of the regions that support the Elastic service level only offer two availability zones. You should query the region for availability zone with the REST API before creating the capacity pool: `GET https://management.azure.com/subscriptions/{subscriptionId}/providers/Microsoft.NetApp/locations/{location}/elasticRegionInfo?api-version=2025-09-01-preview`.

[!INCLUDE [Availability zone role-based access control call-out.](includes/availability-zone-important.md)]

## Considerations for Elastic service level capacity pools

* Creating and resizing a capacity pool can be a long-running operation. On average, creating a pool takes 5-7 minutes, but can take longer. 
* When creating capacity pools, you must designate the failover order for three zones. The order can't be changed after creating the capacity pools.
    * Capacity pools automatically fail over if a zonal outage occurs. You can also manually fail over.  
    * If a zonal outage occurs, capacity pools don't automatically fail back. You can manually perform a fail back. For more information, see [Change the availability zone of an Elastic capacity pool](elastic-capacity-pool-task.md).
* Elastic zone-redundant capacity pools provide throughput at 32 MiB/s per 1 TiB and 1 I/OPS per GiB. With the maximum capacity pool size of 128, throughput maxes out at 4,096 MiB/s and 131,072 I/OPS. QoS is shared across all volumes in a capacity pool.  
* Volumes in zone-redundant storage capacity pools can't be moved out of the capacity pool they're created in. 
* Review the [maximum and minimum sizes](elastic-resource-limits.md) for Elastic zone-redundant storage. 
* When resizing capacity pools: 
    * If you've created a capacity pool smaller than 16 TiB, you can increase its size in 1-TiB increments up to 16 TiB. 
    * Any capacity pool created at a size less than 16 TiB can't be resized beyond 16 TiB. If you need a larger capacity pool, create a new one. 
    * If you create a capacity pool larger than 16 TiB, you can increase its size in 8-TiB increments up to the maximum size. 
    * You can't decrease the size of a capacity pool in Elastic zone-redundant storage. 
* After creating a capacity pool, you can't reduce the quota of the capacity pool. 
* When you resize a capacity pool, the capacity pool might revert to the availability zone it was originally created in. Confirm the capacity pool and [change the zone](elastic-change-zones.md) after resizing if necessary.

<!-- network planning -->

## Steps

1. From your Azure NetApp Files account, select **Capacity pools**. 
1. Select **+ Add pool**.
1. Provide the following information: 
    * **Name**: Consult the [naming rules and restrictions for Azure resources](../azure-resource-manager/management/resource-name-rules.md#microsoftnetapp) for character limits and other naming conventions.
    * **Service level**: **Zone-redundant** is automatically selected.
    * **Quota**: Assign the quota value in TiB. See [Resource limits](elastic-resource-limits.md) for more information about maximums and minimums. 
    * **Virtual network**: Select an existing VNet.
    * **Delegated subnet**: Select a delegated subnet. 
    * **Encryption key source**: If you've already configured a customer-managed key, you can select **Customer Managed**. For more information, see [Configure customer-managed keys](elastic-customer-managed-keys.md). Otherwise, select **NetApp Managed**.
    * **Key vault private endpoint**: If you selected **Customer Managed** for the encryption key source, choose the Azure key vault you configured in your encryption settings. 
    * **Active Directory configuration**: If you've configured an Active Directory account on the NetApp Elastic account, select it from the dropdown menu. If you haven't configured one, select **Create new**.  

    [!INCLUDE [Steps to configure the Active Directory connection.](includes/elastic-active-directory.md)]

    * **Availability zone**: Drag and drop the availability zones in the ranked order for failover. 

    :::image type="content" source="./media/elastic-capacity-pool-task/capacity-pool-elastic.png" alt-text="Screenshot of creation for an Elastic capacity pool." lightbox="./media/elastic-capacity-pool-task/capacity-pool-elastic.png":::

1. Select **Ok** to create the capacity pool. 

## Modify a capacity pool

1. In your NetApp account, select **Capacity pools**. 
1. Select the capacity pool you want to modify. 
1. Select **Edit capacity pool**. 
1. Increase the quota. Quotas can only be increased in to whole TiB values. 
1. Select **Save**. 

## Fail over a capacity pool

1. Select **Capacity pools** then select the capacity pool you want to fail over. 
1. Select **Edit Current Availability Zone**. 
1. In the Edit Current Availability Zone tab, choose the new availability zone for the capacity pool. 
1. Select **OK**. 
1. In the capacity pool overview, check the **Current zone** field to confirm failover succeeded and the availability zone has been updated to the new zone. 

[!INCLUDE [Availability zone role-based access control call-out.](includes/availability-zone-roles.md)]

## Next steps

* [Understand Elastic zone-redundant storage](elastic-zone-redundant-concept.md)
* [Create an NFS volume for Elastic zone-redundant storage](elastic-volume.md)
* [Create an SMB volume for Elastic zone-redundant storage](elastic-volume-server-message-block.md)