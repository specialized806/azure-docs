---
title: Change availability zones for Elastic Zone-Redundant volumes in Azure NetApp Files
description: Learn how to change the availability zone in the event of an outage or failure for Elastic Zone-Redundant volumes in Azure NetApp Files. 
services: azure-netapp-files
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: how-to
ms.date: 08/14/2025
ms.author: anfdocs
---
# Change availability zones for Elastic Zone-Redundant capacity in Azure NetApp Files

With the Elastic Zone-Redundant (ZRS) service level, you can easily change the availability zone of a capacity pool and its volumes. 

<!-- HA, durability -->

## Considerations

* After changing the availability zone, the volume might not display the correct zone. Refer to the capacity pool overview's **Current zone** as the source of truth for all volumes in the capacity pool. 
<!-- failure during upgrade -->

## Change the availability zone 

1. In the Azure portal, select your capacity pool. 
1. In the capacity pool overview, select **Edit Current Availability Zone**. 
1. In the Edit Current Availability Zone blade, select a zone to failover to in the Availability Zone dropdown menu then **OK** to confirm your selection.  
1. Reload the page to confirm the availability zone change was successful in the capacity pool overview's **Current zone** field.