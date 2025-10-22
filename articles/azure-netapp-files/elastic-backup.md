---
title: Back up Elastic Zone-Redundant volumes in Azure NetApp Files
description: Learn how to create and manage backups of Elastic Zone-Redundant volumes in Azure NetApp Files.
services: azure-netapp-files
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: how-to
ms.date: 08/14/2025
ms.author: anfdocs
---
# Back up Elastic Zone-Redundant volumes in Azure NetApp Files

Azure NetApp Files backup expands the data protection capabilities of Azure NetApp Files by providing fully managed backup solution for long-term recovery, archive, and compliance. To learn more about backups, see [Azure NetApp Files backup](backup-introduction.md).

>[!NOTE]
>With the Elastic Zone-Redundant service level, Azure NetApp Files backup is limited to regions that support the [Elastic Zone-Redundant service level](elastic-zone-redundant-concept.md#supported-regions). 

Azure NetApp Files backups in the Elastic service level require a backup vault. Backups vaults are the organization unit for backups. You can create manual (on-demand) or policy-based (scheduled) backups. 

### Policy-based backups 

[!INCLUDE [Policy-based backups](includes/backup-policy.md)]

### Manual backups 

[!INCLUDE [Policy-based backups](includes/backup-manual.md)]

## Considerations

* For the Elastic Zone-Redundant service level, Azure NetApp Files backup is supported in all regions that support the [Elastic Zone-Redundant service level](elastic-zone-redundant-concept.md#supported-regions).
* With the Elastic Zone-Redundant service level, Azure NetApp Files supports daily, weekly, and monthly schedules for backup policies. 
* Deleting a volume does _note_ delete its backups. You must manually delete the backups. 
* If you delete a volume while a backup is in progress, the backup operation is terminated. 
* You can't delete the snapshot used for the most recent backup if there are backups on the volume. 
<!-- snapshots or backups? -->
* Reverting a volume to state before existing backups results in an error. To proceed with reverting the volume, delete the backups causing the error then proceed with the revert. 
* In the Elastic Zone-Redundant service level account, backups aren't currently supported with cross-region replication. 


## Create a backup vault

Backup vaults store the backups for your Azure NetApp Files subscription. Although it's possible to create multiple backup vaults in your Azure NetApp Files account, it's recommended you have only one backup vault per account.

1. In your Azure NetApp Files account, select **Data protection** then **Backup vaults**. 
1. Select **+ Create backup vault**. 
1. Enter a **Name** for the backup vault.
1. Optionally, assign Elastic volumes to the backup vault. Enter specific volume names and select or **Assign**. Alternately, select **Browse** to view a list of all volumes. Select the volumes you want to assign then **Assign selected volumes**. 
1. Review the list of volumes then select **Create**. 

## Modify a backup vault

1. In your Azure NetApp Files account, select **Data protection** then **Backup vaults**. 
1. Identify the backup vault you want to modify, select the action menu `...` then **Edit**. 
<!-- confirm unassign -->
1. To assign Elastic volumes to the backup vault, enter specific volume names and select or **Assign**. Alternately, select **Browse** to view a list of all volumes. Select the volumes you want to assign then **Assign selected volumes**. 

    To remove volumes, select **Browse**. Select the action menu `...` next to an individual volume name then **Unassign**. 
1. Select **Save**. 

## Create a backup policy

<!-- backups to keep: the number of backups retained on the volume. Once the number of backups exceeds this number, older backups are automatically deleted. -->

## Create an on-demand backup


## Modify a backup policy 

## Delete a backup policy 

## Delete a backup 


