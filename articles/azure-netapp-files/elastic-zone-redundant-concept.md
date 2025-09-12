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

When creating your NetApp account, you must designate that the account is for zone-redundant storage. A NetApp account configured for the Elastic zone-redundant service level can only be used for the Elastic service level.

## Elastic zone-redundant service

In comparison to existing Azure NetApp Files service levels, the Elastic zone-redundant service level offers:  

- Zone redundancy that can persist if a zonal outage occurs in a single region 
- Transparent failover in case of a zonal outage 
- Seamless growth from 1 GiB without specialized hardware 

Zone-redundant storage is designed for small workloads, offering capacity pools that scale from 512 GiB to 16 TiB. Volumes can scale from 1 GiB to the maximum size of the capacity pool. 

<!-- short-term clone timing -->

If you're using custom RBAC roles, ensure you configure the [correct permissions](manage-availability-zone-volume-placement.md#configure-custom-rbac-roles).

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

* Because some regions only have two availability zones, confirm supported availability zones in the region before deploying zone-redundant storage. Use the Azure CLI command `az netappfiles resource query-region-info` or the REST API call: 

```https
GET https://management.azure.com/subscriptions/{subscriptionId}/providers/Microsoft.NetApp/locations/{location}/regionInfo?api-version=2025-03-01
```

## Comparison of service levels

| Feature | Flexible, Standard, Premium, and Ultra service levels | Elastic service level | 
| - | - | - | 
| Performance | High performance storage optimized for enterprise workloads | Optimized for lower-performanc NAS workloads | 
| Data management | Snapshots, cross-zone and cross-region replication, backups | Snapshots, cross-zone and cross-region replication, backups | 
| Protocol support | NFS, SMB, and dual-protocol (NFS and SMB) | NFS and SMB | 
| Integrated backup | Integrated backup and recovery | Limited backup and recovery | 
| Price | Premium pricing for enterprise features | Cost-optimized for smaller workloads |

## Supported features 

Elastic zone-redundant storage requires the use of [availability zones](../reliability/reliability-netapp-files.md). The service level also supports:

* [Azure NetApp Files backup](backup-introduction.md)
* [Customer-managed keys](configure-customer-managed-keys.md)
* [Snapshots](snapshots-introduction.md)
* [Cross-zone and cross-region replication](replication.md)

<!-- SMB CA shares, other SMB features -->
<!-- migration assistant, cool access -->


## Next steps 

- [Storage hierarchy of Azure NetApp Files](azure-netapp-files-understand-storage-hierarchy.md)
- [Create a NetApp account](azure-netapp-files-create-netapp-account.md)
- [Set up a capacity pool](azure-netapp-files-set-up-capacity-pool.md)
- [Azure NetApp Files resource limits](azure-netapp-files-resource-limits.md)