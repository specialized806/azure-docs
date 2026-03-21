---
title: Configure export settings in FHIR service
description: This article describes how to configure export settings in the Azure Health Data Services FHIR service
author: expekesheth
ms.service: azure-health-data-services
ms.subservice: fhir
ms.topic: how-to
ms.date: 03/20/2026
ms.author: kesheth
ms.reviewer: v-catheribun
ms.custom:
  - references_regions
  - subject-rbac-steps
  - sfi-image-nochange
---

# Configure export settings and set up a storage account

The FHIR&reg; service supports the `$export` operation [specified by HL7](https://www.hl7.org/fhir/uv/bulkdata/) for exporting FHIR data from a FHIR server. In the FHIR service implementation, when you call the `$export` endpoint, the FHIR service exports data into a preconfigured Azure storage account. The storage account must be a Blob or Azure Data Lake Storage Gen2 (ADLS Gen2) account with hierarchical namespaces enabled.

Before you configure export, ensure you have the **FHIR Data exporter role** application role. To learn more about application roles, see [Authentication and Authorization for FHIR service](../../healthcare-apis/authentication-authorization.md).

Set up the `$export` operation for the FHIR service in three steps:

- Enable a managed identity for the FHIR service.
- Give permission for the FHIR service to access your storage account.
- Set the storage account as the export destination for the FHIR service.

## Prerequisites

- A FHIR service. To create one, see [Deploy the FHIR service](deploy-azure-portal.md).
- An Azure Blob or Azure Data Lake Storage Gen2 (ADLS Gen2) account configured with [Hierarchical Namespaces (HNS) enabled](../../storage/blobs/create-data-lake-storage-account.md) to use as the destination for exported data. 

## Enable managed identity for the FHIR service

The first step in configuring your environment for FHIR data export is to enable a system-assigned managed identity for the FHIR service. The FHIR service uses this managed identity to authenticate and access the ADLS Gen2 account during an `$export` operation. For more information about managed identities in Azure, see [About managed identities for Azure resources](../../active-directory/managed-identities-azure-resources/overview.md).

1. In the Azure portal, browse to your FHIR service.
1. On the left menu, select **Identity**.
1. In the **System assigned** tab, set the **Status** option to **On**, and then select **Save**.

   :::image type="content" source="media/configure-import-data/fhir-managed-identity-enabled.png" alt-text="Screenshot showing the enabled managed identity for the FHIR service." lightbox="media/configure-import-data/fhir-managed-identity-enabled.png":::

1. When the **Yes** and **No** buttons display, select **Yes** to enable the managed identity for the FHIR service. After you enable the system identity, you see an **Object (principal) ID** value for your FHIR service.

   :::image type="content" source="media/configure-import-data/fhir-managed-identity-object-id.png" alt-text="Screenshot showing the enabled managed identity for the FHIR service." lightbox="media/configure-import-data/fhir-managed-identity-object-id.png":::


## Give permission in the storage account for FHIR service access

1. Go to your storage account in the Azure portal. 
1. In your storage account, select **Access control (IAM)**.

1. Select **Add** > **Add role assignment**. If **Add role assignment** is grayed out, ask your Azure administrator for help with this step.

   :::image type="content" source="~/reusable-content/ce-skilling/azure/media/role-based-access-control/add-role-assignment-menu-generic.png" alt-text="Screenshot that shows Access control (IAM) page with Add role assignment menu open." lightbox="~/reusable-content/ce-skilling/azure/media/role-based-access-control/add-role-assignment-menu-generic.png":::

1. On the **Role** tab, select the [Storage Blob Data Contributor](../../role-based-access-control/built-in-roles.md#storage-blob-data-contributor) role.

    :::image type="content" source="~/reusable-content/ce-skilling/azure/media/role-based-access-control/add-role-assignment-page.png" alt-text="Screenshot showing user interface of Add role assignment page." lightbox="~/reusable-content/ce-skilling/azure/media/role-based-access-control/add-role-assignment-page.png":::

1. On the **Members** tab, select **Managed identity**, and then select **Select members**.

1. Select your Azure subscription.

1. Select **System-assigned managed identity**, and then select the managed identity that you previously enabled for your FHIR service.

1. On the **Review + assign** tab, select **Review + assign** to assign the **Storage Blob Data Contributor** role to your FHIR service.

For more information about assigning roles in the Azure portal, see [Azure built-in roles](/azure/role-based-access-control/role-assignments-portal).

Now you're ready to configure the FHIR service by setting the ADLS Gen2 account as the default storage account for export.

## Specify the storage account for FHIR service export

Specify the storage account that the FHIR service uses when exporting data.

> [!NOTE]
> In the storage account, if you don't assign the **Storage Blob Data Contributor** role to the FHIR service, the `$export` operation fails.

1. Go to your FHIR service settings.

1. Select **Export**.

1. Select the name of the storage account from the list. If you need to search for your storage account, use the **Name**, **Resource group**, or **Region** filters. 

:::image type="content" source="media/export-data/fhir-export-storage.png" alt-text="Screenshot showing user interface of FHIR Export Storage list." lightbox="media/export-data/fhir-export-storage.png":::

After you complete these configuration steps, you're ready to export data from the FHIR service. To learn more about performing `$export` operations with the FHIR service, see [How to export FHIR data](./export-data.md).

> [!NOTE]
> You can only register storage accounts in the same subscription as the FHIR service as the destination for `$export` operations.

## Secure the FHIR service `$export` operation

To securely export data from the FHIR service to your storage account, use one of the following options:

* Allow the FHIR service to access the storage account as a Microsoft Trusted Service.
* Allow specific IP addresses associated with the FHIR service to access the storage account. This option permits two different configurations depending on whether the storage account is in the same Azure region as the FHIR service.

### Allow the FHIR service as a Microsoft trusted service

To enable the FHIR workspace as a trusted Microsoft service, follow these steps:

Ensure that your storage account public network access scope is enabled for selected networks. 

1. In the Azure portal, go to your storage account.
1. On the left menu, select **Networking**.
1. On the **Public access** tab, under **Public network access**, select **Manage**.

   :::image type="content" source="media/export-data/storage-networking-1.png" alt-text="Screenshot of Azure Storage networking settings." lightbox="media/export-data/storage-networking-1.png":::
1. Select **Enable from selected networks**.
1. In the **Resource type** dropdown list, select **Microsoft.HealthcareApis/workspaces**. In the **Instance name** dropdown list, select your workspace.
1. In the **Exceptions** section, select the **Allow trusted Microsoft services to access this storage account** checkbox.
   :::image type="content" source="media/export-data/exceptions.png" alt-text="Screenshot that shows the option to allow trusted Microsoft services to access this storage account." lightbox="media/export-data/exceptions.png":::
1. Select **Save** to retain the settings.


To enable the FHIR service as a trusted Microsoft service, use the following PowerShell commands:

1. Run the following PowerShell command to install the `Az.Storage` PowerShell module in your local environment. Use this module to configure your Azure storage accounts by using PowerShell.

```PowerShell
Install-Module Az.Storage -Repository PsGallery -AllowClobber -Force 
```

1. Use the following PowerShell command to set the selected FHIR service instance as a trusted resource for the storage account. Make sure that all listed parameters are defined in your PowerShell environment.

   You need to run the `Add-AzStorageAccountNetworkRule` command as an administrator in your local environment. For more information, see [Configure Azure Storage firewalls and virtual networks](../../storage/common/storage-network-security.md).

   ```PowerShell
   $subscription="xxx"
   $tenantId = "xxx"
   $resourceGroupName = "xxx"
   $storageaccountName = "xxx"
   $workspacename="xxx"
   $fhirname="xxx"
   $resourceId = "/subscriptions/$subscription/resourceGroups/$resourceGroupName/providers/Microsoft.HealthcareApis/workspaces/$workspacename/fhirservices/$fhirname"

   Add-AzStorageAccountNetworkRule -ResourceGroupName $resourceGroupName -Name $storageaccountName -TenantId $tenantId -ResourceId $resourceId
   ```

1. To verify that the FHIR service is added as a trusted Microsoft service for the storage account, go to the storage account in the Azure portal, and select **JSON view**. Verify that the FHIR service is listed in the `properties.networkAcls.resourceAccessRules`.




### Allow specific IP addresses to access the Azure storage account from other Azure regions

<!-- Need information as the interface has changed. -->

[!INCLUDE [Specific IP ranges for storage account](../includes/common-ip-address-storage-account.md)]


### Allow specific IP addresses to access the Azure storage account in the same region as the FHIR service

The configuration process for IP addresses in the same region is just like the previous procedure, except that you use a specific IP address range in Classless Inter-Domain Routing (CIDR) format instead (that is, 100.64.0.0/10). You must specify the IP address range (100.64.0.0 to 100.127.255.255) because an IP address for the FHIR service is allocated each time you make an operation request.

[!NOTE]
> You can use a private IP address within the range of 10.0.2.0/24, but there's no guarantee that the operation succeeds in such a case. You can retry if the operation request fails, but until you use an IP address within the range of 100.64.0.0/10, the request won't succeed.
> This network behavior for IP address ranges is by design. The alternative is to configure the storage account in a different region.

## Next steps

In this article, you learned how to configure your environment to allow export of data from your FHIR service to an Azure storage account. For more information about Bulk Export capabilities in the FHIR service, see the following article.

>[!div class="nextstepaction"]
>[How to export FHIR data](export-data.md)

[!INCLUDE [FHIR trademark statement](../includes/healthcare-apis-fhir-trademark.md)]
