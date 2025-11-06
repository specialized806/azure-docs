---
title: Azure Change Tracking and Inventory overview using Azure Monitoring Agent
description: Learn about Change Tracking and Inventory feature using Azure monitoring agent, which helps you identify software and Microsoft service changes in your environment.
#customer intent: As a customer, I want to evaluate the compatibility of Azure Change Tracking and Inventory with my existing infrastructure so that I can ensure seamless integration.
services: automation
ms.date: 11/03/2025
ms.topic: overview
ms.service: azure-change-tracking-inventory
ms.author: v-jasmineme
author: jasminemehndir
---

# About Azure Change Tracking and Inventory

This article provides an overview of Azure Change Tracking and Inventory (CTI) using Azure Monitoring Agent (AMA). This article also includes the key features and benefits of the service.

## What is Change Tracking and Inventory

Azure CTI service enhances the auditing and governance for in-guest operations by monitoring changes and providing detailed inventory logs for servers across Azure, on-premises, and other cloud environments.

> [!IMPORTANT]
> We recommend that you use Azure CTI with the Change tracking extension version 2.20.0.0 or later.

**Change Tracking:**

- Monitors changes, including modifications to files, registry keys, software installations, and Windows services or Linux daemons.</br>
- Provides detailed logs of what and when the changes were made, enabling you to quickly detect configuration drifts or unauthorized changes. </br>
Change Tracking metadata will get ingested into the *ConfigurationChange* table in the connected LA workspace. [Learn more](/azure/azure-monitor/reference/tables/configurationchange).

> [!NOTE]
> Azure CTI data is logged for both system-level and user-level applications. System-level data is always logged, but user-level applications appear only when a user logs into a machine; if the user logs out, those applications are marked as *Removed*.

**Inventory:**

- Collects and maintains an updated list of installed software, operating system details, and other server configurations in linked LA workspace. </br>
Helps create an overview of system assets, which is useful for compliance, audits, and proactive maintenance.</br>
Inventory metadata will get ingested into the *ConfigurationData* table in the connected LA workspace. [Learn more](/azure/azure-monitor/reference/tables/configurationdata).

## Key benefits of Azure Change Tracking and Inventory

Here are the key benefits:

- **Compatibility with the unified monitoring agent** – Compatible with the [Azure Monitor Agent](/azure/azure-monitor/agents/agents-overview) that enhances security, reliability, and facilitates multi-homing experience to store data.
- **Compatibility with tracking tool** – Compatible with the Change tracking (CT) extension deployed through the Azure Policy on the client's virtual machine. You can switch to AMA, and then the CT extension pushes the software, files, and registry to AMA.
- **Multi-homing experience** – Provides standardization of management from one central workspace. You can [transition from Log Analytics (LA) to AMA](/azure/azure-monitor/agents/azure-monitor-agent-migration) so that all VMs point to a single workspace for data collection and maintenance.
- **Rules management** – Uses [Data Collection Rules](/azure/azure-monitor/essentials/data-collection-rule-overview) to configure or customize various aspects of data collection. For example, you can change the frequency of file collection.

For information on supported operating systems, see [support matrix](../azure-change-tracking-inventory/change-tracking-inventory-support-matrix.md) for Azure CTI.

## Next steps

Review [support matrix](../azure-change-tracking-inventory/change-tracking-inventory-support-matrix.md) for Azure CTI.
