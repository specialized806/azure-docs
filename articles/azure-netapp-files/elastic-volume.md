---
title: Create an NFS volume for Azure NetApp Files Elastic zone-redundant storage
description: Learn about the requirements and steps to create an NFS volume for Elastic zone-redundant storage in Azure NetApp Files. 
services: azure-netapp-files
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: how-to
ms.date: 11/18/2025
ms.author: anfdocs
---
# Create an NFS volume for Azure NetApp Files Elastic zone-redundant storage

Learn how to create an NFS volume for the Elastic zone-redundant storage.

>[!NOTE]
>This workflow is for Elastic zone-redundant storage. For Flexible, Standard, Premium, and Ultra volumes, see [Create an NFS volume](azure-netapp-files-create-volumes.md). 

## Before you begin 

* You must have a NetApp Elastic account. 
* You must have configured a capacity pool with the Zone-redundant service level. 

## Considerations 

* You can't change the protocol of a volume after creating it. 
* Each volume in a capacity pool must have a unique name.
* In Elastic zone-redundant storage, you can't move volumes between capacity pools. 

<!-- unix permissions, chown root access -->

## Steps 

1. In your account, select **Volumes**. 
1. Select **+ Add Volume**. 
1. In the Basics tab: 
    * Select the **Capacity pool** the volume belongs to. 
    * Enter the **Volume name**. 
    * Assign the **Quota** in GiB. 
        For sizing limits, see [Azure NetApp Files Elastic service level resource limits](elastic-resource-limits.md). 

    Select **Show advanced section** to add a [configured snapshot policy](elastic-snapshots-policy.md) or [hide the snapshot path](elastic-snapshots-manage.md#edit-the-hide-snapshot-path-option). You can also change the options in the advanced section after you create the volume. 

    Select **Next**. 

    :::image type="content" source="./media/shared/elastic-create-volume.png" alt-text="Screenshot the volume creation Basic tab." lightbox="./media/shared/elastic-create-volume.png":::

1. Configure the **Protocol**. 

    * For the Protocol type, choose **NFS**.
    * Enter the **File path**. 
    * In the Version dropdown, choose either **NFSv3** or **NFSv4**. Azure NetApp Files supports NFSv3 and NFSv4.1. For information on the difference between NFS versions, see [Understand NAS protocols](network-attached-storage-protocols.md#network-file-system-nfs).
    * Optionally, [configure export policy for the NFS volume](azure-netapp-files-configure-export-policy.md)

    :::image type="content" source="./media/elastic-volume/volume-protocol.png" alt-text="Screenshot of the volume creation protocol tab." lightbox="./media/elastic-volume/volume-protocol.png":::

1. Select **Review + create**. 

1. Review your selections. Select **Create** to finalize the volume.
1. Return to the **Volume** menu then select your volume to view it. 

    >[!NOTE]
    >You can't perform any operations on the volume until it has created successfully. 

## Resize a volume 

1. In your NetApp account, select **Volumes**. 
1. Select the volume you want to modify. 
1. In the overview for the volume, select **Resize**. 
1. Enter the new quota in GiB in the **Quota** field. The Available quota displays the available space in the capacity pool.

    :::image type="content" source="./media/shared/edit-volume.png" alt-text="Screenshot showing how to edit a snapshot policy." lightbox="./media/shared/edit-volume.png":::

1. Select **OK** to confirm the new quota. 

## Next steps 
* [Understand Elastic zone-redundant storage](elastic-zone-redundant-concept.md) 
* [Mount an NFS volume](azure-netapp-files-mount-unmount-volumes-for-virtual-machines.md)