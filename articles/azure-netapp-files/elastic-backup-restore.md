---
title: Restore a backup of an Elastic zone-redundant volume in Azure NetApp Files
description: Learn how to restore backups of Elastic zone-redundant volumes in Azure NetApp Files.
services: azure-netapp-files
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: how-to
ms.date: 10/31/2025
ms.author: anfdocs
---
# Restore to a new volume with a backup of an Elastic zone-redundant volume in Azure NetApp Files

If you need to restore from a backup, you can create a new volume in the same account with the same protocol as the backup. 

## Considerations

[!INCLUDE [Backup restore considerations](includes/backup-restore-considerations.md)]

## Restore to a new volume from a backup

1. In Azure NetApp Files, locate the volume that contains the backup you want to restore from. Select **Backups**. 

2. From the backup list, select the backup to restore. Select the three dots (`…`) to the right of the backup, then select **Restore to new volume** from the Action menu.   

    :::image type="content" source="./media/backup-restore-new-volume/backup-restore-new-volume.png" alt-text="Screenshot of selecting restore backup to new volume." lightbox="./media/backup-restore-new-volume/backup-restore-new-volume.png":::

3. Provide information for the fields in the page as applicable. 

    * The **Capacity pool** that the backup is restored into must have sufficient unused capacity to host the new restored volume. Otherwise, the restore operation fails.
    * The **Volume name** must adhere to [naming rules and restrictions for Azure resources](../azure-resource-manager/management/resource-name-rules.md#microsoftnetapp) for character limits and other naming conventions.
    * The **Quota** value must be **at least 20% greater** than the size of the backup from which the restore is triggered. Once the restore is complete, the volume can be resized depending on the size used. 
    
    :::image type="content" source="./media/elastic-backup-restore/create-volume.png" alt-text="Screenshot of selecting restore backup to new volume." lightbox="./media/elastic-backup-restore/create-volume.png":::

    Select **Next**.

1. The **Protocol** field is pre-populated from the original volume and cannot be changed. You must enter a new **File path**.  

    Select **Review + create**.

1. Review your choices. Select **Create** to initiate the restore operation. 

4. The Volumes page displays the new volume. In the Volumes page, the **Originated from** field identifies the name of the backup used to create the volume.

## Next steps

- [Understand Azure NetApp Files backup](backup-introduction.md)
- [Manage backups for the Elastic zone-redundant storage](elastic-backup.md)