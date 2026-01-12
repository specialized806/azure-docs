---
title: Azure Backup - Restore Confidential VM with Customer Managed Key using Azure Backup CMK (preview)
description: Learn about restoring Confidential VM with CMK using Azure Backup.
ms.topic: how-to
ms.date: 05/15/2023
ms.custom: references_regions
ms.service: backup
author: jyothisuri
ms.author: jsuri
---

# Restore Confidential VM with Customer Managed Key using Azure Backup (private preview)

This article describes how to restore Confidential VM (CVM) with Customer Managed Key (CMK).

***Note***

*For any queries, write to us at [AskAzureBackupTeam@microsoft.com](mailto:AskAzureBackupTeam@microsoft.com).*

## Restore scenarios

You can have the following set of restore scenarios:

- **Sunny day restore scenarios**: These scenarios happen when the original Customer Managed Key (CMK), Key Vault, mHSM, and DES are available. In these scenarios, you can continue the restore process as usual.

- **Rainy day restore scenarios**: These scenarios happen when due to some reason, the original CMK, Key Vault, mHSM, or DES pointing to the original CMK is deleted, or backup isn't able to access the original CMK for restoring. In these scenarios, when you trigger the restore as usual, it fails and CVM isn't restored. You need to perform certain steps to restore the key (which Azure Backup backs up), point a new DES to this restored key, and trigger restore again with this DES.

