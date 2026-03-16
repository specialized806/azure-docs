// ============================================================================
// Secure hub-spoke network foundation for regional web applications
// Deploys: Hub VNet (Bastion + optional Firewall) + Spoke VNet (App Gateway
// WAF_v2 + IIS VMs) with NSGs, peering, optional DDoS, and observability.
// ============================================================================

@description('The Azure region for all resources.')
param location string = resourceGroup().location

@description('Admin username for the backend virtual machines.')
param adminUsername string

@description('Admin password for the backend virtual machines.')
@secure()
param adminPassword string

@description('Deploy Azure Firewall Basic in the hub virtual network for centralized egress control.')
param deployAzureFirewall bool = true

@description('Enable Azure DDoS Protection plan on both virtual networks. Adds significant monthly cost.')
param enableDdosProtection bool = false

@description('Size of the backend virtual machines.')
param vmSize string = 'Standard_DS2_v2'

// ============================================================================
// Variables
// ============================================================================

// Hub VNet: 10.0.0.0/24 — small, shared services only
var hubVnetName = 'vnet-hub'
var hubVnetAddressPrefix = '10.0.0.0/24'
var bastionSubnetPrefix = '10.0.0.0/26'
var firewallSubnetPrefix = '10.0.0.64/26'
var firewallMgmtSubnetPrefix = '10.0.0.128/26'

// Spoke VNet: 10.1.0.0/16 — larger, workload resources
var spokeVnetName = 'vnet-spoke'
var spokeVnetAddressPrefix = '10.1.0.0/16'
var appGatewaySubnetPrefix = '10.1.0.0/24'
var workloadSubnetPrefix = '10.1.1.0/24'

// Naming
var uniqueSuffix = uniqueString(resourceGroup().id)
var bastionName = 'bas-hub'
var bastionPipName = 'pip-bastion'
var appGatewayName = 'agw-spoke'
var appGatewayPipName = 'pip-appgateway'
var wafPolicyName = 'waf-policy-agw'
var logWorkspaceName = 'law-hubspoke-${uniqueSuffix}'
var firewallName = 'fw-hub'
var firewallPipName = 'pip-firewall'
var firewallMgmtPipName = 'pip-firewall-mgmt'
var firewallPolicyName = 'fwpolicy-hub'
var routeTableName = 'rt-spoke-workload'
var ddosPlanName = 'ddos-plan'
var vmNamePrefix = 'vm-workload'
var nsgBastionName = 'nsg-bastion'
var nsgAppGwName = 'nsg-appgateway'
var nsgWorkloadName = 'nsg-workload'

// First available IP in AzureFirewallSubnet (10.0.0.64/26). Azure reserves
// .64 (network), .65-.67 (platform). The firewall receives .68.
var firewallPrivateIp = '10.0.0.68'

// ============================================================================
// DDoS Protection Plan (conditional)
// ============================================================================

resource ddosPlan 'Microsoft.Network/ddosProtectionPlans@2024-05-01' = if (enableDdosProtection) {
  name: ddosPlanName
  location: location
}

// ============================================================================
// Network Security Groups — deploy before VNets so subnets are never exposed
// ============================================================================

// --- Bastion NSG (follows exact Azure Bastion NSG requirements) ---
resource nsgBastion 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: nsgBastionName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsInbound'
        properties: {
          priority: 120
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowGatewayManagerInbound'
        properties: {
          priority: 130
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowAzureLoadBalancerInbound'
        properties: {
          priority: 140
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowBastionHostCommunicationInbound'
        properties: {
          priority: 150
          direction: 'Inbound'
          access: 'Allow'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowSshRdpOutbound'
        properties: {
          priority: 120
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowAzureCloudOutbound'
        properties: {
          priority: 130
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'AzureCloud'
        }
      }
      {
        name: 'AllowBastionHostCommunicationOutbound'
        properties: {
          priority: 140
          direction: 'Outbound'
          access: 'Allow'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowHttpOutbound'
        properties: {
          priority: 150
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
        }
      }
    ]
  }
}

// --- Application Gateway NSG ---
resource nsgAppGw 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: nsgAppGwName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHttpInbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowGatewayManagerInbound'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '65200-65535'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowAzureLoadBalancerInbound'
        properties: {
          priority: 120
          direction: 'Inbound'
          access: 'Allow'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// --- Workload NSG (default-deny with explicit allows) ---
resource nsgWorkload 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: nsgWorkloadName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHttpFromAppGateway'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: appGatewaySubnetPrefix
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowRdpFromBastion'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: hubVnetAddressPrefix
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowSshFromBastion'
        properties: {
          priority: 120
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: hubVnetAddressPrefix
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          priority: 4096
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// ============================================================================
// Route Table (conditional — forces egress through Azure Firewall)
// ============================================================================

resource routeTable 'Microsoft.Network/routeTables@2024-05-01' = if (deployAzureFirewall) {
  name: routeTableName
  location: location
  properties: {
    disableBgpRoutePropagation: true
    routes: [
      {
        name: 'default-to-firewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallPrivateIp
        }
      }
    ]
  }
}

// ============================================================================
// Log Analytics Workspace
// ============================================================================

resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// ============================================================================
// Hub Virtual Network (Bastion + Firewall subnets)
// ============================================================================

resource hubVnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: hubVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        hubVnetAddressPrefix
      ]
    }
    enableDdosProtection: enableDdosProtection
    ddosProtectionPlan: enableDdosProtection ? { id: ddosPlan.id } : null
    subnets: [
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: bastionSubnetPrefix
          networkSecurityGroup: {
            id: nsgBastion.id
          }
        }
      }
      {
        // Always create firewall subnets for future-proofing per architecture guidance.
        // Azure Firewall subnets do not support NSGs.
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: firewallSubnetPrefix
        }
      }
      {
        name: 'AzureFirewallManagementSubnet'
        properties: {
          addressPrefix: firewallMgmtSubnetPrefix
        }
      }
    ]
  }
}

