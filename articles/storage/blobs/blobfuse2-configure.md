---
title: Configure BlobFuse2 settings
titleSuffix: Azure Storage
description: Learn how to configure BlobFuse2 settings before mounting an Azure Blob Storage container through the Linux file system.
author: normesta
ms.author: normesta

ms.service: azure-blob-storage
ms.topic: how-to
ms.date: 12/10/2025

ms.custom: linux-related-content

# Customer intent: "As a Linux user, I want to mount Azure Blob Storage as a file system using BlobFuse2, so that I can perform standard file operations and improve access to my data in a familiar environment."
---

# Configure BlobFuse2 settings

Introduction goes here.

## How to configure BlobFuse2

You can configure BlobFuse2 by using various settings. Some of the typical settings include:

- Logging location and options
- Temporary file path for caching
- Information about the Azure storage account and blob container to be mounted

The settings can be configured in a YAML configuration file, using environment variables, or as parameters passed to the BlobFuse2 commands. The preferred method is to use the configuration file.

For details about each of the configuration parameters for BlobFuse2 and how to specify them, see these articles:

- [Configure settings for BlobFuse2](blobfuse2-configuration.md)
- [BlobFuse2 configuration file](blobfuse2-configuration.md#configuration-file)
- [BlobFuse2 environment variables](blobfuse2-configuration.md#environment-variables)
- [BlobFuse2 mount commands](blobfuse2-commands-mount.md)

To configure BlobFuse2 for mounting:

1. [Configure caching](#configure-caching).
1. [Create an empty directory to mount the blob container](#create-an-empty-directory-to-mount-the-blob-container).
1. [Authorize access to your storage account](#authorize-access-to-your-storage-account).

### Configure caching

BlobFuse2 provides native-like performance by using local file-caching techniques. The caching configuration and behavior varies, depending on whether you're streaming large files or accessing smaller files.

#### Configure caching for streaming large files

BlobFuse2 supports streaming for read and write operations as an alternative to disk caching for files. In streaming mode, BlobFuse2 caches blocks of large files in memory both for reading and writing. The configuration settings related to caching for streaming are under the `stream:` settings in your configuration file:

```yml
stream:
    block-size-mb:
        For read only mode, the size of each block to be cached in memory while streaming (in MB)
        For read/write mode, the size of newly created blocks
    max-buffers: The total number of buffers to store blocks in
    buffer-size-mb: The size for each buffer
```

#### Configure caching for smaller files

Smaller files are cached to a temporary path that's specified under `file_cache:` in the configuration file:

```yml
file_cache:
    path: <path to local disk cache>
```

> [!NOTE]
> BlobFuse2 stores all open file contents in the temporary path. Make sure you have enough space to contain all open files.
>

You have three common options to configure the temporary path for file caching:

- [Use a local high-performing disk](#use-a-local-high-performing-disk)
- [Use a RAM disk](#use-a-ram-disk)
- [Use an SSD](#use-an-ssd)

##### Use a local high-performing disk

If you use an existing local disk for file caching, choose a disk that provides the best performance possible, such as a solid-state disk (SSD).

##### Use a RAM disk

The following example creates a RAM disk of 16 GB and a directory for BlobFuse2. Choose a size that meets your requirements. BlobFuse2 uses the RAM disk to open files that are up to 16 GB in size.

```bash
sudo mkdir /mnt/ramdisk
sudo mount -t tmpfs -o size=16g tmpfs /mnt/ramdisk
sudo mkdir /mnt/ramdisk/blobfuse2tmp
sudo chown <youruser> /mnt/ramdisk/blobfuse2tmp
```

##### Use an SSD

In Azure, you can use the SSD ephemeral disks that are available on your VMs to provide a low-latency buffer for BlobFuse2. Depending on the provisioning agent you use, mount the ephemeral disk on */mnt* for cloud-init or */mnt/resource* for Microsoft Azure Linux Agent (waagent) VMs.

Make sure that your user has access to the temporary path:

```bash
sudo mkdir /mnt/resource/blobfuse2tmp -p
sudo chown <youruser> /mnt/resource/blobfuse2tmp
```

### Create an empty directory to mount the blob container

To create an empty directory to mount the blob container:

```bash
mkdir ~/mycontainer
```

### Authorize access to your storage account

You must grant access to the storage account for the user who mounts the container. The most common ways to grant access are by using one of the following options:

- Storage account access key
- Shared access signature
- Managed identity
- Service principal

You can provide authorization information in a configuration file or in environment variables. For more information, see [Configure settings for BlobFuse2](blobfuse2-configuration.md).

## Subheading goes here

Subheading info goes here.

## Next steps

Put links here.

