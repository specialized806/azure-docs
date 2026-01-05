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

## Key operational differences

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

- **Don't configure the primary Azure Traffic Manager for automatic failover:** Azure Traffic Manager health probes originate only from US-based Azure regions. Because of this, when probing Front Door endpoints (or any CDN using anycast routing), these US-based probes will almost always reach US POPs, leaving the health of non-US POPs unverified. This prevents Traffic Manager from automatically failing over between Azure Front Door and another ingress service based on the true global health of anycast CDN such as Front Door. As such, for global workloads requiring health validation from multiple geographies, manual failover with weighted routing and monitoring disabled provides more reliable control than automated health-based routing.

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
> - This guide uses Azure CLI sample commands executed from within PowerShell.
> - Before proceeding, review the [Global routing redundancy for mission-critical web applications](/azure/architecture/guide/networking/global-web-applications/overview?tabs=cli)

## Scenario 1: Traffic Manager failover: Front Door to alternative CDN

This solution uses a single Traffic Manager profile with weighted/always serve routing so that traffic can be manually switched over between Front Door and an alternative CDN:

1. **Primary endpoint:** Azure Front Door custom domain endpoint. **Traffic flow:** 
    User → DNS Query → Traffic Manager (Weighted / Always serve routing) → Azure Front Door (Priority 1) → Origin servers  

1. **Secondary endpoint:** Alternative CDN endpoint. **Traffic flow:**  
    User → DNS Query → Traffic Manager (Weighted routing / Always serve) → Alternative CDN (Priority 2) → Origin servers

### Key implementation steps

#### Step 1: Provision prerequisites

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
> **Step 5 configurations** will redirect your production traffic from Front Door directly to Traffic Manager. Before proceeding, ensure you have done the following steps:
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

## Scenario 2: Traffic Manager failover: Front Door to Application Gateway WAF

Primary Traffic Manager routes between Front Door (primary) and a nested Secondary Traffic Manager pointing to multi-region Application Gateway instances. During Front Door outage, traffic is manually failed over to regional Application Gateway deployments with WAF protection.


**Traffic Flow (Normal Operation):**

User → DNS Query → Primary Traffic Manager (Weighted / Always server routing) → Front Door (Priority 1) → Origin Servers  
  
**Traffic Flow (Front Door Failure):**  
User → DNS Query → Primary Traffic Manager (Weighted / Always server routing) → Secondary Traffic Manager (Priority mode) → Application Gateway(s) → Origin Servers

### 

Pre-Deployment: Front Door vs Application Gateway Feature Differences

It is important you understand the feature differences between Front Door and Application Gateway WAF in case you are utilizing any features Application Gateway WAF does not offer. Here is an overview.

 

**Critical Architecture Note:** This **solution replaces a global Layer 7 service (Front Door) with Application Gateway, which is a regional service**. Because of this shift, you must evaluate your global traffic patterns and **deploy Application Gateway instances in the regions where you have meaningful user volume**. To maintain the latency‑optimized routing that Front Door normally provides for globally distributed users, **deploy a Secondary Traffic Manager using Performance routing** between the Primary Traffic Manager and the regional Application Gateway instance.

 

Features Differences

