---
title: Troubleshoot issues in BlobFuse2
titleSuffix: Azure Storage
description: Learn how to troubleshoot issues in BlobFuse2.
author: normesta
ms.author: normesta

ms.service: azure-blob-storage
ms.topic: troubleshooting
ms.date: 12/02/2022

ms.custom: linux-related-content

# Customer intent: "As a cloud administrator, I want to access troubleshooting resources for BlobFuse2, so that I can efficiently resolve any issues that arise during its use."
---

# Troubleshoot issues in BlobFuse2

This article discusses common issues that you might encounter when you use BlobFuse2. 

> [!NOTE]
> To better understand the underlying cause of an issue, set the log level to debug mode (`log_debug`) before you attempt to reproduce an issue. See [Configure logging for BlobFuse2](blobfuse2-enable-logs.md).

## Common mount problems

This section lists common issues that can occur when attempting to mount a container.

### Error: fusermount: failed to open /etc/fuse.conf: Permission denied

Only the users that are part of the group fuse, and the root user can run `fusermount` command. In order to mitigate this add your user to the fuse group by using the following command.

```bash
sudo addgroup <user> fuse
```

### Error: mount command successful but log shows 'Failed to init fuse'

If are you using `allow-other: true` configuration then make sure `user_allow_other` is enabled in `/etc/fuse.conf` file. By default, `/etc/fuse.conf` will have this option disabled we just need to enable it and save the file.

### Failed to mount: failed to authenticate credentials for azstorage

There might be something wrong about the storage configuration, please double check the storage account name, account key and `container/filesystem` name.

Possible causes for this issue include the following:

- Invalid account or access key

- Non-existing container (The container must be created prior to BlobFuse2 mount).

- Windows line-endings (CRLF) - fix it by running dos2unix

- Use of HTTP while 'Secure Transfer (HTTPS)' is enabled on a storage account

- Enabled VNET Security rule that blocks VM from connecting to the storage account. Ensure you can connect to your storage account using AzCopy or Azure CLI.

- DNS issues & timeouts. Add the storage account resolution to `/etc/hosts` to bypass the DNS lookup

- If using a proxy endpoint, ensure that you use the correct transfer protocol HTTP vs HTTPS

### For Managed Service Identity (MSI) or Service Principal (SPN) authorization, Http Status Code = 403 in the response. Authorization error

- Verify your storage account access roles. Make sure you have both `Contributor` and `Storage Blob Contributor` roles for the MSI or SPN identity.
- In the case of a private AAD endpoint (private MSI endpoitns) ensure that your env variables are configured correctly.

### fusermount: mount failed: Operation not permitted (CentOS)

fusermount is a privileged operation on CentOS by default. You can work around this issue by changing the permissions of the fusermount operation.

```bash
chown root /usr/bin/fusermount
chmod u+s /usr/bin/fusermount
```

### Cannot access mounted directory

FUSE allows mounting filesystem in user space, and is only accessible by the user mounting it. For instance, if you have mounted using root, but you are trying to access it with another user, you will fail to do so. In order to workaround this, you can use the non-secure, fuse option `--allow-other`.

```bash
sudo blobfuse2 mount /home/myuser/mount_dir/ --config-file=config.yaml --allow-other
```

### fusermount: command not found

This error can happen when you try to unmount the Blob Storage, but the recommended command is not found. While `umount` might work instead, fusermount is the recommended method, so install the fuse package. The following example installs the fuse package on Ubuntu 20+:

```bash
sudo apt install fuse3
```

> [!NOTE]
> Fuse version (2 or 3) is dependent on the linux distribution you're using. Refer to fuse version for your distribution.

### Hangs while mounting to private link storage account

The BlobFuse2 configuration file should specify the account name as the original storage account name and not the privatelink storage account name. For example: `myblobstorageaccount.blob.core.windows.net` is correct while `privatelink.myblobstorageaccount.blob.core.windows.net` is wrong.

