---
title: Migrate a Workload from Amazon Web Services (AWS) to Azure - Introduction
description: Learn how to migrate a single workload from AWS to Azure. Plan, prepare, run, evaluate, and decommission your previous workload with minimal risk.
ms.author: rhackenberg
ai-usage: ai-assisted
ms.date: 01/29/2026
ms.topic: concept-article
ms.custom: migration-hub
ms.service: azure
ms.collection:
  - migration
  - aws-to-azure
---
# Migrate a workload from Amazon Web Services (AWS) to Azure - Introduction

This article series provides architects and engineers with actionable, prescriptive guidance to migrate a single workload from Amazon Web Services (AWS) to Azure. It covers the full migration life cycle, from planning and preparation to execution and evaluation and the decommissioning of AWS resources.

This article series focuses on workloads that range from simple to moderately complex and are mostly independent from other workloads in your organization. It doesn't cover mission-critical workloads.

Migrating a workload from AWS is a strategic initiative that requires careful planning and stakeholder alignment. Without a solid migration plan and proper preparation, you risk introducing undesired disruption, which can erode confidence in your workload.

## Workload migration strategy

A like-for-like workload migration strategy minimizes risk and is typically the safest path to Azure. When you take this approach, the workload continues to use existing architecture and operational patterns. Migrations are most successful when they avoid scope creep, such as paying existing technical debt or introducing optimizations during the workload hosting transition. The goal is that the migrated workload meets the same key performance indicators (KPIs) on Azure as it did on AWS. It should maintain the same service-level agreements (SLAs), service-level objectives (SLOs), and bugs that exist currently in the workload.
 
> [!TIP]
> Minimize changes during the migration and focus on validating performance and stability. After you finish the migration of your workload, you can explore technical debt repayment and further optimizations.

## Recommended tools

Use AWS and Azure tools where appropriate to augment your migration process. These tools support the following tasks:

- Upfront discovery
- Planning your Azure architecture based on data gathered about your AWS workload
- Data and compute platform transfer
- Post-migration validation
- Resource cleanup

Use [Workload Discovery on AWS](https://aws.amazon.com/solutions/implementations/workload-discovery-on-aws/) to assess your workload. You can combine AWS tooling with Azure tooling, like [Azure Migrate](/azure/migrate/tutorial-assess-aws), to assess AWS instances and provide sizing recommendations for Azure resources. Optionally, you can explore non-Microsoft solutions, like [Dr Migrate](https://marketplace.microsoft.com/en-us/product/altratechnologiesptyltd1719876965699.altra_dr_migrate_express_saas) or [CAST highlight](https://marketplace.microsoft.com/en-us/product/saas/cast.cast_highlight), to assist with code analysis, dependency mapping, and migration readiness assessments.

## Timeline assumptions

The migration of a workload can span several weeks or months. The duration depends on the complexity of the workload and your migration and cutover strategy. The following timeline shows a typical workload migration that uses a like-for-like approach for a moderately complex workload. A moderately complex workload typically includes multiple components and dependencies, but it isn't mission-critical and doesn't integrate deeply with other systems.

:::image type="complex" source="./images/migrate-from-aws-phases.svg" alt-text="Diagram that shows three phases of workload migration." lightbox="./images/migrate-from-aws-phases.svg" border="false":::
    The diagram shows three phases of workload migration from AWS to Azure. Across the top, three labeled boxes indicate the following phases and durations: before migration (two to four weeks), during migration (three to seven weeks), and after migration (one to two weeks). Each box includes a summary of key activities, like planning, infrastructure setup, and optimization. Underneath the boxes, a horizontal sequence of five icons represents the plan, prepare, execute, evaluate, and decommission steps.
:::image-end:::

## Workload team responsibility

The team currently responsible for the workload in AWS is typically also responsible for the workload in Azure. This team should migrate the workload. Outsourcing the migration to talent outside of the workload team can lead to the following outcomes:

- Surprise discoveries late in the process
- An under-trained workload team
- A sense of lost ownership

In many cases, you can engage external partners who have Azure expertise to support the migration. These partners include systems integrators or the Microsoft Industry Solutions Delivery team. They can lead planning and preparation, and the workload team carries out the production cutover by using the partner-developed runbooks and automation.

Workload teams should consult with migration experts as part of the process, but the team should drive the process and stay heavily invested.

## Prerequisites

Before you start planning the migration, ensure that you have the following prerequisites in place:

- *Prior experience:* You need prior experience with core cloud concepts and AWS. Understand Azure services and cloud migration processes.
- *Stakeholder alignment:* You need to share and agree on timelines, budget estimates, and project milestones with stakeholders to ensure that all parties align.
- *Support strategy in place:* Purchase a Microsoft support plan and investigate options for free or community support.
- *Platform strategy in place:* This article series describes how to migrate a single workload. It assumes that your platform foundation is in place and that your migration strategy is defined and in alignment with the [Cloud Adoption Framework for Azure](/azure/cloud-adoption-framework/strategy).

   As part of this strategy, establish an *existing platform landing zone*. Your migrated workload becomes an application landing zone and is part of your organization's Azure landing zone topology. It exists under a management group hierarchy, is connected to or isolated from specific networks, and has governance policies applied.

- *Investment in training or partner support:* Assess your team's Azure skills and plan for training or partner support as needed.

In addition to these measures, do a [Migration readiness assessment](/assessments/Strategic-Migration-Assessment/). This assessment scores your readiness to migrate across 10 dimensions. After the assessment, hold a kick-off workshop that includes all stakeholders to gather requirements and constraints and ensure buy-in.

To help you plan and successfully migrate your workload, work through the five phases in the following order:

> [!div class="checklist"]
> * [1. Plan](/azure/migration/migrate-workload-from-aws-plan)
> * [2. Prepare](/azure/migration/migrate-workload-from-aws-prepare)
> * [3. Execute](/azure/migration/migrate-workload-from-aws-execute)
> * [4. Evaluate](/azure/migration/migrate-workload-from-aws-evaluate)
> * [5. Decommission](/azure/migration/migrate-workload-from-aws-decommission)

Each phase includes detailed steps and checklists that guide you through the migration process.

> [!IMPORTANT]
> Throughout each phase, involve your operations team to address operational readiness. Their tasks include workload **monitoring** and **alerting** and the implementation of health **dashboards**. Plan a formal handoff so that the operations team is prepared to manage the workload in Azure. For example, you can set up [Azure Monitor](/azure/architecture/best-practices/monitoring) dashboards and alerts analogous to [AWS CloudWatch](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/) after the migration is complete.

## Next step

> [!div class="nextstepaction"]
> [Plan your workload migration](./migrate-workload-from-aws-plan.md)