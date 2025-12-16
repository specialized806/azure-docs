---
title: Monitor BlobFuse2 mount activities and resource usage
titleSuffix: Azure Storage
description: Learn how to Use Health Monitor to gain insights into BlobFuse2 mount activities and resource usage.
author: normesta
ms.author: normesta

ms.service: azure-blob-storage
ms.topic: how-to
ms.date: 12/02/2022

ms.custom: linux-related-content

# Customer intent: "As a cloud administrator, I want to deploy and utilize Health Monitor for BlobFuse2, so that I can gain insights into mount activities and resource usage effectively."
---

# Monitor BlobFuse2 mount activities and resource usage

_Health monitor_ is a tool that you can use to monitor mount activities and resource usage. This article describes what data you can obtain, as well as how to enable health monitor and view output reports.

## Health monitor data

The BlobFuse2 Health monitor provides these specialized health monitors (_BlobFuse stats_, _CPU profiler_, _Memory profiler_, and _File cache monitor_).

The following table describes each of these monitors and the data that you can obtain from them.

| Health monitor     | Data available                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
|--------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| BlobFuse stats     | Total bytes uploaded and downloaded via BlobFuse2<br>br>Events like create, delete, rename, synchronize, truncate, etc. on files or directories in the mounted directory<br>br>Progress of uploads or downloads of large files to/from Azure Storage<br>br>Number of calls that were made to Azure Storage for operations like create, delete, rename, chmod, etc. in the mounted directory<br>br>Total number of open handles on files<br><br>Total number of open handles on files<br><br>Number of times an open file request was served from the file cache or downloaded from the Azure Storage |
| CPU profiler       | CPU usage of the Blobfuse2 process associated with the mount                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| Memory profiler    | Memory usage of the Blobfuse2 process associated with the mount                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| File cache monitor | monitor the different events like create, delete, rename, chmod, etc. of files and directories in the cache<br><br>Keep track of the cache consumption with respect to the cache size specified during mounting                                                                                                                                                                                                                                                                                                                                                                                      |

## Enable Health Monitor

Enable health monitor by modifying the BlobFuse2 configuration file. The following table describes each configuration field. The following example shows sample configuration entries in the BlobFuse2 configuration file. In this example the file cache monitor and the memory profiler are disabled.

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
| `enable-monitoring` | (Boolean) parameter to enable health monitor. By default it is disabled |
| `stats-poll-interval-sec`| BlobFuse2 stats polling interval (in sec). Default is 10 seconds |
| `process-monitor-interval-sec`| CPU and memory usage polling interval express in seconds. Default is 30 seconds |
| `output-path:`| The path where health monitor will generate its output file. It takes the current directory as default, if not specified. Output file name will be `monitor_<pid>.json` |
| `monitor-disable-list` | List of monitors to be disabled. To disable a monitor, add its corresponding name in the list. |
| `blobfuse_stats` |  Disable BlobFuse2 stats polling |
| `cpu_profiler` | Disable CPU monitoring on BlobFuse2 process |
| `memory_profiler` | Disable memory monitoring on BlobFuse2 process |
| `file_cache_monitor` | Disable file cache directory monitor |

> [!NOTE]
> Health Monitor runs as a separate process where one health monitor process is associated with monitoring one BlobFuse2 mounted directory.

## Output Reports

Health monitor will store its output reports in the path specified in the `output-path` config option. If this option is not specified, it takes the current directory as default. It stores the last 100MB of monitor data in 10 different files named as `monitor_<pid>_<index>.json` where `monitor_<pid>.json`(Zeroth index) is latest and `monitor_<pid>_9.json` is the oldest output file.

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

Put something here.
