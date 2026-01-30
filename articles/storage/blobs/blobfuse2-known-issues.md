---
title: Limitations and known issues with BlobFuse
titleSuffix: Azure Storage
description: Learn about limitations and known issues of BlobFuse.
author: normesta
ms.author: normesta

ms.service: azure-blob-storage
ms.topic: concept-article
ms.date: 1/29/2026

ms.custom: linux-related-content

# Customer intent: "As a Linux user, I want to mount Azure Blob Storage as a file system using BlobFuse, so that I can perform standard file operations and improve access to my data in a familiar environment."
---

# Limitations and known issues with BlobFuse

This article describes limitations and known issues of BlobFuse.

## Chmod operations in premium performance block blob accounts

Premium performance block blob accounts don't support access control lists (ACLs). BlobFuse returns success for `chmod` operations in those types of accounts. 

## Admin privilege required to interact with the fuse driver

When BlobFuse is mounted on a container, SYS_ADMIN privileges are required for it to interact with the fuse driver. If container is created without the privilege, mount will fail. Sample command to spawn a docker container is: `docker run -it --rm --cap-add=SYS_ADMIN --device=/dev/fuse --security-opt apparmor:unconfined <environment variables> <docker image>`

## Limit on the number of containers that can be mounted in parallel

In case of `mount all` system may limit on number of containers you can mount in parallel (when you go above 100 containers). To increase this system limit use below command `echo 256 | sudo tee /proc/sys/fs/inotify/max_user_instances`

### Syslog and securing sensitive information

By default, BlobFuse will send logs to Syslog. The default settings will, in some cases, log relevant file paths to syslog. If this is sensitive information, turn off logging or set log-level to `log_err`.  

## Unsupported file system operations

The following file system operations are not supported in BlobFuse:

`mknod`,`link (hard link api)`,`setxattr`,`getxattr`,`listxattr`,`removexattr`,`access`,`lock`,`bmap`,`ioctl`,`poll`,`write_buf`,`read_buf`,`flock`,`fallocate`,,`copyfilerange`,`lseek`

## Unsupported file system workflows

The following file system workflows aren't supported in BlobFuse:

- Creation of pipes, FIFO queues, Device files

- XAttrs for file or directory

- Hard links for file or directory

- Last access time and Last change time for any file or directory

- `mkfifo` : fifo creation is not supported by BlobFuse and this will result in "function not implemented" error

- `chown`  : Change of ownership is not supported by Azure Storage hence BlobFuse does not support this.

- Creation of device files or pipes is not supported by BlobFuse.

- BlobFuse does not support extended-attributes (x-attrs) operations

- BlobFuse does not support lseek() operation on directory handles. No error is thrown but it will not work as expected.

## Altered behavior for some file system operations

The following file system operations have altered behavior in BlobFuse

- `fsync()` force deletes file from local cache and invalidates attribute cache. This forces BlobFuse to refresh the file metadata and contents on next open call to that file.

- `fsyncdir()` invalidates metadata of that directory recursively. This forces BlobFuse to refresh metadata of any child of that directory on next metadata query by kernel.

## Unsupported scenarios

- BlobFuse does not support overlapping mount paths. While running multiple instances of BlobFuse make sure each instance has a unique and non-overlapping mount point.

- BlobFuse does not support co-existence with NFS on same mount path. Behavior in this case is undefined.

- For storage accounts that have a flat namespace, when data is uploaded through other means, BlobFuse expects special directory marker files to exist in container. For example, if you have a blob `A/B/c.txt` then special marker files shall exist for `A` and `A/B`. To overcome this requirement, BlobFuse uses ListBlob aoi instead of GetBlobProperties api for `ls` operation though `ListBlob` is more expensive.

- For storage accounts that have a flat namespace, `--virtual-directory=false` cli flag or `virtual-directory=false` option under `azstorage` section can be used to switch from `ListBlob` api to `GetBlobProperties` api but in absence of special directory marker, BlobFuse will fail to identify directories. A possible workaround to resolve this from your container is to either create the directory marker files manually through portal or run `mkdir` command for `A` and `A/B` from BlobFuse. Refer [me](https://github.com/Azure/azure-storage-fuse/issues/866) for details on this.

- On non-HNS accounts chmod operations are not permitted and BlobFuse will return back success in such cases.

## Breaking changes

_direct_io_:  To improve performance of repetitive reads from a file BlobFuse utilizes kernel cache. Kernel page cache can only be turned on or off but cannot be controlled by timeout-based expiry. This creates an issue in environment where you wish to sync the latest file from container to your local mount. As long as kernel cache is valid, kernel will not ask for new contents from underlying filesystem (BlobFuse in our case).

To disable the kernel data cache _direct_io_ is the option most customer use. Other than data cache, kernel also maintains a metadata cache. This metadata cache is driven by timeouts configured using `attribute_timeout`, `entry_timeout` and `negative_timeout`. If user wants immediate refresh of contents, then they need to set all these timeouts to 0 as well along with using _direct_io_. With these configuration parameters kernel level caching will be disabled and on top of this user also have to disable BlobFuse level caching (file_cache and attr_cache) with timeouts for them set to 0

This means to disable all caching; user needs to configure roughly seven parameters. To simplify this, as part of _auto config_ feature in version 2.4.0 we started disabling everything when user gives _direct_io_ option. This was to simplify the customer experience, which earlier was generating some issues and complains about the config being too complicated.

However, with this change as both kernel and BlobFuse caching is disabled, BlobFuse started making more calls to storage. This had a cost impact on the customer where higher number of calls were not only degrading performance but were increasing the bill as well. To fix this with correct measures with version 2.5.0 we have introduced a new cli parameter called _disable-kernel-cache_ which only disables kernel level data and metadata caching and then you can control BlobFuse level caching with file-cache timeout and attr-cache timeout values. This allows you to refresh the contents as per your application needs. For example, if the application is fine, and the contents are refreshed in five seconds, then set the file and attribute cache timeouts to five seconds and use this new cli flag. With this your application will get refreshed contents in five seconds and cost will also be under control.

## Synchronizing with data written by other APIs

BlobFuse supports read and write operations. Continuous synchronization of data written to storage by using other APIs or other mounts of BlobFuse isn't guaranteed. For data integrity, we recommend that multiple sources don't modify the same blob, especially at the same time. If one or more applications attempt to write to the same file simultaneously, the results might be unexpected. Depending on the timing of multiple write operations and the freshness of the cache for each operation, the result might be that the last writer wins and previous writes are lost, or generally that the updated file isn't in the intended state.

## See also

- [Troubleshooting BlobFuse](blobfuse2-troubleshooting.md)
- [BlobFuse frequently asked questions](blobfuse2-faq.yml)
- [What is BlobFuse?](blobfuse2-what-is.md)
