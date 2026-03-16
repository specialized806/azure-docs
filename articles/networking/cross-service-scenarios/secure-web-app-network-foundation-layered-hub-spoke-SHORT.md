---
title: Secure network foundation for regional web applications in Azure
description: Learn how to build a secure-by-default network foundation for regional web applications using a minimal hub-spoke topology with Application Gateway, WAF, DDoS Protection, Bastion, NSGs, and VNet peering.
author: mbender-ms
ms.author: mbender
ms.service: azure-networking
ms.topic: concept-article
ms.date: 03/16/2026

#CustomerIntent: As a network engineer or architect at a small or midsize organization, I want to understand secure network design patterns for regional web applications using a hub-spoke topology so that I can build a secure-by-default network foundation in Azure that scales as my organization grows.
---

# Secure network foundation for regional web applications in Azure

When you host a web application in Azure, the network design you choose determines how much of your infrastructure is exposed to attack. Without an intentional design, teams commonly leave default configurations in place, expose management ports to the internet, or skip application-layer inspection—all of which increase the attack surface.

This article explains a repeatable architecture pattern that uses a minimal [hub-spoke topology](/azure/architecture/networking/architecture/hub-spoke) to build a secure-by-default foundation for single-region web applications. A hub virtual network hosts shared services like Azure Bastion, while a spoke virtual network contains your workload. The pattern scales from a single web app to multiple workloads by adding spokes. Each layer depends on the one below it—the [Deployment steps](#deployment-steps) section walks through the recommended order.

This pattern is for network engineers and architects at small or midsize organizations who need to:

- Separate shared services from workloads using a hub-spoke topology that's ready to grow.
- Put an application-layer gateway with WAF in front of every web workload.
- Enforce default-deny traffic rules at the subnet level.
- Eliminate direct RDP/SSH exposure to backend VMs.
- Keep the design simple enough to deploy without specialized networking expertise.

> [!NOTE]
> This article provides an opinionated baseline, not a full landing zone guide. For enterprise-scale implementations, see [Azure Landing Zones](/azure/cloud-adoption-framework/ready/landing-zone/).

## Architecture

<!-- TODO: Replace placeholder with hub-spoke architecture diagram showing:
     - Hub VNet with AzureBastionSubnet (and optional AzureFirewallSubnet)
     - Spoke VNet with Application Gateway subnet and workload subnet
     - VNet peering connection between hub and spoke
     - NSGs on every subnet
     - Internet traffic flowing through App Gateway WAF in spoke
     - Bastion in hub reaching VMs in spoke via peering
     - DDoS Protection covering both VNets -->
:::image type="content" source="media/secure-azure-network-architecture-cross-service-scenarios-m365-copilot-v1/image1.jpg" alt-text="Architecture diagram showing a hub-spoke topology: a hub virtual network with Azure Bastion peered to a spoke virtual network containing Application Gateway with WAF and a backend workload subnet. NSGs control traffic flow at every subnet boundary.":::

The architecture uses two virtual networks connected by [VNet peering](/azure/virtual-network/virtual-network-peering-overview):

- **Hub virtual network** — Hosts shared services consumed across workloads: Azure Bastion for secure VM management, and optionally Azure Firewall for centralized egress control or a VPN/ExpressRoute gateway for on-premises connectivity.
- **Spoke virtual network** — Contains workload-specific resources. [Application Gateway](/azure/application-gateway/overview) with WAF operates as a Layer 7 reverse proxy in a dedicated spoke subnet. The backend pool holds either PaaS endpoints (App Service) or IaaS resources (VMs) in a workload subnet.

[Network security groups](/azure/virtual-network/network-security-groups-overview) (NSGs) enforce default-deny rules on every subnet in both VNets. When there are internet-facing public IPs, Azure DDoS Protection defends against volumetric attacks at Layers 3 and 4.

| Component | VNet | Role | Required? |
|---|---|---|---|
| Hub virtual network | Hub | Hosts shared services (Bastion, optional Firewall) | Always |
| Spoke virtual network | Spoke | Hosts workload (App Gateway, backend compute) | Always |
| VNet peering | Both | Connects hub and spoke over Azure backbone | Always |
| Application Gateway WAF_v2 | Spoke | Layer 7 reverse proxy with web attack inspection | Always |
| NSGs | Both | Default-deny subnet-level traffic control | Always |
| Azure DDoS Protection | Both | Layer 3/4 volumetric attack mitigation | When public IPs face the internet |
| Azure Bastion | Hub | Secure RDP/SSH without public IPs on VMs | When backend is IaaS |
| Azure Firewall Basic | Hub | Centralized egress filtering and logging | Optional |

### Why hub-spoke instead of a single VNet?

A single VNet is simpler initially, but creates problems as the organization grows:

- **CIDR collisions block peering.** Retrofitting address ranges on a live workload often requires redeployment.
- **Shared services can't be reused.** Bastion, DNS, and monitoring must be duplicated for each new workload.
- **No isolation boundary.** A compromise in one workload has a larger blast radius.

The minimal hub-spoke pattern adds only one extra VNet and one peering connection—the architecture is ready to scale without rework.

## Deployment steps

This foundation is built in layers. Each layer depends on the one before it, so deploy in this order:

| Step | Layer | What you deploy | Why this order |
|---|---|---|---|
| 1 | **Resource organization** | Resource group (or separate groups for hub and spoke) | Establishes the RBAC and cost boundary. Separate resource groups let you assign different owners to hub and workload resources. |
| 2 | **Hub network** | Hub VNet with `AzureBastionSubnet` (/26) and optional `AzureFirewallSubnet` (/26) + `AzureFirewallManagementSubnet` (/26) | Creates the shared services foundation. Establishes the address space that all spokes must avoid overlapping. |
| 3 | **Spoke network** | Spoke VNet with Application Gateway subnet (/24) and workload subnet | Hosts all workload-specific resources. Plan CIDR ranges that don't overlap with the hub. |
| 4 | **VNet peering** | Bidirectional peering between hub and spoke | Connects the two VNets so Bastion in the hub can reach VMs in the spoke. Create peering before deploying resources that depend on cross-VNet connectivity. |
| 5 | **Access control** | NSGs with default-deny rules on every subnet in both VNets | Ensures no resource ever operates in an uncontrolled subnet—even briefly during deployment. |
| 6 | **DDoS protection** (conditional) | DDoS Protection plan linked to both VNets | Covers every public IP from the moment it comes online. Skip if the architecture has no public IPs. |
| 7 | **Ingress security** | Application Gateway WAF_v2 with public IP, WAF policy, and Key Vault TLS certificates (in spoke) | Deploys into a spoke subnet that's already locked down. The WAF policy inspects traffic before it reaches any backend. |
| 8 | **Backend compute** | App Service, VMs, or Virtual Machine Scale Sets in the spoke workload subnet | Workloads inherit the NSG rules that allow traffic only from the Application Gateway subnet. |
| 9 | **Management access** (IaaS only) | Azure Bastion in the hub `AzureBastionSubnet` | Bastion reaches spoke VMs through the peering connection. Skip for PaaS-only backends. |
| 10 | **Observability** | Diagnostic logs, VNet flow logs, Log Analytics workspace | Ensures every component feeds data to the same workspace from the start. |

> [!TIP]
> If you use infrastructure as code (Bicep, Terraform, or ARM templates), declare resources in this order so that dependency chains are explicit and deployments succeed on the first run.

## CIDR planning for hub-spoke

**Plan CIDR ranges for both VNets before the first deployment.** Address spaces must not overlap—VNet peering fails if any CIDR ranges collide.

| VNet | Example CIDR | Notes |
|---|---|---|
| Hub | 10.0.0.0/24 | Small address space is sufficient for Bastion + optional Firewall |
| Spoke (workload 1) | 10.1.0.0/16 | Larger space for Application Gateway /24 + workload subnets |
| Spoke (workload 2, future) | 10.2.0.0/16 | Reserve ranges now even if you only have one spoke today |

> [!TIP]
> Reserve address ranges for future spokes from day one. Adding a spoke later is straightforward, but changing address spaces after peering or gateway deployment is disruptive. For detailed planning guidance, see [Plan virtual networks](/azure/virtual-network/virtual-network-vnet-plan-design-arm).

## NSG essentials

Associate an NSG with every subnet in both VNets. Start with a deny-all inbound rule and add explicit allow rules only for traffic the design requires.

- **Application Gateway subnet (spoke):** Allow inbound HTTPS (443) from the internet. Allow ports 65200-65535 from `GatewayManager` ([required for v2 health probes](/azure/application-gateway/configuration-infrastructure#network-security-groups)). Allow the `AzureLoadBalancer` service tag.
- **Workload subnet (spoke):** Allow inbound only from the Application Gateway subnet on the application port. Deny all other inbound traffic.
- **Bastion subnet (hub):** Follow the [Bastion NSG requirements](/azure/bastion/configuration-settings#nsg) exactly—missing rules cause connection failures across peered VNets. Ensure the spoke workload subnet NSG allows inbound RDP (3389) or SSH (22) from the hub VNet's address space.
- **Restrict egress:** Use NSG outbound rules to deny unwanted outbound traffic. If you need FQDN-based filtering, add [Azure Firewall](/azure/firewall/overview) in the hub.
- **Enable flow logs:** [Virtual network flow logs](/azure/network-watcher/vnet-flow-logs-overview) capture traffic patterns for security analysis. If you still use NSG flow logs, [migrate to VNet flow logs](/azure/network-watcher/nsg-flow-logs-migrate) before the retirement on September 30, 2027.

## DDoS Protection: Do you need it?

All Azure public IPs get [DDoS infrastructure protection](/azure/ddos-protection/ddos-protection-overview) at no extra cost. The decision for a paid tier is straightforward:

- **Public IP facing the internet → Enable DDoS Protection.**
- **Private only, or behind Azure Front Door → Infrastructure protection is sufficient.**

| Tier | Best for | Pricing model |
|---|---|---|
| DDoS Network Protection | 15+ public IPs, need rapid response or WAF discounts | Fixed monthly per plan (up to 100 IPs) |
| DDoS IP Protection | Fewer than 15 public IPs | Per public IP |

In a hub-spoke topology, link the DDoS Protection plan to both VNets. For more information, see [Azure DDoS Protection tier comparison](/azure/ddos-protection/ddos-protection-sku-comparison).

## Application Gateway with WAF

Application Gateway deploys into a dedicated subnet in the spoke VNet—close to the workload it protects. The [WAF_v2 SKU](/azure/web-application-firewall/ag/ag-overview) provides OWASP CRS-based protection against SQL injection, cross-site scripting, and other common web exploits.

**Essentials:**

1. **Use WAF policies, not legacy WAF configuration.** [Migrate before March 15, 2027](/azure/web-application-firewall/ag/upgrade-ag-waf-policy).
1. **Start in Detection mode, switch to Prevention before production.**
1. **Size the subnet to /24.** Application Gateway v2 requires a [dedicated subnet](/azure/application-gateway/configuration-infrastructure#size-of-the-subnet).
1. **Store TLS certificates in Azure Key Vault** with [managed identities](/azure/application-gateway/key-vault-certs) for automated rotation.
1. **Enable diagnostic logging from day one.** Send logs to a [Log Analytics workspace](/azure/application-gateway/application-gateway-diagnostics).

> [!IMPORTANT]
> Application Gateway v1 SKU [retires April 28, 2026](/azure/application-gateway/v1-retirement). Deploy all new workloads on v2.

**When to choose something else:** For global multi-region load balancing, use [Azure Front Door with WAF](/azure/frontdoor/web-application-firewall). For non-HTTP traffic, use [Azure Load Balancer](/azure/load-balancer/load-balancer-overview). For full security hardening guidance, see [Secure your Azure Application Gateway](/azure/application-gateway/secure-application-gateway).

## Azure Bastion: PaaS versus IaaS decision

Whether you need Azure Bastion depends on your backend compute model:

| Backend type | Bastion needed? | Why |
|---|---|---|
| **PaaS** (App Service, Container Apps, AKS) | No | No OS-level access to expose. |
| **IaaS** (VMs, Virtual Machine Scale Sets) | Yes | Eliminates public IPs on VMs and removes RDP/SSH exposure. |

Bastion lives in the hub so operators deploy it once and use it to manage VMs across all peered spokes. The Basic SKU and higher support [VNet peering](/azure/bastion/bastion-overview). Deploy in a dedicated `AzureBastionSubnet` of /26 or larger, and follow the [Bastion NSG requirements](/azure/bastion/configuration-settings#nsg) exactly.

## Centralized egress with Azure Firewall (optional)

Azure Firewall is optional in this pattern—NSGs provide basic egress control, and many startups operate successfully without it. Add it when you need FQDN-based outbound filtering, TLS inspection, or centralized egress logging.

| Scenario | Without Azure Firewall | With Azure Firewall |
|---|---|---|
| Outbound traffic control | NSG rules filter by IP/port only | FQDN-based rules |
| Compliance requirements | Limited egress logging | Full egress logging with threat intelligence |
| Spoke-to-spoke traffic | Not applicable (single spoke) | Centralized inspection through the hub |

**If you add it:** Use the [Basic SKU for SMBs](/azure/firewall/choose-firewall-sku) (~250 Mbps, lower cost). Deploy in `AzureFirewallSubnet` (/26) and `AzureFirewallManagementSubnet` (/26) in the hub. Create UDRs on spoke subnets with a default route to the firewall's private IP.

> [!TIP]
> Design your hub VNet with a reserved `AzureFirewallSubnet` even if you don't need Firewall today. Adding it later is straightforward when the subnet already exists.

## Mistakes to avoid

| Anti-pattern | Why it's dangerous | Fix |
|---|---|---|
| Starting with a single VNet and planning to "add hub-spoke later" | CIDR collisions, UDR retrofitting, and Bastion relocation make migration disruptive | Start with hub-spoke from day one—it's one extra VNet and one peering connection |
| Exposing RDP/SSH ports to the internet | Persistent attack surface for brute-force and credential-stuffing attacks | Use Azure Bastion in the hub. Remove all public IPs from backend VMs. |
| Relying on NSGs alone for web app security | NSGs can't inspect HTTP request bodies. SQL injection and XSS pass through undetected. | Always place a WAF in front of web-facing endpoints. |
| Using WAF Detection mode in production | Threats are logged but not blocked—applications remain vulnerable. | Switch to Prevention mode before going to production. |
| Blocking `GatewayManager` ports in App Gateway NSG | Breaks v2 health probes. Backend health shows unknown and clients get 502 errors. | Always allow ports 65200-65535 from `GatewayManager`. |
| Sharing the Application Gateway subnet | Causes deployment failures and unpredictable behavior. | Keep the Application Gateway subnet [dedicated](/azure/application-gateway/configuration-infrastructure#virtual-network-and-dedicated-subnet). |
| Deploying without infrastructure as code | Manual configurations drift and are impossible to audit or reproduce. | Use Bicep, Terraform, or ARM templates for all production deployments. |
| Enabling DDoS Network Protection for private-only workloads | Adds fixed monthly cost with no benefit when no public IPs are exposed. | Evaluate whether your architecture exposes public IPs before purchasing. |
| Deploying resources before NSGs are in place | Creates a window of exposure during deployment. | Always associate NSGs with subnets before deploying any resources into them. |
| Deploying Bastion in every spoke | Adds unnecessary cost and management overhead. | Deploy Bastion once in the hub. Use VNet peering to reach spoke VMs. |
| Not planning CIDR ranges for future spokes | New spokes can't peer if address spaces overlap. | Reserve nonoverlapping address ranges before deploying the first spoke. |

## When things go wrong

### 502 Bad Gateway from Application Gateway

**Check first:** Verify the Application Gateway subnet NSG allows ports 65200-65535 from `GatewayManager`. Confirm backend health probe settings match the application's listening port and path, and that the backend returns HTTP 200-399 on the probe endpoint. See [Troubleshoot 502 errors](/troubleshoot/azure/application-gateway/application-gateway-troubleshooting-502).

### WAF blocks legitimate traffic (false positives)

**Check first:** Enable WAF diagnostic logs and filter by blocked actions. Identify the rule ID and determine whether the match is on safe content. **Fix:** Use [WAF exclusion lists](/azure/web-application-firewall/ag/application-gateway-waf-configuration) or per-rule exclusions in WAF policies.

### Can't connect to VMs through Bastion

**Check first:** Verify `AzureBastionSubnet` is /26 or larger, the hub Bastion subnet NSG has the [required rules](/azure/bastion/configuration-settings#nsg), and the spoke workload subnet NSG allows inbound RDP (3389) or SSH (22) from the hub VNet's address space. **Common causes:** Missing NSG rules, Developer SKU (doesn't support peering), or OS-level firewall blocking connections.

### Peering shows "Disconnected" status

**Check first:** Verify both sides of the peering exist (hub-to-spoke and spoke-to-hub). If one side is deleted, the other shows "Disconnected." **Fix:** Delete the remaining peering and recreate both sides. Ensure CIDR address spaces don't overlap.

## Deploy this scenario

<!-- TODO: Add links when templates are published -->
<!-- - [Bicep template](link-to-bicep-template) -->
<!-- - [Terraform module](link-to-terraform-module) -->

A Bicep template and Terraform module for this architecture are in development.

## Related content

- [Hub-spoke network topology in Azure](/azure/architecture/networking/architecture/hub-spoke)
- [Apply Zero Trust principles to a hub virtual network in Azure](/security/zero-trust/azure-infrastructure-networking)
- [Apply Zero Trust principles to a spoke virtual network with Azure PaaS Services](/security/zero-trust/azure-infrastructure-paas)
- [Secure your Azure Application Gateway](/azure/application-gateway/secure-application-gateway)
- [Choose a secure network topology](../secure-network-topology.md)
