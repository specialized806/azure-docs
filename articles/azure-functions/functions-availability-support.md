---
title: Configure regional and zone availability for Azure Functions
description: Learn how to configure regional and zone availability for Azure Functions, create zone-redundant Function Apps, and migrate existing apps to availability zone support.
author: glynnniall
ms.author: glynnniall
ms.topic: how-to
ms.service: azure-functions
ms.custom: references_regions
ms.date: 02/19/2026
zone_pivot_groups: reliability-functions-hosting-plan

#Customer intent: I want to configure my Azure Functions with availability zone support to improve resilience and handle zonal failures.
---

# Configure regional and zone availability for Azure Functions

This article provides step-by-step guidance for configuring availability zones with Azure Functions. For conceptual information about how availability zones work with Azure Functions, see [Reliability in Azure Functions](/azure/reliability/reliability-functions).

Availability zone configuration for Azure Functions depends on your [Functions hosting plan](/azure/azure-functions/functions-scale):

| Hosting plan | Support level | Configuration section |
| ----- | ----- | ----- |
| [Flex Consumption plan](/azure/azure-functions/flex-consumption-plan) | GA | Select **Flex Consumption** at the top of this article. |
| [Elastic Premium plan](/azure/azure-functions/functions-premium-plan) | GA | Select **Premium** at the top of this article. |
| [Dedicated (App Service) plan](/azure/azure-functions/dedicated-plan) | GA | See [Configure availability zones for App Service](../app-service/how-to-zone-redundancy.md). |
| [Consumption plan](/azure/azure-functions/consumption-plan) | n/a | Not supported by the Consumption plan. |

## Prerequisites

::: zone pivot="flex-consumption-plan"
Before configuring availability zones for Flex Consumption plans:

