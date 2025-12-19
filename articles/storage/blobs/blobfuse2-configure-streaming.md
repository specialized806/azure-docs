---
title: Configure BlobFuse2 for streaming mode
titleSuffix: Azure Storage
description: Learn how to configure BlobFuse2 for streaming mode
author: normesta
ms.author: normesta

ms.service: azure-blob-storage
ms.topic: how-to
ms.date: 12/10/2025

ms.custom: linux-related-content

# Customer intent: "As a Linux user, I want to mount Azure Blob Storage as a file system using BlobFuse2, so that I can perform standard file operations and improve access to my data in a familiar environment."
---

# Configure BlobFuse2 for streaming mode

This article helps you configure BlobFuse2 to mount a container in _streaming mode_. In _streaming mode_, data is streamed in chunks (blocks) and served as it downloads.

> [!TIP]
> You can mount a container in either _streaming mode_ or _caching mode_. To learn more about each mode, see [Streaming versus caching mode](blobfuse2-streaming-versus-caching.md).

## Configuration parameters

Specify the block size, the memory size, and the disk timeout in seconds.


The following example sets these values as parameters to the `mount` command.

```bash
blobfuse2 mount ~/mycontainer --tmp-path=/tmp/blobfusecache --file-cache-timeout=120
```

The following example shows how these settings appear in the BlobFuse2 configuration file.

 ```yaml
   block_cache:
   block-size-mb: 16
   mem-size-mb: 80
   disk-timeout-sec: 120
```

## Choose how to configure streaming mode

For streaming during read and write operations, blocks of data are cached in memory as they're read or updated. Updates are flushed to Azure Storage when a file is closed or when the buffer is filled with dirty blocks.

Reading the same blob from multiple simultaneous threads is supported. However, simultaneous write operations might result in unexpected file data outcomes, including data loss. Performing simultaneous read operations and a single write operation is supported, but the data being read from some threads might not be current.

Use the following diagram as a guide to choosing an optimal streaming configuration.

:::image type="content" source="media/blobfuse2-choose-data-transfer-mode/block-cache-configuration-decision-tree.png" alt-text="Diagram that shows how to configure block cache mode based on various factors." lightbox="media/blobfuse2-choose-data-transfer-mode/block-cache-configuration-decision-tree.png":::

### Configure caching for streaming large files

BlobFuse2 supports streaming for read and write operations as an alternative to disk caching for files. In streaming mode, BlobFuse2 caches blocks of large files in memory both for reading and writing. The configuration settings related to caching for streaming are under the `stream:` settings in your configuration file:

```yml
stream:
    block-size-mb:
        For read only mode, the size of each block to be cached in memory while streaming (in MB)
        For read/write mode, the size of newly created blocks
    max-buffers: The total number of buffers to store blocks in
    buffer-size-mb: The size for each buffer
```

### Recommendations for using streaming mode

- User applications must check the returned code(success/failure) for filesystem calls like read, write, close, flush, etc. If error is returned, the application must abort their respective operation.

- User applications must ensure that there is only one writer at a time for a given file.

- When dealing with very large files (in TiB), the block-size must be configured accordingly. Azure Storage supports only [50,000 blocks](/rest/api/storageservices/put-block-list?tabs=microsoft-entra-id#remarks) per blob.

### Streaming mode should be used with following caveats

- Concurrent write operations on the same file using multiple handles is not checked for data consistency and may lead toincorrect data being written.

- A read operation on a file that is being written to simultaneously by another process or handle will not return the mostup-to-date data.

- When copying files with trailing null bytes using cp utility to a Blobfuse2 mounted path, use --sparse=never parameter to avoid data being trimmed. For example, cp--sparse=never src dest.

- In write operations, data written is persisted(or committed) to the Azure Storage container only when close, sync or flushoperations are called by user application.

- Files cannot be modified if they were originally created with block-size different than the one configured.

There is an option to disable caching either at both the Kernel and BlobFuse levels or exclusively at the Kernel level. Link to an article about how to do this.

## Next steps

Put links here