---
title: Create an Active Directory connection for Azure NetApp Files' Elastic zone-redundant storage
description: Learn how to create an Active Direction connection for Azure NetApp Files Elastic zone-redundant storage.
services: azure-netapp-files
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: how-to
ms.date: 08/14/2025
ms.author: anfdocs
ms.custom:
  - build-2025
# Customer intent: "As a cloud storage administrator, I want to create a capacity pool for Azure NetApp Files so that I can manage the storage volumes and configure their performance requirements effectively."
---
# Create an Active Directory connection for Azure NetApp Files' Elastic zone-redundant storage

If you're adding SMB volumes to your Elastic zone-redundant capacity pool, you must configure an Active Directory connection. 

>[!IMPORTANT]
>For the Flexible, Standard, Premium, and Ultra service levels, follow the instructions in [Create and Manage Active Directory connections](create-active-directory-connections.md).

## Considerations

* You should store your Active Directory password in an Azure Key Vault then percolate the key vault details and secret name to Azure NetApp Files. 
<!-- * You can only add one Active Directory account per NetApp subscription. -->
* The Active Directory resource you create for the capacity pool is limited to Elastic zone-redundant storage. The Active Directory resource is only available with capacity pools in Elastic zone-redundant storage. 

## Add a new Active Directory connection 

You can create the Active Directory connection when you [create the capacity pool](elastic-capacity-pool-task.md) or after. These steps outline creating an Active Directory connection after you've created the capacity pool.

>[!TIP]
>For detailed guidance on the Active Directory configuration, see [Create and Manage Active Directory connections](create-active-directory-connections.md).

1. In the Azure Portal, navigate to **Capacity pools**. Select the capacity pool you want to create an Active Directory connection for. 

1. In the overview for the capacity pool, select **+ Add Active Directory Connection**. 

1. In the Networking tab, provide inputs for the following fields:

    * **Active Directory policy name**
        Enter a name for the Active Directory configuration. 
    *  **DNS addresses**
        The IP address of the primary DNS server that is required for Active Directory domain join operations, SMB authentication, Kerberos, and LDAP operations. If you use multiple DNS servers, enter the IP addresses as a comma-separated list. 
    * **DNS domain name**
        The fully qualified domain name of the Active Directory used with Azure NetApp Files (for example, `contoso.com`).
    * **Site name**
        This is the Active Directory site name that Azure NetApp Files uses for domain controller discovery.  

    Select **Next**. 

    :::image type="content" source="./media/shared/elastic-active-directory-networking.png" alt-text="Screenshot of the networking tab." lightbox="./media/shared/elastic-active-directory-networking.png":::

1. In the **Identity and access** tab, provide inputs for the following fields:

    * **SMB server prefix**
        The naming prefix for new computer accounts created in Active Directory for Azure NetApp Files SMB, dual protocol, and NFSv4.1 Kerberos volumes. If the naming standard your organization uses for file services is `NAS-01`, `NAS-02`, use `NAS` for the prefix
    * **Organizational unit path**
        The LDAP path for the organizational unit (OU) where SMB server computer accounts will be created. 
    * **Security privilege users**
        This option grants security privilege (`SeSecurityPrivilege`) to Active Directory domain users or groups that require elevated privileges to access Azure NetApp Files volumes.
    * **Administrators**
        This option grants additional security privileges to Active Directory domain users or groups that require elevated privileges to access the Azure NetApp Files volumes.
    * **Backup users**
        This option grants addition security privileges to Active Directory domain users or groups that require elevated backup privileges to support backup, restore, and migration workflows in Azure NetApp Files.
    * **AKV resource**
        The resource identity for your Azure Key Vault. 
    * **User name**
    * **Password secret**
    * **User assigned identity**
        The standalone Azure resource assigned to your service. 
    Select **Next**. 

    :::image type="content" source="./media/shared/elastic-active-directory-access.png" alt-text="Screenshot of the identity & access management tab." lightbox="./media/shared/elastic-active-directory-access.png":::

1. Optionally, select **Next** to add tags. Otherwise, select the **Review + create** tab.
1. Review your settings then select **Create** to add the Active Directory connection. 

## Add an existing Active Directory connection 

If you've already created an Active Directory connection in the NetApp Elastic account, you can add it to an existing capacity pool. 

1. In the Azure portal, navigate to **Capacity pools**. Select the capacity pool you want to add an Active Directory connection to. 

1. In the overview for the capacity pool, select **+ Add Active Directory Connection**. 

1. Select the Active Directory connection from the dropdown menu. Select **OK** to add it to associate it with the capacity pool. 

## Next steps

* [Create an SMB volume](elastic-volume-server-message-block.md)