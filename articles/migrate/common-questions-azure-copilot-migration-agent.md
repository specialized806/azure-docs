---
title: Common Questions About Azure Copilot Migration Agent
description: Get answers to common questions for Azure Copilot Migration Agent.
author: piyushdhore-microsoft
ms.author: piyushdhore
ms.manager: vijain
ms.service: azure-migrate
ms.topic: concept-article
ms.date: 02/07/2025
ms.reviewer: v-uhabiba
ms.custom: engagement-fy25
monikerRange: migrate 
# Customer intent: "To understand how Azure Copilot Migration Agent works, what data it uses, how customer data is handled, and whether the service is safe, compliant, and trustworthy to use during migration planning."
---

# Azure Copilot Migration Agent (preview): Common questions

Azure Copilot Migration Agent (AMCA) is built with Microsoft’s Responsible AI principles. This article answers common questions about the **Azure Copilot Migration Agent**. 

## What is the Azure Copilot Migration Agent?

Azure Copilot Migration Agent is a Copilot-powered, conversational experience designed to help customers plan, analyze, and reason about cloud migrations by using data from Azure Migrate.

## What data does the Migration Agent access and process? 

The Migration Agent accesses only data necessary for migration guidance, such as infrastructure metadata and chat inputs. The Agent doesn't access external customer data sources outside the Azure Migrate project.

## Does the Migration Agent store my prompts, responses, or migration data? 

Yes. Prompts, responses, and related data are stored to provide contextual responses. Data is isolated per user.  

## How is my data used within the Migration Agent? 

Data is used only for migration recommendations, assessments, and business case analysis. It is not used for profiling or unrelated purposes.  

## Who can access my data? 

Only users with appropriate Azure role-based access can access the data. Microsoft Support may access the data only with explicit permission.  

## Is my data used to train Microsoft’s AI models? 

No. The Migration Agent doesn't use your data to train Microsoft’s AI models. 

## How does ACMA ensure responsible and ethical AI use? 

The Migration Agent follows Microsoft’s Responsible AI principles and is regularly evaluated for safety and relevance. 

## Can I opt out of data collection or storage? 

You can opt out by leaving the preview or contacting Microsoft Support to request data deletion.  

## How is feedback collected and used? 

Feedback (thumbs up/down) is collected where permitted by your organization. Feedback is used only to improve the tool, isn't linked to users unless consented, and isn't used for advertising or external analytics.  

## Does the Azure Copilot Migration Agent process data outside my selected geography?  

For EU customers, both processing and storage of migration‑related data occur within EU regions. 

For all other geographies, Azure Copilot Migration Agent may process and store migration‑related data in any Azure region, depending on service architecture and optimization. This applies only to Azure Migrate related conversational data used by the Agent.  

Azure Migrate project data such as discovery metadata, assessment metadata, and project configuration is always stored in a region within the geography that you selected when creating the project. Azure Migrate doesn't move or store customer data outside of the region allocated, guaranteeing data residency and resiliency in the same geography. [Learn more](resources-faq.md#what-does-azure-migrate-do-to-ensure-data-residency).