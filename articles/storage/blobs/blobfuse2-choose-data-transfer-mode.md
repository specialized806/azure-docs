---
title: Choose between streaming or caching mode (BlobFuse2)  
titleSuffix: Azure Storage
description: Choose between streaming or caching modes when using BlobFuse2 to mount an Azure Blob Storage container. 
author: normesta
ms.author: normesta

ms.service: azure-blob-storage
ms.topic: concept-article
ms.date: 12/10/2025

ms.custom: linux-related-content

# Customer intent: "As a Linux user, I want to mount Azure Blob Storage as a file system using BlobFuse2, so that I can perform standard file operations and improve access to my data in a familiar environment."
---

# Choose between streaming or caching mode (BlobFuse2)

Introduction goes here.

## Data integrity

File caching plays an important role in the integrity of data that's read and written to a Blob Storage file system mount. We recommend streaming mode for use with large files, which supports streaming for both read and write operations. BlobFuse2 caches blocks of streaming files in memory. For smaller files that don't consist of blocks, the entire file is stored in memory. File cache is the second mode. We recommend file cache for workloads that don't contain large files, such as when files are stored on disk in their entirety.

BlobFuse2 supports read and write operations. Continuous synchronization of data written to storage by using other APIs or other mounts of BlobFuse2 isn't guaranteed. For data integrity, we recommend that multiple sources don't modify the same blob, especially at the same time. If one or more applications attempt to write to the same file simultaneously, the results might be unexpected. Depending on the timing of multiple write operations and the freshness of the cache for each operation, the result might be that the last writer wins and previous writes are lost, or generally that the updated file isn't in the intended state.

### File caching on disk

When a file is the subject of a write operation, the data is first persisted to cache on a local disk. The data is written to Blob Storage only after the file handle is closed. If an issue attempting to persist the data to Blob Storage occurs, an error message appears.

### Streaming

For streaming during read and write operations, blocks of data are cached in memory as they're read or updated. Updates are flushed to Azure Storage when a file is closed or when the buffer is filled with dirty blocks.

Reading the same blob from multiple simultaneous threads is supported. However, simultaneous write operations might result in unexpected file data outcomes, including data loss. Performing simultaneous read operations and a single write operation is supported, but the data being read from some threads might not be current.

## Next steps

Put links here.

