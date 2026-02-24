---
title: Create a VM with a static public IP address using the Azure portal, Azure PowerShell, or Azure CLI
description: Learn how to create a VM with a static public IP address using the Azure portal, Azure PowerShell, or Azure CLI.
services: virtual-network
ms.date: 11/14/2024
ms.author: mbender
author: mbender-ms
ms.service: azure-virtual-network
ms.subservice: ip-services
ms.topic: how-to
ms.custom: template-how-to
# Customer intent: As a cloud administrator, I want to create a virtual machine with a static public IP address using Azure, so that I can ensure reliable external connectivity for my applications.
---
# Create a virtual machine with a static public IP address using the Azure portal, Azure PowerShell, or Azure CLI

In this article, you create a virtual machine (VM) with a static public IP address. A public IP address enables you to communicate to a VM from the internet. Assign a static public IP address, rather than a dynamic address, to ensure the address never changes. 

Public IP addresses have a [nominal charge](https://azure.microsoft.com/pricing/details/ip-addresses). There's a [limit](../../azure-resource-manager/management/azure-subscription-service-limits.md?toc=%2fazure%2fvirtual-network%2ftoc.json#azure-resource-manager-virtual-networking-limits) to the number of public IP addresses that you can use per subscription. 

You can download the list of ranges (prefixes) for the Azure [Public](https://www.microsoft.com/download/details.aspx?id=56519), [US government](https://www.microsoft.com/download/details.aspx?id=57063), [China](https://www.microsoft.com/download/details.aspx?id=57062), and [Germany](https://www.microsoft.com/download/details.aspx?id=57064) clouds.

[!INCLUDE [ip-services-prerequisites](../../../includes/ip-services-prerequisites.md)]

## Create a virtual machine with a static public IP address

In this section, you create a virtual machine with a static public IP address using the Azure portal, Azure PowerShell, or Azure CLI. Along with the virtual machine, you create a public IP address and the other required resources.

# [Azure portal](#tab/azureportal)

### Sign in to Azure

Sign in to the [Azure portal](https://portal.azure.com).

### Create a virtual machine

1. In the search box at the top of the portal, enter *Virtual machine*.

2. In the search results, select **Virtual machines**. 

3. Select **+ Create**, then select **Azure virtual machine**.

4. In **Basics** tab of **Create a virtual machine**, enter or select the following:

    | Setting | Value  |
    | ------- | ------ |
    | **Project Details** |  |
    | Subscription | Select your Azure subscription |
    | Resource Group | Select **Create new**.</br> In **Name**, enter *myResourceGroup*.</br> Select **OK**. |
    | **Instance details** |  |
    | Virtual machine name | Enter *myVM*. |
    | Region | Select **East US**. |
    | Availability Options | Select **No infrastructure redundancy required**. |
    | Security type | Select **Standard**. |
    | Image | Select **Windows Server 2019 Datacenter - x64 Gen2**. |
    | Size | Choose VM size or take default setting. |
    | **Administrator account** |  |
    | Username | Enter a username. |
    | Password | Enter a password. |
    | Confirm password | Reenter password. |
    | Public inbound ports | Select **None**. |

    > [!NOTE]
    > Use Azure Bastion to securely connect to the VM. Azure Bastion is deployed in a later section of this article.

5. Select the **Networking** tab, or select **Next: Disks**, then **Next: Networking**.
  
6. In the **Networking** tab, enter or select the following:

    | Setting | Value |
    |-|-|
    | **Network interface** |  |
    | Virtual network | Accept the default network name. |
    | Subnet | Accept the default subnet configuration. |
    | Public IP | Select **Create new**.</br> In **Create public IP address**, enter *myPublicIP* in **Name**.</br> **SKU**: select **Standard**.</br> **Assignment**: select **Static**.</br> Select **OK**. |
    
    > [!NOTE]
    > The SKU of the virtual machine's public IP address must match the public IP SKU of Azure public load balancer when added to the backend pool of the load balancer. For details, see [Azure Load Balancer](../../load-balancer/skus.md).
   
7. Select **Review + create**. 
  
8. Review the settings, and then select **Create**.

> [!WARNING]
> Do not modify the IP address settings within the virtual machine's operating system. The operating system is unaware of Azure public IP addresses. Though you can add private IP address settings to the operating system, we recommend not doing so unless necessary. For more information, see [Add a private IP address to an operating system](./virtual-network-network-interface-addresses.md#private).

### Deploy Azure Bastion

Azure Bastion uses your browser to connect to VMs in your virtual network over RDP by using their private IP addresses. The VM doesn't need a public IP address for management access, client software, or special configuration. For more information, see [Azure Bastion](/azure/bastion/bastion-overview).

>[!NOTE]
>[!INCLUDE [Pricing](~/reusable-content/ce-skilling/azure/includes/bastion-pricing.md)]

1. In the search box at the top of the portal, enter **Bastion**. Select **Bastions** in the search results.

1. Select **+ Create**.

1. In the **Basics** tab of **Create a Bastion**, enter, or select the following information:

    | Setting | Value |
    |---|---|
    | **Project details** |  |
    | Subscription | Select your subscription. |
    | Resource group | Select **myResourceGroup**. |
    | **Instance details** |  |
    | Name | Enter **bastion**. |
    | Region | Select **East US**. |
    | Tier | Select **Developer**. |
    | **Configure virtual networks** |  |
    | Virtual network | Select the virtual network for **myVM**. |
    | Subnet | The **AzureBastionSubnet** is created automatically with an address space of **/26** or larger. |

1. Select **Review + create**.

1. Select **Create**.

[!INCLUDE [ephemeral-ip-note.md](~/reusable-content/ce-skilling/azure/includes/ephemeral-ip-note.md)]

# [Azure PowerShell](#tab/azurepowershell)

### Create a resource group

An Azure resource group is a logical container into which Azure resources are deployed and managed.

Create a resource group with [New-AzResourceGroup](/powershell/module/az.resources/new-azresourcegroup) named **myResourceGroup** in the **eastus2** location.

```azurepowershell-interactive
$rg =@{
    Name = 'myResourceGroup'
    Location = 'eastus2'
}
New-AzResourceGroup @rg

```

### Create a virtual network

Create a virtual network and subnets for the virtual machine and Azure Bastion with [New-AzVirtualNetwork](/powershell/module/az.network/new-azvirtualnetwork) and [New-AzVirtualNetworkSubnetConfig](/powershell/module/az.network/new-azvirtualnetworksubnetconfig).

```azurepowershell-interactive
## Create virtual network and subnets. ##
$bastionSubnet = New-AzVirtualNetworkSubnetConfig -Name "AzureBastionSubnet" -AddressPrefix "10.0.1.0/24"
$vmSubnet = New-AzVirtualNetworkSubnetConfig -Name "default" -AddressPrefix "10.0.0.0/24"

$vnetParams = @{
    ResourceGroupName = "myResourceGroup"
    Location = "eastus2"
    Name = "myVNet"
    AddressPrefix = "10.0.0.0/16"
    Subnet = $bastionSubnet, $vmSubnet
}
$vnet = New-AzVirtualNetwork @vnetParams
```

### Create a public IP address

Use [New-AzPublicIpAddress](/powershell/module/az.network/new-azpublicipaddress) to create a standard public IPv4 address.

The following command creates a zone-redundant public IP address named **myPublicIP** in **myResourceGroup**.

```azurepowershell-interactive
## Create IP. ##
$ip = @{
    Name = 'myPublicIP'
    ResourceGroupName = 'myResourceGroup'
    Location = 'eastus2'
    Sku = 'Standard'
    AllocationMethod = 'Static'
    IpAddressVersion = 'IPv4'
    Zone = 1,2,3   
}
New-AzPublicIpAddress @ip
```
### Create a virtual machine

Create a virtual machine with [New-AzVM](/powershell/module/az.Compute/new-azvm). 

The following command creates a Windows Server virtual machine. You enter the name of the public IP address created previously in the **`-PublicIPAddressName`** parameter. When prompted, provide a username and password to be used as the credentials for the virtual machine:

```azurepowershell-interactive
## Create virtual machine. ##
$vm = @{
    ResourceGroupName = 'myResourceGroup'
    Location = 'East US 2'
    Name = 'myVM'
    PublicIpAddressName = 'myPublicIP'
    VirtualNetworkName = 'myVNet'
    SubnetName = 'default'
}
New-AzVM @vm
```

### Deploy Azure Bastion

Create a public IP address for the Azure Bastion host with [New-AzPublicIpAddress](/powershell/module/az.network/new-azpublicipaddress), then deploy Azure Bastion with [New-AzBastion](/powershell/module/az.network/new-azbastion).

```azurepowershell-interactive
## Create public IP for Bastion. ##
$bastionIpParams = @{
    ResourceGroupName = "myResourceGroup"
    Name = "public-ip-bastion"
    Location = "eastus2"
    AllocationMethod = "Static"
    Sku = "Standard"
}
New-AzPublicIpAddress @bastionIpParams

## Create Bastion. ##
$bastionParams = @{
    ResourceGroupName = "myResourceGroup"
    Name = "bastion"
    VirtualNetworkName = "myVNet"
    PublicIpAddressName = "public-ip-bastion"
    PublicIpAddressRgName = "myResourceGroup"
    VirtualNetworkRgName = "myResourceGroup"
    Sku = "Basic"
}
New-AzBastion @bastionParams -AsJob
```

For more information on public IP SKUs, see [Public IP address SKUs](public-ip-addresses.md#sku). A virtual machine can be added to the backend pool of an Azure Load Balancer. The SKU of the public IP address must match the SKU of a load balancer's public IP. For more information, see [Azure Load Balancer](../../load-balancer/skus.md).

View the public IP address assigned and confirm that it was created as a static address, with [Get-AzPublicIpAddress](/powershell/module/az.network/get-azpublicipaddress):

```azurepowershell-interactive
## Retrieve public IP address settings. ##
$ip = @{
    Name = 'myPublicIP'
    ResourceGroupName = 'myResourceGroup'
}
Get-AzPublicIpAddress @ip | Select "IpAddress","PublicIpAllocationMethod" | Format-Table

```

> [!WARNING]
> Do not modify the IP address settings within the virtual machine's operating system. The operating system is unaware of Azure public IP addresses. Though you can add private IP address settings to the operating system, we recommend not doing so unless necessary, and not until after reading [Add a private IP address to an operating system](virtual-network-network-interface-addresses.md#private).

[!INCLUDE [ephemeral-ip-note.md](~/reusable-content/ce-skilling/azure/includes/ephemeral-ip-note.md)]


# [Azure CLI](#tab/azurecli)

### Create a resource group

An Azure resource group is a logical container into which Azure resources are deployed and managed.

Create a resource group with [az group create](/cli/azure/group#az-group-create) named **myResourceGroup** in the **eastus2** location.

```azurecli-interactive
  az group create \
    --name myResourceGroup \
    --location eastus2
```

### Create a virtual network

Create a virtual network and subnets for the virtual machine and Azure Bastion with [az network vnet create](/cli/azure/network/vnet#az-network-vnet-create) and [az network vnet subnet create](/cli/azure/network/vnet/subnet#az-network-vnet-subnet-create).

```azurecli-interactive
az network vnet create \
    --resource-group myResourceGroup \
    --name myVNet \
    --address-prefix 10.0.0.0/16 \
    --subnet-name default \
    --subnet-prefix 10.0.0.0/24 \
    --location eastus2

az network vnet subnet create \
    --resource-group myResourceGroup \
    --vnet-name myVNet \
    --name AzureBastionSubnet \
    --address-prefix 10.0.1.0/26
```

### Create a public IP address

Use [az network public-ip create](/cli/azure/network/public-ip#az-network-public-ip-create) to create a standard public IPv4 address.

The following command creates a zone-redundant public IP address named **myPublicIP** in **myResourceGroup**.

```azurecli-interactive
az network public-ip create \
    --resource-group myResourceGroup \
    --name myPublicIP \
    --version IPv4 \
    --sku Standard \
    --zone 1 2 3
```
### Create a virtual machine

Create a virtual machine with [az vm create](/cli/azure/vm#az-vm-create). 

The following command creates a Windows Server virtual machine. You enter the name of the public IP address created previously in the **`-PublicIPAddressName`** parameter. When prompted, provide a username and password to be used as the credentials for the virtual machine:

```azurecli-interactive
az vm create \
    --name myVM \
    --resource-group myResourceGroup \
    --public-ip-address myPublicIP \
    --size Standard_A2 \
    --image MicrosoftWindowsServer:WindowsServer:2019-Datacenter:latest \
    --admin-username azureuser \
    --vnet-name myVNet \
    --subnet default
```

### Deploy Azure Bastion

Create a public IP address for the Azure Bastion host with [az network public-ip create](/cli/azure/network/public-ip#az-network-public-ip-create), then deploy Azure Bastion with [az network bastion create](/cli/azure/network/bastion#az-network-bastion-create).

```azurecli-interactive
az network public-ip create \
    --resource-group myResourceGroup \
    --name public-ip-bastion \
    --location eastus2 \
    --allocation-method Static \
    --sku Standard

az network bastion create \
    --resource-group myResourceGroup \
    --name bastion \
    --vnet-name myVNet \
    --public-ip-address public-ip-bastion \
    --location eastus2 \
    --sku Basic \
    --no-wait
```

For more information on public IP SKUs, see [Public IP address SKUs](public-ip-addresses.md#sku). A virtual machine can be added to the backend pool of an Azure Load Balancer. The SKU of the public IP address must match the SKU of a load balancer's public IP. For more information, see [Azure Load Balancer](../../load-balancer/skus.md).

View the public IP address assigned and confirm that it was created as a static address, with [az network public-ip show](/cli/azure/network/public-ip#az-network-public-ip-show):

```azurecli-interactive
  az network public-ip show \
    --resource-group myResourceGroup \
    --name myPublicIP \
    --query [ipAddress,publicIpAllocationMethod,sku] \
    --output table
```

> [!WARNING]
> Do not modify the IP address settings within the virtual machine's operating system. The operating system is unaware of Azure public IP addresses. Though you can add private IP address settings to the operating system, we recommend not doing so unless necessary, and not until after reading [Add a private IP address to an operating system](virtual-network-network-interface-addresses.md#private).

[!INCLUDE [ephemeral-ip-note.md](~/reusable-content/ce-skilling/azure/includes/ephemeral-ip-note.md)]

---


## Clean up resources

When resources are no longer needed, delete all resources created in this article to avoid incurring charges.

# [Azure portal](#tab/azureportal)

Use the Azure portal to delete the resource group and all of the resources it contains:

1. Enter *myResourceGroup* in the search box at the top of the portal. When you see **myResourceGroup** in the search results, select it.

2. Select **Delete resource group**.

3. Enter *myResourceGroup* for **TYPE THE RESOURCE GROUP NAME:** and select **Delete**.

# [Azure PowerShell](#tab/azurepowershell)

Use [Remove-AzResourceGroup](/powershell/module/az.resources/remove-azresourcegroup) to remove the resource group and all of the resources it contains:

```azurepowershell-interactive
Remove-AzResourceGroup -Name myResourceGroup -Force
```

# [Azure CLI](#tab/azurecli)

Use [az group delete](/cli/azure/group#az-group-delete) to remove the resource group and all of the resources it contains:

```azurecli-interactive
  az group delete --name myResourceGroup --yes
```
---

## Next steps

In this article, you learned how to create a VM with a static public IP.

- Learn how to [Configure IP addresses for an Azure network interface](./virtual-network-network-interface-addresses.md).

- Learn how to [Assign multiple IP addresses to virtual machines](./virtual-network-multiple-ip-addresses-portal.md) using the Azure portal.

- Learn more about [public IP addresses](./public-ip-addresses.md#public-ip-addresses) in Azure.
