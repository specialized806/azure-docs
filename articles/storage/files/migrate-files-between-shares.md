---
title: Copy Files Between Azure File Shares
description: Learn how to copy files from one Azure file share to another using common copy tools such as AzCopy and RoboCopy.
ms.service: azure-file-storage
ms.topic: how-to
ms.date: 01/27/2026
ms.author: kendownie
author: khdownie
# Customer intent: As a cloud administrator, I want to copy files between Azure file shares so that I can efficiently transition data with minimal downtime and optimize storage performance.
---

# Copy files from one Azure file share to another

This article describes how to copy files between Azure file shares using common copy tools. You can copy files between HDD and SSD file shares, file shares using a different billing model, or file shares in different Azure regions.

> [!WARNING]
> If you're using Azure File Sync, the copy process is different than described in this article. See [Copy files from one Azure file share to another when using Azure File Sync](../file-sync/file-sync-share-to-share-migration.md).

## Choose a copy tool

This article covers two tools for copying files between Azure file shares: AzCopy and RoboCopy.

**AzCopy** is generally recommended because it uses server-to-server APIs, meaning data is copied directly between storage servers without passing through a local machine. This provides better performance and avoids the need to provision a VM. AzCopy also works with both SMB and NFS file shares and can be run from Windows, Linux, or macOS. If you need to copy files between NFS shares, choose AzCopy.

**RoboCopy** is a Windows command-line utility that uses the SMB protocol for file copy operations. It requires mounting both file shares to a Windows VM. While this adds overhead and cost, you might choose RoboCopy if you need advanced options such as mirroring, granular retry control, or real-time logging.

## Copy files using AzCopy

You can use AzCopy, a command-line utility, to copy files between Azure file shares. AzCopy uses server-to-server APIs, so data is copied directly between storage servers. The instructions are different depending on whether you're using SMB or NFS file shares.

### Properties preserved when copying files with AzCopy

When you use the `--preserve-info` and `--preserve-permissions` flags, AzCopy preserves the following file attributes and permissions:

| Type | Properties (--preserve-info) | Permissions (--preserve-permissions) |
|------|------------------------------|--------------------------------------|
| **SMB file shares** | File attributes (ReadOnly, Hidden, System, Directory, Archive, None, Temporary, Offline, NotContentIndexed, NoScrubData), creation time, last write time | ACLs |
| **NFS file shares** | Creation time, last write time | Owner, group, file mode |

### Copy files between SMB file shares

