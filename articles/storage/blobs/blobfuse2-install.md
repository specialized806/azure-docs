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

BlobFuse can be installed from Microsoft repository for Linux by using simple command to install the BlobFuse package. In addition, there is an option to build the binary from the source code. Refer [this page](https://github.com/Azure/azure-storage-fuse/wiki/Blobfuse2-Installation) for installation instructions.

> [!IMPORTANT]
> BlobFuse v1 support will be discontinued in September 2026. Migrate to BlobFuse v2 using the provided [instructions](https://github.com/Azure/azure-storage-fuse/blob/main/MIGRATION.md).
> Visit [this](https://github.com/Azure/azure-storage-fuse/wiki/Blobfuse2-Supported-Platforms) page to see list of supported Linux distributions.

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

##### [RHEL](#tab/RHEL)

As an example, on a Red Hat Enterprise Linux 8 distribution:

```bash
sudo rpm -Uvh https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm
sudo dnf update
```

Similarly, change the URL to `.../rhel/7/...` to point to a Red Hat Enterprise Linux 7 distribution.

##### [Ubuntu](#tab/Ubuntu)

Another example on an Ubuntu 20.04 distribution:

```bash
sudo wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
```

Similarly, change the URL to `.../ubuntu/16.04/...` or `.../ubuntu/18.04/...` to reference another Ubuntu version.

##### [SLES](#tab/SLES)

```bash
sudo rpm -Uvh https://packages.microsoft.com/config/sles/15/packages-microsoft-prod.rpm
sudo zypper refresh
```

##### [Azure Linux](#tab/tdnf)

```bash
sudo tdnf install -y https://packages.microsoft.com/config/mariner/2.0/packages-microsoft-prod.rpm
sudo tdnf repolist --refresh
```

---

#### Install BlobFuse2 and fuse

##### [RHEL](#tab/RHEL)

```bash
sudo yum install fuse3 fuse3-libs blobfuse2
```

Similarly, change the package name to `blobfuse2-<version>` to install specific version. 

##### [Ubuntu](#tab/Ubuntu)

```bash
sudo apt-get install fuse3 blobfuse2
```
Similarly, change the package name to `blobfuse2=<version>` to install specific version. 

##### [SLES](#tab/SLES)

```bash
sudo zypper install fuse3 blobfuse2
```

Similarly, change the package name to `blobfuse2-<version>` to install specific version. 

##### [Azure Linux](#tab/tdnf)

```bash
sudo tdnf install fuse fuse3 blobfuse2
```

---

### Option 2: Build the binaries from source code

First, install GoLang 1.20.X. See [Go](https://go.dev/doc/install). Then, clone the repository and install the dependencies.

#### Clone the repository

Use the following commands to clone the BlobFuse2 repository.

```bash
git clone https://github.com/Azure/azure-storage-fuse/
cd azure-storage-fuse
git checkout -b main origin/main
```

If you do not have git, install git by using `sudo apt-get install git`

#### Install the dependencies

##### [RHEL](#tab/RHEL)

```bash
sudo yum install fuse3 fuse3-devel
```

##### [Ubuntu](#tab/Ubuntu)

```bash
sudo apt-get install fuse3 libfuse3-dev 
```

##### [SLES](#tab/SLES)

```bash
sudo zypper install fuse3 libfuse3-dev 
```

##### [Azure Linux](#tab/tdnf)

```bash
sudo tdnf install fuse libfuse-dev fuse3 libfuse3-dev 
```

---

#### Build BlobFuse2

Run the build script located in the root folder of the repository.

##### [RHEL](#tab/RHEL)

```bash
./build.sh
```

##### [Ubuntu](#tab/Ubuntu)

```bash
./build.sh fuse2
```

##### [SLES](#tab/SLES)

```bash
./build.sh
```

##### [Azure Linux](#tab/tdnf)

```bash
./build.sh
```

---

If you would also like to build the health monitor binary, run the following command:

```bash
./build.sh health
```

## Next steps

Put links here.

