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

* You can restore backups only within the same NetApp account. Restoring backups across NetApp accounts isn't supported. 

* You can restore backups to a different capacity pool within the same NetApp account.

* You can restore a backup only to a new volume. You can't overwrite the existing volume with the backup. 

* The new volume created by the restore operation can't be mounted until the restore completes. 

* You should trigger the restore operation when there are no baseline backups. Otherwise, the restore might increase the load on the Azure Blob account where your data is backed up. 

* For volumes greater than 10 TiB, it can take multiple hours to transfer all the data from the backup media.

* In the Volume overview page, refer to the **Originated from** field to see the name of the snapshot used to create the volume. 