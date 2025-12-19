---
title: High Availability Implementation Guide
titleSuffix: Azure Front Door
description: Learn how to implement manual failover for Azure Front Door using Azure Traffic Manager, ensuring high availability during rare service interruptions.
author: halkazwini
ms.author: halkazwini
ms.service: azure-frontdoor
ms.topic: concept-article
ms.date: 12/19/2025

#customer intent: As a cloud architect, I want to implement a manual failover strategy for Azure Front Door using Azure Traffic Manager so that I can ensure high availability during service interruptions.
---

# Azure Front Door high availability implementation guide

Azure Front Door is designed to provide exceptional resiliency and availability for both external customers and Microsoft's internal properties. While Front Door's architecture meets or exceeds the needs of most production workloads, it's important to acknowledge that no distributed system is immune to failure.

This article provides high‑level, step‑by‑step instructions for implementing Azure Traffic Manager to enable manual failover from Front Door to either an alternate CDN or Application Gateway WAF during rare Front Door service interruptions. It supplements the guidance in [Global routing redundancy for mission-critical web applications](/azure/architecture/guide/networking/global-web-applications/overview?tabs=cli).

Multiple strategies exist within the industry for achieving high availability (HA) in CDN and web application architectures. The approach outlined in this article focuses on a straightforward, manual **“break‑glass” failover pattern** that allows customers to quickly redirect traffic during an outage and seamlessly restore routing back to Front Door once service health is confirmed.

The article also includes guidance for implementing HA patterns in production environments, establishing health monitoring, and creating operational runbooks to support ongoing readiness.

## Key operational differences:

This guide presents two proven architectures using Azure Traffic Manager to provide automated failover. The following table summarizes key operational differences to consider:

