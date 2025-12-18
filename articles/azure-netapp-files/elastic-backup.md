---
title: Back up Elastic zone-redundant volumes in Azure NetApp Files
description: Learn how to create and manage backups of Elastic zone-redundant volumes in Azure NetApp Files.
services: azure-netapp-files
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: how-to
ms.date: 11/19/2025
ms.author: anfdocs
---
# Back up Elastic zone-redundant volumes in Azure NetApp Files

Azure NetApp Files backup expands the data protection capabilities of Azure NetApp Files by providing fully managed backup solution for long-term recovery, archive, and compliance. To learn more about backups, see [Azure NetApp Files backup](backup-introduction.md).

>[!NOTE]
>With the Elastic zone-redundant service level, Azure NetApp Files backup is limited to regions that support the [Elastic zone-redundant service level](elastic-zone-redundant-concept.md#supported-regions). 

Azure NetApp Files backups in the Elastic service level require a backup vault. Backup vaults are the organization unit for backups. You can create manual (on-demand) or policy-based (scheduled) backups. 

### Policy-based backups 

[!INCLUDE [Policy-based backups](includes/backup-policy.md)]

### Manual backups 

[!INCLUDE [Policy-based backups](includes/backup-manual.md)]

## Considerations

* For the Elastic zone-redundant service level, Azure NetApp Files backup is supported in all regions that support the [Elastic zone-redundant service level](elastic-zone-redundant-concept.md#supported-regions).
* With the Elastic zone-redundant service level, Azure NetApp Files supports daily, weekly, and monthly schedules for backup policies. 
* Deleting a volume does _not_ delete its backups. You must manually delete the backups. 
* You can't delete a volume when Backup is in progress* You can't delete the snapshot used for the most recent backup if there are backups on the volume. 
* Reverting a volume to state before existing backups results in an error. To proceed with reverting the volume, delete the backups causing the error then proceed with the revert. 
* In the Elastic zone-redundant service level account, backups aren't currently supported with cross-region replication. 
* Backup start times and duration might display incorrect values with a year of 1970. Incorrect dates will be fixed in a separate release. 

## Create a backup vault

Backup vaults store the backups for your Azure NetApp Files subscription. Although it's possible to create multiple backup vaults in your Azure NetApp Files account, it's recommended you have only one backup vault per account.

1. In your Azure NetApp Files account, select **Data protection** then **Backup vaults**. 
1. Select **+ Add backup vault**. 
1. Enter a **Name** for the backup vault then select **OK** to create the vault. 

## Assign volumes to a backup vault

1. In your Azure NetApp Files account, select **Data protection** then **Backup vaults**. 
<!-- >
1. To assign Elastic volumes to the backup vault, enter specific volume names then select **Assign**. Alternately, select **Browse** to view a list of all volumes. Select the volumes you want to assign then **Assign selected volumes**. 

    To remove volumes, select **Browse**. Select the action menu `...` next to an individual volume name then **Unassign**. 
1. Select **Save**. 
-->

## Delete a backup vault 

1. In your Azure NetApp Files account, select **Data protection** then **Backup vaults**. 
1. Identify the backup vault you want to delete, select the action menu `...` then **Delete**. 


## Create an on-demand backup

1. In your Azure NetApp Files account, select **Volumes** then **Backups**. 
1. Select **+ Add**. 
1. Assign a **Name** to the backup. 
    If you select **Use existing snapshot**, choose the snapshot to use as the basis for the backup from the dropdown list. If you leave this option unchecked, Azure NetApp Files creates a new snapshot for the backup.
1. Select **Create**. Once the backup is created, you can view it in the **Backups** menu. 


## Create a backup policy

<!-- backups to keep: the number of backups retained on the volume. Once the number of backups exceeds this number, older backups are automatically deleted. -->

1. In your Elastic service level Azure NetApp Files account, select **Backup policies** under the Data protection navigation menu. 
1. Select **+ Add Backup Policy**. 
1. Specify the **Backup Policy Name**. Enter values for the daily, weekly, and monthly backups you want to retain. 
1. Select **Create** to finish creating the policy.

## Modify a backup policy 

You can modify the schedule and retention count or a backup or disable it. 

1. In your Elastic service level Azure NetApp Files account, select **Backup Policies** under the Data protection navigation menu.
1. Select the action menu `...` at the end of the row with the backup policy name then **Edit**.

    * To turn off backups with the policy, switch the policy state to **Disabled**. To enable backups, switch the policy state to **Enabled**. 

    * **To modify the backup schedule**:
        Choose backup schedule then modify the **Backups to keep** value.

1. Select **Save**. 

## Delete a backup policy 

<!-- import from backup-delete.md -->

1. In your Elastic service level Azure NetApp Files account, select **Backup policies** under the Data protection navigation menu.
1. Select **Delete** to remove the backup policy. 

## Next steps 

- [Restore from a backup for for the Elastic zone-redundant service level](elastic-backup-restore.md)
- [Understand Azure NetApp Files backup](backup-introduction.md)
