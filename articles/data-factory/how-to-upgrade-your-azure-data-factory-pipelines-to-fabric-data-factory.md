---
title: Upgrade your Azure Data Factory pipelines to Fabric
description: Learn how to assess and upgrade your Azure Data Factory pipelines to Fabric Data Factory.
author: ssindhub
ms.author: ssrinivasara
ms.topic: how-to
ms.date: 02/27/2026
ms.custom: pipelines
---

# Upgrade your Azure Data Factory pipelines to Fabric

Your Azure Data Factory pipelines already power critical workflows. In this article, you learn how to bring them into Fabric to unlock a more integrated, analytics-ready experience. This built-in migration experience helps you modernize your existing Azure Data Factory workloads in a few simple clicks.

The migration experience helps you:

1. Assess pipeline readiness directly in Azure Data Factory.
1. Understand compatibility gaps at the pipeline and activity level.
1. Migrate supported pipelines to a Fabric workspace.
1. Plan next steps for items that need updates or that are coming soon.

This assessment-first approach helps ensure migrations are intentional, transparent, and incremental. You can upgrade pipelines at your own pace and validate results before switching production workloads.


## Prerequisites

Before you start, make sure you have:

- An existing Azure Data Factory instance with pipelines.
- Access to a Microsoft Fabric tenant.
- A Fabric workspace in the same Microsoft Entra ID tenant as the Azure Data Factory instance.


## Step 1: Assess your pipelines for migration

