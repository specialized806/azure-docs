---
title: What is Azure Bastion?
description: Azure Bastion is a fully managed service that provides secure and seamless RDP/SSH connectivity to virtual machines without exposing RDP/SSH ports externally.
author: abell
ms.author: abell
ms.service: azure-bastion
services: bastion
ms.topic: overview
ms.custom: mvc, references_regions, ignite-2024
ms.date: 01/14/2026
# Customer intent: As an administrator, I want to evaluate Azure Bastion so I can determine if I want to use it.
---

# What is Azure Bastion?

Azure Bastion is a fully managed PaaS service that provides secure and seamless RDP/SSH connectivity to your virtual machines directly over TLS from the Azure portal, or via the native SSH or RDP client already installed on your local computer. Azure Bastion is deployed directly in your virtual network and supports all VMs in the virtual network using private IP addresses. When you connect via Azure Bastion, your virtual machines don't need a public IP address, agent, or special client software.

Azure Bastion is available in four SKUs: Developer, Basic, Standard, and Premium.

> [!NOTE]
> Azure Bastion is one of the services that make up the Network Security category in Azure. Other services in this category include [Azure DDoS Protection](../ddos-protection/ddos-protection-overview.md), [Azure Firewall](../firewall/overview.md), and [Azure Web Application Firewall](../web-application-firewall/overview.md). Each service has its own unique features and use cases. For more information on this service category, see [Network Security](../networking/security/network-security.md).

## Key benefits

Azure Bastion provides the following benefits:

* **Secure connectivity over TLS**: Connect to VMs using RDP/SSH over TLS on port 443, enabling traffic to traverse firewalls securely. All sessions are encrypted and don't require public IP addresses on your VMs.
* **Protection from external threats**: Your VMs are protected from port scanning and zero-day exploits because RDP/SSH ports aren't exposed to the internet. Azure keeps Bastion hardened and up to date.
* **No bastion host management**: Azure Bastion is a fully managed platform PaaS service. You don't need to deploy, maintain, or harden a separate bastion host VM.
* **Microsoft Entra ID authentication**: Supports identity-based authentication for both portal and native client connections, eliminating the need for local authentication methods.
* **Simplified NSG management**: Configure your NSGs to allow RDP/SSH from Azure Bastion only, centralizing security at the network perimeter rather than on each VM.
* **Centralized deployment**: Deploy Bastion once in a hub virtual network and use it to connect to VMs in peered virtual networks, reducing management overhead.

## <a name="sku"></a>SKUs

Azure Bastion offers four SKU tiers to meet different requirements:

* **Developer**: Free tier using shared infrastructure, designed for development and testing. Supports one VM connection at a time and doesn't require a dedicated virtual network deployment. Available in select regions.
* **Basic**: Dedicated deployment with fixed capacity of 2 instances, supporting 40 concurrent RDP or 80 concurrent SSH sessions. Ideal for production environments with predictable, moderate connection requirements.
* **Standard**: Includes all Basic features plus advanced capabilities such as configurable host scaling (2-50 instances), native client support, shareable links, IP-based connections, custom ports, and file transfer. Supports up to 1,000 concurrent RDP or 2,000 concurrent SSH sessions at maximum scale.
* **Premium**: Includes all Standard features plus session recording for compliance and audit requirements, and private-only deployment option (no public IP address on bastion host).

For a complete feature comparison across all SKU tiers, see [Choose the right Azure Bastion SKU](bastion-sku-comparison.md).

## <a name="architecture"></a>Architecture

Azure Bastion offers multiple deployment architectures depending on the selected SKU:

**Developer**: Uses shared infrastructure managed by Azure and doesn't require deployment to your virtual network. Ideal for development and testing.

:::image type="content" source="media/quickstart-developer/bastion-shared-pool.png" alt-text="Architecture diagram illustrating Azure Bastion Developer deployment using shared infrastructure.":::

