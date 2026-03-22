---
title: "Tutorial: Durable text analysis with a mounted Azure Files share in Azure Functions"
description: Learn how to deploy a Python Azure Functions app that uses Durable Functions to orchestrate parallel text file analysis by using a mounted Azure Files share on a Flex Consumption plan.
ms.service: azure-functions
ms.topic: tutorial
ms.date: 03/11/2026
ms.custom:
  - devx-track-azurecli
  - devx-track-azdevcli
  - devx-track-python
#customer intent: As a developer, I want to deploy a Durable Functions app on the Flex Consumption plan with Azure Files storage mounts so I can analyze multiple text files in parallel without managing infrastructure.
---

# Tutorial: Durable text analysis with a mounted Azure Files share

In this tutorial, you deploy a Python Azure Functions app that uses [Durable Functions](./durable-functions-overview.md) to orchestrate parallel text file analysis. Your function app mounts an Azure Files share, analyzes multiple text files in parallel (fan-out), aggregates the results (fan-in), and returns them to the caller. This approach demonstrates a key advantage of storage mounts: shared file access across multiple function instances without per-request network overhead.

In this tutorial, you:

> [!div class="checklist"]
> * Deploy a Durable Functions app in a Flex Consumption plan with a mounted Azure Files share by using Azure Developer CLI
> * Trigger an orchestration to process sample text files in parallel
> * Verify the aggregated analysis results

[!INCLUDE [functions-azure-files-samples-note](../../../includes/functions-azure-files-samples-note.md)]

## Prerequisites

- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- [Azure Developer CLI (azd)](/azure/developer/azure-developer-cli/install-azd) version 1.9.0 or later
- [Git](https://git-scm.com/)

The CLI examples in this tutorial use Bash syntax and have been tested in [Azure Cloud Shell](/azure/cloud-shell/overview) (Bash) and Linux/macOS terminals.

## Initialize the sample project

The sample code for this tutorial is in the [Azure Functions Flex Consumption with Azure Files OS Mount Samples](https://github.com/Azure-Samples/Azure-Functions-Flex-Consumption-with-Azure-Files-OS-Mount-Samples) GitHub repository. The `durable-text-analysis` folder contains the function app code, a Bicep template that provisions the required Azure resources, and a post-deployment script that uploads sample text files.

1. Open a terminal and navigate to the directory where you want to clone the repository.

1. Clone the repository:

    ```bash
    git clone https://github.com/Azure-Samples/Azure-Functions-Flex-Consumption-with-Azure-Files-OS-Mount-Samples.git
    ```

1. Navigate to the project folder:

    ```bash
    cd Azure-Functions-Flex-Consumption-with-Azure-Files-OS-Mount-Samples/durable-text-analysis
    ```

1. Initialize the `azd` environment. When prompted, enter an environment name such as `durable-text`:

    ```bash
    azd init
    ```

## Deploy with Azure Developer CLI

This sample is an [Azure Developer CLI (azd)](/azure/developer/azure-developer-cli/overview) template. A single `azd up` command provisions infrastructure, deploys the function code, and uploads sample text files to the Azure Files share.

1. Sign in to Azure. The post-deployment script uses Azure CLI commands, so you need to authenticate with both tools:

    ```bash
    azd auth login
    az login
    ```

1. Provision and deploy everything:

    ```bash
    azd up
    ```

    When prompted, select the Azure subscription and location to use. The command then:

    - Creates a resource group, storage account, Flex Consumption function app with a Durable Functions configuration, Application Insights instance, and managed identity
    - Deploys the Python function code
    - Uploads sample text files to the Azure Files share
    - Runs a health check

    The deployment takes a few minutes. When it completes, you see a summary of the created resources.

1. Save resource names as shell variables for the remaining steps:

    ```bash
    RESOURCE_GROUP=$(azd env get-value AZURE_RESOURCE_GROUP)
    FUNCTION_APP_NAME=$(azd env get-value AZURE_FUNCTION_APP_NAME)
    FUNCTION_APP_URL=$(azd env get-value AZURE_FUNCTION_APP_URL)
    ```

## Trigger the orchestration

1. Get the function host key:

    ```azurecli
    HOST_KEY=$(az functionapp keys list \
      --resource-group $RESOURCE_GROUP \
      --name $FUNCTION_APP_NAME \
      --query "functionKeys.default" \
      -o tsv)
    ```

1. Start the orchestration:

    ```bash
    curl -s -X POST "${FUNCTION_APP_URL}/api/start-analysis?code=${HOST_KEY}" | jq .
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

    curl -s "${FUNCTION_APP_URL}/api/orchestrators/TextAnalysisOrchestrator/${INSTANCE_ID}?code=${HOST_KEY}" | jq .
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
            "file": "sample1.txt",
            "word_count": 15,
            "char_count": 98,
            "sentiment": "positive"
          },
          {
            "file": "sample2.txt",
            "word_count": 18,
            "char_count": 120,
            "sentiment": "positive"
          },
          {
            "file": "sample3.txt",
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
> Your function app accessed all three files in parallel through the storage mount. The app didn't need any per-request network calls. The function read them directly from the mounted share by using standard file I/O. This approach demonstrates the power of storage mounts combined with Durable Functions.

## Clean up resources

To avoid ongoing charges, delete all the resources created by this tutorial:

```bash
azd down --purge
```

> [!WARNING]
> This command deletes the resource group and all resources in it, including the function app, storage account, and Application Insights instance.

## Related content

- [Durable Functions overview](./durable-functions-overview.md)
- [Choose a file access strategy for Azure Functions](../concept-file-access-options.md)
- [Tutorial: Process images by using FFmpeg on a mounted Azure Files share](../tutorial-ffmpeg-processing-azure-files.md)
- [Flex Consumption plan](../flex-consumption-plan.md)
- [Storage considerations for Azure Functions](../storage-considerations.md)
