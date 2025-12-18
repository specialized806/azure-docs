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

# Create a BlobFuse2 configuration file

A BlobFuse configuration file is used to define how BlobFuse connects to Azure Blob Storage and manages its behavior when mounting a container as a filesystem on Linux.

## How to create a configuration file

BlobFuse needs following important configuration to mount Blob Storage account

BlobFuse has a feature to auto generate configuration file with some pre-filled details using command mentioned below.
Generate caching (file cache) mode configuration file:

`blobfuse2 gen-configuration --tmp-path=<local cache path> --o <path to save generated config>`

Generate streaming (block cache) mode configuration file:

`blobfuse2 gen-configuration --streaming --o <path to save generated config>`

> [!NOTE]
> After generating the file, details like Azure Storage credentials needs to be added in the file before using it for mounting.

1. Pipeline configuration: Helps to determine the components to be engaged. For example:

   ```yaml
   components:
   - libfuse
   - block_cache
   - file_cache
   - attr_cache
   - azstorage
   ```

   > [!NOTE]
   > Only one of `file_cache` or `block_cache` can be used.

1. Caching configuration: BlobFuse2 has 2 modes - caching (file cache) and streaming (block cache). Choosing the caching mode is crucial in getting optimal performance for your workload. See [Streaming versus caching mode](blobfuse2-streaming-versus-caching.md).

   > [!NOTE]
   > You should only mention component related to one caching mode in pipeline configuration. For example:

   ```yaml
   file_cache:
   path: /tmp/blobfusecache
   timeout-sec: 120 
   ```

   or

   ```yaml
   block_cache:
   block-size-mb: 16
   mem-size-mb: 80
   disk-timeout-sec: 120
   ```

1. Azure Storage configuration: It contains settings for connecting to an Azure Storage account. This includes parameters for storage account name, account key, blob container name, endpoint URL, and authentication mode (such as key, msi, or spn). For example:

   ```yaml
   azstorage:
   type: adls
   account-name: myaccount
   container: mycontainer
   endpoint: blob.core.windows.net
   mode: msi
   appid: myappid
   ```

In addition, there are other optional configuration setting which can be used to fine tune the mount. For details about the configuration options, refer the [baseSampalConfig](https://github.com/Azure/azure-storage-fuse/blob/main/setup/baseConfig.yaml) and [configuration file best practices.](https://github.com/Azure/azure-storage-fuse/wiki/Config-File-Best-Practices)

> [!TIP]
> BlobFuse2 also supports auto-generating configs using blobfuse2 gen-configuration and allows overrides via CLI parameters or environment variables.

## Configuration file best practices

- If `type` is **not provided** in the `azstorage` section of the configuration file, then BlobFuse will auto-detect the account type and set the respective endpoint. Therefore, if you use private endpoints, then you must expose the DFS endpoint, otherwise the mount will fail.

- If `type` **is provided** in the `azstorage` section of the configuration file, then don't mount a hierarchical namespace enabled account with `type: block` in the `azstorage` section. Otherwise, some directory operations will fail. Don't mount a flat namespace account with `type: adls` in the `azstorage` section. Otherwise, you'll receive mount failures.

- To disable all forms of caching at kernel as well as at BlobFuse level, set `-o direct_io` CLI parameter.This option forces every operation to call the storage service directly, ensuring you always have the most up-to-date data.
  
  > [!WARNING]
  > This configuration will lead to increased storage costs, as it generates more transactions.

- To disable only kernel cache but keep BlobFuse cache (data and metadata), set `disable-kernel-cache: true` in common configurations.

  - Both `direct-io: true` and `disable-kernel-cache: true` should not be use together.
  
  - To control metadata caching at blobfuse set `attr-cache-timeout`.
  
  - To control data caching at blobfuse set `file-cache-timeout`.
  
  - For e.g. if your workflow requires file contents to be refreshed within 3 seconds of update, then set both above timeouts to 3.
  
  - Setting them to 0 may give your instant refresh of contents but at cost of higher REST calls to storage.

For details on the correct format, please refer to this [configuration file](https://github.com/Azure/azure-storage-fuse/blob/ba815585e3ce3b2d08f0009de26c212e655af50c/setup/advancedConfig.yaml#L37).

## Next steps

- [How to create a configuration file](https://github.com/Azure/azure-storage-fuse/wiki/BlobFuse2-ConfigFile)
- [Sample file cache configuration](https://github.com/Azure/azure-storage-fuse/blob/main/sampleFileCacheConfig.yaml)
- [Sample block cache configuration](https://github.com/Azure/azure-storage-fuse/blob/main/sampleBlockCacheConfig.yaml)
- [All configuration options](https://github.com/Azure/azure-storage-fuse/blob/main/setup/baseConfig.yaml)