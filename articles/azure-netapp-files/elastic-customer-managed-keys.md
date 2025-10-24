---
title: Configure customer-managed keys for Elastic Zone-Redundant volume encryption in Azure NetApp Files
description: Learn how to configure customer-managed keys for volume encryption with Azure NetApp Files' Elastic Zone-Redundant service level. 
services: azure-netapp-files
author: b-ahibbard
ms.service: azure-netapp-files
ms.topic: how-to
ms.date: 08/14/2025
ms.author: anfdocs
---
# Configure customer-managed keys for Elastic Zone-Redundant volume encryption in Azure NetApp Files

Customer-managed keys for Azure NetApp Files volume encryption enable you to use your own keys rather than the platform-managed (Microsoft-managed) key when creating a new volume. With customer-managed keys, you can fully manage the relationship between a key's life cycle, key usage permissions, and auditing operations on keys.

## Considerations

>[!IMPORTANT]  
> To configure customer-managed keys for the Flexible, Standard, Premium, or Ultra service level, see [Configure cross-region replication](configure-customer-managed-keys.md).

[!INCLUDE [Customer-managed keys considerations](includes/customer-managed-keys-considerations.md)]


## Requirements

Before creating your first customer-managed key volume, you must set up:

* A virtual network:
    The virtual network subnet need to be delegated to `Microsoft.Netapp/elasticVolumes`
* An [Azure Key Vault](/azure/key-vault/general/overview), containing at least one key.
    * The key vault must have soft delete and purge protection enabled.
    * The key must be of type RSA.
* The key vault must have an [Azure Private Endpoint](../private-link/private-endpoint-overview.md).
    * The private endpoint must reside in a different subnet than the one delegated to Azure NetApp Files. The subnet must be in the same virtual network as the one delegated to Azure NetApp.

For more information about Azure Key Vault and Azure Private Endpoint, see:
* [Quickstart: Create a key vault ](/azure/key-vault/general/quick-create-portal)
* [Create or import a key into the vault](/azure/key-vault/keys/quick-create-portal)
* [Create a private endpoint](../private-link/create-private-endpoint-portal.md)
* [More about keys and supported key types](/azure/key-vault/keys/about-keys)
* [Manage network policies for private endpoints](../private-link/disable-private-endpoint-network-policy.md)

## RBAC

<!-- Convert to include from existing -->

## Configure an Elastic NetApp account to use customer-managed keys

<!-- add images -->

1. In your Elastic storage account, select **Encryption**. 
In the Azure portal and under Azure NetApp Files, select Encryption. 
1. For Encryption key source, select **Customer Managed key**. 
1. Provide the Encryption Key. 
    * If you have the URI, select **Enter key URI** then enter manually the **Key URI** and **Subscription**. 
    * To select the key from a list, choose **Select key vault** then **Select a key vault and key**. 
    In the dropdown menus, select the **Subscription**, **Key vault**, and **Key** then **Select** to confirm your choices. 
1. Choose the identity type for authentication with the Azure Key Vault. 

    * If your Azure Key Vault is configured to use Vault access policy as its permission model, both options are available. Otherwise, only the user-assigned option is available. 
    * If you're using 
    If you choose System-assigned, select the Save button. The Azure portal configures the NetApp account automatically by adding a system-assigned identity to your NetApp account. An access policy is also created on your Azure Key Vault with key permissions Get, Encrypt, Decrypt. 

    If you choose User-assigned, you must select an identity. Choose Select an identity to open a context pane where you select a user-assigned managed identity. 
<!-- image -->

## Next steps

After you configure encryption settings for your Elastic NetApp account, [Create an Elastic Zone-Redundant capacity pool](elastic-capacity-pool-task.md). Ensure you select **Customer Managed** for the encryption key source, then provide the configure Azure key vault in the key vault private endpoint. 

After the capacity pool is created with customer-managed keys, volumes created in the capacity pool automatically inherit customer-managed key encryption settings. 