If the configuration file is correct, please verify name resolution. For example, `dig +short myblobstorageaccount.blob.core.windows.net` should return a private IP address such as `10.0.0.5`.

If for some reason the translation and name resolution fails please confirm the VNet settings to ensure that it is forwarding DNS translation requests to Azure Provided DNS `168.63.129.16`. In case the BlobFuse2 hosting VM is set up to forward to a Custom DNS Server, the Custom DNS settings should be verified, it should forward DNS requests to the Azure Provided DNS `168.63.129.16`.

To resolve DNS issues when integrating private endpoint with Azure Private DNS, validate Private Endpoint has proper DNS record on Private DNS Zone. In case Private Endpoint was deleted and recreated a new IP might exist or duplicated records which will cause clients to use round-robin and make connectivity instable. You can also validate if DNS settings of the Azure VM has Correct DNS Servers. DNS settings can be defined VNET level and NIC Level. DNS settings cannot be set inside Guest OS VM NIC.

For custom DNS servers defined, make sure that custom DNS Server forwards all requests to `168.63.129.16`. If it does, then you should be able to consume Azure Private DNS zones correctly. If it doesn't, you might need to create a conditional forwarder either to: privatelink zone or original PaaS Service Zone.

If a custom DNS has Root Hits only, then it's best to have a forwarder configured to `168.63.129.16` which will improve performance and doesn't require any extra conditional forwarding setting.

If a custom DNS has DNS Forwarders to another DNS Server (not Azure Provided DNS), then you need to create a conditional forwarder to original PaaS domain zone (i.e. storage you should configure blob.core.windows.net conditional forwarder to 168.63.129.16). Keep in mind using that approach will make all DNS requests to storage account with or without private endpoint to be resolved by Azure Provided DNS. By having multiple Custom DNS Serves in Azure will help to get better high availability for requests coming from On-Prem.

### BlobFuse2 killed by OOM

The "OOM Killer" or "Out of Memory Killer" is a process that the Linux kernel employs when the system is critically low on memory. Based on its algorithm it kills one or more process to free up some memory space. BlobFuse2 could be one such process. To investigate BlobFuse2 was killed by OOM or not run following command:

```bash
dmesg -T | egrep -i 'killed process'
```

If BlobFuse2 pid is listed in the output then OOM has sent a SIGKILL to BlobFuse2. If BlobFuse2 was not running as a service it will not restart automatically and user has to manually mount again. If this keeps happening then user need to monitor the system and investigate why system is getting low on memory. VM might need an upgrade here if the such high usage is expected.

### Unable to access HNS enabled storage account behind a private end point

For HNS account, always add `type: adls` under `azstorage` section in your configuration file. Avoid using `endpoint` unless your storage account is behind a private endpoint. BlobFuse2 uses both blob and dfs endpoints to connect to storage account. User has to expose both these endpoints over private-endpoint for BlobFuse2 to function properly.

To create a private-endpoint for DFS in Azure portal: Go to your storage account -> Networking -> Private Endpoint connections. Click `+ Private endpoint`, fill in Subscription, Resource Group, Name, Network Interface Name and Region. Click next and under Target sub-resource select `dfs`. Click Virtual network and select virtual network and Subnet. Click DNS. Select Yes for Integrate with private DNS. Select the Subscription and Resource Group for your private link DNS. Select Next, Next and select Create.

### Failed to initialize new pipeline [configuration error in azstorage [account name not provided]]

Make sure the configuration file has `azstorage` section in your configuration file.

