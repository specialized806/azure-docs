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

# Simplify server migrations using the Azure Migrate end‑to‑end experience

This article explains how to use the new experience in Azure portal. It explains how to start migration workflows, complete the required tasks, and track migration progress for supported workloads during the execution phase.

In this article, you learn how to:

- Start migration execution for discovered servers.
- Complete the required configuration steps for your source environment.
- Track execution status across Preparation, Testing, and Completion.
- Understand when you must use the classic portal experience.
 
## Prerequisites  

Before you begin, ensure the following:

- Install the Azure Migrate appliance. The Azure Migrate appliance is required to get the end-to-end experience, from discovery through execution tracking, for all supported source environments.
- Complete server discovery using the appliance.
- For more information, see the following tutorials
    - [Tutorial: Discover servers running in a VMware environment with Azure Migrate](tutorial-discover-vmware.md).
    - [Tutorial: Discover servers running on Hyper-V with Azure Migrate: Discovery and assessment](tutorial-discover-hyper-v.md).
    - [Discover physical servers and servers running in AWS and GCP](tutorial-discover-physical.md)

    >[!NOTE]
    > Use the link on the Migrations page to switch to the classic portal experience for discovering and executing agent‑based and Hyper‑V migrations that use the replication appliance without the Azure Migrate appliance. Servers migrated this way aren’t tracked in the new end‑to‑end experience. To take full advantage of the new experience, we recommend starting discovery by using the Azure Migrate appliance.

## Execute migrations

1. In Azure Migrate project, go to **Execute** > **Migrations**, and then select **Start execution**.
1. On the **Specify intent** pane, select **Servers** or **Virtual machines (VMs)**, and choose Azure VM as the target. You can either select a pre‑created assessment or manually select servers from the discovered inventory.
1. Under **Discovery method**, select the appliance that matches your source environment **(VMware, Hyper‑V, or Physical)**. Only appliances that are already configured appear in the list.

    - **VMware agentless**: Select the **VMware appliance**, select **Agentless migration**, and then select **Continue**.
    - **Hyper-V**: Select the Hyper-V appliance. If the replication provider isn’t already installed, install it on the Hyper-V hosts to enable replication. After you configure the provider by using the provided link, continue to the next step.
    - **Physical servers and VMware agent-based**: Set up the replication appliance (covered in the next step), and then select **Continue**.
1. In **Workloads**, select the servers that you want to replicate, and configure the required settings.

    - For **VMware agent-based and physical servers**, select the **replication appliance** if it’s already configured. If this is the first time you’re running agent-based migrations in the project, select **Set up the replication appliance** and complete the registration by following the steps from [tutorial migrate physical vitural machines](tutorial-migrate-physical-virtual-machines.md#simplified-experience-recommended).
    
1. Complete the remaining configuration for **Target, Compute, Disk**, and **Tags**, review your settings, and then select **Execute migration**. The selected servers move into execution and are available for tracking.

## Track migrations

This section explains how to track server migrations in the new Azure Migrate experience, including viewing execution stages, tracking status, and taking required actions during each phase.

To track migration progress and manage actions for your servers, follow the steps:

1. To track migrations, go to **Execute** > **Migrations**. Use **View by applications** or **View by workloads** to switch how items are grouped.
2. Execution progress is shown in **Execution stage** and **Execution status**:
    - **Execution stage**: Preparation, Testing, or Completion.
    - **Execution status**: In progress, In error, Action pending, or Completed.
3. Select a server to open the details view. Use the stage drop-down menus to review status and take actions.
4. The Execution progress is tracked across three stages in the Execution stage:
    - **Preparation**: Servers that are enabled for replication remain in the Preparation stage while initial replication (data replication) is in progress. After initial replication completes, the servers move to the Testing stage.
    - **Testing**: Servers for which initial replication is complete and delta replication is in progress appear in this stage. Use this stage to run test migrations (recommended). Ensure that you clean up test migrations after validation. You can skip the Testing stage and start migration directly by using the actions available in the completion drop-downs.
    - **Completion**: Servers for which testing is completed or skipped appear in this stage. From the Completion drop-down menu (available when you select a server), you can start migration and complete migration.
    After migration finishes, ensure that you select Complete migration to clean up resources and shut down the source virtual machines.

## Related content

[Learn more][Agentless and Agent-based migration methods](server-migrate-overview.md) about different migration methods in Azure Migrate. 