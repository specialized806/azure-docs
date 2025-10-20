---
title: Back up Elastic Zone-Redundant volumes in Azure NetApp Files
description: Learn how to create and manage backups of Elastic Zone-Redundant volumes in Azure NetApp Files.
services: azure-netapp-files
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: how-to
ms.date: 08/14/2025
ms.author: anfdocs

# Customer intent: "As a cloud storage administrator, I want to create a capacity pool for Azure NetApp Files so that I can manage the storage volumes and configure their performance requirements effectively."
---
# Back up Elastic Zone-Redundant volumes in Azure NetApp Files


Azure NetApp Files backups 

For more information, see [Azure NetApp Files backup](backup-introduction.md).


## Before you begin 

* You must have configured a [backup vault](backup-vault-manage.md) for your Elastic Zone-Redundant service level account. 
* Backups are supported with cross-region replication on the same source volume. 

* Deleting a volume does _note_ delete its backups. You must manually delete the backups. 

* You can't delete the snapshot used for the most recent backup if there are backups on the volume. 

<!-- snapshots or backups? -->
* Reverting a volume to state before existing backups results in an error. To proceed with reverting the volume, delete the backups causing the error then proceed with the revert. 

* In the Elastic Elastic Zone-Redundant service level account, backups aren't currently supported with cross-region replication. 


## Considerations

* For the Elastic Zone-Redundant service level, Azure NetApp Files backup is supported in all regions that support the [Elastic Zone-Redundant service level](elastic-zone-redundant-concept.md#supported-regions).
* With the Elastic Zone-Redundant service level, Azure NetApp Files supports daily, weekly, and monthly schedules for backup policies. 


## Create a backup vault

1. In your Azure NetApp Files account, select **Data protection** then **Backup vaults**. 
1. Select **+ Create backup vault**. 
1. Enter a **Name** for the backup vault.
1. Optionally, assign Elastic volumes to the backup vault. Enter specific volume names and select or **Assign**. Alternately, select **Browse** to view a list of all volumes. Select the volumes you want to assign then **Assign selected volumes**. 
1. Review the lsit of volumes then select **Create**. 

## Modify a backup vault

1. In your Azure NetApp Files account, select **Data protection** then **Backup vaults**. 
1. Identify the backup vault you want to modify, select the action menu `...` then **Edit**. 
1. To assign Elastic volumes to the backup vault, enter specific volume names and select or **Assign**. Alternately, select **Browse** to view a list of all volumes. Select the volumes you want to assign then **Assign selected volumes**. 
<!-- is this right -->
    To remove volumes, select **Browse**. Select the action menu `...` next to an individual volume name then **Unassign**. 
1. Select **Save**. 

## Create a backup policy


## Create an on-demand backup


## Modify a backup policy 

## Delete a backup policy 

## Delete a backup 