The [BlobFuse2 base configuration file](https://github.com/Azure/azure-storage-fuse/blob/main/setup/baseConfig.yaml) contains a list of all settings and a brief explanation of each setting. Use the [sample file cache configuration file](https://github.com/Azure/azure-storage-fuse/blob/main/sampleFileCacheConfig.yaml) or the [sample block cache configuration file](https://github.com/Azure/azure-storage-fuse/blob/main/sampleBlockCacheConfig.yaml) to get started quickly by using some basic settings for each of those scenarios.

### Failed to mount in proxy setup [proxyconnect tcp: dial tcp: lookup : no such host]

Make sure to set the proxy URL in the environment variable `https_proxy` or `http_proxy` and that it is accessible to BlobFuse2 process. If using private endpoint make sure that it is pointing to the `endpoint` in `azstorage` section in config. Alternatively, have a DNS resolution where `account.blob.core.windows.net` can be resolved back to the private endpoint. In case of HNS account, make sure to have the private endpoint configured for both blob and dfs accounts.

### BlobFuse establishes HTTPS communication with blobfuse2.z13.web.core.windows.net

On mount, BlobFuse tries to check if there is an upgrade available. This is done by making a connection to `blobfuse2.z13.web.core.windows.net` and fetching the latest version details. Due to a network policy or a firewall if this call fails, mount will continue. In case a new version is available, a message on shell will be printed calling for an upgrade. In case of failure only a log message will be dumped and it's totally harmless for any file-system operation or mount. If you do not want BlobFuse to make such check, add `--disable-version-check=true` CLI parameter in your mount command.

## Common Problems after a Successful mount

This section lists common issues that can occur when attempting to mount a container.

### Errno 24: Failed to open file /mnt/tmp/root/filex in file cache.  errno = 24 OR Too many files Open error

`Errno 24` in Linux corresponds to "Too many files open" error which can occur when an application opens more files than it is allowed on the system. BlobFuse2 typically allows 20 files less than the ulimit value set in Linux. Usually the Linux limit is 1024 per process (e.g. BlobFuse2 in this case will allow 1004 open file descriptors at a time). Recommended approach is to edit the `/etc/security/limits.conf` in Ubuntu and add these two lines:

```
soft nofile 16384
hard nofile 16384
```

The value `16384` refers to the number of allowed open files. You must reboot after editing this file for BlobFuse2 to pick up the new limits. You might increase the limit via the command `ulimit -n 16834` however this does not appear in work in Ubuntu.

### Input/output error

If you mounted a blob container successfully, but failed to create a directory, or upload a file, it might be that you mounted a blob container from a Premium (Page) blob account which does not support Block blob. BlobFuse2 uses Block Blobs as files hence requires accounts that support Block blobs.

`mkdir: cannot create directory ‘directoryname' : Input/output error`

### Unexplainably high storage account list usage. Costs $$

The mostly likely reason is scanning triggered automatically using `updatedb` by the built-in `mlocation` service that is deployed with Linux VMs. `mlocation` is a built-in service that acts as a search tool. It is added under `/etc/cron.daily` to run on daily basis and it triggers the `updatedb` service to scan every directory on the server to rebuild the index of files in database in order to get the search result up-to-date.

To resolve this issue, type the following command in the shell prompt: `ls -l /etc/cron.daily/mlocate`. If `mlocate` is added to the `/etc/cron.daily` then BlobFuse2 must be added to the allowed list, so that the BlobFuse2 mount directory is not scanned by `updatedb`. This is done by updating the `updatedb.conf` file. 

1. To update that file, type `cat /etc/updatedb.conf`.

   The contents appears similar to the following:

   ```
   PRUNE_BIND_MOUNTS="yes"

   PRUNENAMES=".git .bzr .hg .svn"

   PRUNEPATHS="/tmp /var/spool /media /var/lib/os-prober /var/lib/ceph /home/.ecryptfs /var/lib/schroot"

   PRUNEFS="NFS nfs nfs4 rpc_pipefs afs binfmt_misc proc smbfs autofs iso9660 ncpfs coda devpts ftpfs devfs devtmpfs fuse.mfs shfs sysfs cifs lustre tmpfs usbfs udf fuse.glusterfs fuse.sshfs curlftpfs ceph fuse.ceph fuse.rozofs ecryptfs fusesmb"
   ```

1. Add the BlobFuse2 mount path eg: /mnt to the `PRUNEPATHS`.

1) Add "Blobfuse2" and "fuse" to the `PRUNEFS`. Adding to both values won't cause any harm.

