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

Diagram goes here

### Read-write workloads

Diagram goes here

## Caching mode

When a file is the subject of a write operation, the data is first persisted to cache on a local disk. The data is written to Blob Storage only after the file handle is closed. If an issue attempting to persist the data to Blob Storage occurs, an error message appears.

Use the following diagram as a guide to choosing an optimal file caching configuration.

Diagram goes here.

## Steaming mode (Block cache)

For streaming during read and write operations, blocks of data are cached in memory as they're read or updated. Updates are flushed to Azure Storage when a file is closed or when the buffer is filled with dirty blocks.

Reading the same blob from multiple simultaneous threads is supported. However, simultaneous write operations might result in unexpected file data outcomes, including data loss. Performing simultaneous read operations and a single write operation is supported, but the data being read from some threads might not be current.

Use the following diagram as a guide to choosing an optimal block cache configuration.

Diagram goes here.

### Recommendations for using Block cache

* User applications must check the returned code(success/failure) for filesystem calls like read, write, close, flush, etc. If error is returned, the application must abort their respective operation.
* User applications must ensure that there is only one writer at a time for a given file.
* When dealing with very large files (in TiB), the block-size must be configured accordingly. Azure Storage supports only [50,000blocks(https://learn.microsoft.com/en-us/rest/api/storageservices/put-block-list?tabs=microsoft-entra-id#remarks) per blob.

### Block cache should be used with following caveats

* Concurrent write operations on the same file using multiple handles is not checked for data consistency and may lead toincorrect data being written.
* A read operation on a file that is being written to simultaneously by another process or handle will not return the mostup-to-date data.
* When copying files with trailing null bytes using cp utility to a Blobfuse2 mounted path, use --sparse=never parameter to avoid data being trimmed. For example, cp--sparse=never src dest.
* In write operations, data written is persisted(or committed) to the Azure Storage container only when close, sync or flushoperations are called by user application.
* Files cannot be modified if they were originally created with block-size different than the one configured.

There is an option to disable caching either at both the Kernel and BlobFuse levels or exclusively at the Kernel level. Refer [this page](#No-caching) for details.

## Next steps

Put links here