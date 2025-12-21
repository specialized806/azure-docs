---
title: Manage snapshot policies in Azure NetApp Files
description: Describes how to create, manage, modify, and delete snapshot policies by using Azure NetApp Files.
services: azure-netapp-files
author: b-hchen
ms.service: azure-netapp-files
ms.topic: how-to
ms.date: 11/17/2025
ms.author: anfdocs
# Customer intent: As a system administrator, I want to create and manage snapshot policies for Azure NetApp Files, so that I can ensure point-in-time recovery of volumes and streamline data management.
---

# Manage snapshot policies in Azure NetApp Files

[Snapshots](snapshots-introduction.md) enable point-in-time recovery of volumes. You can schedule for [volume snapshots](snapshots-introduction.md) to be taken automatically by using snapshot policies. You can also modify a snapshot policy as needed, or delete a snapshot policy that you no longer need.  

[!INCLUDE [Snapshot policy workflows](includes/snapshot-policy.md)]

## Edit the Hide snapshot path option

The Hide snapshot path option controls whether the snapshot path of a volume is visible. During the creation of an [NFS](azure-netapp-files-create-volumes.md#create-an-nfs-volume) or [SMB](azure-netapp-files-create-volumes-smb.md#add-an-smb-volume) volume, you can specify whether the snapshot path should be hidden. After creating the volume, you can edit the Hide snapshot path option as needed.  

> [!NOTE]
> For a [destination volume](cross-region-replication-create-peering.md#create-the-data-replication-volume-the-destination-volume) in cross-region replication, the Hide snapshot path option is disabled by default. The setting isn't modifiable. 

[!INCLUDE [Hide a snapshot's file path](includes/snapshot-hide-file-path.md)]

## Next steps

* [Troubleshoot snapshot policies](troubleshoot-snapshot-policies.md)
* [Resource limits for Azure NetApp Files](azure-netapp-files-resource-limits.md)
* [Learn more about snapshots](snapshots-introduction.md)
