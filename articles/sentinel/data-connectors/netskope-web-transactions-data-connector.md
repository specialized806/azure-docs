---
title: "Netskope Web Transactions Data Connector (using Azure Functions) connector for Microsoft Sentinel"
description: "Learn how to install the connector Netskope Web Transactions Data Connector (using Azure Functions) to connect your data source to Microsoft Sentinel."
author: cwatson-cat
ms.topic: generated-reference
ms.date: 05/30/2024
ms.service: microsoft-sentinel
ms.author: cwatson
ms.collection: sentinel-data-connector
---

# Netskope Web Transactions Data Connector (using Azure Functions) connector for Microsoft Sentinel

The [Netskope Web Transactions](https://docs.netskope.com/en/netskope-help/data-security/transaction-events/netskope-transaction-events/) data connector provides the functionality of a docker image to pull the Netskope Web Transactions data from google pubsublite, process the data and ingest the processed data to Log Analytics. As part of this data connector two tables will be formed in Log Analytics, one for Web Transactions data and other for errors encountered during execution.


 For more details related to Web Transactions refer to the below documentation: 
[Netskope Web Transactions documentation](https://docs.netskope.com/en/netskope-help/data-security/transaction-events/netskope-transaction-events/) 


This is autogenerated content. For changes, contact the solution provider.

## Connector attributes

| Connector attribute | Description |
| --- | --- |
| **Log Analytics table(s)** | NetskopeWebtxData_CL<br/> NetskopeWebtxErrors_CL<br/> |
| **Data collection rules support** | Not currently supported |
| **Supported by** | [Netskope](https://www.netskope.com/services#support) |

## Query samples

**Netskope Web Transactions Data**

   ```kusto
NetskopeWebtxData_CL
 
   | sort by TimeGenerated desc
   ```

**Netskope Web Transactions Data Connector Errors**

   ```kusto
NetskopeWebtxErrors_CL
 
   | sort by TimeGenerated desc
   ```



## Prerequisites

To integrate with Netskope Web Transactions Data Connector (using Azure Functions) make sure you have: 

- **Azure Subscription**: Azure Subscription with owner role is required to register an application in Microsoft Entra ID and assign role of contributor to app in resource group.
- **Microsoft.Compute permissions**: Read and write permissions to Azure VMs is required. [See the documentation to learn more about Azure VMs](/azure/virtual-machines/overview).
- **TransactionEvents Credentials and Permissions**: **Netskope Tenant** and **Netskope API Token** is required. [See the documentation to learn more about Transaction Events.](https://docs.netskope.com/en/netskope-help/data-security/transaction-events/netskope-transaction-events/)
- **Microsoft.Web/sites permissions**: Read and write permissions to Azure Functions to create a Function App is required. [See the documentation to learn more about Azure Functions](/azure/azure-functions/).


## Vendor installation instructions


> [!NOTE]
   >  This connector provides the functionality of ingesting Netskope Web Transactions data using a docker image to be deployed on a virtual machine (Either Azure VM/On Premise VM). Check the [Azure VM pricing page](https://azure.microsoft.com/pricing/details/virtual-machines/linux) for details.


**(Optional Step)** Securely store workspace and API authorization key(s) or token(s) in Azure Key Vault. Azure Key Vault provides a secure mechanism to store and retrieve key values. [Follow these instructions](/azure/app-service/app-service-key-vault-references) to use Azure Key Vault with an Azure Function App.


**STEP 1 - Steps to create/get Credentials for the Netskope account** 

 Follow the steps in this section to create/get **Netskope Hostname** and **Netskope API Token**:
 1. Login to your **Netskope Tenant** and go to the **Settings menu** on the left navigation bar.
 2. Click on Tools and then **REST API v2**
 3. Now, click on the new token button. Then it will ask for token name, expiration duration and the endpoints that you want to fetch data from.
 5. Once that is done click the save button, the token will be generated. Copy the token and save at a secure place for further usage.


**STEP 2 - Choose one from the following two deployment options to deploy the docker based data connector to ingest Netskope Web Transactions data **

**IMPORTANT:** Before deploying Netskope data connector, have the Workspace ID and Workspace Primary Key (can be copied from the following) readily available, as well as the Netskope API Authorization Key(s) [Make sure the token has permissions for transaction events].



Option 1 - Using Azure Resource Manager (ARM) Template to deploy VM [Recommended]

Using the ARM template deploy an Azure VM, install the prerequisites and start execution.

1. Click the **Deploy to Azure** button below. 

	[![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://aka.ms/sentinel-NetskopeV2WebTransactions-azuredeploy)
2. Select the preferred **Subscription**, **Resource Group** and **Location**. 
3. Enter the below information : 
	- Docker Image Name (mgulledge/netskope-microsoft-sentinel-plugin:netskopewebtransactions)
	- Netskope HostName 
	- Netskope API Token 
	- Seek Timestamp (The epoch timestamp that you want to seek the pubsublite pointer, can be left empty) 
	- Workspace ID 
	- Workspace Key 
	- Backoff Retry Count (The retry count for token related errors before restarting the execution.)  
	- Backoff Sleep Time (Number of seconds to sleep before retrying) 
	- Idle Timeout (Number of seconds to wait for Web Transactions Data before restarting execution) 
	- VM Name 
	- Authentication Type 
	- Admin Password or Key 
	- DNS Label Prefix 
	- Ubuntu OS Version 
	- Location 
	- VM Size 
	- Subnet Name 
	- Network Security Group Name 
	- Security Type 
4. Click on **Review+Create**. 
5. Then after validation click on **Create** to deploy.

Option 2 - Manual Deployment on previously created virtual machine

Use the following step-by-step instructions to deploy the docker based data connector manually on a previously created virtual machine.


**1. Install docker and pull docker Image**

**NOTE:** Make sure that the VM is linux based (preferably Ubuntu).

1. Firstly you will need to [SSH into the virtual machine](/azure/virtual-machines/linux-vm-connect?tabs=Linux).
2. Now install [docker engine](https://docs.docker.com/engine/install/).
3. Now pull the docker image from docker hub using the command: 'sudo docker pull mgulledge/netskope-microsoft-sentinel-plugin:netskopewebtransactions'.
4. Now to run the docker image use the command: `sudo docker run -it -v $(pwd)/docker_persistent_volume:/app mgulledge/netskope-microsoft-sentinel-plugin:netskopewebtransactions`. You can replace `mgulledge/netskope-microsoft-sentinel-plugin:netskopewebtransactions` with the image id. Here `docker_persistent_volume` is the name of the folder that would be created on the vm in which the files will get stored.


**2. Configure the Parameters**

1. Once the docker image is running it will ask for the required parameters.
2. Add each of the following application settings individually, with their respective values (case-sensitive): 
	- Netskope HostName 
	- Netskope API Token 
	- Seek Timestamp (The epoch timestamp that you want to seek the pubsublite pointer, can be left empty) 
	- Workspace ID 
	- Workspace Key 
	- Backoff Retry Count (The retry count for token related errors before restarting the execution.)  
	- Backoff Sleep Time (Number of seconds to sleep before retrying) 
	- Idle Timeout (Number of seconds to wait for Web Transactions Data before restarting execution)
3. Now the execution has started but is in interactive mode, so that shell cannot be stopped. To run it as a background process, stop the current execution by pressing Ctrl+C and then use the command: `sudo docker run -d -v $(pwd)/docker_persistent_volume:/app mgulledge/netskope-microsoft-sentinel-plugin:netskopewebtransactions`


**3. Stop the docker container**

1. Use the command `sudo docker container ps` to list the running docker containers. Note down your container id.
2. Now stop the container using the command: `sudo docker stop *<*container-id*>*`



## Next steps

For more information, go to the [related solution](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/netskope.netskope-for-azure?tab=Overview) in the Azure Marketplace.
