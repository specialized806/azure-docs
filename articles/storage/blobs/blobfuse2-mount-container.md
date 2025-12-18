---
title: How to mount an Azure Blob Storage container on Linux with BlobFuse2
titleSuffix: Azure Storage
description: Learn how to mount an Azure Blob Storage container on Linux with BlobFuse2.
author: normesta
ms.author: normesta

ms.service: azure-blob-storage
ms.topic: how-to
ms.date: 12/18/2025
ms.custom: linux-related-content
# Customer intent: As a Linux user, I want to mount an Azure Blob Storage container using BlobFuse2, so that I can efficiently access and manage blob data as if it were part of the local file system.
---

# How to mount an Azure Blob Storage container on Linux with BlobFuse2

You can mount a container using by using command-line parameters or by either the command-line interface (CLI) or a configuration file.

## Mount a container by using the command-line

The simplest way to mount a container is by using the mount command. Parameters such as memory, disk limits, and parallelism are automatically configured based on your system configuration. For a complete list of CLI parameters, see [CLI Parameters](https://github.com/Azure/azure-storage-fuse/wiki/Blobfuse2-Cli-Parameters).

First, set the account name, container name, authentication type, and authentication details using environment variables. For a complete list of environment variables, see [Complete list of Environment Variables](https://github.com/Azure/azure-storage-fuse/wiki/Blobfuse-Environment-Variables).

Before mounting a container, choose whether you want to use streaming mode (block cache) or caching mode (file cache) for data transfer. See [Streaming versus caching mode](blobfuse2-streaming-versus-caching.md).

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

You can specify the necessary BlobFuse2 configuration and Azure Storage credentials in a YAML configuration file. BlobFuse2 can then use this file to mount the container with the following command:

```bash
sudo blobfuse2 mount <mount-path> –-config-file=<configuration-file>
```

- Replace the `<mount-path>` placeholder with the name of the Blob Storage container (For example: `~/mycontainer`).

- Replace the `<configuration-file>` placeholder with the path to your configuration file (for example: `./config.yaml`).

> [!NOTE]
> For a full list of mount options, see [BlobFuse2 mount commands](blobfuse2-commands-mount.md).

For detailed information about using a configuration file, see [Using a configuration file](https://github.com/Azure/azure-storage-fuse/wiki/Mount-Blobfuse#using-a-configuration-file-config-file).

For additional configuration resources, see:

- [How to create a configuration file](https://github.com/Azure/azure-storage-fuse/wiki/BlobFuse2-ConfigFile)
- [Sample file cache configuration](https://github.com/Azure/azure-storage-fuse/blob/main/sampleFileCacheConfig.yaml)
- [Sample block cache configuration](https://github.com/Azure/azure-storage-fuse/blob/main/sampleBlockCacheConfig.yaml)
- [All configuration options](https://github.com/Azure/azure-storage-fuse/blob/main/setup/baseConfig.yaml)

## Work with data in a mounted container

Once mounted, you can access your block blobs through the Linux file system and related APIs. To test your deployment, try creating a new directory and file:

```bash
cd ~/mycontainer
mkdir test
echo "hello world" > test/blob.txt
```

You can work with BlobFuse2-mounted storage similarly to how you work with the native Linux file system. It uses a virtual directory scheme with forward slashes (`/`) as delimiters in file paths and supports basic file system operations such as `mkdir`, `opendir`, `readdir`, `rmdir`, `open`, `read`, `create`, `write`, `close`, `unlink`, `truncate`, `stat`, and `rename`.

However, there are some key differences between BlobFuse2 and Linux file systems. For more information, see [BlobFuse2 and Linux file systems compared](blobfuse2-compare-linux-file-system.md).

## Next steps

Now that you've mounted your container, learn more about using BlobFuse2:

- [Configure BlobFuse2](blobfuse2-configure.md)
- [BlobFuse2 commands](blobfuse2-commands.md)
- [BlobFuse2 and Linux file systems compared](blobfuse2-compare-linux-file-system.md)