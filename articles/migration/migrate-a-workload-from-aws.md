---
title: Migrate a Workload from Azure Web Services (AWS)
description: Learn how to migrate a single workload from AWS to Azure
ms.author: rhackenberg
ms.date: 11/24/2025
ms.topic: concept-article
ms.service: azure
ms.collection:
 - migration
 - aws-to-azure
---

# Migrate a workload from Amazon Web Services (AWS)

## Overview

This article provides architects and engineers with actionable, prescriptive guidance to migrate a single workload from Amazon Web Services (AWS) to Azure.

The scope of this article covers the full migration lifecycle, from planning and preparation, to execution and evaluation, to decommissioning of AWS resources.

**Workload migration strategy**

A like-for-like workload migration strategy is the fastest path to Azure and has the least risk. This approach keeps the existing architecture and operational patterns. The goal is that the migrated workload meets the same key performance indicators (KPIs) on Azure as it did on AWS. Minimize changes during the migration and focus on validating performance and stability. Once the migration of your workload is completed, you can explore optimization.

**Recommended tools**

Use AWS and Azure tools where appropriate to augment your migration process. These tools support upfront discovery, planning your Azure architecture (based on data gathered about your AWS workload), data and virtual machine (VM) transfer, and post-migration validation and resource cleanup. 

Migrating a workload from AWS is a strategic initiative that requires careful planning and stakeholder alignment. This article focuses on workloads that range from simple to moderately complex and can benefit from a pragmatic migration strategy. 

## Timeline assumptions

The migration of a workload can span several weeks or months. The duration depends on the complexity of the workload and your migration and cutover strategy. The timeline shows a typical workload migration for a moderately complex workload using a like-for-like approach. 

:::image type="content" source="./images/migrate-from-aws-phases.svg" alt-text="Diagram showing three phases of migrating workloads from AWS to Microsoft Azure. Across the top, three labeled boxes indicate phases with durations: Before migration (2–4 weeks), During migration (3–7 weeks), and After migration (1–2 weeks). Each box includes a summary of key activities such as planning, infrastructure setup, and optimization. Below, a horizontal sequence of five icons represents steps: Plan, Prepare, Execute, Optimize, and Decommission." lightbox="./images/migrate-from-aws-phases.svg" border="false":::

*Guidelines for a moderately complex workload.*

## Prerequisites

Before you begin migration planning and execution, ensure you have the following prerequisites in place:

- *Stakeholder alignment:* Share timelines, budget estimates, and project milestones with stakeholders to ensure that all parties are aligned.
- *Support strategy in place:* Purchase a Microsoft support plan and investigate options for free or community support.
- *Platform strategy in place:* This article covers how to migrate a single workload. It assumes your platform foundation is in place and your migration strategy is defined and in alignment with the [Cloud Adoption Framework](/azure/cloud-adoption-framework/strategy).

In addition to these measures, consider completing a [Migration Readiness Assessment](/assessments/Strategic-Migration-Assessment/). This assessment scores your readiness to migrate across 10 dimensions.

To help with planning and successfully executing your workload migration, work through the following five phases:

- [ ] Plan
- [ ] Prepare
- [ ] Execute
- [ ] Evaluate
- [ ] Decommission

## Plan

The planning phase consists of three steps: **assess**, **design**, and **document**. 

The goal is to understand the current state of the workload, design your existing workload’s architecture like-for-like in Azure, and create a runbook.

Take your time in the planning phase and follow the steps in order. An incomplete discovery or unclear migration objectives risk misaligned expectations and missed dependencies and gaps. 

### Assess your AWS workload

You can use native AWS tools, Azure Migrate, or a manual approach to support the discovery phase.