- You must use a [zone redundant storage account (ZRS)](/azure/storage/common/storage-redundancy#zone-redundant-storage) for your function app's [default host storage account](/azure/azure-functions/storage-considerations#storage-account-requirements). If you use a different type of storage account, your app might behave unexpectedly during a zonal outage.
- Must be hosted on a [Flex Consumption](/azure/azure-functions/flex-consumption-plan) plan.
- You can [enable availability zones in the plan during app creation](#create-a-zone-redundant-flex-consumption-function-app).
- You can [enable or disable availability zones](#update-a-flex-consumption-plan-to-be-zone-redundant) by updating plan resource settings.

::: zone-end

::: zone pivot="premium-plan"

Before configuring availability zones for Premium plans:

- You can only enable availability zones in the plan when you create your app. You can't convert an existing Premium plan to use availability zones.
- You must use a [zone redundant storage account (ZRS)](/azure/storage/common/storage-redundancy#zone-redundant-storage) for your function app's [default host storage account](/azure/azure-functions/storage-considerations#storage-account-requirements). If you use a different type of storage account, your app might behave unexpectedly during a zonal outage.
- Both Windows and Linux are supported.
- Function apps hosted on a Premium plan must have a minimum of three [always ready instances](/azure/azure-functions/functions-premium-plan#always-ready-instances).
- The platform enforces this minimum count behind the scenes if you specify an instance count fewer than three.
- If you aren't using Premium plan or a scale unit that supports availability zones, are in an unsupported region, or are unsure, see [Migrate existing Function Apps to availability zone support](#migrate-existing-function-apps-to-availability-zone-support-premium).

::: zone-end

## Regional availability

::: zone pivot="flex-consumption-plan"
Currently, not all regions support zone redundancy for Flex Consumption plans. You can use the Azure CLI to view the regions that do support it:

1. If you haven't done so already, install and sign in to Azure using the Azure CLI:

    ```azurecli
    az login
    ```

    The [`az login`](/cli/azure/reference-index#az-login) command signs you into your Azure account.

2. Use this [`az functionapp list-flexconsumption-locations`](/cli/azure/functionapp#az-functionapp-list-flexconsumption-locations) command with the `--zone-redundant=true` option to return a list of regions that currently support zone-redundant Flex Consumption plans:

    ```azurecli-interactive
    az functionapp list-flexconsumption-locations --zone-redundant=true --query "sort_by(@, &name)[].{Region:name}" -o table
    ```

When you [create a Flex Consumption app](#create-a-zone-redundant-flex-consumption-function-app) in the Azure portal, the `Zone redundancy` section of the **Basics** page is enabled when your chosen region supports it.

::: zone-end

::: zone pivot="premium-plan"

Zone-redundant Premium plans are available in these regions:

| Americas         | Europe               | Middle East    | Africa             | Asia Pacific   |
|------------------|----------------------|----------------|--------------------|----------------|
| Brazil South     | France Central       | Israel Central | South Africa North | Australia East |
| Canada Central   | Germany West Central | Qatar Central  |                    | Central India  |
| Central US       | Italy North          | UAE North      |                    | China North 3  |
| East US          | North Europe         |                |                    | East Asia      |
| East US 2        | Norway East          |                |                    | Japan East     |
| South Central US | Sweden Central       |                |                    | Southeast Asia |
| West US 2        | Switzerland North    |                |                    |                |
| West US 3        | UK South             |                |                    |                |
|                  | West Europe          |                |                    |                |

::: zone-end

## Create a zone-redundant Function App

::: zone pivot="flex-consumption-plan"

### Create a zone-redundant Flex Consumption function app

There are currently multiple ways to deploy a zone-redundant Flex Consumption app.

#### [Azure portal](#tab/azure-portal)

1. To create a function app in a zone-redundant plan, you must have an existing [zone-redundant storage account](/azure/azure-functions/storage-considerations#storage-account-requirements). If you don't already have a zone-redundant storage account, create one before you proceed.

1. In the Azure portal, go to the **Create Function App** page. For more information about creating a function app in the portal, see [Create a function app](/azure/azure-functions/functions-create-function-app-portal#create-a-function-app).

1. Select **Flex Consumption** and then select the **Select** button.

1. On the **Create Function App (Flex Consumption)** page, on the **Basics** tab, enter the settings for your function app. Pay special attention to the settings in the following table (also highlighted in the following screenshot), which have specific requirements for zone redundancy.

    |Setting|Suggested value|Notes for zone redundancy|
    |-------|---------------|-------------------------|
    |**Region**|Your preferred supported region|The region in which your Flex Consumption plan is created. You must select a region that supports availability zones. See the [region availability list](#regional-availability).|
    |**Zone redundancy**|Enabled|This setting specifies whether your app is zone redundant. You can only select `Enabled` when you've chosen a region that supports zone redundancy.|

    :::image type="content" source="/azure/azure-functions/media/functions-az-redundancy/azure-functions-flex-basics-az.png" alt-text="Screenshot of the Basics tab of the Flex Consumption function app create page.":::

1. On the **Storage** tab, select the zone-redundant storage account for your function app. Pay special attention to the setting in the following table, which has specific requirements for zone redundancy.

    |Setting|Suggested value|Notes for zone redundancy|
    |-------|---------------|-------------------------|
    |**Storage account**|A [zone-redundant storage account](/azure/azure-functions/storage-considerations#storage-account-requirements)|As described in the [prerequisites](#prerequisites) section, we strongly recommend using a zone-redundant storage account for your zone-redundant function app.|
  
1. For the rest of the function app creation process, create your function app as normal. There are no settings in the rest of the creation process that affect zone redundancy.

#### [Azure CLI](#tab/azure-cli)

1. When creating the storage account for the function app, choose a zone redundant SKU, like `Standard_ZRS`. For example:

    ```azurecli
    az storage account create --name <STORAGE_NAME> --location <REGION> --resource-group <RESOURCE_GROUP> --sku Standard_ZRS --allow-blob-public-access false
    ```

1. When creating the Flex Consumption plan, add the `--zone-redundant true` parameter:

    ```azurecli
    az functionapp create --resource-group <RESOURCE_GROUP> --name <APP_NAME> --storage-account <STORAGE_NAME> --flexconsumption-location <REGION> --runtime <RUNTIME> --runtime-version <RUNTIME_VERSION> --zone-redundant true 
    ```

#### [Bicep template](#tab/bicep)

You can use a [Bicep template](/azure/azure-resource-manager/bicep/quickstart-create-bicep-use-visual-studio-code) to deploy to a zone-redundant Flex Consumption plan. To learn how to deploy function apps to a Flex Consumption, see [Automate resource deployment in Azure Functions](/azure/azure-functions/functions-infrastructure-as-code?pivots=flex-consumption-plan).

The only properties to be aware of while creating a zone-redundant hosting plan are the `zoneRedundant` property. The `zoneRedundant` property must be set to `true`.

Following is a Bicep template snippet for a zone-redundant, Flex Consumption plan. It shows the `zoneRedundant` field specification.

```bicep
resource flexFuncPlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: <YOUR_PLAN_NAME>
  location: <YOUR_REGION_NAME>
  kind: 'functionapp'
  sku: {
    tier: 'FlexConsumption'
    name: 'FC1'
  }
  properties: {
    reserved: true
    zoneRedundant: true
  }
}
```

To learn more about these templates, see [Automate resource deployment in Azure Functions](/azure/azure-functions/functions-infrastructure-as-code).

#### [ARM template (Flex Consumption)](#tab/arm-template)

You can use an [ARM template](/azure/azure-resource-manager/templates/quickstart-create-templates-use-visual-studio-code) to deploy to a zone-redundant Flex Consumption plan. To learn how to deploy function apps to a Flex Consumption plan, see [Automate resource deployment in Azure Functions](/azure/azure-functions/functions-infrastructure-as-code?pivots=flex-consumption-plan).

The only properties to be aware of while creating a zone-redundant hosting plan are the `zoneRedundant` property. The `zoneRedundant` property must be set to `true`.

Following is an ARM template snippet for a zone-redundant, Flex Consumption plan. It shows the `zoneRedundant` field specification.

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": [
    {
      "type": "Microsoft.Web/serverfarms",
      "apiVersion": "2024-04-01",
      "name": "<YOUR_PLAN_NAME>",
      "location": "<YOUR_REGION_NAME>",
      "kind": "functionapp",
      "sku": {
        "tier": "FlexConsumption",
        "name": "FC1"
      },
      "properties": {
        "reserved": true,
        "zoneRedundant": true
      }
    }
  ]
}
```

To learn more about these templates, see [Automate resource deployment in Azure Functions](/azure/azure-functions/functions-infrastructure-as-code).

---

After the zone-redundant plan is created and deployed, the Flex Consumption function app hosted on your new plan is considered zone-redundant.

::: zone-end

::: zone pivot="premium-plan"

### Create a zone-redundant Premium function app

There are currently two ways to deploy a zone-redundant Premium plan and function app. You can use either the [Azure portal](https://portal.azure.com) or an ARM template.

#### [Azure portal (Premium)](#tab/azure-portal)

1. In the Azure portal, go to the **Create Function App** page. For more information about creating a function app in the portal, see [Create a function app](/azure/azure-functions/functions-create-function-app-portal#create-a-function-app).

1. Select **Functions Premium** and then select the **Select** button.

1. On the **Create Function App (Functions Premium)** page, on the **Basics** tab, enter the settings for your function app. Pay special attention to the settings in the following table (also highlighted in the following screenshot), which have specific requirements for zone redundancy.

    |Setting|Suggested value|Notes for zone redundancy|
    |-------|---------------|-------------------------|
    |**Region**|Your preferred supported region|The region in which your Elastic Premium plan is created. You must pick a region that supports availability zones. See the [region availability list](#regional-availability).|
    |**Pricing plan**|One of the Elastic Premium plans. For more information, see [Available instance SKUs](/azure/azure-functions/functions-premium-plan#available-instance-skus).|This article describes how to create a zone redundant app in a Premium plan. Zone redundancy isn't currently available in Consumption plans. For information on zone redundancy on App Service plans, see [Configure availability zones for App Service](../app-service/how-to-zone-redundancy.md).|
    |**Zone redundancy**|Enabled|This setting specifies whether your app is zone redundant. You won't be able to select `Enabled` unless you have chosen a region that supports zone redundancy, as described previously.|

    :::image type="content" source="/azure/azure-functions/media/functions-az-redundancy/azure-functions-ep-basics-az.png" alt-text="Screenshot of the Basics tab of the function app create page.":::

1. On the **Storage** tab, enter the settings for your function app storage account. Pay special attention to the setting in the following table, which has specific requirements for zone redundancy.

    |Setting|Suggested value|Notes for zone redundancy|
    |-------|---------------|-------------------------|
    |**Storage account**|A [zone-redundant storage account](/azure/azure-functions/storage-considerations#storage-account-requirements)|As described in the [prerequisites](#prerequisites) section, we strongly recommend using a zone-redundant storage account for your zone-redundant function app.|
  
1. For the rest of the function app creation process, create your function app as normal. There are no settings in the rest of the creation process that affect zone redundancy.

#### [Azure CLI (Premium)](#tab/azure-cli)

1. When creating the storage account for the function app, choose a zone redundant SKU, like `Standard_ZRS`. For example:

    ```azurecli
    az storage account create --name <STORAGE_NAME> --location <REGION> --resource-group <RESOURCE_GROUP> --sku Standard_ZRS --allow-blob-public-access false
    ```

1. When creating the Premium plan, add the `--zone-redundant true` parameter:

    ```azurecli
    az functionapp plan create --resource-group <RESOURCE_GROUP> --name <PLAN_NAME> --location <REGION> --sku EP1 --zone-redundant true
    ```

1. Create the function app and associate it with the zone-redundant Premium plan:

    ```azurecli
    az functionapp create --resource-group <RESOURCE_GROUP> --name <APP_NAME> --storage-account <STORAGE_NAME> --plan <PLAN_NAME> --runtime <RUNTIME> --runtime-version <RUNTIME_VERSION>
    ```

#### [Bicep template (Premium)](#tab/bicep)

You can use a [Bicep template](/azure/azure-resource-manager/bicep/quickstart-create-bicep-use-visual-studio-code) to deploy to a zone-redundant Premium plan. To learn how to deploy function apps to a Premium plan, see [Automate resource deployment in Azure Functions](/azure/azure-functions/functions-infrastructure-as-code?pivots=premium-plan).

The only properties to be aware of while creating a zone-redundant hosting plan are the `zoneRedundant` property and the plan's instance count (`capacity`) fields. The `zoneRedundant` property must be set to `true` and the `capacity` property should be set based on the workload requirement, but not less than `3`. Choosing the right capacity varies based on several factors and high availability / fault tolerance strategies. A good rule of thumb is to specify sufficient instances for the application to ensure that losing one zone instance leaves sufficient capacity to handle expected load.

> [!IMPORTANT]
> Azure Functions apps hosted on an Elastic Premium, zone-redundant plan must have a minimum [always ready instance](/azure/azure-functions/functions-premium-plan#always-ready-instances) count of 3. This minimum ensures that a zone-redundant function app always has enough instances to satisfy at least one worker per zone.

Following is a Bicep template snippet for a zone-redundant, Premium plan. It shows the `zoneRedundant` field and the `capacity` specification.

```bicep
resource EPFuncPlan 'Microsoft.Web/serverfarms@2024-04-01' = {
    name: '<YOUR_PLAN_NAME>'
    location: '<YOUR_REGION_NAME>'
    sku: {
        name: 'EP1'
        tier: 'ElasticPremium'
        size: 'EP1'
        family: 'EP'
        capacity: 3
    }
    kind: 'elastic'
    properties: {
        perSiteScaling: false
        elasticScaleEnabled: true
        maximumElasticWorkerCount: 20
        isSpot: false
        reserved: false
        isXenon: false
        hyperV: false
        targetWorkerCount: 0
        targetWorkerSizeId: 0
        zoneRedundant: true
    }
}
```

To learn more about these templates, see [Automate resource deployment in Azure Functions](/azure/azure-functions/functions-infrastructure-as-code).

#### [ARM template](#tab/arm-template)

You can use an [ARM template](/azure/azure-resource-manager/templates/quickstart-create-templates-use-visual-studio-code) to deploy to a zone-redundant Premium plan. To learn how to deploy function apps to a Premium plan, see [Automate resource deployment in Azure Functions](/azure/azure-functions/functions-infrastructure-as-code?pivots=premium-plan).

The only properties to be aware of while creating a zone-redundant hosting plan are the `zoneRedundant` property and the plan's instance count (`capacity`) fields. The `zoneRedundant` property must be set to `true` and the `capacity` property should be set based on the workload requirement, but not less than `3`. Choosing the right capacity varies based on several factors and high availability / fault tolerance strategies. A good rule of thumb is to specify sufficient instances for the application to ensure that losing one zone instance leaves sufficient capacity to handle expected load.

> [!IMPORTANT]
> Azure Functions apps hosted on an Elastic Premium, zone-redundant plan must have a minimum [always ready instance](/azure/azure-functions/functions-premium-plan#always-ready-instances) count of 3. This minimum ensures that a zone-redundant function app always has enough instances to satisfy at least one worker per zone.

Following is an ARM template snippet for a zone-redundant, Premium plan. It shows the `zoneRedundant` field and the `capacity` specification.

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": [
    {
        "type": "Microsoft.Web/serverfarms",
        "apiVersion": "2024-04-01",
        "name": "<YOUR_PLAN_NAME>",
        "location": "<YOUR_REGION_NAME>",
        "sku": {
            "name": "EP1",
            "tier": "ElasticPremium",
            "size": "EP1",
            "family": "EP", 
            "capacity": 3
        },
        "kind": "elastic",
        "properties": {
            "perSiteScaling": false,
            "elasticScaleEnabled": true,
            "maximumElasticWorkerCount": 20,
            "isSpot": false,
            "reserved": false,
            "isXenon": false,
            "hyperV": false,
            "targetWorkerCount": 0,
            "targetWorkerSizeId": 0, 
            "zoneRedundant": true
        }
    }
  ]
}
```

To learn more about these templates, see [Automate resource deployment in Azure Functions](/azure/azure-functions/functions-infrastructure-as-code).

---

After the zone-redundant plan is created and deployed, any function app hosted on your new plan is considered zone-redundant.

::: zone-end

## Update a Flex Consumption plan to be zone-redundant

::: zone pivot="flex-consumption-plan"

Changing the zone redundancy of your app requires a restart, which causes downtime in your app.

Before updating your Flex Consumption plan to be zone-redundant, you should update the default host storage account to also be zone redundant. If you use a separate storage account for the app's deployment container, you should update it to be zone redundant as well.

Use these steps to prepare your storage accounts for the change:

1. Review [Storage Considerations](/azure/azure-functions/storage-considerations).
1. Create or identify a zone-redundant storage account to be the default host storage account for the app.
1. Update the storage related application settings of the app, like `AzureWebJobsStorage`, to reference the zone redundant storage account. See [Work with application settings](/azure/azure-functions/functions-how-to-use-azure-function-app-settings#use-application-settings).
1. Update the deployment storage account for the app, which can be the same or different as the storage account associated with the app. See [Configure deployment settings](/azure/azure-functions/flex-consumption-how-to#configure-deployment-settings).

After the storage accounts used by your app are updated, you can update the Flex Consumption plan to be zone-redundant using Bicep or ARM templates. The Azure portal currently doesn't support making zone redundancy updates to the plan.

### Update zone redundancy settings

#### [Azure portal (Update)](#tab/azure-portal)

1. In the Azure portal, search for and select the function app to update.

1. Under **Settings**, select **Scale and Concurrency**.

1. On the **Zone redundancy** tab, check **Add zone redundancy** to enable the feature. If already checked, you can uncheck this box to disable the feature.

1. Select **Save** to commit your changes and restart the app.

:::image type="content" source="/azure/azure-functions/media/functions-az-redundancy/azure-functions-flex-update-az.png" alt-text="Screenshot of the Scale and Concurrency tab of a Flex Consumption function app.":::

#### [Azure CLI (Update Flex)](#tab/azure-cli)

Update the app by using the `--zone-redundant` parameter of the [az functionapp plan update](/cli/azure/functionapp/plan#az-functionapp-plan-update) command. Use a value of `true` to enable zone redundancy and `false` disable the feature. This example enables zone redundancy for an existing app in a Flex Consumption plan:

```azurecli
PLAN_RESOURCE_ID=$(az functionapp show --resource-group <RESOURCE_GROUP> --name <APP_NAME> --query "properties.serverFarmId"  -o tsv) 

az functionapp plan update --ids $PLAN_RESOURCE_ID --set zoneRedundant=true
```

In this example, replace `<RESOURCE_GROUP>` and `<APP_NAME>` with the names of your resource group and app, respectively.

#### [Bicep template (Update)](#tab/bicep)

You can use this Bicep file to add the `zoneRedundant` property to `true` in an existing plan definition:

```bicep
resource existingServerFarm 'Microsoft.Web/serverfarms@2024-04-01' existing = {
  name: '<YOUR_PLAN_NAME>'
  scope: resourceGroup()
}

resource updatedServerFarm 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: existingServerFarm.name
  location: '<YOUR_REGION_NAME>'
  kind: 'functionapp'
  sku: {
    tier: 'FlexConsumption'
    name: 'FC1'
  }
  properties: {
    reserved: true
    zoneRedundant: true  // Enables zone redundancy
  }
}
```

In this file, replace `<YOUR_PLAN_NAME>` and `<YOUR_REGION_NAME>` with the name of your plan and region, respectively. To learn how to deploy a Bicep file, see [Deploy your template](/azure/azure-functions/functions-infrastructure-as-code#deploy-your-template).

#### [ARM template (Update)](#tab/arm-template)

You can use this ARM template fragment to set the `zoneRedundant` property to `true` in an existing plan definition:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": [
    {
      "type": "Microsoft.Web/serverfarms",
      "apiVersion": "2024-04-01",
      "name": "<YOUR_PLAN_NAME>",
      "location": "<YOUR_REGION_NAME>",
      "kind": "functionapp",
      "sku": {
        "tier": "FlexConsumption",
        "name": "FC1"
      },
      "properties": {
        "reserved": true,
        "zoneRedundant": true
      }
    }
  ]
}
```

In this template, replace `<YOUR_PLAN_NAME>` and `<YOUR_REGION_NAME>` with the name of your plan and region, respectively. To learn how to deploy an ARM template, see [Deploy your template](/azure/azure-functions/functions-infrastructure-as-code#deploy-your-template).

---

::: zone-end

::: zone pivot="premium-plan"

> [!NOTE]
> You can't currently change the availability zone support of an Elastic Premium plan for an existing function app. For information on how to migrate an existing Premium plan from non-availability zone to availability zone support, see [Migrate existing Function Apps to availability zone support](#migrate-existing-function-apps-to-availability-zone-support-premium).

::: zone-end

## Migrate existing Function Apps to availability zone support (Premium)

::: zone pivot="premium-plan"

You can't currently change the availability zone support of an Elastic Premium plan for an existing function app. For information on how to migrate the public multitenant Premium plan from non-availability zone to availability zone support, see [Migrate App Service to availability zone support](/azure/reliability/migrate-functions).

The migration process typically involves:

1. **Planning**: Assess your current function app configuration, dependencies, and requirements.
2. **Preparation**: Create a zone-redundant storage account and prepare your deployment artifacts.
3. **Creation**: Create a new Premium plan with zone redundancy enabled in a supported region.
4. **Migration**: Deploy your function code to the new zone-redundant plan.
5. **Testing**: Validate that your function app works correctly in the zone-redundant configuration.
6. **Cutover**: Update DNS and traffic routing to point to the new zone-redundant function app.
7. **Cleanup**: Remove the old non-zone-redundant resources after successful validation.

For detailed step-by-step migration guidance, see [Migrate Azure Functions to availability zone support](/azure/reliability/migrate-functions).

::: zone-end

::: zone pivot="flex-consumption-plan"
Flex Consumption plans support updating zone redundancy settings after creation. See [Update a Flex Consumption plan to be zone-redundant](#update-a-flex-consumption-plan-to-be-zone-redundant) for instructions.

::: zone-end

## Next steps

- [Reliability in Azure Functions](/azure/reliability/reliability-functions) - Conceptual guidance on availability zones and disaster recovery patterns
- [Automate resource deployment in Azure Functions](/azure/azure-functions/functions-infrastructure-as-code) - Learn more about Infrastructure as Code options
- [Azure Functions hosting plans](/azure/azure-functions/functions-scale) - Compare different hosting options
- [Storage considerations for Azure Functions](/azure/azure-functions/storage-considerations) - Understand storage requirements for zone-redundant setups
