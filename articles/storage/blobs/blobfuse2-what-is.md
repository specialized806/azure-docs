---
title: What is BlobFuse? - BlobFuse2
titleSuffix: Azure Storage
description: An overview of how to use BlobFuse to mount an Azure Blob Storage container through the Linux file system.
author: normesta
ms.author: normesta

ms.service: azure-blob-storage
ms.topic: feature-guide
ms.date: 12/10/2025
ms.custom: linux-related-content
# Customer intent: "As a Linux user, I want to mount Azure Blob Storage as a file system using BlobFuse2, so that I can perform standard file operations and improve access to my data in a familiar environment."
---

# What is BlobFuse? - BlobFuse2

**BlobFuse** is an open-source virtual file system driver that enables seamless integration of Azure Blob Storage with Linux environments. It allows users to mount Azure storage account containers as a file system, making blob data accessible through standard Linux file operations. BlobFuse translates these operations into Azure Blob REST API calls, allowing your applications to leverage the scalability and durability of Azure Blob Storage.

BlobFuse provides several caching mechanisms (file, metadata, attribute caching) to enhance performance and minimize network traffic charges. Users can configure cache location, size, and retention policies for optimal performance.

## Key Use cases

**Model training and checkpointing for AI and ML -** Azure BlobFuse boosts AI/ML workflows by providing fast access to multi-petabyte datasets in Azure Blob Storage with caching. It allows compute nodes (VMs, containers, AKS pods) to efficiently load training data and save model checkpoints. Preloading data withBlobfuse2 ensures quick access before training starts, helping optimize GPU usage. BlobFuse have been validated with distributed ML frameworks like **PyTorch and Ray** for greater workflow portability.

**High-Performance Computing (HPC) -** Enables rapid, scalable access to Azure Blob Storage in HPC settings, supporting efficient data processing across domains such as:

- Autonomous driving workloads (ADAS)using **Azure Kubernetes services** (**AKS)**, leveraging BlobFuse for large-scale simulation and model training data.

- Hydrofoil simulations, where BlobFuse manages computational files and results for streamlined engineering analysis.

- Genomics sequencing, benefiting from BlobFuse’s ability to handle large datasets and accelerate data sharing.

- Gaming simulations, relying on quick data access with BlobFuse to boost parallel processing and scale complex scenarios.

**Cloud-Native Workload Integration -** BlobFuse is used as a persistent storage layer for containers and stateful workloads in Kubernetes using the CSI driver. It allows applications to share large files, model weights, or logs using Azure Blob Storage’s scalable capacity, and is well suited for ReadWrite or ReadOnly access modes in shared cluster scenarios.

**Big Data Analytics/AI training data pre-processing -** Enhances analytics workload by integrating with tools like Hadoop and Spark for efficient data storage and retrieval. BlobFuse is also useful for pre-processing data on blobs for AI data cleaning, validating and pre-processing.

**Data backup and Archiving -** BlobFuse streamlines the backup and archiving of large datasets by allowing direct storage in Azure Blob Storage. It supports major backup tasks, such as RMAN database and enterprise system backups, and provides secure, scalable storage for surveillance video, reducing manual data management.

## How BlobFuse works

BlobFuse leverages the libfuse (fuse3) library to interface with the Linux FUSE kernel module and performs file system operations using Azure Storage REST APIs. It translates Azure Blob Storage object names into a directory-like structure using path conventions, allowing files to be accessed as if residing locally. Operations such as mkdir, opendir, readdir, rmdir, open, read, create, write, close, unlink, truncate, stat, rename are supported. Chmod is also supported for HNS accounts.

BlobFuse has two operating modes:

- Caching (File Cache)

- Streaming (Block cache)

### Caching (File Cache)

In this mode, Blobfuse downloads the entire file from Azure Blob Storage into a **local cache directory** before making it available to the application. All subsequent reads and writes are served from this local cache until the file is evicted or invalidated. If the file was created or modified, then close of file-handles from application end will trigger upload of this file to storage container. This mode is suitable for workloads with repeated reads of files or datasets which can fit in local disk.

### Streaming (Block Cache)

Unlike traditional file caching, which downloads the entire file before serving, block cache mode **streams data in chunks (blocks)** and serves it as it downloads. This is designed for workloads involving **large files**, such as AI/ML training datasets, genomic sequencing, and HPC simulations.

