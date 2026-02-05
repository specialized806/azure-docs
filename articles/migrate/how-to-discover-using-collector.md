---
title: Discovery using Azure Migrate Collector
description: User guide for Azure Migrate Collector to discover VMware servers and workloads, upload data to Azure Migrate, and generate business case and assessment reports.
author: molishv
ms.author: molir
ms.manager: ronai
ms.service: azure-migrate
ms.topic: how-to
ms.reviewer: v-uhabiba
ms.date: 06/02/2026
ms.custom: engagement-fy26
# Customer intent: As an IT professional, I want to use Azure Migrate Collector to discover my IT estate and generate reports, so I can plan migration and modernization efficiently.
---

# Discover servers & workloads using Azure Migrate collector

This article explains how to use Azure Migrate collector to discover servers and workloads running in your IT estate. The collected inventory data can be used to generate quick business case and perf-based assessment reports to support lift & shift migration and modernization of your IT estate. 
You can deploy Azure Migrate collector in any supported version of Windows Server Machine that has network line of sight to vCenter to discover servers, performance data, software running on the servers, SQL Server, and PostgreSQL database instances and Web apps (.NET on IIS and Java on Tomcat). The Azure Migrate Collector doesn't require connectivity to Azure, helping customers save time typically spent on obtaining networking and Azure access approvals. It allows customers to flexibly scan their IT estate locally and upload the data securely on their own terms. Azure Migrate collector can be used to discover VMware estate or discover individual Windows and Linux servers running in any Hypervisor or public cloud. 


## Collect data from VMware estate

### Prerequisites

Before you set up the collector, create a new Azure Migrate project.

| Requirement | Details |
|---|---|
| Operating System | A server running Windows Server 2019, Windows Server 2022, or Windows Server 2025 Operating System. |
| Compute and storage | A server with 16 GB of RAM, 8 vCPUs, and approximately 80 GB of disk storage. |
| Supported vCenter versions | 8.0, 7.0, 6.7, 6.5, 6.0, or 5.5. |
| Networking - vCenter | Network line of sight from collector to vCenter with inbound access allowed on TCP port 443. <br><br> If the server running vCenter Server listens on a different port, you can modify the port when you provide the vCenter Server details in the collector configuration manager. |
| Networking – ESXi hosts | Network line of sight from collector to all ESXi hosts with inbound access allowed on TCP port 443. |
| Networking – Windows/Linux | To collect data about installed software, webapps and database (SQL, MySQL, PostgreSQL) inventory, network line of sight isn't required from collector to guest machines. Collector captures guest data using the following ports via VMware pipe. <br><br> Windows - WinRM https (5986) or http (5985) <br> Linux - SSH over port 22 |
| SQL | For deeper discovery of SQL readiness data, network line of sight is required from collector to SQL instances. SQL metadata is collected using TCP connection to SQL instances over custom port. |
| vCenter statistical level | Verify Performance Statistics Level in vCenter is set to Level 1 or above: <br> Level 1: CPU and memory metrics only. (recommended) <br> Level 2: CPU, memory, disk, and network metrics. <br> Disabled: No historical data; only real-time data is collected. <br><br> If the level is disabled, change it to level 1 or above and wait for 24 hours before starting data collection using collector. |

### Prepare vCenter, guest & database accounts 
| Account | Permissions | Purpose |
|---|---|---|
| vCenter account | Read only and guest operations | To collect server configurations & performance data of VMware machines. |
| Windows | Domain account or administrator* account | To collect installed software, SQL & PostgreSQL database instance and web apps data. |
| Linux | Root account* | To collect installed software, SQL & PostgreSQL database instance and web apps data. |
| Domain | Domain account with SQL permissions | To collect SQL readiness data |

Note: *You can set up custom least privileged Windows, Linux, and SQL accounts by referring this article. 

### Download Azure Migrate Collector

1.	From Azure Migrate project, select Discover -> using Collector and select Download.  
2.	You can also download the Azure Migrate collector installer script directly using this link: https://aka.ms/Migrate/DownloadCollector 
3.	Extract the installer zip file to a folder on the server that hosts the Azure Migrate collector.

### Run the installer script

1. Launch PowerShell with administrative privileges on the host server.
2. Change directory to the extracted folder.
3. Run the installer script:
   
   ```pwsh
   .\DisconnectedApplianceInstaller.ps1
   ```

