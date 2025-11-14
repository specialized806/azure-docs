---
title: Create Active Directory connections for the Azure NetApp Files Elastic service level
description: Active Directory connections are required to create SMB volumes in Azure NetApp Files. 
services: azure-netapp-files
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: how-to
ms.date: 09/15/2025
ms.author: anfdocs
# Customer intent: As an Azure NetApp Files administrator, I want to create and manage Active Directory connections for the Elastic service level, so that I can enable proper authentication and access control for my SMB volumes.
---
# Create Active Directory connections for the Azure NetApp Files Elastic service level

To create SMB volumes, you must configure an Active Directory account then associate it with a capacity pool in the NetApp account for the Elastic service level. 

>[!IMPORTANT]
>For the Flexible, Standard, Premium, and Ultra service levels, follow the instructions in [Create and Manage Active Directory connections](create-active-directory-connections.md).

## Considerations

* You should store your Active Directory password in an Azure Key Vault then percolate the key vault details and secret name to Azure NetApp Files. 
* You can only add one Active Directory account per NetApp subscription. 
* The Active Directory resource is limited to the Elastic service level. The Active Directory resource is only available with capacity pools in the Elastic service level. 

## Steps

>[!TIP]
>For guidance on these fields, see [Create and Manage Active Directory connections](create-active-directory-connections.md).

<!-- check 1 and 2 -->
1. From your NetApp account for the Elastic service level, select **Active Directory policies**. 
1. Select **Create policy**. 
1. In the Networking tab, provide the following information.

    * Assign the **Active Directory policy name**. 
    * Enter the **DNS addresses** as a comma-separated list. 
    * Enter the **DNS domain name**. 
    * Enter the **Site name**. 

    Select **Next**. 
    
    :::image type="content" source="./media/elastic-active-directory/elastic-active-directory-networking.png" alt-text="Screenshot of the networking tab." lightbox="./media/elastic-active-directory/elastic-active-directory-networking.png":::

1. In the **Identity and access** tab: 
    * Enter the **SMB server prefix**.
    * Enter the **Organizational unit path**. 
    * Enter the **Security privilege users**, **Administrators**, and **Backup users**. 
    * Enter the **Azure Key Vault resource**. 
    * Enter the **Username**. 
    * Enter the **Password secret**. 
    * Enter the **User assigned identity**. 
    Select **Next**. 

    :::image type="content" source="./media/elastic-active-directory/elastic-active-directory-access.png" alt-text="Screenshot of the identity & access management tab." lightbox="./media/elastic-active-directory/elastic-active-directory-access.png":::

1. To enable AES encryption, select the **AES encryption** box. 

    :::image type="content" source="./media/create-active-directory-connections/active-directory-aes-encryption.png" alt-text="Screenshot of the AES encryption checkbox.":::

<!-- image -->
1. Select **Review + create**. 

## Next steps

* [Understand the Elastic Zone-Redundant service level](elastic-zone-redundant-concept.md)
* [Create an SMB volume for the Elastic service level](elastic-volume-server-message-block.md)