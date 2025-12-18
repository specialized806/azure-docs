---
title: Configure logging for BlobFuse2
titleSuffix: Azure Storage
description: Learn how to configure logging for BlobFuse2 activity.
author: normesta
ms.author: normesta

ms.service: azure-blob-storage
ms.topic: how-to
ms.date: 12/10/2025

ms.custom: linux-related-content

# Customer intent: "As a Linux user, I want to mount Azure Blob Storage as a file system using BlobFuse2, so that I can perform standard file operations and improve access to my data in a familiar environment."
---

# Configure logging for BlobFuse2

This article shows you how to configure the logging behavior for BlobFuse2. By default, BlobFuse2 logs warnings to the system log. However, you can route logs to a local directory, change which types of information you want to appear in logs, or disable logs entirely by changing the default configuration.

## Log configuration settings

You can modify logging behavior by changing the values of field (_key_) in the [configuration file](https://github.com/Azure/azure-storage-fuse/blob/main/setup/baseConfig.yaml#L2) or by using [parameters](https://github.com/Azure/azure-storage-fuse/wiki/Blobfuse2%E2%80%90Cli%E2%80%90Parameters) along with BlobFuse2 commands in the command line interface (CLI).

The following table describes each log setting, the allowable values, and the field or command you use to modify the value.

| Setting | Config file field | CLI parameter | Default value | Possible values |
|----|---|----|---|----|
| Output location | `type` | Not available | `syslog` | `silent` \| `base` |
| Log Level  | `level` | `--log-level` | `log_warning` | `log_off`\|`log_crit`\|`log_err`\|`log_warning`\|`log_info`\|`log_trace`\|`log_debug` |
| File path | `file-path` | `--log-file-path` | `$HOME/.blobfuse2/blobfuse2.log` | Any |

## Configure settings

The following example modifies the configuration file so that logs route errors to the path `$HOME/.mycustomdirectory/blobfuse2.log`.

```yaml
logging:
  type: base
  level: log_err
  file-path: $HOME/.mycustomdirectory/blobfuse2.log
```

The following example modifies log settings in the command line by using parameters with the `mount` command.

```bash
sudo blobfuse2 mount ~/mycontainer --log-level=log_err --file-path=$HOME/.mycustomdirectory/blobfuse2.log
```

> [!NOTE]
> You can modify logging behavior after you mount a container by changing settings in the configuration file and saving the file. If you use only Azure CLI to set behavior, you must first unmount the container and then mount the container again by using the `mount` command along with the correct parameters.  

### Choose a log level

The following table describes each log severity level. Choose the level most appropriate for your workload requirements.

| Log level | Description |
|---|---|
| `log_off` | Shuts off logging. |
| `log_crit` | Log issues that prevent BlobFuse2 from starting |
| `log_err` |  Issues that will end up returning errors to the caller. For example, if you write some data and then try to close the file handle, but BlobFuse2 fails (for whatever reason) to properly connect to Azure Storage to commit the data, this event will be logged at level LOG_ERR (as well as returning a failure to the process attempting to close the file handle, of course.)
| `log-warning` | Issues that BlobFuse2 encounters that may not be actual errors, but still may be valuable to log. For example, if a network operation fails but is retriable, a warning may be logged before automatic retries kick in. |
| `log_info` | All operations relating to the uploading or downloading of blob data to Azure Storage are logged at LOG_INFO level. Some other operations are also logged at the level, that may be informative if problems are encountered. |
| `log-trace` | Essentially trace statements for all calls into BlobFuse2. This is very verbose, and contains helpful debugging information such as line number, method name, method inputs and return values, etc. Probably only helpful if you are looking at the source code as well. |
| `log-debug` | Contains additional helpful debugging information. |

### Find logs in Syslog

By default, logs are written to the `/var/log/syslog` file. If you choose to use syslog as the output location, you can find logs by using the `grep` command and pass the string `blobfuse` as a parameter. The following example shows how to find BlobFuse logs in the syslog.

```bash
grep blobfuse /var/log/syslog
```

### Route logs to local directory

The simplest way to route logs to a location other than the `/var/log/syslog` file, is to configure output location to 'base' in your configuration file.

However, if you want to keep output location set to `syslog`, you can instead redirect logs from the `/var/log/syslog` file to a separate file location. The following example shows an example. 

> [!NOTE]
> The files required for these commands are part of the BlobFuse2 package. You can also find them in the source code under the `systemd` directory.

```bash
copy setup/11-blobfuse2.conf to /etc/rsyslog.d/
copy setup/blobfuse2-logrotate to /etc/logrotate.d/
service rsyslog restart
```

## Enable libfuse Logging

LibFuse library provides a `-d` option in mount command to enable its verbose logging on the console. This will enable debug logs in the library and print all system calls being made along with their return values on the console itself. Alternatively, enable libfuse logging by specifying the config file parameter `libfuse.fuse-trace: true`.

## Enable SDK Logging

If the logs indicate that the issue is coming from the storage SDK, enable SDK logging to get detailed logs of the REST calls to be able to diagnose whether an issue is in blobfuse, SDK or service side. SDK logging can be enabled by specifying the config file parameter `azstorage.sdk-trace: true`.

## Next steps

Put links here.