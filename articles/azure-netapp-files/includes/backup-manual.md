---
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: include
ms.date: 10/20/2025
ms.author: anfdocs
ms.custom: include file

# elastic-backup.md
# backup-configure-manual.md
---

A manual backup takes a point-in-time snapshot of the active file system and backs up that snapshot to the Azure storage account.

The following list summarizes manual backup behaviors:  

* You can create manual backups on a volume even if the volume is already assigned to a backup vault and configured with backup policies. However, there can be only one outstanding manual-backup request for the volume. If you assign a backup policy and if the baseline transfer is still in progress, then the creation of a manual backup is blocked until the baseline transfer completes.

* Unless you specify an existing snapshot to use for a backup, creating a manual backup automatically generates a snapshot on the volume. The snapshot is then transferred to Azure storage. The snapshot created on the volume will be retained until the next manual backup is created. During the subsequent manual backup operation, older snapshots are cleaned up. You can't delete the snapshot generated for the latest manual backup. 