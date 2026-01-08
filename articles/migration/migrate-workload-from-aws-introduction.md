---
title: Migrate a Workload from Amazon Web Services (AWS) to Azure - Introduction
description: Learn how to migrate a single workload from AWS to Azure
ms.author: rhackenberg
ai-usage: ai-assisted
ms.date: 11/24/2025
ms.topic: concept-article
ms.service: azure
ms.collection:
  - migration
  - aws-to-azure
---
# Migrate a Workload from Amazon Web Services (AWS) to Azure - Introduction

This article provides architects and engineers with actionable, prescriptive guidance to migrate a single workload from Amazon Web Services (AWS) to Azure. It covers the full migration lifecycle, from planning and preparation, execution and evaluation, to decommissioning of AWS resources.

Migrating a workload from AWS is a strategic initiative that requires careful planning and stakeholder alignment. This article focuses on workloads that range from simple to moderately complex and can benefit from a pragmatic migration strategy. 

## Workload migration strategy

A like-for-like workload migration strategy is the fastest path to Azure and has the least risk. This approach keeps the existing architecture and operational patterns. The goal is that the migrated workload meets the same key performance indicators (KPIs) on Azure as it did on AWS.
 
> [!TIP]
> Minimize changes during the migration and focus on validating performance and stability. Once the migration of your workload is completed, you can explore optimization.

## Recommended tools

Use AWS and Azure tools where appropriate to augment your migration process. These tools support upfront discovery, planning your Azure architecture (based on data gathered about your AWS workload), data and virtual machine (VM) transfer, post-migration validation and resource cleanup. For example, you can use [Workload Discovery on AWS](https://aws.amazon.com/solutions/implementations/workload-discovery-on-aws/) to speed up assessment, and you can use [Azure Migrate](/azure/migrate/tutorial-assess-aws) to assess AWS instances and provide sizing recommendations for Azure resources.

## Timeline assumptions

The migration of a workload can span several weeks or months. The duration depends on the complexity of the workload and your migration and cutover strategy. The timeline shows a typical workload migration for a moderately complex workload using a like-for-like approach. 

:::image type="content" source="./images/migrate-from-aws-phases.svg" alt-text="Diagram showing three phases of migrating workloads from AWS to Microsoft Azure. Across the top, three labeled boxes indicate phases with durations: Before migration (2–4 weeks), During migration (3–7 weeks), and After migration (1–2 weeks). Each box includes a summary of key activities such as planning, infrastructure setup, and optimization. Below, a horizontal sequence of five icons represents steps: Plan, Prepare, Execute, Optimize, and Decommission." lightbox="./images/migrate-from-aws-phases.svg" border="false":::

*Guidelines for a moderately complex workload.*

## Prerequisites

This article series is intended for cloud architects, platform engineers, and IT professionals responsible for migrating workloads from AWS to Azure. Before you begin migration planning and execution, ensure you have the following prerequisites in place:

- *Prior experience:* Prior experience with core cloud concepts, AWS and a basic understanding of Azure services and cloud migration processes.
- *Stakeholder alignment:* Share timelines, budget estimates, and project milestones with stakeholders to ensure that all parties are aligned.
- *Support strategy in place:* Purchase a Microsoft support plan and investigate options for free or community support.
- *Platform strategy in place:* This article series covers how to migrate a single workload. It assumes your platform foundation is in place and your migration strategy is defined and in alignment with the [Cloud Adoption Framework](/azure/cloud-adoption-framework/strategy).
- *Existing landing zone:* Ensure you have a robust landing zone in place and subscriptions, management groups, networks, governance policies are configured to receive the workload.
- *Invest in training or partner support:* Assess your team's Azure skills and plan for training or partner support as needed.

In addition to these measures, consider completing a [Migration Readiness Assessment](/assessments/Strategic-Migration-Assessment/). This assessment scores your readiness to migrate across 10 dimensions.

After the assessment, hold a kick-off workshop, including all stakeholders, to gather requirements and constraints and ensure buy-in.

To help with planning and successfully executing your workload migration, work through the following five phases:

> [!div class="checklist"]
> * [Plan](/azure/migration/migrate-workload-from-aws-plan)
> * [Prepare](/azure/migration/migrate-workload-from-aws-prepare)
> * [Execute](/azure/migration/migrate-workload-from-aws-execute)
> * [Evaluate](/azure/migration/migrate-workload-from-aws-evaluate)
> * [Decommission](/azure/migration/migrate-workload-from-aws-decommission)


Each phase includes detailed steps and checklists to guide you through the migration process.

## Next steps

> [!div class="nextstepaction"]
> [Plan your workload migration](./migrate-workload-from-aws-plan.md)