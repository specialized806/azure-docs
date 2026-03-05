---
title: Change the Identity Source for Azure File Shares
description: Learn how to switch between identity sources for Azure Files identity-based authentication for SMB file shares by disabling your current identity source and enabling a new one.
author: khdownie
ms.service: azure-file-storage
ms.topic: how-to
ms.date: 03/05/2026
ms.author: kendownie
# Customer intent: As a storage administrator, I want to change the identity source configured on my storage account, so that I can switch to a different authentication method for Azure file shares.
---

# Change the identity source for Azure file shares

**Applies to:** :heavy_check_mark: SMB Azure file shares

Azure Files supports only one identity source per storage account for identity-based authentication over SMB. If you want to switch from one identity source to another, for example, from on-premises Active Directory Domain Services (AD DS) to Microsoft Entra Kerberos, you must first disable the current identity source and then enable the new one.

For guidance on choosing the right identity source for your environment, see [Overview of Azure Files identity-based authentication for SMB access](storage-files-active-directory-overview.md).

> [!IMPORTANT]
> Disabling the current identity source removes identity-based access for all file shares in the storage account immediately. Users can't access shares using identity-based authentication until you enable and configure a new identity source.

## Step 1: Disable the current identity source

Use the tabs below to find steps for disabling your current identity source.

### Active Directory Domain Services (AD DS)

# [Portal](#tab/portal-adds)

1. Sign in to the [Azure portal](https://portal.azure.com) and select the storage account.
1. Under **Data storage**, select **File shares**.
1. Next to **Identity-based access**, select the configuration status. It should show **Configured**. If it shows **Not configured**, then you don't have an identity source enabled on the storage account and you can proceed to [Enable a new identity source](#step-2-enable-a-new-identity-source).

   :::image type="content" source="media/storage-files-identity-auth-domain-services-enable/enable-entra-storage-account-identity.png" alt-text="Screenshot of the file shares pane in your storage account, identity-based access is highlighted." lightbox="media/storage-files-identity-auth-domain-services-enable/enable-entra-storage-account-identity.png":::

1. Under **Active Directory Domain Services (AD DS)**, select **Configure**.
1. Select the **Disable Active Directory for this storage account** checkbox.
1. Select **Save**.

> [!IMPORTANT]
> After disabling AD DS authentication, consider deleting the AD DS computer account or service logon account that you created to represent the storage account in your on-premises AD. If you leave the identity in AD DS, it remains as an orphaned object.

# [Azure PowerShell](#tab/powershell-adds)

Run the following command, replacing the placeholder values with your own.

```azurepowershell
Set-AzStorageAccount -ResourceGroupName <resourceGroupName> -StorageAccountName <storageAccountName> -EnableActiveDirectoryDomainServicesForFile $false
```

> [!IMPORTANT]
> After disabling AD DS authentication, consider deleting the AD DS computer account or service logon account that you created to represent the storage account in your on-premises AD. If you leave the identity in AD DS, it remains as an orphaned object.

# [Azure CLI](#tab/cli-adds)

Run the following command, replacing the placeholder values with your own.

```azurecli
az storage account update --name <storage-account-name> --resource-group <resource-group-name> --enable-files-adds false
```

> [!IMPORTANT]
> After disabling AD DS authentication, consider deleting the AD DS computer account or service logon account that you created to represent the storage account in your on-premises AD. If you leave the identity in AD DS, it remains as an orphaned object.

---

### Microsoft Entra Domain Services

# [Portal](#tab/portal-aadds)

1. Sign in to the [Azure portal](https://portal.azure.com) and select the storage account.
1. Under **Data storage**, select **File shares**.
1. Next to **Identity-based access**, select the configuration status. It should show **Configured**. If it shows **Not configured**, then you don't have an identity source enabled on the storage account and you can proceed to [Enable a new identity source](#step-2-enable-a-new-identity-source).
1. Under **Microsoft Entra Domain Services**, select **Configure**.
1. Uncheck the **Microsoft Entra Domain Services** checkbox.
1. Select **Save**.

# [Azure PowerShell](#tab/powershell-aadds)

Run the following command, replacing the placeholder values with your own.

```azurepowershell
Set-AzStorageAccount -ResourceGroupName <resourceGroupName> -StorageAccountName <storageAccountName> -EnableAzureActiveDirectoryDomainServicesForFile $false
```

# [Azure CLI](#tab/cli-aadds)

Run the following command, replacing the placeholder values with your own.

```azurecli
az storage account update --name <storage-account-name> --resource-group <resource-group-name> --enable-files-aadds false
```

---

### Microsoft Entra Kerberos

# [Portal](#tab/portal-aadkerb)

1. Sign in to the [Azure portal](https://portal.azure.com) and select the storage account.
1. Under **Data storage**, select **File shares**.
1. Next to **Identity-based access**, select the configuration status. It should show **Configured**. If it shows **Not configured**, then you don't have an identity source enabled on the storage account and you can proceed to [Enable a new identity source](#step-2-enable-a-new-identity-source).
1. Under **Microsoft Entra Kerberos**, select **Configure**.
1. Uncheck the **Microsoft Entra Kerberos** checkbox.
1. Select **Save**.

# [Azure PowerShell](#tab/powershell-aadkerb)

Run the following command, replacing the placeholder values with your own.

```azurepowershell
Set-AzStorageAccount -ResourceGroupName <resourceGroupName> -StorageAccountName <storageAccountName> -EnableAzureActiveDirectoryKerberosForFile $false
```

# [Azure CLI](#tab/cli-aadkerb)

Run the following command, replacing the placeholder values with your own.

```azurecli
az storage account update --name <storage-account-name> --resource-group <resource-group-name> --enable-files-aadkerb false
```

---

## Step 2: Enable a new identity source

After disabling the current identity source, follow the instructions for the new identity source you want to enable:

- **Active Directory Domain Services (AD DS)**: See [Enable AD DS authentication for Azure file shares](storage-files-identity-ad-ds-enable.md).
- **Microsoft Entra Domain Services**: See [Enable Microsoft Entra Domain Services authentication on Azure Files](storage-files-identity-auth-domain-services-enable.md).
- **Microsoft Entra Kerberos** (hybrid or cloud-only identities): See [Enable Microsoft Entra Kerberos authentication for hybrid and cloud-only identities on Azure Files](storage-files-identity-auth-hybrid-identities-enable.md).
