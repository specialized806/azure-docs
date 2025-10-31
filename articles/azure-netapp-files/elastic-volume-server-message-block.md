---
title: Create an SMB volume for the Elastic service level in Azure NetApp Files 
description: Learn about the requirements and steps to create an SMB volume for the Elastic service level in Azure NetApp Files. 
services: azure-netapp-files
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: how-to
ms.date: 09/11/2025
ms.author: anfdocs
# Customer intent: As a cloud administrator, I want to create an SMB volume in Azure NetApp Files, so that I can leverage scalable storage solutions that meet my organization’s data management and sharing requirements.
---
# Create an SMB volume for the Elastic service level in Azure NetApp Files 

Learn how to create an SMB volume for the Elastic service level. 

>[!NOTE]
>This workflow is for the Elastic service level. For Flexible, Standard, Premium, and Ultra volumes, see [Create an SMB volume](azure-netapp-files-create-volumes-smb.md).

[!INCLUDE [Windows Server 2025 warning](includes/windows-server-2025.md)]


## Before you begin 

* You must have an Azure NetApp Files account configured to use the Elastic service level. 
* You must have configured a capacity pool for the Elastic service level. 
    * If you're creating SMB volumes, you must have configured Active Directory on the capacity pool. 
* If you're configuring cross-zone-region replication, the Elastic service level NetApp account must be placed in a region that adheres to supported regional pairs. For more information, see [supported regional pairs](replication.md#supported-region-pairs). 

[!INCLUDE [Availability zone role-based access control call-out.](includes/availability-zone-roles.md)]

## Considerations 

* You cannot change the protocol of a volume after creating it. 
* Each volume in a capacity pool must have a unique name.
* In the Elastic service level, you can't move volumes between capacity pools. 
* Access-based enumeration and non-browsable shares aren't currently supported for SMB volumes in the Elastic service level. 

<!-- bugs  -->

* If SMB volume creation fails with the error "Error when creating. A problem occurred. Please try again after some time. If the issue persists, please contact support," the Active Directory password has expired and needs to be reset. Reset the password then try to create the password again. 

## Steps 

You can create an NFSv3, NFSv4.1, or SMB volume. Dual-protocol volumes aren't currently supported in the Elastic service level. 

1. In you NetApp account, select **Volumes**. 
1. Select **+ Add Volume**. 
1. In the Basics tab: 
    * Select the **Capacity pool** the volume belongs to. 
    * Enter the **Volume name**. 
    * Assign the **Quota** in GiB. 
        For sizing limits, see [Azure NetApp Files Elastic service level resource limits](elastic-resource-limits.md). Maximum size is contingent on the capacity pool's quota. 
    Select **Next**. 

    :::image type="content" source="./media/shared/elastic-create-volume.png" alt-text="Screenshot the volume creation Basic tab." lightbox="./media/shared/elastic-create-volume.png":::

1. In the Protection tab, provide the following details.

    Snapshots, backup, and replication are enabled by default for volumes, however you must have appropriate policies and resources configured to protection. To disable any type of protection, uncheck the box before proceeding. 
    <!-- are these default -->
    * For snapshots, select **Enable local protection**. 
        Choose your **Snapshot policy**. If you haven't created a policy, select **Create one** to [create a snapshot policy](snapshots-manage-policy.md).
    * For backups, select **Enable backups**. 
        * Select the **Backup vault** or select **Create new** to create one. For more information, see [Create a backup vault](backup-vault-manage.md).
        * Select the **Backup policy** or select **Create new** to create one. For more information, see [Create a backup policy](backup-manage-policies.md).
        * Enter the retention period. Choose weeks or months. 
    * For replication across zones and/or regions, provide the following details. 
        * Enter the <!-- $source-name? --> and select the frequency: hourly, daily, or weekly. 
        * Configure the destination volume: 
            * Enter the **Volume name**. 
            * Select the **Region**.
                If you're configuring cross-zone replication, choose the current region. For cross-region replication 
                Region selections must adhere to supported [cross-region replication pairs](replication.md#supported-region-pairs). 
            * Select the **Zone**. 
                The zone is required for cross-zone replication in the same region. It's optional for cross-region replication. 
            * Select the **NetApp account** in the correct region. 
            * Select the **Capacity pool** for the destination volume. 
            * Optionally, assign maximum throughput (MiB/s).
            * To configure a secondary replication source, select **Add another destination**.  
    Select **Next**.

    :::image type="content" source="./media/shared/elastic-create-volume-protection.png" alt-text="Screenshot of the volume creation protection tab." lightbox="./media/shared/elastic-create-volume-protection.png":::

1. Configure the **Protocol**. 
    * Choose **SMB**. 
    * The **Active Directory** account is set to the capacity pool configured for the account. 
    * Enter the **Share Name**. 

    :::image type="content" source="./media/shared/elastic-create-volume-protocol.png" alt-text="Screenshot of the volume creation protocol tab." lightbox="./media/shared/elastic-create-volume-protocol.png":::

1. Select **Review + create**. 
1. Review your selections. Select **Create** to finalize the volume.
1. Return to the **Volume** menu then select your volume to view it. 

## Resize a volume 

1. In your NetApp account, select **Volumes**. 
1. Locate the volume you want to resize. Select the three dots `...` then **Modify volume**. 
1. Enter the new **Quota** value.
1. Select **Save**. 

## Next steps 

* [Understand the Elastic zone-redundant service level](elastic-zone-redundant-concept.md)

<!-- what can you do -->


    
