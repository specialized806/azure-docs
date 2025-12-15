---
title: Enable logging for BlobFuse2
titleSuffix: Azure Storage
description: Learn how to enable logging for BlobFuse2 activity.
author: normesta
ms.author: normesta

ms.service: azure-blob-storage
ms.topic: how-to
ms.date: 12/10/2025

ms.custom: linux-related-content

# Customer intent: "As a Linux user, I want to mount Azure Blob Storage as a file system using BlobFuse2, so that I can perform standard file operations and improve access to my data in a familiar environment."
---

# Enable logging for BlobFuse2

Introduction goes here.

[Here](https://github.com/Azure/azure-storage-fuse/blob/main/setup/baseConfig.yaml#L16) are the configuration options applicable to logging.

## Type: Output Locations

blobfuse2 supports 2 different types of log outputs, **syslog** which writes data to syslog and **base** which writes data to the output location of your choosing. 

If using syslog, simply grep for blobfuse:

```
grep blobfuse /var/log/syslog
```

The default logging type is syslog.

## Level

blobfuse2 supports five levels of severity:

log_off|log_crit|log_err|log_warning|log_info|log_trace|log_debug

1. **LOG_OFF** - Shuts off logging completely.

2. **LOG_CRIT** - Issues that cause blobfuse2 to fail to start.

3. **LOG_ERR** - Issues that will end up returning errors to the caller. For example, if you write some data and then try to close the file handle, but blobfuse2 fails (for whatever reason) to properly connect to Azure Storage to commit the data, this event will be logged at level LOG_ERR (as well as returning a failure to the process attempting to close the file handle, of course.)

4. **LOG_WARNING** - Issues that blobfuse2 encounters that may not be actual errors, but still may be valuable to log. For example, if a network operation fails but is retriable, a warning may be logged before automatic retries kick in.

5. **LOG_INFO** - All operations relating to the uploading or downloading of blob data to Azure Storage are logged at LOG_INFO level. Some other operations are also logged at the level, that may be informative if problems are encountered.

6. **LOG_TRACE** - Essentially trace statements for all calls into blobfuse2. This is very verbose, and contains helpful debugging information such as line number, method name, method inputs and return values, etc. Probably only helpful if you are looking at the source code as well.

7. **LOG_DEBUG** - Contains additional helpful debugging information. 

The default log level is LOG_WARNING. You can set the log level when you mount blobfuse2 by 

a. adding the CLI parameter:
--log-level=LOG_OFF|LOG_CRIT|LOG_ERR|LOG_WARNING|LOG_INFO|LOG_TRACE|LOG_DEBUG

b. specifying the config file parameter
logging.level: LOG_OFF|LOG_CRIT|LOG_ERR|LOG_WARNING|LOG_INFO|LOG_TRACE|LOG_DEBUG

LOG_OFF will shut off logging completely (specifically, it sets the log threshold for the process to LOG_EMERG, which we do not use.) Other options include all worse levels of severity (meaning, if you specify LOG_INFO, blobfuse will log all INFO, WARNING, ERR, and CRIT level messages.)

## Libfuse Logging

libfuse library provides a '-d' option in mount command to enable its verbose logging on the console. This will enable debug logs in the library and print all system calls being made along with their return values on the console itself.

Alternatively, enable libfuse logging by specifying the config file parameter 
libfuse.fuse-trace: true

## SDK Logging

If the logs indicate that the issue is coming from the storage SDK, enable SDK logging to get detailed logs of the REST calls to be able to diagnose whether an issue is in blobfuse, SDK or service side. 
SDK logging can be enabled by specifying the config file parameter
azstorage.sdk-trace: true

## Syslog Redirection

By default blobfuse2 dumps its logs in `/var/log/syslog` file. To redirect logs to a separate file follow below instructions. Files required for these commands are part of the package or can be found in the source code under 'systemd' directory.

```
- copy setup/11-blobfuse2.conf to /etc/rsyslog.d/

- copy setup/blobfuse2-logrotate to /etc/logrotate.d/

- restart rsyslog service

    - $> service rsyslog restart
```

## Dynamic Logging

Default logging level of blobfuse is LOG_WARNING. User can set a different log level using the --log-level CLI parameter or the logging.level config file parameter. Once blobfuse is mounted if a customer is using a config file, this logging level can be changed without unmounting the container. Modify the logging.level parameter in the config file and save the config file to dynamically update the log level.

## Next steps

Put links here.