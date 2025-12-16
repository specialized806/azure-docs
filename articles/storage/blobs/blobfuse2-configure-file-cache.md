---
title: Configure BlobFuse2 for file caching mode
titleSuffix: Azure Storage
description: Learn how to configure BlobFuse2 for file caching mode
author: normesta
ms.author: normesta

ms.service: azure-blob-storage
ms.topic: how-to
ms.date: 12/10/2025

ms.custom: linux-related-content

# Customer intent: "As a Linux user, I want to mount Azure Blob Storage as a file system using BlobFuse2, so that I can perform standard file operations and improve access to my data in a familiar environment."
---

# Configure BlobFuse2 for caching mode

This article helps you configure streaming mode. To learn more about each mode, see [Streaming versus caching mode](blobfuse2-streaming-versus-caching.md).

## Caching mode

When a file is the subject of a write operation, the data is first persisted to cache on a local disk. The data is written to Blob Storage only after the file handle is closed. If an issue attempting to persist the data to Blob Storage occurs, an error message appears.

Use the following diagram as a guide to choosing an optimal caching configuration.

:::image type="content" source="media/blobfuse2-choose-data-transfer-mode/file-cache-configuration-decision-tree.png" alt-text="Diagram that shows how to configure file caching mode based on various factors." lightbox="media/blobfuse2-choose-data-transfer-mode/file-cache-configuration-decision-tree.png":::

Smaller files are cached to a temporary path that's specified under `file_cache:` in the configuration file:

```yml
file_cache:
    path: <path to local disk cache>
```

> [!NOTE]
> BlobFuse2 stores all open file contents in the temporary path. Make sure you have enough space to contain all open files.

## Configure a temporary path

You can configure a temporary path on a local high performing disk, a RAM disk, or a solid state drive (SSD).

If you use an existing local disk for caching, choose a disk that provides the best performance possible, such as a solid-state disk (SSD).

In Azure, you can use the SSD ephemeral disks that are available on your VMs to provide a low-latency buffer for BlobFuse2. Depending on the provisioning agent you use, mount the ephemeral disk on */mnt* for cloud-init or */mnt/resource* for Microsoft Azure Linux Agent (waagent) VMs.

Make sure that your user has access to the temporary path:

```bash
sudo mkdir /mnt/resource/blobfuse2tmp -p
sudo chown <youruser> /mnt/resource/blobfuse2tmp
```

If you use a RAM disk, choose a size that meets your requirements. The following example creates a RAM disk of 16 GB and a directory for BlobFuse2.  BlobFuse2 uses the RAM disk to open files that are up to 16 GB in size.

```bash
sudo mkdir /mnt/ramdisk
sudo mount -t tmpfs -o size=16g tmpfs /mnt/ramdisk
sudo mkdir /mnt/ramdisk/blobfuse2tmp
sudo chown <youruser> /mnt/ramdisk/blobfuse2tmp
```

## Preload data

In caching mode, BlobFuse waits for open file system call. On receiving the open call it downloads entire file to a local cache before using them. This can make the initial load slower, especially for AI/ML tasks, where application is processing many files. 

The Preload feature helps by downloading entire containers or sub-directories to the local cache when you mount it. Preload enhances data availability, boosting efficiency and reducing wait times. This is vital for AI training with large datasets as it prepares all necessary files in advance, saving GPU time and cutting costs. Combining preload with our blob filter feature allows customers to access specific files in a container or sub-directory, offering extensive flexibility and optimizing GPU cycles.

To enable preload with file-cache mode, use `--preload` parameter. Below is a sample command for reference:

```bash
blobfuse2 mount --preload /mnt/blobfuse_mnt --tmp-path=/home/temp_path 
```

`/mnt/blobfuse_mnt` is where the blob data can be accessed, and /home/temp_path serves as the cache for the BlobFuse mount.

Preloading blob data makes the mount read-only and prevents file eviction. To access updated files, unmount and remount the volume. Newly added files can still be accessed by reading them. If blob filter is used along with preload, only the filtered files are pre-loaded and accessible via the BlobFuse mount.

### Considerations when using the preload feature

- Enabling preload makes the BlobFuse mount read-only.

- All file-caching options in CLI and config file are ignored except for the temporary path setting.

- Ensure enough disk space for all or filtered contents in the container; insufficient space may cause partial loading and block new file access until manual deletion from the local cache.

- Accessing a file immediately after mounting prioritizes it for download while preloading continues in the background.

- BlobFuse logs show preload status and disk warnings.

- BlobFuse mount refreshes preloaded or opened files only if they are manually deleted from the local cache and reopened.

- Blobs added to the Storage container after preload are not automatically downloaded by BlobFuse but can be accessed by reading.

## Next steps

Put links here
