---
title: Manage snapshots for Elastic Zone-Redundant volumes in Azure NetApp Files
description: Learn how to create a snapshot policy for Elastic service level volumes for data protection.
services: azure-netapp-files
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: how-to
ms.date: 11/13/2025
ms.author: anfdocs

# Customer intent: "As a cloud storage administrator, I want to manage snapshots for Elastic Azure NetApp Files volumes to create data protection."
---

# Manage snapshots for Elastic Zone-Redundant volumes in Azure NetApp Files

With the Elastic Zone-Redundant service level, you can create snapshots on-demand. You can also manage

## Create an on-demand snapshot

[!INCLUDE [Create an on-demand snapshot](includes/snapshot-create.md)]

## Delete a snapshot

* You can't delete a snapshot if it's part of an active file-restore operation.
* You can't delete a replication generated snapshot that is used for volume baseline data replication.

### Steps

[!INCLUDE [Delete a snapshot](includes/snapshot-delete.md)]