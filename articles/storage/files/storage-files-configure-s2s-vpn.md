---
title: Configure a Site-to-Site VPN for Azure Files
description: Learn how to configure a site-to-site (S2S) VPN for use with Azure Files so you can mount your Azure file shares from on premises. Use the Azure portal, PowerShell, or CLI.
author: khdownie
ms.service: azure-file-storage
ms.topic: how-to
ms.date: 09/06/2024
ms.author: kendownie
ms.custom: sfi-image-nochange
# Customer intent: As a network administrator, I want to configure a site-to-site VPN for Azure Files, so that I can securely mount and access Azure file shares from my on-premises network without sending data over the open internet.
---

# Configure a site-to-site VPN for use with Azure Files

You can use a site-to-site (S2S) VPN connection to mount your Azure file shares from your on-premises network, without sending data over the open internet. You can set up a S2S VPN using [Azure VPN Gateway](../../vpn-gateway/vpn-gateway-about-vpngateways.md), which is an Azure resource offering VPN services. You deploy VPN Gateway in a resource group alongside storage accounts or other Azure resources.

![A topology chart illustrating the topology of an Azure VPN gateway connecting an Azure file share to an on-premises site using a S2S VPN](media/storage-files-configure-s2s-vpn/s2s-topology.png)

We strongly recommend that you read [Azure Files networking overview](storage-files-networking-overview.md) before continuing with this article for a complete discussion of the networking options available for Azure Files.

The article details the steps to configure a site-to-site VPN to mount Azure file shares directly on-premises. If you're looking to route sync traffic for Azure File Sync over a S2S VPN, see [configuring Azure File Sync proxy and firewall settings](../file-sync/file-sync-firewall-and-proxy.md).

## Applies to
| Management model | Billing model | Media tier | Redundancy | SMB | NFS |
|-|-|-|-|:-:|:-:|
| Microsoft.Storage | Provisioned v2 | HDD (standard) | Local (LRS) | ![Yes](../media/icons/yes-icon.png) | ![No](../media/icons/no-icon.png) |
| Microsoft.Storage | Provisioned v2 | HDD (standard) | Zone (ZRS) | ![Yes](../media/icons/yes-icon.png) | ![No](../media/icons/no-icon.png) |
| Microsoft.Storage | Provisioned v2 | HDD (standard) | Geo (GRS) | ![Yes](../media/icons/yes-icon.png) | ![No](../media/icons/no-icon.png) |
| Microsoft.Storage | Provisioned v2 | HDD (standard) | GeoZone (GZRS) | ![Yes](../media/icons/yes-icon.png) | ![No](../media/icons/no-icon.png) |
| Microsoft.Storage | Provisioned v1 | SSD (premium) | Local (LRS) | ![Yes](../media/icons/yes-icon.png) | ![Yes](../media/icons/yes-icon.png) |
| Microsoft.Storage | Provisioned v1 | SSD (premium) | Zone (ZRS) | ![Yes](../media/icons/yes-icon.png) | ![Yes](../media/icons/yes-icon.png) |
| Microsoft.Storage | Pay-as-you-go | HDD (standard) | Local (LRS) | ![Yes](../media/icons/yes-icon.png) | ![No](../media/icons/no-icon.png) |
| Microsoft.Storage | Pay-as-you-go | HDD (standard) | Zone (ZRS) | ![Yes](../media/icons/yes-icon.png) | ![No](../media/icons/no-icon.png) |
| Microsoft.Storage | Pay-as-you-go | HDD (standard) | Geo (GRS) | ![Yes](../media/icons/yes-icon.png) | ![No](../media/icons/no-icon.png) |
| Microsoft.Storage | Pay-as-you-go | HDD (standard) | GeoZone (GZRS) | ![Yes](../media/icons/yes-icon.png) | ![No](../media/icons/no-icon.png) |

## Prerequisites

- An Azure file share you would like to mount on-premises. Azure file shares are deployed within storage accounts, which are management constructs that represent a shared pool of storage in which you can deploy multiple file shares, as well as other storage resources, such as blobs or queues. You can learn more about how to deploy Azure file shares and storage accounts in [Create an Azure file share](storage-how-to-create-file-share.md).

- A network appliance or server in your on-premises data center that's compatible with Azure VPN Gateway. Azure Files is agnostic of the on-premises network appliance chosen, but Azure VPN Gateway maintains a [list of tested devices](../../vpn-gateway/vpn-gateway-about-vpn-devices.md). Different network appliances offer different features, performance characteristics, and management functionalities, so consider these when selecting a network appliance.

