---
title: Streaming versus caching mode (BlobFuse2)  
titleSuffix: Azure Storage
description: Learn about streaming and caching mode and choose which mode is most appropriate for your workload.
author: normesta
ms.author: normesta

ms.service: azure-blob-storage
ms.topic: concept-article
ms.date: 12/10/2025

ms.custom: linux-related-content

# Customer intent: "As a developer using BlobFuse2, I want to understand the differences between streaming and caching modes, so that I can choose the optimal mode for my workload's performance and storage requirements."
---

# Streaming versus caching mode for BlobFuse2 mounts

You can use BlobFuse to mount an Azure Blob Storage container in either _streaming mode_ or _caching mode_. This article describes each mode and helps you decide which mode is best suited for your workloads.

## Choosing between streaming and caching modes

In _streaming mode_, data is streamed in chunks (blocks) and served as it downloads. This mode is designed for workloads involving **large files**, such as AI/ML training datasets, genomic sequencing, and high performance computing (HPC) simulations. File caching plays an important role in maintaining the integrity of data that is read and written to a Blob Storage file system mount.

Use streaming mode for large files, as it supports streaming for both read and write operations. BlobFuse2 caches blocks of streaming files in memory. For smaller files that don't consist of blocks, the entire file is stored in memory. Caching mode is the alternative mode, which you should use for workloads that don't involve large files, where files are stored on disk in their entirety.

In _caching mode_, BlobFuse2 downloads the entire file from Azure Blob Storage into a **local cache directory** before making it available to the application. All subsequent reads and writes come from this local cache until the file is evicted or invalidated. If a file is created or modified, closing the file handle from the application triggers the upload of this file to the storage container. This mode is suitable for workloads with repeated reads of files or datasets that can fit on the local disk.

The following diagram helps you decide between these two modes when working with read-only workloads.

:::image type="content" source="media/blobfuse2-choose-data-transfer-mode/read-workload-decision-tree.png" alt-text="Diagram that helps you choose between block cache or file cache for read-only workloads." lightbox="media/blobfuse2-choose-data-transfer-mode/read-workload-decision-tree.png":::

The following diagram helps you decide between these two modes when working with read-write workloads.

:::image type="content" source="media/blobfuse2-choose-data-transfer-mode/read-write-workload-decision-tree.png" alt-text="Diagram that shows how to choose between block cache and file cache mode for read-write workloads." lightbox="media/blobfuse2-choose-data-transfer-mode/read-write-workload-decision-tree.png":::

## Next steps

- [Configure BlobFuse2 for streaming mode](blobfuse2-configure-streaming.md)
- [Configure BlobFuse2 for caching mode](blobfuse2-configure-caching.md)
