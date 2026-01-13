---
title: Azure Backup - Restore Confidential VM using Azure Backup (preview)
description: Learn about restoring Confidential VM with CMK using Azure Backup.
ms.topic: how-to
ms.date: 01/28/2026
ms.custom: references_regions
ms.service: azure-backup
author: AbhishekMallick-MS
ms.author: v-mallicka
---

# Restore Confidential VM using Azure Backup (preview)

[!INCLUDE [Confidential VM backup preview advisory.](../../includes/confidential-vm-backup-preview.md)]

This article describes how to restore Confidential VM (CVM) with Platform or Customer Managed Key (PMK or CMK).

***Note***

*For any queries, write to us at [AskAzureBackupTeam@microsoft.com](mailto:AskAzureBackupTeam@microsoft.com).*

## Restore scenarios for Confidential VM

Confidential VM restore behavior depends on the state of the DES, Key Vault, and keys at the time of restore. Key scenarios include:

- **Original Key or Key Version intact**: Restore succeeds if the original Disk Encryption Set (DES) and key remain intact.
- **Key Rotation**: Restore succeeds when a new key version is active, provided the previous key version isn't expired or deleted.
- **Key Change**: If the DES uses a new key, restore succeeds only if the previous key still exists; it fails if the previous key is deleted.
- **DES or Key Deleted**: Restore fails with errors, such as `UserErrorDiskEncryptionSetDoesNotExist` or `UserErrorDiskEncryptionSetKeyDoesNotExist`. To resolve, re-create the key and DES using restored key data, then retry the restore.
- **Input DES Provided**: If you provide a new DES created from restored key data, restore can succeed if the key and version match the ones used at backup time.
- **Mismatched DES or Key**: Restore fails with `UserErrorInputDESKeyDoesNotMatchWithOriginalKey`. To resolve this error, restore the missing keys.

















## Restore missing keys for Confidential VM restore
If the restore operation fails, you need to restore the Platform Managed Key (PMK) or Customer Managed Key (CMK) that Azure Backup backed up. 

To restore the key using PowerShell, run the following cmdlets:

1. Select the vault containing the protected CVM + CMK. In the cmdlet, you need to specify the resource group and name of the vault.

   ```azurepowershell
   $vault = Get-AzRecoveryServicesVault -ResourceGroupName "<vault-rg>" -Name "<vault-name>"
   ```

2. Get the list of all failed restore jobs.

   This cmdlet fetches all failed restore jobs for *last 7 days*. If the restore job is older, then change the days accordingly.

   ```azurepowershell
   $Jobs = Get-AzRecoveryServicesBackupJob -From (Get-Date).AddDays(-7).ToUniversalTime() -Status Failed -Operation Restore -VaultId $vault.ID
   ```

3. Select the failed restore job from the result and get the job details.

   *Example*

   ```azurepowershell
   $JobDetails = Get-AzRecoveryServicesBackupJobDetail -Job $Jobs[0] -VaultId $vault.ID
   ```

4. Get all the necessary parameters.

   ```azurepowershell
   $properties = $JobDetails.properties
   $storageAccountName = $properties["Target Storage Account Name"]
   $containerName = $properties["Config Blob Container Name"]
   $securedEncryptionInfoBlobName = $properties["Secured Encryption Info Blob Name"]
   ```

5. Select the target storage account that was selected for restore as well.

   In the following cmdlet, you need to specify the resource group of that storage account as well. 

   ```azurepowershell
   Set-AzCurrentStorageAccount -Name $storageaccountname -ResourceGroupName '<storage-account-rg >'
   ```

6. Restore the JSON configuration file containing key details for CVM with CMK.

   ```azurepowershell
   $destination_path = 'C:\cvmcmkencryption_config.json'
   Get-AzStorageBlobContent -Blob $securedEncryptionInfoBlobName -Container $containerName -Destination $destination_path
   $encryptionObject = Get-Content -Path $destination_path | ConvertFrom-Json 
   ```

7. After the JSON file is generated in the destination path mentioned previously, generate key blob file from the JSON.

   ```azurepowershell
   $keyDestination = 'C:\keyDetails.blob'
   [io.file]::WriteAllBytes($keyDestination, [System.Convert]::FromBase64String($encryptionObject.OsDiskEncryptionDetails.KeyBackupData)) 
   ```

8. Now, restore the key back in the Key Vault or Managed Hardware Security Module (HSM).

   ```azurepowershell
   Restore-AzKeyVaultKey -VaultName '<target_key_vault_name> ' -InputFile $keyDestination
   For MHSM Use,  
   Restore-AzKeyVaultKey -HsmName '<target_mhsm_name>' -InputFile $keyDestination
   ```

Now, you can create a new DES with Encryption type as *Confidential disk encryption with a customer-managed key* to point to this restored key. This DES should have enough permissions to perform a successful restore. If you use a new Key Vault or Managed HSM to restore the key, then *Backup Management Service* has enough permissions on it. [Learn how to grant permission for Key Vault or mHSM access](confidential-vm-backup.md#assign-permissions-for-confidential-vm-backup).

### Grant permissions to DES and Confidential Guest VM Agent

Disk Encryption Set and Confidential Guest VM Agent also need permissions on the Key Vault or Managed HSM. To provide the permissions, follow these steps:

**For Key vault**: To grant permissions to the Key vault, select the message *To associate a disk, image, or snapshot with this disk encryption set, you must grant permissions to the key vault*.

- **For Managed HSM**: To grant permissions to the Managed HSM, follow these steps:

  1. Assign newly created DES with Managed HSM Crypto the User Role:

     1. Go to **Managed HSM** on the Azure portal and select **Local RBAC** in **Settings**.
     2. Select **Add** to add new Role Assignment.
     3. For **Role**, select **Managed HSM Crypto User Role**.
     4. For **Scope**, select the restored key. You can also select **All Keys**.
     5. On the **Security principal**, you need to select *newly created DES*.

  2. Confidential Guest VM Agent should have the necessary permissions for CVM to boot up.

     1. Go to **Managed HSM** on the Azure portal and select **Local RBAC** in **Settings**.
     2. Select **Add** to add new role assignment.
     3. For **Role**, select **Managed HSM Crypto Service Encryption User**.
     4. For **Scope**, select the restored key. You can also select **All Keys**.
     5. On the **Security principal**, you need to select **Confidential Guest VM Agent**.

### Restore the Confidential VM

After you assign the required permissions, you can run the restore operation. [Learn how to restore an Azure VM](backup-azure-arm-restore-vms.md).