4. During the first installation of the script, select fresh option f.
5.	When upgrading the collector to the new versions, select update option u.  
6. The installer script:
   - Installs agents and web applications.
   - Enables Windows features: Windows Activation Service, Web-Server, Web-Mgmt-Service.
   - Updates a registry key (HKLM) with persistent setting details for Azure Migrate.
   - Creates files:
     - Config: `%ProgramData%\Microsoft Azure\Config`
     - Logs: `%ProgramData%\Microsoft Azure\OfflineData`

7.  After successful execution, the appliance configuration manager launches automatically and a desktop shortcut is created.

### Provide vCenter credentials

1.	In Step 1: Select Add credentials to enter a name for the credentials. Add the username and password for the vCenter Server account that the collector will use to discover servers running on vCenter Server.
2.	If you want to add multiple credentials at once, select Add more to save and add more credentials. Multiple credentials are supported for discovery of servers across multiple vCenter Servers using a single collector.
3.	In Step 2: Provide vCenter Server details, select Add discovery source to add the IP address or FQDN of a vCenter Server. You can leave the port as the default (443) or specify a custom port on which vCenter Server listens. Select the friendly name for credentials you would like to map to the vCenter Server and select Save.
4.	Select Add more to save the previous details and add more vCenter Server details. You can add up to 10 vCenter Servers per collector.

### Provide guest and database credentials

1.	Refer security best practices to set up least privileged accounts to set up least privileged accounts. 
2.	Provide Windows & Linux guest accounts to collect data about installed software, database instances and web apps. Provide SQL credentials (Windows or SQL server authentication) to collect SQL suitability data. 
3.	Verify the guest credentials by validating against a target server. 
4.	Enable the checkbox to validate credential. 
5.	Select the vCenter and select up to 5 virtual machines from the drop down.
6.	Click on validate.   
7.	If the credentials are not valid, fix the errors by following the recommendation step before triggering data collection. 
8.	If the credentials are successfully validated, guest discovery of installed software, inventory of database instance on the machines will be successful. 
> [!NOTE]
> - For the collection of data about installed software, web apps and for identifying SQL/PostgreSQL server instances, collector doesn’t need network line of sight to guest machines. The guest data collection is done via the ESXi hosts using the installed VMware tools. However, for collecting readiness data directly from database instances, collector must have network line of sight to the target SQL server instances. 
> - Identifying server dependencies and in-depth discovery of MySQL/PostgreSQL instances using MySQL/PostgreSQL accounts are not supported in this version of Collector.

## Collect data from physical servers: 
The same Azure migrate collector can be used to discover both VMware machines and physical servers that’s hypervisor agnostic. To collect data about physical servers, switch the fabric type at the top to physical. 

### Provide credentials for Windows & Linux servers:
1. Provide credentials for discovery of Windows and Linux physical or virtual servers, select Add credentials.
2. For a Windows server:
    Select the source type as Windows Server.
    Enter a friendly name for the credentials.
    Add the username and password.
    Select Save.
3. If you use password-based authentication for a Linux server, select the source type as Linux Server (Password-based).
    Enter a friendly name for the credentials.
    Add the username and password, and then select Save.
4. If you use SSH key-based authentication for a Linux server:
    Select the source type as Linux Server (SSH key-based).
    Enter a friendly name for the credentials.
    Add the username.
    Browse and select the SSH private key file.
    Select Save.

> [!NOTE]
> -Azure Migrate supports SSH private keys created using the ssh-keygen command with RSA, DSA, ECDSA, and ed25519 algorithms.
> -It does not support SSH keys with a passphrase. Use a key without a passphrase.
> -It does not support SSH private key files created by PuTTY.
> -It supports SSH private key files in OpenSSH format.
> -To add multiple credentials at once, select Add more to save and enter more credentials. 

