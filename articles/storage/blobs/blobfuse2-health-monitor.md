---
title: Monitor BlobFuse2 mount activities and resource usage
titleSuffix: Azure Storage
description: Learn how to use Health monitor to gain insights into BlobFuse2 mount activities and resource usage.
author: normesta
ms.author: normesta

ms.service: azure-blob-storage
ms.topic: how-to
ms.date: 12/02/2022

ms.custom: linux-related-content

# Customer intent: "As a system administrator monitoring BlobFuse2 performance, I want to configure and use Health Monitor to track resource usage, mount activities, and troubleshoot performance issues in my storage environment."
---

# Monitor BlobFuse2 mount activities and resource usage

Health monitor is a tool that you use to monitor mount activities and resource usage. This article describes what data you can obtain, and how to enable health monitor and view output reports.

## Health monitor data

The BlobFuse2 Health monitor provides these specialized health monitors: _BlobFuse stats_, _CPU profiler_, _Memory profiler_, and _File cache monitor_.

The following table describes each of these monitors and the data that you can obtain from them.

| Health monitor     | Data available                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
|--------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| BlobFuse stats     | Total bytes uploaded and downloaded via BlobFuse2<br><br>Events such as create, delete, rename, synchronize, and truncate on files or directories in the mounted directory<br><br>Progress of uploads or downloads of large files to and from Azure Storage<br><br>Number of calls made to Azure Storage for operations such as create, delete, rename, and chmod in the mounted directory<br><br>Total number of open handles on files<br><br>Number of times an open file request was served from the file cache or downloaded from Azure Storage |
| CPU profiler       | CPU usage of the Blobfuse2 process associated with the mount                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| Memory profiler    | Memory usage of the Blobfuse2 process associated with the mount                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| File cache monitor | Monitor the different events such as create, delete, rename, and chmod of files and directories in the cache<br><br>Keep track of the cache consumption with respect to the cache size specified during mounting |

## Enable health monitor

You can enable the health monitor by modifying the BlobFuse2 configuration file. The following example shows sample configuration entries in the BlobFuse2 configuration file. In this example, the file cache monitor and the memory profiler are disabled.

```yaml
health_monitor:
  enable-monitoring: true
  stats-poll-interval-sec: 10
  process-monitor-interval-sec: 30
  output-path: outputReportsPath
  monitor-disable-list:
    - file_cache_monitor
    - memory_profiler
```

The following table describes each configuration field.

| Field | Description |
|-----------|------------|
| `enable-monitoring` | Boolean parameter to enable health monitor. By default, health monitor is disabled. |
| `stats-poll-interval-sec`| BlobFuse2 stats polling interval (in seconds). Default is 10 seconds. |
| `process-monitor-interval-sec`| CPU and memory usage polling interval expressed in seconds. Default is 30 seconds. |
| `output-path`| The path where health monitor generates its output file. It uses the current directory as the default if not specified. Output file name is `monitor_<pid>.json`. |
| `monitor-disable-list` | List of monitors to disable. To disable a monitor, add its corresponding name to the list. |
| `blobfuse_stats` | Disable BlobFuse2 stats polling |
| `cpu_profiler` | Disable CPU monitoring on the BlobFuse2 process |
| `memory_profiler` | Disable memory monitoring on the BlobFuse2 process |
| `file_cache_monitor` | Disable file cache directory monitor |

> [!NOTE]
> Health monitor runs as a separate process where one health monitor process is associated with monitoring one BlobFuse2 mounted directory.

## Output reports

Health monitor stores its output reports in the path specified in the `output-path` configuration option. If you don't specify this option, it uses the current directory as the default. It stores the last 100 MB of monitor data in 10 different files named `monitor_<pid>_<index>.json`, where `monitor_<pid>.json` (zeroth index) is the latest and `monitor_<pid>_9.json` is the oldest output file.

The following JSON shows an example of the output file contents.

```
{
    "Timestamp": "t1",
    "CPUUsage": "value in %",
    "MemoryUsage": "value in bytes",
    "BlobfuseStats": [
        {
            "componentName": "azstorage",
            "value": {
                "Bytes Downloaded": value in bytes,
                "Bytes Uploaded": value in bytes,
                "Chmod": count of chmod calls,
                "StreamDir": count of stream dir calls
            }
        },
        {
            "componentName": "file_cache",
            "value": {
                "Cache Usage": "value in MB",
                "Usage Percent": "value in %",
                "Files Downloaded": count,
                "Files served from cache": count
            }
        }
    ],
    "FileCache": [
        {
            "cacheEvent": "CREATE",
            "path": "filePath",
            "isDir": false,
            "cacheSize": value in bytes,
            "cacheConsumed": "value in %",
            "cacheFilesCount": count of files in cache,
            "evictedFilesCount": count of files evicted from cache,
            "value": {
                "FileSize": "value in bytes"
            }
        }
    ]
}
```

## Next steps

- [Configure BlobFuse2](blobfuse2-configuration.md)
- [BlobFuse2 frequently asked questions](blobfuse2-faq.yml)
- [Known issues with BlobFuse2](blobfuse2-known-issues.md)
- [Enable logs for BlobFuse2](blobfuse2-enable-logs.md)
