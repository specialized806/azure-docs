---
title: Enable External Data Services (EDS) in Azure Data Manager for Energy
description: Learn how to enable External Data Services (EDS) to pull metadata from OSDU-compliant external data sources into Azure Data Manager for Energy.
author: bharathim
ms.author: bselvaraj
ms.service: azure-data-manager-energy
ms.topic: how-to
ms.date: 01/28/2026

#customer intent: As a Data Manager in Operating company, I want to enable external data sources so that I pull metadata at scheduled intervals into Azure Data Manager for Energy and retrieve bulk data on demand.

---

# Enable External Data Services (EDS)

External Data Services (EDS) is a capability in [OSDU®](https://osduforum.org/) that allows data from an OSDU-compliant external data source to be shared with an Azure Data Manager for Energy resource. EDS is designed to pull specified data (metadata) from OSDU-compliant data sources via scheduled jobs while leaving associated dataset files (LAS, SEG-Y, etc.) stored at the external source for retrieval on demand.

## Prerequisites

- An Azure subscription. If you don't have an Azure subscription, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account).
- An Azure Data Manager for Energy resource. If you don't have one, see [Create an Azure Data Manager for Energy instance](/azure/energy-data-services/quickstart-create-microsoft-energy-data-services-instance).

## Create or configure a key vault
1. Create a new key vault or use an existing one to store secrets managed by the OSDU secret service. To learn how to create a key vault, see [Quickstart: Create a key vault using the Azure portal](/azure/key-vault/general/quick-create-portal).

   > [!IMPORTANT]
   > Your key vault must exist in the same tenant as your Azure Data Manager for Energy resource.

   > [!TIP]
   > When you create the key vault, select [Enable purge protection (enforce a mandatory retention period for deleted vaults and vault objects)](/azure/key-vault/general/key-vault-recovery?tabs=azure-portal#what-are-soft-delete-and-purge-protection).

1. In the **Access configuration** tab, under **Permission model**, select **Azure role-based access control (recommended)**.
    [![Screenshot of create a key vault.](media/how-to-enable-external-data-sources/create-a-key-vault.jpg)](media/how-to-enable-external-data-sources/create-a-key-vault.jpg#lightbox)

1. Select **Review + create** to create the key vault.

## Managed Identity
A [managed identity](/entra/identity/managed-identities-azure-resources/overview) is a feature in Microsoft Entra ID that allows Azure resources to authenticate to other services without storing credentials in code. Azure supports two types of managed identities:
- **System-assigned managed identity**: Enabled directly on an Azure resource. The identity is tied to the lifecycle of the resource and is automatically deleted when the resource is deleted.
- **User-assigned managed identity**: Created as a standalone Azure resource. It can be assigned to one or more Azure resources and is managed independently from the resources that use it.

You can use either a user-assigned or system-assigned managed identity for External Data Services. Note that a system-assigned managed identity is automatically created during Azure Data Manager for Energy resource provisioning.

## Granting Managed Identity permissions to the Key Vault

### User-assigned managed identity
1. In the Azure portal, navigate to your key vault.
1. Select **Access control (IAM)** from the left menu.
1. Select **+ Add** > **Add role assignment**.
1. On the **Role** tab, select **Job function roles**, search for and select **Key Vault Secrets User**, then select **Next**.
1. On the **Members** tab, select **Managed identity** for **Assign access to**.
1. Select **+ Select members**.
1. In the **Select managed identities** pane, select **User-assigned managed identity** from the **Managed identity** dropdown.
1. Select the user-assigned managed identity you want to grant access to, then select **Select**.
1. Select **Review + assign** to complete the role assignment.

### System-assigned managed identity
1. In the Azure portal, navigate to your key vault.
1. Select **Access control (IAM)** from the left menu.
1. Select **+ Add** > **Add role assignment**.
1. On the **Role** tab, select **Job function roles**, search for and select **Key Vault Secrets User**, then select **Next**.
1. On the **Members** tab, select **User, group, or service principal** for **Assign access to**.
1. Select **+ Select members**.
1. In the **Select members** pane, search for and select the service principal with the same name as your Azure Data Manager for Energy resource.
1. Select **Select**.
1. Select **Review + assign** to complete the role assignment.

## Enable External Data Services
1. Navigate to your Azure Data Manager for Energy resource in the Azure portal.
1. In the left menu, under **Advanced**, select **External Data Sources**.
1. Select the checkbox to **Enable External Data Sources**.
1. Select **Select a key vault** to open the flyout panel. Select the subscription and the key vault you created earlier, then select **Add**.
1. Under **Managed identity type**, select **User-assigned managed identity** or **System-assigned managed identity**.
1. If you selected **User-assigned managed identity**, select **Select user assigned managed identity** to open the flyout panel.
1. In the **Select user assigned managed identity** flyout, select your **Subscription** from the dropdown.
1. Search for your user-assigned managed identity in the search field.
1. Select the managed identity from the list, then select **Add**.
1. Select **Save** to enable External Data Services.

## FAQ
See [External data sources FAQ.](faq-energy-data-services.yml#external-data-sources)

> [!div class="nextstepaction"]
> [How to register an external data source with Azure Data Manager for Energy?](how-to-register-external-data-sources.md) 
