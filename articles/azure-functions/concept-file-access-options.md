---
title: Choose a file access strategy for Azure Functions
description: Compare storage bindings, external databases, and Azure Files storage mounts to choose the right file access approach for your function app.
ms.service: azure-functions
ms.topic: concept-article
ms.date: 03/11/2026
ms.custom:
  - devx-track-azurecli
#customer intent: As a developer, I want to compare file access options (storage bindings, external databases, and Azure Files mounts) so I can choose the right approach for my function app.
---

# Choose a file access strategy for Azure Functions

This article compares three ways to access files from Azure Functions: storage bindings, external databases, and Azure Files storage mounts. You learn the trade-offs between each approach, see when mounts are the right choice, and find patterns for real-world scenarios.

Storage bindings and external databases work on all hosting plans. Storage mounts are supported only on [Flex Consumption](./flex-consumption-plan.md) and [Dedicated (App Service)](./dedicated-plan.md) plans.

[!INCLUDE [functions-azure-files-samples-note](../../includes/functions-azure-files-samples-note.md)]

## File access options at a glance

When you need to access files from your functions, you have three main options:

| Approach | Pros | Cons | Best for | Learn more |
| --- | --- | --- | --- | --- |
| **Storage bindings** | Simple, cloud-native, secure | Network overhead, eventual consistency | Moving data to/from cloud services (queues, blobs) | [Blob](./functions-bindings-storage-blob.md), [Queue](./functions-bindings-storage-queue.md), [Table](./functions-bindings-storage-table.md) bindings |
| **External database** | Flexible, transactional | Network calls, complexity | Structured data, complex queries | [Manage connections](manage-connections.md#manage-connections-in-azure-functions) |
| **Storage mount (Azure Files)** | Direct file access, POSIX semantics, large binaries | Slower than local disk, Linux only | Large files, shared executables, frequent access | [What is a storage mount?](#what-is-a-storage-mount) |

Not every option is available on every hosting plan:

| Hosting plan | Storage bindings | External database | Storage mount (Azure Files) |
| --- | :---: | :---: | :---: |
| **Flex Consumption** | Yes | Yes | Yes |
| **Dedicated (App Service)** | Yes | Yes | Yes |
| **Premium** | Yes | Yes | No |
| **Consumption** (Windows only) | Yes | Yes | No |

The rest of this article focuses on mounts: when they're the right choice, and how to use them safely.

## What is a storage mount?

A storage mount is a network file share mounted as if it were a local directory. When you mount an Azure Files share on your function app, the path appears in the function container's file system:

```
┌─────────────────────────────────────┐
│  Your function code                 │
│  (reads/writes to /mnt/mydata/)     │
├─────────────────────────────────────┤
│  POSIX file-system layer            │
│  (appears as a local directory)     │
├─────────────────────────────────────┤
│  SMB protocol (over network)        │
├─────────────────────────────────────┤
│  Azure Files share                  │
│  (in your storage account)          │
└─────────────────────────────────────┘
```

Your code uses standard file system APIs (for example, `open()`, `os.listdir()` in Python, or equivalent calls in other languages) without knowing it's communicating over the network. This provides POSIX semantics, which means your code looks like local file I/O.

## When not to use mounts

Mounts aren't the right choice for every scenario:

| Scenario | Recommended alternative |
| --- | --- |
| Small transient data | [Azure Queue Storage](./functions-bindings-storage-queue.md)<br/>[Azure Blob Storage](./functions-bindings-storage-blob.md) |
| Frequent small reads/writes | [Azure Cosmos DB](./functions-bindings-cosmosdb-v2.md) or [Azure Cache for Redis](./functions-bindings-cache-trigger-redislist.md) |
| Real-time streaming | [Azure Event Hubs](./functions-bindings-event-hubs.md) or [Azure IoT Hub](./functions-bindings-event-iot.md) |
| Cross-region data sharing | [Blob Storage replication](./performance-reliability.md) |

> [!IMPORTANT]  
> Only Flex Consumption and Dedicated (App Service) plans support storage mounts.

## Mount limits

| Limit | Value |
| --- | --- |
| Share size | Up to 100 TiB |
| File size | Up to 4 TiB |
| Throughput | ~60 MB/s (standard), ~100+ MB/s (premium) |
| Concurrency | Many (SMB handles it), but writes serialize |

For more information, see [Azure Files scale targets](../storage/files/storage-files-scale-targets.md).

## Compare storage options

Consider our three main file access options when processing 1,000 images (1 MB each) stored in a reference folder:

| Approach | Mechanism | Network calls | Relative cost | Best for |
| ---- | ---- | ---- | ---- | ---- |
| Blob storage binding | Download each file | 1,000 GET requests | High bandwidth + latency | One-time or infrequent access |
| Storage mount | Read from share | One mount setup | Minimal bandwidth | Repeated or high-volume access |
| External database | Azure Cosmos DB | One query | RU charges + network latency | Structured data with complex queries |

> [!NOTE]
> The following code examples use Python, but the same pattern applies to any language that supports file system APIs, including C#, Java, JavaScript, and PowerShell.

### [Blob storage binding](#tab/blob-binding)

```python
files = container_client.list_blobs(name_starts_with="reference/")
for blob in files:
    stream = container_client.download_blob(blob.name)
```

### [Storage mount](#tab/storage-mount)

```python
for file_path in Path("/mnt/reference").iterdir():
    with open(file_path, "rb") as f:
```

### [Azure Cosmos DB](#tab/cosmos-db)

```python
reference_data = container.query_items(
    query="SELECT * FROM reference WHERE id IN (...)"
)
```

---

For large shared files with repeated access, it's best to use share mounts. Let's investigate more detailed scenarios that  

## Share mount scenarios

These example scenarios also benefit from using mounted storage shares:

| Scenario | Problem solved | Example |
| --- | --- | --- |
| **Parallel file analysis** | Avoid packaging large reference data or downloading it per invocation | ML models, lookup tables, corpus data shared across 1,000+ instances |
| **Shared executables** | Keep large binaries out of the deployment package | ffmpeg, ImageMagick, or other 500+ MB tools |
| **Cross-app data sharing** | Share files between producer and consumer apps without message passing | App A writes results, App B reads them from the same mount |

### [Parallel file analysis](#tab/parallel-anaylsis)

> **Use case:** You have 1,000 analysis tasks that all need to read from the same set of reference data files (for example, ML models, lookup tables, or corpus data).

**The problem:** Without mounts, you have two suboptimal options:

- **Package the reference files with your function**: This leads to a huge deployment artifact, slow cold starts, and storage redundancy.
- **Download from Blob Storage each time**: This introduces network latency on every function invocation and wastes bandwidth.

**The mount-based solution:** All instances read from the mounted share directly. After mount initialization, there's no per-request network overhead and no redundant storage.

```
┌─────────────────────────┐
│  Function Instance 1    │
│  Function Instance 2    ├──→  /mnt/models/  ──→  Azure Files share
│  Function Instance 3    │     (shared mount)
└─────────────────────────┘
```

**Implementation pattern**: (Python)

```python
import os
from pathlib import Path

MOUNT_PATH = "/mnt/models"

def analyze_data(item: str) -> dict:
    """Activity function: reads from shared mount."""
    model_path = Path(MOUNT_PATH) / "model.pkl"
    
    # Direct file I/O — no SDK call, no network overhead
    with open(model_path, "rb") as f:
        model = pickle.load(f)
    
    result = model.predict(item)
    return {"item": item, "score": result}
```

**Key points:**

- All instances of your function app see the same mount.
- File reads are POSIX-compliant. You use standard file system APIs.
- No need to authenticate per read (the mount is authenticated once at startup).
- Changes written by one instance are visible to others immediately.

**Security considerations:**

- **Storage account key**: Azure Files storage mounts on Flex Consumption authenticate by using a storage account access key configured in the function app's mount settings. Managed identity with `Storage File Data SMB Share Contributor` RBAC isn't supported for SMB mounts on Azure Functions. Keep the access key secure and rotate it periodically.
- **Read-only option**: If your workload doesn't need to write, restrict the mount to read-only.
- **Quotas**: Set Azure Files share quotas to prevent runaway costs if instances write large files.

### [Shared executables](#tab/shared-executables)

> **Use case:** You need to run a large third-party binary (500+ MB) on every instance, but you don't want to package it with your function code. Such binaries could include ffmpeg, ImageMagick, and others.

**The problem:**

- Without mounts:

    - **Package binary in deployment artifact**: 500+ MB per instance, slow deployment, wasted bandwidth.
    - **Download from Blob on each invocation**: Network call on every execution, slower than local access.

- Using mounted shares

    Upload the binary once to Azure Files. All instances access it from the mount.

    ```
    ┌─────────────────────────────────────────────────┐
    │  Deployment package: 10 MB (just your code)     │
    ├─────────────────────────────────────────────────┤
    │  Mount: /mnt/binaries/ffmpeg                    │
    │  (500 MB binary, shared across all instances)   │
    ├─────────────────────────────────────────────────┤
    │  Execution: your code calls the mounted binary  │
    └─────────────────────────────────────────────────┘
    ```

**Implementation pattern:** (Python)

```python
import subprocess
from pathlib import Path

FFMPEG_PATH = "/mnt/binaries/ffmpeg"
TEMP_PATH = "/mnt/binaries/temp"

def process_video(video_file: str) -> str:
    """Activity function: calls ffmpeg from mount."""
    input_file = Path(TEMP_PATH) / video_file
    output_file = Path(TEMP_PATH) / f"{video_file}.mp4"
    
    result = subprocess.run(
        [FFMPEG_PATH, "-i", str(input_file), "-codec", "libx264", str(output_file)],
        capture_output=True,
        timeout=300
    )
    
    if result.returncode != 0:
        raise Exception(f"FFmpeg error: {result.stderr.decode()}")
    
    return str(output_file)
```

**Key points:**

- The binary is mounted, not packaged.
- The deployment artifact stays small.
- Cold starts are faster (less to unzip).
- All instances can call the same binary concurrently.

**Performance implications:**

- **First execution**: SMB mount initialization adds approximately 200-500 ms.
- **Subsequent executions**: Direct file access with minimal overhead.
- **Binary caching**: The OS caches the binary in memory, reducing repeated disk reads.

> [!TIP]
> For frequently called binaries, the performance overhead is negligible after the first few invocations.

### [Cross-app data sharing](#tab/cross-app-sharing)

> **Use case:** You have App A (data producer) and App B (data consumer) running in the same region. App A writes processed data, and App B reads it.

**The problem:** Without mounts, you'd typically use Azure Blob Storage (decoupled, but with network overhead), Azure Queue Storage with message passing (eventual consistency), or Azure Cosmos DB (more complexity than simple file sharing needs).

**The mount-based solution:** Both apps mount the same Azure Files share. App A writes, and App B reads. No message passing, no eventual consistency.

```
┌──────────────────────┐
│  App A (Producer)    ├──write──┐
└──────────────────────┘         │
                           ┌─────┴─────────────────┐
                           │  /mnt/shared/         │
                           │  Azure Files share    │
                           │  (single source of    │
                           │   truth)              │
                           └─────┬─────────────────┘
┌──────────────────────┐         │
│  App B (Consumer)    ├──read───┘
└──────────────────────┘
```

**Implementation pattern:**

App A (Producer):

```python
from pathlib import Path
import json

MOUNT_PATH = "/mnt/shared"

def write_results(data: dict) -> None:
    """Write results to shared mount."""
    output_file = Path(MOUNT_PATH) / "latest_results.json"
    with open(output_file, "w") as f:
        json.dump(data, f)
```

App B (Consumer):

```python
from pathlib import Path
import json

MOUNT_PATH = "/mnt/shared"

def read_results() -> dict:
    """Read results from shared mount."""
    results_file = Path(MOUNT_PATH) / "latest_results.json"
    if not results_file.exists():
        return {}
    with open(results_file, "r") as f:
        return json.load(f)
```

**Key points:**

- Both apps need mount configuration referencing the same storage account and access key.
- Use file locks (for example, `fcntl` on Linux or equivalent locking APIs in your language) to prevent read/write race conditions.
- Azure Files supports concurrent reads; writes should be sequential or locked.

> [!WARNING]
> Azure Files doesn't provide database-level transactions. If you need atomic writes and reads, consider Azure Cosmos DB or Azure SQL Database instead.

---

## Best practices

### Understand the two auth models

Azure Files storage mounts and the Azure SDK use different authentication mechanisms:

- **Storage mounts (SMB)**: Authenticated with a storage account access key at mount time. The key is stored in the function app's site configuration (`azureStorageAccounts`). Managed identity isn't supported for SMB mounts on Azure Functions.
- **Azure SDK (REST API)**: For programmatic access via the Azure Storage SDK, use managed identity when possible.

```bicep
// Mount config in Bicep — requires storage account key
resource mountConfig 'Microsoft.Web/sites/config@2023-12-01' = {
  parent: functionApp
  name: 'azurestorageaccounts'
  properties: {
    dataMount: {
      type: 'AzureFiles'
      shareName: shareName
      mountPath: '/mounts/data'
      accountName: storageAccountName
      accessKey: storageAccount.listKeys().keys[0].value
    }
  }
}
```

> [!IMPORTANT]
> Rotate storage account keys periodically. When you rotate keys, update the mount configuration on every function app that references the account.

### Set mount quotas

Prevent runaway storage costs by setting a quota on your Azure Files share:

```bash
az storage share-rm update \
  --resource-group $RESOURCE_GROUP \
  --storage-account $STORAGE_ACCOUNT \
  --name myshare \
  --quota 100  # 100 GB limit
```

### Monitor file access

Enable diagnostics on your storage account to see mount access patterns:

```bash
az monitor metrics list \
  --resource /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT/fileServices/default \
  --metric Transactions
```

### Use read-only mounts when possible

If your function only reads from the mount, configure it as read-only to prevent accidental writes.

### Clean up temporary files

If your functions write to the mount, implement cleanup:

```python
from pathlib import Path
import time

MOUNT_PATH = "/mnt/temp"
TEMP_THRESHOLD = 24 * 60 * 60  # 24 hours

def cleanup_old_files():
    """Remove temp files older than 24 hours."""
    cutoff_time = time.time() - TEMP_THRESHOLD
    for file_path in Path(MOUNT_PATH).iterdir():
        if file_path.stat().st_mtime < cutoff_time:
            file_path.unlink()
```

## Troubleshoot storage mounts

The following table lists common issues with Azure Files storage mounts on function apps:

| Issue | Resolution |
| --- | --- |
| **Binary or file not found on mount path** | Verify the file was uploaded to the correct Azure Files share. Check that the mount path configured on the function app matches the path your code references. In the Azure portal, check **Settings** > **Configuration** > **Path Mappings**. |
| **Permission denied when accessing mounted files** | Storage mounts authenticate by using a storage account access key. Verify the key in the mount configuration is correct and hasn't been rotated. When you rotate keys, update the mount configuration on every function app that references the account. |
| **Binary lacks execute permissions** | Azure Files preserves POSIX permissions set at upload time. Re-upload the binary after running `chmod +x` locally, or set permissions after upload. |
| **Mount adds latency to cold starts** | SMB mount initialization adds approximately 200-500 ms on first execution. Subsequent invocations reuse the mount. For latency-sensitive apps, consider the [always-ready instances](./flex-consumption-plan.md) feature. |

## Related content

- [Tutorial: Process images by using FFmpeg on a mounted Azure Files share](./tutorial-ffmpeg-processing-azure-files.md)
- [Quickstart: Durable text analysis with a mounted Azure Files share](./quickstart-durable-text-analysis-azure-files.md)
- [Mount file shares](./storage-considerations.md#mount-file-shares)
- [Flex Consumption plan](./flex-consumption-plan.md)
- [Durable Functions overview](./durable/durable-functions-overview.md)
