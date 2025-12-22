---
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: include
ms.date: 10/20/2025
ms.author: anfdocs
ms.custom: include file

# backup-restore-new-volume.md
# elastic-backup-restore.md
---

1. In Azure NetApp Files, locate the volume that contains the backup you want to restore from. Select **Backups**. 

2. From the backup list, select the backup to restore. Select the three dots (`…`) to the right of the backup, then select **Restore to new volume** from the Action menu.   

    :::image type="content" source="../media/backup-restore-new-volume/backup-restore-new-volume.png" alt-text="Screenshot of selecting restore backup to new volume." lightbox="../media/backup-restore-new-volume/backup-restore-new-volume.png":::

3. In the Create a Volume page, provide information for the fields in the page as applicable. 

    * The **Capacity pool** that the backup is restored into must have sufficient unused capacity to host the new restored volume. Otherwise, the restore operation fails.
    * The **Protocol** field is pre-populated from the original volume and cannot be changed.    
    * The **Quota** value must be **at least 20% greater** than the size of the backup from which the restore is triggered. Once the restore is complete, the volume can be resized depending on the size used. 

    Select **Review + Create** to begin restoring the backup to a new volume.

4. The Volumes page displays the new volume. In the Volumes page, the **Originated from** field identifies the name of the backup used to create the volume.