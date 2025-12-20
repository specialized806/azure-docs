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

1. In your Azure NetApp Files account, select **Backup vaults** in the Data Protection section. 
1. Select **+ Add backup vault**. 
1. Enter a **Name** for the backup vault then select **OK** to create the vault. 

## Delete a backup vault 

1. In your Azure NetApp Files account, select **Data protection** then **Backup vaults**. 
1. Identify the backup vault you want to delete, select the action menu `...` then **Delete**. 
1. In the pop-up, select **Yes** to confirm you want to create the backup vault. 


## Create an on-demand backup

>[!NOTE]
>You must have created a backup vault before you can create an on-demand backup. 

1. In your Azure NetApp Files account, select **Volumes**.
1. Select the volume you want to create a back up for.
1. From the volume overview, select **Backups**. 
1. Select **+ Add Backup**. 
1. Assign a **Name** to the backup. The backup name should be between 3 and 255 characters. As a best practices, assign a descriptive name that identifies the capacity pool, volume, 

    Optionally, select **Use existing snapshot** to use an existing snapshot as the basis for the backup then choose the snapshot from the dropdown menu. If you leave this option unchecked, Azure NetApp Files creates a new snapshot for the backup.

    :::image type="content" source="./media/elastic-backup/new-on-demand.png" alt-text="Screenshot of a new on-demand backup." lightbox="./media/elastic-backup/new-on-demand.png":::

1. Select **Create**. Once the backup is created, you can view it in the **Backups** menu under the volume. 

## Create a backup policy

<!-- backups to keep: the number of backups retained on the volume. Once the number of backups exceeds this number, older backups are automatically deleted. -->

1. In your NetApp Elastic account, select **Backup policies** under the Data protection navigation menu. 
1. Select **+ Add Backup Policy**. 
1. Specify the **Backup Policy Name**.
1. To activate the policy, toggle it to **Enabled**.
1. Enter values for the number of daily, weekly, and monthly backups you want to retain. 
1. Select **Save** to create the policy. 

## Modify a backup policy 

You can modify the retention count of a backup policy or disable it. 

1. In your NetApp Elastic account, select **Backup Policies** under the Data protection navigation menu.
1. Select the action menu `...` at the end of the row with the backup policy name then **Edit**.

    * To turn off backups with the policy, switch the policy state to **Disabled**. To activate backups, switch the policy state to **Enabled**. 

    * **To modify the backup schedule**:
        Choose backup schedule then modify the **Backups to keep** value.

1. Select **Save**. 

## Assign a backup policy to a volume

1. Navigate to **Volumes** then select the volume for which you want to configure backups.
1. From the selected volume, select **Backups** then **Configure Backups**.
1. In the **Configure Backups** page, select the **Backup vault** for the backups. 
    Select a **Backup policy** from the dropdown then select **Enabled** to activate the policy on the volume. 

    :::image type="content" source="./media/elastic-backup/assign-policy.png" alt-text="Screenshot of assigning a backup policy." lightbox="./media/elastic-backup/assign-policy.png":::

1. Select **OK** to start creating backups on the volume. 

## Bulk assign a policy to volumes 

1. In your NetApp Elastic account, select **Backup Policies** under the Data protection navigation menu.
1. Identify the policy you want to assign to volumes. Select the three dots `...` in the Actions column for the policy then **Assign volumes**. 
1. Select the volumes you want to back up with the policy.
1. Select **Assign policy** to back up the volumes with the policy. Select **Yes** to confirm the assignment. 

## Delete a backup policy 

<!-- import from backup-delete.md -->

1. In your Elastic service level Azure NetApp Files account, select **Backup Policies** under the Data protection navigation menu.
1. Identify the policy you want to delete then select the three dots `...` to see the action menu for the policy. Select **Delete** to remove the backup policy. 
1. Select **Yes** to confirm you want to delete the policy. 

## Next steps 

- [Restore from a backup for for the Elastic zone-redundant service level](elastic-backup-restore.md)
- [Understand Azure NetApp Files backup](backup-introduction.md)
