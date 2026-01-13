---
title: Azure Backup - Configure backup of Confidential VM using Azure Backup (preview) 
description: Learn about backing up Confidential VM with PMK or CMK using Azure Backup.
ms.topic: how-to
ms.date: 01/28/2026
ms.custom: references_regions
ms.service: azure-backup
author: AbhishekMallick-MS
ms.author: v-mallicka
---

# Back up Confidential VM using Azure Backup (preview)

[!INCLUDE [Confidential VM backup preview advisory.](../../includes/confidential-vm-backup-preview.md)]

Azure Backup supports [Confidential Virtual Machines (CVMs)](/azure/confidential-computing/confidential-vm-overview), that provide secure, encrypted backup and restore for sensitive workloads. This capability uses Azure Disk Encryption Sets (DES) with Platform Managed Keys (PMKs) or Customer Managed Keys (CMKs) to maintain data confidentiality throughout the backup lifecycle. Confidential VMs provide strong security by creating a hardware-enforced boundary between your application and the virtualization stack.

>[!Note]
>Azure Backup support for Confidential VMs (DC Series v6) is in public preview, available only in select regions, and requires subscription-level enablement. This feature isn’t recommended for production workloads.

This article describes how to configure and back up Confidential VM (CVM) with Platform or Customer Managed Key (PMK or CMK).

## Prerequisites

Before you configure backup for CVM with CMK, ensure that the following prerequisites are met:

- [Configure preview features in Azure subscription](/azure/azure-resource-manager/management/preview-features?tabs=azure-portal).
- Identify or create a Confidential VM (CVM) in a supported region. See the [supported regions](backup-support-matrix-iaas.md#support-for-confidential-vm-backup-preview)
- Identify or [create a Recovery Services Vault](backup-create-recovery-services-vault.md#create-a-recovery-services-vault) in the same region as that of the VM.
- Disk Encryption Set (DES) with keys used for VM encryption. 

Learn more about the [supported scenarios for Confidential VM backup](backup-support-matrix-iaas.md#support-for-confidential-vm-backup-preview).

## Create a new Confidential VM with Customer Managed Key

Learn how to [create a new Confidential VM with Customer Managed Key](/azure/confidential-computing/quick-create-confidential-vm-portal-amd), if needed.

## Assign permissions for Confidential VM backup

Azure Backup needs certain access to Key Vault or managed Hardware Security Module (mHSM) that are used to store the key. These permissions also help Azure Backup to back up the key, which you can restore if deleted for some reason.

When you configure backup of CVM with confidential OS disk encryption using CMK, the Azure portal automatically grants access to the Backup Management Service. If you're using other clients such as PowerShell, CLI, or REST API, permissions aren't granted automatically, and you need to grant the permissions.

If you are using a Key vault to store keys, [grant permission to the Azure Backup service for the backup operations](backup-azure-vms-encryption.md#provide-permissions). 

To assign permissions for mHSM, follow these steps:

1. In the Azure portal, go to **Managed HSM**, and then select **Local RBAC** in **Settings**.

2. Select **Add** to add a *new Role Assignment*.

3. Select one of the following roles:

   - **Built-in roles**: If you want to use a built-in roles, select the **Managed HSM Crypto User** role.

   - **Custom roles**: If you want to use custom role, then *dataActions* of that role should have these values:

     - **Microsoft.KeyVault/managedHsm/keys/read/action**
     - **Microsoft.KeyVault/managedHsm/keys/backup/action**

     You can create a custom role using the [Managed HSM data plane role management](/azure/key-vault/managed-hsm/role-management#create-a-new-role-definition).

4. For **Scope**, select the specific key used to create Confidential VM with Customer Managed Key.

   You can also select **All Keys**. 

5. On the **Security principal**, select **Backup Management Service**.

## Configure backup for Confidential VM

Once Azure Backup has the necessary permissions, you can continue configuring backup. [Learn how to configure Azure VM backup](backup-during-vm-creation.md).

## Next step

[Restore CVM with CMK using Azure Backup (preview)](confidential-vm-restore.md).