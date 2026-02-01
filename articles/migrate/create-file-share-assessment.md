---
title: Create a fileshare assessment
description: Learn how to create a Fileshare assessment using Azure Migrate.
author: ankitsurkar06
ms.author: ankitsurkar
ms.service: azure-migrate
ms.topic: concept-article
ms.reviewer: v-uhabiba
ms.date: 11/05/2024
# Customer intent: As a cloud architect, I want to create an application assessment using Azure Migrate, so that I can evaluate migration strategies, identify optimal targets, and understand the cost and readiness of my application workloads for the cloud transition.
---

# Create an Azure Files assessment

This article explains how to create Azure Files assessments for fileshares hosted on Windows and Linux servers. For details information on general Azure Migrate assessment concepts, see [assessment overview](concepts-assessment-overview.md). 

To quickly migrate your on-premises fileshares to Azure, create an Azure Files assessment to check readiness, cost, and get migration advice for your workloads. 

> [!Note]
> All assessments you create with Azure Migrate are a point-in-time snapshot of data. The assessment results are subject to change based on aggregated server performance data collected or change in the source configuration.  

## Prerequisites 

Before you start creating assessments, ensure you have discovered the inventory of your on-premises servers, and file shares hosted on these VMs, and you can view all the servers in the **All inventory** and **Infrastructure** tab. For more information about prerequisites, see [Prerequisites for assessments](assessment-prerequisites.md). 

Once you have discovered your servers and file shares, identify if you want to create an As-is on-premises assessment or Performance-based assessment. Check [Performance vs. As-is on-premises assessments](target-right-sizing.md) for more details.  

## Create an assessment 

To create an assessment, follow these steps:

1. Go to **Infrastructure** tab and select the Fileshares card on top.
1. Select all the shares you want to assess.
1. You can apply column based or custom tags-based filters to identify and add fileshares to the scope of your assessment. 
    After you have selected all the fileshares, select **Create assessment**.  
1. Provide a friendly name for the assessment. You see a query that you used to select the servers on the previous screen. Review the number of fileshares added and the query used before moving ahead. If you want to add more fileshares to the assessment, select **Add workloads**. Once you have added all the fileshares to the assessment scope, select **Next**. 
> [!Note]
> For accurate calculations servers hosting the selected fileshares and other colocated fileshares will be automatically added to the assessment scope.   
1. You can customize the assessment properties to fit your requirements. Specify the general properties for **Target region**, **Default environment**, **Pricing options**, **Saving options**, and **Sizing criteria**. [Learn more](assessment-report.md). 
1. Select **Next** to navigate to the Azure Files specific assessment properties.  
1. Select **Edit defaults**:
    1. To review and customize Azure Files-specific settings.  
1. Select **Save** if you customized any property.
1. In **Review + create assessment**, review the assessment details, and select **Create Assessment** to run the assessment. 
1. After the assessment is created, view the assessment in **Decide and plan** > **Assessments** > **Workloads**.  

## Next steps

- Learn how to use [dependency mapping](how-to-create-group-machine-dependencies.md) to create high confidence groups.
- [Learn more](concepts-assessment-calculation.md) about how assessments are calculated.
