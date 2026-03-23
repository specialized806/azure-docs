---
title: include file
description: include file
services: virtual-network-manager
author: mbender-ms
ms.service: azure-virtual-network-manager
ms.topic: include
ms.date: 02/02/2026
ms.author: mbender
ms.custom: include file
---

## Create a Virtual Network Manager instance

Deploy a Virtual Network Manager instance with the defined scope and access that you need. You can create a Virtual Network Manager instance using the Azure portal, Azure CLI, or Azure PowerShell.

# [Portal](#tab/azure-portal)

1. Sign in to the [Azure portal](https://portal.azure.com/).

1. Select **+ Create a resource** and search for **Network Manager**. Then select **Network Manager** > **Create** to begin setting up Virtual Network Manager.

1. On the **Basics** tab, enter or select the following information:

    | Setting | Value |
    | ------- | ----- |
    | **Subscription** | Select the subscription containing your existing virtual networks. |
    | **Resource group** | Select the existing resource group where you want to deploy Virtual Network Manager. |
    | **Name** | Enter a name for your Virtual Network Manager instance. |
    | **Region** | Select a region for your Virtual Network Manager instance. Virtual Network Manager can manage virtual networks in any region. The selected region is where the Virtual Network Manager instance will be deployed. |
    | **Description** | *(Optional)* Provide a description about this Virtual Network Manager instance and the task it's managing. |
    | [Features](../../../virtual-network-manager/concept-network-manager-scope.md#features) | Select the features you need from the dropdown list: </br> - **Connectivity**: Enables the creation of a full mesh or hub-and-spoke network topology between virtual networks within the scope. </br> - **Security Admin**: Enables the creation of global network security rules. </br> - **Routing**: Enables the creation and management of user-defined routes at scale. |

1. Select the **Management scope** tab or **Next: Management scope** to continue.

1. On the **Management scope** tab, select **+ Add**.

1. In the **Add scopes** pane, select the subscriptions or management groups containing your existing virtual networks, and choose **Select**.

1. Select **Review + create** to validate your configuration.

1. After validation passes, select **Create** to deploy the Virtual Network Manager instance.

# [Azure CLI](#tab/azure-cli)

1. Sign in to Azure and set your subscription context:

    ```azurecli-interactive
    az login
    az account set --subscription "<subscription-id>"
    ```

1. Install or update the Virtual Network Manager extension:

    ```azurecli-interactive
    az extension add --name virtual-network-manager
    az extension update --name virtual-network-manager
    ```

1. Create a Virtual Network Manager instance using [az network manager create](/cli/azure/network/manager#az-network-manager-create). Replace the placeholder values with your specific information:

    ```azurecli-interactive
    az network manager create \
        --name "<network-manager-name>" \
        --location "<region>" \
        --resource-group "<existing-resource-group-name>" \
        --scope-accesses "Connectivity" "SecurityAdmin" \
        --network-manager-scopes subscriptions="/subscriptions/<subscription-id>" \
        --description "<optional-description>"
    ```

    > [!NOTE]
    > For management group scope, use: `managementGroups="/providers/Microsoft.Management/managementGroups/<management-group-id>"`
    > Ensure the specified resource group already exists in your subscription.

# [Azure PowerShell](#tab/azure-powershell)

1. Sign in to Azure and set your subscription context:

    ```azurepowershell-interactive
    Connect-AzAccount
    Set-AzContext -Subscription "<subscription-id>"
    ```

1. Install or update the Azure PowerShell module:

    ```azurepowershell-interactive
    Install-Module -Name Az.Network -Force
    ```

1. Define the scope and access type for your Virtual Network Manager instance:

    ```azurepowershell-interactive
    # Define subscription scope
    $subscriptionId = "<subscription-id>"
    [System.Collections.Generic.List[string]]$subGroup = @()  
    $subGroup.Add("/subscriptions/$subscriptionId")
    
    # Define access types
    [System.Collections.Generic.List[String]]$access = @()  
    $access.Add("Connectivity")
    $access.Add("SecurityAdmin")
    
    # Create scope object
    $scope = New-AzNetworkManagerScope -Subscription $subGroup
    ```

1. Create the Virtual Network Manager instance using [New-AzNetworkManager](/powershell/module/az.network/new-aznetworkmanager):

    ```azurepowershell-interactive
    $networkManagerParams = @{
        Name = "<network-manager-name>"
        ResourceGroupName = "<existing-resource-group-name>"
        Location = "<region>"
        NetworkManagerScope = $scope
        NetworkManagerScopeAccess = $access
        Description = "<optional-description>"
    }
    
    $networkManager = New-AzNetworkManager @networkManagerParams
    ```

    > [!NOTE]
    > Ensure the specified resource group already exists in your subscription.

---

> [!IMPORTANT]
> Virtual Network Manager requires specific permissions within the defined scope. Ensure you have the necessary [Azure RBAC roles](../../../virtual-network-manager/concept-network-manager-scope.md#permissions) before creating the instance.

The Virtual Network Manager instance is now created and ready to manage your existing virtual networks within the defined scope. You can proceed to create network groups and configurations to organize and manage your virtual networks.