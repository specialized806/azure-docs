---
title: 'Quickstart: Set up Azure NetApp Elastic Zone-Redundant storage'
description: Quickly understand the steps to set up an Azure NetApp Files account, capacity pool, delegated subnet, and virtual network on the Elastic zone-redundant storage level. 
author: b-ahibbard
ms.author: anfdocs
ms.service: azure-netapp-files
ms.topic: quickstart
ms.date: 09/10/2025
ms.custom: devx-track-azurecli, subject-armqs, mode-ui, devx-track-azurepowershell, devx-track-terraform
---

# Quickstart: Set up Azure NetApp Files Elastic Zone-Redundant storage (preview)

The Elastic zone-redundant service level offers a different approach to storage. 

## Register for NetApp Resource Provider

> [!NOTE]
> The registration process can take some time to complete.

# [Portal](#tab/azure-portal)

For registration steps using Portal, open a Cloud Shell session as indicated above and follow these Azure CLI steps:

[!INCLUDE [azure-netapp-files-cloudshell-include](../../includes/azure-netapp-files-azure-cloud-shell-window.md)]

# [PowerShell](#tab/azure-powershell)

This how-to article requires the Azure PowerShell module Az version 2.6.0 or later. Run `Get-Module -ListAvailable Az` to find your current version. If you need to install or upgrade, see [Install Azure PowerShell module](/powershell/azure/install-azure-powershell). If you prefer, you can use Cloud Shell console in a PowerShell session instead.

1. In a PowerShell command prompt (or PowerShell Cloud Shell session), specify the subscription that has been approved for Azure NetApp Files:
    ```powershell-interactive
    Select-AzSubscription -Subscription <subscriptionId>
    ```

2. Register the Azure Resource Provider:
    ```powershell-interactive
    Register-AzResourceProvider -ProviderNamespace Microsoft.NetApp
    ```

# [Azure CLI](#tab/azure-cli)

Prepare your environment for the Azure CLI.

[!INCLUDE [azure-cli-prepare-your-environment-no-header.md](~/reusable-content/azure-cli/azure-cli-prepare-your-environment-no-header.md)]

[!INCLUDE [azure-netapp-files-cloudshell-include](../../includes/azure-netapp-files-azure-cloud-shell-window.md)]

# [Template](#tab/template)

None.

Use the Azure portal, PowerShell, or the Azure CLI to [register for NetApp Resource Provider](azure-netapp-files-register.md).

# [Terraform](#tab/terraform)

[!INCLUDE [Terraform abstract](~/azure-dev-docs-pr/articles/terraform/includes/abstract.md)]

Use the Azure portal, Azure PowerShell, or the Azure CLI to [register for NetApp Resource Provider](azure-netapp-files-register.md).

---

## Create a NetApp account

# [Portal](#tab/azure-portal)

1. In the Azure portal's search box, enter **Azure NetApp Files** and then select **Azure NetApp Files** from the list that appears.

      ![Select Azure NetApp Files](./media/azure-netapp-files-quickstart-set-up-account-create-volumes/azure-netapp-files-select-azure-netapp-files.png)

2. Select **+ Create** to create a new NetApp account.

3. In the New NetApp Account window, provide the following information:
   1. Enter **myaccount1** for the account name.
   2. Select your subscription.
   3. Select **Create new** to create new resource group. Enter **myRG1** for the resource group name. Select **OK**.
   4. Select your account location.

      ![New NetApp Account window](./media/azure-netapp-files-quickstart-set-up-account-create-volumes/azure-netapp-files-new-account-window.png)

      ![Resource group window](./media/azure-netapp-files-quickstart-set-up-account-create-volumes/azure-netapp-files-resource-group-window.png)

4. Select **Create** to create your new NetApp account.

# [PowerShell](#tab/azure-powershell)

1. Define some variables so we can refer to them throughout the rest of the examples:

    ```powershell-interactive
    $resourceGroup = "myRG1"
    $location = "eastus"
    $anfAccountName = "myaccount1"
    ```

    > [!NOTE]
    > Please refer to [Products available by region](https://azure.microsoft.com/global-infrastructure/services/?products=netapp&regions=all) for a list of supported regions.
    > To obtain the region name that is supported by our command line tools, please use `Get-AzLocation | select Location`
    >

1. Create a new resource group by using the [New-AzResourceGroup](/powershell/module/az.resources/new-azresourcegroup) command:

    ```powershell-interactive
    New-AzResourceGroup -Name $resourceGroup -Location $location
    ```

2. Create Azure NetApp Files account with [New-AzNetAppFilesAccount](/powershell/module/az.netappfiles/New-AzNetAppFilesAccount) command:

    ```powershell-interactive
    New-AzNetAppFilesAccount -ResourceGroupName $resourceGroup -Location $location -Name $anfAccountName
    ```

# [Azure CLI](#tab/azure-cli)

1. Define some variables so we can refer to them throughout the rest of the examples:

    ```azurecli-interactive
    RESOURCE_GROUP="myRG1"
    LOCATION="eastus"
    ANF_ACCOUNT_NAME="myaccount1"
    ```

    > [!NOTE]
    > Please refer to [Products available by region](https://azure.microsoft.com/global-infrastructure/services/?products=netapp&regions=all) for a list of supported regions.
    > To obtain the region name that is supported by our command line tools, please use `az account list-locations --query "[].{Region:name}" --out table`
    >

2. Create a new resource group by using the [az group create](/cli/azure/group#az-group-create) command:

    ```azurecli-interactive
    az group create \
        --name $RESOURCE_GROUP \
        --location $LOCATION
    ```

3. Create Azure NetApp Files account with [az netappfiles account create](/cli/azure/netappfiles/account#az-netappfiles-account-create) command:

    ```azurecli-interactive
    az netappfiles account create \
        --resource-group $RESOURCE_GROUP \
        --location $LOCATION \
        --account-name $ANF_ACCOUNT_NAME
    ```

# [Template](#tab/template)

[!INCLUDE [About Azure Resource Manager](~/reusable-content/ce-skilling/azure/includes/resource-manager-quickstart-introduction.md)]

The following code snippet shows how to create a NetApp account in an Azure Resource Manager template (ARM template), using the [Microsoft.NetApp/netAppAccounts](/azure/templates/microsoft.netapp/netappaccounts) resource. To run the code, download the [full ARM template](https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.netapp/anf-nfs-volume/azuredeploy.json) from our GitHub repo.

:::code language="json" source="~/quickstart-templates/quickstarts/microsoft.netapp/anf-nfs-volume/azuredeploy.json" range="177-183":::

<!-- Block begins with "type": "Microsoft.NetApp/netAppAccounts", -->

# [Terraform](#tab/terraform)

The following code snippet shows how to create a NetApp account using [Terraform](/azure/developer/terraform). The sample code for this article is located in the [Azure Terraform GitHub repo](https://github.com/Azure/terraform/tree/master/quickstart/101-azure-netapp-files). You can view the log file containing the [test results from current and previous versions of Terraform](https://github.com/Azure/terraform/tree/master/quickstart/101-azure-netapp-files/TestRecord.md).

:::code language="terraform" source="~/terraform_samples/quickstart/101-azure-netapp-files/main.tf" range="48-53":::

---