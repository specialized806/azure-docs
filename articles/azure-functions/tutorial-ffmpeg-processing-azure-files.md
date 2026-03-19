---
title: "Tutorial: Process images by using FFmpeg on a mounted Azure Files share in Azure Functions"
description: Learn how to deploy a Python Azure Functions app that uses an ffmpeg binary hosted on a mounted Azure Files share to process images on a Flex Consumption plan.
ms.topic: tutorial
ms.date: 03/11/2026
ms.custom:
  - devx-track-azurecli
  - devx-track-azdevcli
  - devx-track-python
#customer intent: As a developer, I want to host large third-party binaries like ffmpeg on a mounted Azure Files share so I can keep my function deployment small and cold starts fast.
---

# Tutorial: Process images by using FFmpeg on a mounted Azure Files share

In this tutorial, you deploy a Python app that uses an ffmpeg binary on a mounted Azure Files share to process images in Azure Functions. When you upload an image to the container, the function triggers, calls ffmpeg from the mount to convert the image, and saves the result back to storage. By hosting large binaries like ffmpeg on a mounted share instead of in your deployment package, you keep deployments small and cold starts fast.

In this tutorial, you:

> [!div class="checklist"]
> * Deploy a Flex Consumption function app with a mounted Azure Files share by using Azure Developer CLI
> * Upload a sample image to trigger blob-based processing
> * Verify that the function called ffmpeg from the mount and saved the converted image

[!INCLUDE [functions-azure-files-samples-note](../../includes/functions-azure-files-samples-note.md)]

## Prerequisites

- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn)
- [Azure Developer CLI (azd)](/azure/developer/azure-developer-cli/install-azd) version 1.9.0 or later
- [Git](https://git-scm.com/)

The CLI examples in this tutorial use Bash syntax and have been tested in [Azure Cloud Shell](/azure/cloud-shell/overview) (Bash) and Linux/macOS terminals.

## Initialize the sample project

The sample code for this tutorial is in the [Azure Functions Flex Consumption with Azure Files OS Mount Samples](https://github.com/Azure-Samples/Azure-Functions-Flex-Consumption-with-Azure-Files-OS-Mount-Samples) GitHub repository. The `ffmpeg-image-processing` folder contains the function app code, a Bicep template that provisions the required Azure resources, and a post-deployment script that uploads the ffmpeg binary.

1. Open a terminal and navigate to the directory where you want to clone the repository.

1. Clone the repository:

    ```bash
    git clone https://github.com/Azure-Samples/Azure-Functions-Flex-Consumption-with-Azure-Files-OS-Mount-Samples.git
    ```

1. Navigate to the project folder:

    ```bash
    cd Azure-Functions-Flex-Consumption-with-Azure-Files-OS-Mount-Samples/ffmpeg-image-processing
    ```

1. Initialize the `azd` environment. When prompted, enter an environment name such as `ffmpeg-processing`:

    ```bash
    azd init
    ```

## Deploy with Azure Developer CLI

This sample is an [Azure Developer CLI (azd)](/azure/developer/azure-developer-cli/overview) template. A single `azd up` command provisions infrastructure, deploys the function code, uploads the ffmpeg binary to Azure Files, and creates the EventGrid subscription for blob triggers.

1. Sign in to Azure:

    ```bash
    azd auth login
    ```

1. Provision and deploy everything:

    ```bash
    azd up
    ```

    When prompted, select the Azure subscription and location to use. The command then:

    - Creates a resource group, storage account, Flex Consumption function app, Application Insights instance, and managed identity.
    - Deploys the Python function code.
    - Downloads and uploads the ffmpeg binary to the Azure Files share.
    - Creates an EventGrid subscription so blob uploads trigger your function.
    - Runs a health check.

    The deployment takes a few minutes. When it completes, you see a summary of the created resources.

1. Save resource names as shell variables for the remaining steps:

    ```bash
    RESOURCE_GROUP=$(azd env get-value AZURE_RESOURCE_GROUP)
    STORAGE_ACCOUNT=$(azd env get-value AZURE_STORAGE_ACCOUNT_NAME)
    FUNCTION_APP_NAME=$(azd env get-value AZURE_FUNCTION_APP_NAME)
    INPUT_CONTAINER=$(azd env get-value AZURE_STORAGE_INPUT_CONTAINER)
    OUTPUT_CONTAINER=$(azd env get-value AZURE_STORAGE_OUTPUT_CONTAINER)
    ```

## Process an image

1. Upload a test image to the input container. The EventGrid subscription created during deployment automatically triggers your function when a blob is uploaded.

    ```azurecli
    az storage blob upload \
      --container-name $INPUT_CONTAINER \
      --name sample_image.jpg \
      --file <path-to-a-local-image> \
      --account-name $STORAGE_ACCOUNT \
      --auth-mode login
    ```

    Replace `<path-to-a-local-image>` with the path to any `.jpg` or `.png` file on your computer.

    > [!TIP]
    > If the trigger doesn't fire immediately, wait 10-15 seconds, and then check the function's execution logs in the Azure portal.

1. Check the function logs to confirm the image was processed:

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

1. List and download the converted image:

    ```azurecli
    az storage blob list \
      --container-name $OUTPUT_CONTAINER \
      --account-name $STORAGE_ACCOUNT \
      --auth-mode login \
      -o table

    az storage blob download \
      --container-name $OUTPUT_CONTAINER \
      --name sample_image_converted.png \
      --file ./output_image.png \
      --account-name $STORAGE_ACCOUNT \
      --auth-mode login
    ```

> [!NOTE]
> The first execution might be slightly slower (cold start). Subsequent invocations are faster because the function container stays warm and ffmpeg is cached. To minimize cold starts, consider enabling [always-ready instances](./flex-consumption-plan.md#always-ready-instances).

## Clean up resources

To avoid ongoing charges, delete all the resources created by this tutorial:

```bash
azd down --purge
```

> [!WARNING]
> This command deletes the resource group and all resources in it, including the function app, storage account, and Application Insights instance.

## Related content

- [Choose a file access strategy for Azure Functions](./concept-file-access-options.md)
- [Tutorial: Durable text analysis with a mounted Azure Files share](./durable/tutorial-durable-text-analysis-azure-files.md)
- [Flex Consumption plan](./flex-consumption-plan.md)
- [Storage considerations for Azure Functions](./storage-considerations.md)
