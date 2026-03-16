# Secure hub-spoke network for regional web applications

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fsecure-web-app-hub-spoke%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fsecure-web-app-hub-spoke%2Fazuredeploy.json)

This template deploys a secure hub-spoke network foundation for regional web applications, following the [Secure network foundation for regional web applications](https://learn.microsoft.com/azure/networking/cross-service-scenarios/secure-web-app-network-foundation-layered-hub-spoke) architecture guide.

## Architecture

A **hub virtual network** hosts shared services (Azure Bastion, optional Azure Firewall), and a **spoke virtual network** hosts the workload (Application Gateway WAF_v2 with two IIS backend VMs). VNet peering connects them, NSGs enforce default-deny rules at every subnet boundary, and a Log Analytics workspace collects diagnostic data.

## Deployed resources

| Resource | Count | Notes |
|---|---|---|
| Virtual networks | 2 | Hub (10.0.0.0/24) and spoke (10.1.0.0/16) |
| VNet peerings | 2 | Bidirectional hub-to-spoke |
| Network security groups | 3 | Bastion, Application Gateway, workload subnets |
| Application Gateway WAF_v2 | 1 | HTTP listener on port 80, OWASP 3.2 in Detection mode |
| WAF policy | 1 | OWASP Core Rule Set 3.2 |
| Azure Bastion (Basic SKU) | 1 | In hub, reaches spoke VMs via peering |
| Windows Server 2022 VMs | 2 | IIS installed via CustomScriptExtension |
| Network interfaces | 2 | In workload subnet, linked to App Gateway backend pool |
| Public IP addresses | 2–4 | Bastion + App Gateway always; +2 if Firewall enabled |
| Log Analytics workspace | 1 | Receives App Gateway diagnostic logs and metrics |
| Azure Firewall Basic | 0–1 | Conditional: `deployAzureFirewall` parameter (default: true) |
| Firewall policy | 0–1 | Conditional: basic outbound allow rules |
| Route table | 0–1 | Conditional: default route to firewall private IP |
| DDoS Protection plan | 0–1 | Conditional: `enableDdosProtection` parameter (default: false) |

## Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `location` | string | Resource group location | Azure region for all resources |
| `adminUsername` | string | *(required)* | Admin username for backend VMs |
| `adminPassword` | securestring | *(required)* | Admin password for backend VMs |
| `deployAzureFirewall` | bool | `true` | Deploy Azure Firewall Basic in the hub |
| `enableDdosProtection` | bool | `false` | Enable DDoS Protection plan (~$2,944/month) |
| `vmSize` | string | `Standard_DS2_v2` | VM size for backend VMs |

## Testing the deployment

After deployment completes:

1. **Test web traffic through WAF:** Browse to the Application Gateway public IP (shown in outputs). You should see the IIS default page with the VM hostname.
2. **Test Bastion connectivity:** In the Azure portal, navigate to one of the backend VMs and select **Connect > Bastion**. Enter the admin credentials to verify RDP access through the hub.

## Post-deployment recommendations

- **Switch WAF to Prevention mode** before serving production traffic.
- **Enable VNet flow logs** on both virtual networks for traffic analysis. See [VNet flow logs](https://learn.microsoft.com/azure/network-watcher/vnet-flow-logs-overview).
- **Store TLS certificates in Azure Key Vault** and configure HTTPS listeners on Application Gateway. See [Key Vault certificates](https://learn.microsoft.com/azure/application-gateway/key-vault-certs).
- **Review NSG rules** and tighten egress rules based on your workload requirements.

## Cost considerations

- **DDoS Protection** is disabled by default because it adds ~$2,944/month. Enable it only for internet-facing production workloads.
- **Azure Firewall Basic** is enabled by default (~$250/month + data processing). Set `deployAzureFirewall` to `false` if you don't need centralized egress control.
- **Azure Bastion Basic** runs at ~$140/month. Required for secure IaaS management without public IPs on VMs.
- **Application Gateway WAF_v2** uses autoscaling (1–2 instances) to minimize cost during evaluation.

Tags: `hub-spoke, waf, application-gateway, bastion, firewall, nsg, ddos, vnet-peering, iis`