<table>
<colgroup>
<col style="width: 28%" />
<col style="width: 38%" />
<col style="width: 33%" />
</colgroup>
<thead>
<tr>
<th><strong>Feature</strong></th>
<th><strong>Azure Front Door</strong></th>
<th><strong>Application Gateway</strong></th>
</tr>
</thead>
<tbody>
<tr>
<td colspan="3"><strong>Core Architecture &amp; Features</strong></td>
</tr>
<tr>
<td>Service Scope</td>
<td>Global service</td>
<td>Regional service</td>
</tr>
<tr>
<td>OSI Layer</td>
<td>Layer 7 (Application layer)</td>
<td>Layer 7 (Application layer)</td>
</tr>
<tr>
<td>Load Balancing Level</td>
<td>Across regions</td>
<td>Within region/VNET</td>
</tr>
<tr>
<td>Deployment Model</td>
<td>Single global instance</td>
<td>Per-region instances</td>
</tr>
<tr>
<td>Backend Scope</td>
<td>Any public endpoint (Azure or external), and selected Private Link endpoints</td>
<td>Any public endpoint (Azure or external), private IP addresses and Kubernetes pods in VNET</td>
</tr>
<tr>
<td>Content Edge Caching</td>
<td>Yes</td>
<td>No</td>
</tr>
<tr>
<td>Network Architecture</td>
<td>Microsoft's global edge network with anycast</td>
<td>Azure regional deployment (no anycast)</td>
</tr>
<tr>
<td>Configuration Differences</td>
<td> </td>
<td> </td>
</tr>
<tr>
<td>Path Pattern Syntax</td>
<td>/path/* or exact /path</td>
<td>Regex patterns, path maps</td>
</tr>
<tr>
<td>WAF Rule Sets</td>
<td>Default Ruleset (OWASP), Bot Manager Ruleset, HTTP DDoS Ruleset</td>
<td>Default Ruleset (OWASP), Bot Manager Ruleset, HTTP DDoS Ruleset</td>
</tr>
<tr>
<td>Health Probe Evaluation</td>
<td>Latency + health for routing</td>
<td>Health status only</td>
</tr>
<tr>
<td>Backend Selection</td>
<td>Based on priority, weight, latency</td>
<td>Round-robin, cookie affinity</td>
</tr>
<tr>
<td colspan="3"><strong>Routing Rules</strong></td>
</tr>
<tr>
<td>Path-based Routing</td>
<td>✓ Yes</td>
<td>✓ Yes</td>
</tr>
<tr>
<td>Pattern Matching</td>
<td>- Exact match paths</td>
<td>- URL path maps</td>
</tr>
<tr>
<td>Host-based Routing</td>
<td>- Wildcard paths (/*)</td>
<td>- Path-based rules</td>
</tr>
<tr>
<td>URL Rewrite</td>
<td>- Case-insensitive</td>
<td>- Regex patterns supported</td>
</tr>
<tr>
<td>Request Routing Order</td>
<td>- Wildcard must be preceded by /</td>
<td>✓ Multi-site hosting</td>
</tr>
<tr>
<td>Routing Methods</td>
<td>✓ Multiple frontend hosts</td>
<td>- URL path rewrite</td>
</tr>
<tr>
<td>Path-based Routing</td>
<td>- Static path to static path (Classic)</td>
<td><p>- Load Aware for Latency Optimization*</p>
<p>- Weighted*</p>
<p>- Session affinity.</p>
<p> </p>
<p>* available with Application Gateway for Containers<a href="#_msocom_1">[JS1]</a> <a href="#_msocom_2">[JS2]</a> <a href="#_msocom_3">[DB3]</a> </p></td>
</tr>
<tr>
<td colspan="3"><strong>Routing Features</strong></td>
</tr>
<tr>
<td>Rules Engine/Rewrite Rules</td>
<td>Rule sets with conditions and actions</td>
<td>Rewrite rule sets with conditions and actions</td>
</tr>
<tr>
<td>Regex in Path Patterns</td>
<td>Not supported in "Patterns to match"</td>
<td>Supported with PCRE</td>
</tr>
<tr>
<td colspan="3"><strong>Header and Request Manipulation</strong></td>
</tr>
<tr>
<td>Header Rewrite</td>
<td>✓ Request and response headers</td>
<td>✓ Request and response headers</td>
</tr>
<tr>
<td>Header Value Character Limit</td>
<td>No documented limit</td>
<td>1,000 characters in rewrite rules</td>
</tr>
<tr>
<td>Host Header Rewrite</td>
<td>✓ Supported</td>
<td>✓ Supported (can't rewrite to external domains)</td>
</tr>
<tr>
<td>Server Variables</td>
<td>✓ Supported</td>
<td>✓ Supported</td>
</tr>
<tr>
<td>Header Pattern Matching</td>
<td>Conditions with patterns</td>
<td>Regex pattern matching</td>
</tr>
<tr>
<td colspan="3"><strong>Security Features</strong></td>
</tr>
<tr>
<td>WAF Availability</td>
<td>✓ Optional (Premium SKU)</td>
<td>✓ Optional (WAF SKU)</td>
</tr>
<tr>
<td>L3/4 DDoS Protection</td>
<td>✓ Built-in</td>
<td>Via Azure DDoS Protection service</td>
</tr>
<tr>
<td>SSL/TLS Policies</td>
<td>✓ Configurable</td>
<td>✓ Configurable</td>
</tr>
<tr>
<td>End-to-End SSL</td>
<td>✓ Supported</td>
<td>✓ Supported</td>
</tr>
<tr>
<td>Private Link Support</td>
<td>✓ Premium tier</td>
<td>✓ V2 SKU</td>
</tr>
<tr>
<td>WAF Custom Rules</td>
<td>✓ Supported</td>
<td>✓ Supported</td>
</tr>
</tbody>
</table>

 

WAF Differences

| **Azure Front Door** | **Application Gateway** |
|----|----|
| Microsoft_DefaultRuleSet (DRS 2.1) | OWASP Core Rule Set (CRS 3.2 or 4.0) |
| Rule IDs: 949xxx series | Rule IDs: 9xxxxx series |
| Front Door WAF (DRS): inspects first 128 KB of request body | Application Gateway WAF (CRS 3.2+): up to 2 MB inspection; 4 GB file upload; enforcement and inspection can be configured independently |

** **

Recommendations:

•       Maintain separate custom rule sets; use Front Door rules as baseline

•        Test Application Gateway WAF separately and independently

•        Document all custom exclusions for both platforms

•       Regularly audit rule sets for consistency

 

Capacity Planning & Autoscaling Strategy

Please reference <https://learn.microsoft.com/en-us/azure/well-architected/service-guides/azure-application-gateway> for detailed best practices

 

Network Planning

##### VNet and Subnet Requirements:

1.  **Subnet sizing (per region):**

    - Minimum: /27 (32 addresses)

    - Recommended: /24 (256 addresses) for autoscaling and hitless maintenance

    - Formula: (max instances \* 10) + 5 Azure reserved IPs

    - Example: 20 max instances → (20 \* 10) + 5 = 205 IPs → use /24

2.  **Connectivity to origins:**

    - VNet peering: For origins in different VNets

    - ExpressRoute/VPN: For on-premises origins

    - Public internet: For SaaS/cloud origins with proper security

3.  **Securing Application Gateway:**

- Dedicated subnet for Application Gateway (no other resources)

- **Inbound allows:**

  - 443/80 from Internet (or specific source ranges)

  - 65200-5535 from GatewayManager (Application Gateway v2)

  - AzureLoadBalancer

- Block other inbound; do not block required outbound internet

- Use ASGs for backend segmentation and least-privilege rules

###  

### Key Implementation Steps

### 

Step 1: Provision Prerequisites

- Azure Front Door configured with custom domain and BYO Certificate

- Lower DNS TTL for your CNAME is Front Door serving traffic to the lowest time setting.

- Azure subscription with permissions to create VNets, Application Gateway, and Traffic Manager
>
- SSL/TLS certificate in Azure Key Vault or available for upload
>
- Origin servers accessible from Azure VNets

 

**Important:** If you are currently using Front Door-managed certificates, you MUST migrate to BYO certificates before implementing this solution. Front Door-managed certificates can't be exported and installed on alternative CDNs. See [Microsoft documentation](https://learn.microsoft.com/en-us/azure/frontdoor/standard-premium/how-to-configure-https-custom-domain) for BYO certificate configuration instructions.

 

Step 2: Deploy Application Gateway (Region 1)

2.1: Create Network Infrastructure for Application Gateway

<https://learn.microsoft.com/en-us/azure/application-gateway/configuration-infrastructure>

 

2.2: Create Managed Identity and Grant Key Vault Access

<https://learn.microsoft.com/en-us/azure/application-gateway/key-vault-certs>

 

**SSL/TLS Certificate:** Application Gateway requires the SSL/TLS certificate in PFX format with private key. The certificate must be accessible from Azure Key Vault or uploaded directly. Use the same certificate deployed to Front Door to ensure consistent TLS behavior.

 

 

2.3: Create WAF Policy

<https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/create-waf-policy-ag>

 

2.4: Create Application Gateway with HTTPS and WAF

<https://learn.microsoft.com/en-us/azure/application-gateway/create-ssl-portal>

 

2.5: Configure Backend Host Header

<https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-backend-health-troubleshooting#host-name>

 

2.6: Verify Application Gateway

\# Get Application Gateway public IP

\$APPGW_IP = az network public-ip show \`

    --name \$APPGW_PIP_NAME_R1 \`

    --resource-group \$RESOURCE_GROUP \`

    --query ipAddress -o tsv

Write-Host "Application Gateway IP: \$APPGW_IP"

\# Test Application Gateway directly (SkipCertificateCheck because cert is for domain, not IP)

Invoke-WebRequest -Uri "https://\$APPGW_IP/index.html" -Method Head -SkipCertificateCheck

** **

**Expected Result:** StatusCode 200. If you get 502 Bad Gateway, ensure the backend HTTP settings have --host-name-from-backend-pool true enabled

 

Step 3: Configure WAF Policy Settings (Optional)

**Note:** By default, WAF is created in Detection mode. Prevention mode actively blocks malicious requests. Test thoroughly before enabling Prevention mode in production.

 

**IMPORTANT REMINDER: Evaluate your global traffic patterns and deploy Application Gateway instances in regions with meaningful user volume.** If deploying multi-region Application Gateway, **repeat Steps 2 and 3 for each additional region (for example,  West US 2) using different** VNet address spaces (10.2.0.0/16, 10.3.0.0/16, etc.) and region-specific variable suffixes (R2, R3, etc).

 

Step 4: Create Traffic Manager Architecture

 

4.1: Create Secondary Traffic Manager (for Application Gateway endpoints)

<https://learn.microsoft.com/en-us/azure/traffic-manager/traffic-manager-create-profile>

Single-Region Configuration:

- Routing Method: Priority
>
- Endpoint: Single Application Gateway public IP address

 

Multi-Region Configuration:

- Routing Method: Performance (routes users to nearest healthy Application Gateway)
>
- Endpoints: Multiple Application Gateway public IP addresses across regions
>
- Endpoint Locations: Specify Azure region for each endpoint (required for Performance routing)

** **

**Configuration:**

| **Setting** | **Value** | **Notes** |
|----|----|----|
| **Routing Method** | Performance (multi-region) or Priority (single-region) | Performance optimizes latency for multi-region |
| **Protocol** | HTTPS | Validates Application Gateway health via HTTPS |
| **Port** | 443 | Standard HTTPS port |
| **Path** | /health or /index.html | Must match Application Gateway backend health probe path |
| **TTL** | 300 seconds | Balances DNS query load and responsiveness |

 

 

**Application Gateway Public IP Limitation:** By default, Azure public IPs don't have DNS names configured. You must use the public IP address directly in Traffic Manager endpoints, not a DNS name. The --endpoint-location parameter is required for Performance routing to enable geographic routing.

 

4.2: Create Primary Traffic Manager (Front Door primary, Application Gateway failover)

<https://learn.microsoft.com/en-us/azure/traffic-manager/traffic-manager-create-profile>  

** **

** **

**Configurations for Both Endpoints:**

| **Setting** | **Value** | **Notes** |
|----|----|----|
| **Routing Method** | Weighted | Allows manual control via endpoint status (Enabled/Disabled) |
| **Weight** | 100 |   |
| **Protocol** | HTTPS | Required for validating SSL/TLS endpoints |
| **Port** | 443 | Standard HTTPS port |
| **Path** | /index.html | Choose a lightweight endpoint for health checks |
| **TTL** | 300 seconds | DNS TTL - lower values enable faster failover but increase DNS queries |
| **Health Check** | Always serve traffic | Do not enable Health checks |

 

**Endpoint Specific Configurations:**

1.  **Primary Endpoint:**

    - **Name:** endpoint-afd-primary

    - **Type:** External endpoint

    - **Target:** Front Door endpoint hostname (for example,  myapp-12345.z01.azurefd.net)

    - **End Point Status:** Enabled

2.  **Secondary Endpoint:**

    - **Name:** endpoint-appgw-secondary

    - **Type:** External endpoint

    - **Target:** Secondary Traffic Manager FQDN (for example,  myapp-appgw.trafficmanager.net)

    - **End Point Statis:** Disabled

 

4.3: Verify Traffic Manager Health

\# Check endpoint health status

az network traffic-manager profile show \`

    --name \$ATM_PRIMARY_PROFILE \`

    --resource-group \$RESOURCE_GROUP \`

    --query "{ProfileStatus:profileStatus, MonitorStatus:monitorConfig.profileMonitorStatus, Endpoints:endpoints\[\].{Name:name, Target:target, Priority:priority, Status:endpointMonitorStatus}}"

**Expected Result:** Both endpoints should show Status: Online. If an endpoint shows Degraded or CheckingEndpoint, wait 1-2 minutes for health probes to complete.

 

5: Update DNS CNAME to Traffic Manager and Verify Update

**⚠️ WARNING - Potential Service Impact:** The following steps will redirect your production traffic from Front Door directly to Traffic Manager. Before proceeding:

- **Test these steps in a non-production environment first**

- **Reduce your DNS CNAME TTL to the lowest value possible** (for example,  60-300 seconds) at least 24-48 hours before making changes

- **Plan for a maintenance window** during low-traffic periods if possible

- **Have rollback procedures ready** in case issues arise

5.1 Update DNS CNAME Record

Update your DNS CNAME record to point to the **Primary** Traffic Manager (see above) instead of directly to Front Door:

**Field Old Value New Value**

Name/Host www www (no change)

Value / Points to Front Door endpoint hostname \$ATM_DNS_NAME.trafficmanager.net

5.2 Verify Traffic Manager Resoltion, Wait for DNS Propagation, and Test

DNS propagation typically takes 5-10 minutes but can take up to 48 hours globally. Monitor propagation progress and test HTTPS connectivity:

\# Verify Traffic Manager profile is resolving

nslookup "\$ATM_DNS_NAME.trafficmanager.net"

\# Expected result: Should return IP address(es) of Front Door endpoint

\# Check DNS from different resolvers

nslookup \$CUSTOM_DOMAIN 8.8.8.8 \# Google DNS

\# Test HTTPS connectivity

Invoke-WebRequest -Uri "https://\$CUSTOM_DOMAIN/index.html" -Method Head

\# Expected result: StatusCode 200

5.3 Monitor Front Door

After the DNS cutover, actively monitor the following Azure Front Door Metrics:

- Request count - Should remain consistent (no drop in traffic)

- Response time - Should remain within normal ranges

- Error rates - 4xx/5xx errors should not increase

- Origin health - Backend health should remain Online

Step 6: Test Failover Procedures

 

6.1: Simulate Front Door Failure (Manual Failover to Application Gateway)

\# Manual Failover to Application Gateway

\# Disable Front Door endpoint
az network traffic-manager endpoint update \`

--name "endpoint-afd-primary" \`

--profile-name \$ATM_PRIMARY_PROFILE \`

--resource-group \$RESOURCE_GROUP \`

--type externalEndpoints \`

--endpoint-status Disabled

\# Enable Secondary Traffic Manager endpoint (Application Gateway)

az network traffic-manager endpoint update \`

--name "endpoint-appgw-secondary" \`

--profile-name \$ATM_PRIMARY_PROFILE \`

--resource-group \$RESOURCE_GROUP \`

--type externalEndpoints \`

--endpoint-status Enabled

\# Verify Traffic Manager endpoint status

az network traffic-manager endpoint list \`

--profile-name \$ATM_PRIMARY_PROFILE \`

--resource-group \$RESOURCE_GROUP \`

--query "\[\].{Name:name, Status:endpointStatus, Health:endpointMonitorStatus}" \`

--output table

\# Flush DNS cache (Windows)

ipconfig /flushdns

\# Verify DNS resolution (should now point to Secondary Traffic Manager → Application Gateway)

nslookup \$CUSTOM_DOMAIN

\# Test - should now work via Application Gateway

curl --head https://\$CUSTOM_DOMAIN/

**Note:** DNS TTL affects failover time. With TTL of 60 seconds, clients may take up to 60 seconds to see the change. Use nslookup to verify resolution is pointing to Application Gateway.

 

6.2: Failback to Front Door

\# Re-enable Front Door endpoint

az network traffic-manager endpoint update \`

--name "endpoint-afd-primary" \`

--profile-name \$ATM_PRIMARY_PROFILE \`

--resource-group \$RESOURCE_GROUP \`

--type externalEndpoints \`

--endpoint-status Enabled

\# Disable Application Gateway (via Secondary Traffic Manager)

az network traffic-manager endpoint update \`

--name "endpoint-appgw-secondary" \`

--profile-name \$ATM_PRIMARY_PROFILE \`

--resource-group \$RESOURCE_GROUP \`

--type externalEndpoints \`

--endpoint-status Disabled

\# Verify endpoint status

az network traffic-manager endpoint list \`

--profile-name \$ATM_PRIMARY_PROFILE \`

--resource-group \$RESOURCE_GROUP \`

--query "\[\].{Name:name, Status:endpointStatus, Health:endpointMonitorStatus}" \`

--output table

\# Flush DNS cache (Windows)

ipconfig /flushdns

\# Verify DNS resolution (should now point back to Front Door)

nslookup \$CUSTOM_DOMAIN

\# Test - should now work via Front Door

curl --head https://\$CUSTOM_DOMAIN/

 

6.3: Verify Current Routing

\# Check which endpoint is serving traffic

nslookup \$CUSTOM_DOMAIN

\# The response headers can help identify the serving endpoint

\# Front Door includes "x-azure-ref" header

\# Application Gateway includes "Server: Microsoft-IIS" or similar

Invoke-WebRequest -Uri "https://\$CUSTOM_DOMAIN/index.html" -Method Head \| Select-Object -ExpandProperty Headers

 

## <u>Monitoring</u>

 

**Critical Recommendation:** Configure synthetic monitors to alert immediately on failures. These alerts should trigger manual failover if automatic failover is insufficient (for example,  Front Door custom domain issues that Traffic Manager can't detect).

>  

 

Recommended Monitoring for Production

- **Azure Monitor Workbooks:** Track Traffic Manager queries, Front Door requests, Application Gateway health - [Workbooks Overview](https://learn.microsoft.com/en-us/azure/azure-monitor/visualize/workbooks-overview)

<!-- -->

- **Outside-in Monitoring** **to Detect Global Front Door Issues:** Implement outside-in global synthetics observability solutions (Catchpoint or ThousandEyes) to monitor endpoints. Services such as https://www.webpagetest.org/ are a free service that does provide limited global visibility.

<!-- -->

- **Application Insights Availability Tests:** Multi-region HTTP checks - [Availability Testing](https://learn.microsoft.com/en-us/azure/azure-monitor/app/availability-overview)

- **DNS Monitoring:** Validate CNAME resolution chain and TTL propagation via DNSPerf, Pingdom, or Uptime.com

- **Certificate Monitoring:** SSL Labs Server Test - <https://www.ssllabs.com/ssltest/>
