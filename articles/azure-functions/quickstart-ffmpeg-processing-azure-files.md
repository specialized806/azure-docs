---
title: "Quickstart: FFmpeg image processing with Azure Files OS mount"
description: Learn how to deploy a Python Azure Functions app that uses an ffmpeg binary hosted on an Azure Files OS mount to process images on a Flex Consumption plan.
ms.service: azure-functions
ms.topic: quickstart
ms.date: 03/11/2026
ms.custom:
  - devx-track-azurecli
  - devx-track-python
#customer intent: As a developer, I want to host large third-party binaries like ffmpeg on an Azure Files OS mount so I can keep my function deployment small and cold starts fast.
---

# Quickstart: FFmpeg image processing with Azure Files OS mount

In this quickstart, you deploy a Python Azure Functions app that uses an **ffmpeg binary on an OS-mounted Azure Files share** to process images. When you upload an image to Azure Blob Storage, the function triggers, downloads the image, converts it by using ffmpeg from the mount, and saves the result back to storage.

This quickstart demonstrates a key advantage of OS mounts: hosting large third-party binaries (like ffmpeg) outside your deployment package to keep cold starts fast and code size small.

[!INCLUDE [functions-azure-files-samples-note](../../includes/functions-azure-files-samples-note.md)]

## Prerequisites

- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- [Azure CLI](/cli/azure/install-azure-cli) version 2.60.0 or later.
- [Azure Functions Core Tools](./functions-run-local.md) version 4.x or later.
- [Python 3.9 or later](https://www.python.org/downloads/).
- [Git](https://git-scm.com/).
- [ffmpeg](https://ffmpeg.org/download.html) installed locally (for preparing the binary to upload).

## What you'll build

You deploy an application with the following components:

- **Function app**: Listens for image uploads to Azure Blob Storage.
- **Process function**: Triggered by blob uploads, reads the image, calls ffmpeg from the mounted share, and saves the converted image.
- **Azure Files mount**: Contains the ffmpeg binary and temporary files.

When you upload an image (JPG, PNG), the function:

1. Triggers on the blob upload.
1. Calls ffmpeg from the OS mount.
1. Converts and resizes the image.
1. Saves the result to an output storage container.

## Clone the repository

```bash
git clone https://github.com/Azure-Samples/Azure-Functions-Flex-Consumption-with-Azure-Files-OS-Mount-Samples.git
cd Azure-Functions-Flex-Consumption-with-Azure-Files-OS-Mount-Samples/ffmpeg-image-processing
```

## Create Azure resources

This quickstart uses Bicep to automate resource creation.

### Sign in to Azure

```bash
az login
az account set --subscription <YOUR_SUBSCRIPTION_ID>
```

### Create a resource group

```bash
RESOURCE_GROUP="rg-ffmpeg-processing"
LOCATION="eastus"

az group create --name $RESOURCE_GROUP --location $LOCATION
```

### Deploy infrastructure with Bicep

```bash
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file infra/main.bicep \
  --parameters infra/main.bicepparam
```

This deployment creates the following resources:

- Storage account with a blob container and Azure Files share
- Flex Consumption function app plan
- Azure Functions app
- Application Insights for monitoring
- Managed identity with permissions to storage

After the deployment succeeds, save the resource names for later steps:

```bash
STORAGE_ACCOUNT=$(az deployment group show --resource-group $RESOURCE_GROUP --name main --query properties.outputs.storageAccountName.value -o tsv)
FUNCTION_APP_NAME=$(az deployment group show --resource-group $RESOURCE_GROUP --name main --query properties.outputs.functionAppName.value -o tsv)
SHARE_NAME="ffmpeg-binaries"
INPUT_CONTAINER="images-input"
OUTPUT_CONTAINER="images-output"

echo "Storage Account: $STORAGE_ACCOUNT"
echo "Function App: $FUNCTION_APP_NAME"
```

## Upload the ffmpeg binary to Azure Files

### Prepare the ffmpeg binary

Get the ffmpeg binary and prepare it for upload.

**On Linux/macOS:**

```bash
mkdir -p ffmpeg_share
cp $(which ffmpeg) ffmpeg_share/ffmpeg
chmod +x ffmpeg_share/ffmpeg
./ffmpeg_share/ffmpeg -version | head -1
```

**On Windows:**

Download the ffmpeg binary from [ffmpeg.org](https://ffmpeg.org/download.html), extract it, and copy `ffmpeg.exe` to a local folder.

### Upload to Azure Files

```bash
STORAGE_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT --query "[0].value" -o tsv)

az storage file upload \
  --share-name $SHARE_NAME \
  --source ffmpeg_share/ffmpeg \
  --path ffmpeg \
  --account-name $STORAGE_ACCOUNT \
  --account-key $STORAGE_KEY
```

Verify the upload:

```bash
az storage file list --share-name $SHARE_NAME --account-name $STORAGE_ACCOUNT --account-key $STORAGE_KEY -o table
```

Expected output:

```
Name
------
ffmpeg
```

> [!TIP]
> The Azure Files share is mounted at `/mnt/ffmpeg_binaries` inside the function container. Your function calls `/mnt/ffmpeg_binaries/ffmpeg` directly.

## Verify the OS mount configuration

The Bicep deployment configures the mount. Verify that it's set up correctly:

```bash
az functionapp config appsettings list --resource-group $RESOURCE_GROUP --name $FUNCTION_APP_NAME | grep -i mount
```

If you don't see mount configuration settings, manually configure the mount in the Azure portal under **Settings** > **Configuration** > **Path Mappings**.

## Deploy the function app

### Install dependencies

```bash
pip install -r requirements.txt
```

### Configure local settings

```bash
cp local.settings.json.example local.settings.json
```

Edit `local.settings.json` to match your deployment:

```json
{
  "IsEncrypted": false,
  "Values": {
    "FUNCTIONS_WORKER_RUNTIME": "python",
    "AzureWebJobsStorage": "DefaultEndpointsProtocol=https;AccountName=<your-account>;...",
    "FFMPEG_PATH": "/mnt/ffmpeg_binaries/ffmpeg",
    "TEMP_PATH": "/mnt/ffmpeg_binaries/temp"
  }
}
```

### Publish to Azure

```bash
func azure functionapp publish $FUNCTION_APP_NAME --build remote
```

## Upload an image to trigger processing

### Create input and output blob containers

```bash
az storage container create \
  --name $INPUT_CONTAINER \
  --account-name $STORAGE_ACCOUNT \
  --account-key $STORAGE_KEY

az storage container create \
  --name $OUTPUT_CONTAINER \
  --account-name $STORAGE_ACCOUNT \
  --account-key $STORAGE_KEY
```

### Create a sample image

Create a simple test image locally:

```bash
# On macOS with ImageMagick
convert -size 400x300 xc:blue sample_image.jpg

# Or on Linux
ffmpeg -f lavfi -i color=c=blue:s=400x300 -frames:v 1 sample_image.jpg -y
```

### Upload the image

```bash
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

### Check function logs

```bash
az functionapp log tail --resource-group $RESOURCE_GROUP --name $FUNCTION_APP_NAME
```

Expected output:

```
Executing 'ProcessImageFunction' (Reason='New blob detected', Id=12345)
Image processing started for sample_image.jpg
FFmpeg conversion completed successfully
Executed 'ProcessImageFunction' (Succeeded, Id=12345, Duration=2765ms)
```

### Download the converted image

```bash
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
> The first execution might be slightly slower (cold start). Subsequent invocations are faster because the function container stays warm and ffmpeg is cached.

## Clean up resources

To avoid ongoing charges, delete the resource group when you no longer need the resources:

```bash
az group delete --name $RESOURCE_GROUP --yes
```

> [!WARNING]
> This command deletes the resource group and all resources in it, including the function app, storage account, and Application Insights instance.

## Troubleshooting

| Issue | Resolution |
| --- | --- |
| **ffmpeg: command not found** | Verify the binary was uploaded to Azure Files. Check the mount path in your function app settings. Ensure the binary has execute permissions. |
| **Permission denied** | Verify the storage account access key in the mount configuration is correct and hasn't been rotated. OS mounts use storage account keys, not managed identity RBAC. |
| **Blob trigger not firing** | Ensure the function app's managed identity can read from the input blob container. Assign **Storage Blob Data Reader** if needed. |
| **Conversion takes too long** | Flex Consumption cold starts add approximately 1-2 seconds. For large files, consider resizing the image first or using a Premium function plan. |
| **ffmpeg binary too large** | Keep ffmpeg and temporary files on the Azure Files mount to avoid bloating your deployment package. |

## Related content

- [Tutorial: Shared file access patterns with Azure Files OS mounts](./tutorial-shared-file-access-azure-files.md)
- [Quickstart: Durable text analysis with Azure Files OS mount](./quickstart-durable-text-analysis-azure-files.md)
- [Flex Consumption plan](./flex-consumption-plan.md)
- [Storage considerations for Azure Functions](./storage-considerations.md)
