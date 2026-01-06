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
# Customer intent: "As a developer or system administrator working with Linux, I want to understand what BlobFuse2 is and how it works, so that I can evaluate whether it meets my needs for accessing Azure Blob Storage through familiar file system operations for workloads like AI/ML training, HPC simulations, or cloud-native applications."
---

# What is BlobFuse?

BlobFuse is an open-source virtual file system driver that enables seamless integration of Azure Blob Storage with Linux environments. It allows users to mount Azure Storage account containers as a file system, making blob data accessible through standard Linux file operations. BlobFuse translates these operations into Azure Blob REST API calls, so your applications can leverage the scalability and durability of Azure Blob Storage.

BlobFuse provides several caching mechanisms (file, metadata, and attribute caching) to enhance performance and minimize network traffic charges. You can configure the cache location, size, and retention policies for optimal performance.

> [!NOTE]
> BlobFuse2 is the latest version of BlobFuse and has many significant improvements over BlobFuse v1. [BlobFuse v1](storage-how-to-mount-container-linux.md) support will be discontinued in September 2026. Migrate to BlobFuse v2 using the provided [instructions](https://github.com/Azure/azure-storage-fuse/blob/main/MIGRATION.md.

## Key Use cases

**Model training and checkpointing for AI and ML -** Azure BlobFuse boosts AI/ML workflows by providing fast access to multi-petabyte datasets in Azure Blob Storage with caching. It allows compute nodes (virtual machines (VMs), containers, AKS pods) to efficiently load training data and save model checkpoints. Preloading data by using BlobFuse ensures quick access before training starts, helping optimize GPU usage. BlobFuse is validated with distributed ML frameworks like **PyTorch and Ray** for greater workflow portability.

**High-Performance Computing (HPC) -** Enables rapid, scalable access to Azure Blob Storage in HPC settings, supporting efficient data processing across domains such as:

- Autonomous driving workloads (ADAS) using **Azure Kubernetes services** (**AKS**), leveraging BlobFuse for large-scale simulation and model training data.

- Hydrofoil simulations, where BlobFuse manages computational files and results for streamlined engineering analysis.

- Genomics sequencing, benefiting from BlobFuse’s ability to handle large datasets and accelerate data sharing.

- Gaming simulations, relying on quick data access with BlobFuse to boost parallel processing and scale complex scenarios.

**Cloud-Native Workload Integration -** Use BlobFuse as a persistent storage layer for containers and stateful workloads in Kubernetes by using the CSI driver. It allows applications to share large files, model weights, or logs by using Azure Blob Storage’s scalable capacity.BlobFuse is well suited for ReadWrite or ReadOnly access modes in shared cluster scenarios.

**Big Data Analytics/AI training data pre-processing -** Enhances analytics workloads by integrating with tools like Hadoop and Spark for efficient data storage and retrieval. BlobFuse is also useful for preprocessing data on blobs for AI data cleaning, validating, and preprocessing.

**Data backup and Archiving -** BlobFuse streamlines the backup and archiving of large datasets by allowing direct storage in Azure Blob Storage. It supports major backup tasks, such as RMAN database and enterprise system backups. It provides secure, scalable storage for surveillance video, reducing manual data management.

## Key features

- Mount an Azure Blob Storage container or Azure Data Lake Storage file system on Linux.

  BlobFuse supports storage accounts with either flat namespaces or hierarchical namespaces configured.

- Use local file caching to improve subsequent access times.

- Gain insights into mount activities and resource usage by using the [health monitor](blobfuse2-health-monitor.md).

- Restrict which blobs a mount can see or operate on by using a [blob filter](https://github.com/Azure/azure-storage-fuse/wiki/Blobfuse2%E2%80%90Blob-Filter).

- Download entire containers or subdirectories to the local cache when you mount BlobFuse. See [Optimize performance by preloading data](blobfuse2-configure-caching.md#optimize-performance-by-preloading-data).

- Use basic file system operations like `mkdir`, `opendir`, `readdir`, `rmdir`, `open`, `read`, `create`, `write`, `close`, `unlink`, `truncate`, `stat`, and `rename`.

  > [!NOTE]
  > BlobFuse doesn't guarantee 100% POSIX compliance because it translates requests into [Blob REST APIs](/rest/api/storageservices/blob-service-rest-api). For example, rename operations are atomic in POSIX but not in BlobFuse. See [BlobFuse2 and Linux file systems compared](blobfuse2-compare-linux-file-system.md).


## How BlobFuse works

BlobFuse uses the libfuse (fuse3) library to connect with the Linux FUSE kernel module. It performs file system operations by using Azure Storage REST APIs. By using path conventions, it converts Azure Blob Storage object names into a directory-like structure. This conversion lets you access files as if they reside locally. BlobFuse supports operations such as `mkdir`, `opendir`, `readdir`, `rmdir`, `open`, `read`, `create`, `write`, `close`, `unlink`, `truncate`, `stat`, and `rename`. It also supports `chmod` for hierarchical namespace (HNS) accounts.

BlobFuse has two operating modes: _caching_ (file cache) and _streaming_ (block cache).

### Caching mode

In this mode, BlobFuse downloads the entire file from Azure Blob Storage into a local cache directory before making it available to the application. All subsequent reads and writes come from this local cache until the file is evicted or invalidated. If you create or modify the file, closing the file handle from the application triggers the upload of this file to the storage container. This mode works well for workloads that repeatedly read files or datasets that fit on the local disk. 

To learn more, see [Configure BlobFuse for caching mode](blobfuse2-configure-caching.md).

### Streaming mode

Unlike traditional file caching, which downloads the entire file before serving, block cache mode streams data in chunks (blocks) and serves it as it downloads. This mode is designed for workloads that involve large files, such as AI/ML training datasets, genomic sequencing, and HPC simulations. 

To learn more, see [Configure BlobFuse for streaming mode](blobfuse2-configure-streaming.md).

## Performance benchmarks

For various performance benchmarks of BlobFuse, see the [BlobFuse performance page](https://azure.github.io/azure-storage-fuse/).

## Licensing

The BlobFuse project is [licensed under the MIT license](https://github.com/Azure/azure-storage-fuse/blob/main/LICENSE).

## Support

See any of the following articles:

- [Limitations and known issues with BlobFuse](blobfuse2-known-issues.md)
- [Troubleshoot issues in BlobFuse](blobfuse2-troubleshooting.md)
- [BlobFuse frequently asked questions](blobfuse2-faq.yml)

If you encounter an issue that's not described in any of these articles, [report it on GitHub](https://github.com/Azure/azure-storage-fuse/issues).

## Next steps

- [Install BlobFuse](blobfuse2-install.md)
- [Mount an Azure Blob Storage container on Linux with BlobFuse](blobfuse2-mount-container.md)
