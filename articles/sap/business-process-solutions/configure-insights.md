---
title: Configure Insights in Business Process Solutions
description: Learn how to configure insights in Business Process Solutions, including setting up semantic models, deploying Power BI report templates, and establishing connections to refresh reports and models.
author: mohitmakhija1
ms.service: sap-on-azure
ms.subservice: center-sap-solutions
ms.topic: how-to
ms.date: 11/07/2025
ms.author: momakhij
---

# Configure insights in Business Process Solutions

Insights in Business Process Solutions are analytics templates, such as Power BI reports and semantic models, designed to help you quickly start analysing your data. You can explore available templates on the Business Templates page.
This article explains how to configure Insights and establish connections to refresh reports and models.

## Import Lakehouse Views

Some Insights require additional transformations delivered through SQL views on top of the lakehouse. To deploy these views, run the provided notebook from your workspace:

1. Navigate to your workspace.
2. Open the notebook **bps_gold_view_creation**.
   :::image type="content" source="./media/configure-insights/gold-view-notebook.png" alt-text="Screenshot showing how to open the bps_gold_view_creation notebook." lightbox="./media/configure-insights/gold-view-notebook.png":::
3. Click on the **Run All** button.
   :::image type="content" source="./media/configure-insights/run-gold-view-notebook.png" alt-text="Screenshot showing how to run the bps_gold_view_creation notebook." lightbox="./media/configure-insights/run-gold-view-notebook.png":::
4. Once the notebook run is finished, you should see the sql views in your gold lakehouse.

## Deploy Power BI Report

To deploy a new Power BI report or Semantic model, use the onboarding wizard. On the overview page, click either the **Get Started** button or the **+ New Insight** button to open the wizard.
:::image type="content" source="./media/configure-insights/overview-wizard-buttons.png" alt-text="Screenshot showing the Get Started and New Insight buttons on the overview page." lightbox="./media/configure-insights/overview-wizard-buttons.png":::

The wizard guides you through four steps: **Set up insight**, **Set up connections**, **Set up dataset**, and **Review and deploy**.

### Step 1: Set up insight

In this step, you configure the source system and select the insight to deploy. The wizard opens to the **Set up Business Process Solution insight** page.

Under **Source system**, you can select an existing source system or create a new source system to see available insights. If no source system exists in the Business Process Solutions item, the **Select existing** option is disabled and **Create new** is automatically selected. If at least one source system already exists, the **Select existing** option is selected by default.
:::image type="content" source="./media/configure-insights/wizard-source-system-options.png" alt-text="Screenshot showing the source system options with Create new and Select existing." lightbox="./media/configure-insights/wizard-source-system-options.png":::

#### Create new

If you don't have an existing source system, or want to create a new one:

1. Select **Create new** under **Source system**.
   :::image type="content" source="./media/configure-insights/wizard-create-new-selected.png" alt-text="Screenshot showing the Create new option selected under source system." lightbox="./media/configure-insights/wizard-create-new-selected.png":::
2. Under **Source system type**, select the card for your system: **SAP S/4HANA**, **SAP ECC**, or **Salesforce**.
   :::image type="content" source="./media/configure-insights/wizard-source-system-type-cards.png" alt-text="Screenshot showing the source system type cards for SAP S/4HANA, SAP ECC, and Salesforce." lightbox="./media/configure-insights/wizard-source-system-type-cards.png":::
3. Under **Source system name**, enter a name for the source system and select the **System version** from the dropdown.
   :::image type="content" source="./media/configure-insights/wizard-create-new-name-version.png" alt-text="Screenshot showing the source system name field and system version dropdown." lightbox="./media/configure-insights/wizard-create-new-name-version.png":::
4. Under **Select insight**, the available insights for the selected source system type are displayed as cards, grouped by **Area** (for example, Record to Report, Order to Cash, Procure to Pay). You can change the grouping using the **Group by** dropdown, or use the **Search insights** box to filter. Each card shows the insight name, type (Report or Semantic Model), and a preview. Click **Select** on the insight you want to deploy.
   :::image type="content" source="./media/configure-insights/wizard-create-new-insight-cards.png" alt-text="Screenshot showing the available insight cards grouped by area for a new source system." lightbox="./media/configure-insights/wizard-create-new-insight-cards.png":::
5. Under **Define insight**, the **Insight name** is auto-populated. If an error message appears indicating the name already exists, update the name to a unique value.
   :::image type="content" source="./media/configure-insights/wizard-create-new-define-insight.png" alt-text="Screenshot showing the Define insight section with the auto-populated insight name." lightbox="./media/configure-insights/wizard-create-new-define-insight.png":::

#### Select existing

If at least one source system already exists in the Business Process Solutions item:

