---
title: Create snapshot policies for Elastic zone-redundant volumes in Azure NetApp Files
description: Learn how to create a snapshot policy to automate snapshot creation for volumes in Elastic zone-redundant storage.
services: azure-netapp-files
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: how-to
ms.date: 11/13/2025
ms.author: anfdocs

# Customer intent: "As a cloud storage administrator, I want to create a snapshot policy for Elastic Azure NetApp Files volumes to create data protection."
---
# Create snapshot policies for Elastic zone-redundant volumes in Azure NetApp Files

Snapshot policies enable you to schedule automatic point-in-time [snapshots](snapshots-introduction.md) of Azure NetApp Files volumes that you can use for recovery. Snapshot policies can be shared across volumes and modified at any time. 

[!INCLUDE [Snapshot policy workflows](includes/snapshot-policy.md)]

## More information 

- [Elastic resource limits](elastic-resource-limits.md)
- [Understand Azure NetApp Files snapshots](snapshots-introduction.md).