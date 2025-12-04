---
title: Migrate a Workload from Amazon Web Services (AWS) - Plan
description: Learn how to plan migration of a single workload from AWS to Azure
ms.author: rhackenberg
ai-usage: ai-assisted
ms.date: 11/24/2025
ms.topic: concept-article
ms.service: azure
ms.collection:
 - migration
 - aws-to-azure
---
# Plan your workload migration from Amazon Web Services (AWS) to Azure - Plan

The planning phase consists of three steps: 

> [!div class="checklist"]
> * assess
> * design
> * document

The goal is to understand the current state of the workload, design your existing workload’s architecture like-for-like in Azure, and create a runbook.

> [!IMPORTANT]
> Take your time in the planning phase and follow the steps in order. An incomplete discovery or unclear migration objectives, risk misaligned expectations and missed dependencies and gaps. 

## Assess your AWS workload

You can use native AWS tools, Azure Migrate, or a manual approach to support the discovery phase.

1. **Existing workload architecture:** Ensure you have a fully documented workload architecture and the migration team is aligned. Make sure it includes all workload dependencies, such as network configurations, data flows, and external integrations. 
2. **Use discovery tooling:** To speed up assessment, use [Workload Discovery on AWS](https://aws.amazon.com/solutions/implementations/workload-discovery-on-aws/) to visualize your AWS workload. It uses AWS Config and AWS Systems Manager data to help identify your workload's components, dependencies, and relationships. 
3. **Identify critical flows:** Map out essential user and system interactions and [workflows](/azure/well-architected/reliability/identify-flows). When you design the target architecture in the next step, this information helps prioritize reliability efforts and ensures that the most important and impactful components are protected against failure.
4. **Create a detailed inventory** of your current AWS environment that's required for running the workload (all servers, storage, database, and services), along with usage patterns, performance metrics, and licensing requirements. Use [Azure Migrate](/azure/migrate/tutorial-assess-aws) to assess AWS instances for migration to Azure.
5. **Assess your team's skills:** Focus on like-for-like capability mapping. Identify the skills your team already uses in AWS and align them with the equivalent Azure services and tools. Include Azure training in your project timeline to ensure that the workload and operations teams are prepared. This approach reduces friction and accelerates adoption. It builds confidence with Azure as existing experience in AWS translates directly to the new environment.
6. **Document existing KPIs:** Document the defined performance baseline of your workload, such as throughput, latency, error rates, and resource utilization. If these KPIs aren't available, collect these metrics from your AWS environment to establish this baseline. Use these KPIs in the evaluation phase after migration to validate that the workload in Azure performs as it did in AWS. This strategy supports the like-for-like migration strategy and reduces risks.

## Design a like-for-like architecture in Azure

1. **Start with networking:** Discuss your workload's networking requirements with the platform team. Your request should include not only the target architecture, but also the migration connectivity. AWS uses the concept of a Transit Gateway as the network hub with Amazon VPCs as the spoke networks. In the Azure application landing zone design, the platform team provisions spoke virtual networks to workload teams. These spoke networks communicate to other internal and external networks through the hub or Azure Virtual WAN network. Learn more about how to [migrate networking from AWS](/azure/migration/migrate-networking-from-aws).   
2. To **identify Azure services** that you can use to build your workload in Azure, refer to the [AWS to Azure resource comparison guides](/azure/architecture/aws-professional).
3. **Document your migration decisions:** Document the resources that you don't migrate and any architecture decisions you make. 
4. **Reduce risks:** Identify any high-risk components or flows and build out proof of concepts (POCs) as needed to test and mitigate those risks. Consider performing a [failure mode analysis](/azure/well-architected/reliability/failure-mode-analysis) to proactively uncover potential points of failure and assess their impact on the reliability of your workload. 
5. **Check availability:** Check Azure service availability and capacity in your preferred region, specifically if you plan to use specialized resource types.
6. **Validate requirements:** If you decide to use Azure Migrate, review the [Azure Migrate support matrix](/azure/migrate/migrate-support-matrix-physical) to ensure your AWS instances meet OS and configuration requirements.
7. Ensure **compliance and security** requirements are addressed. Learn more about [migrating security from AWS](/azure/migration/migrate-security-from-aws).

## Develop and document a migration plan and create a runbook

**Choose your data migration strategy:** Your choice depends on the amount of data, type of data storage, and usage requirements. Decide between offline migration (backup-and-restore) and live replication.

- **Database migration:** For your [database migration](/azure/migration/migrate-databases-from-aws) you can use AWS as well as Azure tooling. For example, Azure Data Studio allows you to [replicate Amazon RDS for SQL Server to Azure SQL Database and cut over with minimal downtime](/azure/data-factory/connector-amazon-rds-for-sql-server?tabs=data-factory). This feature enables continuous replication from Amazon RDS to Azure SQL Database. Alternatively, you can use [AWS DMS](https://docs.aws.amazon.com/dms/latest/userguide/Welcome.html) which offers continuous replication and change data capture until you cutover. 

- **Storage:** To transfer storage data from [Amazon S3 to Azure](/azure/migration/migrate-storage-from-aws) you have multiple options. For fast bulk-transfer using the CLI, you can use [AzCopy](/azure/storage/common/storage-use-azcopy-s3). For enterprise-grade orchestration and transform-heavy data transfer, use [Azure Data Factory](/azure/data-factory/data-migration-guidance-s3-azure-storage). You can also use [AWS DataSync](https://aws.amazon.com/datasync/features/) to automate the transfer. If you chose AWS DataSync, the DataSync agent needs to be deployed in Azure during the [prepare phase](./migrate-workload-from-aws-prepare.md).

**Choose your cutover strategy:** This strategy moves production traffic from the AWS environment to the Azure environment. 

When practical, choose an active-active design over a hot-cold or hot-warm design. If your budget and timeline allow, plan to perform the migration in small incremental steps rather than all at once. An active-active multicloud design during migration lets you migrate and test gradually and with reduced risk. In this scenario, you run your workload in AWS as normal throughout the migration, moving traffic over to Azure in a deliberate, incremental way. Both environments run in parallel throughout the migration, allowing you to shift traffic back to AWS if issues arise in the Azure environment. 

This approach also enables live testing under real-world conditions to catch issues early with minimal impact on the user. For best results, use AWS Transit Gateway to simplify routing between VPCs and Azure, and AWS Route 53 or Azure Traffic Manager for a DNS-based traffic management. Consider applying the [Strangler Fig façade](/azure/architecture/patterns/strangler-fig) as part of a controlled and phased cutover strategy.

There's a cost trade-off to this approach. You incur costs for both cloud providers during the transition. For most teams, the extra costs are worth taking on due to the reduction of risk and operational burden.

**Document in a runbook:** Document the sequence of steps at a high level. If you're planning a one-time all-at-once cutover, define the exact steps, sequence, and timing of the move. Include the planned outage window in your documentation. Consider including a dry-run, especially for complex cutovers. Document your rollback strategy, DNS TTLs, and how to test success metrics.

Plan and document your traffic routing changes in detail. Define exactly how DNS records, load balancer configurations, and routing rules will be updated to direct traffic to Azure. Take into consideration any TTL that you might have configured. 

> [!CAUTION]
> Neglecting to explicitly plan traffic routing is a common pitfall that can lead to unexpected downtime. 

Review the plan with stakeholders and reconcile differing expectations. Include IT security and risk management teams from the start and ensure they sign off on the plan. A joint workshop at this stage can help minimize delays in later stages.

Once the plan and runbook are reviewed and agreed upon by stakeholders and decision-makers, move on to the prepare phase.

## Next step

> [!div class="nextstepaction"]
> [Prepare for workload migration](./migrate-workload-from-aws-prepare.md)