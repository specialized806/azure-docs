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

This article explains a repeatable architecture pattern that uses a minimal [hub-spoke topology](/azure/architecture/networking/architecture/hub-spoke) to build a secure-by-default foundation for single-region web applications. A hub virtual network hosts shared services like Azure Bastion, while a spoke virtual network contains your workload—whether running on Azure App Service (PaaS) or virtual machines (IaaS). The pattern scales from a single web app to multiple workloads by adding spokes.

The pattern follows a layered approach. The hub and spoke virtual networks form the base, VNet peering connects them, and NSGs add default-deny access control at every subnet boundary. Higher-level services—Application Gateway with WAF in the spoke, Azure Bastion in the hub, and DDoS Protection across both—layer on top. Each layer depends on the one below it. The [Deployment steps](#deployment-steps) section later in this article walks through the recommended order.

This pattern is for network engineers and architects at small or midsize organizations who need to:

- Separate shared services from workloads using a hub-spoke topology that's ready to grow.
- Put an application-layer gateway with WAF in front of every web workload.
- Enforce default-deny traffic rules at the subnet level.
- Eliminate direct RDP/SSH exposure to backend VMs.
- Protect public IPs from volumetric DDoS attacks when the threat profile warrants it.
- Keep the design simple enough to deploy without specialized networking expertise.

> [!NOTE]
> This article provides an opinionated baseline, not a full landing zone guide. For production-ready, enterprise-scale implementations, see [Azure Landing Zones](/azure/cloud-adoption-framework/ready/landing-zone/).

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

The architecture uses two virtual networks connected by VNet peering:

**Hub virtual network** — Hosts shared services that are used across workloads. In this minimal pattern, the hub contains Azure Bastion for secure VM management. As the organization grows, the hub can also host Azure Firewall for centralized egress control, a VPN or ExpressRoute gateway for on-premises connectivity, or centralized DNS.

**Spoke virtual network** — Contains workload-specific resources. Internet traffic arrives at a public IP address associated with [Azure Application Gateway](/azure/application-gateway/overview), which operates as a Layer 7 reverse proxy in a dedicated spoke subnet. A WAF policy inspects every HTTP/HTTPS request against OWASP Core Rule Set rules before forwarding traffic to the backend pool. The backend pool contains either PaaS endpoints (such as App Service) or IaaS resources (VMs or Virtual Machine Scale Sets) in a dedicated workload subnet.

**VNet peering** connects the hub and spoke with low-latency, high-bandwidth connectivity over the Azure backbone. Peering is nontransitive—each spoke connects only to the hub, not to other spokes—which enforces workload isolation by default.

[Network security groups](/azure/virtual-network/network-security-groups-overview) (NSGs) enforce default-deny rules on every subnet in both virtual networks. The Application Gateway subnet allows inbound HTTPS and the required `GatewayManager` health probe ports. The workload subnet accepts traffic only from the Application Gateway subnet. When the backend includes VMs, Azure Bastion in the hub provides secure RDP/SSH access across the peering connection. When there are internet-facing public IPs, Azure DDoS Protection defends against volumetric and protocol attacks at Layers 3 and 4.

Each component in this pattern has a clear role:

| Component | VNet | Role | Required? |
|---|---|---|---|
| Hub virtual network | Hub | Hosts shared services (Bastion, optional Firewall) | Always |
| Spoke virtual network | Spoke | Hosts workload (App Gateway, backend compute) | Always |
| VNet peering | Both | Connects hub and spoke over Azure backbone | Always |
| Application Gateway WAF_v2 | Spoke | Layer 7 reverse proxy with web attack inspection | Always |
| NSGs | Both | Default-deny subnet-level traffic control | Always |
| Azure DDoS Protection | Both | Layer 3/4 volumetric attack mitigation | When public IPs face the internet |
| Azure Bastion | Hub | Secure RDP/SSH without public IPs on VMs | When backend is IaaS |
| Azure Firewall Basic | Hub | Centralized egress filtering and logging | Optional — add when you need FQDN-based outbound control |

### Why hub-spoke instead of a single VNet?

A single virtual network with all resources is simpler to set up initially, but creates problems as the organization grows:

- **CIDR collisions block peering.** If you start with a single VNet and later need to peer it with a hub, the address spaces can't overlap. Retrofitting CIDR ranges on a live workload often requires redeployment.
- **Shared services can't be reused.** Bastion, DNS, and monitoring resources deployed in a workload VNet must be duplicated for each new workload.
- **No isolation boundary.** All workloads share the same network boundary, so a compromise in one workload has a larger blast radius.

The minimal hub-spoke pattern in this article adds only one extra VNet and one peering connection. The incremental complexity is small—roughly equivalent to creating one additional NSG—but the architecture is ready to scale without rework.

## Deployment steps

This foundation is built in layers. Each layer depends on the one before it, so deploy in this order:

| Step | Layer | What you deploy | Why this order |
|---|---|---|---|
| 1 | **Resource organization** | Resource group (or separate resource groups for hub and spoke) | Establishes the RBAC and cost boundary. Everything else deploys into it. Separate resource groups let you assign different owners to hub infrastructure and workload resources. |
| 2 | **Hub network** | Hub virtual network with `AzureBastionSubnet` (/26) and optional `AzureFirewallSubnet` (/26) + `AzureFirewallManagementSubnet` (/26) | The hub is the shared services foundation. Creating it first establishes the address space that all spokes must avoid overlapping. |
| 3 | **Spoke network** | Spoke virtual network with Application Gateway subnet (/24) and workload subnet | The spoke hosts all workload-specific resources. Plan CIDR ranges that don't overlap with the hub. |
| 4 | **VNet peering** | Bidirectional peering between hub and spoke | Peering connects the two VNets so that Bastion in the hub can reach VMs in the spoke and traffic can flow between shared services and workloads. Create peering before deploying resources that depend on cross-VNet connectivity. |
| 5 | **Access control** | NSGs with default-deny rules on every subnet in both VNets | NSGs are the first security boundary. Associating them immediately after peering ensures no resource ever operates in an uncontrolled subnet—even briefly during deployment. Add the Application Gateway, Bastion, and workload NSG rules at this step so subnets are ready to receive services. |
| 6 | **DDoS protection** (conditional) | DDoS Protection plan linked to both VNets | DDoS Protection enables at the VNet level and covers every public IP in that VNet. Enabling the plan before you create public IPs for Application Gateway or Bastion means those IPs are protected from the moment they come online. Skip this step if the architecture has no public IPs. |
| 7 | **Ingress security** | Application Gateway WAF_v2 with public IP, WAF policy, and Key Vault TLS certificates (in spoke) | With the network foundation, peering, NSG rules, and DDoS protection in place, the Application Gateway can deploy into a spoke subnet that's already locked down. The WAF policy inspects traffic before it reaches any backend. |
| 8 | **Backend compute** | App Service, VMs, or Virtual Machine Scale Sets in the spoke workload subnet | Backend resources inherit the NSG rules that allow traffic only from the Application Gateway subnet. Workloads start in a secure state from the first request. |
| 9 | **Management access** (IaaS only) | Azure Bastion in the hub `AzureBastionSubnet` | Deploy Bastion in the hub after VMs exist in the spoke so operators have targets to manage. Bastion reaches spoke VMs through the peering connection. The Basic SKU or higher supports VNet peering. Skip this step for PaaS-only backends. |
| 10 | **Observability** | Diagnostic logs on Application Gateway and WAF, VNet flow logs, Log Analytics workspace | Enable monitoring after all resources are deployed so that every component feeds data to the same workspace from the start. |

> [!TIP]
> If you use infrastructure as code (Bicep, Terraform, or ARM templates), declare resources in this order so that dependency chains are explicit and deployments succeed on the first run.

## Network foundation: VNet and subnet planning

Before deploying any security service, create both virtual networks and size all subnets. Every component in this pattern requires a specific subnet, and some have strict naming and sizing requirements.

### Hub virtual network

The hub is intentionally small. It hosts shared services that are consumed across spokes.

| Subnet | Purpose | Minimum size | Naming requirement |
|---|---|---|---|
| AzureBastionSubnet | Hosts Azure Bastion (IaaS management) | /26 (59 usable IPs) | Must be named exactly `AzureBastionSubnet` |
| AzureFirewallSubnet (optional) | Hosts Azure Firewall for centralized egress control | /26 (59 usable IPs) | Must be named exactly `AzureFirewallSubnet` |
| AzureFirewallManagementSubnet (required for Basic SKU) | Separates management traffic from customer traffic on Azure Firewall Basic | /26 (59 usable IPs) | Must be named exactly `AzureFirewallManagementSubnet` |

### Spoke virtual network

The spoke contains workload-specific resources. Each new workload gets its own spoke.

| Subnet | Purpose | Minimum size | Naming requirement |
|---|---|---|---|
| Application Gateway subnet | Hosts Application Gateway WAF_v2 instances | /24 (251 usable IPs) | No naming requirement, but must be dedicated to Application Gateway |
| Workload subnet | Hosts App Service VNet integration or backend VMs | Size based on workload | None |

### CIDR planning for hub-spoke

**Plan CIDR ranges for both VNets before the first deployment.** Address spaces must not overlap—VNet peering fails if any CIDR ranges collide. A common approach for minimal hub-spoke:

| VNet | Example CIDR | Notes |
|---|---|---|
| Hub | 10.0.0.0/24 | Small address space is sufficient for Bastion + optional Firewall |
| Spoke (workload 1) | 10.1.0.0/16 | Larger space for Application Gateway /24 + workload subnets |
| Spoke (workload 2, future) | 10.2.0.0/16 | Reserve ranges now even if you only have one spoke today |

> [!TIP]
> Reserve address ranges for future spokes from day one. Adding a spoke later is straightforward, but changing address spaces after peering or gateway deployment is disruptive.

### VNet peering

[Virtual network peering](/azure/virtual-network/virtual-network-peering-overview) connects the hub and spoke with low-latency connectivity over the Azure backbone. Configure peering as bidirectional so that traffic flows in both directions:

- **Hub → Spoke:** Enables Bastion to reach VMs and (when present) Azure Firewall to inspect spoke traffic.
- **Spoke → Hub:** Enables workloads to use shared hub services.

Key peering settings:

| Setting | Value | Why |
|---|---|---|
| Allow forwarded traffic | Enabled on both sides | Required when Azure Firewall or an NVA inspects traffic |
| Allow gateway transit | Enabled on hub (if hub has a VPN/ExpressRoute gateway) | Lets spokes use the hub's gateway for on-premises connectivity |
| Use remote gateways | Enabled on spoke (if hub has a gateway) | Spoke uses the hub's gateway instead of deploying its own |

> [!NOTE]
> VNet peering is nontransitive. If you add a second spoke, it must be peered directly to the hub. Spoke-to-spoke traffic must route through the hub (via Azure Firewall or an NVA with UDRs) or use [Azure Virtual Network Manager](/azure/virtual-network-manager/overview) for direct connectivity.

## Network segmentation with NSGs

> [!NOTE]
> **Deployment step 5.** Create NSGs and associate them with subnets immediately after creating the virtual networks and peering. See [Deployment steps](#deployment-steps).

Both the hub and spoke virtual networks use NSGs to enforce default-deny rules at every subnet boundary. Separate subnets for each role—Application Gateway, workload, Bastion, and optional Firewall—allow NSGs to control traffic precisely.

### Essentials when deploying

1. **Associate an NSG with every subnet in both VNets.** Start with a deny-all inbound rule. Add explicit allow rules only for traffic the design requires.
1. **Application Gateway subnet rules (spoke):** Allow inbound HTTPS (443) from the internet. Allow inbound on ports 65200-65535 from the `GatewayManager` [service tag](/azure/application-gateway/configuration-infrastructure#network-security-groups) (required for v2 health probes). Allow the `AzureLoadBalancer` service tag.
1. **Workload subnet rules (spoke):** Allow inbound only from the Application Gateway subnet on the application port. Deny all other inbound traffic.
1. **Bastion subnet rules (hub):** Follow the [Bastion NSG requirements](/azure/bastion/configuration-settings#nsg) exactly. Bastion has specific inbound and outbound rules that must be applied for connectivity to work across peered VNets.
1. **Restrict egress.** Use NSG outbound rules to deny unwanted outbound traffic. For most regional web apps, limiting egress to known Azure service destinations is sufficient. If you need FQDN-based filtering, add [Azure Firewall](/azure/firewall/overview) in the hub virtual network (see [Centralized egress with Azure Firewall](#centralized-egress-with-azure-firewall-optional)).
1. **Enable flow logs.** [Virtual network flow logs](/azure/network-watcher/vnet-flow-logs-overview) capture traffic patterns for security analysis and troubleshooting. If you still use NSG flow logs, [migrate to VNet flow logs](/azure/network-watcher/nsg-flow-logs-migrate) before the NSG flow logs retirement on September 30, 2027.

## DDoS Protection: Do you need it?

> [!NOTE]
> **Deployment step 6.** Enable DDoS Protection on both virtual networks before creating public IPs for Application Gateway or Bastion. See [Deployment steps](#deployment-steps).

All Azure services with public IPv4 and IPv6 addresses receive [Azure DDoS infrastructure protection](/azure/ddos-protection/ddos-protection-overview) at no extra cost. However, infrastructure protection defends the Azure platform as a whole—it doesn't adaptively tune to your specific traffic patterns or protect individual customer resources. For workloads that accept traffic from the public internet, enable a DDoS Protection plan (Network Protection or IP Protection) to get resource-level adaptive tuning, attack diagnostics, rapid response support, and cost protection guarantees.

The decision is straightforward:

- **Public IP facing the internet → Enable DDoS Protection.** Choose the tier based on how many public IPs you protect. Don't rely on infrastructure protection alone for customer-facing workloads.
- **Private only (no public IP), or behind Azure Front Door → A DDoS Protection plan is optional.** Front Door includes its own integrated DDoS protection. Private-only resources have no public endpoint to attack, but infrastructure protection alone doesn't provide resource-level guarantees.

| Tier | Best for | Key extras over infrastructure protection | Pricing model |
|---|---|---|---|
| DDoS Network Protection | 15+ public IPs, need rapid response or WAF discounts | Adaptive tuning, DDoS Rapid Response, cost protection, [WAF discount](/azure/ddos-protection/ddos-protection-sku-comparison) | Fixed monthly per plan (up to 100 IPs) |
| DDoS IP Protection | Fewer than 15 public IPs | Adaptive tuning, attack diagnostics | Per public IP |

In a hub-spoke topology, link the DDoS Protection plan to both the hub and spoke VNets so that public IPs in either network are covered.

> [!IMPORTANT]
> Azure DDoS infrastructure protection and Azure DDoS Protection are separate services. Infrastructure protection defends the Azure platform and doesn't provide adaptive tuning, diagnostics, or response support for your individual resources. Don't treat it as a substitute for a DDoS Protection plan on internet-facing workloads.

For more information, see [Azure DDoS Protection tier comparison](/azure/ddos-protection/ddos-protection-sku-comparison).

## Application Gateway with WAF

> [!NOTE]
> **Deployment step 7.** Deploy Application Gateway in the spoke virtual network after peering, NSG rules, and DDoS protection are in place. See [Deployment steps](#deployment-steps).

Application Gateway is a regional Layer 7 load balancer purpose-built for web traffic. The [WAF_v2 SKU](/azure/web-application-firewall/ag/ag-overview) provides OWASP CRS-based protection against SQL injection, cross-site scripting, and other common web exploits. It supports autoscaling, zone redundancy, and a static VIP.

Application Gateway deploys into its dedicated subnet in the spoke virtual network—close to the workload it protects. This placement keeps ingress traffic in the spoke and avoids routing internet traffic through the hub unnecessarily.

**When to choose something else:** If you need global load balancing across multiple Azure regions, use [Azure Front Door with WAF](/azure/frontdoor/web-application-firewall) instead. If traffic isn't HTTP/HTTPS (for example, raw TCP or UDP), use [Azure Load Balancer](/azure/load-balancer/load-balancer-overview) at Layer 4.

### Essentials when deploying

1. **Use WAF policies, not legacy WAF configuration.** You can't create new WAF configuration deployments on WAF v2 starting March 15, 2025. [Migrate existing configurations to WAF policies before March 15, 2027](/azure/web-application-firewall/ag/upgrade-ag-waf-policy). WAF policies provide per-site and per-URI rule granularity, bot protection, and the next-generation WAF engine.
1. **Start in Detection mode, switch to Prevention before production.** Detection mode logs threats without blocking them, giving you time to tune rules and identify false positives. Use Prevention mode for all production workloads.
1. **Size the subnet to /24.** Application Gateway v2 supports up to 125 instances and requires a [dedicated subnet](/azure/application-gateway/configuration-infrastructure#size-of-the-subnet). A /24 provides 251 usable addresses for autoscaling and maintenance upgrades.
1. **Store TLS certificates in Azure Key Vault.** Use [Key Vault integration](/azure/application-gateway/key-vault-certs) with managed identities for automated certificate rotation. This approach eliminates manual certificate management and prevents outages from expired certificates.
1. **Enable diagnostic logging from day one.** Send access logs, firewall logs, and performance metrics to a [Log Analytics workspace](/azure/application-gateway/application-gateway-diagnostics). Without logs, you can't investigate security incidents or tune WAF rules.

> [!IMPORTANT]
> Application Gateway v1 SKU [retires April 28, 2026](/azure/application-gateway/v1-retirement). Deploy all new workloads on v2.

For security hardening guidance, see [Secure your Azure Application Gateway](/azure/application-gateway/secure-application-gateway). For sizing and performance recommendations, see [Architecture best practices for Application Gateway v2](/azure/well-architected/service-guides/azure-application-gateway).

## Azure Bastion in the hub: PaaS versus IaaS decision

> [!NOTE]
> **Deployment step 9 (IaaS only).** Deploy Bastion in the hub virtual network after backend VMs are in place in the spoke. See [Deployment steps](#deployment-steps).

Whether you need Azure Bastion depends entirely on your backend compute model:

| Backend type | Bastion needed? | Why |
|---|---|---|
| **PaaS** (App Service, Container Apps, AKS) | No | No OS-level access to expose. Manage through the portal, CLI, or CI/CD. |
| **IaaS** (VMs, Virtual Machine Scale Sets) | Yes | Eliminates public IPs on VMs and removes RDP/SSH exposure to the internet. |

### Why Bastion lives in the hub

Placing Bastion in the hub virtual network means operators deploy it once and use it to manage VMs across all peered spokes. If Bastion were in each spoke, every new workload would need its own Bastion instance—adding cost and management overhead.

The Basic SKU and higher support [virtual network peering](/azure/bastion/bastion-overview), so Bastion in the hub can connect to VMs in any peered spoke.

### Essentials when deploying

1. **Deploy Bastion in a dedicated `AzureBastionSubnet` of /26 or larger.** Azure requires this exact subnet name and it can't be shared with other resources.
1. **Use the Basic SKU at minimum for production.** The Basic SKU provides dedicated instances and supports virtual network peering. The Developer SKU uses shared infrastructure and [isn't suitable for production](/azure/bastion/bastion-overview).
1. **Follow the Bastion NSG requirements.** The Bastion subnet has [specific inbound and outbound rules](/azure/bastion/configuration-settings#nsg) that you must apply exactly. Missing rules cause connection failures. When Bastion is in the hub, ensure the spoke workload subnet NSG allows inbound RDP (3389) or SSH (22) from the hub VNet's address space.
1. **Enable Microsoft Entra ID authentication for SSH/RDP** when using the Standard or Premium SKU with the native client. This approach eliminates distributing SSH keys or local passwords.

## Centralized egress with Azure Firewall (optional)

For organizations that need FQDN-based outbound filtering, TLS inspection, or centralized logging of all egress traffic, add [Azure Firewall](/azure/firewall/overview) to the hub virtual network. Azure Firewall is optional in this pattern—NSGs provide basic egress control, and many startups operate successfully without it.

### When to add Azure Firewall

| Scenario | Without Azure Firewall | With Azure Firewall |
|---|---|---|
| Outbound traffic control | NSG rules filter by IP/port only | FQDN-based rules (e.g., allow `*.microsoft.com`) |
| Compliance requirements | Limited egress logging | Full egress logging with threat intelligence |
| Spoke-to-spoke traffic | Not applicable (single spoke) | Centralized inspection through the hub |

### If you choose to add it

1. **Use the Basic SKU for SMBs.** Azure Firewall Basic supports up to 250 Mbps throughput and costs less than Standard or Premium SKUs. It's designed for small and midsize environments. For help choosing a SKU, see [Choose the right Azure Firewall SKU](/azure/firewall/choose-firewall-sku).
1. **Deploy in `AzureFirewallSubnet` (/26) in the hub.** Azure Firewall Basic also requires a dedicated `AzureFirewallManagementSubnet` (/26) to separate management traffic from customer traffic. Create both subnets before deploying the firewall.
1. **Create UDRs on spoke subnets** with a default route (`0.0.0.0/0`) pointing to the firewall's private IP. This forces all outbound traffic through the hub for inspection.
1. **Start simple.** Begin with a small set of application and network rules. Add rules as you understand your workload's traffic patterns.

> [!TIP]
> If you don't need Azure Firewall today, design your hub VNet with a reserved `AzureFirewallSubnet` anyway. Adding Firewall later is straightforward when the subnet already exists, but adding a subnet to a hub that's already peered requires no downtime—just add the subnet and deploy.

## Identity and access control

Use [Microsoft Entra ID](/entra/fundamentals/whatis) for role-based access control (RBAC) across all networking resources:

- Assign [built-in roles](/azure/role-based-access-control/built-in-roles) like **Network Contributor** instead of custom roles where possible.
- Require at least `Microsoft.Network/virtualNetworks/subnets/join/action` and `subnets/read` for users and service principals operating Application Gateway.
- Use [managed identities](/entra/identity/managed-identities-azure-resources/overview) for Application Gateway to access Key Vault—don't store credentials.

## Mistakes to avoid

| Anti-pattern | Why it's dangerous | Fix |
|---|---|---|
| Starting with a single VNet and planning to "add hub-spoke later" | CIDR collisions, UDR retrofitting, and Bastion relocation make migration disruptive | Start with hub-spoke from day one—it's one extra VNet and one peering connection |
| Exposing RDP/SSH ports to the internet | Persistent attack surface for brute-force and credential-stuffing attacks | Use Azure Bastion in the hub. Remove all public IPs from backend VMs. |
| Relying on NSGs alone for web app security | NSGs operate at Layers 3 and 4 and can't inspect HTTP request bodies. SQL injection and XSS pass through undetected. | Always place a WAF in front of web-facing endpoints. |
| Using WAF Detection mode in production | Threats are logged but not blocked—applications remain vulnerable. | Switch to Prevention mode before going to production. |
| Blocking `GatewayManager` ports in App Gateway NSG | Breaks v2 health probes. Backend health shows unknown and clients get 502 errors. | Always allow ports 65200-65535 from `GatewayManager`. |
| Sharing the Application Gateway subnet | Causes deployment failures and unpredictable behavior. | Keep the Application Gateway subnet [dedicated](/azure/application-gateway/configuration-infrastructure#virtual-network-and-dedicated-subnet). |
| Deploying without infrastructure as code | Manual configurations drift and are impossible to audit or reproduce. | Use Bicep, Terraform, or ARM templates for all production deployments. |
| Enabling DDoS Network Protection for private-only workloads | Adds fixed monthly cost with no benefit when no public IPs are exposed. | Evaluate whether your architecture exposes public IPs before purchasing. |
| Deploying resources before NSGs are in place | Resources operate briefly in an uncontrolled subnet, creating a window of exposure. | Always associate NSGs with subnets before deploying any resources into them. |
| Deploying Bastion in every spoke | Adds unnecessary cost and management overhead when the hub can serve all spokes | Deploy Bastion once in the hub. Use VNet peering to reach spoke VMs. |
| Not planning CIDR ranges for future spokes | New spokes can't peer if their address space overlaps with existing VNets | Reserve nonoverlapping address ranges for future spokes before deploying the first spoke. |

## When things go wrong

### 502 Bad Gateway from Application Gateway

**Check first:** Verify the Application Gateway subnet NSG allows ports 65200-65535 from `GatewayManager`. Confirm backend health probe settings match the application's listening port and path, and that the backend returns HTTP 200-399 on the probe endpoint.

**Common causes:** Blocked `GatewayManager` health probes, misconfigured custom health probes, backend app crashes, or [TLS certificate mismatch](/troubleshoot/azure/application-gateway/application-gateway-troubleshooting-502) when end-to-end TLS is enabled.

### WAF blocks legitimate traffic (false positives)

**Check first:** Enable WAF diagnostic logs and filter by blocked actions. Identify the rule ID (for example, `942130` for SQL injection detection) and determine whether the match is on safe content like authentication tokens.

**Fix:** Use [WAF exclusion lists](/azure/web-application-firewall/ag/application-gateway-waf-configuration) to omit specific request attributes, or use per-rule exclusions available in WAF policies.

### Can't connect to VMs through Bastion

**Check first:** Verify the `AzureBastionSubnet` is /26 or larger. Check that the NSG on the Bastion subnet in the hub has the [required rules](/azure/bastion/configuration-settings#nsg). Confirm the target VM's NSG in the spoke allows inbound RDP (3389) or SSH (22) from the hub VNet's address space.

**Common causes:** Missing or incorrect NSG rules on the Bastion subnet, Bastion SKU doesn't support peering (Developer SKU), subnet too small, or the target VM's OS-level firewall blocking connections.

### Peering shows "Disconnected" status

**Check first:** Verify that both sides of the peering exist (hub-to-spoke and spoke-to-hub). Peering must be created in both directions. If one side is deleted, the other shows "Disconnected."

**Fix:** Delete the remaining peering and recreate both sides. Ensure CIDR address spaces don't overlap.

## Related content

- [Apply Zero Trust principles to a hub virtual network in Azure](/security/zero-trust/azure-infrastructure-networking)
- [Apply Zero Trust principles to a spoke virtual network with Azure PaaS Services](/security/zero-trust/azure-infrastructure-paas)
