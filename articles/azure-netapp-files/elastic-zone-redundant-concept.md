---
title: Understand Azure NetApp Files zone-redundant storage
description: Understand the difference between hardware-based and zone-redundant storage. 
services: azure-netapp-files
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: article
ms.date: 01/09/2026
ms.author: anfdocs
ms.custom: references-regions 
---

# Understand Azure NetApp Files zone-redundant storage (preview)

Azure NetApp Files zone-redundant storage is cost‑optimized landing zone for unstructured data, built for modern workloads. 

It delivers built‑in local redundancy, shared QoS, and native multi‑tenancy with global regional availability—making it a natural fit for ISVs and SaaS solution providers. ​

Scale smaller volumes with flexible throughput, power backups, analytics staging, and AI datasets—all at an affordable price without compromising reliability.

Elastic zone-redundant storage offers built-in high-availability and zero recovery point objective (RPO). 

When creating your NetApp account, you must designate that the account is for zone-redundant storage. An Elastic NetApp account can only be used for Elastic zone-redundant storage.

## Elastic zone-redundant service

In comparison to existing Azure NetApp Files service levels, Elastic zone-redundant storage offers:

<!-- Elastic ZR volumes write synchronously across Availability Zones (AZ) for zero‑data‑loss continuity and trigger platform‑managed failover in under two minutes -->
<!-- 

What is Azure NetApp Files zone redundant? 

Azure NetApp Files zone redundant ensures robust data resiliency and availability through synchronous replication across multiple zones within a region. It offers automated and transparent failover and user-defined availability zones, allowing for tailored operational continuity. This feature provides enterprise-grade storage to protect against zonal outages and ensures availability for mission-critical applications, combined with the ability to dynamically scaling to meet workload demands. 

Why Azure NetApp Files zone redundant? 

Organizations today face increasing demands for robust data resilience and scalability in their cloud infrastructures. Azure NetApp Files zone redundant addresses these challenges by fortifying system reliability, reducing downtime risks and improving operational excellence. By ensuring continuous data availability and access across Azure availability zones, this new capability aligns with the principles of reliability, operational excellence, and performance efficiency. 

Key Benefits 

Reliability: Offers automated failover and synchronous data mirroring across zones, ensuring continuity during zonal outages. 

User-Defined Availability Zones: Flexibly define failover priorities, tailoring the system to your specific needs. 

Operational excellence: Enables flexible management of resources with scalable capacity pools, allowing shared QoS across volumes to adapt to changing workloads seamlessly. 
-->

- Zone redundancy that can persist if a zonal outage occurs in a single region 
- Transparent failover if a zonal outage occurs
- Seamless growth from 1 GiB without specialized hardware 

Zone-redundant storage is designed for small workloads, offering capacity pools that scale from 1 TiB to 128 TiB.

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
* UK South 
* West Europe
* West US 2
* West US 3
<!-- issues with France Central, Germany West Central, and Spain Central. Spain Central removed. --> 

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
| Integrated backup | Integrated backup and recovery | Limited backup and recovery | 
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

Elastic zone-redundant storage requires the use of [availability zones](../reliability/reliability-netapp-files.md). Not all features int he Flexible, Standard, Premium, and Ultra services levels are supported with Elastic zone-redundant storage. 

The Elastic zone-redundant service level supports:

* [Azure NetApp Files backup](backup-introduction.md)
* [Customer-managed keys](configure-customer-managed-keys.md)
* [Snapshots](snapshots-introduction.md)

## Next steps 

- [Storage hierarchy of Azure NetApp Files](azure-netapp-files-understand-storage-hierarchy.md)
- [Create a NetApp account](azure-netapp-files-create-netapp-account.md)
- [Set up a capacity pool](azure-netapp-files-set-up-capacity-pool.md)
- [Azure NetApp Files resource limits](azure-netapp-files-resource-limits.md)