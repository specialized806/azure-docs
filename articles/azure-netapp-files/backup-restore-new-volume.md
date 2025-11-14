---
title: Restore a backup to a new Azure NetApp Files volume
description: Describes how to restore a backup to a new volume.
services: azure-netapp-files
author: b-hchen
ms.service: azure-netapp-files
ms.topic: how-to
ms.date: 11/14/2025
ms.author: anfdocs
ms.custom: sfi-image-nochange
# Customer intent: As a cloud administrator, I want to restore a backup to a new volume in Azure NetApp Files, so that I can recover data without affecting existing volumes while ensuring proper capacity and protocol settings are maintained.
---
# Restore a backup to a new volume

When you restore a backup, a new volume is created using the same protocol type as the original. This article explains how to perform a restore.

## Considerations

[!INCLUDE [Backup restore considerations](includes/backup-restore-considerations.md)]

* When you're restoring a [large volume](large-volumes.md), the new volume must also be a large volume. For a regular volume, the new volume must also be a regular volume. 

* Restoring a backup to a new volume isn't dependent on the networking type used by the source volume. You can restore the backup of a volume configured with Basic networking to a volume configured with Standard networking and vice versa.

* For more information, see [Restoring volume backups from vaulted snapshots](snapshots-introduction.md#restoring-volume-backups-from-vaulted-snapshots). 


> [!IMPORTANT]
> Concurrently restoring multiple volumes might increase the time it takes for each individual, in-progress restore to complete. If time is a factor, prioritize and sequentialize the most important volume first. Wait until the restore operations complete before starting lower priority volume restores.  

See [Requirements and considerations for Azure NetApp Files backup](backup-requirements-considerations.md) for more considerations about using Azure NetApp Files backup. See [Resource limits for Azure NetApp Files](azure-netapp-files-resource-limits.md) for information about minimums and maximums. 

## Steps

>[!IMPORTANT]
>All backups must be migrated to backup vaults. You can't perform any operation on or with a backup until you have migrated the backup to a backup vault. For more information about this procedure, see [Manage backup vaults](backup-vault-manage.md).

[!INCLUDE [Backup restore steps](includes/backup-restore-steps.md)]

## Next steps  

* [Understand Azure NetApp Files backup](backup-introduction.md)
* [Requirements and considerations for Azure NetApp Files backup](backup-requirements-considerations.md)
* [Resource limits for Azure NetApp Files](azure-netapp-files-resource-limits.md)
* [Configure policy-based backups](backup-configure-policy-based.md)
* [Configure manual backups](backup-configure-manual.md)
* [Manage backup policies](backup-manage-policies.md)
* [Search backups](backup-search.md)
* [Delete backups of a volume](backup-delete.md)
* [Volume backup metrics](azure-netapp-files-metrics.md#volume-backup-metrics)
* [Azure NetApp Files backup FAQs](faq-backup.md)
* [How Azure NetApp Files snapshots work](snapshots-introduction.md)
