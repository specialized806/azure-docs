---
title: Steaming versus caching mode (BlobFuse2)  
titleSuffix: Azure Storage
description: Learn about streaming and caching mode, choose which mode is most appropriate for your workload, and how to configure that mode.  
author: normesta
ms.author: normesta

ms.service: azure-blob-storage
ms.topic: concept-article
ms.date: 12/10/2025

ms.custom: linux-related-content

# Customer intent: "As a Linux user, I want to mount Azure Blob Storage as a file system using BlobFuse2, so that I can perform standard file operations and improve access to my data in a familiar environment."
---

# Streaming versus caching mode (BlobFuse2)

Introduction goes here. Brief description of each model

In _caching mode_, Blobfuse downloads the entire file from Azure Blob Storage into a **local cache directory** before making it available to the application. All subsequent reads and writes are served from this local cache until the file is evicted or invalidated. If the file was created or modified, then close of file-handles from application end will trigger upload of this file to storage container. This mode is suitable for workloads with repeated reads of files or datasets which can fit in local disk.

In _streaming mode_ data is streamed in chunks (blocks) and serves it as it downloads. This is designed for workloads involving **large files**, such as AI/ML training datasets, genomic sequencing, and HPC simulations.

File caching plays an important role in the integrity of data that's read and written to a Blob Storage file system mount. We recommend streaming mode for use with large files, which supports streaming for both read and write operations. BlobFuse2 caches blocks of streaming files in memory. For smaller files that don't consist of blocks, the entire file is stored in memory. File cache is the second mode. We recommend file cache for workloads that don't contain large files, such as when files are stored on disk in their entirety.

## Choose between caching and streaming mode

Base your decision on whether the workload is read-only or read-write

### Read only workloads

Brief description goes here.

Diagram goes here:::image type="content" source="media/blobfuse2-choose-data-transfer-mode/read-workload-decision-tree.png" alt-text="Diagram that helps you choose between block cache or file cache for read-only workloads." lightbox="media/blobfuse2-choose-data-transfer-mode/read-workload-decision-tree.png":::

### Read-write workloads

Brief description goes here.

:::image type="content" source="media/blobfuse2-choose-data-transfer-mode/read-write-workload-decision-tree.png" alt-text="Diagram that shows how to choose between block cache and file cache mode for read-write workloads." lightbox="media/blobfuse2-choose-data-transfer-mode/read-write-workload-decision-tree.png":::

## Next steps

Put links here