### Provide Windows and Linux server details:
1.	Provide physical or virtual server details.
2.	Select Add discovery source to enter the server IP address or FQDN and the friendly name for the credentials used to connect to the server.
3.	The appliance uses WinRM port 5986 (HTTPS) by default to communicate with Windows servers, and port 22 (TCP) for Linux servers.
4.	If the target Hyper-V servers do not have HTTPS prerequisites set up, the appliance switches to WinRM port 5985 (HTTP).
5.	You can Add single item at a time or Add multiple items together. You can also provide server details through Import a CSV file.
6.	If you choose Add single item, select the OS type.
7.	Enter a friendly name for the credentials, add the server IP address or FQDN.
8.	Select Save.
9.	If you choose Add multiple items, enter multiple records at once by specifying the server IP address or FQDN.
10.	Enter the friendly name for the credentials in the text box.
11.	Verify the records and then select Save.
12.	If you choose Import CSV (this is selected by default), download the CSV template file.
13.	Fill it with the server IP address or FQDN.
14.	Enter the friendly name for the credentials. Then import the file into the appliance.
15.	Verify the records, and then select Save.
16.	When you select Save, the collector validates the connection to the added servers and shows the Validation status in the table next to each server.
17.	If validation fails for a server, you can review the error by selecting Validation failed in the Status column. Fix the issue and validate again.
18.	To remove a server, select Delete.
19.	You can revalidate the connectivity to servers any time before you start the data collection.
20.	Before you start data collection, you can turn off the slider to skip software inventory on the added servers. You can change this option at any time.
21.	To discover SQL Server instances and databases, you add extra credentials (Windows domain, non-domain, or SQL authentication). The appliance then tries to automatically map these credentials to the SQL servers. If you add domain credentials, the appliance authenticates them with the domain’s Active Directory to prevent user account lockouts. To check if the domain credentials are valid, follow these steps:
22.	In the configuration manager credentials table, you see the Validation status for domain credentials. Only domain credentials are validated.
23.	If you use domain accounts, the username must be in Down-Level format (domain\username). The UPN format (username@domain.com) isn't supported.
24.	If validation fails, you can select the Failed status to view the error. Fix the issue, and then select Revalidate credentials to try again.


### Start data collection

> [!IMPORTANT]
> Ensure you are using the latest version of Collector before starting data collection.

1. After adding all credentials, select **Start Data Collection**.
2. After validating vCenter credentials, if you skip adding any guest or DB credentials, **Start Data Collection** is disabled. To proceed, disable the **Guest discovery** toggle.
3. After starting data collection, it may take 2–4 hours depending on environment scale and number of credentials.
4. Track progress in the collection progress bar.
5. After completion, a summary of data collection is displayed.

### Review collected data

1. Review the summary to understand status and proportion of machines/workloads that failed.
2. Download the CSV file to review detailed error messages per server.
3. Diagnose errors by fixing network access issues, modifying user privileges, or adding new credentials.
4. After resolving issues, select **Start Data Collection** to run again.

### Collect incremental data

1. After addressing issues, enable **Incremental data** to attempt collection only on workloads where previous attempts failed.
2. When enabled, VMware configuration and performance data collection is skipped. Software inventory, databases, and webapps collections are attempted on previously failed workloads.
3. If disabled, full data collection runs.

### Export collected data

1. After successful data collection, export the collected data by generating a ZIP file.
2. Select **Export**. A ZIP file is created at: `C:\ProgramData\Microsoft Azure\OfflineData\Azure-Migrate-Discovery-YYYY-MM-DD-HH-MM-SS.zip`.

## Upload the collected data to an Azure Migrate project
1.	Refer this article to create a new Azure Migrate project. Inventory Import from collector is supported only for newly created projects. 
2.	Once the project is created, select start discovery using collector option. 

### Import the zip file generated using collector

1.	Click Browse and select the ZIP file exported from your collector.
2.	Once you have selected the right file, click on import. 
3.	You will be able to see the import status as it proceeds. 

> [!NOTE]
> Discovery may take up to 30 minutes. Keep the page open until import completes.

### Create business cases and assessments

1. After upload is successful, create business cases and assessments.
2. Wait 45 minutes after successful upload before creating a business case or assessment to ensure all discovery data is updated.

### Import more inventory

1.	If you wish to discover more inventory with the Azure migrate collector after your initial import, follow these steps to add the new data to your Azure Migrate project:
2.	Navigate to “All inventory” view. You will be able to see your existing discovery data here.
3.	Click on the “Discover” option at the top and select “Using collector”. 
4.	You will be able to navigate to the import page. 
5.	Select “Azure migrate collector (ZIP)” in the file type dropdown
6.	Click Browse and select the ZIP file exported from your collector.
7.	Once you have selected the right file, click on import to ingest the file. 
8.	Multiple zip files of different hypervisor type (VMware, physical) can be imported to the same project. 