To run the migration assessment, in your [Azure Data Factory](https://adf.azure.com) authoring canvas, select **Migrate to Fabric (Preview)** > **Get started (preview)** to evaluate pipelines and activities for migration readiness.

:::image type="content" source="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/migrate-to-fabric-get-started.png" alt-text="Screenshot showing how to run the Azure Data Factory migration assessment." lightbox="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/migrate-to-fabric-get-started.png":::

## Step 2: Review and understand assessment results

Both the factory and individual pipelines are categorized with a readiness status: **Ready**, **Needs review**, **Coming soon**, or **Unsupported**.
You can also export your assessment results to a CSV file to support offline review and remediation planning.

:::image type="content" source="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/assessment-results.png" alt-text="Screenshot showing the Azure Data Factory migration assessment results." lightbox="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/assessment-results.png":::

Each pipeline and activity is assigned one of the following statuses. Use these results to plan your migration.

| Status            | Meaning                                                            |
|-------------------|--------------------------------------------------------------------|
| **Ready**         | Fully supported and safe to migrate.                               |
| **Needs review**  | Requires minor updates, such as parameter or configuration changes.|
| **Coming soon**   | Support is planned; migrate later.                                 |
| **Not compatible**| No Fabric equivalent; redesign required.                           |


## Step 3: Select a Fabric workspace and mount your Azure Data Factory

After you review the assessment, select **Next** to mount your Azure Data Factory to a Fabric workspace and continue the migration flow in Fabric. Mounting lets you reference your ADF instance inside a Fabric workspace without migrating, copying, or altering the ADF environment.

:::image type="content" source="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/mount_azure-data-factory-to-fabric.png" alt-text="Screenshot showing Fabric workspace selection for mounting Azure Data Factory to Fabric." lightbox="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/mount_azure-data-factory-to-fabric.png":::

After mounting completes, select **Continue in Fabric** to proceed with migration steps.

:::image type="content" source="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/successfully-mounted-factory.png" alt-text="Screenshot showing the Continue in Fabric option after successful mounting." lightbox="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/successfully-mounted-factory.png":::

## Step 4: Migrate pipelines

Continue migration from the Fabric experience by selecting **Migrate to Fabric (Preview)**.

:::image type="content" source="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/migrate_to_fabric_post_mount.png" alt-text="Screenshot showing the Migrate to Fabric option in Fabric." lightbox="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/migrate_to_fabric_post_mount.png":::

Select the pipelines you want to migrate.

:::image type="content" source="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/pick-pipelines-for-migration.png" alt-text="Screenshot showing the option to select pipelines for migration." lightbox="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/pick-pipelines-for-migration.png":::

> [!NOTE]
> To preserve your existing Azure Data Factory folder structure, first recreate the same folders in your Fabric workspace. Then migrate pipelines folder by folder, selecting the corresponding Fabric folders during migration.

## Step 5: Map linked services to Fabric connections and complete migration

Select **Review connections** to map Azure Data Factory linked services to Fabric connections.

The migration experience attempts to automatically create commonly used connections (Azure Blob Storage, Azure Data Lake Storage Gen2, SQL Server, and Azure SQL Database) that don't rely on Azure Key Vault.
For other connections, either select an existing Fabric connection or create new connections by using the modern Get Data experience or from workspace settings. Then select **Confirm**.

:::image type="content" source="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/linkedservices-to-connection-mapping.png" alt-text="Screenshot showing the mapping of linked services to Fabric connections." lightbox="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/linkedservices-to-connection-mapping.png":::

Next, select an existing folder or create a new folder to migrate your Azure Data Factory pipelines, and then select **Confirm**.
This action starts the migration of the selected pipelines to the chosen folder in the Fabric workspace. A confirmation message appears when the migration completes successfully.

:::image type="content" source="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/migration-successfully-completed.png" alt-text="Screenshot showing successful completion of migration from Azure Data Factory to Fabric." lightbox="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/migration-successfully-completed.png":::

After the migration completes, go to the folder you selected in the Fabric workspace to view the migrated pipelines. You can open each pipeline to review and validate it before you continue with further configuration or testing.

:::image type="content" source="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/validate-migration.png" alt-text="Screenshot showing the migration folder with the migrated pipelines for validation." lightbox="media/how-to-assess-and-upgrade-your-azure-data-factory-pipelines-to-fabric/validate-migration.png":::

> [!NOTE]
> If you don't map any connections during this step, pipelines still migrate. Activities within those pipelines are deactivated, and you can configure them later in Fabric.

After migration completes, validate the pipelines in the Fabric Data Factory experience.

## Migration behavior

- Pipelines migrate into a Fabric Data Factory workspace.
- Pipeline names must be unique within a workspace.
- If a pipeline with the same name already exists, the migration tool skips that pipeline.
- To ensure uniqueness, migrated pipelines use the following naming format: `<Source factory or workspace name>_<Pipeline name>`.
- The migration flow includes a mounting step that lets you view your existing factory structure in Fabric before migration.

## Post-migration validation

After migration, complete the following tasks:

1. Validate all connections and credentials.
1. Recreate global parameters as variable libraries.
1. Re-enable and configure triggers (disabled by default).
1. Run end-to-end tests to confirm pipeline behavior.
1. Validate migrations in a nonproduction environment before you migrate production workloads.

## What's out of scope

The following items aren't supported in the UX-based migration experience today. Pipelines that use these features require redesign or alternate migration approaches.

| **Category**                 | **Out-of-scope item**                                      | **Details** |
|-----------------------------|-------------------------------------------------------------|-------------|
| **Integration Runtimes**    | Self-Hosted Integration Runtime (SHIR)                     | SHIR can't be migrated. Replace it with Fabric On-Premises Data Gateway (OPDG). |
|                             | Managed Virtual Network IR / VNet injected IR              | Fabric doesn't support migrating Managed VNet IRs. VNet Gateway is a different model that requires re-setup. |
|                             | SSIS IR                                                     | SSIS IR isn't supported. |
| **Workload Types**          | ADF CDC (Change Data Capture)                              | CDC workloads are out of scope and don't migrate. |
|                             | Airflow assets                                              | Airflow DAG-based orchestration can't be migrated to Fabric. |
|                             | U-SQL / ADLA                                                | ADLA and U-SQL are deprecated and not supported in Fabric. |
|                             | Cross-cloud / AML refresh                                   | WI support for AML/SPN dual tokens is in progress. These workloads don't migrate. |
| **Connectors**              | Long-tail connectors (for example, SAP ECC BW MDX, SAP C**)     | Fabric has no equivalent connectors. Redesign is required. |
|                             | Marketing & Finance SaaS (HubSpot, Google Ads, QuickBooks, Shopify, Xero) | Not supported today. |
| **Triggers & Orchestration**| Custom Event Triggers                                       | Custom event triggers can't be migrated. |
|                             | Storage Event Triggers                                      | Support is coming soon. |
|                             | Tumbling Window Triggers                                    | Interval-based schedule support is coming soon. Watermark/backfill workloads must be redesigned. |
|                             | Chaining / Dependency Triggers                              | Chaining/dependency trigger semantics aren't supported yet. |
| **Security & Authentication**| Advanced configurations (CMK, dual tokens, FIC flows)     | WI or SPN auth models not yet supported don't migrate. |
|                             | Certificate-based authentication (Web activity)             | Unsupported. Requires redesign. |
|                             | UAMI support                                                | UAMI isn't supported yet. Use Workspace Identity (WI) as a workaround. |
| **Parameterization & Metadata** | Global Parameters                                      | Coming soon. Recreate by using Fabric Variable Libraries. |
|                             | Dynamic linked services (parameterized connections)         | Not supported. Each permutation must be a separate connection and can't migrate. |
|                             | Metadata-driven pipelines                                   | Highly dynamic linked-service/dataset-driven patterns can't migrate. |
| **Activities & Compute**    | Synapse SJD / Notebook                                      | Partially supported. Requires redesign into Fabric notebook / Spark job. |
|                             | Mapping Data Flows (MDF)                                    | Support is coming soon. |
|                             | Web/Webhook/HTTP activities with custom auth/headers        | Complex auth scenarios must be rebuilt manually. |
|                             | Notebook pool environment settings                          | Not supported. Migration is blocked. |
|                             | Batch / Custom Activity WI support                          | Missing WI support blocks migration for these activities. |
|                             | Copy activity upsert into Lakehouse tables                  | Not supported. Requires Copy to staging and Notebook MERGE. |


## FAQ

**Does the assessment change my factory?**

No. The assessment is read-only. It scans your factory configuration and surfaces findings in the side pane without modifying pipelines, activities, or settings. You can safely run it to understand migration impact before taking any action.

**Can I rerun the assessment or migration after making changes?**

Yes. You can rerun the assessment at any time during validation. If you rerun migration for the same pipelines, you must first delete the previously migrated pipelines in Fabric, because pipeline names must be unique within a workspace.

**Does mounting Azure Data Factory migrate my pipelines?**

No. Mounting is just a snapshot of your existing Azure Data Factory in a Fabric workspace. No pipelines are migrated until you explicitly start migration by selecting the **Migrate to Fabric (Preview)** button from your mounted data factory in Fabric.

**Will triggers migrate automatically?**

Schedule triggers are migrated automatically but disabled after migration by design. You must manually re-enable them in Fabric. All other triggers must be manually reconfigured and re-enabled after you validate the migrated pipelines.

**Do unsupported items block the entire migration?**

No. Unsupported activities affect only the pipelines that contain them. Other supported pipelines can migrate independently. The assessment clearly identifies which pipelines require redesign.

**Can I migrate without mapping connections?**

Yes. Pipelines still migrate, but activities that depend on unmapped connections are deactivated. You must configure the required Fabric connections and re-enable those activities before running the pipelines.

**Can I validate migrations before moving production workloads?**

Yes. Microsoft recommends validating migrations in a nonproduction environment, confirming connections, triggers, and end-to-end execution before migrating production pipelines.

## Related content

- [Compare Azure Data Factory and Fabric Data Factory](/fabric/data-factory/compare-fabric-data-factory-and-azure-data-factory)
- [Plan your migration from Azure Data Factory to Fabric Data Factory](/fabric/data-factory/migrate-planning-azure-data-factory)
- [Assess your pipelines for migration to Fabric Data Factory](how-to-assess-your-azure-data-factory-to-fabric-data-factory-migration)
- [Migration best practices](/fabric/data-factory/migration-best-practices)
- [Connector parity](/fabric/data-factory/connector-parity)
- [Convert global parameters to variable libraries](/fabric/data-factory/convert-global-parameters-to-variable-libraries)


