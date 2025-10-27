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
- Transparent failover if a zonal outage occurs
- Seamless growth from 1 GiB without specialized hardware 

Zone-redundant storage is designed for small workloads, offering capacity pools that scale from 512 GiB to 16 TiB. Volumes can scale from 1 GiB to the maximum size of the capacity pool. 

If you're using custom RBAC roles, ensure you configure the [correct permissions](manage-availability-zone-volume-placement.md#configure-custom-rbac-roles).

## Supported regions

* Australia East
* Canada Central 
* Central US 
* East US
* East US 2 
* France Central 
* Germany West Central 
* North Europe
* South Central US
* Spain Central 
* UK South 
* West Europe
* West US 2
* West US 3 

### Best practices

* Because some regions only have two availability zones, confirm supported availability zones in the region before deploying zone-redundant storage. Use the Azure CLI command `az netappfiles resource query-region-info` or the REST API call: 

```https
GET https://management.azure.com/subscriptions/{subscriptionId}/providers/Microsoft.NetApp/locations/{location}/regionInfo?api-version=2025-03-01
```

## Comparison of service levels

>[!IMPORTANT]
>Elastic Zone-Redundant storage has [dedicated endpoints](#api-endpoints). Workflows for this service level are different than other service levels. Ensure you follow the correct guidelines for your service level. 

| Feature | Flexible, Standard, Premium, and Ultra service levels | Elastic service level | 
| - | - | - | 
| Performance | High performance storage optimized for enterprise workloads | Optimized for lower-performanc NAS workloads | 
| Data management | Snapshots, cross-zone and cross-region replication, backups | Snapshots, cross-zone and cross-region replication, backups | 
| Protocol support | NFS, SMB, and dual-protocol (NFS and SMB) | NFS and SMB | 
| Integrated backup | Integrated backup and recovery | Limited backup and recovery | 
| Price | Premium pricing for enterprise features | Cost-optimized for smaller workloads |

### API endpoints

New API endpoints have been introduced that are specific to the Elastic service level. Consult the table for the different endpoints:

| Resource type | Elastic endpoint | Flexible, Standard, Premium, and Ultra endpoint |
| - | -- | -- |
| Accounts | elasticAccounts | netAppAccounts |
| Backups | /elasticAccounts/{accountName}/elasticBackupVaults/{vaultName}/elasticBackups | /netAppAccounts/{accountName}/backupVaults/{vaultName}/backups |
| Backups policies | /elasticAccounts/{accountName}/elasticBackupPolicies | netAppAccounts/{accountName}/backupPolicies |
| Backup vaults | /elasticAccounts/{accountName}/elasticBackupVaults | /netAppAccounts/{accountName}/backupVaults | 
| Capacity pools | /elasticAccounts/elasticCapacityPools | /netAppAccounts/capacityPools |
| Change zone | elasticCapacityPools/{poolName}/changeZone | N/A |
| Region info | elasticRegionInfos | locations/{location}/regionInfo
| Snapshots | elasticAccounts/{accountName}/elasticCapacityPools/elasticVolumes/{volumeName}/elasticSnapshots | /netAppAccounts/{accountName}/capacityPools/{poolName}/volumes/{volumeName}/snapshots |
| Snapshot policies | elasticAccounts/{accountName}/elasticCapacityPools/elasticVolumes/{volumeName}/elasticSnapshotPolicies | netAppAccounts/{accountName}/snapshotPolicies/{snapshotPolicyName} |
| Volumes | elasticAccounts/{accountName}/elasticCapacityPools/elasticVolumes | /netAppAccounts/{accountName}/capacityPools/{poolName}/volumes/{volumeName} |
| Volume file path availability | elasticCapacityPools/{poolName}/checkVolumeFilePathAvailability | /locations/{location}/checkFilePathAvailability |

For more detailed information, see [Azure NetApp Files REST API](/rest/api/netapp).

## Supported features 

Elastic zone-redundant storage requires the use of [availability zones](../reliability/reliability-netapp-files.md). The service level also supports:

* [Azure NetApp Files backup](backup-introduction.md)
* [Customer-managed keys](configure-customer-managed-keys.md)
* [Snapshots](snapshots-introduction.md)
* [Cross-zone, cross-region, and cross-zone-region replication](replication.md)

<!-- SMB CA shares, other SMB features -->
<!-- migration assistant, cool access -->
<!-- short term clones -->

## Next steps 

- [Storage hierarchy of Azure NetApp Files](azure-netapp-files-understand-storage-hierarchy.md)
- [Create a NetApp account](azure-netapp-files-create-netapp-account.md)
- [Set up a capacity pool](azure-netapp-files-set-up-capacity-pool.md)
- [Azure NetApp Files resource limits](elastic-resource-limits.md)