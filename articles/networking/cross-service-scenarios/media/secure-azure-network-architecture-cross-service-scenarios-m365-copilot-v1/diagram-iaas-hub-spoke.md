# IaaS Backend - Hub-Spoke Network Architecture

Hub-spoke network foundation for regional web applications with Virtual Machine backends.

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
            subgraph BS["🔒 AzureBastionSubnet"]
                Bastion[Azure Bastion]
            end
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
            subgraph WLS["🔒 Workload Subnet · private"]
                VM[Virtual Machines]
            end
            NAT[NAT Gateway · conditional]
        end
    end

    Internet -->|HTTPS| AppGW
    AppGW -->|Backend traffic| VM
    AppGW -.->|TLS certificates| KV
    Bastion -->|RDP / SSH| Peering
    Peering -->|RDP / SSH| VM
    FWMgmt ---|Management plane| FW
    VM --> NAT -->|Outbound| Internet
    VM -.->|Optional UDR| Peering
    Peering -.-> FW -.->|Outbound| Internet
```
