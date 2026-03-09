---
title: Requirements and Considerations for Azure NetApp Files advanced ransomware protection 
description: Understand the considerations and requirements for Azure NetApp Files advanced ransomware protection. 
services: azure-netapp-files
author: netapp-manishc
ms.service: azure-netapp-files
ms.topic: concept-article
ms.date: 03/09/2026
ms.author: anfdocs
ms.custom: references_regions
---
# Requirements and considerations for Azure NetApp Files advanced ransomware protection 

Before you configure [Azure NetApp Files advanced ransomware protection](ransomware-configure.md), make sure that you understand the requirements.

## Considerations 

* Attack reports are retained for 30 days.  
* Ransomware threat notifications are sent in the Azure Activity log.  
* It’s recommended that you enable no more than five volumes per Azure region with advanced ransomware protection to mitigate performance issues. 
* It's recommended you increase QoS capacity by 5 to 10 percent due to potential performance impacts of advanced ransomware protection. The scale of the impact can vary based on the configurations across your Azure NetApp Files deployment.  
