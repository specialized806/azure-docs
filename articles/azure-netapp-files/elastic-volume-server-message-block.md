---
title: Create an SMB volume for the Elastic service level in Azure NetApp Files 
description: Learn about the requirements and steps to create an SMB volume for the Elastic service level in Azure NetApp Files. 
services: azure-netapp-files
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: how-to
ms.date: 11/18/2025
ms.author: anfdocs
# Customer intent: As a cloud administrator, I want to create an SMB volume in Azure NetApp Files, so that I can leverage scalable storage solutions that meet my organization’s data management and sharing requirements.
---
# Create an SMB volume for the Elastic service level in Azure NetApp Files 

Learn how to create an SMB volume for the Elastic service level. 

>[!NOTE]
>This workflow is for the Elastic service level. For Flexible, Standard, Premium, and Ultra volumes, see [Create an SMB volume](azure-netapp-files-create-volumes-smb.md).

## Before you begin 

* You must have an Azure NetApp Files account configured to use the Elastic service level. 
* You must have configured a capacity pool for the Elastic service level. 
    * If you're creating SMB volumes, you must have configured Active Directory on the capacity pool. 
* If you're configuring cross-zone-region replication, the Elastic service level NetApp account must be placed in a region that adheres to supported regional pairs. For more information, see [supported regional pairs](replication.md#supported-region-pairs). 

## Considerations 

* You can't change the protocol of a volume after creating it. 
* Each volume in a capacity pool must have a unique name.
* In the Elastic service level, you can't move volumes between capacity pools. 
* Access-based enumeration and non-browsable shares aren't currently supported for SMB volumes in the Elastic service level. 

<!-- bugs  -->

* If SMB volume creation fails with the error "Error when creating. A problem occurred. Please try again after some time. If the issue persists, please contact support." the Active Directory password has expired and needs to be reset. Reset the password then try to create the password again. 

## Steps 

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
        <!-- delete this section -->

    Select **Next**.

    :::image type="content" source="./media/shared/elastic-create-volume-protection.png" alt-text="Screenshot of the volume creation protection tab." lightbox="./media/shared/elastic-create-volume-protection.png":::

1. Configure the **Protocol**. 

    * Choose **SMB**. 
        When you choose SMB, the **Active Directory** account is automatically set to the Active Directory account configured for the account. If the account is not assigned and you have an Active Directory account for the account, select **Refresh**.  
    * Enter the **Share Name**. 
    * Select **Enable SMB3 Protocol Encryption** to encrypt SMB3 data in-flight. 

        If you enable SMB3 encyrption, SMB clients not using SMB3 encryption can't access this volume. Data at rest is encrypted regardless of this setting. For more information, see [SMB encryption](azure-netapp-files-smb-performance.md#smb-encryption).

    :::image type="content" source="./media/elastic-volume-server-message-block/elastic-create-volume-protocol.png" alt-text="Screenshot of the volume creation protocol tab." lightbox="./media/elastic-volume-server-message-block/elastic-create-volume-protocol.png":::

1. Select **Review + create**. 
1. Review your selections. Select **Create** to finalize the volume.
1. Return to the **Volume** menu then select your volume to view it. 

## Resize a volume 

1. In your NetApp account, select **Volumes**. 
1. Locate the volume you want to resize. Select the three dots `...` then **Modify volume**. 
1. Enter the new **Quota** value.

    :::image type="content" source="./media/shared/edit-volume.png" alt-text="Screenshot showing how to edit a snapshot policy." lightbox="./media/shared/edit-volume.png":::

1. Select **Save**. 

## Next steps 

* [Understand the Elastic zone-redundant service level](elastic-zone-redundant-concept.md)

   
