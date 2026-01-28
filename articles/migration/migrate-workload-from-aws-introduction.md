---
title: Migrate a workload from Amazon Web Services (AWS) to Azure - Introduction
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
# Migrate a workload from Amazon Web Services (AWS) to Azure - Introduction

This article series provides architects and engineers with actionable, prescriptive guidance to migrate a single workload from Amazon Web Services (AWS) to Azure. It covers the full migration lifecycle, from planning and preparation, execution and evaluation, to decommissioning of AWS resources.

This article focuses on workloads that range from simple to moderately complex that are fairly independent from other workloads in your organization. It does not cover mission-critical workloads.

Migrating a workload from AWS is a strategic initiative that requires careful planning and stakeholder alignment. Without a solid migration plan and proper preparation, you risk introducing undesired disruption which can erode confidence in your workload.

## Workload migration strategy

A like-for-like workload migration strategy is generally considered the safest path to Azure by minimizing risk. This approach keeps the workload using existing architecture and operational patterns. Migrations are most successful when they avoid scope creep, such as trying to pay down existing technical debt or introduce optimizations during this already risky workload hosting transition. The goal is that the migrated workload meets the same key performance indicators (KPIs) on Azure as it did on AWS; maintaining the same SLAs, SLOs, and even bugs that exist currently in the workload.
 
> [!TIP]
> Minimize changes during the migration and focus on validating performance and stability. Once the migration of your workload is completed, you can explore technical debt repayment and further optimizations.

## Recommended tools

Use AWS and Azure tools where appropriate to augment your migration process. These tools support upfront discovery, planning your Azure architecture (based on data gathered about your AWS workload), data and compute platform transfer, post-migration validation and resource cleanup. You should use [Workload Discovery on AWS](https://aws.amazon.com/solutions/implementations/workload-discovery-on-aws/) to perform the assessment of your workload. You can combine AWS tooling with Azure tooling, such as [Azure Migrate](/azure/migrate/tutorial-assess-aws), to assess AWS instances and provide sizing recommendations for Azure resources. Optionally, you can explore third-party solutions such as [Dr Migrate](https://marketplace.microsoft.com/en-us/product/altratechnologiesptyltd1719876965699.altra_dr_migrate_express_saas) or [CAST highlight](https://marketplace.microsoft.com/en-us/product/saas/cast.cast_highlight) to assist with code analysis, dependency mapping, and migration readiness assessments.

## Timeline assumptions

The migration of a workload can span several weeks or months. The duration depends on the complexity of the workload and your migration and cutover strategy. The timeline shows a typical workload migration for a moderately complex workload using a like-for-like approach. A moderately complex workload typically includes multiple components and dependencies, but is not mission-critical and does not have deep integration with other systems.

:::image type="complex" source="./images/migrate-from-aws-phases.svg" alt-text="Diagram showing three phases of workload migration." lightbox="./images/migrate-from-aws-phases.svg" border="false":::
    Diagram showing three phases of migrating workloads from AWS to Microsoft Azure. Across the top, three labeled boxes indicate phases with durations: Before migration (2–4 weeks), During migration (3–7 weeks), and After migration (1–2 weeks). Each box includes a summary of key activities such as planning, infrastructure setup, and optimization. Below, a horizontal sequence of five icons represents steps: Plan, Prepare, Execute, Evaluate, and Decommission.
:::image-end:::

*Guidelines for a moderately complex workload.*

## Workload team responsibility

We've found that the workload team who is currently responsible for the workload in AWS and ultimately will be responsible for the workload in Azure should be performing the migration of the workload. Outsourcing a bulk of the migration to talent outside of the workload team can lead to:

- surprise discoveries late in the process
- an under-trained workload team
- sense of lost ownership

In many cases, external partners with Azure expertise (such as System Integrators or Microsoft's Industry Solutions Delivery team) are brought in to support the migration. While these partners may lead planning and preparation, the workload team executes the production cutover using the partner-developed runbooks and automation.

Workload teams should consult with migration experts as part of the process, but the team should drive the process and stay heavily invested.

## Prerequisites

Before you begin migration planning and execution, ensure you have the following prerequisites in place:

- *Prior experience:* Prior experience with core cloud concepts, AWS and a basic understanding of Azure services and cloud migration processes.
- *Stakeholder alignment:* You'll need to share and agree on timelines, budget estimates, and project milestones with stakeholders to ensure that all parties are aligned.
- *Support strategy in place:* Purchase a Microsoft support plan and investigate options for free or community support.
- *Platform strategy in place:* This article series covers how to migrate a single workload. It assumes your platform foundation is in place and your migration strategy is defined and in alignment with the [Cloud Adoption Framework](/azure/cloud-adoption-framework/strategy[]()).

   This includes having an *existing platform landing zone* established. Your migrated workload will become an application landing zone and will be part of your organization's Azure landing zone topology. It will exist under a management group hierarchy, be connected to or isolated from certain networks, and have governance policies applied.

- *Invest in training or partner support:* Assess your team's Azure skills and plan for training or partner support as needed.

In addition to these measures, complete a [Migration Readiness Assessment](/assessments/Strategic-Migration-Assessment/). This assessment scores your readiness to migrate across 10 dimensions. After the assessment, hold a kick-off workshop, including all stakeholders, to gather requirements and constraints and ensure buy-in.

To help with planning and successfully executing your workload migration, work through the following five phases, in order:

> [!div class="checklist"]
> * [Plan](/azure/migration/migrate-workload-from-aws-plan)
> * [Prepare](/azure/migration/migrate-workload-from-aws-prepare)
> * [Execute](/azure/migration/migrate-workload-from-aws-execute)
> * [Evaluate](/azure/migration/migrate-workload-from-aws-evaluate)
> * [Decommission](/azure/migration/migrate-workload-from-aws-decommission)

Each phase includes detailed steps and checklists to guide you through the migration process.

> [!IMPORTANT]
> Throughout each phase, involve your operations team to address operational readiness. This includes workload **monitoring**, **alerting**, and health **dashboards**. Plan a formal hand-off so Ops is prepared to manage the workload in Azure (for example, by setting up [Azure Monitor](/azure/architecture/best-practices/monitoring) dashboards and alerts analogous to [AWS CloudWatch](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/)) once the migration is complete.

## Next step

> [!div class="nextstepaction"]
> [Plan your workload migration](./migrate-workload-from-aws-plan.md)