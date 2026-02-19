---
title: VPN Gateway Legacy SKUs
description: How to work with the old virtual network gateway SKUs, called Standard and High Performance.
author: cherylmc
ms.service: azure-vpn-gateway
ms.topic: how-to
ms.date: 10/8/2025
ms.author: cherylmc 
# Customer intent: As a network administrator, I want to manage legacy VPN gateway SKUs so that I can ensure continuity of service and plan for the upcoming deprecation of these SKUs before the migration deadline.
---
# Work with VPN Gateway legacy SKUs

This article contains information about the legacy (old) virtual network gateway SKUs. The legacy SKUs still work in both deployment models for existing VPN gateways. Classic VPN gateways continue to use the legacy SKUs, for both existing and new gateways. When you create new Resource Manager VPN gateways, use the new gateway SKUs. For information about the new SKUs, see [About VPN Gateway](vpn-gateway-about-vpngateways.md). For the projected gateway SKU deprecation and migration timeline, see the [What's new?](whats-new.md) article.

## <a name="gwsku"></a>Legacy gateway SKUs

[!INCLUDE [Legacy gateway SKUs](../../includes/vpn-gateway-gwsku-legacy-include.md)]

You can view legacy gateway pricing on the [ExpressRoute pricing page](https://azure.microsoft.com/pricing/details/expressroute). Select the **ExpressRoute Gateways** tab, and refer to the table in the **Virtual Network Gateways** section.

For SKU deprecation, see the [SKU deprecation](#sku-deprecation) and SKU deprecation [FAQs](#sku-deprecation-faqs) sections of this article.

## <a name="agg"></a>Estimated aggregate throughput by SKU

The following table shows the gateway types and the estimated aggregate throughput by gateway SKU. This table applies to the Resource Manager and classic deployment models.

Pricing differs between gateway SKUs. For more information, see [VPN Gateway Pricing](https://azure.microsoft.com/pricing/details/vpn-gateway).

The Ultra Performance gateway SKU isn't represented in this table. For information about the Ultra Performance SKU, see the [ExpressRoute](../expressroute/expressroute-about-virtual-network-gateways.md) documentation.

| SKU | VPN Gateway throughput (1) | VPN Gateway max IPsec tunnels (2) | ExpressRoute Gateway throughput | VPN Gateway and ExpressRoute coexist |
| --- | --- | --- | --- | --- |
| Standard SKU (3)(4) | 100 Mbps | 10 | 1,000 Mbps | Yes |
| High Performance SKU (3) | 200 Mbps | 30 | 2,000 Mbps | Yes |

(1) The VPN throughput is a rough estimate based on the measurements between virtual networks in the same Azure region. It isn't a guaranteed throughput for cross-premises connections across the internet. It's the maximum possible throughput measurement.

(2) The number of tunnels refers to route-based VPNs. A policy-based VPN can only support one site-to-site VPN tunnel.

(3) Policy-based VPNs aren't supported for this SKU. They're supported for the Basic SKU.

(4) Site-to-site VPN Gateway connections in active-active mode aren't supported for this SKU. Active-active mode is supported on the High Performance SKU.

## <a name="config"></a>Supported configurations by SKU and VPN type

[!INCLUDE [Table requirements for old SKUs](../../includes/vpn-gateway-table-requirements-legacy-sku-include.md)]

## Move to another gateway SKU

Consider the following points if you want to move to another gateway SKU:

* You can't upgrade a legacy SKU to one of the newer VPN Gateway SKUs (such as VpnGw1AZ or VpnGw2AZ). To use a new SKU, you must delete the gateway, and then create a new one.
* When you go from a legacy SKU to a newer SKU, you incur connectivity downtime.
* When you go from a legacy SKU to a newer SKU, the public IP address for your VPN gateway changes. The IP address change happens even if you specified the same public IP address object that you used previously.
* If you have a classic VPN gateway, you must continue using the older legacy SKUs for that gateway. However, you can upgrade between the legacy SKUs available for classic gateways. You can't change to the new SKUs.
* Standard and High Performance legacy SKUs are being deprecated. See [Legacy SKU deprecation](vpn-gateway-about-skus-legacy.md#sku-deprecation) for SKU migration and upgrade timelines.

### <a name="migrate"></a>Migrate a gateway SKU

As part of Basic IP address migration, your legacy SKU will be migrated to a newer SKU that's supported by availability zones. All legacy SKUs use Basic IP today, and you can use the Azure portal to [migrate a Basic IP address to a Standard IP address](basic-public-ip-migrate-about.md) before the retirement date. For the most up-to-date timeline, see [What's new in Azure VPN Gateway?](whats-new.md).

### <a name="resize"></a>Upgrade to a gateway SKU in the same SKU family

For legacy gateway SKUs, there are limitations. You can only upgrade your gateway to a gateway SKU within the same SKU family (except for the Basic SKU).

For example, if you have a Standard SKU, you can upgrade to a High Performance SKU. However, you can't upgrade your VPN gateway between the old SKUs and the new SKU families.

You can upgrade a gateway for the [Resource Manager deployment model](../azure-resource-manager/management/deployment-models.md) by using the Azure portal or PowerShell. For PowerShell, use the following command:

```powershell
$gw = Get-AzVirtualNetworkGateway -Name vnetgw1 -ResourceGroupName testrg
Resize-AzVirtualNetworkGateway -VirtualNetworkGateway $gw -GatewaySku HighPerformance
```

To upgrade a gateway for the [classic deployment model](../azure-resource-manager/management/deployment-models.md), you must use the Service Management PowerShell cmdlets. Use the following command:

```powershell
Resize-AzureVirtualNetworkGateway -GatewayId <Gateway ID> -GatewaySKU HighPerformance
```

### <a name="change"></a>Change to the new gateway SKUs

Standard and High Performance SKUs will be deprecated on March 31, 2026. The product team will migrate the legacy SKUs. For more information, see the [Legacy SKU deprecation](#sku-deprecation) section. You can choose to change from a legacy SKU to one of the new SKUs at any point. If you change to a new SKU, there are more steps required and you'll incur downtime.

[!INCLUDE [Change to the new SKUs](../../includes/vpn-gateway-gwsku-change-legacy-sku-include.md)]

## SKU deprecation

The Standard and High Performance SKUs will be deprecated on March 31, 2026. Your legacy SKU will be migrated to a SKU supported by an availability zone as part of Basic IP address migration. All legacy SKUs use Basic IP today, and you can use the Azure portal to [migrate a Basic IP address to a Standard IP address](basic-public-ip-migrate-about.md) before the retirement date.

For more information, you can:

* View the [announcement](https://go.microsoft.com/fwlink/?linkid=2255127).
* See the SKU deprecation [FAQs](#sku-deprecation-faqs).

When the migration path becomes available, as part of Basic IP migration, your gateway SKU will automatically migrate to the following SKUs:

* Standard SKU becomes VpnGw1AZ
* High Performance SKU becomes VpnGw2AZ

Performance improves after this migration.

## SKU deprecation FAQs

[!INCLUDE [legacy SKU deprecation](../../includes/vpn-gateway-deprecate-sku-faq.md)]

## Related content

For more information about the new Gateway SKUs, see [Gateway SKUs](vpn-gateway-about-vpngateways.md#gwsku).

For more information about configuration settings, see [About VPN Gateway configuration settings](vpn-gateway-about-vpn-gateway-settings.md).
