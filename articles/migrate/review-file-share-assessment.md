---
title: Review an Azure Files assessment
description: Review the Azure Files assessment created using Azure Migrate.
author: ankitsurkar06
ms.author: ankitsurkar
ms.service: azure-migrate
ms.topic: concept-article
ms.reviewer: v-uhabiba
ms.date: 11/05/2024
monikerRange:
# Customer intent: As a migration planner, I want to conduct an Azure Files assessment for my Fileshares, so that I can determine the best migration strategies and prepare for a successful transition to Azure.
---

# Review a Azure Files assessment

This article describes the various components of a Fileshare assessment and how you can review the assessment after it is created. 

## Overview

An Azure Migrate assessment evaluates your on-premises workloads or workloads hosted on other public clouds for migration to Azure, analyzing Azure readiness for different Azure targets, right-sizing, and cost. The Azure Files assessment enables you to assess all the Fileshare and identify a strategy to migrate them to Azure Files on Azure. Use this article for a guided walkthrough of a Fileshare assessment.  

## Review an assessment

To review an Azure Files assessment, follow the steps: 

1. On the Azure Migrate project **Overview** page, under **Decide and Plan**, select **Assessments**.

   ![Screenshot of Overview page.](./media/review-application-assessment/overview.png)
   
1. Search for the assessment with the **Workloads** filter and select it.

   ![Screenshot of list of assessments.](./media/review-application-assessment/assessments.png)

1. Review the **Overview** page to get the summary of assessed Fileshares and different migration paths. You can check the recommended migration path that is selected based on your migration preference.  
      :::image type="content" source="./media/review-fileshare-assessment/fileshare-assessment-overview.jpg" alt-text="The screenshot that shows where the user can start with application assessment review." lightbox="./media/review-fileshare-assessment/fileshare-assessment-overview.jpg":::

## Migration Scenarios
   Migration scenarios include the various migration paths a customer can choose to complete the migration of the assessed file shares. You can review the readiness for target deployment types and the cost estimates for assessed shares that are marked ready or ready with conditions: 

**Recommended path**

Choosing a Microsoft-recommended target minimizes your migration effort. If your file share instance supports both Azure Files and on share on Azure VM, the most cost-effective and migration-ready option is recommended. This includes readiness checks and monthly cost estimates for instances marked as Ready or Ready with conditions. The recommended path is set to ‘Modernize’ by default to always prefer and assess for PaaS services wherever possible. 
:::image type="content" source="./media/review-fileshare-assessment/recommended-path.jpg" alt-text="The screenshot that shows where the user can start with recommended path review." lightbox="./media/review-fileshare-assessment/recomended-path.jpg":::

You can use this path to: 

- Review the best recommended path, readiness states, cost estimates and suggested configurations for Azure Files or Azure VMs or a combination of both. 

- Understand details around migration issues, warnings that you can remediate before migration to the different Azure Files share.  

> [!Note]
> In the image above, the recommended deployment strategy for the demo-assessment2 workloads is migrating to Azure Files since all shares have been successfully assessed without any issues along with cost benefits.  
> Azure migrate will always try to provide a successful migration path for all chosen shares. 
> If we encounter an error during assessment either for the share volume or size estimations, we will count the file share and all the other collocated shares of that server for an Azure VM migration path. 

**Migrate all files shares to Azure Files** 
In this strategy, you can see the readiness and cost estimates for migrating to Azure Files shares. You will also be able to details for each of the shares, its sources, target recommendations and monthly cost. 
:::image type="content" source="./media/review-fileshare-assessment/to-azure-files.jpg" alt-text="The screenshot that shows where the user can start with Azure Files path review." lightbox="./media/review-fileshare-assessment/to-azure-files.jpg":::

You can select on ‘View details’ to see: 
- Various readiness states of each of the file shares 
- Source servers hosting such instances 
- Monthly cost 
- Target azure service SKU 
- Top file shares by used capacity and  

:::image type="content" source="./media/review-fileshare-assessment/view-assessment-details.jpg" alt-text="The screenshot that shows where the user can check the assessment details." lightbox="./media/review-fileshare-assessment/view-assessment-details.jpg":::

A further drill down view provides you with the details of readiness states, source properties and target recommendations. 

:::image type="content" source="./media/review-fileshare-assessment/instance-level-details.jpg" alt-text="The screenshot that shows where the user can check the path details." lightbox="./media/review-fileshare-assessment/instance-level-details.jpg":::

**Migrate all shares to Azure VM** 
In this strategy, you can see how you can rehost all the shares on Azure VM. You will be able to review the readiness and cost estimates. The readiness and sizing logic is similar to Azure VM assessment type. 

This assessment accounts for all the shares on a server to a suitable size Azure VM. This includes: 
- Server readiness state 
- VM SKU 
- Total monthly cost (compute, storage, security) 

:::image type="content" source="./media/review-fileshare-assessment/azfiles-vm-details.jpg" alt-text="The screenshot that shows where the user can check the path details." lightbox="./media/review-fileshare-assessment/azfiles-vm-details.jpg":::


**Migration Issues** 
1. Fileshare size is 0: In case the fileshare size is 0 the target recommendation is not given for that fileshares. It is recommended to check if the fileshares still exist on the on-premises servers. 

1. Fileshare size exceeds maximum size: In case the on-premises fileshare size is greater than 200TB, it cannot be migrated to Azure as the maximum fileshare size supported by Azure Files is 200GB. It is recommended to distribute the fileshare data in multiple fileshares. 