- **Existing workload architecture:** Ensure you have a fully documented workload architecture and the migration team is aligned. Make sure it includes all workload dependencies, such as network configurations, data flows, and external integrations. 
- **Use discovery tooling:** To speed up assessment, use [Workload Discovery on AWS](https://aws.amazon.com/solutions/implementations/workload-discovery-on-aws/) to visualize your AWS workload. It uses AWS Config and AWS Systems Manager data to help identify your workload's components, dependencies, and relationships. 
- **Identify critical flows:** Map out essential user and system interactions and [workflows](/azure/well-architected/reliability/identify-flows). When you design the target architecture in the next step, this information helps prioritize reliability efforts and ensures that the most important and impactful components are protected against failure.
- **Create a detailed inventory** of your current AWS environment that's required for running the workload (all servers, storage, database, and services), along with usage patterns, performance metrics, and licensing requirements. Use [Azure Migrate](/azure/migrate/tutorial-assess-aws) to assess AWS instances for migration to Azure.
- **Assess your team's skills:** Focus on like-for-like capability mapping. Identify the skills your team already uses in AWS and align them with the equivalent Azure services and tools. Include Azure training in your project timeline to ensure that the workload and operations teams are prepared. This approach reduces friction and accelerates adoption. It builds confidence with Azure as existing experience in AWS translates directly to the new environment.
- **Document existing KPIs:** Document the defined performance baseline of your workload, such as throughput, latency, error rates, and resource utilization. If these KPIs aren't available, collect these metrics from your AWS environment to establish this baseline. Use these KPIs in the evaluation phase after migration to validate that the workload in Azure performs as it did in AWS. This strategy supports the like-for-like migration strategy and reduces risks.

### Design a like-for-like architecture in Azure

- **Start with networking:** Discuss your workload's networking requirements with the platform team. Your request should include not only the target architecture, but also the migration connectivity. AWS uses the concept of a Transit Gateway as the network hub with Amazon VPCs as the spoke networks. In the Azure application landing zone design, the platform team provisions spoke virtual networks to workload teams. These spoke networks communicate to other internal and external networks through the hub or Azure Virtual WAN network. Learn more about how to [migrate networking from AWS](/azure/migration/migrate-networking-from-aws).   
- To **identify Azure services** that you can use to build your workload in Azure, refer to the [AWS to Azure resource comparison guides](/azure/architecture/aws-professional).
- **Document your migration decisions:** Document the resources that you don't migrate and any architecture decisions you make. 
- **Reduce risks:** Identify any high-risk components or flows and build out proof of concepts (POCs) as needed to test and mitigate those risks. Consider performing a [failure mode analysis](/azure/well-architected/reliability/failure-mode-analysis) to proactively uncover potential points of failure and assess their impact on the reliability of your workload. 
- **Check availability:** Check Azure service availability and capacity in your preferred region, specifically if you plan to use specialized resource types.
- **Validate requirements:** If you decide to use Azure Migrate, review the [Azure Migrate support matrix](/azure/migrate/migrate-support-matrix-physical) to ensure your AWS instances meet OS and configuration requirements.
- Ensure **compliance and security** requirements are addressed. Learn more about [migrating security from AWS](/azure/migration/migrate-security-from-aws).

### Develop and document a migration plan and create a runbook

**Choose your data migration strategy:** Your choice depends on the amount of data, type of data storage, and usage requirements. Decide between offline migration (backup-and-restore) and live replication.

- **Database migration:** For your [database migration](/azure/migration/migrate-databases-from-aws) you can use AWS as well as Azure tooling. For example, Azure Data Studio allows you to [replicate Amazon RDS for SQL Server to Azure SQL Database and cut over with minimal downtime](/azure/dms/tutorial-sql-server-azure-sql-online.). This feature enables continuous replication from Amazon RDS to Azure SQL Database. Alternatively, you can use [AWS DMS](https://docs.aws.amazon.com/dms/latest/userguide/Welcome.html) which offers continuous replication and change data capture until you cutover. 

- **Storage:** To transfer storage data from [Amazon S3 to Azure](/azure/migration/migrate-storage-from-aws) you have multiple options. For fast bulk-transfer using the CLI, you can use [AzCopy](/azure/storage/common/storage-use-azcopy-s3). For enterprise-grade orchestration and transform-heavy data transfer, use [Azure Data Factory](/azure/data-factory/data-migration-guidance-s3-azure-storage). You can also use [AWS DataSync](https://aws.amazon.com/datasync/features/) to automate the transfer. If you chose AWS DataSync, the DataSync agent needs to be deployed in Azure during the prepare phase. 

**Choose your cutover strategy:** This strategy moves production traffic from the AWS environment to the Azure environment. 

When practical, choose an active-active design over a hot-cold or hot-warm design. If your budget and timeline allow, plan to perform the migration in small incremental steps rather than all at once. An active-active multicloud design during migration lets you migrate and test gradually and with reduced risk. In this scenario, you run your workload in AWS as normal throughout the migration, moving traffic over to Azure in a deliberate, incremental way. Both environments run in parallel throughout the migration, allowing you to shift traffic back to AWS if issues arise in the Azure environment. 

This approach also enables live testing under real-world conditions to catch issues early with minimal impact on the user. For best results, use AWS Transit Gateway to simplify routing between VPCs and Azure, and AWS Route 53 or Azure Traffic Manager for a DNS-based traffic management. Consider applying the [Strangler Fig façade](/azure/architecture/patterns/strangler-fig) as part of a controlled and phased cutover strategy.

There's a cost trade-off to this approach. You incur costs for both cloud providers during the transition. For most teams, the extra costs are worth taking on due to the reduction of risk and operational burden.

**Document in a runbook:** Document the sequence of steps at a high level. If you're planning a one-time all-at-once cutover, define the exact steps, sequence, and timing of the move. Include the planned outage window in your documentation. Consider including a dry-run, especially for complex cutovers. Document your rollback strategy, DNS TTLs, and how to test success metrics.

Review the plan with stakeholders and reconcile differing expectations. Include IT security and risk management teams from the start and ensure they sign off on the plan. A joint workshop at this stage can help minimize delays in later stages.

Once the plan and runbook are reviewed and agreed upon by stakeholders and decision-makers, move on to the prepare phase.

## Prepare

The prepare phase consists of two steps: Preparing your **environment** and preparing your **application**. 

During this phase, the goal is to build out your Azure environment, implement any changes if refactoring is required, set up your CI/CD tooling and pipelines, and perform tests to support a smooth and secure migration. Take your time during this phase as any misconfigured infrastructure, insufficient testing, or lack of your team's readiness can result in delays, security vulnerabilities, or failed deployments during execution.

### Prepare your environment

- **Provision application landing zones:** Ensure the platform team provisions the **[Azure application landing zones](/azure/cloud-adoption-framework/ready/enterprise-scale/implementation)** for your preproduction and production workload environments.
- **Deploy and configure Azure infrastructure:** Use Infrastructure as Code (IaC) to deploy your resources. This approach ensures consistency and repeatability. If your teams use Terraform on AWS, they can continue using it. However, you need to write new Terraform scripts and modules for your Azure resources. If your existing deployment scripts use [CloudFormation](https://docs.aws.amazon.com/cloudformation/), consider using [Bicep](/azure/azure-resource-manager/bicep/) to deploy on Azure. Focus on nonproduction environments first and validate everything before moving on to production environments.
- **Update CI/CD pipelines for Azure:** Modify your deployment pipelines to target Azure Services. Configure the service connections and validate that your build and release workflows can deploy your selected Azure compute resources, such as AppService, AKS, or VMs. During the migration and while using an active-active migration, make sure that your scripts deploy to both AWS and Azure. This approach maintains parity and reduces risk.
- **Test your infrastructure:** Validate your Virtual WAN or hub network and any other foundational services like DirectConnect on AWS and ExpressRoute on Azure or VPN connections. Ensure they're configured to support both the target workload and the migration process. Validate that connectivity works end-to-end across your Azure and AWS environments.

### Prepare your application

- **Refactor your application's code:** Use feature flags to simplify version management between the AWS and Azure environments.
- **Prepare your operational functions:** Work with the platform team to implement workload monitoring. Collaborate with the security team to implement security monitoring and validate the Azure architecture.

For guidance on preparing your workloads and building your Azure environment, see the [CAF Prepare workloads](/azure/cloud-adoption-framework/migrate/prepare-workloads-cloud) guide.

## Execute

The execute phase consists of three steps: **before** cutover, **during** cutover, and **after** cutover. 

The goal of this phase is to migrate your workload to Azure with minimal downtime and disruption. Follow your runbook closely and communicate with stakeholders throughout the process.

The execute phase carries the highest risk of service disruption. Data synchronization issues, network misconfigurations, or unexpected application behaviors can cause outages or data loss. Don't rush testing or skip validation steps.

### Before cutover

- **Execute your data migration:** Align the order of operations with the cutover model you selected.
	- For active replication scenarios, start with the setup of your continuous data synchronization between AWS and Azure. This approach ensures minimal downtime and data consistency during cutover. 
	- For backup-and-restore models, start with a full backup of your AWS data. Securely transfer the backup to Azure, then restore it into the target environment. Validate the integrity of the data before you proceed with the next step.
- **Configure your application's components:** Point components to their dependencies, some of which might still be on AWS initially. In an incremental migration approach, your database might still be in AWS and will be replicated later.
- **Connectivity and networking modifications:** Ensure that your Azure resources can reach anything that still remains in AWS and vice versa if needed. Adjust your firewall and Network Security Groups (NSGs) rules and policies as well as routing as required. Troubleshooting this component can be tricky. Take your time and check everything step-by-step. Security group misconfigurations are a common pitfall.
- **Testing:** Perform functional testing, performance testing, and failure testing. Use [**Azure Chaos Studio**](/azure/chaos-studio/) to simulate potential faults, such as VM or networking outages. Validate that the migrated workload remains resilient under those circumstances.
- **Iterate and fix** any issues you encounter. Common pitfalls include paths in scripts or APIs calls, Azure service limits, and quotas that might need to increase. Some Azure resource features can require different implementations in Terraform.

### During cutover

- **Cutover to Azure:** How you execute this step depends on your chosen strategy. In the recommended, incremental active-active approach, you gradually shift traffic from AWS to Azure based on a given criteria (criteria could include regions, user types, or application features). In the all-at-once approach, you switch all traffic at once during a cutover time. You must ensure that all data is synced and all components are prepared to accept production traffic. Then you switch all connections to Azure and bring up your Azure environment as primary. A maintenance window is recommended in which you briefly pause traffic or the application to avoid inconsistencies. Automate any health checks and monitor in real time during the cutover.
- **Follow your runbook**: Follow your runbook and communicate with stakeholders about cutover progress and any expected impact to the timeline or any other issues they should be aware of.
### After cutover

- **Take advantage of the active-active design**: Deallocate AWS components gradually without downtime.
- **Update CI/CD pipelines for Azure:** Update deployment pipelines to stop targeting AWS and only target Azure.
- **Post-cutover verification:** Closely monitor your workload metrics in Azure, and if they degrade severely or if you detect a critical bug, execute your rollback plan and be ready to revert traffic back to AWS. Run a full regression test in production if possible and check all components. Run smoke tests for critical functions, watch your security logs, and ensure all monitoring signals and alerts are green. After a day or two, monitor costs and usage to ensure there are no runaway resources incurring costs. 

For detailed cutover guidance, see the [CAF Execute migration](/azure/cloud-adoption-framework/migrate/execute-migration) guide.

## Evaluate

Congratulations, your workload is now running on Azure! 

The goal of this phase is to confirm your workload in Azure meets functional, performance, reliability, security, and cost baselines you established in the planning phase on AWS.

Incomplete monitoring, insufficient performance testing, or weak cost and security reviews can hide issues that only surface later as outages, data exposure, or budget overruns.

### Validate successful cutover

- **Monitor and fine-tune:** Closely track your workload trends for any errors, performance bottlenecks, or unusual patterns, especially in the first one to two weeks. This step includes right-sizing components, ensuring your scaling strategy works as intended, watching budget thresholds, and checking and validating your disaster recovery configurations and backups. Prioritize the remediation of any security issues.
- **Measure against baselines**: Verify that the baseline KPIs you documented in the planning phase, like throughput, latency, and error rates, are met and compare favorably to the AWS measurements.
- **Validate cutover via AWS logs:** [AWS CloudTrail](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-user-guide.html) logs every API call and console action in your AWS account. Check and validate that these logs don't show any unintended workload traffic. If any of your workload's components still call any of the AWS services, CloudTrail exposes this.

### Sign-off

- **Sign-off milestones**: Sign-off when you achieve your minimum viable cutover and all tests validate a successful migration outcome.
- **Plan for future improvements:** Create a work backlog for any nonurgent improvements like opportunities for cost optimization and added resilience.

## Decommission

This step is the final step in the workload migration. Proceed when you're confident in how your workload operates in Azure. 

The goal of this phase is to safely retire AWS dependencies, remove redundant resources, and complete the transition to Azure.

If you prematurely delete AWS resources, overlook hidden dependencies, or skip final data and access checks, you risk data loss, unexpected downtime, compliance violations, or lingering cost from orphaned assets.

- **Finalize your data cutover:** If you took an active-active approach with AWS and Azure running in parallel, and especially if you kept your primary database instance in AWS, decide when to fully remove the AWS instance from the workflow and switch your apps to only use the Azure database. Decommission any data synchronization or replication processes.
- **Take any final backups and snapshots** for archival purposes or just in case.
- **Plan the AWS sunset date:**  Stop and delete any AWS EC2 instances, databases, and services that you no longer need. Ensure that nothing critical is still running in AWS before deleting.
- **Check everything is deleted:** [AWS Config](https://docs.aws.amazon.com/config/latest/developerguide/WhatIsConfig.html) maintains an inventory of all your AWS resources and you can use it during the decommission phase to ensure no resources related to your workload are left active.
- **Clean up artifacts:** Update your configuration management database (CMDB), billing, and documentation.

For a thorough review of decommissioning steps, see the [CAF Decommission source workload](/azure/cloud-adoption-framework/migrate/decommission-source-workload) guide.

**Checklist**

- Confirm cutover success
- Notify stakeholders
- Archive backups
- Turn off replication
- Delete AWS resources
- Update internal documents

## Conclusion

Migrating a workload, especially if it's your first workload, is an intense project.

With this guide and the right approach, you can execute it smoothly and with confidence. With a concrete and well thought out plan, relevant stakeholders on board, a solid target architecture, the right migration strategy for each component of the workload, and following a phased approach with clear checklists, you set the stage for success. 

Migrations require much work, coordination, and cooperation across teams, with often late hours to verify everything works as intended. In the end, after a successful migration and after decommissioning your AWS workloads, **celebrate your win**! 

## Next steps

Now that you completed your workload's migration, learn more about recommendations for post-migration tuning and cost optimization in the [CAF Optimize workloads after migration](/azure/cloud-adoption-framework/migrate/optimize-workloads-after-migration) guide. Consider conducting a [Well-Architected Review](/azure/well-architected/) of your new Azure workload to ensure your workload and team's practices align with industry best practices. 

## Tools and references 

- [Azure for AWS professionals](/azure/architecture/aws-professional/)
- [Azure Migrate documentation](/azure/migrate/)

## Training

- [Introduction to migrating from Amazon Web Services to Microsoft Azure](/training/modules/introduction-to-migrating-aws-to-azure/)
- [Configure and migrate to Azure Database for PostgreSQL](/training/paths/microsoft-learn-azure-database-for-postgresql/)
- [Migrate to Azure Database for PostgreSQL](/training/modules/migrate-azure-database-postgresql-flexible-server/)

## Example workload migrations

- [Migrate AWS Lambda to Azure Functions](/azure/azure-functions/migration/lambda-functions-migration-overview)
- [Migrate Amazon RDS for PostgreSQL to Azure Database for PostgreSQL (offline)](/azure/postgresql/migrate/migration-service/tutorial-migration-service-aws-offline)
- [Migrate Amazon Aurora PostgreSQL to Azure Database for PostgreSQL (offline)](/azure/postgresql/migrate/migration-service/tutorial-migration-service-aurora-offline)
- [AKS for Amazon EKS professionals](/azure/architecture/aws-professional/eks-to-aks/)
- [Connect AWS and Azure using a BGP-enabled VPN gateway](/azure/vpn-gateway/vpn-gateway-howto-aws-bgp)
- [Migrate Amazon API Gateway to Azure API Management](/azure/api-management/migrate-amazon-api-gateway-to-api-management)
- [Discover, assess, and migrate Amazon Web Services (AWS) VMs to Microsoft Azure](/azure/migrate/tutorial-migrate-aws-virtual-machines)
