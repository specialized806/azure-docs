---
title: Restore from snapshots for Azure NetApp Files Elastic zone-redundant volumes
description: Learn how to restore a volume from a snapshot in Azure NetApp Files' Elastic service level.
services: azure-netapp-files
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: how-to
ms.date: 11/13/2025
ms.author: anfdocs

# Customer intent: "As a cloud storage administrator, I want to restore a volume using the Elastic zone-redundant storage level in Azure NetApp Files. 
---
# Restore from snapshots for Azure NetApp Files Elastic zone-redundant volumes

With the Elastic zone-redundant service level, you can use snapshots to restore to a new volume or revert the volume to its point-in-time snapshot. For more information, see [How Azure NetApp Files snapshots work](snapshots-introduction.md).

## Revert a volume 

Reverting a volume using snapshot revert isn't supported on Azure NetApp Files volumes that have backups.

> [!IMPORTANT]
> Active filesystem data and snapshots taken after the selected snapshot will be lost. The snapshot revert operation replaces *all* the data in the targeted volume with the data in the selected snapshot. You should pay attention to the snapshot contents and creation date when you select a snapshot. You can't undo reverting a snapshot.

### Steps

[!INCLUDE [Revert a snapshot](includes/snapshot-revert.md)]

## Restore to a new volume

[Snapshots](snapshots-introduction.md) enable point-in-time recovery of volumes. You can use a snapshot to restore the data to a new volume. 

### Considerations 

* The new volume must be in the same capacity pool that contains the source snapshot. 
* When restoring a snapshot to a new volume in the Elastic zone-redundant service level, the volume quota is set to 1 GiB instead of the source volume's quota. You must manually [modify the volume's quota](elastic-volume-server-message-block.md#resize-a-volume) to the correct value. 

>[!TIP]
>To avoid unnecessary slowness in the restore operation, only restore one snapshot to a new volume at a time. 

### Steps 

1. Navigate to the volume hosting the snapshot you want to restore. Select **Snapshots** from the Volume page to display the snapshot list. 

2. Right-click the snapshot to restore and select **Restore to new volume** from the menu option.  

    :::image type="content" source="./media/shared/snapshot-actions.png" alt-text="Screenshot showing the options when right-clicking a snapshot."::: 

3. In the **Restore to a new volume** page, provide a **Volume name** and **Quota** value in GiB. The capacity pool is pre-selected based on the capacity pool that contains the volume. 

    Optionally, select **Show advanced options** where you can assign a snapshot policy to the volume and choose to hide the snapshot path. 

    :::image type="content" source="./media/elastic-snapshot-restore/elastic-restore-new-volume.png" alt-text="Screenshot Restore to a new field option.":::

    The new volume uses the same protocol that the snapshot uses.   
    For information about the fields in the Create a Volume page, see: 
    * [Create an NFS volume](elastic-volume.md)  
    * [Create an SMB volume](elastic-volume-server-message-block.md)    

    <!-- By default, the new volume includes a reference to the snapshot that was used for the restore operation from the original volume from Step 2, referred to as the *base snapshot*. This base snapshot does *not* consume any additional space because of [how snapshots work](snapshots-introduction.md). -->

1. Select **Review + create** to review your choices. Select **Create** to begin the restore process. 
    The Volumes page displays the new volume to which the snapshot restores. Refer to the **Originated from** field to see the name of the snapshot used to create the volume. 

## More information 

* [How Azure NetApp Files snapshots work](snapshots-introduction.md).