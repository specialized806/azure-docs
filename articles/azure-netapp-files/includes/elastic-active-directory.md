---
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: include
ms.date: 12/16/2025
ms.author: anfdocs
ms.custom: include file

# azure-netapp-files/elastic-capacity-pool-task.md
---


1. In the Networking tab, provide inputs for the following fields:

    >[!TIP]
    >For detailed guidance on Active Directory configuration, see [Create and Manage Active Directory connections](../create-active-directory-connections.md).

    * **Active Directory policy name**
        Enter a name for the Active Directory configuration. 
    *  **DNS addresses**
        The IP address of the primary DNS server that is required for Active Directory domain join operations, SMB authentication, Kerberos, and LDAP operations. If you use multiple DNS servers, enter the IP addresses as a comma-separated list. 
    * **DNS domain name**
        The fully qualified domain name of the Active Directory used with Azure NetApp Files (for example, `contoso.com`).
    * **Site name**
        This is the Active Directory site name that Azure NetApp Files uses for domain controller discovery.  

    Select **Next**. 

    :::image type="content" source="../media/shared/elastic-active-directory-networking.png" alt-text="Screenshot of the networking tab." lightbox="../media/shared/elastic-active-directory-networking.png":::

1. In the **Identity and access** tab, provide inputs for the following fields:

    * **SMB server prefix**
        The naming prefix for new computer accounts created in Active Directory for Azure NetApp Files SMB, dual protocol, and NFSv4.1 Kerberos volumes. If the naming standard your organization uses for file services is `NAS-01`, `NAS-02`, use `NAS` for the prefix
    * **Organizational unit path**
        The LDAP path for the organizational unit (OU) where SMB server computer accounts will be created. 
    * **Security privilege users**
        This option grants security privilege (`SeSecurityPrivilege`) to Actie Directory domain users or groups that require elevated privileges to access Azure NetApp Files volumes.
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

    :::image type="content" source="../media/shared/elastic-active-directory-access.png" alt-text="Screenshot of the identity & access management tab." lightbox="../media/shared/elastic-active-directory-access.png":::

1. Optionally, select **Next** to add tags. Otherwise, select the **Review + create** tab.
1. Review your settings then select **Create** to add the Active Directory connection. 