**Basic, Standard, and Premium**: Deployed to your virtual network in a dedicated subnet (AzureBastionSubnet). These SKUs support virtual network peering, allowing you to connect to VMs in peered virtual networks from a centrally deployed bastion host.

:::image type="content" source="media/bastion-overview/architecture.png" alt-text="Diagram showing Azure Bastion architecture." lightbox="media/bastion-overview/architecture.png":::

**Private-only deployment (Premium)**: Removes the public IP address requirement from the bastion host. Users connect via ExpressRoute or VPN private peering, and all traffic remains within the virtual network.

:::image type="content" source="media/private-only-deployment/private-only-architecture.png" alt-text="Diagram showing Azure Bastion private-only architecture." lightbox="media/private-only-deployment/private-only-architecture.png":::

For detailed information about each architecture and deployment model, see [Bastion design and architecture](design-architecture.md).

## Connection methods

Azure Bastion supports multiple connection methods:

* **Browser-based connections**: Connect through the Azure portal using an HTML5 web client. Available for all SKU tiers. No additional client software required.
* **Native client connections**: Connect using the SSH or RDP client already installed on your local computer. Available for Standard and Premium SKUs. Supports Microsoft Entra ID authentication and file transfer.
* **Shareable links**: Create shareable links that allow users to connect to VMs without accessing the Azure portal. Available for Standard and Premium SKUs.

For more information about connection methods and authentication options, see [About VM connections and features](vm-about.md).

## Key features

Azure Bastion includes the following key features:

* **[Virtual network peering](vnet-peering.md)**: Deploy Bastion in a hub virtual network and connect to VMs in peered virtual networks without deploying multiple bastion hosts.
* **[Host scaling](configuration-settings.md#instance)**: Configure 2-50 instances (scale units) to support thousands of concurrent sessions. Each instance supports 20 RDP and 40 SSH concurrent connections.
* **[Session recording](session-recording.md)**: Premium SKU captures all sessions for compliance and audit requirements, storing recordings in a customer-designated storage container.
* **[Kerberos authentication](kerberos-authentication-portal.md)**: Authenticate to domain-joined Windows VMs using Kerberos protocol.
* **[Availability zones](configuration-settings.md#az)**: Deploy Bastion across availability zones for high availability.
* **[Shareable links](shareable-link.md)**: Create links that allow users to connect to specific VMs without Azure portal access.
* **[IP-based connections](connect-ip-address.md)**: Connect to VMs using IP address instead of VM name, useful for migrated VMs or those without Azure VM IDs.

## Requirements

Deployment requirements vary by SKU:

* **Developer SKU**: No virtual network deployment required. Uses shared infrastructure.
* **Basic, Standard, and Premium SKUs**: Require a dedicated subnet named AzureBastionSubnet (minimum /26 prefix) and a public IP address (Standard SKU, static allocation). Private-only deployments (Premium) don't require a public IP address.

For complete configuration requirements, NSG rules, and subnet sizing guidance, see [About Bastion configuration settings](configuration-settings.md).

## What's new

Azure Bastion is continuously updated with new features and improvements. To learn about the latest updates and announcements, see [What's new in Azure Bastion?](whats-new.md).

## Troubleshooting and FAQ

For information about troubleshooting and frequently asked questions, see the [troubleshooting guide](troubleshoot.md) and [Azure Bastion FAQ](bastion-faq.md).

## Next steps

* [Quickstart: Deploy Bastion automatically with default settings and Standard SKU](quickstart-host-portal.md)
* [Quickstart: Deploy Bastion Developer](quickstart-developer.md)
* [Tutorial: Deploy Bastion using specified settings and SKUs](tutorial-create-host-portal.md)
* [Choose the right Azure Bastion SKU](bastion-sku-comparison.md)
* [About Bastion configuration settings](configuration-settings.md)
* [Azure Bastion FAQ](bastion-faq.md)
* [Learn module: Introduction to Azure Bastion](/training/modules/intro-to-azure-bastion/)
