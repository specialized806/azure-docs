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

This article shows you how to use the new Execute > Migrations experience in Azure Migrate to start replication or migration, complete required tasks, and track progress until your servers are migrated to Azure.

In this article, you learn how to:

- Start migration execution for discovered servers.
- Complete the required configuration steps for your source environment.
- Track execution status across Preparation, Testing, and Completion.
- Understand when you must use the classic portal experience.
 
>[!NOTE]
> Some execution capabilities are still available only in the classic Azure Migrate portal experience. This article calls out those scenarios and how to switch to classic when needed. 

## Prerequisites  

Before you start, install the Azure Migrate appliance and complete server discovery. The appliance is required for the end-to-end experience (discovery through execution tracking) for all supported source environments.

Add links
add links
add links

**Redirect to classic Portal:** 

Some of the execution capabilities are currently only available via the classic portal experience such as 

- ISV-linked projects 

- Executing agent-based and Hyper-V migrations directly by discovering and migrating servers via the replication appliance without completing discovery via Azure Migrate experience (not recommended). These servers will not be available for tracking in the new end to end experience. Please complete discovery via the Azure migrate appliance first for an enhanced end to end experience. 

- To view Hyper-V Infrastructure blades for monitoring the replication provider health/status (This will be brought to new E2E in upcoming release)

Add image

- Initial replication Progress % for servers (This will be brought to new E2E in upcoming release) 
- Properties blade to view Recovery services fault (This will be brought to new E2E in upcoming release) 

 You can choose to redirect to the classic portal experience by navigating to Execute > Migrations blade on the left TOC using the link available on the page to navigate to the classic experience. The above capabilities are available on the classic Portal. 
Add image 
 

Note: The classic experience is not blocked/stopped. Customers can still use classic portal for their workflows, and any change will be announced well in advance. 

**Executing Migrations in New Experience:** 

In Execute Migrations, 

1.  Select Start Execution 

Add image

In Specify Intent blade, Select Servers or Virtual Machines (VM) and Azure VM as the Target. You can choose to select a pre created assessment (Now works for physical and Hyper-V as well in the new experience) or manually choose the inventory from the discovered servers.  

**Under Discovery Method:** Select the appropriate appliance configured based on the source environment and method (VMWare, Physical, Hyper-V). Only the appliances already configured will be showed here.  

- For VMWare, you can select either Agentless (recommended) or Agent-based method and click next. 
- For Hyper-V, you need to install the replication provider on the Hyper-V hosts to proceed with replication via the link shown in the blade. Proceed to next step after configuring the provider.  
- For Physical/VMware agent-based, you need to set up the replication appliance (covered in next step), click continue 


Add image

Add image

2.  In the Workloads section, select the servers you want to replicate. You can select up to 10 servers for replication in parallel. Select the security type (Standard or Trusted Launch Virtual Machines).  

Add image

 **2a. For VMware Agent-based/Physical servers,** select the replication appliance to migrate your servers if already configured. If you are executing migrations for the first time via agent-based migrations in the project, click set up the replication appliance and complete the registration as per steps provided in this [documentation](https://learn.microsoft.com/en-us/azure/migrate/tutorial-migrate-physical-virtual-machines?view=migrate#simplified-experience-recommended). For VMWare agent-based, you need to select the vCenter server that is managing the VMs to be migrated (Not required for physical) and select the appropriate credentials for mobility agent installation (choose credential less for manual agent installation). 
 
Add image 

3.  Complete the Target, Compute, Disk, Tags settings (No changes from classic portal experience) and review and start execution. 

Add image
**Tracking Migrations** 

**Note:** For existing migrations, you had already initiated on the classic experience, these would be tracked in the new portal only after refresh or by performing any actions on the existing replications/migrations in the classic portal. 

You can track the existing migrations by navigating to Execute, clicking on Migrations. You can also track workloads that were executed as part of waves here along with other server migrations executed directly as discussed in the previous section. You can either track the same by choosing View by applications/View by workloads on the top right corner. 

Add image

The Execution progress is tracked under 3 stages **Preparation, Testing and Completion** and is tracked under the column “**Execution stage**”.  For any failures or action is pending in any stage it will be appropriately tracked under the “**Execution status”** column as “**In progress” “In error” “Action Pending” and “Completed”.**  

You can click on any of the servers to view the status and take appropriate actions from the specific blades using the drop down shown in the blades (See Image below). 

Add image


- **Preparation: **Workloads that are successfully enabled for replication and is in progress of Initial replication will be grouped under Preparation stage until the Initial replication or “replication of data “is completed. You can take actions for this stage by clicking on the Preparation drop down in the drill down blade shown below. 

Steps/Tasks under this stage: Replication of data (initial replication). 

- **Testing: **Workloads for which Initial replication is completed and delta replication in progress will be tracked here, and you can do test migrations (recommended) and clean up test operations by clicking on the Testing drop down in the drill down blade as shown below. you can skip and directly start migrations from the completion drop downs in the drill down blade.  

Steps/tasks under this stage: Test Migration, Clean up test migration 

- **Completion: **This can be done post preparation (replication of data) is completed and workloads are in Testing status or post-test, and clean-up operations are completed by starting migrations for them under completion drop down in the drop-down blade as shown below. 

Steps/Tasks under this stage: Migration, Complete Migration (This is to shut down, cleanup of the VMs to ensure that the end-to-end migration is complete) 

  **Context Blades:** 

Add image

The context blades are intended to quickly view the count of workloads in each phase along with how many workloads needs attention. You can’t take any actions from those blades and only for quick overview the migrations. 

Add image
 
**Others:** 

 **Jobs **and **Events** are placed under Manage section of the Project in the left side TOC Pane. 

 
