---
title: Plan your workload migration from Amazon Web Services (AWS) to Azure
description: Learn how to plan migration of a single workload from AWS to Azure
ms.author: rhackenberg
ai-usage: ai-assisted
ms.date: 11/24/2025
ms.topic: concept-article
ms.custom: migration-hub
ms.service: azure
ms.collection:
  - migration
  - aws-to-azure
---
# Plan your workload migration from Amazon Web Services (AWS) to Azure

This article is part of a series on [how to migrate a workload from AWS to Azure](/azure/migration/migrate-workload-from-aws-introduction). 

The planning phase consists of these steps: 

> [!div class="checklist"]
> * assess your workload
> * design a like-for-like architecture
> * develop and document a migration plan

:::image type="icon" source="images/goal.svg" alt-text="Goal icon"::: The goal of the planning phase is to understand your existing AWS workload from a technical and business standpoint, so that you can confidently build a plan to replicate it in Azure.

> [!IMPORTANT]
> Take your time in the planning phase and follow the steps in order. Incomplete discovery or unclear migration objectives risk misaligned expectations and missed dependencies.

## Assess your AWS workload

In order to build a comparable system in Azure, you first need to fully understand your current system. You'll need to evaluate it from multiple perspectives to ensure that you eventually design an Azure implementation that fulfills the needs of users, operators, developers, compliance, and business stakeholders to the same level it does today.

