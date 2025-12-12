---
title: Install BlobFuse2
titleSuffix: Azure Storage
description: Install BlobFuse2 to mount an Azure Blob Storage container through the Linux file system.
author: normesta
ms.author: normesta

ms.service: azure-blob-storage
ms.topic: how-to
ms.date: 12/10/2025

ms.custom: linux-related-content

# Customer intent: "As a Linux user, I want to mount Azure Blob Storage as a file system using BlobFuse2, so that I can perform standard file operations and improve access to my data in a familiar environment."
---

# Install BlobFuse2

Introduction goes here.

## How to install BlobFuse2

You have two options for installing BlobFuse2:

- [**Install BlobFuse2 from the Microsoft software repositories for Linux**](#option-1-install-blobfuse2-from-the-microsoft-software-repositories-for-linux) - This is the preferred method of installation. BlobFuse2 is available in the repositories for several common Linux distributions.
- [**Build the BlobFuse2 binaries from source code**](#option-2-build-the-binaries-from-source-code) - You can build the BlobFuse2 binaries from source code if it is not available in the repositories for your distribution.

### Option 1: Install BlobFuse2 from the Microsoft software repositories for Linux

To see supported distributions, see [BlobFuse2 releases](https://github.com/Azure/azure-storage-fuse/releases).

For information about libfuse support, see the [BlobFuse2 README](https://github.com/Azure/azure-storage-fuse/blob/main/README.md#distinctive-features-compared-to-blobfuse-v1x).

To check your version of Linux, run the following command:

```bash
cat /etc/*-release
```

If no binaries are available for your distribution, you can [Option 2: Build the binaries from source code](#option-2-build-the-binaries-from-source-code).

To install BlobFuse2 from the repositories:

> [Configure the Microsoft package repository](#configure-the-microsoft-package-repository)
>
> [Install BlobFuse2](#install-blobfuse2)

#### Configure the Microsoft package repository

Configure the [Linux Package Repository for Microsoft Products](/windows-server/administration/Linux-Package-Repository-for-Microsoft-Software).

# [RHEL](#tab/RHEL)

As an example, on a Red Hat Enterprise Linux 8 distribution:

```bash
sudo rpm -Uvh https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm
```

Similarly, change the URL to `.../rhel/7/...` to point to a Red Hat Enterprise Linux 7 distribution.

# [Ubuntu](#tab/Ubuntu)

Another example on an Ubuntu 20.04 distribution:

```bash
sudo wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install libfuse3-dev fuse3
```

Similarly, change the URL to `.../ubuntu/16.04/...` or `.../ubuntu/18.04/...` to reference another Ubuntu version.

# [SLES](#tab/SLES)

```bash
sudo rpm -Uvh https://packages.microsoft.com/config/sles/15/packages-microsoft-prod.rpm
```

---

#### Install BlobFuse2

# [RHEL](#tab/RHEL)

```bash
sudo yum install blobfuse2
```

Similarly, change the package name to `blobfuse2-<version>` to install specific version. 

# [Ubuntu](#tab/Ubuntu)

```bash
sudo apt-get install blobfuse2
```
Similarly, change the package name to `blobfuse2=<version>` to install specific version. 

# [SLES](#tab/SLES)

```bash
sudo zypper install blobfuse2
```
Similarly, change the package name to `blobfuse2-<version>` to install specific version. 

---
### Option 2: Build the binaries from source code

To build the BlobFuse2 binaries from source code:

1. Install the dependencies:

    1. Install Git:

       ```bash
       sudo apt-get install git
       ```

    1. Install BlobFuse2 dependencies.

       On Ubuntu:

       ```bash
       sudo apt-get install libfuse3-dev fuse3 -y
       ```

1. Clone the repository:

   ```Git
   sudo git clone https://github.com/Azure/azure-storage-fuse/
   sudo cd ./azure-storage-fuse
   sudo git checkout main
   ```

1. Build BlobFuse2:

    ```Git
    go get
    go build -tags=fuse3
    ```

> [!TIP]
> If you need to install Go, see [Download and install Go](https://go.dev/doc/install).

## Content taken from overview

BlobFuse can be installed from Microsoft repository for Linux by using simple command to install the BlobFuse package. In addition, there is an option to build the binary from the source code. Refer [this page](https://github.com/Azure/azure-storage-fuse/wiki/Blobfuse2-Installation) for installation instructions.

> [!IMPORTANT]
> BlobFuse v1 support will be discontinued in September 2026. Migrate to BlobFuse v2 using the provided [instructions](https://github.com/Azure/azure-storage-fuse/blob/main/MIGRATION.md).
> Visit [this](https://github.com/Azure/azure-storage-fuse/wiki/Blobfuse2-Supported-Platforms) page to see list of supported Linux distros.

## Next steps

Put links here.

