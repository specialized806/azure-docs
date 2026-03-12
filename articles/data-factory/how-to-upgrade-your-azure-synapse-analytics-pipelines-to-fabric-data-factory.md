---
title: Upgrade your Azure Synapse Analytics pipelines to Fabric
description: Learn how to assess and upgrade your Azure Synapse Analytics pipelines to Fabric Data Factory.
author: ssindhub
ms.author: ssrinivasara
ms.topic: how-to
ms.date: 03/15/2026
ms.custom: pipelines
ai-usage: ai-assisted
---

# Upgrade your Azure Synapse Analytics pipelines to Fabric

Modernizing your workflows in Microsoft Fabric often starts with bringing your existing Azure Synapse Analytics pipelines forward. The built-in migration experience (Preview) helps you assess pipeline readiness, understand compatibility gaps, and migrate supported pipelines into a Fabric workspace—so you can move in a controlled, low-risk way.


## What you can do with the migration experience

With the Synapse pipelines migration experience (Preview), you can:
- Assess pipeline readiness directly in your Synapse workspace.
- See compatibility gaps at the pipeline and activity level.
- Migrate supported pipelines to a Fabric workspace.
- Export results to CSV to plan remediation and phased validation.

## Prerequisites

Before you start:
- You have an **Azure Synapse Analytics workspace** that contains pipelines.
- You have access to a **Microsoft Fabric tenant** and a **Fabric workspace**.
- If you want to preserve your folder structure, **recreate the same folders** in your Fabric workspace first, then migrate folder by folder.


## Step 1: Run an assessment in Azure Synapse Analytics

- In **Azure Synapse Analytics**, open the workspace you want to assess.
- In the **Integrate** hub, select **Migrate to Fabric (Preview)**, then select **Get started**.
- Review the assessment pane. Expand pipelines to see activity-level details.
- Export assessment results as a **.csv** file to support offline planning and remediation (optional)
   
:::image type="content" source="media/how-to-assess-and-upgrade-your-azure-synapse-analytics-pipelines-to-fabric/start-synapse-pipelines-migration-assessment.png" alt-text="Screenshot showing how to run the Azure Synapse Analytics migration assessment." lightbox="media/how-to-assess-and-upgrade-your-azure-synapse-analytics-pipelines-to-fabric/start-synapse-pipelines-migration-assessment.png":::

### Understand assessment statuses

Each pipeline is categorized using one of the following statuses:

| Status | What it means |
|---|---|
| **Ready** | Good to go for migration. |
| **Needs review** | Changes are required before migration. |
| **Coming soon** | Support is in progress; migrate later. |
| **Unsupported / Not compatible** | No equivalent in Fabric; refactor required. |


## Step 2: Select pipelines to migrate

After reviewing results, select the Synapse pipelines you want to migrate to your Fabric workspace.

:::image type="content" source="media/how-to-assess-and-upgrade-your-azure-synapse-analytics-pipelines-to-fabric/view-synapse-pipelines-assessment-results.png" alt-text="Screenshot showing Synapse Analytics migration assessment results with option to select pipelines for migration." lightbox="media/how-to-assess-and-upgrade-your-azure-synapse-analytics-pipelines-to-fabric/view-synapse-pipelines-assessment-results.png":::

A phased approach works well:
- Start with **Ready** pipelines to validate end-to-end behavior.
- Then address **Needs review** items and rerun assessment to confirm progress.

## Step 3: Map linked services to Fabric connections

In the migration flow, select a destination **Fabric workspace**, then map **Synapse linked services** to **Fabric connections**.

- If you already created the required Fabric connections, select them from the dropdown.
- Otherwise, create new Fabric connections from workspace settings.

For guidance on creating and managing connections in Fabric, see
[Data source management - Microsoft Fabric | Microsoft Learn](https://learn.microsoft.com/fabric/data-factory/data-source-management).

:::image type="content" source="media/how-to-assess-and-upgrade-your-azure-synapse-analytics-pipelines-to-fabric/synapse-linked-service-to-connection-mapping.png" alt-text="Screenshot showing Fabric migration workspace selection followed by Synapse linked services to Fabric connection mapping." lightbox="media/how-to-assess-and-upgrade-your-azure-synapse-analytics-pipelines-to-fabric/synapse-linked-service-to-connection-mapping.png":::

> [!IMPORTANT]
> Pipelines can migrate even if you don’t map connections, but **activities that use those connections remain deactivated** until you configure them in Fabric and reactivate them.


## Step 4: Complete migration

After you map linked services to Fabric connections, select **Confirm** to complete migration.

:::image type="content" source="media/how-to-assess-and-upgrade-your-azure-synapse-analytics-pipelines-to-fabric/successful-migration-completion.png" alt-text="Screenshot showing successful migration." lightbox="media/how-to-assess-and-upgrade-your-azure-synapse-analytics-pipelines-to-fabric/successful-migration-completiong.png":::

When migration completes, open the destination folder in your Fabric workspace and review the migrated pipelines.

> [!NOTE]
> Pipelines migrate safely, with **triggers disabled by default**, so you stay in control of execution.

## Post-migration checklist

After migration:
1. Validate connections and credentials.
2. Re-enable and configure triggers as needed (triggers are disabled by default).
3. Run end-to-end tests to confirm behavior.
4. Validate in a nonproduction environment before switching production workloads.


## Related migration resources

Use these resources to round out your end-to-end Synapse-to-Fabric migration plan:

- [Assess your Azure Data Factory and Synapse pipelines for migration to Fabric](https://learn.microsoft.com/en-us/azure/data-factory/how-to-assess-your-azure-data-factory-to-fabric-data-factory-migration)
- [Upgrade your Azure Data Factory pipelines to Fabric](https://learn.microsoft.com/en-us/azure/data-factory/how-to-upgrade-your-azure-data-factory-pipelines-to-fabric-data-factory)
- [Migration Assistant for Fabric Data Warehouse - Microsoft Fabric | Microsoft Learn](https://learn.microsoft.com/en-us/fabric/data-warehouse/migration-assistant)
- [Spark Synapse to Fabric Spark Migration Assistant (Preview)](https://learn.microsoft.com/en-us/fabric/data-engineering/synapse-to-fabric-spark-migration-assistant)
- [Spark Synapse to Fabric Spark Migration Assistant (Preview) (review branch)](https://review.learn.microsoft.com/en-us/fabric/data-engineering/synapse-to-fabric-spark-migration-assistant?branch=release-fabsqlcon-2026-de)


