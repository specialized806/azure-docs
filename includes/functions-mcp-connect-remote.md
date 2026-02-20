---
author: ggailey777
ms.service: azure-functions
ms.topic: include
ms.date: 02/20/2026
ms.author: glenga
---

Your MCP server is now running in Azure. When you access the tools, you need to include a system key in your request. This key provides a degree of access control for clients accessing your remote MCP server. After you get this key, you can connect GitHub Copilot to your remote server.

1. Run this script that uses `azd` and the Azure CLI to print out both the MCP server URL and the system key (`mcp_extension`) required to access the tools:

    ### [Linux/macOS](#tab/linux)

    ```bash
    eval $(azd env get-values --output dotenv)
    MCP_EXTENSION_KEY=$(az functionapp keys list --resource-group $AZURE_RESOURCE_GROUP \
        --name $AZURE_FUNCTION_NAME --query "systemKeys.mcp_extension" -o tsv)
    printf "MCP Server URL: %s\n" "https://$SERVICE_API_NAME.azurewebsites.net/runtime/webhooks/mcp"
    printf "MCP Server key: %s\n" "$MCP_EXTENSION_KEY"
    ```

    ### [Windows](#tab/windows-cmd)

    ```powershell
    azd env get-values --output dotenv | ForEach-Object { 
        if ($_ -match "^([^=]+)=(.*)$") { 
            Set-Variable -Name $matches[1] -Value ($matches[2] -replace '"', '')
        } 
    }
    $MCP_EXTENSION_KEY = az functionapp keys list --resource-group $AZURE_RESOURCE_GROUP `
        --name $AZURE_FUNCTION_NAME --query "systemKeys.mcp_extension" -o tsv
    Write-Host "MCP Server URL: https://$SERVICE_API_NAME.azurewebsites.net/runtime/webhooks/mcp"
    Write-Host "MCP Server key: $MCP_EXTENSION_KEY"
    ```

    ---

1. In Visual Studio Code, press <kbd>F1</kbd> to open the command palette, search for and run the command `MCP: Open Workspace Folder MCP Configuraton`, which opens the `mcp.json` configuration file.

1. In the `mcp.json` configuration, find the named MCP server you added earlier, change the `url` value to your remote MCP server URL, and add a `headers.x-functions-key` element, which contains your copied MCP server access key, as in this example:   

    ```json
    {
        "servers": {
            "remote-mcp-function": {
                "type": "http",
                "url": "https://contoso.azurewebsites.net/runtime/webhooks/mcp",
                "headers": {
                    "x-functions-key": "A1bC2dE3fH4iJ5kL6mN7oP8qR9sT0u..."
                }
            }
        }
    }
    ```

1. Select the **Start** button above your server name in the open `mcp.json` to restart the remote MCP server, this time using your deployed app. 
