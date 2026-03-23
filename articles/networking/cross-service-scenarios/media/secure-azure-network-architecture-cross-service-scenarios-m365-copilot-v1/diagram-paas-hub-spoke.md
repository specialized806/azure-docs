# PaaS Backend - Hub-Spoke Network Architecture

Hub-spoke network foundation for regional web applications with Azure App Service backends.

- 🛡️ = Azure DDoS Protection (conditional)
- 🔒 = Network Security Group (on every subnet)
- Solid arrow = active traffic flow
- Dotted arrow = optional / conditional path

```mermaid
flowchart TB
    Internet((Internet))
    KV[Azure Key Vault]

    subgraph DDoS["🛡️ Azure DDoS Protection · conditional"]
        subgraph Hub["Hub Virtual Network"]
            subgraph FS["🔒 AzureFirewallSubnet · optional"]
                FW[Azure Firewall Basic]
            end
            subgraph FMS["🔒 AzureFirewallManagementSubnet · optional"]
                FWMgmt[Firewall Management]
            end
        end

        Peering{{"VNet Peering"}}

        subgraph Spoke["Spoke Virtual Network"]
            subgraph AGS["🔒 Application Gateway Subnet"]
                AppGW[Application Gateway WAF_v2]
            end
            subgraph WLS["🔒 Workload Subnet"]
                AppSvc[Azure App Service]
            end
        end
    end

    Internet -->|HTTPS| AppGW
    AppGW -->|Backend traffic| AppSvc
    AppGW -.->|TLS certificates| KV
    Hub --- Peering --- Spoke
    FWMgmt ---|Management plane| FW
    AppSvc -.->|"Optional · VNet Integration + UDR"| Peering
    Peering -.-> FW -.->|Outbound| Internet
```
