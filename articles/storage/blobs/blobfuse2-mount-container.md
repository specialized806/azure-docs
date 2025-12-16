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

You can mount a container by using the command-line or by using a configuration file. 

## Mount using the command-line

This is the simplest way to mount a container is by using the mount command. The parameters like memory, disk limits, and parallelism are automatically decided based on system configuration. For a complete list of CLI parameters, see [CLI Parameters](https://github.com/Azure/azure-storage-fuse/wiki/Blobfuse2-Cli-Parameters)

First, set the account name, container name, auth type and authentication details by using environment variables. For a complete list of environment variables, see [Complete list of Environment Variables.](https://github.com/Azure/azure-storage-fuse/wiki/Blobfuse-Environment-Variables).

Before you mount a container, choose whether you want to use steaming mode (block cache) or cache mode (block cache) for data transfer. See [Streaming versus caching mode](blobfuse2-streaming-versus-caching.md).

### Option 1: Mount the container in caching mode

To mount a Blob Storage container in caching (file cache) mode, use the `mount` command and specify the path of the local file cache.  

```bash
sudo blobfuse2 mount <mount-path> --tmp-path=<local-cache-path>
```

- Replace the `<mount-path>` placeholder with the name of the Blob Storage container (For example: `~/mycontainer`).

- Replace the `<local-cache-path>` placeholder with the path of the local file cache.

Or Streaming (block cache) mode using following command:

### Option 2: Mount the container in streaming mode

To mount a Blob Storage container in streaming mode, use the `mount` command with the `--streaming` parameter.  

```bash
sudo blobfuse2 mount <mount-path> --streaming
```

Replace the `<mount-path>` placeholder with the name of the Blob Storage container (For example: `~/mycontainer`).

## Mount using a configuration file

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

## Next steps

Put something here