To automate this configuration at pod creation, create a new `configmap` in the cluster which contains the new configuration about the script. Then, create a `DaemonSet` with the new `configmap` which could apply the configuration changes to every node in the cluster.

```
Example:
configmap fiie: (testcm.yaml)
apiVersion: v1
kind: ConfigMap
metadata:
name: testcm
data:
updatedb.conf: |
PRUNE_BIND_MOUNTS="yes"
PRUNEPATHS="/tmp /var/spool /media /var/lib/os-prober /var/lib/ceph /home/.ecryptfs /var/lib/schroot /mnt /var/lib/kubelet"
PRUNEFS="NFS nfs nfs4 rpc_pipefs afs binfmt_misc proc smbfs autofs iso9660 ncpfs coda devpts ftpfs devfs devtmpfs fuse.mfs shfs sysfs cifs lustre tmpfs usbfs udf fuse.glusterfs fuse.sshfs curlftpfs ceph fuse.ceph fuse.rozofs ecryptfs fusesmb fuse Blobfuse2"
DaemonSet file: (testcmds.yaml)
apiVersion: apps/v1
kind: DaemonSet
metadata:
name: testcmds
labels:
test: testcmds
spec:
selector:
matchLabels:
name: testcmds
template:
metadata:
labels:
name: testcmds
spec:
tolerations:
- key: "kubernetes.azure.com/scalesetpriority"
operator: "Equal"
value: "spot"
effect: "NoSchedule"
containers:
- name: mypod
image: debian
volumeMounts:
- name: updatedbconf
mountPath: "/tmp"
- name: source
mountPath: "/etc"
command: ["/bin/bash","-c","cp /tmp/updatedb.conf /etc/updatedb.conf;while true; do sleep 30; done;"]
restartPolicy: Always
volumes:
- name: updatedbconf
configMap:
name: testcm
items:
- key: "updatedb.conf"
path: "updatedb.conf"
- name: source
hostPath:
path: /etc
type: Directory
```

### File contents are not in sync with storage

Please refer to the file cache component setting `timeout-sec`.

### failed to unmount /path/<mount dir>

Unmount fails when a file is open or a user or process changes directories into the mount directory or its sub directories. Please ensure no files are in use and try the unmount command again. Even `umount -f` will not work if the mounted files /directories are in use. `umount -l` does a lazy unmount meaning it will unmount automatically when the mounted files are no longer in use.

### BlobFuse2 mounts but not functioning at all

There are cases where anti-malware & anti-virus software block the fuse functionality and in such case though mount command is successful and BlobFuse2 binary is running, the fuse functionality will not work. One way to identify that you are hitting this issue is turn on the debug logs and mount BlobFuse2. If you do not see any logs coming from BlobFuse2 and potentially you have run into this issue. Stop the anti-virus software and try again. In such cases we have seen mounting through /etc/fstab works, because that executes mount command before the anti-malware software kicks in.

### file cache temp directory not empty

To ensure that you don't have leftover files in your file cache temp dir, unmount rather than stopping BlobFuse2. If BlobFuse2 is stopped without unmounting you can also set `cleanup-on-start` in your configuration file on the next mount to clear the temp directory.

### Unable to modify existing file (error: invalid argument)

By default `writeback-cache` is enabled for libfuse3 and this might result in append/write operations to fail. Either you can disable writeback-cache, which might hurt the performance or you can configure BlobFuse2 to ignore open flags given by user and make it work with writeback-cache.

To disable writeback-cache : Add `disable-writeback-cache: true` under libfuse section in your configuration file.

