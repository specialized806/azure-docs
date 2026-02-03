---
title: 'Quickstart: Create Bicep files with Visual Studio Code and Bicep MCP server'
description: Learn how to use Visual Studio Code and the Bicep MCP server to create Bicep files and deploy Azure resources.
ms.topic: quickstart
ms.date: 01/30/2026
ms.custom:
  - mode-ui
  - devx-track-bicep
  - sfi-image-nochange
#customer intent: As a developer new to Azure deployment, I want to learn how to use Visual Studio Code to create and edit Bicep files so that I can use them to deploy Azure resources.
---

# Quickstart: Create Bicep files with Visual Studio Code and Bicep MCP Server

This quickstart guides you how to use Visual Studio Code and [Bicep MCP Server](./bicep-mcp-server.md) to create a [Bicep file](overview.md). 

## Prerequisites

If you don't have an Azure subscription, [create a free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you start.

1. To set up your environment for Bicep development, see [Install Bicep tools](install.md). After completing those steps, you have [Visual Studio Code](https://code.visualstudio.com/) and the [Bicep extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep) version v0.40.2 or later installed. The Bicep extension version v0.40.2 automatically installs the Bicep MCP server. You also have either the latest [Azure CLI](/cli/azure/) version or [Azure PowerShell module](/powershell/azure/new-azureps-module-az).
1. Start Bicep MCP server.  See [Start and stop the Bicep MCP server](./bicep-mcp-server.md#start-and-stop-the-bicep-mcp-server).
1. Enable the Bicep MCP server tools.  See [Manage the MCP server](./bicep-mcp-server.md#manage-the-mcp-server).

## Create a Bicep file using Bicep MCP

You use the Copilot chat to create your Bicep files.

1. From the `File` menu, select `New File` to create a new Bicep file called `main.bicep`.
1. From the `View` menu, select `Chat` to open the Copilot chat pane. Notice the current file context is changed to `main.bicep`. If it is not, click the `Add context` button to add the file.

    :::image type="content" source="./media/quickstart-create-bicep-use-visual-studio-code-mcp/vscode-copilot-chat-new.png" alt-text="Screenshot of Visual Studio Code chat pane.":::

1. For the demonstration purpose, submit the following prompt to ensure the usage of the Bicep MCP server tools.

    ```
    For this conversation, only use tools from the "bicep-mcp" MCP server.
    Do not call any other MCP tools.
    ```

1. Submit the following prompt to create a create a simple storage account

    ```
    Add a storage account resource with only the required properties using Bicep best practices.
    ```

    The chat pane lists the Bicep MCP server tools used, and the Bicep file it generated.

    :::image type="content" source="./media/quickstart-create-bicep-use-visual-studio-code-mcp/prompt-add-storage.png" alt-text="Screenshot of adding a storage account.":::

1. Hoover your cursor over the code generated, select `Apply in Editor`, and then select `Active editor ...` to add the code to `main.bicep`.
1. In the editor, select `Keep` to confirm the insert.

    :::image type="content" source="./media/quickstart-create-bicep-use-visual-studio-code-mcp/prompt-add-storage-keep.png" alt-text="Screenshot of confirming adding a storage account.":::

1. Submit the following prompt to add default values for the parameters:

    ```
    Add default values for the parameters.
    ```

1. Select `Apply in Editor`, select `Active editor ...`, and then select `Keep`.

1. Submit the following prompt to add default values:

    ```
    Create a Bicep parameters file with all the parameters defined in the Bicep file.
    ```

    Select `Allow`. `Allow without Review in this Workspace`.

    The following tools are used:

    - Run Format Bicep File

    Select 'Allow`.

1. From the generated code block, select `Apply in Editor`, select `New untitled editor`, and then select `Keep`.

1. From the `File` menu, select `Save`, and save the file as `main.bicepparam`.

    Notice, the active content is `main.bicepparam` now.

1. Submit the following prompt:

    ```
    verify the Bicep file
    ```

    "Run Get Bicep File Diagnostics" tools is used. And it shows `no errors or warnings`.

1. Submit the following prompt:

    ```
    get a snapshot of the deployment
    ```
    
    
    "Ran Get deployment snapshot" is ran.

## Deploy the Bicep file

1. Right-click the Bicep file inside the Visual Studio Code, and then select **Deploy Bicep file**.

    :::image type="content" source="./media/quickstart-create-bicep-use-visual-studio-code/vscode-bicep-deploy.png" alt-text="Screenshot of the Deploy Bicep File option.":::

1. In the **Please enter name for deployment** text box, type **deployStorageAndVNet**, and then press <kbd>ENTER</kbd>.

    :::image type="content" source="./media/quickstart-create-bicep-use-visual-studio-code/vscode-bicep-deploy-name.png" alt-text="Screenshot of entering the deployment name.":::

1. From the **Select Resource Group** listbox on the top, select **Create new Resource Group**.

1. Enter **exampleRG** as the resource group name, and then press <kbd>ENTER</kbd>.

1. Select a location for the resource group, select **Central US** or a location of your choice, and then press <kbd>ENTER</kbd>.

1. From **Select a parameters file**, select **None**.

It takes a few moments to create the resources. For more information, see [Deploy Bicep files with Visual Studio Code](./deploy-vscode.md).

You can also use the Azure CLI or Azure PowerShell to deploy the Bicep file:

# [Azure CLI](#tab/azure-cli)

```azurecli
az group create --name exampleRG --location eastus

az deployment group create --resource-group exampleRG --template-file main.bicep --parameters storageAccountName=uniquename
```

# [Azure PowerShell](#tab/azure-powershell)

```azurepowershell
New-AzResourceGroup -Name exampleRG -Location eastus

New-AzResourceGroupDeployment -ResourceGroupName exampleRG -TemplateFile ./main.bicep -storageAccountName "uniquename"
```

---

When the deployment finishes, you should see a message describing that the deployment succeeded.

## Clean up resources

When the Azure resources are no longer needed, use the Azure CLI or Azure PowerShell module to delete the quickstart resource group.

# [Azure CLI](#tab/azure-cli)

```azurecli
az group delete --name exampleRG
```

# [Azure PowerShell](#tab/azure-powershell)

```azurepowershell
Remove-AzResourceGroup -Name exampleRG
```

---

## Next steps

> [!div class="nextstepaction"]
> [Create template specs](./quickstart-create-template-specs.md).
