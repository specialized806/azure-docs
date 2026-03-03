---
title: 'Quickstart: Direct web traffic using the portal'
titleSuffix: Azure Application Gateway
description: In this quickstart, you learn how to use the Azure portal to create an Azure Application Gateway that directs web traffic to virtual machines in a backend pool.
services: application-gateway
author: mbender-ms
ms.author: mbender
ms.date: 03/03/2026
ms.topic: quickstart
ms.service: azure-application-gateway
ms.custom:
  - mvc
  - mode-ui
  - sfi-image-nochange
# Customer intent: "As a network engineer, I want to set up an application gateway that directs web traffic to backend virtual machines, so that I can manage traffic efficiently and ensure high availability for my web applications."
---

# Quickstart: Direct web traffic with Azure Application Gateway - Azure portal

In this quickstart, you use the Azure portal to create an [Azure Application Gateway](overview.md) and test it to make sure it works correctly. You assign listeners to ports, create rules, and add resources to a backend pool. For the sake of simplicity, a simple setup is used with a public frontend IP address, a basic listener to host a single site on the application gateway, a basic request routing rule, and two virtual machines (VMs) in the backend pool.

:::image type="content" source="./media/quick-create-portal/application-gateway-qs-resources.png" alt-text="Conceptual diagram of the quickstart setup." lightbox="./media/quick-create-portal/application-gateway-qs-resources.png":::

For more information about the components of an application gateway, see [Application gateway components](application-gateway-components.md).

You can also complete this quickstart using [Azure PowerShell](quick-create-powershell.md) or [Azure CLI](quick-create-cli.md).

> [!NOTE]
> Application Gateway frontend now supports dual-stack IP addresses (Preview). You can now create up to four frontend IP addresses: Two IPv4 addresses (public and private) and two IPv6 addresses (public and private).

## Prerequisites

- An Azure account with an active subscription is required. If you don't already have an account, you can [create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).

## Create a resource group and virtual network

Create a resource group and virtual network for the application gateway and related resources. A resource group is a container that holds related resources for an Azure solution. The virtual network is needed for the application gateway to communicate with other resources.

> [!NOTE]
> The application gateway must be in a separate subnet from the backend targets. In this quickstart, *myAGSubnet* is used for the application gateway and *myBackendSubnet* is used for the backend targets.

