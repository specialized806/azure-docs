---
# Required metadata
# For more information, see https://learn.microsoft.com/en-us/help/platform/learn-editor-add-metadata
# For valid values of ms.service, ms.prod, and ms.topic, see https://learn.microsoft.com/en-us/help/platform/metadata-taxonomies

title:       # Add a title for the browser tab
description: # Add a meaningful description for search results
author:      eshanchomsft # GitHub alias
ms.author:   echowdhury # Microsoft alias
ms.service:  # Add the ms.service or ms.prod value
# ms.prod:   # To use ms.prod, uncomment it and delete ms.service
ms.topic:    # Add the ms.topic value
ms.date:     02/25/2026
---

# Elastic SAN Datastore Performance on Azure VMWare Solutions

## Overview

This article outlines performance benchmarks that **Azure Elastic SAN** datastores deliver for **Virtual Machines on Azure VMware Solution**. Organizations evaluating Elastic SAN can use these results as a reference by comparing their workload profiles to the test results in this document. Environment details and benchmarking instructions are included to help reproduce the tests as needed.

The workload categories evaluated are:

- **I/O‑intensive workloads** – Small, random, read‑heavy I/O patterns commonly observed in transactional workloads.

- **Throughput‑intensive workloads** – Large, sequential I/O patterns typical of backup, scan, and read‑ahead workloads.

All tests were conducted using sufficiently sized Elastic SAN as described in the environment details below. For guidance on configuring Elastic SAN for optimal performance, see [Azure Elastic SAN configuration best practices](/azure/storage/elastic-san/elastic-san-best-practices).

## Environment Details

### Azure VMware Solution configuration

- Gen 2 Private Cloud

- 3 x AV64 ESXi hosts

- Guest virtual machines: Tests were performed on both Windows and Linux

- Operating systems: Windows Server 2022 & Ubuntu 24.04

- VM size: 32 vCPU, 256 GB RAM
  
  - VM disk: 1 TiB / 500 GiB with eager‑zeroed thick provisioning
  
### Azure Elastic SAN configuration

- Elastic SAN deployed in the same region and availability zone as the AVS cluster

- Elastic SAN base capacity provisioned: **100 TiB**

- Elastic SAN volume backing the datastore: **20 TiB** (supports up to **80,000 IOPS** and **1,280 MBps**)

- Private endpoints configured: 8

> **Note**
> Elastic SAN performance is governed by the provisioned base capacity. To achieve the maximum performance of **80,000 IOPS** and/or **1,280 MBps** for a single datastore, configure Elastic SAN with **at least 16 base units**.

For detailed information on scale targets per base unit, see [Azure Elastic SAN scalability and performance targets](/azure/storage/elastic-san/elastic-san-scale-targets).

## Benchmarking Tools Overview

The results in this article were produced using industry‑standard benchmarking tools:

- **DiskSPD (Windows)** – A flexible tool for generating synthetic storage workloads. Download from [GitHub – DiskSPD](https://github.com/Microsoft/diskspd).

- **fio (Linux)** – A commonly used Linux storage benchmarking tool that supports random and sequential I/O patterns, configurable I/O sizes, and multi‑threaded workloads. Download from [GitHub – fio](https://github.com/axboe/fio).

For each workload scenario, the benchmark commands featured below were executed on one or more guest VMs connected to the same ESAN datastore.

## Running the Featured Benchmark Tests

The following examples describe how benchmark tests were executed to reproduce the run data shown in the **Test Results** section below. There are two examples for each of the Windows & Linux tests we ran for I/O Intensive Workloads & Throughput intensive workloads respectively.

## I/O‑Intensive Workload Example

### Windows (DiskSPD)

Each guest VM executed the following command independently, with all VMs running concurrently:


```
diskspd.exe -b4K -d900 -Sh -L -o32 -t3 -r -w25 -Z1G -c20G G:\Testdata\IO.dat
```

Baseline parameters:

- `-b4K` – 4 KB I/O size

- `-r -w25` – Random I/O with a 75% read / 25% write mix

- `-t3` – Three threads per VM

- `-o32` – Queue depth of 32 per thread

- `-d900` – 15‑minute steady‑state runtime

- `-c20G` – Per‑VM test file size

### Linux (fio)


```
fio --name=randrw \
    --rw=randrw \
    --rwmixread=75 \
    --bs=4k \
    --iodepth=32 \
    --numjobs=3 \
    --time_based \
    --runtime=900 \
    --direct=1 \
    --ioengine=libaio \
    --group_reporting \
    --filename=/mnt/esan/testfile
```

Baseline parameters:

- `bs=4k` – 4 KB I/O size

- `rw=randrw`, `rwmixread=75` – 75% read / 25% write mix

- `numjobs=3` – Three threads per VM

- `iodepth=32` – Outstanding I/Os per thread

- `runtime=900` – 15‑minute steady‑state runtime

## Throughput‑Intensive Workload Example

### Windows (DiskSPD)


```
diskspd.exe -b1M -d900 -Sh -L -o32 -t3 -si -w0 -c200G G:\Testdata\BackupIO.dat
```

Baseline parameters:

- `-b1M` – 1 MB I/O size

- `-si -w0` – Sequential, read‑only I/O

- `-t3` – Three threads per VM

- `-o32` – Queue depth

- `-d900` – 15‑minute steady‑state runtime

### Linux (fio)


```
fio --name=readseq \
    --rw=read \
    --bs=1M \
    --iodepth=32 \
    --numjobs=3 \
    --time_based \
    --runtime=900 \
    --direct=1 \
    --ioengine=libaio \
    --group_reporting \
    --filename=/mnt/esan/testfile
```

## Test Results

### I/O‑Intensive Workloads

Each guest VM executed the benchmark independently, with all participating VMs running concurrently against the same ESAN‑backed datastore. Reported IOPS and throughput reflect **aggregate datastore‑level performance** observed across all VMs during the runtime of the tests.

#### Windows / DiskSPD (Test #1)

| # of Guest VMs | I/O Pattern                    | I/O Size | Threads per VM | Queue Depth | IOPS Achieved | MBps Achieved |
|---------------:|--------------------------------|----------|---------------:|------------:|--------------:|--------------:|
| 4              | Random (Read/Write 75/25)      | 4K       | 3              | 96          | 100,000       | 414           |

#### Linux / fio (Test #2)

| # of Guest VMs | I/O Pattern                    | I/O Size | Threads per VM | Queue Depth | IOPS Achieved | MBps Achieved |
|---------------:|--------------------------------|----------|---------------:|------------:|--------------:|--------------:|
| 6              | Random (Read/Write 75/25)      | 4K       | 3              | 96          | 85,000        | 356           |

---

### Throughput‑Intensive Workloads

In this scenario, a single guest VM executed the benchmark against an ESAN‑backed AVS datastore.

#### Windows / DiskSPD (Test #1)

| # of Guest VMs | I/O Pattern               | I/O Size | Threads per VM | Queue Depth | IOPS Achieved | MBps Achieved |
|---------------:|---------------------------|----------|---------------:|------------:|--------------:|--------------:|
| 1              | Sequential (Read 100%)    | 1M       | 3              | 96          | 12,790        | 1,648         |

#### Linux / fio (Test #2)

| # of Guest VMs | I/O Pattern               | I/O Size | Threads per VM | Queue Depth | IOPS Achieved | MBps Achieved |
|---------------:|---------------------------|----------|---------------:|------------:|--------------:|--------------:|
| 1              | Sequential (Read 100%)    | 1M       | 3              | 96          | 13,000        | 1,519         |
``
