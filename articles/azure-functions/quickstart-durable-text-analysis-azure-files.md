---
title: "Quickstart: Durable text analysis with Azure Files OS mount"
description: Learn how to deploy a Python Azure Functions app that uses Durable Functions to orchestrate parallel text file analysis by using an Azure Files OS mount on a Flex Consumption plan.
ms.service: azure-functions
ms.topic: quickstart
ms.date: 03/11/2026
ms.custom:
  - devx-track-azurecli
  - devx-track-python
#customer intent: As a developer, I want to deploy a Durable Functions app on the Flex Consumption plan with Azure Files OS mounts so I can analyze multiple text files in parallel without managing infrastructure.
---

# Quickstart: Durable text analysis with Azure Files OS mount

In this quickstart, you deploy a Python Azure Functions app that uses [Durable Functions](./durable/durable-functions-overview.md) to orchestrate parallel text file analysis. Your function app mounts an Azure Files share, analyzes multiple text files in parallel (fan-out), aggregates the results (fan-in), and returns them to the caller.

This quickstart demonstrates a key advantage of OS mounts: shared file access across multiple function instances without per-request network overhead.

[!INCLUDE [functions-azure-files-samples-note](../../includes/functions-azure-files-samples-note.md)]

## Prerequisites

- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- [Azure CLI](/cli/azure/install-azure-cli) version 2.60.0 or later.
- [Azure Functions Core Tools](./functions-run-local.md) version 4.x or later.
- [Python 3.9 or later](https://www.python.org/downloads/).
- [Git](https://git-scm.com/).

## What you'll build

You deploy an application with the following components:

- **Orchestrator function**: Receives a trigger to analyze a folder of text files. Reads the mount point, discovers files, and fans out parallel analysis tasks.
- **Activity functions**: Each activity analyzes one file, computing word count, character count, and mock sentiment.
- **Azure Files mount**: A shared network path mounted on your function app, accessible to all instances.

When you trigger the orchestration, it:

1. Connects to your mounted Azure Files share.
1. Lists all text files in a folder.
1. Starts parallel analysis tasks (one per file).
1. Waits for all tasks to complete (fan-in).
1. Returns aggregated results.

## Clone the repository

```bash
git clone https://github.com/Azure-Samples/Azure-Functions-Flex-Consumption-with-Azure-Files-OS-Mount-Samples.git
cd Azure-Functions-Flex-Consumption-with-Azure-Files-OS-Mount-Samples/durable-text-analysis
```

## Create Azure resources

This quickstart uses Bicep to automate resource creation. Alternatively, you can create resources manually in the Azure portal.

### Sign in to Azure

```bash
az login
az account set --subscription <YOUR_SUBSCRIPTION_ID>
```

### Create a resource group

```bash
RESOURCE_GROUP="rg-durable-text"
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

- Storage account with an Azure Files share
- Flex Consumption function app plan
- Azure Functions app
- Application Insights for monitoring
- Managed identity with permissions to the storage account

After the deployment succeeds, save the resource names for later steps:

```bash
STORAGE_ACCOUNT=$(az deployment group show --resource-group $RESOURCE_GROUP --name main --query properties.outputs.storageAccountName.value -o tsv)
FUNCTION_APP_NAME=$(az deployment group show --resource-group $RESOURCE_GROUP --name main --query properties.outputs.functionAppName.value -o tsv)
SHARE_NAME="text-data"

echo "Storage Account: $STORAGE_ACCOUNT"
echo "Function App: $FUNCTION_APP_NAME"
echo "Share Name: $SHARE_NAME"
```

## Verify the Azure Files mount

The Bicep deployment creates the Azure Files share and configures the mount on your function app.

### Verify the storage share exists

```bash
az storage share list --account-name $STORAGE_ACCOUNT --query "[].name" -o table
```

Expected output:

```
Name
------
text-data
```

### Verify mount configuration on the function app

```bash
az functionapp config appsettings list --resource-group $RESOURCE_GROUP --name $FUNCTION_APP_NAME | grep -i mount
```

> [!TIP]
> The OS mount typically appears at `/mnt/filedata` inside the function container. Your app settings map this local path to the Azure Files share.

## Upload sample text files

### Create local sample files

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

### Upload files to the Azure Files share

```bash
STORAGE_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT --query "[0].value" -o tsv)

az storage file upload-batch \
  --destination $SHARE_NAME \
  --source sample_texts \
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
file1.txt
file2.txt
file3.txt
```

## Deploy the function app

### Install dependencies

```bash
pip install -r requirements.txt
```

### Configure local settings

```bash
cp local.settings.json.example local.settings.json
```

Edit `local.settings.json` to include your mount path:

```json
{
  "IsEncrypted": false,
  "Values": {
    "FUNCTIONS_WORKER_RUNTIME": "python",
    "AzureWebJobsStorage": "DefaultEndpointsProtocol=https;AccountName=<your-account>;...",
    "MOUNT_PATH": "/mnt/filedata"
  }
}
```

### Publish to Azure

```bash
func azure functionapp publish $FUNCTION_APP_NAME --build remote
```

## Trigger the orchestration

### Get the function URL

```bash
HOST_KEY=$(az functionapp keys list --resource-group $RESOURCE_GROUP --name $FUNCTION_APP_NAME --query "functionKeys.default" -o tsv)

FUNCTION_URL="https://${FUNCTION_APP_NAME}.azurewebsites.net/api/orchestrators/TextAnalysisOrchestrator"
```

### Start the orchestration

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

### Check orchestration status

Use the `statusQueryGetUri` from the previous response, or construct the URL manually:

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
> Your function app accessed all three files in parallel through the OS mount. No per-request network calls were needed. The function read them directly from the mounted share by using standard file I/O. This approach demonstrates the power of OS mounts combined with Durable Functions.

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
| **Mount path not found** | Verify the mount is configured in the Azure portal under **Settings** > **Configuration** > **Path Mappings**. |
| **Permission denied when reading files** | Verify the storage account access key in the mount configuration is correct and hasn't been rotated. OS mounts use storage account keys, not managed identity RBAC. |
| **Deployment failed** | Check the Bicep parameters file (`infra/main.bicepparam`). Ensure all required values are set and the storage account name is globally unique. |
| **Orchestration timed out** | Increase `maxRetryInterval` in `function_app.py` if your files are large or your analysis is slow. |

## Related content

- [Durable Functions overview](./durable/durable-functions-overview.md)
- [Tutorial: Shared file access patterns with Azure Files OS mounts](./tutorial-shared-file-access-azure-files.md)
- [Quickstart: FFmpeg image processing with Azure Files OS mount](./quickstart-ffmpeg-processing-azure-files.md)
- [Flex Consumption plan](./flex-consumption-plan.md)
- [Storage considerations for Azure Functions](./storage-considerations.md)