[Recommendations for using Block cache](https://github.com/Azure/azure-storage-fuse/wiki/How-Blobfuse2-Works#recommendations-for-using-block-cache)

> [!NOTE]
> Due to known data consistency issues when using older versions of Blobfuse2 in streaming with `block-cache` mode, it is strongly recommended that all Blobfuse2 installations be upgraded to version 2.3.2 or higher. For more information, see **[this](https://github.com/Azure/azure-storage-fuse/wiki/Blobfuse2-Known-issues)**.

## Supported operations

The general format of the Blobfuse2 commands is `blobfuse2 [command] [arguments] --[flag-name]=[flag-value]`

For detailed information, refer [this page](/azure/storage/blobs/blobfuse2-commands?toc=%2Fazure%2Fstorage%2Fblobs%2Ftoc.json).

<!-- 5th Section -->

## Performance Benchmarks

Refer the [page](https://azure.github.io/azure-storage-fuse/) to check the various performance benchmarks of BlobFuse.

## Features

A full list of BlobFuse2 features is at [BlobFuse2 README](https://github.com/Azure/azure-storage-fuse/wiki/BlobFuse2-Features). Some key features include:

- Gain insights into mount activities and resource usage by using [Health Monitor](https://github.com/Azure/azure-storage-fuse/blob/main/tools/health-monitor/README.md)

- Restrict what all blobs a mount can see or operate upon using [Blob Filter](https://github.com/Azure/azure-storage-fuse/wiki/Blobfuse2%E2%80%90Blob-Filter)

- Downloading entire containers or sub-directories to the local cache when you mount BlobFuse with [Preload Data](https://github.com/Azure/azure-storage-fuse/wiki/Blobfuse2%E2%80%90Preload)

## Logging

Refer [this page](https://github.com/Azure/azure-storage-fuse/wiki/Blobfuse2-Logging) for details on available logging options when using BlobFuse.

### Differences between the Linux file system and BlobFuse2

BlobFuse2 doesn't guarantee 100% POSIX compliance because BlobFuse2 simply translates requests into [Blob REST APIs](/rest/api/storageservices/blob-service-rest-api). For example, rename operations are atomic in POSIX but not in BlobFuse2. See [the full list of differences between a native file system and BlobFuse2](https://github.com/Azure/azure-storage-fuse/wiki/Blobfuse2-Limitations-Issues#differences-between-the-linux-file-system-and-blobfuse2).

## Limitations and Known Issues

Please refer the [pLimitations and known issues with BlobFuse2](blobfuse2-known-issues.md).

## Support

BlobFuse2 is supported by Microsoft if it's used within the specified [limits](#limitations). If you encounter an issue, [report it on GitHub](https://github.com/Azure/azure-storage-fuse/issues).

This table shows how this feature is supported in your account and the effect on support when you enable certain capabilities.

| Storage account type | Blob Storage (default support) | Data Lake Storage <sup>1</sup> | Network File System (NFS) 3.0 <sup>1</sup> | SSH File Transfer Protocol (SFTP) <sup>1</sup> |
|--|--|--|--|--|
| Standard general-purpose v2 | ![Yes](../media/icons/yes-icon.png) |![Yes](../media/icons/yes-icon.png)              | ![Yes](../media/icons/yes-icon.png) | ![Yes](../media/icons/yes-icon.png) |
| Premium block blobs          | ![Yes](../media/icons/yes-icon.png)|![Yes](../media/icons/yes-icon.png) | ![Yes](../media/icons/yes-icon.png) | ![Yes](../media/icons/yes-icon.png) |

<sup>1</sup> Data Lake Storage, the NFS 3.0 protocol, and SFTP support all require a storage account that has a hierarchical namespace enabled.

## Licensing

The BlobFuse2 project is [licensed under the MIT license](https://github.com/Azure/azure-storage-fuse/blob/main/LICENSE)

[About the BlobFuse2 open source project](https://github.com/Azure/azure-storage-fuse/wiki#about-the-blobfuse2-open-source-project)

## See also

- [Migrate to BlobFuse2 from BlobFuse v1](https://github.com/Azure/azure-storage-fuse/blob/main/MIGRATION.md)
- [BlobFuse2 commands](blobfuse2-commands.md)
- [Troubleshoot BlobFuse2 issues](blobfuse2-troubleshooting.md)

## Next steps

- [Mount an Azure Blob Storage container on Linux by using BlobFuse2](blobfuse2-how-to-deploy.md)
- [Configure settings for BlobFuse2](blobfuse2-configuration.md)
- [Use Health Monitor to gain insights into BlobFuse2 mount activities and resource usage](blobfuse2-health-monitor.md)

