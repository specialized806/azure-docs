---
title: Prerequisites include file shared by two tabs in the same file  | Microsoft Docs
description: Prerequisites for Data Box service and device before deployment. 
services: databox
author: stevenmatthew
ms.service: azure-databox
ms.topic: include
ms.date: 03/25/2024
ms.author: shaas
zone_pivot_groups: data-box-sku
---
### For the Data Box service

[!INCLUDE [Data Box service prerequisites](data-box-supported-subscriptions.md)]

### For the Data Box device

Before you begin, make sure that:

* You should have a host computer connected to the datacenter network. Data Box will copy the data from this computer. Your host computer must run a supported operating system as described in [Azure Data Box system requirements](../articles/databox/data-box-system-requirements.md).

:::zone pivot="dbx-ng"
* Your datacenter needs to have high-speed network. We strongly recommend that you have at least one 100-GbE connection. If a 100-GbE connection isn't available, you can use a 10-GbE or 1-GbE data link can be used, but copy speeds are impacted.
  
:::zone-end

:::zone pivot="dbx"
* Your datacenter needs to have high-speed network. We strongly recommend that you have at least one 10-GbE connection. If a 10-GbE connection isn't available, 1-GbE data link can be used, but copy speeds are impacted.

:::zone-end