1. Sign in to the [Azure portal](https://portal.azure.com) with your Azure account.
1. On the Azure portal menu or from the **Home** page, enter "Resource groups" in the search box, and then select **Resource groups** from the search results.
1. On the **Resource groups** page, select **+ Create**.
1. On the **Create a resource group** page, enter these values for the following resource group settings:

   | Setting | Value |
   | --- | --- |
   | **Subscription** | Select your Azure subscription from the drop-down list. |
   | **Resource group** | Enter *myResourceGroupAG* for the name of the resource group. |
   | **Region** | Select a region from the drop-down list. Select the same region when you create other resources for this quickstart. |

1. Select **Review + create** and then select **Create**.
1. Browse to the resource group that you just created by selecting **Resource groups** from the Azure portal menu, and then selecting **myResourceGroupAG** from the list.
1. On the **myResourceGroupAG** page, select **+ Create** to create a new resource in this resource group.
1. In the **Search the Marketplace** box, enter **Virtual Network** and select **Virtual Network** from the search results.
1. Select **Create** on the **Virtual Network** page.
1. On the **Create virtual network** page, enter these values for the following virtual network settings:

   | Setting | Value |
   | --- | --- |
   | **Subscription** | Select your Azure subscription from the drop-down list. |
   | **Resource group** | Verify that *myResourceGroupAG* is selected. |
   | **Name** | Enter *myVNet* for the name of the virtual network. |
   | **Region** | Select the same region you selected for the resource group. |

1. Select **Next > Next** or select the **IP Addresses** tab to configure the IP address settings for the virtual network.
1. On the **IP Addresses** tab, select **+ Add a subnet** to add a subnet for the application gateway. 
1. In the **Add subnet** window, enter *myBackendSubnet* for the name of the subnet and accept the default address range & other settings, then select **Add** to save the subnet and return to the **IP Addresses** tab.
1. From the **Subnets** list, select the **default** subnet and select the pencil icon to edit the subnet. Change the name of this subnet to *myAGSubnet* and then select **Save**.
1. Select **Review + create** and then select **Create** to create the virtual network.

## Create an application gateway

Create the application gateway using the tabs on the **Create application gateway** page. The Standard v2 SKU is used in this example. To create a Basic SKU using the Azure portal, see [Deploy Application Gateway basic (Preview)](deploy-basic-portal.md).

1. On the Azure portal menu or from the **Home** page, enter "Application Gateway" in the search box, and then select **Application Gateways** from the search results.
1. On the **Application Gateways** page, select **+ Create > Application Gateway**.
1. On the **Basics** tab, enter these values for the following application gateway settings:

    | Setting | Value |
    | --- | --- |
    | **Subscription** | Select your Azure subscription from the drop-down list. |
    | **Resource group** | Select **myResourceGroupAG** for the resource group. |
    | **Application gateway name** | Enter **myAppGateway** for the name of the application gateway. |
    | **Region** | Select the same region you selected for the resource group. |
    | **Tier** | Select **Standard V2** from the drop-down list. |
    | **Configure virtual network** |  |
    | **Virtual network** | Select **myVNet** from the drop-down list. |
    | **Subnet** | Select **myAGSubnet** from the drop-down list. |

    > [!NOTE]
    > Application Gateways are zone-redundant by default in regions that support multiple availability zones.
    > [Virtual network service endpoint policies](../virtual-network/virtual-network-service-endpoint-policies-overview.md) are currently not supported in an Application Gateway subnet.

### Frontends tab

The frontend of an application gateway is the entry point for incoming traffic. The frontend configuration includes the frontend IP address and the frontend ports. The frontend IP address can be either public or private. In this example, you create a public frontend IP address.

1. Select **Next: Frontends**.
1. On the **Frontends** tab, verify **Frontend IP address type** is set to **Public**. <br>You can configure the Frontend IP to be Public or Private as per your use case. In this example, you'll choose a Public Frontend IP.
   > [!NOTE]
   > * The [Private-only deployment](application-gateway-private-deployment.md) (with only private IP) for the Application Gateway v2 SKU is currently in Public Preview.
   > * Application Gateway frontend now supports dual-stack IP addresses in Public Preview. You can create up to four frontend IP addresses: Two IPv4 addresses (public and private) and two IPv6 addresses (public and private).

1. Select **Add new** for the **Public IP address** and enter *myAGPublicIPAddress* for the public IP address name, and then select **OK**. 
1. Select **Next: Backends**.

### Backends tab

The backend pool is used to route requests to the backend servers that serve the request. Backend pools can be composed of NICs, Virtual Machine Scale Sets, public IP addresses, internal IP addresses, fully qualified domain names (FQDN), and multitenant backends like Azure App Service. In this example, you'll create an empty backend pool with your application gateway and then add backend targets to the backend pool.

1. On the **Backends** tab, select **Add a backend pool**.

1. In the **Add a backend pool** window that opens, enter the following values to create an empty backend pool:

    | Setting | Value |
    | --- | --- |
    | **Name** | Enter **myBackendPool** for the name of the backend pool. |
    | **Add backend pool without targets** | Select **Yes** to create a backend pool with no targets. You'll add backend targets after creating the application gateway. |

1. Select **Add** to save the backend pool configuration and return to the **Backends** tab.

1. On the **Backends** tab, select **Next: Configuration**.

### Configuration tab

On the **Configuration** tab, you'll connect the frontend and backend pool you created using a routing rule.

1. Select **Add a routing rule** in the **Routing rules** column.

1. In the **Add a routing rule** window that opens, enter the following values for Rule name and Priority:

    - **Rule name**: Enter *myRoutingRule* for the name of the rule.
    - **Priority**: The priority value should be between 1 and 20000 (where 1 represents highest priority and 20000 represents lowest) - for the purposes of this quickstart, enter *100* for the priority.

1. On the **Listener** tab within the **Add a routing rule** window, enter the following values for the listener:

    | Setting | Value |
    | --- | --- |
    | **Listener name** | Enter *myListener* for the name of the listener. |
    | **Frontend IP** | Select **Public IPv4** to choose the public IP you created for the frontend. |

1. Accept the default values for the other settings on the **Listener** tab, then select the **Backend targets** tab to configure the rest of the routing rule.

1. On the **Backend targets** tab, select or enter the following:

    | Setting | Value |
    | --- | --- |
    | **Target type** | Select **Backend pool** radio button |
    | **Backend target** | Select **myBackendPool**. |
    | **Backend settings** | Select **Add new** to add a new backend setting. |
    | **Add backend setting** | In the **Add Backend setting** window, enter the following: |
    | **Backend settings name** | Enter **myBackendSetting** for the name of the backend setting. |
    | **Backend port** | Enter *80* for the backend port. |

1. Accept the default values for the other settings and select **Add** to return to the **Add a routing rule** window. |

1. On the **Add a routing rule** window, select **Add** to save the routing rule and return to the **Configuration** tab.

1. Select **Next: Tags** and then **Next: Review + create**.

### Review + create tab

Review the settings on the **Review + create** tab, and then select **Create** to create the virtual network, the public IP address, and the application gateway. It can take several minutes for Azure to create the application gateway. Wait until the deployment finishes successfully before moving on to the next section.

## Add backend targets

In this example, you'll use virtual machines as the target backend. You can either use existing virtual machines or create new ones. You'll create two virtual machines as backend servers for the application gateway.

To do this, you'll:

1. Add a backend subnet.
1. Create two new VMs, *myVM* and *myVM2*, to be used as backend servers.
1. Install IIS on the virtual machines to verify that the application gateway was created successfully.
1. Add the backend servers to the backend pool.

### Create a virtual machine

1. On the Azure portal menu or from the **Home** page, select **Create a resource**. The **New** window appears.
1. Select **Windows Server 2022 Datacenter** in the **Popular** list. The **Create a virtual machine** page appears.<br>Application Gateway can route traffic to any type of virtual machine used in its backend pool. In this example, you use a Windows Server 2022 Datacenter virtual machine.
1. Enter these values in the **Basics** tab for the following virtual machine settings:

    | Setting | Value |
    | --- | --- |
    | **Resource group** | Select **myResourceGroupAG** for the resource group name. |
    | **Virtual machine name** | Enter *myVM* for the name of the virtual machine. |
    | **Region** | Select the same region where you created the application gateway. |
    | **Username** | Type a name for the administrator user name. |
    | **Password** | Type a password. |
    | **Public inbound ports** | None. |
1. Accept the other defaults and then select **Next: Disks**.  
1. Accept the **Disks** tab defaults and then select **Next: Networking**.
1. On the **Networking** tab, verify that **myVNet** is selected for the **Virtual network** and the **Subnet** is set to **myBackendSubnet**. For **Public IP**, select **None**. Accept the other defaults and then select **Next: Management**.<br>Application Gateway can communicate with instances outside of the virtual network that it's in, but you need to ensure there's IP connectivity.
1. Select **Next: Monitoring** and set **Boot diagnostics** to **Disable**. Accept the other defaults and then select **Review + create**.
1. On the **Review + create** tab, review the settings, correct any validation errors, and then select **Create**.
1. Wait for the virtual machine creation to complete before continuing.

> [!NOTE]
> The default rules of the network security group block all inbound access from the internet, including RDP. To connect to the virtual machine, use Azure Bastion. For more information, see [Quickstart: Deploy Azure Bastion with default settings](../bastion/quickstart-host-portal.md).

### Install IIS for testing

In this example, you install IIS on the virtual machines to verify Azure created the application gateway successfully.

1. Open Azure PowerShell.

   Select **Cloud Shell** from the top navigation bar of the Azure portal and then select **PowerShell** from the drop-down list. 

    :::image type="content" source="./media/application-gateway-create-gateway-portal/application-gateway-extension.png" alt-text="Screenshot of installing custom extension in Cloud Shell.":::

1. Run the following command to install IIS on the virtual machine. Change the *Location* parameter if necessary: 

    ```azurepowershell
    Set-AzVMExtension `
      -ResourceGroupName myResourceGroupAG `
      -ExtensionName IIS `
      -VMName myVM `
      -Publisher Microsoft.Compute `
      -ExtensionType CustomScriptExtension `
      -TypeHandlerVersion 1.4 `
      -SettingString '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}' `
      -Location EastUS
    ```

1. Create a second virtual machine and install IIS by using the steps that you previously completed. Use *myVM2* for the virtual machine name and for the `VMName` setting of the **Set-AzVMExtension** cmdlet.

### Add backend servers to backend pool

1. On the Azure portal menu, select **All resources** or search for and select *All resources*. Then select **myAppGateway**.
1. Select **Backend pools** from the left menu.
1. Select **myBackendPool**.
1. Under **Backend targets**, **Target type**, select **Virtual machine** from the drop-down list.
1. Under **Target**, select the **myVM** and **myVM2** virtual machines and their associated network interfaces from the drop-down lists.

1. Select **Save**.
1. Wait for the deployment to complete before proceeding to the next step.

## Test the application gateway

Although IIS isn't required to create the application gateway, you installed it in this quickstart to verify if Azure successfully created the application gateway. 

Use IIS to test the application gateway:

1. Find the public IP address for the application gateway on its **Overview** page. Or, you can select **All resources**, enter *myAGPublicIPAddress* in the search box, and then select it in the search results. Azure displays the public IP address on the **Overview** page.
1. Copy the public IP address, and then paste it into the address bar of your browser to browse that IP address.
1. Check the response. A valid response verifies that the application gateway was successfully created and can successfully connect with the backend.

   Refresh the browser multiple times and you should see connections to both myVM and myVM2.

## Clean up resources

When you no longer need the resources that you created with the application gateway, delete the resource group. When you delete the resource group, you also remove the application gateway and all the related resources.

To delete the resource group:

1. On the Azure portal menu, select **Resource groups** or search for and select *Resource groups*.
1. On the **Resource groups** page, search for **myResourceGroupAG** in the list, then select it.
1. On the **Resource group page**, select **Delete resource group**.
1. Enter *myResourceGroupAG* under **TYPE THE RESOURCE GROUP NAME** and then select **Delete**.

## Next steps

> [!div class="nextstepaction"]
> [Tutorial: Configure an application gateway with TLS termination using the Azure portal](create-ssl-portal.md)
