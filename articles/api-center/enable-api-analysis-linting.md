---
title: Perform API Linting and Analysis
titleSuffix: Azure API Center
description: Configure linting of API definitions in your API center to analyze compliance of APIs with the organization's API style guide.
ms.service: azure-api-center
ms.topic: how-to
ms.date: 02/27/2026

ms.custom:
  - devx-track-azurecli
  - sfi-image-nochange
# Customer intent: As an API program manager, I want to lint the API definitions in my organization's API center and analyze whether my APIs comply with my organization's API style guide.
---

# Enable API analysis in your API center - self-managed

This article explains how to enable API analysis in [Azure API Center](overview.md) by manually setting up a linting engine and triggers. These capabilities analyze your API definitions for adherence to organizational style rules, generating both individual and summary reports. API analysis helps identify and correct common errors and inconsistencies in your API definitions.

> [!NOTE]
> Azure API Center also [automatically configures](enable-managed-api-analysis-linting.md) a default linting engine and dependencies for API analysis. If you enable self-managed analysis as described in this article, you override these built-in features.  

> [!VIDEO https://www.youtube.com/embed/m0XATQaVhxA]

> [!NOTE]
> Azure CLI command examples in this article can run in PowerShell or a bash shell. Where needed because of different variable syntax, separate command examples are provided for the two shells.

## Scenario overview

In this scenario, you analyze API definitions in your API center by using the [Spectral](https://github.com/stoplightio/spectral) open source linting engine. A function app built with Azure Functions runs the linting engine in response to events in your API center. Spectral checks that the APIs defined in a JSON or YAML specification document conform to the rules in a customizable API style guide. An analysis report is generated that you can view in your API center.

The following diagram shows the steps to enable linting and analysis in your API center. 

:::image type="content" source="media/enable-api-analysis-linting/scenario-overview.png" border="false" alt-text="Diagram showing how API linting works in Azure API Center." lightbox="media/enable-api-analysis-linting/scenario-overview.png":::

1. Deploy a function app that runs the Spectral linting engine on an API definition.

1. Configure an event subscription in an Azure API center that triggers the function app.

1. An event is triggered by adding or replacing an API definition in the API center.

1. On receiving the event, the function app invokes the Spectral linting engine.

1. The linting engine checks that the APIs defined in the definition conform to the organization's API style guide and generates a report.

1. View the analysis report in the API center.

### Options to deploy the linting engine and event subscription

This article provides two options to deploy the linting engine and event subscription in your API center:

- **Automated deployment**: Use the Azure Developer CLI (`azd`) for one-step deployment of linting infrastructure. This option is recommended for a streamlined deployment process.

- **Manual deployment**: Follow step-by-step guidance to deploy the function app and configure the event subscription. This option is recommended if you prefer to deploy and manage the resources manually.

### Limitations

* Linting currently supports only JSON or YAML specification files, such as OpenAPI or AsyncAPI specification documents.
* By default, the linting engine uses the built-in [`spectral:oas` ruleset](https://docs.stoplight.io/docs/spectral/4dec24461f3af-open-api-rules). To extend the ruleset or create custom API style guides, see the [Spectral repository](https://github.com/stoplightio/spectral/blob/develop/docs/reference/openapi-rules.md) on GitHub.
* The function app that invokes linting is charged separately, and you manage and maintain it.

## Prerequisites

* An API center in your Azure subscription. To create a subscription, see [Quickstart: Create your API center](set-up-api-center.md).

* The Event Grid resource provider registered in your subscription. If you need to register the Event Grid resource provider, see [Subscribe to events published by a partner with Azure Event Grid](../event-grid/subscribe-to-partner-events.md#register-the-event-grid-resource-provider).

* For Azure CLI:
   [!INCLUDE [include](~/reusable-content/azure-cli/azure-cli-prepare-your-environment-no-header.md)]

   [!INCLUDE [install-apic-extension](includes/install-apic-extension.md)]

## Use azd deployment for function app and event subscription

This section provides automated steps for the Azure Developer CLI (`azd`) to configure the function app and event subscription that enable linting and analysis in your API center. You can also configure the resources [manually](#manual-steps-to-configure-function-app-and-event-subscription).

### Other prerequisites for this option

* [Azure Developer CLI (azd)](/azure/developer/azure-developer-cli/install-azd). Install `azd` on your machine into the environment you plan to use for the following procedure. 

* [Azure Functions Core Tools](/azure/azure-functions/functions-run-local). Install the core tools on your machine into the environment you plan to use for the following procedure. Make sure the tools are reachable by your `PATH` settings.

### Run the sample by using azd

1. Clone the sample [Azure API Center Analyzer](https://github.com/Azure/APICenter-Analyzer/) GitHub repository to your local machine.

1. Launch Visual Studio Code, and select **File** > **Open Folder** (**Ctrl**+**K**, **Ctrl**+**O**). Browse to the `APICenter-Analyzer` folder for the cloned repository and choose **Select folder**.

1. In the Visual Studio Code **Activity Bar**, select **Explorer** (**Ctrl**+**Shift**+**E**) so you can view the repository folder structure.

   - Expand the `resources/rulesets` folder and notice the `oas.yaml` file. This file reflects your current API style guide. You can modify this file to satisfy your organizational needs.

   - Expand the `src/functions` folder and notice the `ApiAnalyzerFunction.ts` file. This file provides the function code for the function app. You can modify this file to adjust the function behavior to meet your application requirements.

1. Open a terminal in Visual Studio Code and authenticate with the Azure Developer CLI (`azd`):

   ```azurecli
   azd auth login
   ```

   > [!TIP]
   > You can avoid authentication issues across development environments by running the following commands:
   > 
   > 1. Create a new development environment: `azd new env`
   > 1. Get your tenant ID: `az account show --query tenantId -o tsv` (copy the output ID for later)
   > 1. Sign out: `azd auth logout` command
   > 1. Sign into `azd` with your `tenantId` value from step 2: `azd auth login --tenant-id <tenant_ID>`
   > 1. Sign in again: `azd auth login`
   
   When you successfully authenticate, the command output shows you _Logged into Azure as <your_user_alias>_. 

1. Next, sign into the Azure portal by using the Azure CLI:

   ```azurecli
   az login
   ```

   You're prompted to enter your credentials to sign into Azure.
   
   A browser window confirms your successful sign in. Close the window and return to this procedure.

1. Run the following command to deploy the linting infrastructure to your Azure subscription.

   For this command, you need the following information. Most of these values are available on the **Overview** page for your API center resource in the Azure portal.

   - Subscription name and ID
   - API center name
   - Resource group name for the API center
   - Deployment region for the function app (can be different from your API center region)

   ```azurecli
   azd up
   ```

1. Follow the prompts to provide the required deployment information and settings. For more information, see [Running the sample by using the Azure Developer CLI (azd)](https://github.com/Azure/APICenter-Analyzer/#wrench-running-the-sample-using-the-azure-developer-cli-azd).

   As the deployment progresses, the output shows the completed provisioning tasks:

   > [!NOTE]
   > It can take several minutes to provision the function app and deploy it to Azure.

   <a name="deployment-resources"></a>

   ```output
   Packaging services (azd package)

   (✓) Done: Packaging service function
   - Build Output: C:\GitHub\APICenter-Analyzer
   - Package Output: C:\Users\<user>\AppData\Local\Temp\api-center-analyzer-function-azddeploy-0123456789.zip

   Loading azd .env file from current environment

   Provisioning Azure resources (azd provision)
   Provisioning Azure resources can take some time.

   Subscription: <your_selected_subscription>
   Location: <your_selected_region_for_this_process>

   You can view detailed progress in the Azure Portal:

   https://portal.azure.com/#view/HubsExtension/DeploymentDetailsBlade/~/overview/id/%2Fsubscriptions%2F00001111-a2a2-b3b3-c4c4-dddddd555555%2Fproviders%2FMicrosoft.Resources%2Fdeployments%2F<your_azd_environment_name-0123456789>

   (✓) Done: Resource group: <new_resource_group_for_function_app> (5.494s)
   (✓) Done: App Service plan: <new_app_service_plan> (5.414s)
   (✓) Done: Storage account: <new_storage_account> (25.918s)
   (✓) Done: Log Analytics workspace: <new_workspace> (25.25s)
   (✓) Done: Application Insights: <new_application_insights> (5.628s)
   (✓) Done: Portal dashboard: <new_dashboard> (1.63s)
   (✓) Done: Function App: <new_function_app> (39.402s)
   ```

   The output includes a link to monitor the deployment progress in the Azure portal.

1. After provisioning completes, the process deploys the new function app to the Azure portal:

   ```output
   Deploying services (azd deploy)

   (✓) Done: Deploying service function
   - Endpoint: https://<new_function_app>.azurewebsites.net/

   Configuring EventGrid subscription for API Center

   Examples from AI knowledge base
   ```

1. When the deployment completes, [confirm the new function app is present and the function is published](#confirm-function-published-in-azure-portal).

   If the `apicenter-analyer` function isn't listed or the **Status** isn't **Enabled**, [publish the function](#publish-apicenter-analyzer-function-with-azure-functions-core-tools) by using the Azure Functions Core Tools.

1. [Configure an event subscription](#configure-event-subscription-with-the-azure-cli) by using PowerShell or a bash shell in Visual Studio Code.

#### Publish apicenter-analyzer function with Azure Functions Core Tools

If the deployment process doesn't publish the `apicenter-analyer` function to the function app in the Azure portal, you can run the following commands in a Visual Studio Code terminal and complete the process.

1. Run the following command to confirm the function isn't published to the function app:

   > [!NOTE]
   > This command uses the [new resource group created by the deployment process](#deployment-resources) for the function app and not the resource group for your API center. Replace `<function-app-name>` and `<new_resource_group_for_function_app>` with your function app name and the name of the resource group for the function app.

   ```azurecli
   az functionapp function list --name <function_app_name> --resource-group <new_resource_group_for_function_app> --query "[].name" -o tsv
   ```

   The command output should be empty.

1. In **Explorer**, expand the `src/functions` folder and open the `ApiAnalyzerFunction.ts` file. This action confirms the environment is set to look for content in the correct location.

1. Confirm your environment includes the npm package manager and node runtime environment, and install any tools as needed:

   ```azurecli
   node --version
   npm --version
   ```

1. As needed, install the Azure Functions Code Tools into the environment:

   ```azurecli
   npm install -g azure-functions-core-tools@4 --unsafe-perm true
   ```

1. Run the following command to publish the function code to the function app in the Azure portal. Replace `<function-app-name>` with your function app name.

   ```azurecli
   func azure functionapp publish <function_app_name> --typescript
   ```

   The command shows the following output:

   ```output
   Getting site publishing info...
   [2026-02-26T19:58:38.779Z] Starting the function app deployment...
   Uploading package...
   Uploading 33.8 MB [###############################################################################]
   Upload completed successfully.
   Deployment completed successfully.
   apicenter-analyzer - [eventGridTrigger]
   ```

1. In the Azure portal, confirm the `apicenter-analyer` function is now [published and enabled for your function app](#confirm-function-published-in-azure-portal).

### Configure event subscription with the Azure CLI

After the function is successfully published to the function app in the Azure portal, you can [configure an event subscription](#configure-event-subscription-programatically) by using PowerShell or a bash shell. Then browse to your API center in the Azure portal, and confirm the new event subscription under **Events** > **Event Subscriptions**.

You can now upload an API definition file to your API center to [trigger the event subscription](#trigger-event-in-your-api-center) and run the linting engine.


## Manual steps to configure function app and event subscription

This section provides the manual deployment steps to configure the function app and event subscription to enable linting and analysis in your API center.

- Step 1: Deploy a function app to run the linting function on your API definitions.
- Step 2: Configure a system-assigned managed identity for the function app (Azure portal or the Azure CLI).
- Step 3: Create an event subscription to trigger the function app when you upload or change an API definition (Azure portal or the Azure CLI).

If you prefer automated deployment, you can use the [Azure Developer CLI (azd)](#use-azd-deployment-for-function-app-and-event-subscription).

### Other prerequisites for this option

* Visual Studio Code with the [Azure Functions extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azurefunctions) version v1.10.4 or later.

### Deploy your function app

To deploy the function app that runs the linting function on API definitions:

1. Clone the [GitHub repository](https://github.com/Azure/APICenter-Analyzer/) and open it in Visual Studio Code.

1. In the `resources/rulesets` folder, locate the `oas.yaml` file. This file reflects your current API style guide and can be modified based on your organizational needs and requirements.

1. (Optional) Run the function app locally to test it. For more information, see the [README](https://github.com/Azure/APICenter-Analyzer/tree/preview#-configure--run-your-function-locally) file in the repository.

1. Deploy the function app to Azure. For instructions, see [Quickstart: Create and deploy function code to Azure by using Visual Studio Code (TypeScript)](/azure/azure-functions/how-to-create-function-vs-code?pivot=programming-language-typescript&tabs=go%2Cwindows&pivots=programming-language-typescript#sign-in-to-azure).

   > [!NOTE]
   > Deploying the function app can take several minutes.

### Confirm function published in Azure portal

When the deployment completes, confirm the new function app is present in the Azure portal and the function is published.

1. Sign in to the [Azure portal](https://portal.azure.com), browse to the **Function App** section, and select your new function app in the list.

1. On the **Overview** page for the new function app, confirm the function app **Status** is **Running**.

1. In the **Functions** section, confirm the `apicenter-analyer` function is listed and the **Status** is **Enabled**.
   
   :::image type="content" source="media/enable-api-analysis-linting/function-app-status.png" alt-text="Screenshot of the function app in the Azure portal showing the Running status and Enabled function.":::

### Configure managed identity in your function app

To enable the function app to access the API center, configure a managed identity for the function app. The following steps show how to enable and configure a system-assigned managed identity for the function app by using the Azure portal or the Azure CLI. 

#### [Portal](#tab/portal)

1. In the Azure portal, browse to the **Overview** page for your function app.

1. Expand **Settings** and select **Identity**.

1. On the **System assigned** tab, set the **Status** to **On** and then select **Save**.

After the managed identity is enabled, assign it the Azure API Center Compliance Manager role to access the API center.

1. In the [Azure portal](https://portal.azure.com), browse to your API center, and select **Access control (IAM)**.

1. Select **+ Add > Add role assignment**.

1. On the **Job function roles** tab, select **Azure API Center Compliance Manager** in the list, and select **Next**.

1. On the **Members** page, in the **Assign access to** box, select **Managed identity**, and then choose **+ Select members**.

1. On the **Select managed identities** page, search for and select the managed identity of the function app. Choose **Select**.

1. On the **Add role assignment** page, select **Next**.

1. Review the role assignment, and select **Review + assign**.

#### [Azure CLI](#tab/cli)

1. Enable the system-assigned identity of the function app by using the [az functionapp identity assign](/cli/azure/functionapp/identity#az-functionapp-identity-assign) command. The following command stores the principal ID of the system-assigned managed identity in the `principalID` variable.

   Replace `<function-app-name>` and `<resource-group-name>` with your function app name and the name of the resource group for your function app. 

    ```azurecli
    #! /bin/bash
    principalID=$(az functionapp identity assign --name <function-app-name> \
        --resource-group <resource-group-name> --identities [system] \
        --query "principalId" --output tsv)
    ```

    ```azurecli
    # PowerShell syntax
    $principalID=$(az functionapp identity assign --name <function-app-name> `
        --resource-group <resource-group-name> --identities [system] `
        --query "principalId" --output tsv)
    ```

1. Get the resource ID of your API center.

   Replace `<apic-name>` and `<resource-group-name>` with your API center name and the name of the resource group for your API center.

    ```azurecli
    #! /bin/bash
    apicID=$(az apic show --name <apic-name> --resource-group <resource-group-name> \
        --query "id" --output tsv)
    ```

    ```azurecli
    # PowerShell syntax
    $apicID=$(az apic show --name <apic-name> --resource-group <resource-group-name> `
        --query "id" --output tsv)
    ```

1. Assign the function app's managed identity the Azure API Center Compliance Manager role in the API center using the [az role assignment create](/cli/azure/role/assignment#az-role-assignment-create) command. 

    ```azurecli
    #! /bin/bash
    az role assignment create \
        --role "Azure API Center Compliance Manager" \
        --assignee-object-id $principalID \
        --assignee-principal-type ServicePrincipal \
        --scope $apicID 
    ```

    ```azurecli
    # PowerShell syntax
    az role assignment create `
        --role "Azure API Center Compliance Manager" `
        --assignee-object-id $principalID `
        --assignee-principal-type ServicePrincipal `
        --scope $apicID 
    ```
---

### Configure event subscription in your API center

Now create an event subscription in your API center to trigger the function app when an API definition file is uploaded or updated. The following steps show how to create the event subscription by using the Azure portal or the Azure CLI.

#### [Portal](#tab/portal)

1. In the [Azure portal](https://portal.azure.com), browse to your API center, and select **Events**.

1. Select **+ Event Subscription**.

1. On the **Create Event Subscription** page, complete the following configuration:

   1. Enter a descriptive **Name** for the event subscription.
   
   1. For the **Event Schema**, select **Event Grid Schema**.
   
   1. Expand the **Event Types** dropdown list, and select the checkboxes for the following events:
   
      - **API definition added**
      - **API definition updated**

   1. Expand the **Endpoint Details** dropdown list, and select **Azure Function**.
   
   1. To provide an **Endpoint** value, select **Configure an endpoint**.

      In the **Select Azure Function** page, configure the following settings:

      1. Select the **Subscription** for your API center, and **Resource group** for your new function app.

      1. As needed, provide a **System Topic Name** under **Topic details**.

      1. Set the **Function app** to your new function app.

      The **Slot** and **Function** values are configured for you based on your other selections.

      Select **Confirm Selection**.

   1. Select **Create**.

      :::image type="content" source="media/enable-api-analysis-linting/create-event-subscription.png" alt-text="Screenshot of creating the event subscription in the Azure portal.":::

1. Select the **Event Subscriptions** tab, and select **Refresh**.

1. At the bottom of the page, locate the new event subscription in the list and confirm the **Provisioning state** is **Succeeded**.

   :::image type="content" source="media/enable-api-analysis-linting/event-subscription-provisioning-state.png" alt-text="Screenshot of the state of the event subscription in the Azure portal." lightbox="media/enable-api-analysis-linting/event-subscription-provisioning-state.png":::

#### [Azure CLI](#tab/cli)

<a name="configure-event-subscription-programatically"></a>

1. Get the resource ID of your API center. Substitute `<apic-name>` and `<resource-group-name>` with your API center name and the name of the resource group for your API center.

    ```azurecli
    #! /bin/bash
    apicID=$(az apic show --name <apic-name> --resource-group <resource-group-name> \
        --query "id" --output tsv)
    ```

    ```azurecli
    # PowerShell syntax
    $apicID=$(az apic show --name <apic-name> --resource-group <resource-group-name> `
        --query "id" --output tsv)
    ```

1. Get the resource ID of the function in the function app. In this example, the function name is *apicenter-analyzer*. Substitute `<function-app-name>` and `<resource-group-name>` with your function app name and the name of the resource group for your function app.

    ```azurecli
    #! /bin/bash
    functionID=$(az functionapp function show --name <function-app-name> \
        --function-name apicenter-analyzer --resource-group <resource-group-name> \
        --query "id" --output tsv)
    ```

    ```azurecli
    # PowerShell syntax
    $functionID=$(az functionapp function show --name <function-app-name> `
        --function-name apicenter-analyzer --resource-group <resource-group-name> `
        --query "id" --output tsv)
    ```

1. Create an event subscription by using the [az eventgrid event-subscription create](/cli/azure/eventgrid/event-subscription#az-eventgrid-event-subscription-create) command. The created subscription includes events for adding or updating API definitions.

    ```azurecli
    #! /bin/bash
    az eventgrid event-subscription create --name MyEventSubscription \
        --source-resource-id "$apicID" --endpoint "$functionID" \
        --endpoint-type azurefunction --included-event-types \
        Microsoft.ApiCenter.ApiDefinitionAdded Microsoft.ApiCenter.ApiDefinitionUpdated
    ```

    ```azurecli
    # PowerShell syntax
    az eventgrid event-subscription create --name MyEventSubscription `
        --source-resource-id "$apicID" --endpoint "$functionID" `
        --endpoint-type azurefunction --included-event-types `
        Microsoft.ApiCenter.ApiDefinitionAdded Microsoft.ApiCenter.ApiDefinitionUpdated
    ```

    The command output shows details of the event subscription. You can also get details by using the [az eventgrid event-subscription show](/cli/azure/eventgrid/event-subscription#az-eventgrid-event-subscription-show) command:

    ```azurecli
    az eventgrid event-subscription show --name MyEventSubscription --source-resource-id "$apicID"
    ```
---

> [!NOTE]
> It can take a short time for the event subscription to propagate to the function app.

## Trigger event in your API center

To test the event subscription, try uploading or updating an API definition file associated with an API version in your API center. For example, upload an OpenAPI or AsyncAPI document. After the event subscription is triggered, the function app invokes the API linting engine to analyze the API definition.

* For detailed steps to add an API, API version, and API definition to your API center, see [Tutorial: Register APIs in your API center](./tutorials/register-apis.md).

* To create an API by uploading an API definition file with the Azure CLI, see [Register API from a specification file](manage-apis-azure-cli.md#register-api-from-a-specification-file---single-step).

To confirm that the event subscription is triggered:

1. Browse to your API center, and select **Events**.

1. Select the **Event Subscriptions** tab and select the event subscription for your function app.

1. Review the metrics to confirm the event subscription is triggered and linting is invoked successfully.

   :::image type="content" source="media/enable-api-analysis-linting/event-subscription-metrics.png" alt-text="Screenshot of the metrics for the event subscription in the portal.":::

   > [!NOTE]
   > It might take a few minutes for the metrics to appear.

After the system analyzes the API definition, the linting engine generates a report based on the configured API style guide.

## View API analysis reports

You can view the analysis report for your API definition in the Azure portal. After an API definition is analyzed, the report lists errors, warnings, and information based on the configured API style guide. 

In the portal, you can also view a summary of analysis reports for all API definitions in your API center.

### Analysis report for an API definition

To view the analysis report for an API definition in your API center:

1. In the portal, browse to your API center, expand **Inventory**, and select **Assets**.

1. In the **Asset** list, select the API for which you added or updated an API definition.

1. Select **Versions**, and then expand the row for the API to examine. 

1. Under **Definition**, select the definition name that you uploaded or updated.

1. Select the **Analysis** tab.

   :::image type="content" source="media/enable-api-analysis-linting/analyze-api-definition.png" alt-text="Screenshot of the Analysis tab for an API definition in the Azure portal.":::

The **API Analysis Report** opens, and it displays the API definition and errors, warnings, and information based on the configured API style guide. The following screenshot shows an example of an API analysis report.

:::image type="content" source="media/enable-api-analysis-linting/api-analysis-report.png" alt-text="Screenshot of an API analysis report in the portal." lightbox="media/enable-api-analysis-linting/api-analysis-report.png":::

### API analysis summary

You can view a summary of analysis reports for all API definitions in your API center.

- In the portal, browse to your API center, expand **Governance**, and select **API Analysis**.

   :::image type="content" source="media/enable-api-analysis-linting/api-analysis-summary.png" alt-text="Screenshot of the API analysis summary in the portal.":::

- The icon at the right on each row opens the **API Analysis Report** for the definition.

## Related content

* [Enable API analysis in your API center - Microsoft managed](enable-managed-api-analysis-linting.md)
* [System topics in Azure Event Grid](../event-grid/system-topics.md)
* [Event Grid push delivery - concepts](../event-grid/concepts.md)
* [Event Grid schema for Azure API Center](../event-grid/event-schema-api-center.md)