// ============================================================================
// Spoke Virtual Network (Application Gateway + Workload subnets)
// ============================================================================

resource spokeVnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: spokeVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        spokeVnetAddressPrefix
      ]
    }
    enableDdosProtection: enableDdosProtection
    ddosProtectionPlan: enableDdosProtection ? { id: ddosPlan.id } : null
    subnets: [
      {
        name: 'snet-appgateway'
        properties: {
          addressPrefix: appGatewaySubnetPrefix
          networkSecurityGroup: {
            id: nsgAppGw.id
          }
        }
      }
      {
        name: 'snet-workload'
        properties: {
          addressPrefix: workloadSubnetPrefix
          networkSecurityGroup: {
            id: nsgWorkload.id
          }
          routeTable: deployAzureFirewall ? { id: routeTable.id } : null
        }
      }
    ]
  }
}

// ============================================================================
// VNet Peering (bidirectional)
// ============================================================================

resource hubToSpokePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-05-01' = {
  parent: hubVnet
  name: 'hub-to-spoke'
  properties: {
    remoteVirtualNetwork: {
      id: spokeVnet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

resource spokeToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-05-01' = {
  parent: spokeVnet
  name: 'spoke-to-hub'
  properties: {
    remoteVirtualNetwork: {
      id: hubVnet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

// ============================================================================
// Application Gateway Public IP
// ============================================================================

resource pipAppGw 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: appGatewayPipName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// ============================================================================
// WAF Policy (OWASP 3.2, Detection mode)
// ============================================================================

resource wafPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2024-05-01' = {
  name: wafPolicyName
  location: location
  properties: {
    policySettings: {
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
      state: 'Enabled'
      mode: 'Detection'
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.2'
        }
      ]
    }
  }
}

// ============================================================================
// Application Gateway WAF_v2
// ============================================================================

resource appGateway 'Microsoft.Network/applicationGateways@2024-05-01' = {
  name: appGatewayName
  location: location
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
    }
    autoscaleConfiguration: {
      minCapacity: 1
      maxCapacity: 2
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: '${spokeVnet.id}/subnets/snet-appgateway'
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        properties: {
          publicIPAddress: {
            id: pipAppGw.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port-80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'backendPool'
        properties: {}
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'httpSettings'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
        }
      }
    ]
    httpListeners: [
      {
        name: 'httpListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/frontendIPConfigurations',
              appGatewayName,
              'appGwPublicFrontendIp'
            )
          }
          frontendPort: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/frontendPorts',
              appGatewayName,
              'port-80'
            )
          }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'routingRule'
        properties: {
          priority: 100
          ruleType: 'Basic'
          httpListener: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/httpListeners',
              appGatewayName,
              'httpListener'
            )
          }
          backendAddressPool: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendAddressPools',
              appGatewayName,
              'backendPool'
            )
          }
          backendHttpSettings: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
              appGatewayName,
              'httpSettings'
            )
          }
        }
      }
    ]
    firewallPolicy: {
      id: wafPolicy.id
    }
  }
}

// ============================================================================
// Diagnostic Settings on Application Gateway
// ============================================================================