To copy files between SMB file shares, use the [azcopy copy](/azure/storage/common/storage-use-azcopy-files#copy-files-between-storage-accounts) command. You can authorize access using a SAS token or Microsoft Entra ID.

> [!TIP]
> These examples enclose path arguments with single quotes (''). Use single quotes in all command shells except for the Windows Command Shell (cmd.exe). If you're using a Windows Command Shell (cmd.exe), enclose path arguments with double quotes ("") instead of single quotes ('').

#### Copy a single file between SMB file shares

Use the following command to copy a single file from one SMB file share to another.

```azcopy
azcopy copy 'https://<source-storage-account-name>.file.core.windows.net/<file-share-name>/<file-path><SAS-token>' 'https://<destination-storage-account-name>.file.core.windows.net/<file-share-name>/<file-path><SAS-token>' --preserve-permissions=true --preserve-info=true
```

#### Copy a directory between SMB file shares

Use the following command to copy a directory and all of its files from one SMB file share to another. The result is a directory in the destination file share with the same name.

```azcopy
azcopy copy 'https://<source-storage-account-name>.file.core.windows.net/<file-share-name>/<directory-path><SAS-token>' 'https://<destination-storage-account-name>.file.core.windows.net/<file-share-name><SAS-token>' --recursive --preserve-permissions=true --preserve-info=true
```

#### Copy an entire SMB file share to another storage account

Use the following command to copy an entire SMB file share to another storage account.

```azcopy
azcopy copy 'https://<source-storage-account-name>.file.core.windows.net/<file-share-name><SAS-token>' 'https://<destination-storage-account-name>.file.core.windows.net/<file-share-name><SAS-token>' --recursive --preserve-permissions=true --preserve-info=true
```

#### Copy all SMB file shares, directories, and files to another storage account

Use the following command to copy all SMB file shares, directories, and files from one storage account to another.

```azcopy
azcopy copy 'https://<source-storage-account-name>.file.core.windows.net/<SAS-token>' 'https://<destination-storage-account-name>.file.core.windows.net/<SAS-token>' --recursive --preserve-permissions=true --preserve-info=true
```

### Copy files between NFS file shares

To copy files between NFS Azure file shares, use the [azcopy copy](/azure/storage/common/storage-use-azcopy-files#copy-files-between-storage-accounts) command with the `--from-to=FileNFSFileNFS` flag. The `FileNFSFileNFS` scenario uses the server-to-server copy API. Alternatively, you can use open source file copy tools such as [fpsync and rsync](storage-files-migration-nfs.md#using-fpsync-vs-rsync).

> [!TIP]
> These examples enclose path arguments with single quotes (''). Use single quotes in all command shells except for the Windows Command Shell (cmd.exe). If you're using a Windows Command Shell (cmd.exe), enclose path arguments with double quotes ("") instead of single quotes ('').

#### Copy a single file between NFS file shares

Use the following command to copy a single file from one NFS file share to another.

```azcopy
azcopy copy 'https://<source-storage-account-name>.file.core.windows.net/<file-share-name>/<file-path><SAS-token>' 'https://<destination-storage-account-name>.file.core.windows.net/<file-share-name>/<file-path><SAS-token>' --preserve-permissions=true --preserve-info=true --from-to=FileNFSFileNFS
```

#### Copy a directory between NFS file shares

Use the following command to copy a directory and all of its files from one NFS file share to another. The result is a directory in the destination file share with the same name.

```azcopy
azcopy copy 'https://<source-storage-account-name>.file.core.windows.net/<file-share-name>/<directory-path><SAS-token>' 'https://<destination-storage-account-name>.file.core.windows.net/<file-share-name><SAS-token>' --recursive --preserve-permissions=true --preserve-info=true --from-to=FileNFSFileNFS
```

#### Copy an entire NFS file share to another storage account

Use the following command to copy an entire NFS file share to another storage account.

```azcopy
azcopy copy 'https://<source-storage-account-name>.file.core.windows.net/<file-share-name><SAS-token>' 'https://<destination-storage-account-name>.file.core.windows.net/<file-share-name><SAS-token>' --recursive --preserve-permissions=true --preserve-info=true --from-to=FileNFSFileNFS
```

#### Copy all NFS file shares, directories, and files to another storage account

Use the following command to copy all NFS file shares, directories, and files from one storage account to another.

```azcopy
azcopy copy 'https://<source-storage-account-name>.file.core.windows.net/<SAS-token>' 'https://<destination-storage-account-name>.file.core.windows.net/<SAS-token>' --recursive --preserve-permissions=true --preserve-info=true --from-to=FileNFSFileNFS
```

## Copy files using Robocopy

Follow these steps to copy files using Robocopy, a command-line utility included with Windows. You can only use this method with Windows and SMB file shares.

1. Deploy a Windows virtual machine (VM) in Azure in the same region as your source file share. Keeping the data and networking in Azure is faster and avoids outbound data transfer charges. For optimal performance, we recommend a multi-core VM type with at least 56 GiB of memory, for example **Standard_DS5_v2**.

1. Mount both the source and target file shares to the VM. To make sure the VM has access to all the files, mount the Azure file share with [admin-level access](storage-files-identity-configure-file-level-permissions.md#mount-the-file-share-with-admin-level-access): either with identity-based access with admin-level Azure RBAC roles (recommended) or with storage account key (less secure).

1. Run this command at the Windows command prompt. Optionally, you can include flags for logging features as a best practice (/NP, /NFL, /NDL, /UNILOG). Remember to replace `s:\` and `t:\` with the paths to the mounted source and target shares as appropriate.
   
   ```console
   robocopy s:\ t:\ /MIR /COPYALL /MT:16 /R:2 /W:1 /B /IT /DCOPY:DAT
   ```
   
   You can run the command while your source is still online, but IOPS and throughput used for the Robocopy job counts against your file share limits.

1. After the initial run completes, run the same Robocopy command again to copy over all the changes that happened since the initial run. Any data unchanged since the last copy job is skipped.

1. You can repeat step 4 as many times as you would like before cutting over to the new file share.

## See also

- [Transfer data with AzCopy and file storage](/azure/storage/common/storage-use-azcopy-files)
- [Copy files from one Azure file share to another when using Azure File Sync](../file-sync/file-sync-share-to-share-migration.md)
