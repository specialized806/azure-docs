## Overview

This article provides architects and engineers with actionable, prescriptive guidance to migrate a single workload from Amazon Web Services (AWS) to Azure.

The scope of this article covers the full migration lifecycle, from planning and preparation, to execution and validation, to decommissioning of AWS resources.

Migrating a workload from AWS is a strategic initiative that requires careful planning and stakeholder alignment. This article focuses on workloads that range from simple to moderately complex and can benefit from a pragmatic migration strategy. 


## Migration strategies to consider

When planning a workload migration, you should consider three types of strategies.  The **migration strategy** refers to how a workload is moved to Azure. This is the overall migration approach from a technical perspective. The **cutover strategy** is how production traffic is moved from the AWS to environment to the Azure environment. Finally, the **data strategy** focuses on how to move the data itself from AWS to Azure. 
 
Choosing the right **migration strategy** for your workload is crucial. The most common strategies are: rehost (aka lift-and-shift), replatform, and (less commonly) refactor. Choose the least impactful strategy for your workload. 


**Migration Strategy**

| **Workload characteristics**                                                                 | **Recommended strategy**                         | **Rationale and notes**                                                                                                                                                                                                     |
| -------------------------------------------------------------------------------------------- | ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Legacy or tightly-coupled system (like older enterprise apps on VMs, or monolithic apps)** | **Rehost (lift-and-shift)**                      | Easiest and safest: recreate the workload on Azure VMs or equivalent services with minimal changes. Use this when speed is a priority or application changes are not feasible. Plan for modernization after a successful move. |
| **Modern, cloud-ready application (like containerized microservices and stateless apps)**       | **Replatform (minor modifications)**             | Take advantage of Azure’s managed services (AKS, App Service, Azure SQL Database, and others) to reduce operational burden and to improve scalability. The app can be moved with minor updates, leveraging cloud offerings for databases, caching, and other functions.    |
| **Mixed components (combining legacy and modern components)**                                        | **Hybrid approach** (Mix of rehost & replatform) | You might rehost certain components and replatform others. For example, migrate the database to Azure via rehost, but move the front-end to an Azure App Service. Take the simplest approach for each component.               |

In some cases, combining migration strategies is the best solution. For example, rehosting0 0a VM-hosted database can be easier than moving to a managed database service if it relieves the need to make significant schema changes. You can still re-platform your application servers to a managed compute service if you don't need to perform major code changes.


**Cutover strategy**

If your budget and timeline allows, perform the migration in small incremental steps rather than all at once. An active-active multi-cloud design during migration lets you migrate and test gradually and with reduced risk.  In this scenario, you run your workload in AWS as normal throughout the migration, moving traffic over to Azure in a deliberate, incremental way. Both environments run in parallel throughout the migration, allowing you to shift traffic back to AWS if issues arise in the Azure environment.

This approach also enables live testing under real-world conditions to catch issues early with minimal user impact.

There is a cost trade-off to this approach. You will incur costs for both cloud providers during the transition. For most teams, the additional costs are worth taking on due to the reduction of risk and operational burden.


**Data strategy**

Determine the right data migration for your workload. Your choice depends on the amount of data, type of data storage and usage requirements. Decide between offline migration (backup-and-restore), live replication and/or file storage. 

Learn more about migration strategies for [databases](/azure/migration/migrate-databases-from-aws) or [storage](/azure/migration/migrate-storage-from-aws).

## Timeline assumptions

The migration of a workload can span several weeks or months. The duration depends on the complexity of the workload and your migration strategy. The timeline below shows a typical workload migration for a moderately complex workload. The chosen migration strategy is lift-and-shift and/or light re-platforming. Timelines can extend by a few weeks if significant refactoring is needed.

:::image type="content" source="./images/migrate-from-aws-phases.svg" alt-text="Diagram showing three phases of migrating workloads from AWS to Microsoft Azure. Across the top, three labeled boxes indicate phases with durations: Before migration (2–4 weeks), During migration (3–7 weeks), and After migration (1–2 weeks). Each box includes a summary of key activities such as planning, infrastructure setup, and optimization. Below, a horizontal sequence of five icons represents steps: Plan, Prepare, Execute, Optimize, and Decommission." lightbox="./images/migrate-from-aws-phases.svg" border="false":::