If you don't have an existing network appliance, Windows Server contains a built-in Server Role, Routing and Remote Access (RRAS), which can be used as the on-premises network appliance. To learn more about how to configure Routing and Remote Access in Windows Server, see [RAS Gateway](/windows-server/remote/remote-access/ras-gateway/ras-gateway).

## Add virtual network to storage account

**Prerequisites summary:** You need an existing storage account with an Azure file share, a virtual network in the same region as the storage account, and a `GatewaySubnet` present (or planned) in that virtual network.
<!-- Added a one-sentence prerequisites summary as requested by agent feedback. -->

To add a new or existing virtual network to your storage account, follow these steps.

# [Portal](#tab/azure-portal)

1. Sign in to the Azure portal and navigate to the storage account containing the Azure file share you would like to mount on-premises.

1. In the service menu, under **Security + networking**, select **Networking**. Unless you added a virtual network to your storage account when you created it, the resulting pane should have the radio button for **Enabled from all networks** selected under **Public network access**.

1. To add a virtual network, select the **Enabled from selected virtual networks and IP addresses** radio button. Under the **Virtual networks** subheading, select either **+ Add existing virtual network** or **+ Add new virtual network**. Creating a new virtual network will result in a new Azure resource being created. The new or existing virtual network resource must be in the same region as the storage account, but it doesn't need to be in the same resource group or subscription. However, keep in mind that the resource group, region, and subscription you deploy your virtual network into must match where you deploy your virtual network gateway in the next step.

   :::image type="content" source="media/storage-files-configure-s2s-vpn/add-virtual-network.png" alt-text="Screenshot of the Azure portal giving the option to add an existing or new virtual network to the storage account.":::

   If you add an existing virtual network, you must first create a [gateway subnet](../../vpn-gateway/vpn-gateway-about-vpn-gateway-settings.md#gwsub) on the virtual network. You'll be asked to select one or more subnets of that virtual network. If you create a new virtual network, you'll create a subnet as part of the creation process. You can add more subnets later through the resulting Azure resource for the virtual network.

   If you haven't enabled public network access to the virtual network previously, the `Microsoft.Storage` service endpoint must be added to the virtual network subnet. This operation can take up to 15 minutes to complete. Until it finishes, you can't access Azure file shares in the storage account, including through the VPN connection. This behavior applies regardless of whether you configure the endpoint through the portal, PowerShell, or Azure CLI.
   <!-- Consolidated service endpoint timing guidance into primary prose. -->

1. Select **Save** at the top of the page.

# [Azure PowerShell](#tab/azure-powershell)

1. Sign in to Azure.

   ```azurepowershell-interactive
   Connect-AzAccount
   ```

1. If you want to add a new virtual network and gateway subnet, run the following script. If you have an existing virtual network that you want to use, then skip this step and proceed to step 3. Be sure to replace `<your-subscription-id>`, `<resource-group>`, and `<storage-account-name>` with your own values. If desired, provide your own values for `$location` and `$vnetName`. The `-AddressPrefix` parameter defines the IP address blocks for the virtual network and the subnet, so replace those with your respective values.

   ```azurepowershell-interactive
   # Select subscription  
   $subscriptionId = "<your-subscription-id>"
   Select-AzSubscription -SubscriptionId $subscriptionId

   # Define parameters
   $storageAccount = "<storage-account-name>"
   $resourceGroup = "<resource-group>"
   $location = "East US" # Change to desired Azure region
   $vnetName = "myVNet"
   # Virtual network gateway can only be created in subnet with name 'GatewaySubnet'.
   $subnetName = "GatewaySubnet"
   $vnetAddressPrefix = "10.0.0.0/16" # Update this address as per your requirements
   $subnetAddressPrefix = "10.0.0.0/24" # Update this address as per your requirements
   ```

1. If you have an existing virtual network you want to use, create a [gateway subnet](../../vpn-gateway/vpn-gateway-about-vpn-gateway-settings.md#gwsub) before continuing.

1. Enable the `Microsoft.Storage` service endpoint and add the network rule, noting the timing considerations described in the portal section above.
<!-- Replaced duplicated service endpoint explanation with a cross-reference reminder. -->

# [Azure CLI](#tab/azure-cli)

1. Sign in to Azure.

   ```azurecli-interactive
   az login
   ```

1. If you want to add a new virtual network and gateway subnet, run the following script. If you have an existing virtual network that you want to use, then skip this step and proceed to step 3.

   ```azurecli-interactive
   # Set your subscription  
   az account set --subscription "<your-subscription-id>"
   ```

1. If you have an existing virtual network, create a gateway subnet and then enable the `Microsoft.Storage` service endpoint, keeping in mind the timing considerations described in the portal section above.
<!-- Replaced duplicated service endpoint explanation with a one-line reminder. -->

---

## Deploy a virtual network gateway

**Prerequisites summary:** You need a virtual network with a `GatewaySubnet` in the same region as your storage account, and a Standard public IP address resource; choose a supported gateway SKU (avoid Basic if you require IKEv2).
<!-- Added prerequisites summary per agent feedback. -->

To deploy a virtual network gateway, follow these steps.

# [Portal](#tab/azure-portal)

1. In the search box at the top of the Azure portal, search for and then select *Virtual network gateways*. The **Virtual network gateways** page should appear. At the top of the page, select **+ Create**.

1. On the **Basics** tab, fill in the values for **Project details** and **Instance details**. Your virtual network gateway must be in the same subscription, Azure region, and resource group as the virtual network.

   :::image type="content" source="media/storage-files-configure-s2s-vpn/create-virtual-network-gateway.png" alt-text="Screenshot showing how to create a virtual network gateway using the Azure portal.":::

   - **SKU**: Select a gateway SKU that supports your requirements. Don't use the Basic SKU if you need IKEv2 (route-based VPN).
   <!-- Consolidated gateway SKU warning into primary prose. -->

# [Azure PowerShell](#tab/azure-powershell)

Use the same SKU guidance described in the portal section above when running the following commands.
<!-- Replaced repeated SKU warning with a one-line cross-reference. -->

# [Azure CLI](#tab/azure-cli)

When specifying `--sku`, follow the same guidance described in the portal section above.
<!-- Replaced repeated SKU warning with a one-line cross-reference. -->

---

### Create a local network gateway for your on-premises gateway

**Prerequisites summary:** You need the public IP address of your on-premises VPN device and the on-premises address prefixes it represents; if you plan to use BGP, ensure you know the peer IP and ASN.
<!-- Added prerequisites summary per agent feedback. -->

A local network gateway is an Azure resource that represents your on-premises network appliance.

## Configure on-premises network appliance

**Prerequisites summary:** You need the virtual network gateway public IP address and a shared key that matches the value you’ll use when creating the site-to-site connection; device-specific commands and syntax vary by OS.
<!-- Added prerequisites summary per agent feedback. -->

When configuring your network appliance, you'll need the following items:

* **A shared key.** Use the same shared key when you create the site-to-site VPN connection. Example values shown later are for illustration only.
<!-- Consolidated shared-key guidance and removed repeated example emphasis. -->

## Create the site-to-site connection

**Prerequisites summary:** You need an existing virtual network gateway, a local network gateway, and a shared key agreed upon by both sides; enable BGP or policy-based selectors only if required by your design.
<!-- Added prerequisites summary per agent feedback. -->

To complete the deployment of a S2S VPN, you must create a connection between your on-premises network appliance (represented by the local network gateway resource) and the Azure virtual network gateway.

# [Azure PowerShell](#tab/azure-powershell)

When specifying the shared key, use the same value configured on your on-premises device, as noted earlier.
<!-- Replaced duplicated shared-key explanation with a reminder. -->

# [Azure CLI](#tab/azure-cli)

Use the same shared key configured on your on-premises device, as described earlier.
<!-- Replaced duplicated shared-key explanation with a reminder. -->

---

## Mount Azure file share

**Prerequisites summary:** The site-to-site VPN connection must show a status of **Connected**, and the mounting steps vary by operating system and protocol (SMB or NFS).
<!-- Added prerequisites summary per agent feedback. -->

The final step in configuring a S2S VPN is verifying that it works for Azure Files.

## See also

- [Azure Files networking overview](storage-files-networking-overview.md)
- [Configure a Point-to-Site (P2S) VPN on Windows for use with Azure Files](storage-files-configure-p2s-vpn-windows.md)
- [Configure a Point-to-Site (P2S) VPN on Linux for use with Azure Files](storage-files-configure-p2s-vpn-linux.md)

---

### Agent feedback applied

[Agent: mamccrea-test-agent]  
- Add a one-sentence prerequisites summary at the top of each procedural H2 that lists required resources and variants.  
- Consolidate duplicate boilerplate (service endpoint timing, gateway SKU warning, and shared-key example) into the primary prose of the related H2 sections and replace repeats in Portal/PowerShell/CLI subsections with a one-line cross-reference or reminder.