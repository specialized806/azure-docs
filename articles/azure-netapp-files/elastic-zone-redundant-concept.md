---
title: Understand Azure NetApp Files zone-redundant storage
description: Understand the unique qualities of Elastic zone-redundant storage, which delivers built-in local redundancy is designed as a more affordable alternative. 
services: azure-netapp-files
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: article
ms.date: 01/26/2026
ms.author: anfdocs
ms.custom: references-regions 
---

# Understand Azure NetApp Files zone-redundant storage (preview)

Azure NetApp Files zone-redundant storage is cost‑optimized landing zone for unstructured data, built for modern workloads. 

It delivers built‑in local redundancy, shared QoS, and native multi‑tenancy with global regional availability—making it a natural fit for ISVs and SaaS solution providers. ​

Scale smaller volumes with flexible throughput, power backups, analytics staging, and AI datasets—all at an affordable price without compromising reliability.

Elastic zone-redundant storage offers built-in high-availability and zero recovery point objective (RPO). 

When creating your NetApp account, you must designate that the [account is for Elastic zone-redundant storage](elastic-zone-redundant-concept.md). An Elastic NetApp account can only be used for Elastic zone-redundant storage.

## Elastic zone-redundant service

In comparison to existing Azure NetApp Files service levels, Elastic zone-redundant storage offers:

- Zone redundancy that can persist if a zonal outage occurs in a single region 
- Transparent failover if a zonal outage occurs
- Seamless growth from 1 GiB without specialized hardware 

Zone-redundant storage is designed for small workloads, offering capacity pools that scale from 1 TiB to 128 TiB.

If you're using custom RBAC roles, ensure you configure the [correct permissions](manage-availability-zone-volume-placement.md#configure-custom-rbac-roles).

## Supported regions

* Australia East
* Canada Central 
* Central US 
* South Central US
* UK South 
* West Europe

### Best practice

* Because some regions only have two availability zones, confirm supported availability zones in the region before deploying zone-redundant storage. Use the REST API call: 

```rest
GET https://management.azure.com/subscriptions/{subscriptionId}/providers/Microsoft.NetApp/locations/{location}/elasticRegionInfo?api-version=2025-09-01-preview
```

## Comparison of service levels

>[!IMPORTANT]
>Elastic zone-redundant storage has [dedicated endpoints](#api-endpoints). Workflows for this service level are different than other service levels. Ensure you follow the correct guidelines for your service level. 

| Feature | Flexible, Standard, Premium, and Ultra service levels | Elastic zone-redundant service level | 
| - | - | - | 
| Performance | High performance storage optimized for enterprise workloads | Optimized for lower-performance NAS workloads | 
| Data management | Snapshots, cross-zone and cross-region replication, backups | Snapshots and backups | 
| Protocol support | NFS, SMB, and dual-protocol (NFS and SMB) | NFS and SMB | 
| Integrated backup | Integrated backup and recovery | Integrated backup and recovery | 
| Price | Premium pricing for enterprise features | Cost-optimized for smaller workloads |

To see which features the Elastic zone-redundant service level offers, see [Supported features](#supported-features).

### API endpoints

The Elastic zone-redundant service level has dedicated API endpoints. This table identifies the different endpoints for service levels. 

| Resource type | Elastic zone-redundant endpoint | Flexible, Standard, Premium, and Ultra endpoint |
|-|---|---|
| Accounts | elasticAccounts | netAppAccounts |
| Active Directory | /activeDirectoryConfigs
| Backups | /elasticAccounts/{accountName}/elasticBackupVaults/{vaultName}/elasticBackups | /netAppAccounts/{accountName}/backupVaults/{vaultName}/backups |
| Backups policies | /elasticAccounts/{accountName}/elasticBackupPolicies | netAppAccounts/{accountName}/backupPolicies |
| Backup vaults | /elasticAccounts/{accountName}/elasticBackupVaults | /netAppAccounts/{accountName}/backupVaults | 
| Capacity pools | /elasticAccounts/{accountName}/elasticCapacityPools | /netAppAccounts/{account}/capacityPools |
| Change zone | elasticCapacityPools/{poolName}/changeZone | N/A |
| Region info | locations/{location}/elasticRegionInfos | locations/{location}/regionInfo
| Snapshots | elasticAccounts/{accountName}/elasticCapacityPools/{poolName}/elasticVolumes/{volumeName}/elasticSnapshots | /netAppAccounts/{accountName}/capacityPools/{poolName}/volumes/{volumeName}/snapshots |
| Snapshot policies | elasticAccounts/{accountName}/elasticSnapshotPolicies | netAppAccounts/{accountName}/snapshotPolicies/{snapshotPolicyName} |
| Volumes | elasticAccounts/{accountName}/elasticCapacityPools/{poolName}/elasticVolumes | /netAppAccounts/{accountName}/capacityPools/{poolName}/volumes/{volumeName} |
| Volume file path availability | elasticAccounts/{accountName}/elasticCapacityPools/{poolName}/checkVolumeFilePathAvailability | /locations/{location}/checkFilePathAvailability |

For more detailed information, see [Azure NetApp Files REST API](/rest/api/netapp).

## Supported features 

Elastic zone-redundant storage requires the use of availability zones. Not all features in the Flexible, Standard, Premium, and Ultra services levels are supported with Elastic zone-redundant storage. 

The Elastic zone-redundant service level supports:

* [Azure NetApp Files backup](backup-introduction.md)
* [Customer-managed keys](configure-customer-managed-keys.md)
* [Snapshots](snapshots-introduction.md)

## Next steps 

- [Storage hierarchy of Azure NetApp Files](azure-netapp-files-understand-storage-hierarchy.md)
- [Create a NetApp account](azure-netapp-files-create-netapp-account.md)
- [Set up a capacity pool](azure-netapp-files-set-up-capacity-pool.md)
- [Azure NetApp Files resource limits](azure-netapp-files-resource-limits.md)