---
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: include
ms.date: 10/20/2025
ms.author: anfdocs
ms.custom: include file

# elastic-backup.md
# backup-configure-policy-based.md
---

Backups are long-running operations. The system schedules backups based on the primary workload (which is given higher priority) and runs backups in the background. Depending on the size of the volume being backed up, a backup can run in background for hours. There's no option to select the start time for backups. The service performs the backups based on the internal scheduling and optimization logic. 

Assigning a policy creates a baseline snapshot that is the current state of the volume and transfers the snapshot to Azure storage. This baseline snapshot is deleted automatically when the first scheduled backup is complete (based on the policy). If the backup policy is attached to a volume, the backup list will be empty until the baseline snapshot is transferred. When the backup is complete, the baseline backup entry appears in the list of backups for the volume. After the baseline transfer, the list will be updated daily based on the policy. An empty list of backups indicates that the baseline backup is in progress. If a volume already has existing manual backups before you assign a backup policy, the baseline snapshot isn't created. A baseline snapshot is created only when the volume has no prior backups.