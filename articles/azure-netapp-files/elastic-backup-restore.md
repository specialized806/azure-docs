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

## Restore a volume from a backup

[!INCLUDE [Backup restore steps](includes/backup-restore-steps.md)]

## Next steps

- [Understand Azure NetApp Files backup](backup-introduction.md)
- [Manage backups for the Elastic zone-redundant service level](elastic-backup.md)