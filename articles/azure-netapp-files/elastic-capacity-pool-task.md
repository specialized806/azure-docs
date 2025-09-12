---
title: Create a capacity pool for Elastic Zone-Redundant service in Azure NetApp Files
description: Describes how to create a capacity pool so that you can create volumes within it.
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
# Create a capacity pool for Elastic Zone-Redundant service in Azure NetApp Files

You must create a capacity pool before you can create volumes in Azure NetApp Files. Capacity pools determine quota and throughput for volumes. 

>[!IMPORTANT]
>To create a capacity pool for the Elastic zone-redundant service level, see [Create an Elastic zone-redundant capacity pool](elastic-capacity-pool-task.md).

## Before you begin 

* You must have a NetApp account designated for use with the Elastic Zone-Redundant service level. 
* If you're using Azure CLI, ensure that you're using the latest version.
* If you're using PowerShell, ensure that you're using the latest version of the Az.NetAppFiles module. To update to the latest version, use the 'Update-Module Az.NetAppFiles' command. For more information, see [Update-Module](/powershell/module/powershellget/update-module).
* If you're using the Azure REST API, ensure that you specify the latest version.
    >[!IMPORTANT]

## Considerations for Elastic service level capacity pools

* Capacity pools can only use auto QoS in the Elastic service level.  
* You must use [Standard network features](configure-network-features.md).  
* Capacity pools for the Elastic zone-redundant service level can be created at sizes between 512 GiB to 16 TiB. After increasing from 512 GiB to 1 TiB, capacity pools can only be created and grow in 1-TiB increments. For example, you can create a 512-GiB capacity pool and resize it to 1-TiB or 2-TiB, or you can create a 2-TiB capacity pool and resize it to 3 TiB then 4 TiB; a capacity pool can't be resized to 3.5 TiB. 
    * See [Elastic service level](elastic-service-levels.md) for resource limits. 
* After creating a capacity pool, you can't reduce the quota of the capacity pool. 
* When creating capacity pools, you must designate the failover order for three zones. The order cannot be changed after creating the capacity pools. Capacity pools wautomatically failover if a zonal outage occurs. You can also manually perform failovers.  
    * Failback is not supported.  
* Zone-redundant capacity pools provide throughput at 32 MiB/s per 1 TiB and 1 I/OPS per GiB. With the maximum capacity pool size of 16 TiB, throughput maxes out at 512 MiB/s and 16,384 I/OPS. QoS is shared across all volumes in a capacity pool.  
* Volumes in zone-redundant storage capacity pools can't be moved out of the capacity pool they're created in. 

## Network planning

<!-- network planning -->

## Steps

1. From your Azure NetApp Files account, select **Capacity pools**. 
1. Select **+ Add pools**.
1. Provide the following information: 
    * **Name**
    * **Service level**
        Choose **Elastic**
    * **Quota** 
        Assign the quota. See Resource limits for more information about maxmiums and minimums. 
    * **Virtual network**
        Select an existing or create a new VNet. 
    * **Delegated subnet**
        Select or create a delegated subnet. 
    * **Active Directory configuration**
        If you're going to add SMB volumes, you must add the AD configuration. 
    * **Availability zone**
        Drag and drop the availability zones in the ranked order for failover. 

    :::image type="content" source="./media/elastic-capacity-pool-task/capacity-pool-elastic.png" alt-text="Screenshot of creation for an Elastic capacity pool." lightbox="./media/elastic-capacity-pool-task/capacity-pool-elastic.png":::

1. Select **Create**. 

## Modify a capacity pool

1. In your NetApp account, select **Capacity pools**. 
1. Select the capacity pool you want to modify. 
1. Select **Edit capacity pool**. 
1. Increase the quota. Quotas can only be increased whole TiB values. 
1. Select **Save**. 

## Fail over a capacity pool

## Next steps

* [Create an NFS volume for the Elastic Zone-Redundant service level](elastic-create-volume-network.md)
* [Create an SMB volume for the Elastic Zone-Redundant service level](elastic-create-volume-server.md)