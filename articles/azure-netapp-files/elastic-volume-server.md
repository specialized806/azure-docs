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

Azure NetApp Files supports NFSv3, NFSv4.1, and SMB3 volumes in the Elastic service level.  

>[!IMPORTANT]
>Windows Server 2025 currently doesn't work with the Azure NetApp Files SMB protocol.

>[!NOTE]
>This workflow is for the Elastic service level. For Flexible, Standard, Premium, and Ultra volumes, see [Create an NFS volume](azure-netapp-files-create-volumes.md) or [Create an SMB volume](azure-netapp-files-create-volumes-smb.md).

## Before you begin 

* You must have an Azure NetApp Files account configured to use the Elastic service level. 
* You must have configured a capacity pool for the Elastic service level. 
    * If you're creating SMB volumes, you must have configured Active Directory on the capacity pool. 
* If you're configure cross-zone-region replication, you must have a Elastic service level Netapp account in supported paired region. For more information, see [supported regional pairs](reliability.md#supported-cross-region-replication-pairs). 

## Considerations 

* You cannot change the protocol of a volume after creating it. 
* All volumes in a capacity pool must have unique names.
* In the Elastic service level, you can't move volumes between capacity pools. 
* Access-based enumeration and non-browsable shares aren't currently supported for SMB volumes in the Elastic service level. 

<!-- one create volume topic. use tabs -->

## Steps 

You can create an NFSv3, NFSv4.1, or SMB volume. Dual-protocol volumes aren't currently supported in the Elastic service level. 

1. In you Azure NetApp Files Elastic account, select **Volumes**. 
1. Select **+ Add Volume**. 
1. In the Basics tab: 
    * Select the **Capacity pool** the volume belongs to. 
    * Enter the **Volume name**. 
    * Assign the **Quota** in GiB. 
        For sizing limits, see [Azure NetApp Files Elastic service level resource limits](elastic-resource-limits.md). Maximum size is contingent on the capacity pool's quota. 
    Select **Next**. 
1. In the Protection tab, configure you protection settings.
    <!-- are these default -->
    * For snapshots, select **Enable local protection**. 
        Choose your **Snapshot policy**. If you haven't created a policy, select **Create one** to [create a snapshot policy](snapshot-manage-policy.md).
    * For backups, select **Enable backups**. 
        * Select the **Backup vault** or select **Create new** to create one. For more information, see [Create a backup vault](backup-vault-manage.md).
        * Select the **Backup policy** or select **Create new** to create one. For more information, see [Create a backup policy](backup-manage-policies.md).
        * Enter the retention period. Choose weeks or months. 
    * For replication across zones and/or regions, select **Enable replication**. 
        * Enter the <!-- $source-name? --> and select the frequency: hourly, daily, or weekly. 
        * Configure the destination volume: 
            * Enter the **Volume name**. 
            * Select the **Region**.
                If you're configuring cross-zone replication, choose the current region. For cross-region replication 
                Region selections must adhere to approved [cross-region replicaition pairs](replication.md#supported-cross-region-replication-pairs). 
            * Select the **Zone**. 
                The zone is required for cross-zone replication in the same region. It's optional for cross-region replication. 
            * Select the **NetApp account** in the correct region. 
            * Select the **Capacity pool** for the destination volume. 
            * Optionally, assign maximum throughput (MiB/s).
            * To configure a secondary replication source, select **Add another destination**.  
    Select **Next**.
1. Configure the **Protocol**. 
    * Choose **SMB**. 
    * The **Active Directory** account is set to the capacity pool configured for the account. 
    * Enter the **Share Name**. 
1. Select **Review + create**. 
1. Review your elections. Select **Create** to finalize the volume.
1. Return to the **Volume** menu then select your volume to view it. 

## Resize a volume 

## Next steps 

<!-- what can you do -->


    
