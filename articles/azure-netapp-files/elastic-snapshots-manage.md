---
title: Manage snapshots for Elastic zone-redundant volumes in Azure NetApp Files
description: Learn how to create on-demand snapshots and delete snapshots for volumes using Elastic zone-redundant storage in Azure NetApp Files.
services: azure-netapp-files
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: how-to
ms.date: 01/09/2026
ms.author: anfdocs

# Customer intent: "As a cloud storage administrator, I want to manage snapshots for Elastic Azure NetApp Files volumes to create data protection."
---

# Manage snapshots for Elastic zone-redundant volumes in Azure NetApp Files

In addition to policy-based snapshots, you can also create a snapshot on demand with Elastic zone-redundant storage to create an out-of-band restore point or clone. 

Managing snapshots also includes deleting unnecessary snapshots and managing the visibility of the snapshot path. 

## Create an on-demand snapshot

[!INCLUDE [Create an on-demand snapshot](includes/snapshot-create.md)]

## Delete a snapshot

[!INCLUDE [Delete a snapshot](includes/snapshot-delete.md)]

## Edit the Hide snapshot path option

The Hide snapshot path option controls whether the snapshot path of a volume is visible. During the creation of an [NFS](elastic-volume.md) or [SMB](elastic-volume-server-message-block.md) volume, you can specify whether the snapshot path should be hidden. After creating the volume, you can edit the Hide snapshot path option as needed.  

>[!NOTE]
>If you edit the hide snapshot path option, you have to remount the volume. 

[!INCLUDE [Hide a snapshot's file path](includes/snapshot-hide-file-path.md)]

## More information

- [Understand Azure NetApp Files snapshots](snapshots-introduction.md)