| Aspect | Section 1 (Front Door + Other CDN) | Section 2 (Front Door + Application Gateway) |
|----|----|----|
| Failover target | Single Other CDN endpoint | Secondary Traffic Manager → Multiple Application Gateway instances |
| Caching during failover | Yes | No (Application Gateway doesn't cache) |
| Geographic distribution | Other CDN's global edge network | Specific Azure regions (2 in this lab) |
| WAF protection | Other CDN's WAF (different rule sets) | Azure WAF (consistent rule sets) |
| Cost during standby | Dependent on CDN (For example, Akamai typically \$1k-\$5k/month minimum + usage overages, but includes global CDN infrastructure and advanced features). DDoS protection costs are often higher since Azure provides infrastructure-level DDoS protection by default for all customers at no extra cost, covering Layer 3 and Layer 4 attacks. | Fixed compute costs (Application Gateway charges even when idle: ~\$300-400/month for WAF_v2 with minimal capacity). |

## Considerations for production environments

When implementing high availability architectures for production workloads, consider the following best practices and important notes:

- **Don't configure the primary Azure Traffic Manager for automatic failover:** Azure Traffic Manager health probes originate only from US-based Azure regions. Because of this, when probing Front Door endpoints (or any CDN using anycast routing), these U.S.-based probes will almost always reach U.S. POPs, leaving the health of non-U.S. POPs unverified. This prevents Traffic Manager from automatically failing over between Azure Front Door and another ingress service based on the true global health of anycast CDN such as Front Door. As such, for global workloads requiring health validation from multiple geographies, manual failover with weighted routing and monitoring disabled provides more reliable control than automated health-based routing.

- **Certificates:** If you're currently using Front Door-managed certifications, you must migrate to BYO certificates. For more information, see [Configure HTTPS on an Azure Front Door custom domain](/azure/frontdoor/standard-premium/how-to-configure-https-custom-domain).

- Always test failover procedures in non-production environments first.

- **Traffic Manager doesn't support CNAME flattening at the DNS zone apex (root domain):** If you require Traffic Manager at the apex, you must use DNS providers that support alias records or similar mechanisms.

- Use short DNS TTLs (300 - 600 seconds) and monitor DNS TTL propagation times with your user base before setting aggressive TTLs.

- **Security:** Lock down Application Gateway with NSGs/ACLs (allow required platform ranges and inbound application ports) and keep origins secured for all ingress paths. For more information, see [Configure network security groups for your Application Gateway](/azure/application-gateway/configuration-infrastructure#network-security-groups).

- Document WAF rule differences between Front Door and failover solutions.

- **Origin security consideration:** For production environments, consider using `X-Azure-FDID` header validation and IP address filtering for enhanced origin security. For more information, see [Secure traffic to Azure Front Door origins](/azure/frontdoor/origin-security?tabs=app-service-functions&pivots=front-door-standard-premium#public-ip-address-based-origins). **Private Link is not recommended for these HA architectures** because alternative CDNs can't access origins protected by Front Door Private Link, and Application Gateway requires additional virtual network/Private Endpoint configuration to access private origins, and can't use Front Door's native Private Link integration.

- **Edit the sample commands listed in this guide so that they are tailored to your environment for automation and runbooks.**

- Establish clear runbooks and test failover and failback procedures.

- Configure comprehensive monitoring and alerting for all endpoints.

- Plan for gradual traffic shifting during failover to validate functionality.

- Test certificate renewal processes across all platforms.

- Regularly validate that failover endpoints remain functional (quarterly testing recommended).

> [!NOTE]
> - This guide uses Azure CLI (az) **sample** commands executed from within PowerShell.
> - Before proceeding, review the [Global routing redundancy for mission-critical web applications](/azure/architecture/guide/networking/global-web-applications/overview?tabs=cli)


## Scenario 1: Traffic Manager failover: Front Door to alternative CDN

This solution uses a single Traffic Manager profile with weighted/always serve routing so that traffic can be manually switched over between Front Door and an alternative CDN:

1. **Primary endpoint:** Azure Front Door custom domain endpoint. **Traffic flow:** 
    User → DNS Query → Traffic Manager (Weighted / Always serve routing) → Azure Front Door (Priority 1) → Origin servers  

1. **Secondary endpoint:** Alternative CDN endpoint. **Traffic flow:**  
    User → DNS Query → Traffic Manager (Weighted routing / Always serve) → Alternative CDN (Priority 2) → Origin servers

### Key implementation steps

#### Step1: Provision prerequisites

Configure your secondary CDN provider with:

- Azure Front Door configured with custom domain and BYO Certificate.

- Alternative CDN account.

- Lower DNS TTL for your CNAME is Front Door serving traffic to the lowest time setting.

- Origin servers accessible by both Front Door and the alternative CDN.

- Custom domain with ability to modify DNS records

> [!IMPORTANT]
> If you're currently using Front Door-managed certificates, you must migrate to BYO certificates before implementing this HA solution. Front Door-managed certificates can't be exported and installed on alternative CDNs. For more information, see [Configure HTTPS on an Azure Front Door custom domain](/azure/frontdoor/standard-premium/how-to-configure-https-custom-domain) for BYO certificate configuration instructions.


#### Step 2: Configure alternative CDN

Configure your secondary CDN provider with:

- Set up CDN zone/property with your custom domain.

- Configure origin servers (same as Front Door backend pool).

- **Upload BYO SSL/TLS certificate:** (the same certificate used in Front Door).

- **Replicate caching rules:** Configure CDN caching rules to match Front Door behavior (cache durations, query string handling, etc.)

- **Enable similar features:** Set up caching settings, control headers, and compression settings to match Front Door configuration.

- Set up WAF rules if the CDN provider offers WAF capabilities (attempt to match Front Door WAF policy).

- Configure custom domain to match your Front Door custom domain (for example, `www.contoso.com`).

- Record the CDN edge hostname for Traffic Manager configuration (for example, `your-site.cdn.provider.net`).


#### Step 3: Create Traffic Manager profile

Apply the following configuration to create the Traffic Manager profile. For more information, see [Create a Traffic Manager profile](/azure/traffic-manager/quickstart-create-traffic-manager-profile).

| Setting | Value | Notes |
|----|----|----|
| **Routing Method** | Weighted | Allows manual control via endpoint status (Enabled/Disabled). |
| **Weight** | 100 | Enter 100 when the Traffic Manager profile is created and for both endpoints. |
| **Protocol** | HTTPS | Required for validating SSL/TLS endpoints. |
| **Port** | 443 | Standard HTTPS port. |
| **Path** | /index.html | Choose a lightweight endpoint for health checks. |
| **TTL** | 300 seconds | DNS TTL - lower values enable faster failover but increase DNS queries. |

#### Step 4: Configure Traffic Manager endpoints

**Primary endpoint (Front Door):**

- Name: endpoint-afd-primary

- Type: External endpoint

- Target: Front Door endpoint hostname (for example, `myapp-endpoint-12345.z01.azurefd.net`)

- Weight: 100

- Status: Enabled (initially)

- Custom Headers: Host=\$CUSTOM_DOMAIN (required for Front Door to route to correct custom domain)

**Custom headers for Front Door:** The `--custom-headers "Host=\$CUSTOM_DOMAIN"` parameter is critical for Front Door endpoints. Without it, Front Door might not properly route requests to your custom domain configuration. It's a supported feature of Azure Traffic Manager.

**Secondary endpoint (alternative CDN):**

- Name: endpoint-cdn-secondary

- Type: External endpoint

- Target: CDN edge hostname (for example, `myapp.cdn.net`)

- Weight: 100

- Status: Disabled (initially - standby mode)

#### Step 5: Update DNS CNAME to Traffic Manager and verify update

> [!WARNING]
> The following steps will redirect your production traffic from Front Door directly to Traffic Manager. Before proceeding:
> - **Test these steps in a non-production environment first**
> - **Reduce your DNS CNAME TTL to the lowest value possible** (for example, 60-300 seconds) at least 24-48 hours before making changes.
> - **Plan for a maintenance window** during low-traffic periods if possible.
> - **Have rollback procedures ready** in case issues arise.

1. **Update your DNS CNAME record to point to Traffic Manager instead of directly to Front Door:**

    | Field | Old Value | New Value |
    |----|----|----|
    | Name/Host | www | www (no change) |
    | Value/Points to | Front Door endpoint hostname | `$ATM_CDN_DNS_NAME.trafficmanager.net` |

    > [!NOTE]
    > DNS propagation typically takes 5-10 minutes but can take up to 48 hours globally.

2. **Verify Traffic Manager resolution:** Wait for DNS propagation and test HTTPS connectivity. 

```
# Verify Traffic Manager profile is resolving
nslookup "$ATM_CDN_DNS_NAME.trafficmanager.net"
# Expected result: Should return IP address(es) of Front Door endpoint

# Check DNS from different resolvers
nslookup $CUSTOM_DOMAIN 8.8.8.8    # Google DNS

# Test HTTPS connectivity
Invoke-WebRequest -Uri "https://$CUSTOM_DOMAIN/index.html" -Method Head
# Expected result: StatusCode 200
```

3. **Monitor Front Door:** After the DNS cutover, actively monitor the following Azure Front Door metrics:

- Request count: Should remain consistent (no drop in traffic).

- Response time: Should remain within normal ranges.

- Error rates: 4xx/5xx errors shouldn't increase.

- Origin health: Backend health should remain Online.

#### Step 6: Failover procedures

1. Manual failover to alternative CDN

```
# Failover: Disable Front Door and enable CDN
az network traffic-manager endpoint update `
    --name "endpoint-afd-primary" `
    --profile-name $ATM_CDN_PROFILE_NAME `
    --resource-group $RESOURCE_GROUP `
    --type externalEndpoints `
    --endpoint-status Disabled

az network traffic-manager endpoint update `
    --name "endpoint-cdn-secondary" `
    --profile-name $ATM_CDN_PROFILE_NAME `
    --resource-group $RESOURCE_GROUP `
    --type externalEndpoints `
    --endpoint-status Enabled

# Verify endpoint status
az network traffic-manager profile show `
    --name \$ATM_CDN_PROFILE_NAME `
    --resource-group $RESOURCE_GROUP `
    --query "endpoints[].{Name:name, Status:endpointStatus, Health:endpointMonitorStatus, Target:target}"

# Flush local DNS cache and verify resolution
ipconfig /flushdns
nslookup "$ATM_CDN_DNS_NAME.trafficmanager.net"

# Test HTTPS access
curl --head https://$CUSTOM_DOMAIN/
```
 
2. Failback to Front Door

```
# Failback: Enable Front Door, Disable CDN

az network traffic-manager endpoint update `
    --name "endpoint-afd-primary" `
    --profile-name $ATM_CDN_PROFILE_NAME `
    --resource-group $RESOURCE_GROUP `
    --type externalEndpoints `
    --endpoint-status Enabled

az network traffic-manager endpoint update `
    --name "endpoint-cdn-secondary" `
    --profile-name $ATM_CDN_PROFILE_NAME `
    --resource-group $RESOURCE_GROUP `
    --type externalEndpoints `
    --endpoint-status Disabled

# Verify
az network traffic-manager profile show `
    --name $ATM_CDN_PROFILE_NAME `
    --resource-group $RESOURCE_GROUP `
    --query "endpoints[].{Name:name, Status:endpointStatus, Health:endpointMonitorStatus}"
```

