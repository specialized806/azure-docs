---
title: Hardware specifications of the hosts
description: Hosts used to build or scale clusters come from an isolated pool of hosts.
ms.topic: include
ms.service: azure-vmware
ms.date: 6/18/2025
author: suzizuber
ms.author: v-szuber
ms.custom: engagement-fy23
# Customer intent: "As a cloud architect, I want to understand the hardware specifications of different host types in Azure VMware Solution, so that I can select the appropriate resources for building or scaling my private cloud clusters."
---

<!-- Used in plan-private-cloud-deployment.md and concepts-private-cloud-clusters.md -->

Azure VMware Solution clusters are based on a hyperconverged infrastructure. The following table shows the CPU, memory, disk, and network specifications of the host.

| Host type | CPU (cores/GHz)   | RAM (GB)  | vSAN Architecture| vSAN cache tier (TB, raw***)  | vSAN capacity tier (TB, raw***)  | Regional availability |
| :---      | :---: | :---:     | :---:                      | :---:                                        | :---:                 | :---:| 
| AV36      | Intel Xeon Scalable processors (Skylake generation), 36 cores |  576 | OSA | 3.2 (NVMe) | 15.20 (SSD)  | Selected regions (*) |
| AV36P     | Intel Xeon Scalable processors (Cascade Lake generation), 36 cores |  768 | OSA | 1.5 (Intel Cache) | 19.20 (NVMe) | Selected regions (*) |
| AV48      | Intel Xeon Scalable processors (Sapphire Rapids generation), 48 cores| 1,024 | ESA | N/A | 25.6 (NVMe) | Selected regions (*) |
| AV52      | Intel Xeon Scalable processors (Cascade Lake generation), 52 cores | 1,536 | OSA | 1.5 (Intel Cache) | 38.40 (NVMe) | Selected regions (*) |
| AV64      | Intel Xeon Scalable processors (Ice Lake generation), 64 cores |  1,024 | OSA / ESA****| 3.84 (NVMe) / N/A | 15.36 (NVMe) / 19.25 (NVMe)| Selected regions (**) |

An Azure VMware Solution cluster requires a minimum number of three hosts. You can use hosts of the same type only in a single Azure VMware Solution private cloud. Hosts used to build or scale clusters come from an isolated pool of hosts. Those hosts passed hardware tests and had all data securely deleted before being added to a cluster.

All of the preceding host types have 100-Gbps network interface throughput.

*Details are available via the Azure pricing calculator.

**AV64 prerequisite: An Azure VMware Solution private cloud deployed with AV36, AV36P, or AV52 is required before adding AV64.

***Raw is based on [International Standard of Units (SI)](https://en.wikipedia.org/wiki/International_System_of_Units) reported by disk manufacturers. Example: 1 TB Raw = 1000000000000 bytes. Space calculated by a computer in binary (1 TB binary = 1099511627776 bytes binary) equals 931.3 gigabytes converted from the raw decimal.

***ESA with AV64 only applies to Gen 2 deployments
