---
title: How to mount an Azure Blob Storage container on Linux with BlobFuse2
titleSuffix: Azure Storage
description: Learn how to mount an Azure Blob Storage container on Linux with BlobFuse2.
author: normesta
ms.author: normesta

ms.service: azure-blob-storage
ms.topic: how-to
ms.date: 01/26/2023
ms.custom: linux-related-content
# Customer intent: As a Linux user, I want to mount an Azure Blob Storage container using BlobFuse2, so that I can efficiently access and manage blob data as if it were part of the local file system.
---

# How to mount an Azure Blob Storage container on Linux with BlobFuse2

Put some sort of introductory sentance here.

There are two methods available for mounting:

1. Command-line interface (CLI)

2. Configuration file (config file)

You must also decide if you want to mount BlobFuse in Caching mode (File Cache) or Streaming mode (Block cache) before mounting. For guidance, please refer the [Config Guide](https://github.com/Azure/azure-storage-fuse/wiki/Blobfuse2-Config-Guide).

## Mount a Blob Storage container by using the command-line

This is the simplest way to mount by specifying Caching (File cache) mode or Streaming (Block cache) mode in the mount command. The parameters like memory, disk limits, and parallelism are automatically decided based on system configuration.

Note - Azure storage configurations like account name, container name, auth type and authentication details should be provided via. [Environment Variables](https://github.com/Azure/azure-storage-fuse/wiki/Blobfuse-Environment-Variables) as shown below:

- `AZURE_STORAGE_AUTH_TYPE="msi"`

- `AZURE_STORAGE_ACCOUNT="mystorageaccount"`

- `AZURE_STORAGE_IDENTITY_OBJECT_ID="myobjectid"`

- `AZURE_STORAGE_ACCOUNT_CONTAINER="mycontainer"`

 [Complete list of Environment Variables.](https://github.com/Azure/azure-storage-fuse/wiki/Blobfuse-Environment-Variables)

For detailed information on mounting with CLI, refer [this page](https://github.com/Azure/azure-storage-fuse/wiki/Mount-Blobfuse#command-line-interface-cli) 

[Complete list of CLI Parameters.](https://github.com/Azure/azure-storage-fuse/wiki/Blobfuse2-Cli-Parameters)

### Mount the container in caching mode

To mount a Blob Storage container in caching (file cache) mode, use the `mount` command and specify the path of the local file cache.  

```bash
sudo blobfuse2 mount <mount-path> --tmp-path=<local-cache-path>
```

- Replace the `<mount-path>` placeholder with the name of the Blob Storage container (For example: `~/mycontainer`).

- Replace the `<local-cache-path>` placeholder with the path of the local file cache

Or Streaming (block cache) mode using following command:

### Mount the container in streaming mode

To mount a Blob Storage container in streaming mode, use the `mount` command with the `--streaming` parameter.  

```bash
sudo blobfuse2 mount <mount-path> --streaming
```

Replace the `<mount-path>` placeholder with the name of the Blob Storage container (For example: `~/mycontainer`).

## Mount a Blob Storage container by using a configuration file

You should specify the necessary BlobFuse configuration and Azure storage credentials in a configuration file in YAML format, which BlobFuse can then use to mount with the following command:

```bash
sudo blobfuse2 mount <mount-path> –-config-file=<configuration-file>
```

- Replace the `<mount-path>` placeholder with the name of the Blob Storage container (For example: `~/mycontainer`).

- Replace the `<configuration-file>` placeholder with the name of the configuration file (For example: `./config.yaml`).

> [!NOTE]
> For a full list of mount options, see [BlobFuse2 mount commands](blobfuse2-commands-mount.md).

For detailed information on using config file, refer [this page](https://github.com/Azure/azure-storage-fuse/wiki/Mount-Blobfuse#using-a-configuration-file-config-file)

[How to create a Config file](https://github.com/Azure/azure-storage-fuse/wiki/BlobFuse2-ConfigFile)

[Sample File Cache Config](https://github.com/Azure/azure-storage-fuse/blob/main/sampleFileCacheConfig.yaml)
[Sample Block-Cache Config](https://github.com/Azure/azure-storage-fuse/blob/main/sampleBlockCacheConfig.yaml)

[All Config options](https://github.com/Azure/azure-storage-fuse/blob/main/setup/baseConfig.yaml)

## Work with data in a mounted container

You should now have access to your block blobs through the Linux file system and related APIs. To test your deployment, try creating a new directory and file:

```bash
cd ~/mycontainer
mkdir test
echo "hello world" > test/blob.txt
```

Generally, you can work with the BlobFuse2-mounted storage like you would work with the native Linux file system. It uses the virtual directory scheme with a forward slash (`/`) as a delimiter in the file path and supports basic file system operations such as `mkdir`, `opendir`, `readdir`, `rmdir`, `open`, `read`, `create`, `write`, `close`, `unlink`, `truncate`, `stat`, and `rename`.

However, you should be aware of some key [BlobFuse2 and Linux file systems compared](blobfuse2-compare-linux-file-system.md):

- [Differences between the Linux file system and BlobFuse2](blobfuse2-what-is.md#differences-between-the-linux-file-system-and-blobfuse2)
- [Data integrity](blobfuse2-what-is.md#data-integrity)
- [Permissions](blobfuse2-what-is.md#permissions)

## See also

- [Migrate to BlobFuse2 from BlobFuse v1](https://github.com/Azure/azure-storage-fuse/blob/main/MIGRATION.md)
- [BlobFuse2 commands](blobfuse2-commands.md)
- [Troubleshoot BlobFuse2 issues](blobfuse2-troubleshooting.md)

## Next steps

- [Configure settings for BlobFuse2](blobfuse2-configuration.md)
- [Use Health Monitor to gain insights into BlobFuse2 mount activities and resource usage](blobfuse2-health-monitor.md)
