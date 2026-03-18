---
title: "Tutorial: Durable text analysis with a mounted Azure Files share in Azure Functions"
description: Learn how to deploy a Python Azure Functions app that uses Durable Functions to orchestrate parallel text file analysis by using a mounted Azure Files share on a Flex Consumption plan.
ms.service: azure-functions
ms.topic: tutorial
ms.date: 03/11/2026
ms.custom:
  - devx-track-azurecli
  - devx-track-python
#customer intent: As a developer, I want to deploy a Durable Functions app on the Flex Consumption plan with Azure Files storage mounts so I can analyze multiple text files in parallel without managing infrastructure.
---

# Tutorial: Durable text analysis with a mounted Azure Files share

In this tutorial, you deploy a Python Azure Functions app that uses [Durable Functions](./durable/durable-functions-overview.md) to orchestrate parallel text file analysis. Your function app mounts an Azure Files share, analyzes multiple text files in parallel (fan-out), aggregates the results (fan-in), and returns them to the caller. This approach demonstrates a key advantage of storage mounts: shared file access across multiple function instances without per-request network overhead.

In this tutorial, you:

> [!div class="checklist"]
> * Deploy a Durable Functions app in a Flex Consumption plan with a mounted Azure Files share using Bicep
> * Upload sample text files to the mounted Azure Files share
> * Deploy a Python function app that uses a [fan-out/fan-in pattern](./durable/durable-functions-fan-in-fan-out.md?pivots=durable-functions) to analyze text files in parallel
> * Trigger an orchestration to process the files and verify results

[!INCLUDE [functions-azure-files-samples-note](../../includes/functions-azure-files-samples-note.md)]

## Prerequisites

- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn)
- [Azure CLI](/cli/azure/install-azure-cli) version 2.60.0 or later
- [Azure Functions Core Tools](./functions-run-local.md) version 4.x or later
- [Python 3.9 or later](https://www.python.org/downloads/)
- [Git](https://git-scm.com/)

## Clone the repository

```bash
git clone https://github.com/Azure-Samples/Azure-Functions-Flex-Consumption-with-Azure-Files-OS-Mount-Samples.git
cd Azure-Functions-Flex-Consumption-with-Azure-Files-OS-Mount-Samples/durable-text-analysis
```

## Create Azure resources

This tutorial uses Bicep to automate resource creation.

1. Sign in to Azure:

    ```azurecli
    az login
    ```

1. If you have multiple subscriptions, set the one you want to use:

    ```azurecli
    az account set --subscription <YOUR_SUBSCRIPTION_ID>
    ```

1. Create a resource group:

    ```azurecli
    RESOURCE_GROUP="rg-durable-text"
    LOCATION="eastus"

    az group create --name $RESOURCE_GROUP --location $LOCATION
    ```

1. Deploy infrastructure by using Bicep:

    ```azurecli
    az deployment group create \
      --resource-group $RESOURCE_GROUP \
      --template-file infra/main.bicep \
      --parameters infra/main.bicepparam
    ```

    This deployment creates the following resources:

    - Storage account with an Azure Files share
    - Durable Functions app in a Flex Consumption plan
    - Application Insights for monitoring
    - Managed identity with permissions to the storage account

1. After the deployment succeeds, save the resource names for later steps:

    ```azurecli
    STORAGE_ACCOUNT=$(az deployment group show \
      --resource-group $RESOURCE_GROUP \
      --name main \
      --query properties.outputs.storageAccountName.value \
      -o tsv)
    FUNCTION_APP_NAME=$(az deployment group show \
      --resource-group $RESOURCE_GROUP \
      --name main \
      --query properties.outputs.functionAppName.value \
      -o tsv)
    SHARE_NAME="text-data"

    echo "Storage Account: $STORAGE_ACCOUNT"
    echo "Function App: $FUNCTION_APP_NAME"
    echo "Share Name: $SHARE_NAME"
    ```

> [!NOTE]
> If you're using Azure Cloud Shell, shell variables don't persist between sessions. If your session times out, rerun the variable assignments in this section before continuing.

## Verify the storage mount configuration

1. The Bicep deployment creates the Azure Files share and configures the mount on your function app. Verify that it's set up correctly:

    ```azurecli
    az storage share list \
      --account-name $STORAGE_ACCOUNT \
      --query "[].name" \
      -o table
    ```
    
    Expected output:
    
    ```
    Name
    ------
    text-data
    ```

1. Verify the mount configuration on the function app:

    ```azurecli
    az functionapp config appsettings list \
      --resource-group $RESOURCE_GROUP \
      --name $FUNCTION_APP_NAME \
      | grep -i mount
    ```
    
    > [!TIP]
    > The storage mount typically appears at `/mnt/filedata` inside the function container. Your app settings map this local path to the Azure Files share.

    If you don't see mount configuration settings, manually configure the mount in the Azure portal under **Settings** > **Configuration** > **Path Mappings**.

## Upload sample text files

1. Create local sample files:

    ```bash
    mkdir -p sample_texts
    cat > sample_texts/file1.txt << 'EOF'
    Azure Functions is a serverless compute service that lets you run code on-demand without managing infrastructure.
    EOF

    cat > sample_texts/file2.txt << 'EOF'
    Durable Functions extends Azure Functions with workflow capabilities like orchestration and state management.
    EOF

    cat > sample_texts/file3.txt << 'EOF'
    Azure Files provides managed file shares in the cloud accessible via the SMB protocol.
    EOF
    ```

1. Upload files to the Azure Files share:

    ```azurecli
    STORAGE_KEY=$(az storage account keys list \
      --resource-group $RESOURCE_GROUP \
      --account-name $STORAGE_ACCOUNT \
      --query "[0].value" \
      -o tsv)

    az storage file upload-batch \
      --destination $SHARE_NAME \
      --source sample_texts \
      --account-name $STORAGE_ACCOUNT \
      --account-key $STORAGE_KEY
    ```

1. Verify the upload:

    ```azurecli
    az storage file list \
      --share-name $SHARE_NAME \
      --account-name $STORAGE_ACCOUNT \
      --account-key $STORAGE_KEY \
      -o table
    ```

    Expected output:

    ```
    Name
    ------
    file1.txt
    file2.txt
    file3.txt
    ```

## Prepare and deploy the function app

1. Make sure the required app settings exist on the remote function app. This command can be run even if these settings already exist:

    ```azurecli
    az functionapp config appsettings set \
      --resource-group $RESOURCE_GROUP \
      --name $FUNCTION_APP_NAME \
      --settings MOUNT_PATH=/mnt/filedata
    ```

1. Publish the function app to Azure. The `--build remote` flag installs Python dependencies on the server, so you don't need to install them locally:

    ```bash
    func azure functionapp publish $FUNCTION_APP_NAME --build remote
    ```

## Trigger the orchestration

1. Get the function URL and host key:

    ```azurecli
    HOST_KEY=$(az functionapp keys list \
      --resource-group $RESOURCE_GROUP \
      --name $FUNCTION_APP_NAME \
      --query "functionKeys.default" \
      -o tsv)

    FUNCTION_URL="https://${FUNCTION_APP_NAME}.azurewebsites.net/api/orchestrators/TextAnalysisOrchestrator"
    ```

1. Start the orchestration:

    ```bash
    curl -X POST "$FUNCTION_URL" \
      -H "x-functions-key: $HOST_KEY" \
      -H "Content-Type: application/json" \
      -d '{}'
    ```

    The response includes an instance ID and status query URIs:

    ```json
    {
      "id": "abc123def456",
      "statusQueryGetUri": "https://...",
      "sendEventPostUri": "https://...",
      "terminatePostUri": "https://..."
    }
    ```

## Verify results

1. Check orchestration status. Use the `statusQueryGetUri` from the previous response, or construct the URL manually:

    ```bash
    INSTANCE_ID="<instance-id-from-trigger-response>"

    curl "https://${FUNCTION_APP_NAME}.azurewebsites.net/api/orchestrators/TextAnalysisOrchestrator/${INSTANCE_ID}" \
      -H "x-functions-key: $HOST_KEY"
    ```

    While the orchestration is running, the `runtimeStatus` is `Running`. When complete, the response looks like:

    ```json
    {
      "name": "TextAnalysisOrchestrator",
      "instanceId": "abc123def456",
      "runtimeStatus": "Completed",
      "output": {
        "results": [
          {
            "file": "file1.txt",
            "word_count": 15,
            "char_count": 98,
            "sentiment": "positive"
          },
          {
            "file": "file2.txt",
            "word_count": 18,
            "char_count": 120,
            "sentiment": "positive"
          },
          {
            "file": "file3.txt",
            "word_count": 12,
            "char_count": 85,
            "sentiment": "neutral"
          }
        ],
        "total_words": 45,
        "total_chars": 303,
        "analysis_duration_seconds": 2.34
      }
    }
    ```

> [!TIP]
> Your function app accessed all three files in parallel through the storage mount. No per-request network calls were needed. The function read them directly from the mounted share by using standard file I/O. This approach demonstrates the power of storage mounts combined with Durable Functions.

## Clean up resources

To avoid ongoing charges, delete the resource group when you no longer need the resources:

```azurecli
az group delete --name $RESOURCE_GROUP --yes
```

> [!WARNING]
> This command deletes the resource group and all resources in it, including the function app, storage account, and Application Insights instance.

## Related content

- [Durable Functions overview](./durable/durable-functions-overview.md)
- [Choose a file access strategy for Azure Functions](./concept-file-access-options.md)
- [Tutorial: Process images by using FFmpeg on a mounted Azure Files share](./tutorial-ffmpeg-processing-azure-files.md)
- [Flex Consumption plan](./flex-consumption-plan.md)
- [Storage considerations for Azure Functions](./storage-considerations.md)
