---
title: Plan and Analyze VMware Migrations to Azure Using Azure Copilot Migration Agent
description: Learn how to plan and analyze VMware migrations to Azure using Azure Copilot Migration Agent and Azure Migrate data. Explore inventory, readiness, ROI, and landing zone design before migration execution.
ms.topic: how-to
author: ankurgupta2212
ms.author: ankug
ms.service: azure-migrate
ms.reviewer: v-uhabiba
ms.date: 01/22/2026
monikerRange:
# Customer intent: Customers plan and analyze VMware migrations to Azure using Azure Copilot Migration Agent, including inventory review, readiness assessment, cost and ROI analysis, and Azure landing zone design—before migration execution in Azure Migrate.
---

# Plan and analyze VMware migrations using Azure Copilot Migration Agent

This tutorial shows you how to plan and analyze a VMware migration to Azure by using Azure Copilot Migration Agent with Azure Migrate data. You use the agent to explore migration paths, review discovered inventory, analyze costs and readiness, and design an Azure landing zone.

## How to manage access to Agents 

To manage access to Agents (preview) in Azure Copilot, an administrator can request or remove access at the tenant level. For more information, see Manage access to Agents (preview) in Azure Copilot.

>[!NOTE]
> Azure Copilot Migration Agent supports migration planning and analysis only. Migration execution, including replication and cutover, is completed in the Azure Migrate portal.

## Prerequisites

Before you begin, ensure you have:

- An Azure subscription with permissions to use Azure Migrate
- Access to the Azure portal and Azure Migrate
- Access to VMware vCenter

### Step 1: Launch the migration Agent and define migration goal
 
**Action**: Sign in to the Azure portal and open Azure Migrate. Launch Azure Copilot Migration Agent.
**Prompt**: Help me explore migration paths for VMware workloads moving to Azure quickly.
**Migration Agent Response**: Explains journey steps, offers step-by-step guidance. 

The agent outlines the migration planning journey and suggests next steps based on your goal.

### Step 2: Choose discovery method

Choose one of the following discovery methods to provide inventory data to the agent.

**Option 1: Quick discovery using RVTools**

Use this option if you want a fast, lightweight inventory.

1. Run RVTools against your VMware environment.
1. Export the inventory to an .xlsx file.
1. Upload the file in the Migration Agent chat.

**Prompt**: Import the RVTools file.
**Migration agent response**: Inventory summary, option to proceed to business case. 

The agent summarizes the discovered inventory and confirms that you can proceed with analysis, such as business case creation.

**Option 2: Comprehensive discovery using Azure Migrate appliance**

Use this option if you want continuous discovery and performance-based insights.

1. Generate a project key in Azure Migrate.
1. Deploy the Azure Migrate appliance (OVA) in VMware.
1. Register the appliance using the project key.

After deployment, confirm discovery with the agent.

**Prompt**: I have deployed the appliance. Can you verify?
**Migration agent response**: Connection/discovery verification, workload summary, advisement on performance data collection. 

The agent verifies connectivity, confirms discovery status, and summarizes the workloads detected. It also advises collecting performance data when applicable.

**Step 3: Review and summarize inventory**

After inventory data is available, ask the agent to analyze and organize your workloads.

**Prompt**: Summarize the discovered workloads.
**Migration agent response**: Categorized summary, next steps suggestion. 

The agent provides a categorized inventory summary and suggests relevant next analysis steps.

**Step 4: Analyze ROI & Business case**

Use the agent to review ROI, cost drivers, and migration scenarios.

**Prompt**: Provide the ROI analysis summary for migration.
**Migration agent response**: Business case report (savings, cost breakdowns, drivers), report export. 

**Optional prompt**: How are the savings achieved? Compare the ROI of moving to AVS instead of Azure VMs. 
**Migration agent response**: Cost driver details, Azure VMs vs. AVS comparison. 

The agent generates a business case with cost estimates, savings drivers, and comparison details. You can also compare different target options, such as Azure Virtual Machines versus Azure VMware Solution (AVS).

**Step 5: Assess Azure readiness of workloads**

Evaluate whether your VMware workloads are ready to move to Azure.

**Prompt**: What is the readiness of my workloads for migrating to Azure VMs?
**Migration agent response**: Triggers assessment, notification on completion. 
**Follow-up prompt**: Summarize the assessment for my workloads. 
**Migration agent reponse**:  Readiness report, blockers, sizing, cost estimates, recommendations. 

The agent reports readiness status, blockers, sizing recommendations, and estimated costs.

**Step 6: Create and configure Azure landing zone**
 
Use the agent to reason about Azure landing zone architecture based on your requirements.

1. Ask the agent to explain landing zones.
1. Provide subscription and governance details.
1. Share region, compliance, and networking requirements.

**Prompt: What is a landing zone?** 
**Migration agent response**: Concept explanation, subscription ID request. 

**Prompt**: Here are my subscription IDs: `X` for management and identity, `Y` for connectivity. 
**Migration agent response**: Confirms management structure, asks networking preferences. 

**Prompt**: We are only in Central India. Our compliance requires Palo Alto firewall. 
**Migration agent response**: Architecture recommendation, downloadable template (e.g., Terraform), policies, monitoring, identity setup.
 
The agent recommends an architecture aligned to your input and may provide deployable templates (such as Terraform), along with guidance on identity, networking, policies, and monitoring.

**Step 7:  Continue rest of the steps in the Azure Migrate portal**
 
To execute the migration, continue in the Azure Migrate portal.
- Perform replication, test migrations, and cutover in Azure Migrate.
- Use Azure Copilot Migration Agent to continue clarifying concepts and reviewing planning data.

For execution guidance, see [Server migration overview in Azure Migrate](server-migrate-overview.md).
