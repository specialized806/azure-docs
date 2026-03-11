---
title: "Tutorial: Shared file access patterns with Azure Files OS mounts in Azure Functions"
description: Learn when and how to use Azure Files OS mounts with Azure Functions Flex Consumption for shared file access, large binaries, and cross-app data sharing.
ms.service: azure-functions
ms.topic: tutorial
ms.date: 03/11/2026
ms.custom:
  - devx-track-azurecli
  - devx-track-python
#customer intent: As a developer, I want to understand when to use Azure Files OS mounts versus storage bindings or external databases so I can choose the right approach for my function app.
---

# Tutorial: Shared file access patterns with Azure Files OS mounts

This tutorial explores when, how, and why to use Azure Files OS mounts with Azure Functions on the [Flex Consumption plan](./flex-consumption-plan.md). You learn the trade-offs between mounts, storage bindings, and external coordination, and see patterns for real-world scenarios.

[!INCLUDE [functions-azure-files-samples-note](../../includes/functions-azure-files-samples-note.md)]

## Prerequisites

- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- [Azure CLI](/cli/azure/install-azure-cli) version 2.60.0 or later.
- Familiarity with [Azure Functions](./functions-overview.md) and the [Flex Consumption plan](./flex-consumption-plan.md).

## The problem: sharing files between functions

When you need to share data between function instances, you have three main options:

| Approach | Pros | Cons | Best for |
| --- | --- | --- | --- |
| **Storage bindings** | Simple, cloud-native, secure | Network overhead, eventual consistency | Moving data to/from cloud services (queues, blobs) |
| **External database** | Flexible, transactional | Network calls, complexity | Structured data, complex queries |
| **OS mount (Azure Files)** | Direct file access, POSIX semantics, large binaries | Slower than local disk, requires Flex Consumption | Large files, shared executables, frequent access |

This tutorial focuses on OS mounts: when they're the right choice, and how to use them safely.

## What is an OS mount?

An OS mount is a network file share mounted as if it were a local directory. When you mount an Azure Files share on your function app, the path appears in the function container's file system:

```
Your Function Code
    ↓
/mnt/mydata/  (appears as local directory)
    ↓
Azure Files Share (via SMB protocol over network)
    ↓
Storage Account
```

Your code uses standard Python file APIs (`open()`, `os.listdir()`, and so on) without knowing it's communicating over the network. This provides POSIX semantics, which means your code looks like local file I/O.

## Scenario 1: Parallel analysis of shared files

**Use case:** You have 1,000 analysis tasks that all need to read from the same set of reference data files (for example, ML models, lookup tables, or corpus data).

### The problem

Without mounts, you have two suboptimal options:

1. **Package the reference files with your function**: This leads to a huge deployment artifact, slow cold starts, and storage redundancy.
2. **Download from Blob Storage each time**: This introduces network latency on every function invocation and wastes bandwidth.

### The mount solution

All instances read from the mounted share directly. After mount initialization, there's no per-request network overhead and no redundant storage.

```
Function Instance 1 ┐
Function Instance 2 ├→ /mnt/models/  (shared OS mount) → Azure Files Share
Function Instance 3 ┘
```

### Implementation pattern

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

Key points:

- All instances of your function app see the same mount.
- File reads are POSIX-compliant. You use standard Python file APIs.
- No need to authenticate per read (the mount is authenticated once at startup).
- Changes written by one instance are visible to others immediately.

### Security considerations

1. **Storage account key**: Azure Files OS mounts on Flex Consumption authenticate by using a storage account access key configured in the function app's mount settings. Managed identity with `Storage File Data SMB Share Contributor` RBAC isn't supported for SMB mounts on Azure Functions. Keep the access key secure and rotate it periodically.
2. **Read-only option**: If your workload doesn't need to write, restrict the mount to read-only.
3. **Quotas**: Set Azure Files share quotas to prevent runaway costs if instances write large files.

## Scenario 2: Shared executables (ffmpeg, ImageMagick, and others)

**Use case:** You need to run a large third-party binary (500+ MB) on every instance, but you don't want to package it with your function code.

### The problem

Without mounts:

1. **Package binary in deployment artifact**: 500+ MB per instance, slow deployment, wasted bandwidth.
2. **Download from Blob on each invocation**: Network call on every execution, slower than local access.

### The mount solution

Upload the binary once to Azure Files. All instances access it from the mount.

