---
title: Create snapshot policies for Elastic zone-redundant volumes in Azure NetApp Files
description: Learn how to create a snapshot policy to automate snapshot creation for volumes in the Elastic zone-redundant service level.
services: azure-netapp-files
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: how-to
ms.date: 11/13/2025
ms.author: anfdocs

# Customer intent: "As a cloud storage administrator, I want to create a snapshot policy for Elastic Azure NetApp Files volumes to create data protection."
---
# Create snapshot policies for Elastic zone-redundant volumes in Azure NetApp Files

[Elastic resource limits](elastic-resource-limits.md)
[Understand Azure NetApp Files snapshots](snapshots-introduction.md).

## Create a snapshot policy

You can create snapshot policies when you create an [NFS](elastic-volume.md) or [SMB](elastic-volume-server-message-block.md) volume. You can create new policy 

1. Under Data protection, select **Snapshot policies**. 
1. Select **+ Create**. 
1. Provide inputs for the following fields: 
    - **Policy name** - Assign
    - **Snapshot schedule** - Select hourly, daily, weekly, or monthly.
    - **Retention** - Select the number of snapshots to preserve in storage.
    - Select when you want Azure NetApp Files to create your snapshots. If you choose hourly, select when in the hour. If you choose daily, select the time of day. If you choose weekly, choose the day of the week and time. If you choose monthly, select the days of the month (numerical) and time of day. 

    To create a secondary frequency for the snapshots, select **Add schedule** then provide the aforementioned inputs. 

    :::image type="content" source="./media/elastic-snapshots-policy/create-policy-elastic.png" alt-text="Screenshot showing how to create a snapshot policy." lightbox="./media/elastic-snapshots-policy/create-policy-elastic.png":::

1. Select **Create** to finalize the policy. 

1. After you create a policy, you need to [assign it to volumes to begin protecting your data](#apply-a-snapshot-policy-to-a-volume). 

## Apply a snapshot policy to a volume

1. Go to the **Volumes** page, right-click the volume that you want to apply a snapshot policy to, then select **Edit**.
1. In the Edit window, select the **Snapshot policy** dropdown. Choose the policy you want to add to the volume. 

    :::image type="content" source="./media/shared/edit-volume.png" alt-text="Screenshot showing how to edit a snapshot policy." lightbox="./media/shared/edit-volume.png":::

1. Select **Save** to apply the policy. 

## Edit a snapshot policy

1. Under Data protection, select **Snapshot policies**. 
1. Identify the snapshot policy you want to edit. Select the actions menu `...` at the end of the row for the policy then **Edit**.
1. To edit the name, enter a new name in the **Policy name** field.
1. To add a new snapshot schedule, select the snapshot frequency in the **Select type** dropdown, then **Add schedule**. 
    1. Enter a value in **Retention** for the number of snapshots you want to save. When the number of snapshots for the volume exceeds the retention count, Azure NetApp Files deletes the oldest snapshot. 
    1. Select when want Azure NetApp Files to create your snapshots. If you choose hourly, select when in the hour. If you choose daily, select the time of day. If you choose weekly, choose the day of the week and time. If you choose monthly, select the days of the month (numerical) and time of day. 
1. To edit an existing snapshot schedule, select the actions menu `...` at the end of the row with the schedule type. Choose **Edit**. 
    1. Modify the retention count or when the snapshot is created. 
1. To remove a snapshot schedule, select the actions menu `...` at the end of the row with the schedule type then **Remove**. <!-- what is impact if no schedules left-->
1. Select **Save** to apply your changes.

### Delete a snapshot policy

1. Under Data protection, select **Snapshot policies**. 
1. Identify the snapshot policy you want to edit. Select the actions menu `...` at the end of the row for the policy then **Delete**.
 