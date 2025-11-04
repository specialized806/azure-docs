---
title: Configure cross-region replication for Elastic Zone-Redundant volumes in Azure NetApp Files
description: Learn how to configure cross-region replication for disaster recovery with the Elastic Zone-Redundant volumes in Azure NetApp Files.
services: azure-netapp-files
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: how-to
ms.date: 08/14/2025
ms.author: anfdocs
---
# Configure cross-region replication for Elastic Zone-Redundant volumes in Azure NetApp Files

Azure NetApp Files Elastic Zone-Redundant storage supports cross-region replication for added data protection. Cross-region replication is offered in addition to the native availability zone failover capability of Azure NetApp Files Elastic Zone-Redundant storage.

When you configure cross-region replication on a source volume, the replication volume is automatically configured. 

>[!IMPORTANT]  
> To configure cross-region replication for the Flexible, Standard, Premium, or Ultra service level, see [Configure cross-region replication](cross-region-replication-create-peering.md).

## Considerations

* Ensure your replication relationship adheres to [supported regional pairs](#supported-cross-region-replication-pairs).
* Azure NetApp Files replication is supported within a subscription and between subscriptions under the same tenant. To enable replication across subscriptions, you must [register the feature](cross-region-replication-create-peering.md#register-for-cross-subscription-replication).
* Cross-region replication of SMB volumes requires an Active Directory (AD) connection in the source and the destination NetApp accounts. The destination AD connection must have access to the Domain Name System (DNS) servers or the Active Directory Domain Services (AD DS) domain controllers that are reachable from the delegated subnet in the destination zone. For more information, see [Requirements for AD connections](create-active-directory-connections.md#requirements-for-active-directory-connections).
* Cross-region replication requires a NetApp account in the destination region.
* You can delete manual snapshots on the source volume of a replication relationship when the replication relationship is active or broken. You can also delete manual snapshots after you delete the replication relationship. You can't delete manual snapshots for the destination volume until you break the replication relationship.
* The replication destination volume is read-only until you [fail over to the destination region](cross-region-replication-manage-disaster-recovery.md#fail-over-to-destination-volume) to enable the destination volume for read and write.

    > [!IMPORTANT]
    > Failover is a manual process. When you need to activate the destination volume (like when you want to fail over to the destination region), you need to break replication peering and then mount the destination volume. For more information, see [Fail over to the destination volume](cross-region-replication-manage-disaster-recovery.md#fail-over-to-destination-volume).

    > [!IMPORTANT]
    > A volume that has an active backup policy enabled can't be the destination volume in a reverse resync operation. You must suspend the backup policy on the volume before you start the reverse resync. You can resume the backup policy when the reverse resync completes.

## Supported cross-region replication pairs

Azure NetApp Files volume replication is supported between various [Azure regional pairs](../../reliability/cross-region-replication-azure.md#paired-regions) and nonstandard pairs. Azure NetApp Files volume replication for the _Elastic Zone-Redundant Service Level_ is currently available between the following regions. You can replicate Azure NetApp Files volumes from Regional Pair A to Regional Pair B and from Regional Pair B to Regional Pair A.

### Azure regional pairs

| Geography | Regional Pair A | Regional Pair B  |
|:--- |:--- |:--- |
| Europe | North Europe | West Europe |
| North America | Central US | West US 3 |
| North America | East US 2 | Central US |
| North America | West US 3 | East US |


### Azure regional nonstandard pairs

| Geography | Regional Pair A | Regional Pair B  |
|:--- |:--- |:--- |
| France/Europe | France Central | West Europe |
| Germany/UK | Germany West Central | UK South |
| Germany/Europe | Germany West Central | West Europe | 
| Germany/France | Germany West Central | France Central |
| North America | Central US | East US |
| North America | East US | East US 2 |
| North America | East US 2| West US 2 |
| North America | East US 2 | West US 3 |
| North America | South Central US | East US |
| North America | South Central US | East US 2 |
| North America | South Central US | Central US |
| North America | West US 2 | East US |

## Create a replication relationship 

1. Navigate to the Elastic Zone-Redundant volume you want to create a replication relationship for. In the Azure portal's sidebar, select **Data Protection** then **Replications**. 
1. Select **Create replication**. 
1. For the source volume, provide a **Replication name** and select a **Frequency**: every 10 minutes, hourly, or daily. 
1. For the secondary volume, provide:
    * **Elastic volume name** - the name of the replication volume
    * **Region** - select the region of the Elastic account, ensuring it adheres to [supported regional pairs](#supported-cross-region-replication-pairs)
    * **NetApp Elastic account** - choose the account that includes the capacity pool for the volume to reside in
    * **Elastic capacity pool** - choose the capacity pool for the replication volume to reside in 

    :::image type="content" source="./media/elastic-cross-region-replication/create-replication.png" alt-text="Screenshot of create replication option." lightbox="./media/elastic-cross-region-replication/create-replication.png":::

1. Optionally, select **Add another replica** to configure another replication relationship. 
1. You can optionally add tags to the source and destination volumes. Select **Next** to add tags or **Review + create** to skip tags. 
1. Review your selections. Select **Create** to establish the replication relationship and add the replication volume in the designated capacity pool. 
1. In the Azure portal, navigate to **Replications** under protections. You can monitor the status of your replication relationship. A successfully created volume displays a replication status of "Scheduled replications".

## Manage replication relationships

1. In the sidebar of the Azure portal, select **Replications** under protections. 
1. Monitor the status of the replications in the **Replication status** column. 
    * To stop, pause, or resume a replication relationship, select the replication name then choose the appropriate action. 
    * If you see 
    * Select **Reverse and resume**. 
1. To modify the replication schedule, select the replication relationship.
1. In the overview, select **Edit replication schedule**.
1. In the pop-up menu, select the new schedule you want (every 10 minutes, hourly, or daily). Optionally, add or modify the tags. 
1. Select **Save**. 

## Failover

1. Navigate to the Elastic Zone-Redundant volume you want to create a replication relationship for. In the Azure portal's sidebar, select **Data Protection** then **Replications**. 
1. Select the replication relationship to failover. 
1. Select **Reverse and resume**. 


## Reestablish the replication relationship 

## Delete replication relationships 

1. Navigate to the source volume you whose replication relationship you want to delete. 
1. Select **Replications**.
1. Review the replication status.
1. Select **Delete replication**. 

<!-- consequences, requirements?  -->