1. **Existing workload architecture:** Fully document and verify your workload architecture. Make sure it includes all workload dependencies, such as network configurations, data flows, and external integrations.
2. **Document authentication (AuthN) and authorization (AuthZ):** Include identity and access management (IAM) configurations in your assessment. A complete documentation how authentication and authorization are handled in AWS is critical to designing a secure and functional Azure equivalent.
3. **Use discovery tooling:** Use AWS-specific tooling such as [Workload Discovery on AWS](https://aws.amazon.com/solutions/implementations/workload-discovery-on-aws/) to visualize your AWS workload. It uses AWS Config and AWS Systems Manager data to help identify your workload's components, dependencies, and relationships. Use Azure tooling, such as [Azure Migrate](/azure/migrate/tutorial-assess-aws), to provide additional discovery of AWS workload components and make Azure-specific recommendations.
4. **Identify critical flows:** Map out essential user and system interactions and [workflows](/azure/well-architected/reliability/identify-flows). When you design the target architecture in the next section, this information helps prioritize reliability efforts and ensures that the most important and impactful components are protected against failure.
5. **Create a detailed inventory**: Make a list of your current AWS environment that's required for running the workload (all servers, storage, database, and services), along with usage patterns, performance metrics, and licensing requirements.
6. **Involve subject matter experts:** In addition to automated discovery tools, engage experts throughout the workload team to uncover hidden dependencies, complex component relationships, and sensitive state. Critical components, like scheduled scripts, undocumented integrations, or legacy configurations, are often missed by tooling. A conversation with these subject matter experts can reveal these nuances and prevent surprises during migration. Include their input in the migration plan and runbook.
7. **Assess your team's skills:** Focus on like-for-like capability mapping. Identify the skills your team already uses in AWS and align them with the equivalent Azure services and tools. Include Azure training in your project timeline to prepare your workload and operations teams. This approach reduces friction and builds confidence with Azure as existing experience in AWS translates directly to the new environment.
8. **Document existing commitments:** Document the defined performance baseline of your workload, such as throughput, latency, error rates, and resource utilization. If these KPIs aren't available, collect these metrics from your AWS environment to establish this baseline. You will use the these KPIs in the evaluation phase after migration to validate that the workload in Azure performs as it did in AWS. Also understand if there are any SLAs or SLOs associated with the workload. These SLA and SLO commitments made to end users or stakeholders do not change based on your cloud platform. For example, if your recovery time objective (RTO) in AWS was 45 minutes, you'll be responsible to design the workload in Azure to also have an RTO of 45 minutes.
9. **Document current monitoring and alerting:** Document how the workload is monitored in AWS today (CloudWatch metrics, alarms, dashboards, etc.). Plan equivalent Azure monitoring (Azure Monitor logs, metrics, Application Insights dashboards) for the target environment. Engage your operations team in this assessment so they’re ready to implement and manage Azure-based monitoring and alerts.

## Design a like-for-like architecture in Azure

Many cloud-based modern workloads use managed or serverless services instead of VMs for many of their functions. If your AWS workload uses manages services, for example EKS or ECS, you need to research Azure's offerings to find the best like-for-like match for your use case. In some cases, Azure might have multiple services that you can choose from, like containerized apps. Choose the service that is the most similar. For example, do not switch container orchestration platforms during migration.

**Example like-for-like architecture for a Kubernetes workload on AWS and Azure**

:::image type="complex" source="./images/like-for-like-architecture-aws-and-azure.svg" alt-text="Diagram showing like-for-like architecture for Kubernetes based workload" lightbox="./images/like-for-like-architecture-aws-and-azure.svg" border="false":::
Diagram illustrating hybrid connectivity between AWS and Azure clouds for Kubernetes workloads. On the left, AWS Cloud includes services such as Amazon Elastic Container Registry (ECR), IAM, KMS, and CloudWatch, with an Amazon EKS cluster inside a VPC connected to compute nodes and a network load balancer. On the right, Azure Cloud includes Azure Container Registry, Microsoft Entra ID, Key Vault, and Monitor, with an Azure Kubernetes Service (AKS) cluster inside a Virtual Network (VNet) featuring private endpoints, an application gateway, and node pools. In the center, admins and engineers use Terraform for infrastructure automation. Connectivity between AWS and Azure is established via Site-to-Site VPN, AWS Direct Connect, and Azure ExpressRoute. Users interact from the top of the diagram.
:::image-end:::

To begin mapping your like-for-like architecture, first establish a solid foundation.

**Start with networking:** Discuss your workload's networking requirements with the platform team. This discussion should include not only the target architecture, but also the migration connectivity. AWS uses the concept of a Transit Gateway as the network hub with Amazon VPCs as the spoke networks. In the Azure application landing zone design, the platform team provisions spoke virtual networks to workload teams. These spoke networks communicate to other internal and external networks through the hub or Azure Virtual WAN network. 

To exchange data during the migration, you can use either Site-to-Site VPN or ExpressRoute with AWS Direct Connect. Relying on VPN is suitable for smaller or proof-of-concept migrations, while ExpressRoute with AWS Direct Connect is recommended for production-scale migrations or large data transfers. Consider using both for reliability. In that case, you use VPN for failover.

:::image type="complex" source="./images/migrate-from-aws-connectivity.svg" alt-text="Diagram showing network connectivity between AWS and Azure clouds." lightbox="./images/migrate-from-aws-connectivity.svg" border="false":::
    Diagram showing network connectivity between AWS and Azure clouds. At the top, a DNS icon connects to two boxes: on the left, AWS Cloud with a Virtual Private Cloud (VPC); on the right, Azure Cloud with a Virtual Network (VNet). A bidirectional arrow between the boxes is labeled Site-to-Site VPN and Direct Connect + ExpressRoute, indicating secure connectivity options.
:::image-end:::
 
Learn more about how to [migrate networking from AWS](/azure/migration/migrate-networking-from-aws).

After planning your networking, follow these steps:

1. **Identify Azure services:** Use the [AWS to Azure resource comparison guide](/azure/architecture/aws-professional) to help you narrow down choices for your workload's Azure components. Build proof of concepts (POCs) to gain confidence or help make decision on candidate components and their configuration. When you select your components, refer to the [Azure Well Architected Service Guides](/azure/well-architected/service-guides/). This will ensure your like-for-like architecture is not just functionally equivalent but also optimized for Azure’s platform characteristics and best practices.
2. **Plan identity management:** Plan how identity and access will be handled in Azure for both end-users and for workload operations. If your workload uses AWS IAM roles or federated identity providers, determine how these roles translate to Entra ID (formerly Azure AD) roles, managed identities, or service principals. Review any hardcoded ARNs, IAM policies, or identity integrations in the application. If you overlook identity mapping, it can lead to post-migration access issues or broken integrations. Integrating with third-party identity providers are a key challenge during migrations. If possible, consolidate identity management by transitioning to Entra ID.
3. **Document your migration decisions:** Document the resources that you don't migrate and any architecture decisions you make. 
4. **Reduce risks:** Identify any high-risk components or flows and build proof of concepts (POCs) as needed to test and mitigate those risks. Perform [failure mode analysis](/azure/well-architected/reliability/failure-mode-analysis) on your selected components to proactively uncover potential points of failure and assess their impact on the reliability of your workload. Your Azure components might have new failure modes or fail differently than their counterpart does in AWS.
5. **Check availability:** Check Azure service availability and capacity in your preferred region, specifically if you plan to use specialized resource types. When selecting your target region, aim to align it closely with your current AWS region. Migrating to a geographically similar Azure region helps maintain consistent latency.
6. **Validate requirements:** If you decide to use Azure Migrate, review the [Azure Migrate support matrix](/azure/migrate/migrate-support-matrix-physical) to ensure your AWS instances meet OS and configuration requirements. If you're not using Azure Migrate, perform a manual validation of your workload's compatibility with Azure services. This includes verifying supported operating systems, VM sizes, disk configurations, and network dependencies.
7. **Compliance and security:** Ensure you meet your security requirements in your Azure implementation. Ensure your Azure implementation matches security expectations such as OS security patching, network isolation, ingress and egress inspection, least-privileged access, static code analysis, and penetration testing schedules.

   In addition to maintaining an identical security posture in your workload, you'll also want to ensure that any temporary infrastructure, network connections, and processes that are created to facilitate the migration are also meeting security expectations. Migrations can be a chaotic period of time in a workload, don't let an oversight or shortcut in security during the migration lead to an incident.

   Be aware that the security model used in AWS differs from that of Azure in significant ways. Learn more about [migrating security from AWS](/azure/migration/migrate-security-from-aws).

## Develop and document a migration plan and create a runbook

### Your cutover strategy

Plan how to cut over production traffic from the AWS environment to the Azure environment. The most common approaches are:

- **Big Bang:** Everything is migrated and switched at the same time during a maintenance window
- **Phased migration:** Workload components are migrated incrementally 
- **Blue/Green (recommended):** Two environments run in parallel and traffic is switched over after validation.

#### Key differences at a glance

| Strategy   | Downtime | Risk Level | Cost Impact | Rollback Ease |
| ---------- | -------- | ---------- | ----------- | ------------- |
| Big Bang   | High     | High       | Low         | Hard          |
| Phased     | Low      | Medium     | Medium      | Moderate      |
| Blue/Green | Low      | Low        | High        | Easy          |

To keep the risk low and rollback easy, a blue/green approach is recommended. In this case, you maintain two environments. Blue is the current environment (AWS) and green is the new environment (Azure).

In the blue/green scenario, you plan a migration window, run your workload in AWS as normal throughout the migration, and move traffic over to Azure after a successful dry run. Both environments run in parallel throughout the migration, so you can shift traffic back to AWS if issues arise in the Azure environment. In this case, you also need a rollback strategy for state that might have changed. Be sure to consider databases and less obvious state, such as unprocessed items in message queues.

If your workload is more complex and you want to minimize risk, you can combine blue/green with a canary approach for switching over traffic. With a canary approach you gradually route a small percentage of traffic to the new environment, then increase incrementally. Using a canary approach for traffic routing increases the complexity because live state needs to exist in both AWS and Azure during the transition.
 
If any components are going to co-exist on AWS while other components run on Azure, consider applying patterns such as the [Strangler Fig façade](/azure/architecture/patterns/strangler-fig) as part of a controlled cutover strategy. You'll implement these added layers of indirection in the next phase.

There's a cost trade-off to the Blue/Green approach. You incur costs for both cloud providers during the transition. For most teams, the extra costs are worth taking on due to the reduction of risk and operational burden.

#### Plan a maintenance window

No matter what approach you select for your workload, it's highly encouraged that a generous maintenance window is negotiated during the plan phase. This is to respect the sensitive nature of migration activities and to account for any loss of functionality during the migration. The maintenance window allows you to develop plans that reduce risk of data loss, data corruption, or inconsistent user experiences by taking advantage of no active usage of the system. For example, this time can be used to drain Amazon Simple Queue Service (SQS) messages.

If your workload has an outage budget, consider the migration window to not draw from that budget, as you might need that budget to address post-migration surprises. You'll need to consider impacts to contractual SLAs in this decision.

### Choose your data migration strategy

Your choice depends on the amount of data, type of data storage, and usage requirements. Decide between offline migration (backup and restore) and live replication.

**Align strategy to your workload's RPO (recovery point objective):** Consider your workload's RPO for data loss. You'll refer to this RPO in the [decommission phase](/azure/migration/migrate-workload-from-aws-decommission), and your database migration strategy depends on it as well. RPO is the maximum amount of data loss that you're willing to accept as part of the cut-over. For example, an RPO could be "no more than 5 minutes of data loss". This definition means only up to five minutes of data can be lost during the cutover. Ideally, you'll minimize the risk of data loss by shutting down state change operations within the workload prior to cut over.

The lower the RPO is, the more you have to consider continuous replication or very recent backups as well as maintenance windows. Lower RPOs can also increase cost and effort to migrate your data.

**Database migration:** For your [database migration](/azure/migration/migrate-databases-from-aws) you should evaluate AWS as well as Azure tooling. For example, Azure Data Studio allows you to [replicate Amazon RDS for SQL Server to Azure SQL Database](/azure/data-factory/connector-amazon-rds-for-sql-server?tabs=data-factory). This feature enables continuous replication from Amazon RDS to Azure SQL Database. Alternatively, you could use [AWS DMS](https://docs.aws.amazon.com/dms/latest/userguide/Welcome.html) which offers continuous replication and change data capture until you cutover.

In most scenarios, data migration occurs in multiple phases. For example, you may perform an initial migration for testing and validation, followed by a final cutover migration or continuous synchronization to ensure data freshness. This approach allows teams to validate application behavior in Azure before the final cutover, reduces risk of data loss, and supports rollback planning.

**Storage:** To transfer storage data from [Amazon S3 to Azure](/azure/migration/migrate-storage-from-aws) you have multiple options. 

| Tool                                                                               | Purpose                                                                                |
| ---------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| [AzCopy](/azure/storage/common/storage-use-azcopy-s3)                              | fast bulk-transfer using the CLI                                                       |
| [Azure Data Factory](/azure/data-factory/data-migration-guidance-s3-azure-storage) | enterprise-grade orchestration and transform-heavy data transfer                       |
| [AWS DataSync](https://aws.amazon.com/datasync/)                                   | automates the transfer of files and replication of unstructured data from AWS to Azure |

> [!TIP]
> If you choose AWS DataSync, you need to deploy the DataSync agent in Azure during the [prepare phase](./migrate-workload-from-aws-prepare.md).

**Plan a maintenance window:** Schedule a dedicated window for your final cutover and decommissioning steps. Document and communicate it with your stakeholders before you start migration. Include time for a possible rollback and DNS switch.

### Document in a runbook

**Sequence of steps:** Document the sequence of steps at a high level. Define the exact steps, sequence, and timing of the move. Include the planned maintenance window in your documentation. Consider including a dry-run, especially for complex cutovers. Document your rollback strategy, DNS TTLs, and how to test success metrics.

**Security and networking configuration:** Include all firewall rule changes, required port openings, and updates to Network Security Groups (NSGs) or Application Security Groups (ASGs) needed to support Azure connectivity. Document any temporary exceptions or overrides required during cutover and ensure rollback procedures account for these changes.

**Sign-off acceptance criteria:** Define what a *stable operation* means and make it measurable. For example, agree that after cutover Azure must run for at least a certain number of minutes or hours without errors and the workload passes all tests. 

**Rollback trigger criteria and steps:** Document the exact conditions that trigger a rollback to the AWS environment. For example, if any critical functionality is down or the system is in a degraded state (for example, a certain percentage below baseline) for more than a certain number of minutes, initiate a rollback. Document the rollback steps.

Depending on state changes, rollbacks can be more complex than mitigating the problem in Azure. Failed mitigation attempts might also complicate a rollback. Having a shared understanding of break-fix scenarios vs revert scenarios will help derisk the migration.

**Client configuration changes:** Identify and document all client-facing configuration items that will be impacted by the workload migration. This includes DNS endpoints, authentication flows, and connection strings. Involve the client teams early and communicate the upcoming changes with timelines and responsibilities.

**Traffic and routing changes:** Plan and document your traffic routing changes in detail. Define exactly how to update DNS records, load balancer configuration, and routing rules to direct traffic to Azure. Take into consideration any TTL that you configured as it determines how long DNS changes take to propagate. 

Many applications and scripts reference Fully Qualified Domain Names (FQDNs) for endpoints, APIs, and services. If these change unexpectedly during migration, integrations can break. As part of your routing and cutover planning, inventory all FQDNs used by your workload. Decide whether to retain existing names via DNS forwarding or update application configurations to use new Azure FQDNs. For public-facing services, plan DNS cutover carefully to minimize downtime and ensure a seamless transition.

> [!CAUTION]
> Neglecting to explicitly plan traffic routing is a common pitfall that can lead to unexpected downtime. 

Review the plan with stakeholders and reconcile differing expectations. Include IT security and risk management teams from the start and ensure they sign off on the plan. A joint workshop at this stage can help minimize delays in later stages.

Once stakeholders and decision-makers review and agree on the plan and runbook, move on to the prepare phase.

## Outputs and artifacts

By the end of the planning phase, you should have:

- Target architecture diagram
- Architecture decision records (ADRs)
- Budget and cost estimates
- Migration runbook and timeline
- Stakeholder sign-offs on the migration plan

## Checklist

| &nbsp;  | Deliverable tasks                                     |
| ------- | ----------------------------------------------------- |
| &#9744; | Document existing workload architecture               |
| &#9744; | Document authentication and authorization             |
| &#9744; | Use discovery tooling                                 |
| &#9744; | Identify critical flows                               |
| &#9744; | Create detailed inventory                             |
| &#9744; | Involve application team                              |
| &#9744; | Assess skills                                         |
| &#9744; | Document KPIs                                         |
| &#9744; | Plan monitoring and Ops hand off                      |
| &#9744; | Address networking                                    |
| &#9744; | Identify matching Azure services                      |
| &#9744; | Plan identity management                              |
| &#9744; | Document migration decisions                          |
| &#9744; | Reduce risks                                          |
| &#9744; | Check resource availability                           |
| &#9744; | Validate requirements if using Azure Migrate          |
| &#9744; | Address compliance and security requirements          |
| &#9744; | Choose cutover strategy                               |
| &#9744; | Choose database migration strategy                    |
| &#9744; | Choose storage migration strategy                     |
| &#9744; | Plan maintenance window                               |
| &#9744; | Document sequence of steps                            |
| &#9744; | Document security and networking configuration        |
| &#9744; | Document sign-off acceptance criteria                 |
| &#9744; | Document rollback trigger criteria and steps          |
| &#9744; | Document and communicate client configuration changes |
| &#9744; | Document traffic and routing changes                  |

## Next step

> [!div class="nextstepaction"]
> [Prepare for workload migration](./migrate-workload-from-aws-prepare.md)