---
title: BlobFuse2 and Linux file systems compared
titleSuffix: Azure Storage
description: Learn about the differences between a BlobFuse2 file system and a Linux file system.
author: normesta
ms.author: normesta

ms.service: azure-blob-storage
ms.topic: reference
ms.date: 12/10/2025

ms.custom: linux-related-content

# Customer intent: "As a Linux user, I want to mount Azure Blob Storage as a file system using BlobFuse2, so that I can perform standard file operations and improve access to my data in a familiar environment."
---

# BlobFuse2 and Linux file systems compared

Introduction goes here.

## Differences between the Linux file system and BlobFuse2

In many ways, you can use BlobFuse2-mounted storage just like the native Linux file system. The virtual directory scheme is the same and uses a forward slash (`/`) as a delimiter. Basic file system operations like `mkdir`, `opendir`, `readdir`, `rmdir`, `open`, `read`, `create`, `write`, `close`, `unlink`, `truncate`, `stat`, and `rename` work the same as in the Linux file system.

BlobFuse2 is different from the Linux file system in some key ways:

- **Readdir count of hard links**:

  For performance reasons, BlobFuse2 doesn't correctly report the hard links inside a directory. The number of hard links for empty directories returns as 2. The number for non-empty directories always returns as 3, regardless of the actual number of hard links.

- **Non-atomic renames**:

  Azure Blob Storage doesn't support atomic rename operations. Single-file renames are actually two operations: a copy, and then a deletion of the original. Directory renames recursively enumerate all files in the directory and renames each file.

- **Special files**:

  BlobFuse2 supports only directories, regular files, and symbolic links. Special files like device files, pipes, and sockets aren't supported.

- **mkfifo**:

  Fifo creation isn't supported by BlobFuse2. Attempting this action results in a "function not implemented" error.

- **chown and chmod**:

  BlobFuse2 does not support `chown` operations for either block blob storage (FNS) or Data Lake Storage (HNS). FNS storage accounts do not support `chmod` operations, HNS storage accounts do support `chmod` operations but only on child objects inside of the mount directory, not on the root mount directory.
  
- **Device files or pipes**:

  BlobFuse2 doesn't support creating device files or pipes.

- **Extended-attributes (x-attrs)**:

  BlobFuse2 doesn't support extended-attributes (`x-attrs`) operations.

- **Write-streaming**:

  Concurrent streaming of read and write operations on large file data might produce unpredictable results. Simultaneously writing to the same blob from different threads isn't supported.

## Next steps

Put links here.

