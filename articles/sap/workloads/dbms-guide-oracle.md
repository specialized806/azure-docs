---
title: Oracle Azure Virtual Machines Database Deployment for SAP Workload
description: Learn about Oracle Azure virtual machines DBMS deployment for SAP workloads.
keywords: 'SAP, Azure, Oracle, Data Guard'
ms.service: sap-on-azure
ms.subservice: sap-vm-workloads
ms.topic: concept-article
ms.date: 02/12/2026
ms.author: juergent
author: msjuergent
manager: bburns
ms.custom: H1Hack27Feb2017, linux-related-content
# Customer intent: As a database administrator, I want to deploy Oracle Database for SAP workloads on Azure so that I can optimize performance and ensure compatibility with SAP application requirements.
---

# Azure virtual machines Oracle database deployment for SAP workload

This article covers several different areas to consider when you deploy Oracle Database for SAP workload in Azure infrastucture as a service (IaaS). Before you read this document, we recommend that you read [Considerations for Azure virtual machines database management system (DBMS) deployment for SAP workload](./dbms-guide-general.md). We also recommend that you read other guides in the [SAP workload on Azure](./get-started.md) documentation.

You can find information about Oracle versions and corresponding operating system (OS) versions that are supported for running SAP on Oracle on Azure in SAP Note [2039619](https://launchpad.support.sap.com/#/notes/2039619).

For general information about running SAP Business Suite on Oracle, see [SAP on Oracle](https://www.sap.com/community/topic/oracle.html). Oracle supports running Oracle databases on Azure. For more information about general support for Windows Hyper-V and Azure, see the [Oracle and Azure FAQ](https://www.oracle.com/technetwork/topics/cloud/faq-1963009.html).

## Relevant SAP Notes for an Oracle installation

| Note number | Note title |
| --- | --- |
| 1738053 | [SAPinst for Oracle ASM installation SAP ONE Support Launchpad](https://launchpad.support.sap.com/#/notes/0001738053) |
| 2896926 | [ASM disk group compatibility NetWeaver SAP ONE Support Launchpad](https://launchpad.support.sap.com/#/notes/0002896926) |
| 1550133 | [Using Oracle Automatic Storage Management (ASM) with SAP NetWeaver-based Products SAP ONE Support Launchpad](https://launchpad.support.sap.com/#/notes/0001550133) |
| 888626 | [Redo log layout for high-end systems SAP ONE Support Launchpad](https://launchpad.support.sap.com/#/notes/0000888626) |
| 105047 | [Support for Oracle functions in the SAP environment SAP ONE Support Launchpad](https://launchpad.support.sap.com/#/notes/0000105047) |
| 2799920 | [Patches for 19c: Database SAP ONE Support Launchpad](https://launchpad.support.sap.com/#/notes/0002799920) |
| 974876 | [Oracle Transparent Data Encryption (TDE) SAP ONE Support Launchpad](https://launchpad.support.sap.com/#/notes/0000974876) |
| 2936683 | [Oracle Linux 8: SAP Installation and Upgrade SAP ONE Support Launchpad](https://launchpad.support.sap.com/#/notes/2936683) |
| 1672954 | [Oracle 11g, 12c, 18c, and 19c: Usage of HugePages on Linux](https://launchpad.support.sap.com/#/notes/1672954) |
| 1171650 | [Automated Oracle DB parameter check](https://launchpad.support.sap.com/#/notes/1171650) |
| 2936683 | [Oracle Linux 8: SAP Installation and Upgrade](https://launchpad.support.sap.com/#/notes/2936683) |
| 3399081 | [Oracle Linux 9: SAP Installation and Upgrade](https://launchpad.support.sap.com/#/notes/3399081) |

### Specifics for Oracle Database on Oracle Linux

Oracle supports running its database instances on Azure with Oracle Linux as the guest OS. For more information about general support for Windows Hyper-V and Azure, see the [Oracle and Azure FAQ](https://www.oracle.com/technetwork/topics/cloud/faq-1963009.html).

The specific scenario of SAP applications using Oracle databases is also supported. Details are discussed in the next part of this article.

### General recommendations for running SAP on Oracle on Azure

When you install or migrate existing SAP on Oracle systems to Azure, follow this deployment pattern:

* Use the most [recent Oracle Linux](https://docs.oracle.com/en/operating-systems/oracle-linux/8/) version available (Oracle Linux 8.6 or later).
* Use the most recent Oracle Database version available with the latest SAP Bundle Patch (Oracle 19 Patch 15 or later) [2799920 - Patches for 19c: Database](https://launchpad.support.sap.com/#/notes/2799920).
* Use Automatic Storage Management (ASM) for small, medium, and large-sized databases on block storage.
* Use Azure Premium Storage SSD. Don't use Standard or other storage types.
* ASM removes the requirement for Mirror Log. Follow the guidance from Oracle in Note [888626 - Redo log layout for high-end systems](https://launchpad.support.sap.com/#/notes/888626).
* Use `ASMLib` and don't use `udev`.
* Use Oracle dNFS for Azure NetApp Files deployments, which is Oracle's own high-performance direct Network File System (dNFS) driver solution.
* Large Oracle databases benefit greatly from large System Global Area (SGA) sizes. Large customers should deploy on Azure M-series with 4 TB or more RAM size:

  * Set Linux HugePages to 75% of physical RAM size.
  * Set SGA to 90% of HugePage size.
  * Set the Oracle parameter `USE_LARGE_PAGES = ONLY`. The value `ONLY` is preferred over the value `TRUE` because the value `ONLY` is supposed to deliver more consistent and predictable performance. The value `TRUE` might allocate both large 2-MB and standard 4 K pages. The value `ONLY` always forces large 2-MB pages. If the number of available HugePages isn't sufficient or isn't correctly configured, the database instance fails to start with the following error code:

  ```error
  ora-27102 :  out of memory Linux_x86_64 Error 12 : can't allocate memory
  ```

  If you encounter insufficient contiguous memory, you might need to restart Oracle Linux or reconfigure the OS HugePage parameters.

* Locate Oracle Home outside of the "root" volume or disk. Use a separate disk or Azure NetApp Files volume. The disk holding the Oracle Home should be 64 gigabytes in size or larger.
* Recognize that the size of the boot disk for large high-performance Oracle database servers is important. At a minimum, use a P10 disk for M-series or E-series. Don't use small disks, such as P4 or P6. A small disk can cause performance issues.
* Enable Accelerated Networking on all virtual machines (VMs). Upgrade to the latest Oracle Linux release if there are any problems when you enable Accelerated Networking.
* Check for updates in this documentation and the SAP Note [2039619 - SAP Applications on Microsoft Azure using the Oracle Database: Supported Products and Versions](https://launchpad.support.sap.com/#/notes/2039619).

For information about which Oracle versions and corresponding OS versions are supported for running SAP on Oracle on Azure VMs, see SAP Note [2039619](https://launchpad.support.sap.com/#/notes/2039619).

For general information about running SAP Business Suite on Oracle, see the [SAP on Oracle community page](https://www.sap.com/community/topic/oracle.html). SAP on Oracle on Azure is supported only on Oracle Linux (and not SUSE or Red Hat) for application and database servers.

ASCS/ERS servers can use RHEL/SUSE because the Oracle client isn't installed or used on these VMs. Don't install application servers (PAS/AAS) on these VMs. Refer to SAP Note [3074643 - OLNX: FAQ: if Pacemaker for Oracle Linux is supported in SAP Environment](https://me.sap.com/notes/3074643). Oracle Real Application Cluster (RAC) isn't supported on Azure because RAC requires multicast networking.

## Storage configuration

Two storage deployment patterns are recommended for SAP on Oracle on Azure:

* Oracle Automatic Storage Management (ASM)
* Azure NetApp Files with Oracle dNFS

Customers currently running Oracle databases on EXT4 or XFS file systems with Logical Volume Manager (LVM) are encouraged to move to ASM. There are considerable performance, administration, and reliability advantages to running on ASM compared to an LVM. ASM reduces complexity, improves supportability, and makes administration tasks simpler. This documentation contains links for Oracle database administrators (DBAs) to learn how to install and manage ASM.

Azure provides [multiple storage solutions](/azure/virtual-machines/disks-types).

The following table details the support status:

| Storage type | Oracle support | Sector size | Oracle Linux 8.x or higher | Windows Server 2019 |
|--|--|--|--|--|
| Block Storage Type | | | | |
| Premium SSD | Supported. | 512e | ASM recommended. LVM supported. | No support for ASM on Windows. |
| Premium SSD v2<sup>1</sup> | Supported. | 4K Native or 512e<sup>2</sup> | ASM recommended. LVM supported. | No support for ASM on Windows. Change Log File disks from 4K Native to 512e. |
| Standard SSD | Not supported. | | | |
| Standard HDD | Not supported. | | | |
| Ultra Disk | Supported. | 4K Native | ASM recommended. LVM supported. | No support for ASM on Windows. Change Log File disks from 4K Native to 512e. |
| | | | | |
| Network Storage Types | | | | |
| Azure NetApp Files | Supported. | - | Oracle dNFS required. | Not supported. |
| Azure Files NFS | Not supported. | | | |
| Azure files SMB | Not supported. | | | |

<sup>1</sup> Azure Premium SSD v2 doesn't have predefined storage sizes. There's no need to allocate multiple disks within an ASM Disk Group or LVM VG. The recommendation is to allocate a single Premium SSD v2 disk with the required size, throughput, and IOPS per ASM Disk Group.

<sup>2</sup> 512e is supported on Premium SSD v2 for Windows systems. 512e configurations are't recommended for Linux customers. Migrate to 4K Native by using the procedure in MOS 512/512e sector size to 4K Native Review (Doc ID 1133713.1).

Other considerations that apply:

* No support for `DIRECTIO` with 4K Native sector size. Recommended settings for `FILESYSTEMIO_OPTIONS` for LVM configurations:

  * LVM: If disks with 512/512e geometry are used, `FILESYSTEMIO_OPTIONS = SETALL`.
  * LVM: If disks with 4K Native geometry are used, `FILESYSTEMIO_OPTIONS = ASYNC`.

* Oracle 19c and higher fully supports 4K Native sector size with both ASM and LVM.
* Oracle 19c and higher on Linux – when moving from 512e storage to 4K Native storage Log sector sizes must be changed.
* To migrate from 512/512e sector size to 4K Native Review (Doc ID 1133713.1), see the section **Offline Migration to 4KB Sector Disks**.
* SAPInst writes to the pfile during installation. If the $ORACLE_HOME/dbs is on a 4K disk, set `filesystemio_options=asynch` and see the section **Datafile Support of 4kB Sector Disks** in MOS Supporting 4K Sector Disks (Doc ID 1133713.1).
* No support for ASM on Windows platforms.
* No support for 4K Native sector size for Log volume on Windows platforms. SSDv2 and Ultra Disk must be changed to 512e via the **Edit Disk** pencil icon in the Azure portal.
* 4K Native sector size is supported only on Data volumes for Windows platforms. 4K isn't supported for Log volumes on Windows.
* Review the following MOS articles:

  * Oracle Linux: File System's Buffer Cache versus Direct I/O (Doc ID 462072.1)
  * Supporting 4K Sector Disks (Doc ID 1133713.1)
  * Using 4k Redo Logs on Flash, 4k-Disk, and SSD-based Storage (Doc ID 1681266.1)
  * Things To consider For Setting filesystemio_options And disk_asynch_io (Doc ID 1987437.1)

We recommend that you use Oracle ASM on Linux with ASMLib. Performance, administration, support, and configuration are optimized with deployment pattern. Oracle ASM and Oracle dNFS are going to set the correct parameters or bypass parameters (such as `FILESYSTEMIO_OPTIONS`) and deliver better performance and reliability.

### Storage configurations for SAP on Oracle on Windows

# [Minimum configuration](#tab/minimum)

| Component                           | Disk | Host cache        | Striping<sup>1</sup> |
|-----------------------------------------|----------|-----------------------|--------------------------|
| E:\oracle\\<SID\>\origlogaA & mirrlogB | Premium  | None                  | Not needed               |
| F:\oracle\\<SID\>\origlogaB & mirrlogA | Premium  | None                  | Not needed               |
| G:\oracle\\<SID\>\sapdata1...*n* | Premium  | None                  | Recommended              |
| H:\oracle\\<SID\>\oraarch<sup>2</sup> | Premium  | None                  | Not needed |
| I:\Oracle Home, saptrace, ... | Premium  | None | None |

<sup>1</sup> Striping: Windows Storage Spaces.
<sup>2</sup> `oraarch`: Windows Storage Spaces is optional.

You must select disks for hosting Oracle's online redo logs based on IOPS requirements. It's possible to store all `sapdata1...*n*` (tablespaces) on a single mounted disk if the volume, IOPS, and throughput satisfy the requirements.

# [Performance configuration](#tab/performance)

| Component                          | Disk | Host cache        | Striping<sup>1</sup> |
|----------------------------------------|----------|-----------------------|--------------------------|
| E:\oracle\\<SID\>\origlogaA           | Premium  | None                  | Can be used              |
| F:\oracle\\<SID\>\origlogaB           | Premium  | None                  | Can be used              |
| G:\oracle\\<SID\>\mirrlogAB           | Premium  | None                  | Can be used              |
| H:\oracle\\<SID\>\mirrlogBA           | Premium  | None                  | Can be used              |
| I:\oracle\\<SID\>\sapdata1...*n*        | Premium  | None                  | Recommended              |
| J:\oracle\\<SID\>\oraarch<sup>2</sup> | Premium  | None                  | Not needed               |
| K:\Oracle Home, saptrace, ...          | Premium  | None                  | None                     |

<sup>1</sup> Striping: Windows Storage Spaces.
<sup>2</sup> oraarch: Windows Storage Spaces is optional.

---

## Storage configurations for SAP on Oracle on Linux

# [Minimum configuration](#tab/minimum)

| Component                        | Disk | Host cache        | Striping<sup>1</sup> |
|--------------------------------------|----------|-----------------------|--------------------------|
| `/oracle/\<SID\>/origlogaA & mirrlogB` | Premium  | None                  | Not needed               |
| `/oracle/\<SID\>/origlogaB & mirrlogA` | Premium  | None                  | Not needed               |
| `/oracle/\<SID\>/sapdata1...*n*`         | Premium  | None                  | Recommended              |
| `/oracle/\<SID\>/oraarch`<sup>2</sup>  | Premium  | None                  | Not needed               |
| Oracle Home, `saptrace`, ...           | Premium  | None                  | None                     |

<sup>1</sup> Striping: LVM stripe by using RAID0.
<sup>2</sup> oraarch: LVM is optional.

You must select disks for hosting Oracle's online redo logs based on IOPS requirements. It's possible to store all sapdata1...*n* (tablespaces) on a single mounted disk as long as the volume, IOPS, and throughput satisfy the requirements.

# [Performance configuration](#tab/performance)

| Component                       | Disk | Host cache        | Striping<sup>1</sup> |
|-------------------------------------|----------|-----------------------|--------------------------|
| `/oracle/\<SID\>/origlogaA`           | Premium  | None                  | Can be used              |
| `/oracle/\<SID\>/origlogaB`           | Premium  | None                  | Can be used              |
| `/oracle/\<SID\>/mirrlogAB`           | Premium  | None                  | Can be used              |
| `/oracle/\<SID\>/mirrlogBA`           | Premium  | None                  | Can be used              |
| `/oracle/\<SID\>/sapdata1...*n*`        | Premium  | None                  | Recommended              |
| `/oracle/\<SID\>/oraarch`<sup>2</sup> | Premium  | None                  | Not needed               |
| Oracle Home, `saptrace`, ...          | Premium  | None                  | None                     |

<sup>1</sup> Striping: LVM stripe using RAID0.
<sup>2</sup> oraarch: LVM is optional.

---

### SAP on Oracle on Azure with LVM

ASM is the default recommendation from Oracle for all SAP systems of any size on Azure. Performance, reliability, and support are better for customers when they use ASM. Oracle provides documentation and training for DBAs to transition to ASM. When the Oracle DBA team doesn't follow the recommendation from Oracle, Microsoft, and SAP to use ASM, use the following LVM configuration.

When you create an LVM, the `-i` option must be used to evenly distribute data across the number of disks in the LVM group. Mirror Log is required when you run LVM.

### Oracle Automatic Storage Management

Checklist for Oracle ASM:

* All SAP on Oracle on Azure systems run ASM, including Development, Quality Assurance, and Production, for small, medium, and large databases.
* [ASMLib](https://docs.oracle.com/en/database/oracle/oracle-database/19/ladbi/about-oracle-asm-with-oracle-asmlib.html) is used and not `UDEV`. `UDEV` is required for multiple SANs. This scenario doesn't exist on Azure.
* ASM should be configured for **External Redundancy**. Azure Premium SSD storage provides triple redundancy. Azure Premium SSD matches the reliability and integrity of any other storage solution. For optional safety, customers can consider **Normal Redundancy** for the Log Disk Group.
* Mirroring Redo Log files is optional for ASM [888626 - Redo log layout for high-end systems](https://launchpad.support.sap.com/#/notes/888626).
* ASM Disk Groups configured as per Variant 1, 2, or 3.
* ASM Allocation Unit size = 4 MB (default). Very large database (VLDB) OLAP systems such as SAP BW might benefit from larger ASM Allocation Unit size. Change only after you confirm with Oracle support.
* ASM Sector Size and Logical Sector Size = default (UDEV isn't recommended but requires 4k).
* If the `COMPATIBLE.ASM` disk group attribute is set to `11.2` or greater for a disk group, you can create, copy, or move an Oracle ASM `SPFILE` into the ACFS file system. Review the Oracle documentation about moving `pfile` into ACFS. `SAPInst` doesn't create the `pfile` in ACFS by default.
* The appropriate ASM variant is used. Production systems should use Variant 2 or 3.

### Variant types

> [!NOTE]
> You can set the Azure Host Disk Cache for the DATA ASM Disk Group to either read only or none. Consider some of the new M(b)v3 VM types where the use of read cached Premium SSD v1 storage might result in lower read and write IOPS rates and throughput. You get better performance if you don't use read cache on these VM types. Set all other ASM Disk Groups to none. On BW or SCM, you can consider a separate ASM Disk Group for `TEMP` for large or busy systems.

# [Variant 1](#tab/variant1)

In this example, a customer has small or medium-sized databases (up to 3 TB). Ypu can accomplish the backup or restore of all databases by using Oracle Recovery Manager (RMAN) in a timely fashion where recovery time isn't critical. When a complete Oracle ASM disk group with data files from one or more databases is broken, all data files from all databases must be restored. This restoration is performed to a newly created Oracle ASM disk group by using RMAN.

Oracle ASM disk group recommendation:

| ASM disk group name | Stores | Azure Storage |
|--|--|--|
| +DATA | All data files <br><br> Control file (first copy) <br><br> Online redo logs (first copy) | 3-6 x P 30 (1 TiB) <br><br> (To increase database size, add extra P30 disks.) |
| +ARCH | Control file (second copy) <br><br> Archived redo logs | 2 x P20 (512 GiB) |
| +RECO | Control file (third copy) <br><br> RMAN backups (optional) <br><br> Recovery area (optional) | 2 x P20 (512 GiB) |

# [Variant 2](#tab/variant2)

In this example, a customer has medium to large-sized databases (between 3 TB and 12 TB). The backup and/or restore of all databases can't be accomplished in a timely fashion where the recovery time is important. Usually, customers use RMAN, Azure Backup for Oracle, or disk snapshot techniques in combination.

Major differences to Variant 1 are:

* Separate Oracle ASM disk group for each database.
* \<DBNAME>+"\_" is used as a prefix for the name of the DATA disk group.
* The number of the DATA disk group is appended if the database spans over more than one DATA disk group.
* No online redo logs are located in the "data" disk groups. Instead, an extra disk group is used for the first member of each online redo log group.

| ASM disk group name | Stores | Azure Storage |
|--|--|--|
| +\<DBName>_DATA[#] | All data files <br><br> All temp files <br><br> Control file (first copy) | 3-12 x P 30 (1 TiB) <br><br> (To increase database size, add extra P30 disks.) |
| +OLOG | Online redo logs (first copy) | 3 x P20 (512 GiB) |
| +ARCH | Control file (second copy) <br><br> Archived redo logs |3 x P20 (512 GB) |
| +RECO | Control file (third copy) <br><br> RMAN backups (optional) <br><br> Fast recovery area (optional) | 3 x P20 (512 GiB) |

# [Variant 3](#tab/variant3)

In this example, a customer has a huge database (volumes greater than 5 TB). Backup or restore to a single database can't be accomplished in a timely fashion where recovery time is crucial. Usually, customers use RMAN, Azure Backup for Oracle, or disk snapshot techniques in combination. In this variant, each relevant database file type is separated to different Oracle ASM disk groups.

| ASM disk group name | Stores | Azure Storage |
|--|--|--|
| +\<DBName>_DATA[#] | All data files <br><br> All temp files <br><br> Control file (first copy) |5-30 or more x P30 (1 TiB) or P40 (2 TiB) <br><br> (To increase database size, add extra P30 disks.) |
| +OLOG | Online redo logs (first copy) | 3-8 x P20 (512 GiB) or P30 (1 TiB) <br><br> For more safety, select **Normal Redundancy** for this ASM disk group. |
| +ARCH | Control file (second copy) <br><br> Archived redo logs |3-8 x P20 (512 GiB) or P30 (1 TiB) |
| +RECO | Control file (third copy) <br><br> RMAN backups (optional) <br><br> Fast recovery area (optional) | 3 x P30 (1 TiB), P40 (2 TiB) or P50 (4 TiB) |

---

### Oracle ASM disk groups

Part II of the official Oracle Guide describes the installation and management of ASM:

- [Oracle Automatic Storage Management Administrator's Guide, 19c](https://docs.oracle.com/en/database/oracle/oracle-database/19/ostmg/index.html)
- [Oracle Grid Infrastructure Grid Infrastructure Installation and Upgrade Guide, 19c for Linux](https://docs.oracle.com/en/database/oracle/oracle-database/19/cwlin/index.html)

The following ASM limits exist for Oracle Database 12c or later:

511 disk groups, 10,000 ASM disks in a Disk Group, 65,530 ASM disks in a storage system, 1 million files for each Disk Group. For more information, see [Performance and Scalability Considerations for Disk Groups (oracle.com)](https://docs.oracle.com/en/database/oracle/oracle-database/19/ostmg/performance-scability-diskgroup.html#GUID-5AC1176D-D331-4C1C-978F-0ECA43E0900F).

Review the ASM documentation in the relevant [SAP Installation Guide for Oracle][https://help.sap.com/viewer/nwguidefinder].

### Add space to ASM and Azure disks

You can either extend Oracle ASM disk groups by adding extra disks or extending current disks. We recommend that you add extra disks rather than extending existing disks. Review these MOS articles and the MOS Notes 1684112.1 and 2176737.1.

ASM adds a disk to the disk group:

`asmca -silent -addDisk -diskGroupName DATA -disk '/dev/sdd1'`

ASM automatically rebalances the data. To check rebalancing, run this command:

`ps -ef | grep rbal`

`oraasm 4288 1 0 Jul28 ? 00:04:36 asm_rbal_oradb1`

To learn more, see:

- [Resize ASM Disk Groups Between Multiple Zones (aemcorp.com)](https://www.aemcorp.com/managedservices/blog/resizing-asm-disk-groups-between-multiple-zones)
- [RESIZING - Altering Disk Groups (oracle.com)](https://docs.oracle.com/en/database/oracle/oracle-database/21/ostmg/alter-diskgroups.html#GUID-6AEFFA72-7BDC-4AA8-8667-8417AAF3DAC8)

### Monitor SAP on Oracle ASM systems on Azure

Run an Oracle Automatic Workload Repository (AWR) report as the first step when you troubleshoot a performance problem. Disk performance metrics are detailed in the AWR report.

You can monitor disk performance from inside Oracle Enterprise Manager and via external tools. For more information, see:

- [Using Views to Display Oracle ASM Information](https://docs.oracle.com/en/database/oracle/oracle-database/19/ostmg/views-asm-info.html#GUID-23E1F0D8-ECF5-4A5A-8C9C-11230D2B4AD4)
- [ASMCMD Disk Group Management Commands (oracle.com)](https://docs.oracle.com/en/database/oracle/oracle-database/19/ostmg/asmcmd-diskgroup-commands.html#GUID-55F7A91D-2197-467C-9847-82A3308F0392)

OS level monitoring tools can't monitor ASM disks because there's no recognizable file system. Free space monitoring must be done from within Oracle.

## Azure NetApp Files with Oracle dNFS

The combination of Azure VMs and Azure NetApp Files is a robust and proven combination implemented by many customers on an exceptionally large scale.

Databases of 100+ TB are already running productive on this combination. To start, see the detailed blog on how to set up this combination:

- [Deploy SAP AnyDB (Oracle 19c) with Azure NetApp Files - Microsoft Tech Community](https://techcommunity.microsoft.com/t5/running-sap-applications-on-the/deploy-sap-anydb-oracle-19c-with-azure-netapp-files/ba-p/2064043)

For more general information, see:

- [Solution architectures using Azure NetApp Files](../../azure-netapp-files/azure-netapp-files-solution-architectures.md#oracle)
- [Solution architectures using Azure NetApp Files](../../azure-netapp-files/azure-netapp-files-solution-architectures.md#sap-anydb)

Mirror Log is required on dNFS Azure NetApp Files production systems.

Even though Azure NetApp Files is highly redundant, Oracle still requires a mirrored `redo-logfile` volume. The recommendation is to create two separate volumes and configure `origlogA` together with `mirrlogB` and `origlogB` together with `mirrlogA`. In this case, you make use of a distributed load balancing of the `redo-logfiles`.

We don't recommend the mount option `nconnect` when the dNFS client is configured. dNFS manages the IO channel and makes use of multiple sessions. This option is obsolete and can cause many issues. The dNFS client ignores the mount options and handles the IO directly.

Both NFS versions (v3 and v4.1) with Azure NetApp Files are supported for the Oracle binaries, data- and log-files. We highly recommend that you use the Oracle dNFS client for all Oracle volumes.

We recommend the following mount options:

| NFS version | Mount options |
|--|--|
| NFSv3 | rw,vers=3,rsize=262144,wsize=262144,hard,timeo=600,noatime |
| NFSv4.1 | rw,vers=4.1,rsize=262144,wsize=262144,hard,timeo=600,noatime |

### Azure NetApp Files backup

With Azure NetApp Files, some key features are available like consistent snapshot-based backups, low latency, and remarkably high performance. From version 6 of the AzAcSnap tool [Azure Application Consistent Snapshot tool for Azure NetApp Files](../../azure-netapp-files/azacsnap-get-started.md), you can configure Oracle databases for consistent database snapshots.

Those snapshots remain on the actual data volume and must be copied away by using Azure NetApp Files cross-region replication (CRR) or other backup tools. For more information, see [Cross-region replication of Azure NetApp Files](../../azure-netapp-files/cross-region-replication-introduction.md).

## Oracle configuration guidelines for SAP installations in Azure VMs on Windows

SAP on Oracle on Azure also supports Windows. The recommendations for Windows deployments are:

* We recommend the following Windows releases:

  * Windows Server 2022 (only from Oracle Database 19.13.0 on)
  * Windows Server 2019 (only from Oracle Database 19.5.0 on)

* Recognize that ASM has no support on Windows. Use Windows Storage Spaces to aggregate disks for optimal performance.
* Install the Oracle Home on a dedicated independent disk. (Don't install Oracle Home on the `C:\` drive.)
* Format all disks as New Technology File System.
* Follow the Windows Tuning guide from Oracle and enable large pages, lock pages in memory, and make other Windows specific settings.

At the time of writing ASM for Windows, customers on Azure aren't supported. Currently, the SAP Software Provisioning Manager for Windows doesn't support ASM.

## Azure Infra: VM throughput limits and Azure Disk storage options

### Current recommendations for Oracle Storage

* **Azure premium storage**: Most customers deploy on ASM with premium storage.
* **Azure NetApp Files**: VLDB customers, often with single Oracle databases larger than 50 TB, typically use Azure NetApp Files and Storage Snapshot capabilities of Azure NetApp Files for backup and restore.
* [Managed disk bursting - Azure VMs](/azure/virtual-machines/disk-bursting).
* **Azure Write Accelerator**: Used for the case that the Oracle redo log is based on Premium SSD v1 disks.
* **Online disk extension**: Fully supported for premium storage v1 and works with ASM.

You can improve log write times on Azure M-Series VMs by enabling Azure Write Accelerator. Enable Azure Write Accelerator for the Azure Premium Storage disks used by the ASM disk group for <u>online redo log files</u>. For more information, see [Write Accelerator](/azure/virtual-machines/how-to-enable-write-accelerator).

Using Write Accelerator is optional, but you can enable it if the AWR report indicates that log write times are higher than expected.

### Azure VM throughput limits

Each Azure VM type has limits for CPU, Disk, Network, and RAM.

Follow these recommendations when you select a VM type:

* Ensure that the disk throughput and IOPS are sufficient for the workload and at least equal to the aggregate throughput of the disks.
* Consider enabling paid *bursting*, especially for redo log disks.
* Understand that for Azure NetApp Files, the network throughput is important because all storage traffic is counted as "Network" rather than disk throughput.
* Review this blog for Network tuning for M-series. For more information, see [Optimizing Network Throughput on Azure M-series VMs HCMT](https://techcommunity.microsoft.com/t5/running-sap-applications-on-the/optimizing-network-throughput-on-azure-m-series-vms/ba-p/3581129).
* Review [Architectures for Oracle Database Enterprise Edition on Azure](/azure/virtual-machines/workloads/oracle/oracle-design) to learn how to use an AWR report to select the correct Azure VM.
* Learn about Azure Intel Ev5 [Edv5 and Edsv5-series - Azure VMs](/azure/virtual-machines/easv5-eadsv5-series).
* Learn about Azure AMD Eadsv5 [Easv5 and Eadsv5-series - Azure VMs](/azure/virtual-machines/easv5-eadsv5-series#eadsv5-series).
* Learn about Azure M-series/Msv2-series [M-series - Azure VMs](/azure/virtual-machines/m-series) and [Msv2/Mdsv2 Medium Memory Series - Azure VMs](/azure/virtual-machines/msv2-mdsv2-series).
* Learn about Azure Mv2 [Mv2-series - Azure VMs](/azure/virtual-machines/mv2-series).

## Backup and restore

For backup/restore functionality, the SAP BR*Tools for Oracle are supported in the same way as they are on bare metal and Hyper-V. RMAN is also supported for backups to disk and restores from disk.

For more information about how you can use Azure Backup and Recovery services for Oracle databases, see [Azure Backup service](../../backup/backup-overview.md) and [Back up and recover an Oracle Database on an Azure Linux VM using Azure Backup](/azure/virtual-machines/workloads/oracle/oracle-database-backup-azure-backup).

## High availability

Oracle Data Guard is supported for high availability and disaster recovery purposes. To achieve automatic failover in Data Guard, you need to use Fast-Start Failover (FSFA). The Observer functionality (FSFA) triggers the failover. If you don't use FSFA, you can only use a manual failover configuration. For more information, see [Implement Oracle Data Guard on an Azure Linux VM](/azure/virtual-machines/workloads/oracle/configure-oracle-dataguard).

For disaster recovery aspects of Oracle databases in Azure, see [Disaster recovery for an Oracle Database 12c database in an Azure environment](/azure/virtual-machines/workloads/oracle/oracle-disaster-recovery).

## HugePages and large Oracle SGA configurations

VLDB SAP on Oracle on Azure deployments apply SGA sizes in excess of 3 TB. Modern versions of Oracle handle large SGA sizes well and significantly reduce IO. Review the AWR report and increase the SGA size to reduce read IO.

As general guidance, configure Linux HugePages to approximately 75% of the VM RAM size. You can set the SGA to 90% of the HugePage size. An approximate example is M192ms VM with 4 TB of RAM would have HugePages set approximately at 3 TB. You can set the SGA to a value a little less such as 2.95 TB.

Large SAP customers running on High Memory Azure VMs greatly benefit from HugePages described in
[Oracle HugePages configuration steps](https://www.carajandb.com/en/blog/2016/7-easy-steps-to-configure-hugepages-for-your-oracle-database-server/).

Non-Uniform Memory Access (NUMA) systems `vm.min_free_kbytes` should be set to `524288` (number of NUMA nodes). To learn more, see [Oracle Linux: Recommended value of vm.min_free_kbytes Kernel Tuning Parameter (Doc ID 2501269.1...](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=79485198498171&parent=EXTERNAL_SEARCH&sourceId=HOWTO&id=2501269.1&_afrWindowMode=0&_adf.ctrl-state=mvhajwq3z_4).

## Training resources on Oracle Automatic Storage Management (ASM)

For Oracle DBAs who aren't familiar with Oracle ASM, follow the training materials and resources here:

- [SAP on Oracle with ASM on Microsoft Azure - Part1](https://techcommunity.microsoft.com/t5/running-sap-applications-on-the/sap-on-oracle-with-asm-on-microsoft-azure-part1/ba-p/1865024)
- [Oracle19c DB ASM installation on [Oracle Linux 8.3 \| Grid \| ASM \| UDEV \| OEL 8.3 \| VMware]](https://www.youtube.com/watch?v=pRJgiuT-S2M)
- [ASM Administrator's Guide (oracle.com)](https://docs.oracle.com/en/database/oracle/oracle-database/19/ostmg/automatic-storage-management-administrators-guide.pdf)
- [Oracle for SAP Development Update (May 2022)](https://www.oracle.com/a/ocom/docs/sap-on-oracle-dev-update.pdf)
- [Performance and Scalability Considerations for Disk groups (oracle.com)](https://docs.oracle.com/en/database/oracle/oracle-database/19/ostmg/performance-scability-diskgroup.html#GUID-BC6544D7-6D59-42B3-AE1F-4201D3459ADD)
- [Migrating to Oracle ASM with Oracle Enterprise Manager](https://docs.oracle.com/en/database/oracle/oracle-database/19/ostmg/admin-asm-em.html#GUID-002546C0-7D5F-46E9-B3AD-CDCFF25AFEA0)
- [Using Recovery Manager (RMAN) to migrate to ASM](https://theoraclementor.wordpress.com/2013/07/07/using-rman-to-migrate-to-asm/)
- [What is Oracle ASM to Azure IaaS?](https://www.red-gate.com/simple-talk/databases/oracle-databases/what-is-oracle-asm-to-azure-iaas/)
- [ASM Command-Line Utility (ASMCMD)](https://docs.oracle.com/cd/B19306_01/server.102/b14215/asm_util.htm)
- [Useful asmcmd commands - DBACLASS](https://dbaclass.com/article/useful-asmcmd-commands-oracle-cluster/)
- [Installing and Configuring Oracle ASMLIB Software](https://docs.oracle.com/en/database/oracle/oracle-database/19/ladbi/installing-and-configuring-oracle-asmlib-software.html#GUID-79F9D58F-E5BB-45BD-A664-260C0502D876)

## Oracle Linux utilities

Oracle Linux provides a useful GUI management utility:

- Oracle web console [Oracle Linux: Install Cockpit Web Console on Oracle Linux](https://docs.oracle.com/en/operating-systems/oracle-linux/8/obe-cockpit-install/index.html#want-to-learn-more).
- Upstream [Cockpit Project](https://cockpit-project.org/).

Oracle Linux has a new package management tool – DNF

- [Oracle Linux 8: Package Management made easy with free videos](https://blogs.oracle.com/linux/oracle-linux-8%3a-package-management-made-easy-with-free-videos)
- [Oracle Linux 8 Managing Software on Oracle Linux - Chapter 1 Yum DNF](https://docs.oracle.com/en/operating-systems/oracle-linux/8/software-management/dnf.html)

You can test and benchmark memory and NUMA configurations with Oracle Real Application Testing:

- [Oracle Real Application Testing: What Is It and How Do You Use It?](https://www.aemcorp.com/managedservices/blog/oracle-real-application-testing-rat-what-is-it-and-how-do-you-use-it)
- [Oracle ASM in Azure corruption](http://dbaharrison.blogspot.com/2017/07/oracle-asm-in-azure-corruption-follow-up.html)
- [Data corruption on Hyper-V or Azure when running Oracle ASM - Red Hat Customer Portal](https://access.redhat.com/solutions/3114361)
- [Set up Oracle ASM on an Azure Linux VM](/azure/virtual-machines/workloads/oracle/configure-oracle-asm)

## Related content

To learn more about Oracle on Windows, see:

- [Overview of Windows Tuning (oracle.com)](https://docs.oracle.com/en/database/oracle/oracle-database/19/ntqrf/overview-of-windows-tuning.html#GUID-C0A0EC5D-65DD-4693-80B1-DA2AB6147AB9)
- [Postinstallation Configuration Tasks on Windows (oracle.com)](https://docs.oracle.com/en/database/oracle/oracle-database/19/ntqrf/postinstallation-configuration-tasks-on-windows.html#GUID-ECCA1626-A624-48E4-AB08-3D1F6419709E)
- [SAP on Windows Presentation (oracle.com)](https://www.oracle.com/technetwork/topics/dotnet/tech-info/oow2015-windowsdb-bestpracticesperf-2757613.pdf)
- [2823030 - Oracle on MS WINDOWS Large Pages](https://launchpad.support.sap.com/#/notes/2823030)

To learn more about SAP Azure VM DBMS deployments, see:

- [Considerations for Azure VMs DBMS deployment for SAP workload](dbms-guide-general.md)