1. Select **Select existing** under **Source system**.
   :::image type="content" source="./media/configure-insights/wizard-select-existing-selected.png" alt-text="Screenshot showing the Select existing option selected under source system." lightbox="./media/configure-insights/wizard-select-existing-selected.png":::
2. Under **Source system name**, select a source system from the dropdown. Each source system shows its name, type, and status (a green indicator for succeeded, red for failed).
   :::image type="content" source="./media/configure-insights/wizard-select-existing-dropdown.png" alt-text="Screenshot showing the source system dropdown with name, type, and status indicators." lightbox="./media/configure-insights/wizard-select-existing-dropdown.png":::
3. Under **Select insight**, the available insights for the selected source system are displayed as cards, grouped by **Area**. You can change the grouping using the **Group by** dropdown, or use the **Search insights** box to filter. Each card shows the insight name, type (Report or Semantic Model), and a preview. Click **Select** on the insight you want to deploy.
   :::image type="content" source="./media/configure-insights/wizard-select-existing-insight-cards.png" alt-text="Screenshot showing the available insight cards for an existing source system." lightbox="./media/configure-insights/wizard-select-existing-insight-cards.png":::
4. Under **Define insight**, the **Insight name** is auto-populated. If an error message appears indicating the name already exists, update the name to a unique value.
   :::image type="content" source="./media/configure-insights/wizard-select-existing-define-insight.png" alt-text="Screenshot showing the Define insight section for an existing source system." lightbox="./media/configure-insights/wizard-select-existing-define-insight.png":::

Click **Next** to proceed.

### Step 2: Set up connections

The **Set up connections** page displays the connection configuration for the selected source system. The page shows the **Source system name** and a **Data extraction setting** section where you choose how to extract data from the system.
:::image type="content" source="./media/configure-insights/wizard-connections-page.png" alt-text="Screenshot showing the Set up connections page with source system name and data extraction settings." lightbox="./media/configure-insights/wizard-connections-page.png":::

For an existing source system that has succeeded, the connection details are shown as read-only. No action is required. Click **Next** to proceed.
:::image type="content" source="./media/configure-insights/wizard-connections-readonly.png" alt-text="Screenshot showing the read-only connection details for a succeeded source system." lightbox="./media/configure-insights/wizard-connections-readonly.png":::

For a new source system, the available connection types depend on the source system type:

- **SAP S/4HANA**: Choose between **Azure Data Factory** and **Open Mirroring**.
- **SAP ECC**: **Open Mirroring** is the available connection type.
- **Salesforce**: **Fabric** is the available connection type.

Select a **Connection type** and fill in the required fields.

For **SAP S/4HANA**, choose between Azure Data Factory and Open Mirroring:
:::image type="content" source="./media/configure-insights/wizard-hana-connection-type-radio.png" alt-text="Screenshot showing the connection type options for SAP S/4HANA with Azure Data Factory and Open Mirroring." lightbox="./media/configure-insights/wizard-hana-connection-type-radio.png":::

For **SAP ECC**:
:::image type="content" source="./media/configure-insights/wizard-ecc-connection-type-radio.png" alt-text="Screenshot showing the connection type option for SAP ECC." lightbox="./media/configure-insights/wizard-ecc-connection-type-radio.png":::

For **Salesforce**:
:::image type="content" source="./media/configure-insights/wizard-sf-connection-type-radio.png" alt-text="Screenshot showing the connection type option for Salesforce." lightbox="./media/configure-insights/wizard-sf-connection-type-radio.png":::

> [!NOTE]
> When you create the first source system in a Business Process Solutions item, all fields are editable. For subsequent source system creations, the Azure subscription, location, and resource group fields that were previously saved are disabled and reused. The same goes for the Azure resource names.

##### Azure Data Factory

If you select **Azure Data Factory** as the connection type, provide the following details:

- **Azure Subscription ID** and **Location**
- **Resource group**
- **Azure resources**: Specify the Azure Data Factory name, Azure Key Vault name, and Azure Storage account name. These names can't be modified after source system creation.
- **System connection**: Provide the Hostname, Subscriber name, SAP instance number, SAP Client ID, Username, Password, and Service Principal details (Name, Object ID, Client ID, and Secret).

:::image type="content" source="./media/configure-insights/wizard-connection-adf.png" alt-text="Screenshot showing the Azure Data Factory connection setup with Azure resources and system connection fields." lightbox="./media/configure-insights/wizard-connection-adf.png":::

##### Open Mirroring

If you select **Open Mirroring** as the connection type, a **Mirrored Database** is deployed as the target data store for the extracted data. Business Process Solutions only manages datasets and objects that are already available for processing. To ensure the necessary data is present, coordinate with your data extraction provider and share the list of required tables so they can populate the Mirrored Database accordingly.