For more information on the restore process, see [this article](https://learn.microsoft.com/en-us/azure/backup/backup-azure-arm-restore-vms).

***Note***

*We recommend you to try at least two restores from both these scenarios.*

## Sunny day restore scenarios

This section shows how you can trigger the supported restores from the **Backup Item** page as usual.

To perform the restore, on the **Restore** page, choose the supported restore mechanism, and then trigger restore.

![Screenshot shows the sunny restore scenario from the Backup Item page.](https://github.com/MicrosoftDocs/Backup-Confidential-VMs-with-CMK/blob/main/articles/media/backup-confidential-vm-with-customer-managed-key/sunny-restore-scenario.png)

See the following scenarios.

### Scenario 1: Restore without Disk Encryption Set

You can find a dropdown list to select a Disk Encryption Set (DES) on the **Restore** page of CVM. This is optional, and you can select DES from it in case of rainy-day scenarios.

For this scenario, don't provide any Disk Encryption Set (DES) and the restore process should be successful.

![Screenshot shows Restore page of CVM with an option to enter DES.](https://github.com/MicrosoftDocs/Backup-Confidential-VMs-with-CMK/blob/main/articles/media/backup-confidential-vm-with-customer-managed-key/disk-encryption-set-on-restore.png)

### Scenario 2: Restore using Disk Encryption Set pointed to another key

For this scenario, choose a DES pointing to a different key than the original from the dropdown list. The restoration may fail.

![Screenshot shows restore fails using a DES pointing to a different CMK.](https://github.com/MicrosoftDocs/Backup-Confidential-VMs-with-CMK/blob/main/articles/media/backup-confidential-vm-with-customer-managed-key/sunny-restore-fails-with-disk-encryption-set-pointed-to-different-key.png)

## Rainy day restore scenarios

These scenarios comprise edge-case scenarios that occur due to some accidental reasons or malicious admins.

Rainy day restore workflow:

1. Perform first restore.

   The restore will fail due to missing key.

2. (Post-restoration process) Restore the Customer Managed Key that Azure Backup has backed up, and then create a new DES to point to the restored key.

3. Trigger a restore again by entering the DES on the *Restore* page.

### Step 1: Delete original Customer Managed Key

You need to delete the original Customer Managed Key (used for encrypting CVM), delete Key Vault, or mHSM having the original CMK.

***Important***

*Ensure that you've Soft Delete enabled on the [key vault](https://learn.microsoft.com/en-us/azure/key-vault/general/soft-delete-overview) / [mHSM](https://learn.microsoft.com/en-us/azure/key-vault/managed-hsm/soft-delete-overview) so that you can recover the key, key vault, or mHSM later. Learn more on [how to recover the key or key vault from the soft deleted state](https://learn.microsoft.com/en-us/azure/key-vault/general/key-vault-recovery?tabs=azure-portal).*

### Step 2: Perform Restore

Trigger restore, as usual, for the Confidential VM (CVM) for which you've deleted the CMK, Key Vault, or mHSM.

The restore process fails due to the missing key.

The following screenshot shows the *Restore* page after the first restore has failed.

![Screenshot shows the first rainy restore has failed when the key is removed.](https://github.com/MicrosoftDocs/Backup-Confidential-VMs-with-CMK/blob/main/articles/media/backup-confidential-vm-with-customer-managed-key/rainy-restore-fails-for-missing-key.png)

### Step 3: Perform post restoration steps

Once your first restore fails, you need to restore the Customer Managed Key, which Azure Backup has backed up. 

To restore the key using PowerShell, run the following cmdlets:

1. Select the vault in which you've protected CVM + CMK. In the cmdlet, you need to specify the resource group and name of the vault.

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

7. Once the JSON file is generated in the destination path mentioned above, generate key blob file from the JSON.

   ```azurepowershell
   $keyDestination = 'C:\keyDetails.blob'
   [io.file]::WriteAllBytes($keyDestination, [System.Convert]::FromBase64String($encryptionObject.OsDiskEncryptionDetails.KeyBackupData)) 
   ```

8. Now, restore the key back in the Key Vault or managed HSM.

   ```azurepowershell
   Restore-AzKeyVaultKey -VaultName '<target_key_vault_name> ' -InputFile $keyDestination
   For MHSM Use,  
   Restore-AzKeyVaultKey -HsmName '<target_mhsm_name>' -InputFile $keyDestination
   ```

Now, you can create a new DES with Encryption type as *Confidential disk encryption with a customer-managed key* to point to this restored key. This DES should have enough permissions to perform a successful restore. If you've used a new Key Vault or managed HSM to restore the key, then *Backup Management Service* should have enough permissions on it. For granting permission for Key Vault or mHSM access, see [these steps](https://github.com/MicrosoftDocs/Backup-Confidential-VMs-with-CMK/blob/main/articles/configure-backup-confidential-vm-with-customer-managed-key.md#scenario-2-error-while-configuring-backup).

Disk Encryption Set and Confidential Guest VM Agent also need permissions on the Key Vault or Managed HSM. To provide the permissions, follow these steps:

- **For Key Vault**: To grant these permissions to the Key Vault, select the red message as shown in the following screenshot.

  ![Screenshot shows how to assign permissions to the Key Vault.](https://github.com/MicrosoftDocs/Backup-Confidential-VMs-with-CMK/blob/main/articles/media/backup-confidential-vm-with-customer-managed-key/assign-permissions-to-key-vault.png)

- **For Managed HSM**: To grant these permissions, follow these steps:

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

### Step 4: Re-trigger restore

Follow these steps:

1. Go to the **Backup Items** page, select the recovery point that you've used for triggering the first restore, and then perform restore again.

2. On the **Restore** page, select the *newly created DES pointing to restored key* while triggering the restore.

   This time, the restore should be successful.

   ![Screenshot shows the selection of DES pointing to the restored key and trigger the restore.](https://github.com/MicrosoftDocs/Backup-Confidential-VMs-with-CMK/blob/main/articles/media/backup-confidential-vm-with-customer-managed-key/re-trigger-restore.png)

***Note***

*If you select ***snapshot only tier*** recovery point to restore and then trigger the restore by selecting a different DES (than the original DES), an error appears. This happens because restore from a different DES (even though that is pointing to correct key) is currently not supported from the ***snapshot only tier***.*

![Screenshot shows Snapshot only tier.](https://github.com/MicrosoftDocs/Backup-Confidential-VMs-with-CMK/blob/main/articles/media/backup-confidential-vm-with-customer-managed-key/restore-using-snapshot-only-tier.png)

*Restore error on selection of snapshot only tier.*

![Screenshot shows restore error pn selection of snapshot only tier.](https://github.com/MicrosoftDocs/Backup-Confidential-VMs-with-CMK/blob/main/articles/media/backup-confidential-vm-with-customer-managed-key/restore-error-on-selecting-snapshot-only-tier.png)
