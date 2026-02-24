---
title: Upgrade your Azure Data Factory pipelines to Fabric
description: Learn how to assess and upgrade your Azure Data Factory Pipelines to Fabric 
author: ssindhub
ms.author: ssrinivasara
ms.topic: article
ms.date: 02/27/2026
ms.custom: pipelines
---

# Overview
Your Azure Data Factory pipelines already power critical workflows. Bring them into Fabric to unlock a more integrated, analytics ready experience. To help you modernize your existing workloads, this built-in migration experience helps you assess and upgrade supported Azure Data Factory pipelines in few simple clicks.

The migration experience helps you:
1. Assess pipeline readiness directly in Azure Data Factory.
1. Understand compatibility gaps at the pipeline and activity level.
1. Migrate supported pipelines to a Fabric workspace.
1. Plan next steps for items that need updates or are coming soon.
   
This assessment first approach helps ensure migrations are intentional, transparent, and incremental, so you can upgrade pipelines at your own pace and validate results before switching production workloads.


## Prerequisites
Before you start, make sure you have:
1. An existing Azure Data Factory with pipelines.
1. Access to a Microsoft Fabric tenant.
1. A Fabric workspace where pipelines will migrate to.


## 1. Assess your pipelines for migration
1.	Run the migration assessment
In your [Azure Data Factory](https://adf.azure.com) authoring canvas, select **Migrate to Fabric (Preview)**, then select **Get started (preview)** to evaluate pipelines and activities for migration readiness.

:::image type="content" source="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/migrate-to-fabric-get-started.png" alt-text="Screenshot showing how to run the Azure Data Factory Migration assessment." lightbox="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/migrate-to-fabric-get-started.png":::

## 2. Review and understand assessment results
Both the factory and individual pipelines will be categorized with readiness status as Ready, Needs review, Coming soon, or Unsupported. 
You can also export your assessment results to a csv file to support offline review and remediation planning.


:::image type="content" source="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/assessment-results.png" alt-text="Screenshot showing how to view the Azure Data Factory migration assessment results." lightbox="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/assessment-results.png" :::

Each pipeline and activity is assigned one of the following statuses. Use these results to plan your migration.


| Status            | Meaning                                                            |
|-------------------|--------------------------------------------------------------------|
| **Ready**         | Fully supported and safe to migrate                                |
| **Needs review**  | Requires minor updates, such as parameter or configuration changes |
| **Coming soon**   | Support is planned; migrate later                                  |
| **Not compatible**| No Fabric equivalent: redesign required                            |


## 3. Select a Fabric Workspace and mount your Azure Data Factory
After reviewing the assessment, select **Next** to mount your Azure Data Factory to a Fabric workspace and continue the migration flow in Fabric. Mounting lets you seamlessly reference your Azure Data Factory (ADF) instance inside a Fabric workspace—without migrating, copying, or altering the ADF environment. 

:::image type="content" source="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/mount_azure-data-factory-to-fabric.png" alt-text="Screenshot showing Fabric workspace selection for mounting Azure Data Factory to Fabric." lightbox="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/mount_azure-data-factory-to-fabric.png" :::

Once mounting completes, select **Continue in Fabric** to proceed with migration steps.

:::image type="content" source="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/successfully-mounted-factory.png" alt-text="Screenshot for continuing in Fabric post successful mounting of the Azure Data Factory to Fabric." lightbox="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/successfully-mounted-factory.png" :::

## 4. Migrate Pipelines
Continue migration from the Fabric experience by selecting **Migrate to Fabric (Preview)**.
:::image type="content" source="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/migrate_to_fabric_post_mount.png" alt-text="Screenshot showing Migrate to Fabric option in Fabric." lightbox="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/migrate_to_fabric_post_mount.png" :::


Select the pipelines you want to migrate.
:::image type="content" source="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/pick-pipelines-for-migration.png" alt-text="Screenshot showing option to select pipelines for migration." lightbox="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/pick-pipelines-for-migration.png" :::

> [!NOTE]
> To preserve your existing Azure Data Factory folder structure, first recreate the same folders in your Fabric workspace. Then migrate pipelines folder by folder, selecting the corresponding Fabric folders during migration.

## 5. Map Azure Data Factory Linked Services to Fabric Connections and complete migration
Select **Review connections** to map Azure Data Factory linked services to Fabric connections. 

The migration experience attempts to automatically create commonly used connections (Azure Blob Storage, ADLS Gen2, SQL Server and Azure SQL Database) that don’t rely on Azure Key Vault.
For other connections, either select an existing Fabric connection or create new connections using the modern Get Data experience or from workspace settings. Then select **Confirm**.

> [!NOTE]
> If you do not map any connections during this step, pipelines still migrate. Activities within those pipelines would be deactivated and you can configure them later in Fabric. 
After migration completes, validate the pipelines in the Fabric Data Factory experience.

## Migration behavior
•	Pipelines migrate into a Fabric Data Factory workspace.
•	Pipeline names must be unique within a workspace. 
•	If a pipeline with the same name already exists, migration tools skips that pipeline.
•	To ensure uniqueness, migrated pipelines use the following naming format:
<Source factory or workspace name>_<Pipeline name>
•	The migration flow includes a mounting step that lets you view your existing factory structure in Fabric before migration

## Post-migration validation

After migration, you should:
•	Validate all connections and credentials
•	Recreate global parameters as Variable Libraries
•	Re-enable and configure triggers (disabled by default)
•	Run end-to-end tests to confirm pipeline behavior
•	Validate migrations in a non-production environment before migrating production workloads.

## What's out of scope
The following items aren’t supported in the UX-based migration experience today:
Pipelines using these features require redesign or alternate migration approaches.

| **Category**                 | **Out of Scope Item**                                      | **Details** |
|-----------------------------|-------------------------------------------------------------|-------------|
| **Integration Runtimes**    | Self Hosted Integration Runtime (SHIR)                     | SHIR cannot be migrated; must be replaced with Fabric On‑Premises Data Gateway (OPDG). |
|                             | Managed Virtual Network IR / VNet injected IR              | Fabric does not support migrating Managed VNet IRs; VNet Gateway is a different model requiring re‑setup. |
|                             | SSIS IR                                                     | SSIS IR is not supported. |
| **Workload Types**          | ADF CDC (Change Data Capture)                              | CDC workloads are explicitly out of scope and will not migrate. |
|                             | Airflow assets                                              | Airflow DAG‑based orchestration is not migratable to Fabric. |
|                             | U‑SQL / ADLA                                                | ADLA and U‑SQL are deprecated and not supported in Fabric. |
|                             | Cross‑cloud / AML refresh                                   | WI support for AML/SPN dual tokens is WIP; these workloads will not migrate. |
| **Connectors**              | Long‑tail connectors (e.g., SAP ECC BW MDX, SAP C\*\*)     | Fabric has no equivalent connectors; redesign is required. |
|                             | Marketing & Finance SaaS (HubSpot, Google Ads, QuickBooks, Shopify, Xero) | Not supported today. |
| **Triggers & Orchestration**| Custom Event Triggers                                       | Custom event triggers cannot be migrated. |
|                             | Storage Event Triggers                                      | Support coming soon. |
|                             | Tumbling Window Triggers                                    | Interval‑based schedule support coming soon; watermark/backfill workloads must be redesigned. |
|                             | Chaining / Dependency Triggers                              | No support yet for chaining/dependency trigger semantics. |
| **Security & Authentication**| Advanced configurations (CMK, dual tokens, FIC flows)     | WI or SPN auth models not yet supported will not migrate. |
|                             | Certificate‑based authentication (Web activity)             | Unsupported; requires redesign. |
|                             | UAMI support                                                | UAMI not yet supported; workaround is to use Workspace Identity (WI). |
| **Parameterization & Metadata** | Global Parameters                                      | Coming soon; must recreate via Fabric Variable Libraries. |
|                             | Dynamic linked services (parameterized connections)         | Not supported; each permutation must be a separate connection → cannot migrate. |
|                             | Metadata‑driven pipelines                                   | Highly dynamic LS/Dataset‑driven patterns cannot migrate. |
| **Activities & Compute**    | Synapse SJD / Notebook                                      | Partially supported; requires redesign into Fabric notebook / Spark job. |
|                             | Mapping Data Flows (MDF)                                    | Support coming soon. |
|                             | Web/Webhook/HTTP activities with custom auth/headers        | Complex auth scenarios must be rebuilt manually. |
|                             | Notebook pool environment settings                          | Not supported; migration blocked. |
|                             | Batch / Custom Activity WI support                          | Missing WI support blocks migration for these activities. |
|                             | Copy activity upsert into Lakehouse tables                  | Not supported; requires Copy → staging + Notebook MERGE. |


## FAQ
**Does the assessment change my factory?**

**Answer:** No. The assessment is read‑only. It scans your factory configuration and surfaces findings in the side pane without modifying pipelines, activities, or settings. You can safely run it to understand migration impact before taking any action.

**Can I rerun the assessment or migration after making changes?**

**Answer:** Yes, you can rerun anytime during the validation process. Since Pipeline names must be unique, you need to delete your previously migrated pipelines before re-migrating them after making any necessary changes.

**Does mounting Azure Data Factory migrate my pipelines?**

**Answer:** No. Mounting is just a snapshot of your existing Azure Data Factory in Fabric workspace. No pipelines are migrated until you explicitly start migration by selecting the **Migrate to Fabric (Preview)** button from your mounted data factory in Fabric.

**Will triggers migrate automatically?**

**Answer:** Schedule triggers are migrated automatically but disabled after migration by design. You must manually re‑enable them in Fabric. All other triggers must be manually reconfigured and reenabled after validating the migrated pipelines.

**Do unsupported items block the entire migration?**

**Answer:** No. Unsupported activities affect only the pipelines that contain them. Other supported pipelines can migrate independently. The assessment clearly identifies which pipelines require redesign.
 
**Can I migrate without mapping connections?**

**Answer:** Yes. Pipelines will still migrate, but activities that depend on unmapped connections will be deactivated. You must configure the required Fabric connections and re‑enable those activities before running the pipelines.

**Can I validate migrations before moving production workloads?**
**Answer:** Yes. Microsoft recommends validating migrations in a non‑production environment, confirming connections, triggers, and end‑to‑end execution before migrating production pipelines.

## Related content

[Compare Azure Data Factory and Fabric Data Factory](/fabric/data-factory/compare-fabric-data-factory-and-azure-data-factory)

[Plan your migration from Azure Data Factory to Fabric Data Factory](/fabric/data-factory/migrate-planning-azure-data-factory)

[Assess your Pipelines for Migration to Fabric Data Factory](how-to-assess-your-azure-data-factory-to-fabric-data-factory-migration)

[Migration best practices](/fabric/data-factory/migration-best-practices)

[Connector parity](/fabric/data-factory/connector-parity)

[Convert global parameters to variable libraries](/fabric/data-factory/convert-global-parameters-to-variable-libraries)


