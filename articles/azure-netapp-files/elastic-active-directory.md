---
title: Create Active Directory connections for the Azure NetApp Files Elastic service level
description: Active Directory connections are required to create SMB volumes in Azure NetApp Files. 
services: azure-netapp-files
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: how-to
ms.date: 07/30/2025
ms.author: anfdocs
# Customer intent: As an Azure NetApp Files administrator, I want to create and manage Active Directory connections for the Elastic service level, so that I can enable proper authentication and access control for my SMB volumes.
---
# Create Active Directory connections for the Azure NetApp Files Elastic service level

To create SMB volumes, you must configure an Active Directory account then associate it with a capacity pool in the NetApp account for the Elastic service level. 

## Considerations

* You should store your Active Directory password in an Azure Key Vault then percolate the key vault details and secret name to Azure NetApp Files. 
* You can only add one Active Directory account per NetApp subscription. 

## Steps
<!-- check 1 and 2 -->
1. From your NetApp account for the Elastic service level, select **Active Directory policies**. 
1. Select **Create policy**. 
1. In the Networking tab: 
    * Assign the **Active Directory policy name**. 
    * Enter the **DNS addresses** as a comma-separated list. 
    * Enter the **DNS domain name**. 
    * Enter the **Site name**. 
    Select **Next**. 

    <!-- image -->

1. In the **Identity and access** tab: 
    * Enter the **SMB server prefix**.
    * Enter the **Organizational unit path**. 
    * Enter the **Security privilege users**, **Administrators**, and **Backup users**. 
    * Enter the **Azure Key Vault resource**. 
    * Enter the **Username**. 
    * Enter the **Passerword secret**. 
    * Enter the **User assigned identity**. 
    Select **Next**. 

    <!-- image -->

1. To enable AES encryption, select the box. 

<!-- image -->
1. Select **Review + create**. 

## Next steps

* [Create an SMB volume for the Elastic service level](elastic-volume-server.md)