```
Deployment Package: 10 MB (just your code)
    ↓
Mount: /mnt/binaries/ffmpeg (500 MB, shared, downloaded once)
    ↓
Execution: subprocess.run(["/mnt/binaries/ffmpeg", ...])
```

### Implementation pattern

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

Key points:

- The binary is mounted, not packaged.
- The deployment artifact stays small.
- Cold starts are faster (less to unzip).
- All instances can call the same binary concurrently.

### Performance implications

- **First execution**: SMB mount initialization adds approximately 200-500 ms.
- **Subsequent executions**: Direct file access with minimal overhead.
- **Binary caching**: The OS caches the binary in memory, reducing repeated disk reads.

> [!TIP]
> For frequently called binaries, the performance overhead is negligible after the first few invocations.

## Scenario 3: Data sharing between multiple function apps

**Use case:** You have App A (data producer) and App B (data consumer) running in the same region. App A writes processed data, and App B reads it.

### Without mounts

You'd typically use Azure Blob Storage (decoupled, but with network overhead), Azure Queue Storage with message passing (eventual consistency), or Azure Cosmos DB (more complexity than simple file sharing needs).

### With mounts

Both apps mount the same Azure Files share. App A writes, and App B reads. No message passing, no eventual consistency.

```
App A (Producer) ┐
App B (Consumer) ├→ /mnt/shared/  → Azure Files Share (single source of truth)
```

### Implementation pattern

**App A (Producer):**

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

**App B (Consumer):**

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

Key points:

- Both apps need mount configuration referencing the same storage account and access key.
- Use file locks (for example, `fcntl` on Linux) to prevent read/write race conditions.
- Azure Files supports concurrent reads; writes should be sequential or locked.

> [!WARNING]
> Azure Files doesn't provide database-level transactions. If you need atomic writes and reads, consider Azure Cosmos DB or Azure SQL Database instead.

## Best practices

### Understand the two auth models

Azure Files OS mounts and the Azure SDK use different authentication mechanisms:

- **OS mounts (SMB)**: Authenticated with a storage account access key at mount time. The key is stored in the function app's site configuration (`azureStorageAccounts`). Managed identity isn't supported for SMB mounts on Azure Functions.
- **Azure SDK (REST API)**: For programmatic access via `azure-storage-file-share`, use managed identity when possible.

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

## When not to use mounts

Mounts aren't the right choice for every scenario:

| Scenario | Recommended alternative |
| --- | --- |
| Small transient data | Azure Queue Storage or Blob Storage bindings |
| Frequent small reads/writes | Azure Cosmos DB or Azure Cache for Redis |
| Real-time streaming | Azure Event Hubs or Azure IoT Hub |
| Cross-region data sharing | Blob Storage replication |
| Consumption plan functions | Only Flex Consumption and App Service support OS mounts |

### Mount limits

| Limit | Value |
| --- | --- |
| Share size | Up to 100 TiB |
| File size | Up to 4 TiB |
| Throughput | ~60 MB/s (standard), ~100+ MB/s (premium) |
| Concurrency | Many (SMB handles it), but writes serialize |

For more information, see [Azure Files scale targets](/azure/storage/files/storage-files-scale-targets).

## Comparison: mounts vs. bindings vs. external storage

Consider processing 1,000 images stored in a reference folder:

**Option A: Blob binding (with download)**

```python
files = container_client.list_blobs(name_starts_with="reference/")
for blob in files:
    stream = container_client.download_blob(blob.name)
    # Cost: 1000 GET requests × 1 MB = high bandwidth cost + latency
```

**Option B: OS mount (read from share)**

```python
for file_path in Path("/mnt/reference").iterdir():
    with open(file_path, "rb") as f:
        # Cost: One mount setup + local reads, minimal bandwidth
```

**Option C: External database (Azure Cosmos DB)**

```python
reference_data = container.query_items(
    query="SELECT * FROM reference WHERE id IN (...)"
)
# Cost: Query RUs + network latency, good for structured data
```

For large shared files, Option B (mounts) is the best choice.

## Related content

- [Quickstart: Durable text analysis with Azure Files OS mount](./quickstart-durable-text-analysis-azure-files.md)
- [Quickstart: FFmpeg image processing with Azure Files OS mount](./quickstart-ffmpeg-processing-azure-files.md)
- [Flex Consumption plan](./flex-consumption-plan.md)
- [Storage considerations for Azure Functions](./storage-considerations.md)
- [Durable Functions overview](./durable/durable-functions-overview.md)
