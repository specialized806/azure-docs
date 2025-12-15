---
title: Limitations and known issues with BlobFuse2
titleSuffix: Azure Storage
description: Learn about limitations and known issues of BlobFuse2.
author: normesta
ms.author: normesta

ms.service: azure-blob-storage
ms.topic: concept-article
ms.date: 12/10/2025

ms.custom: linux-related-content

# Customer intent: "As a Linux user, I want to mount Azure Blob Storage as a file system using BlobFuse2, so that I can perform standard file operations and improve access to my data in a familiar environment."
---

# Limitations and known issues with BlobFuse2

Introduction goes here.

## Limitations

- In case of BlockBlob accounts, ACLs are not supported by Azure Storage so Blobfuse2 will by default return success for 'chmod' operation. However it will work fine for Gen2 (DataLake) accounts.
- When Blobfuse2 is mounted on a container, SYS_ADMIN privileges are required for it to interact with the fuse driver. If container is created without the privilege, mount will fail. Sample command to spawn a docker container is: `docker run -it --rm --cap-add=SYS_ADMIN --device=/dev/fuse --security-opt apparmor:unconfined <environment variables> <docker image>`

- In case of `mount all` system may limit on number of containers you can mount in parallel (when you go above 100 containers). To increase this system limit use below command `echo 256 | sudo tee /proc/sys/fs/inotify/max_user_instances`

- Refer [this](#limitations-in-block-cache) for block-cache limitations.

### Syslog security warning

By default, Blobfuse2 will log to syslog. The default settings will, in some cases, log relevant file paths to syslog. 
If this is sensitive information, turn off logging or set log-level to LOG_ERR.  

## Following file-system operations are not supported in Blobfuse2

- mknod
- link (hard link api)
- setxattr
- getxattr
- listxattr
- removexattr
- access
- lock
- bmap
- ioctl
- poll
- write_buf
- read_buf
- flock
- fallocate
- copyfilerange
- lseek

## Following file-system workflows are not supported in Blobfuse2

- Creation of pipes, FIFO queues, Device files
- XAttrs for file or directory
- Hardlinks for file or directory
- Last access time and Last change time for any file or directory
- mkfifo : fifo creation is not supported by blobfuse2 and this will result in "function not implemented" error
- chown  : Change of ownership is not supported by Azure Storage hence Blobfuse2 does not support this.
- Creation of device files or pipes is not supported by Blobfuse2.
- Blobfuse2 does not support extended-attributes (x-attrs) operations
- Blobfuse2 does not support lseek() operation on directory handles. No error is thrown but it will not work as expected.


## Following file-system operations have altered behavior in Blobfuse2

- fsync() force deletes file from local cache and invalidates attribute cache. This forces blobfuse2 to refresh the file metadata and contents on next open call to that file.
- fsyncdir() invalidates metadata of that directory recursively. This forces blobfuse2 to refresh metadata of any child of that directory on next metadata query by kernel.

## Unsupported scenarios

- Blobfuse2 does not support overlapping mount paths. While running multiple instances of Blobfuse2 make sure each instance has a unique and non-overlapping mount point.
- Blobfuse2 does not support co-existence with NFS on same mount path. Behavior in this case is undefined.
- For non-HNS accounts (flat name space), when data is uploaded through other means, Blobfuse2 expects special directory marker files to exist in container. For e.g. if you have a blob 'A/B/c.txt' then special marker files shall exist for 'A' and 'A/B'. To overcome this requirement, BlobFuse2 uses ListBlob aoi instead of GetBlobProperties api for 'ls' opertaion though ListBlob is costlier.
- For non-HNS accounts (flat name space), `--virtual-directory=false` cli flag or `virtual-directory=false` option under `azstorage` section can be used to switch from ListBlob api to GetBlobProperties api but in absence of special directory marker, Blobfuse2 will fail to identify directories. Possible workaround to resolve this from your container is to either create the directory marker files manually through portal or run 'mkdir' command for 'A' and 'A/B' from blobfuse. Refer [me](https://github.com/Azure/azure-storage-fuse/issues/866) for details on this.
- On non-HNS accounts chmod operations are not permitted and Blobfuse2 will return back success in such cases.

## Breaking changes

- *direct_io*:  To improve performance of repetitive reads from a file Blobfuse2 utilizes kernel cache. Kernel page cache can only be turned on or off but cannot be controlled by timeout-based expiry. This creates an issue in environment where you wish to sync the latest file from container to your local mount. As long as kernel cache is valid, kernel will not ask for new contents from underlying filesystem (blobfuse in our case). 
To disable the kernel data cache *direct_io* is the option most customer use. Other than data cache, kernel also maintains a metadata cache. This metadata cache is driven by timeouts configured using *attribute_timeout, entry_timeout and negative_timeout*. If user wants immediate refresh of contents, then they need to set all these timeouts to 0 as well along with using *direct_io*. With these configuration parameters kernel level caching will be disabled and on top of this user also have to disable blobfuse level caching (file_cache and attr_cache) with timeouts for them set to 0. 
This means to disable all caching; user needs to configure roughly 7 parameters. To simplify this, as part of *auto config* feature in version 2.4.0 we started disabling everything when user gives *direct_io* option. This was to simplify the customer experience, which earlier was generating some issues and complains about the config being too complicated. 
However, with this change as both kernel and blobfuse caching is disabled, blobfuse started making more calls to storage. This had a cost impact on the customer where higher number of calls were not only degrading performance but were increasing the bill as well. To fix this with correct measures with version 2.5.0 we have introduced a new cli parameter called *disable-kernel-cache* which only disables kernel level data and metadata caching and then you can control blobfuse level caching with file-cache timeout and attr-cache timeout values. This allows you to refresh the contents as per your application needs. For e.g. if application is fine if it gets refreshed contents in 5 seconds then set the file and attribute cache timeouts to 5 seconds and use this new cli flag. With this your application will get refreshed contents in 5 seconds and cost will also be under control.

## Synchronizing with data written by other APIs

BlobFuse2 supports read and write operations. Continuous synchronization of data written to storage by using other APIs or other mounts of BlobFuse2 isn't guaranteed. For data integrity, we recommend that multiple sources don't modify the same blob, especially at the same time. If one or more applications attempt to write to the same file simultaneously, the results might be unexpected. Depending on the timing of multiple write operations and the freshness of the cache for each operation, the result might be that the last writer wins and previous writes are lost, or generally that the updated file isn't in the intended state.

## Next steps

Put links here.