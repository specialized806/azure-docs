---
title: Simplified End-to-End Migrations Experience in Azure Migrate
description: Learn how the Azure Copilot migration agent (preview) helps you plan and analyze migrations using Azure Migrate data, providing insights on readiness, migration strategy, ROI, and landing zone options.
ms.topic: how-to
author: dhananjayanr98 
ms.author: dhananjayanr
ms.service: azure-migrate
ms.reviewer: v-uhabiba
ms.date: 03/13/2026
monikerRange: migrate 
Customer intent: This article is intended to guide users on leveraging the Azure Copilot migration agent for planning and analyzing migrations. It covers how the agent utilizes Azure Migrate data, outlines supported migration scenarios, details available capabilities, and provides example interactions to help users understand and execute migration processes effectively.
---

# Execute end-to-end server migrations in Azure Migrate 

You can migrate servers to Azure using the new Azure Migrate experience, which provides a streamlined, end-to-end workflow from discovery through migration execution and progress tracking until the migration is complete.

This article explains how to migrate servers using the new experience, including how to start migration workflows, perform required tasks, and monitor migration progress for supported workloads during the execution phase.

In this article, you learn how to:

- Start migration execution for discovered servers.
- Complete the required configuration steps for your source environment.
- Track execution status across Preparation, Testing, and Completion.
- Understand when you must use the classic portal experience.
 
>[!NOTE]
>You can now identify capabilities that are available only in the classic experience and switch to the classic portal to use them when needed. 

## Prerequisites  

Before you begin, ensure the following:

1. Install the Azure Migrate appliance.
1. Complete server discovery using the appliance.
1. The Azure Migrate appliance is required to get the end-to-end experience, from discovery through execution tracking, for all supported source environments.
1. For more information, see the following tutorials
    - [Tutorial: Discover servers running in a VMware environment with Azure Migrate](tutorial-discover-vmware.md).
    - [Tutorial: Discover servers running on Hyper-V with Azure Migrate: Discovery and assessment](tutorial-discover-hyper-v.md).
    - [Discover physical servers and servers running in AWS and GCP](tutorial-discover-physical.md)

### When to use the classic portal experience

The following capabilities are currently available only in the classic portal experience:

- ISV-linked projects.
- Agent-based and Hyper-V migrations started by using the replication appliance directly (without completing discovery through Azure Migrate). These servers won’t appear in the new end-to-end tracking experience (not recommended).
- Hyper-V infrastructure that monitor replication provider health and status.
- Initial replication Progress % for servers.
- Properties pane to view Recovery services fault.

>[!NOTE]
> These capabilities are currently available only in the classic portal. To switch, go to Execute > Migrations and use the link on the page to open the classic experience.

### Start execution in the new experience

To start a streamlined, end‑to‑end server migration to Azure using the new Azure Migrate experience, follow these steps: 

1. In an **Azure Migrate** project, select **Execute** > **Migrations**.
1. On the Migrations pane, select **Start execution**. 
1. On the **Specify intent** pane, select **Servers (or Virtual machines (VMs))** and then select **Azure VM** as the target.
1. You can select a pre‑created assessment, which is now supported for Physical and Hyper‑V servers in the new experience, or manually select servers from the discovered inventory.

#### Discovery method

Select the appliance that matches your source environment (VMware, Hyper-V, or Physical). Only appliances that are already configured are available for selection.

1. **VMware**: Select **Agentless** (recommended) or **Agent-based**, and then select **Next**
1. **Hyper-V**: Install the replication provider on the Hyper-V hosts by using the link shown in the pane. After configuration, continue to the next step.
1. **Physical servers (and VMware agent-based)**: Set up the replication appliance (covered in the next step), and then select Continue.

#### Workloads and security settings

Use the Workloads section to select servers you want to replicate and selelct the virtual machine security type.

  1. In **Workloads**, select the servers to replicate. You can replicate up to ten servers in parallel.
  1. Select the security type:
      - Standard
      - Trusted launch virtual machines.
  
#### Configure target settings

Configure the target, compute, disk, and tagging settings before you start migration execution.

For **VMware agent-based and physical servers**: 

1. If the replication appliance is already configured, select it.
1. If this is your first agent‑based migration in the project, set up and register the replication appliance by following the steps in the [migration tutorial](tutorial-migrate-physical-virtual-machines.md#simplified-experience-recommended). For VMware agent-based migrations, select the vCenter Server that manages the VMs and choose credentials for Mobility service installation or select credential-less to install the agent manually.
1. For VMware agent‑based migrations, select the vCenter Server that manages the VMs, and choose credentials for Mobility service installation, or select Credential‑less to install the agent manually.

Complete the **Target, Compute, Disks**, and **Tags** settings, review your configuration, and then start execution. These settings are unchanged from the classic portal experience.

## Track migrations

This section explains how to monitor server migrations in the new Azure Migrate experience, including viewing execution stages, tracking status, and taking required actions during each phase.

>[!IMPORTANT]
> Migrations that you start in the classic experience appear in the new Azure Migrate experience after you refresh the page or perform an action on replication or migration in the classic portal.

To track migration progress and manage actions for your servers, follow the steps:

1. To track migrations, go to **Execute** > **Migrations**. Use **View by applications** or **View by workloads** to switch how items are grouped.
2. Execution progress is shown in **Execution stage** and **Execution status**:
    - **Execution stage**: Preparation, Testing, or Completion.
    - **Execution status**: In progress, In error, Action pending, or Completed.
3. Select a server to open the details view. Use the stage drop-down menus to review status and take actions.
4. **Preparation**: Initial replication is running. Typical task - **Replication of data** (initial replication).
5. **Testing**: Initial replication is complete and delta replication is in progress. Recommended tasks - **Test migration**, then **Clean up test migration**. You can also skip testing and start migration from the Completion stage.
6. **Completion**: Start and finalize the migration. Typical tasks: **Migrate**, then **Complete migration**, shut down and clean up source resources to finish the migration.

### Understand context pane

Use context pane to get a quick overview of migration status. Context pane provide a quick overview of the number of workloads in each stage and highlight how many require attention. These pane are read-only and don’t support any actions.


 

 
