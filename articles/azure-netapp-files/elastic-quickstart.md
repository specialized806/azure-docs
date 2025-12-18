---
title: 'Quickstart: Set up Azure NetApp Elastic zone-redundant storage'
description: Quickly understand the steps to set up an Azure NetApp Files account, capacity pool, delegated subnet, and virtual network on the Elastic zone-redundant storage level. 
author: b-ahibbard
ms.author: anfdocs
ms.service: azure-netapp-files
ms.topic: quickstart
ms.date: 09/10/2025
---

# Quickstart: Set up Azure NetApp Files Elastic zone-redundant storage (preview)

The Elastic zone-redundant service level offers a different approach to storage.

Ensure you've registered for [Elastic zone-redundant storage](elastic-account.md#register-for-the-elastic-zone-redundant-service-level).

## Register for NetApp Resource Provider

> [!NOTE]
> The registration process can take some time to complete.

# [Portal](#tab/azure-portal)

For registration steps using Portal, open a Cloud Shell session as indicated above and follow these Azure CLI steps:

[! INCLUDE [Azure NetApp Files CloudShell](./includes/azure-netapp-files-azure-cloud-shell-window.md)]

# [REST API](#tab/rest-api)

---

## Create a NetApp account

# [Portal](#tab/azure-portal)

1. In the Azure portal's search box, enter **Azure NetApp Files** and then select **Azure NetApp Files** from the list that appears.

      ![Select Azure NetApp Files](./media/azure-netapp-files-quickstart-set-up-account-create-volumes/azure-netapp-files-select-azure-netapp-files.png)

2. Select **+ Create** to create a new NetApp account.

[!INCLUDE [Create an Elastic zone-redundant account.](includes/elastic-account-create.md)]


# [REST API](#tab/rest-api)

1. Create a dedicated account for zone-redundant storage. Specify the `serviceTier` as `ZoneRedundant`.

```rest
POST https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.NetApp/elasticAccounts/{accountName}?api-version=2025-09-01-preview 
    { 
        "location": "<location>", 
        "properties": { 
            "serviceTier": "ZoneRedundant", 
        }
    } 
```



---

## Create a capacity pool 

# [Portal](#tab/azure-portal)

# [REST API](#tab/rest-api)

1. Create the capacity pool. You must indicate the service level and rank the order of availability zones for failover. The ranking is determined by the sequence in which you input the availability zones. In this example, the order is zone 2, 1, and 3.  

```rest
PUT https://management.azure.com/subscriptions/<subscription>/resourceGroups/<resource-group>/providers/Microsoft.NetApp/elasticAccounts/<account>/elasticCapacityPools/<pool-name>?api-version=2025-09-01-preview 
    {
        "location": "<location>", 
        "zones": ["2", "1", "3"] 
        "properties": { 
            "size": <size>, 
            "serviceLevel": "ZoneRedundant", 
            "qosType": "Auto", 
            "encryptionType": "single", 
            "subnetId": "/subscription/<subscriptionID>/resourceGroup/<group-name>/Microsoft.Network/virtualNetworks/<vnet-name>/subnets/<subnet-name>", 
        }
    }
```
---

## Create an NFS volume

# [Portal](#tab/azure-portal)

# [REST API](#tab/rest-api)

1. Send a PUT request to create the NFS volume: 

```rest
PUT https://management.azure.com/subscriptions/<subscription>/resourceGroups/<resource-group>/providers/Microsoft.NetApp/elasticAccounts/<account>/elasticcCapacityPools/<pool-name>/ealsticVolumes/<volume-name>?api-version=2025-09-01-preview 

{
    "location": "<location>", 
    "properties": { 
        "creationToken": "<file-path>", 
        "serviceLevel": "ZoneRedundant", 
        "networkFeatures": "Standard", 
        "subnetId": "/subscription/<subscriptionID>/resourceGroup/<group-name>/Microsoft.Network/virtualNetworks/<vnet-name>/subnets/<subnet-name", 
        "usageThreshhold": <size>, 
        "protocolTypes": "NFSv3", 
        "securityStyle": ""unix",  
        "unixPermissions": "0770" 
    }
} 
```
---

## Change the availability zone 

# [Portal](#tab/azure-portal)

# [REST API](#tab/rest-api)

1. Change the availability zone. 

```rest
PUT https://management.azure.com/subscriptions/<subscription>/resourceGroups/<resource-group>/providers/Microsoft.NetApp/elasticAccounts/<account>/elasticCapacityPools/<poolName>/changeZone?api-version=2025-09-01-preview 
    {
        "newZone": "<zoneNumber>",
    }
```

---


## Clean up resources

# [Portal](#tab/azure-portal)

# [REST API](#tab/rest-api)

---