*Guidelines for a moderately complex workload.*

## Prerequisites

Before you begin migration planning and execution, ensure you have the following in place:

- An **[Azure platform and application landing zone](/azure/cloud-adoption-framework/ready/enterprise-scale/implementation)**.
- *Stakeholder alignment:* Share timelines, budget estimates, and project milestones with stakeholders to ensure that all parties are aligned.
- *Project plan and timeline:* Collaborate with the platform and operations teams to develop a thorough overall migration plan with your estimated timeline.
- *Tooling:* Ensure all workload tooling is documented and understood by necessary project teams.  Investigate and train on new tooling to adopt for the Azure environment.
- *Support strategy in place:* Purchase a Microsoft support plan and investigate options for free/community support.

In addition to these measures, consider completing a [[Migration Readiness Assessment]]. This assessment scores your readiness to migrate across 10 dimensions.

To help with planning and successful executing your workload migration, work through the following five phases.

## Plan

The goal of this phase is to **assess** the current state of the workload and the environment it is running in and then **design** the target state and architecture.

**Assess your AWS environment**

- **Existing workload architecture:** Ensure you have a fully documented workload architecture that is well understood by the migration team. This includes all workload dependencies (network configurations, data flows, external integrations). 
- **Identify critical workload flows:** Map out essential user, as well as system interactions and [workflows.](/azure/well-architected/reliability/identify-flows) When designing the target architecture in the next step, this helps prioritize reliability efforts and ensures that the most important and impactful components are protected against failure.
- **Create a detailed inventory** of your current AWS environment that is required for running the workload (all servers, storage, database, and services), along with usage patterns, performance metrics and licensing requirements.
- **Success criteria and KPIs:** Define what good looks like in terms of your workload running in Azure after a successful migration. This should include performance metrics (like throughput and response times), security and reliability targets and costs. You can use your inventory to estimate Azure costs and potential savings with [Azure Migrate assessments](/azure/migrate/cost-estimation) or the [Azure pricing calculator](https://azure.microsoft.com/en-us/pricing/calculator/).
- **Assess your team's skills:** Include Azure training in your project timeline to ensure that the workload and operations teams are prepared.

For detailed guidance, see the [CAF Plan migration](azure/cloud-adoption-framework/migrate/plan-migration) guide.

**Design your target architecture**

**Start with networking:** Provide the networking requirements for your workload to the platform team for a new spoke network. Your request should include not only the target architecture, but also the migration connectivity. Learn more about how to [migrate networking from AWS](/azure/migration/migrate-networking-from-aws). 

**Choose your migration cutover model as a first step:** When practical, prefer an active-active design over a hot-cold or hot-warm design. Once you have made that determination, design your workload architecture accordingly.

To **identify Azure services** that you can use to build your workload in Azure, refer to the AWS to Azure resource comparison guides:

- [Azure compute services comparison](/azure/architecture/aws-professional/compute)
- [Azure data and AI services comparison](/azure/architecture/aws-professional/data-ai)
- [Azure database services comparison](/azure/architecture/aws-professional/databases)
- [Azure messaging services comparison](/azure/architecture/aws-professional/messaging)
- [Azure networking services comparison](/azure/architecture/aws-professional/networking)
- [Azure security services comparison](/azure/architecture/aws-professional/security-identity)
- [Azure storage services comparison](/azure/architecture/aws-professional/storage)

- **Document your migration decisions:** Document the resources that you won’t migrate and any architecture decisions you made. 
- **Reduce risks:** Identify any high-risk components or flows and build out POCs as needed to test and mitigate those risks. Consider performing a [failure mode analysis](/azure/well-architected/reliability/failure-mode-analysis) to proactively uncover potential points of failure and assess their impact on the reliability of your workload. 
- **Check availability:** Check Azure service availability and capacity in your preferred region, specifically if you plan to use specialized resource types.
- Ensure **compliance and security** requirements are addressed. Learn more about [migrating security from AWS](/azure/migration/migrate-security-from-aws).
- **Choose migration approaches per component:** Determine whether you need to use different approaches for different components. Use the decision framework above and decide your strategy for each component. Allocate time for refactoring of any code. 

**Develop a migration plan and runbook**

Document the sequence of steps at a high level. When practical, take a phased approach, including a phased cutover.  If you are planning a one-time all-at-once cutover, define the exact steps, sequence, and timing of the move. Include the  planned outage window in your documentation. Consider including a dry-run, especially for complex cutovers. Document your rollback strategy, DNS TTLs and how to test success metrics.

**Review**

Review the plan with stakeholders and reconcile differing expectations. Include IT security and risk management teams from the start and ensure they sign off on the plan. A joint workshop at this stage can help minimize delays in later stages.

**Tools**

- Well Architected Framework Review (on both platforms)
- Azure Migrate
- AWS tools

Before moving to the next stage, ensure all plans have been agreed upon by stakeholders and decision-makers.

## Prepare

In this phase you build out your Azure environment, implement any changes if refactoring is required, setup your CI/CD tooling and pipelines and perform tests.

- **Deploy and configure Azure infrastructure**: Use Infrastructure as Code (IaC) to deploy your resources, to ensure consistency and repeatability. If your teams use Terraform on AWS, they can continue using it, however you will need to write new Terraform scripts and modules for your Azure resources. Focus on non-production environments first and validate everything before moving on to staging and production environments.
- **Test your application landing zone and networking**: Ensure that your Virtual WAN or hub network and any other foundational services like ExpressRoute or VPN connections are configured to support both the target workload and the migration process. Validate that connectivity is working end-end across your Azure and AWS environments.
- **Refactor your workload early**: Use feature flags to simplify version management between the AWS and Azure environments.
- **Prepare your operational functions**: Build CI/CD pipelines and work with the platform team to implement workload monitoring. Collaborate with the security team to implement security monitoring and validate the Azure architecture.

For guidance on preparing your workloads and building your Azure environment, see the [CAF Prepare workloads](/azure/cloud-adoption-framework/migrate/prepare-workloads-cloud) guide.

## Execute

- **Execute your data migration:** Align the order of operations with the migration model you have selected. For active replication scenarios, start with the setup of your continuous data synchronization between AWS and Azure. This ensures minimal downtime and data consistency during cutover. For backup-and-restore models, start with a full backup of your AWS data, transfer it securely to Azure, and then restore it into the target environment. Validate the integrity of the data before you proceed with the next step.
- **Configure your application's components:** Point components to their dependencies, some of which might still be on AWS initially. In an incremental migration approach, your database might still be in AWS and will be replicated later.
- **Connectivity and networking modifications:** Ensure that your Azure resources can reach anything that still remains in AWS and vice versa if needed. Adjust your firewall and Network Security Groups (NSGs) rules and policies as well as routing as required. Troubleshooting this component can be tricky. Take your time and check everything step-by-step. Security group misconfigurations are a common pitfall.
- **Testing** includes functional testing, performance testing, and failure testing. Use [**Azure Chaos Studio**](/azure/chaos-studio/) to simulate potential faults (such as VM or networking outages) and validate that the migrated workload remains resilient under those circumstances.
- **Iterate and fix** any issues you encounter. Common pitfalls include paths in scripts or APIs calls, Azure service limits and quotas that might need increasing. Some Azure resource features may require different implementations in Terraform.
- **Cutover to Azure:** How you execute this step depends on your chosen strategy. In the recommended, incremental active-active approach, you gradually shift traffic from AWS to Azure based on a given criteria (criteria could include regions, user types, or application features). In the all-at-once approach, you switch all traffic at once during a cutover time. You must ensure that all data is synced and all components are prepared to accept production traffic. Then you switch all connections to Azure and bring up your Azure environment as primary. A maintenance window is recommended in which you briefly pause traffic/the application to avoid inconsistencies. Automate any health checks and monitor in real time during the cutover.
- **Follow your runbook**: In either scenario, follow your runbook and communicate with stakeholders about cutover progress and any expected impact to the timeline or any other issues they should be aware of.
- **Take advantage of the active-active design**: Deallocate AWS components gradually without downtime.
- **Post-cutover verification:** Closely monitor your workload metrics in Azure, and if they degrade severely or if you detect a critical bug, execute your rollback plan and be ready to revert traffic back to AWS. Run a full regression test in production if possible and check all components. Run smoke tests for critical functions, watch your security logs, and ensure all monitoring signals and alerts are green. After a day or two, monitor costs and usage to ensure there are no runaway resources incurring costs. 

For detailed cutover guidance, see the [CAF Execute migration](/azure/cloud-adoption-framework/migrate/execute-migration) guide.

## Validate and optimize

Congratulations, your workload is now running on Azure! In this final phase, focus on validating workload stability and efficiency, and the shutdown of resources in AWS.

- **Monitor and fine-tune:** Closely track your workload trends for any errors, performance bottlenecks or unusual patterns, especially in the first 1-2 weeks. This step includes right-sizing components, ensuring your scaling strategy is working as intended, watching budget thresholds, and checking/validating your disaster recovery configurations and backups. Prioritize the remediation of any security issues.
- **Measure against baselines**: Verify that the agreed upon KPIs, like throughput, latency, and error rates, are being met and compare favorably to the AWS measurements.
- **Plan for future improvements:** Create a work backlog for any non-urgent improvements like opportunities for cost optimization and added resilience.
- **Celebrate milestones**: Sign-off when your minimum viable cutover has been achieved and all tests validate a successful migration outcome.

**Tools**
Microsoft Defender for Cloud

For additional recommendations for post-migration tuning and cost optimization, see the [CAF Optimize workloads after migration](/azure/cloud-adoption-framework/migrate/optimize-workloads-after-migration) guide.
## Decommission

This is the final step in the workload migration. Proceed once you are confident in how your workload operates in Azure. 

- **Finalize your data cutover:** If you took an active-active approach with AWS and Azure running in parallel, and especially if you kept your primary database instance in AWS, decide when to fully remove the AWS instance from the workflow and switch your apps to only use the Azure database. Decommission any data synchronization or replication processes.
- **Take any final backups and snapshots** for archival purposes or just in case.
- **Plan the AWS sunset date:**  Stop and/or delete any AWS ECS instances, databases and services that are no longer needed. Ensure that nothing critical is still running in AWS before deleting.
- **Clean up artifacts**: Update CMDB, billing, documentation.

For a thorough review of decommissioning steps, see the [CAF Decommission source workload](/azure/cloud-adoption-framework/migrate/decommission-source-workload) guide.

**Checklist**

- [ ] Confirm cutover success
- [ ] Notify stakeholders
- [ ] Archive backups
- [ ] Turn off replication
- [ ] Delete AWS resources
- [ ] Update internal documents


## Conclusion

Migrating a workload, especially if it is the first, is an intensive project. With this guide and the right approach it can be executed smoothly and with confidence. With a concrete and well thought out plan, relevant stakeholders on board, a solid target architecture, the right migration strategy for each component of the workload and following a phased approach with clear checklists, you set the stage for success. 

Remember to embrace an incremental switch over if possible to reduce risk and anxiety for everyone involved. 

This is not just a technical challenge, it is also a learning journey for your whole team, especially if this is the first workload.

Migrations require a lot of work and coordination as well as cooperation across teams with often late hours to verify everything works as intended. In the end, after a successful migration and after decommissioning your AWS workloads, celebrate your win! 

## Next steps

Consider conducting a [Well-Architected Review](/azure/well-architected/) of your new Azure workload to ensure your workload and team's practices are aligned with industry best practices.


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
- [Copy data from Amazon S3 to Azure Storage (AzCopy)](/azure/storage/common/storage-use-azcopy-s3)
- [Copy data from Amazon S3 to Azure Storage (Azure Data Factory)](/azure/data-factory/data-migration-guidance-s3-azure-storage)
- [Connect AWS and Azure using a BGP-enabled VPN gateway](/azure/vpn-gateway/vpn-gateway-howto-aws-bgp)
- [Migrate Amazon API Gateway to Azure API Management](/azure/api-management/migrate-amazon-api-gateway-to-api-management)
- [Discover, assess, and migrate Amazon Web Services (AWS) VMs to Microsoft Azure](/azure/migrate/tutorial-migrate-aws-virtual-machines)




