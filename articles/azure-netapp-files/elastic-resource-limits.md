---
title: Resource limits for Azure NetApp Files Elastic zone-redundant service level
description: Describes limits for Azure NetApp Files Elastic zone-redundant service level
services: azure-netapp-files
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: concept-article
ms.date: 06/10/2025
ms.author: anfdocs
# Customer intent: As an IT administrator managing Azure NetApp Files, I want to understand the resource limits for the elastic service level so I can effectively plan and allocate storage resources for my organization’s needs.
---
# Resource limits for Azure NetApp Files Elastic service level

Understanding resource limits for Azure NetApp Files helps you manage your volumes.

>[!IMPORTANT]
>These limits pertain to the Elastic service level. For resource limits for the Flexible, Standard, Premium, and Ultra service levels, see [Azure NetApp Files resource limits](azure-netapp-files-resource-limits.md).

## Elastic service level resource limits

The following table outlines resource limits for the Elastic service level of Azure NetApp Files:

| Resource | Default limit | Adjustable via support request? |
| ---- | -- | - |
| Maximum number of Elastic zone-redundant NetApp accounts per subscription | 10 | Yes | 
| Number of capacity pools per NetApp account | 50 | No |
| Number of Elastic capacity pools per region per subscription  | 5 | Yes | 
| Number of volumes per capacity pool | 50 | No |
| Minimum size of a capacity pool | 1 TiB | No | 
| Maximum size of a capacity pool | 128 TiB | No | 
| Minimum size of a volume | 1 GiB | No | 
| Maximum size of a volume | 16 TiB | No |
| Maximum number of snapshots per volume | 255 | No | 
| Maximum number of export policy rules per volume | 5 | No | 
| Maximum number of quota rules per volume | 1,000| No | 

<!-- maxfiles -->
<!-- file, throughput, regional capacity per subscription, number of IPs / VNet, backups per day, backups, snapshots, |  # of CRR/CZR DP volumes, # volumes per subscription --> 

To request an increase where applicable, learn how to [Create a support request](azure-netapp-files-resource-limits.md#request-limit-increase).

## Next steps

* [Understand the Elastic zone-redundant service level](elastic-zone-redundant-concept.md)