Provide the following details under **System connection**:

- **Partner name**: Select the partner from the dropdown or type it in the input box.
- **Fabric SQL database connection ID**: Provide the SQL connection ID.

:::image type="content" source="./media/configure-insights/wizard-connection-om.png" alt-text="Screenshot showing the Open Mirroring connection setup with partner name and Fabric SQL database connection ID." lightbox="./media/configure-insights/wizard-connection-om.png":::

##### Fabric

If you select **Fabric** as the connection type (available for Salesforce), provide the required connection details.

:::image type="content" source="./media/configure-insights/wizard-connection-sf.png" alt-text="Screenshot showing the Fabric connection setup for Salesforce." lightbox="./media/configure-insights/wizard-connection-sf.png":::

Click **Next** to proceed.

### Step 3: Set up dataset

The **Set up dataset** page shows the **Dataset template** that is activated based on the insight you chose. The template details include:

- **Template name** and **Version**
- **Supported systems**
- **Power BI** availability status
- A **Show details** link for more information

:::image type="content" source="./media/configure-insights/wizard-dataset-template.png" alt-text="Screenshot showing the dataset template details including name, version, and supported systems." lightbox="./media/configure-insights/wizard-dataset-template.png":::

Under **Name Dataset**, a **Dataset name** is auto-populated based on the insight and source system. If the name already exists for the source system, update it to a unique name before proceeding.
:::image type="content" source="./media/configure-insights/wizard-dataset-name.png" alt-text="Screenshot showing the dataset name field auto-populated based on insight and source system." lightbox="./media/configure-insights/wizard-dataset-name.png":::

Click **Next** to proceed.

### Step 4: Review and deploy

The **Review and deploy** page displays a summary of all configurations. The sections shown depend on the source system:

- For a **new source system** or an **existing source system that previously failed**, the page shows three sections:
  - **Set up insight**: Source system type, source system name, system version, insight name, and insight type.
  - **Set up connections**: This depends on the connection type you have selected in the previous steps.
  - **Set up dataset**: Template name and dataset name.

:::image type="content" source="./media/configure-insights/wizard-review-new.png" alt-text="Screenshot showing the review page with insight, connections, and dataset sections for a new source system." lightbox="./media/configure-insights/wizard-review-new.png":::

- For an **existing source system that succeeded**, the page shows two sections:
  - **Set up insight**: Source system type, source system name, system version, insight name, and insight type.
  - **Set up dataset**: Template name and dataset name.

:::image type="content" source="./media/configure-insights/wizard-review-succeeded.png" alt-text="Screenshot showing the review page with insight and dataset sections for a succeeded source system." lightbox="./media/configure-insights/wizard-review-succeeded.png":::

Review the details and click the **Deploy** button to deploy the insight.
:::image type="content" source="./media/configure-insights/wizard-deploy-button.png" alt-text="Screenshot showing the Deploy button on the review and deploy page." lightbox="./media/configure-insights/wizard-deploy-button.png":::

Once the deployment completes, you can see the report in your workspace as well as in the Business Propess Solutions item overview page.

> [!NOTE]
> Power BI Report deployment automatically deploys the semantic model. You don't need to deploy the semantic model separately.

## Connection for Semantic Model Refresh

To refresh the semantic model, we need to set up a connection in fabric, else we won't be able to automatically refresh the reports via pipelines. To set up the connection, follow the steps:

1. Open the Semantic Model item, Click on **File**, and then select **Settings** button.
   :::image type="content" source="./media/configure-insights/model-settings.png" alt-text="Screenshot showing how to open the semantic model settings." lightbox="./media/configure-insights/model-settings.png":::
2. Open the **Gateway and cloud connections** and under cloud connections, click on Create a connection.
3. Now, Enter a unique name for your connection, multiple reports can use this connection. Select Authentication method as OAuth 2.0.
   :::image type="content" source="./media/configure-insights/lakehouse-connection.png" alt-text="Screenshot showing how to create a Microsoft Fabric lakehouse connection." lightbox="./media/configure-insights/lakehouse-connection.png":::
4. Now, click on **Edit credentials** and provide the credentials. Click on **Create**.
5. Once connection is created, navigate back to the semantic model and associate the connection.
   :::image type="content" source="./media/configure-insights/associate-connection.png" alt-text="Screenshot showing how to associate a connection to the semantic model." lightbox="./media/configure-insights/associate-connection.png":::
6. Once done, try to refresh the semantic model and check if it completes successfully.

## Summary

In this article, we described the steps required to configure Insights in Business Process Solutions. You learned how to deploy lakehouse views, Power BI reports, and semantic models, and how to set up connections for refreshing reports and models. Now you can start exploring the reports and models to gain insights from your data.