resource appGwDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-appgateway'
  scope: appGateway
  properties: {
    workspaceId: logWorkspace.id
    logs: [
      {
        category: 'ApplicationGatewayAccessLog'
        enabled: true
      }
      {
        category: 'ApplicationGatewayPerformanceLog'
        enabled: true
      }
      {
        category: 'ApplicationGatewayFirewallLog'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// ============================================================================
// Backend Compute — NICs, VMs, IIS
// ============================================================================

resource nics 'Microsoft.Network/networkInterfaces@2024-05-01' = [
  for i in range(0, 2): {
    name: 'nic-${vmNamePrefix}-${i}'
    location: location
    properties: {
      ipConfigurations: [
        {
          name: 'ipconfig1'
          properties: {
            privateIPAllocationMethod: 'Dynamic'
            subnet: {
              id: '${spokeVnet.id}/subnets/snet-workload'
            }
            applicationGatewayBackendAddressPools: [
              {
                id: '${appGateway.id}/backendAddressPools/backendPool'
              }
            ]
          }
        }
      ]
    }
  }
]

resource vms 'Microsoft.Compute/virtualMachines@2024-07-01' = [
  for i in range(0, 2): {
    name: '${vmNamePrefix}-${i}'
    location: location
    properties: {
      hardwareProfile: {
        vmSize: vmSize
      }
      osProfile: {
        computerName: '${vmNamePrefix}-${i}'
        adminUsername: adminUsername
        adminPassword: adminPassword
      }
      storageProfile: {
        imageReference: {
          publisher: 'MicrosoftWindowsServer'
          offer: 'WindowsServer'
          sku: '2022-datacenter-azure-edition'
          version: 'latest'
        }
        osDisk: {
          createOption: 'FromImage'
          managedDisk: {
            storageAccountType: 'StandardSSD_LRS'
          }
        }
      }
      networkProfile: {
        networkInterfaces: [
          {
            id: nics[i].id
          }
        ]
      }
    }
  }
]

resource vmExtensions 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = [
  for i in range(0, 2): {
    parent: vms[i]
    name: 'installIIS'
    location: location
    properties: {
      publisher: 'Microsoft.Compute'
      type: 'CustomScriptExtension'
      typeHandlerVersion: '1.10'
      autoUpgradeMinorVersion: true
      settings: {
        commandToExecute: 'powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path "C:\\inetpub\\wwwroot\\Default.htm" -Value $($env:computername)'
      }
    }
  }
]

// ============================================================================
// Azure Bastion (hub — Basic SKU, supports VNet peering)
// ============================================================================

resource pipBastion 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: bastionPipName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2024-05-01' = {
  name: bastionName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'bastionIpConfig'
        properties: {
          publicIPAddress: {
            id: pipBastion.id
          }
          subnet: {
            id: '${hubVnet.id}/subnets/AzureBastionSubnet'
          }
        }
      }
    ]
  }
}

// ============================================================================
// Azure Firewall Basic (conditional)
// ============================================================================

resource pipFirewall 'Microsoft.Network/publicIPAddresses@2024-05-01' = if (deployAzureFirewall) {
  name: firewallPipName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource pipFirewallMgmt 'Microsoft.Network/publicIPAddresses@2024-05-01' = if (deployAzureFirewall) {
  name: firewallMgmtPipName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2024-05-01' = if (deployAzureFirewall) {
  name: firewallPolicyName
  location: location
  properties: {
    sku: {
      tier: 'Basic'
    }
    threatIntelMode: 'Alert'
  }
}

resource firewallRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2024-05-01' = if (deployAzureFirewall) {
  parent: firewallPolicy
  name: 'DefaultNetworkRuleCollectionGroup'
  properties: {
    priority: 200
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'AllowOutbound'
        priority: 100
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'AllowHTTP'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              workloadSubnetPrefix
            ]
            destinationAddresses: [
              '*'
            ]
            destinationPorts: [
              '80'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'AllowHTTPS'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              workloadSubnetPrefix
            ]
            destinationAddresses: [
              '*'
            ]
            destinationPorts: [
              '443'
            ]
          }
        ]
      }
    ]
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2024-05-01' = if (deployAzureFirewall) {
  name: firewallName
  location: location
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Basic'
    }
    firewallPolicy: {
      id: firewallPolicy.id
    }
    ipConfigurations: [
      {
        name: 'fw-ipconfig'
        properties: {
          subnet: {
            id: '${hubVnet.id}/subnets/AzureFirewallSubnet'
          }
          publicIPAddress: {
            id: pipFirewall.id
          }
        }
      }
    ]
    managementIpConfiguration: {
      name: 'fw-mgmt-ipconfig'
      properties: {
        subnet: {
          id: '${hubVnet.id}/subnets/AzureFirewallManagementSubnet'
        }
        publicIPAddress: {
          id: pipFirewallMgmt.id
        }
      }
    }
  }
}

// ============================================================================
// Outputs
// ============================================================================

output appGatewayPublicIpAddress string = pipAppGw.properties.ipAddress
output bastionName string = bastion.name
output hubVnetName string = hubVnet.name
output spokeVnetName string = spokeVnet.name
