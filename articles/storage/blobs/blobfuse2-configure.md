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

A BlobFuse configuration file is used to define how BlobFuse connects to Azure Blob Storage and manages its behavior when mounting a container as a filesystem on Linux. 

## How to create a config file (from WIKI)

BlobFuse needs following important configuration to mount Blob Storage account

BlobFuse has a feature to auto generate configuration file with some pre-filled details using command mentioned below.
Generate Caching (File cache) mode configuration file: 

`blobfuse2 gen-config --tmp-path=<local cache path> --o <path to save generated config>`

Generate Streaming (Block cache) mode configuration file:

`blobfuse2 gen-config --streaming --o <path to save generated config>`

Note: After generating the file, details like Azure storage credentials needs to be added in the file before using it for mounting.


1. Pipeline configuration: Helps to determine the components to be engaged. For example:

```
components:
- libfuse
- block_cache
- file_cache
- attr_cache
- azstorage
                                                                 
```

> [!NOTE]
> Only one of filecache or blockcache can be used.

2. Cache configuration: BlobFuse2 has 2 modes - Caching (File Cache) and Streaming (Block cache). Choosing the caching mode is crucial in getting optimal performance for your workload. See [Streaming versus caching mode](blobfuse2-choose-data-transfer-mode.md).

   Note: You should only mention component related to one caching mode in pipeline configuration. For example:

```
file_cache:
  path: /tmp/blobfusecache
  timeout-sec: 120 
```

 or

```
block_cache:
  block-size-mb: 16
  mem-size-mb: 80
  disk-timeout-sec: 120
```

3. Azure storage configuration: It contains settings for connecting to an Azure Storage account. This includes parameters for storage account name, account key, blob container name, endpoint URL, and authentication mode (such as key, msi, or spn). For example:

```
azstorage:
  type: adls
  account-name: myaccount
  container: mycontainer
  endpoint: blob.core.windows.net
  mode: msi
  appid: myappid
```

In addition, there are other optional configuration setting which can be used to fine tune the mount. For details about the configuration options, refer the [baseSampalConfig](https://github.com/Azure/azure-storage-fuse/blob/main/setup/baseConfig.yaml) and [config file best practices.](https://github.com/Azure/azure-storage-fuse/wiki/Config-File-Best-Practices)

> Tip: BlobFuse2 also supports auto-generating configs using blobfuse2 gen-config and allows overrides via CLI parameters or environment variables.

Config File Best Practices

- If `type` is **not provided** in the `azstorage` section of the config file:  
  - **Blobfuse** will auto-detect the account type and set the respective endpoint.  
  - For **private endpoints**, exposing the DFS endpoint is required, otherwise the mount will fail.  
- If `type` **is provided** in the `azstorage` section of the config file:  
  - **HNS account** should **not** be mounted with `type: block` (used to specify FNS) in the `azstorage` section.  
    - This will result in failure of certain directory operations.  
  - **FNS account** should **not** be mounted with `type: adls` (used to specify HNS) in the `azstorage` section.  
    - This will cause mount failures.
- To disable all forms of caching at kernel as well as at Blobfuse level, set `-o direct_io` CLI parameter.
  - This option forces every operation to call the storage service directly, ensuring you always have the most up-to-date data.
  - This configuration will lead to increased storage costs, as it generates more transactions.
- To disable only kernel cache but keep Blobfuse cache (data and metadata), set `disable-kernel-cache: true` in common configurations.
  - Both `direct-io: true` and `disable-kernel-cache: true` should not be use together.
  - To control metadata caching at blobfuse set `attr-cache-timeout`.
  - To control data caching at blobfuse set `file-cache-timeout`.
  - For e.g. if your workflow requires file contents to be refreshed within 3 seconds of update, then set both above timeouts to 3.
  - Setting them to 0 may give your instant refresh of contents but at cost of higher REST calls to storage.

For details on the correct format, please refer to this [config file](https://github.com/Azure/azure-storage-fuse/blob/ba815585e3ce3b2d08f0009de26c212e655af50c/setup/advancedConfig.yaml#L37).


****** Not sure what to do with this material *****

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

### Create an empty directory to mount the blob container

To create an empty directory to mount the blob container:

```bash
mkdir ~/mycontainer
```

## Next steps

Put links here.

