---
title: "Tutorial: Process images by using FFmpeg on a mounted Azure Files share in Azure Functions"
description: Learn how to deploy a Python Azure Functions app that uses an ffmpeg binary hosted on a mounted Azure Files share to process images on a Flex Consumption plan.
ms.topic: tutorial
ms.date: 03/11/2026
ms.custom:
  - devx-track-azurecli
  - devx-track-python
#customer intent: As a developer, I want to host large third-party binaries like ffmpeg on a mounted Azure Files share so I can keep my function deployment small and cold starts fast.
---

# Tutorial: Process images by using FFmpeg on a mounted Azure Files share

In this tutorial, you deploy a Python app that uses an ffmpeg binary on a mounted Azure Files share to process images in Azure Functions. When you upload an image to the container, the function triggers, calls ffmpeg from the mount to convert the image, and saves the result back to storage. By hosting large binaries like ffmpeg on a mounted share instead of in your deployment package, you keep deployments small and cold starts fast.

In this tutorial, you:

> [!div class="checklist"]
> * Deploy Azure infrastructure by using Bicep, including a Flex Consumption plan function app with a mounted Azure Files share
> * Upload the ffmpeg binary to the mounted Azure Files share
> * Deploy a Python function app that calls ffmpeg to process images
> * Trigger and verify image processing by uploading a blob

[!INCLUDE [functions-azure-files-samples-note](../../includes/functions-azure-files-samples-note.md)]

## Prerequisites

- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn)
- [Azure CLI](/cli/azure/install-azure-cli) version 2.60.0 or later
- [Azure Functions Core Tools](./functions-run-local.md) version 4.x or later
- [Python 3.9 or later](https://www.python.org/downloads/)
- [Git](https://git-scm.com/)
- [ffmpeg](https://ffmpeg.org/download.html) installed locally (for preparing the binary to upload)

## Clone the repository

```bash
git clone https://github.com/Azure-Samples/Azure-Functions-Flex-Consumption-with-Azure-Files-OS-Mount-Samples.git
cd Azure-Functions-Flex-Consumption-with-Azure-Files-OS-Mount-Samples/ffmpeg-image-processing
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
    RESOURCE_GROUP="rg-ffmpeg-processing" 
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

    - Storage account with a blob container and Azure Files share
    - Function app in a Flex Consumption function plan
    - Application Insights for monitoring
    - Managed identity with permissions to storage

1. After the deployment succeeds, save the resource names for later steps:

    ```azurecli
    STORAGE_ACCOUNT=$(az deployment group show --resource-group $RESOURCE_GROUP --name main --query properties.outputs.storageAccountName.value -o tsv)
    FUNCTION_APP_NAME=$(az deployment group show --resource-group $RESOURCE_GROUP --name main --query properties.outputs.functionAppName.value -o tsv)
    SHARE_NAME="ffmpeg-binaries"
    INPUT_CONTAINER="images-input"
    OUTPUT_CONTAINER="images-output"

    echo "Storage Account: $STORAGE_ACCOUNT"
    echo "Function App: $FUNCTION_APP_NAME"
    ```

> [!NOTE]
> If you're using Azure Cloud Shell, shell variables don't persist between sessions. If your session times out, rerun the variable assignments in this section before continuing.

## Upload the ffmpeg binary to Azure Files

1. Get the ffmpeg binary and prepare it for upload.

    ### [Linux/macOS](#tab/linux)

    ```bash
    mkdir -p ffmpeg_share
    cp $(which ffmpeg) ffmpeg_share/ffmpeg
    chmod +x ffmpeg_share/ffmpeg
    ./ffmpeg_share/ffmpeg -version | head -1
    ```

    ### [Windows](#tab/windows)

    Download the ffmpeg binary from [ffmpeg.org](https://ffmpeg.org/download.html), extract it, and copy `ffmpeg.exe` to a local folder named `ffmpeg_share`.

    ---

1. Upload the binary to the Azure Files share:

    ```azurecli
    STORAGE_KEY=$(az storage account keys list \
      --resource-group $RESOURCE_GROUP \
      --account-name $STORAGE_ACCOUNT \
      --query "[0].value" \
      -o tsv)

    az storage file upload \
      --share-name $SHARE_NAME \
      --source ffmpeg_share/ffmpeg \
      --path ffmpeg \
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
    ffmpeg
    ```

> [!TIP]
> The Azure Files share is mounted at `/mnt/ffmpeg_binaries` inside the function container. Your function calls `/mnt/ffmpeg_binaries/ffmpeg` directly.

## Verify the storage mount configuration

The Bicep deployment configures the mount. Verify that it's set up correctly:

```azurecli
az functionapp config appsettings list \
  --resource-group $RESOURCE_GROUP \
  --name $FUNCTION_APP_NAME \
  | grep -i mount
```

If you don't see mount configuration settings, manually configure the mount in the Azure portal under **Settings** > **Configuration** > **Path Mappings**.

## Prepare and deploy the function app

1. Make sure the required app settings exist on the remote function app. This command can be run even if these settings already exist:

    ```azurecli
    az functionapp config appsettings set \
      --resource-group $RESOURCE_GROUP \
      --name $FUNCTION_APP_NAME \
      --settings FFMPEG_PATH=/mnt/ffmpeg_binaries/ffmpeg TEMP_PATH=/mnt/ffmpeg_binaries/temp
    ```

1. Publish the function app to Azure. The `--build remote` flag installs Python dependencies on the server, so you don't need to install them locally:

    ```bash
    func azure functionapp publish $FUNCTION_APP_NAME --build remote
    ```

1. Create input and output blob containers

    ```azurecli
    az storage container create \
      --name $INPUT_CONTAINER \
      --account-name $STORAGE_ACCOUNT \
      --account-key $STORAGE_KEY
    
    az storage container create \
      --name $OUTPUT_CONTAINER \
      --account-name $STORAGE_ACCOUNT \
      --account-key $STORAGE_KEY
    ```

Now, you can upload an image to trigger processing.

## Upload a sample image to trigger processing

1. Create a simple test image on your local computer by using ffmpeg:

    ```bash
    ffmpeg -f lavfi -i color=c=blue:s=400x300 -frames:v 1 sample_image.jpg -y
    ```

1. Upload the image to the input container:

    ```azurecli
    az storage blob upload \
      --container-name $INPUT_CONTAINER \
      --name sample_image.jpg \
      --file sample_image.jpg \
      --account-name $STORAGE_ACCOUNT \
      --account-key $STORAGE_KEY
    ```

    The upload automatically triggers your function.

> [!TIP]
> If the trigger doesn't fire immediately, wait 10-15 seconds, and then check the function's execution logs in the Azure portal.

## Verify the converted image

1. Check the function logs:

    ```azurecli
    az functionapp log tail \
      --resource-group $RESOURCE_GROUP \
      --name $FUNCTION_APP_NAME
    ```

    Expected output:

    ```
    Executing 'ProcessImageFunction' (Reason='New blob detected', Id=12345)
    Image processing started for sample_image.jpg
    FFmpeg conversion completed successfully
    Executed 'ProcessImageFunction' (Succeeded, Id=12345, Duration=2765ms)
    ```

1. Download the converted image:

    ```azurecli
    az storage blob list \
      --container-name $OUTPUT_CONTAINER \
      --account-name $STORAGE_ACCOUNT \
      --account-key $STORAGE_KEY \
      -o table

    az storage blob download \
      --container-name $OUTPUT_CONTAINER \
      --name sample_image_converted.png \
      --file ./output_image.png \
      --account-name $STORAGE_ACCOUNT \
      --account-key $STORAGE_KEY
    ```

    You should see execution times in the 1-3 second range, including ffmpeg startup and conversion time.

> [!NOTE]
> The first execution might be slightly slower (cold start). Subsequent invocations are faster because the function container stays warm and ffmpeg is cached. To minimize cold starts, consider enabling [always-ready instances](./flex-consumption-plan.md#always-ready-instances).

## Clean up resources

To avoid ongoing charges, delete the resource group when you no longer need the resources:

```azurecli
az group delete --name $RESOURCE_GROUP --yes
```

> [!WARNING]
> This command deletes the resource group and all resources in it, including the function app, storage account, and Application Insights instance.

## Related content

- [Choose a file access strategy for Azure Functions](./concept-file-access-options.md)
- [Tutorial: Durable text analysis with a mounted Azure Files share](./durable/tutorial-durable-text-analysis-azure-files.md)
- [Flex Consumption plan](./flex-consumption-plan.md)
- [Storage considerations for Azure Functions](./storage-considerations.md)
