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

# Execute server migrations in the Azure Migrate end-to-end experience 

You can migrate servers to Azure using the new Azure Migrate experience, which provides a streamlined, end-to-end workflow from discovery through migration execution and progress tracking until migration is complete.

This article explains how to migrate servers using the new experience, including how to start migration workflows, perform required tasks, and monitor migration progress for supported workloads during the execution phase.

In this article, you learn how to:

- Start migration execution for discovered servers.
- Complete the required configuration steps for your source environment.
- Track execution status across Preparation, Testing, and Completion.
- Understand when you must use the classic portal experience.
 
>[!NOTE]
> Some execution capabilities are still available only in the classic Azure Migrate portal experience. This article calls out those scenarios and how to switch to classic when needed. 

## Prerequisites  

Before you begin, install the Azure Migrate appliance and complete server discovery. The appliance is required for the end-to-end experience (discovery through execution tracking) for all supported source environments. For more information, see;

- [Tutorial: Discover servers running in a VMware environment with Azure Migrate](tutorial-discover-vmware.md).
- [Tutorial: Discover servers running on Hyper-V with Azure Migrate: Discovery and assessment](tutorial-discover-hyper-v.md).
- [Discover physical servers and servers running in AWS and GCP](tutorial-discover-physical.md)

### When to use the classic portal experience

The following capabilities are currently available only in the classic portal experience:
- ISV-linked projects.
- Agent-based and Hyper-V migrations started by using the replication appliance directly (without completing discovery through Azure Migrate). These servers won’t appear in the new end-to-end tracking experience (not recommended).
- Hyper-V infrastructure blades that monitor replication provider health and status - will be available in the new experience in a future release.
- Initial replication Progress % for servers - will be available in new E2E in the upcoming release.
- Properties blade to view Recovery services fault - will be available in the new E2E in upcoming release. 

>[!NOTE]
> - These capabilities are currently available only in the classic portal. To switch, go to Execute > Migrations and use the link on the page to open the classic experience.
> - The classic experience is still available. Any future change will be announced in advance.

### Start execution in the new experience

In the new Azure Migrate experience, you can start executing server migrations to Azure using a streamlined, end‑to‑end workflow.

1. In your Azure Migrate project, select **Execute** > **Migrations**.
1. Select **Start execution**. 
1. On **Specify intent**, select **Servers (or Virtual machines (VMs))** and then select **Azure VM** as the target.
1. Select an assessment to use (optional), or select servers from inventory.
1.	Select **Start Execution**. 
1. **Discovery method**: Select the appliance that matches your source environment (VMware, Hyper-V, or Physical). Only appliances that are already configured appear.
    - **VMware**: Select **Agentless** (recommended) or **Agent-based**, and then select **Next**
    - **Hyper-V**: Install the replication provider on the Hyper-V hosts by using the link shown in the blade. After configuration, continue to the next step.
    - **Physical servers (and VMware agent-based)**: Set up the replication appliance (covered in the next step), and then select Continue.
1. In **Workloads**, select the servers to replicate. You can replicate up to 10 servers in parallel.
1. Select the security type - **Standard or Trusted launch virtual machines**.
1. **VMware agent-based and physical servers**: Select the replication appliance if it’s already configured. If this is your first time running agent-based migrations in the project, set up and register the replication appliance by following the steps in the [migration tutorial](tutorial-migrate-physical-virtual-machines.md#simplified-experience-recommended). For VMware agent-based migrations, select the vCenter Server that manages the VMs and choose credentials for Mobility service installation or select credential-less to install the agent manually.
1. Configure **Target, Compute, Disks**, and **Tags**, review your settings, and then start execution. 
1. Complete the Target, Compute, Disk, Tags settings (No changes from classic portal experience) and review and start execution. 

### Track migrations

This section explains how to monitor server migrations in the new Azure Migrate experience, including viewing execution stages, tracking status, and taking required actions during each phase.

>[!NOTE]
> Migrations that you start in the classic experience appear in the new Azure Migrate experience after you refresh the page or perform an action on replication or migration in the classic portal.

1. To track migrations, go to **Execute** > **Migrations**. Use **View by applications** or **View by workloads** to switch how items are grouped.
1. Execution progress is shown in **Execution stage** and **Execution status**:

- **Execution stage**: Preparation, Testing, or Completion.
- **Execution status**: In progress, In error, Action pending, or Completed.
1. Select a server to open the details view. Use the stage drop-down menus to review status and take actions.
1. **Preparation**: Initial replication is running. Typical task - **Replication of data** (initial replication).
1. **Testing**: Initial replication is complete and delta replication is in progress. Recommended tasks - **Test migration**, then **Clean up test migration**. You can also skip testing and start migration from the Completion stage.
1. **Completion**: Start and finalize the migration. Typical tasks: **Migrate**, then **Complete migration**, shut down and clean up source resources to finish the migration.

### Understand context blades

Use context blades to get a quick overview of migration status. Context blades provide a quick overview of the number of workloads in each stage and highlight how many require attention. These blades are read-only and don’t support any actions.

### Related monitoring

**Jobs** and **Events** are available under the **Manage** section of your Azure Migrate project.


 

 