To make it work with writeback-cache : Add `ignore-open-flags: true` under libfuse section in your configuration file.

### Unable to list files/directories for non-HNS (flat-namespace) accounts

For non-HNS accounts blobfuse expects special directory marker files to exist in container to identify a directory. If these files do not exist then `virtual-directory: true` in `azstorage` section is required.

### File size and LMT are updated but file contents are not refreshed

BlobFuse2 supports both fuse2 and fuse3 compatible linux distributions. In all linux distributions  kernel cached contents of file in its page-cache. As long as cache is valid read/write are served from cache and calls will not reach to file-system drivers (blobfuse in our case). This page-cache is invalidated when page is swapped-out, manually cleared by user through cli or file-system driver requests for it.

In case of fuse2 compliant distributions , libfuse does not support invalidating the page cache. Contents once cached will remain with kernel until user manually clears the page-cache or kernel decides to swap it out. This means even if the file size or LMT has changed and blobfuse decided to refresh the content by redownloading the file, on read user will still get the stale contents.

In case of fuse3 compliant distributions , blobfuse configures libfuse to invalidate the page cache on file size or LMT change so this issue will not be hit.

If user is observing that list or stat call to file shows updated time or size but contents are not reflecting accordingly, first confirm with blobfuse logs that file was indeed downloaded afresh. If file-cache-timeout has not expired then blobfuse will keep using the current version of file persisted on temp cache and contents will not be refreshed. If blobfuse has downloaded the latest file and user still observes stale contents then clear the kernel page-cache manually using ```sysctl -w vm.drop_caches=3``` command.

If your workflow involves updating the file directly on container (not using blobfuse) and you wish to get latest contents on blobfuse mount then do the following (for fuse3 compliant linux distribution only):

- Set all timeouts in libfuse section to 0 (entry, attribute, negative).

- Remove attr_cache from your pipeline section in config.

- Set file-cache-timeout to 0.

- In libfuse section of you configuration file add "disable-writeback-cache: true".

## BlobFuse2 Health Monitor

One of the BlobFuse2 features is health monitor. It allows customers gain more insight into how their BlobFuse2 instance is behaving with the rest of their machine. Visit [here](https://github.com/Azure/azure-storage-fuse/blob/main/tools/health-monitor/README.md) to set it up. This feature is currently in preview.

## Problems with build

Make sure you have correctly setup your GO dev environment. Ensure you have installed fuse3/2 for example:

```bash
sudo apt-get install fuse3 libfuse3-dev -y

```

## Issues with private endpoints for hierarchical namespace enabled storage accounts

When accessing hierarchical namespace enabled Azure storage account behind private endpoints, it is crucial to create **two separate private endpoints** to ensure proper connectivity:

1. **Private Endpoint for DFS**  
   - Target: `privatelink.dfs.core.windows.net`  
   - This endpoint is necessary for accessing the Data Lake Storage Gen2 (HNS) functionality.

2. **Private Endpoint for Blob**  
   - Target: `privatelink.blob.core.windows.net`  
   - This endpoint is necessary for accessing Blob Storage operations.

### Why both endpoints are required

hierarchical namespace enabled storage accounts utilize separate endpoints for blob and DFS operations:

- The Data Lake Storage endpoint (`dfs.core.windows.net`) is used for namespace-related operations like directory and file management.

- The Blob Storage endpoint (`blob.core.windows.net`) is used for operations like streaming data to and from blobs.

## See also

- [Use Health Monitor to gain insights into BlobFuse2 mount activities and resource usage](blobfuse2-health-monitor.md)
- [Migrate to BlobFuse2 from BlobFuse v1](https://github.com/Azure/azure-storage-fuse/blob/main/MIGRATION.md)

## Next steps

- [Configure settings for BlobFuse2](blobfuse2-configuration.md)
- [BlobFuse2 commands](blobfuse2-commands.md)
