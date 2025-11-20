## Overview

This article equips technical solutions architects and hand-on engineers with actionable, prescriptive guidance of this article is to help teams migrate single workloads from Amazon Web Services (AWS) to Azure.

It covers the full migration lifecycle, from planning and preparation, to execution and validation, to decommissioning of AWS resources.

Migrating a workload from AWS is a strategic initiative that requires careful planning and stakeholder alignment. This article focuses on workloads that go from simple to moderately complex and can benefit from a pragmatic migration strategy. 

We cover:

- Step-by-step migration phases
- Migration strategy framework
- Timeline and best practices
- Links with further information

## Migration strategies to consider

There are three types of strategies to consider. **Migration strategy** refers to how a workload is moved to Azure. It is concerned with the technical transformation. **Cutover strategy** is how production traffic is switched. It refers to the operational transition. **Data strategy** focuses on how to move the data itself from AWS to Azure. 
 
Choosing the right migration strategy for a single workload is crucial. The main options include rehost (aka lift-and-shift), replatform and in some cases refactor. We recommend to move the workload with minimal changes. 


**Migration Strategy

| **Workload Characteristics**                                                                 | **Recommended Strategy**                         | **Rationale & Notes**                                                                                                                                                                                                     |
| -------------------------------------------------------------------------------------------- | ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Legacy or tightly-coupled system (e.g. older enterprise app on VMs, not easily modified)** | **Rehost (Lift-and-Shift)**                      | Easiest and safest: recreate the workload in Azure VMs or equivalent services with minimal changes. Use this when speed is a priority or application changes are not feasible. You can modernize after a successful move. |
| **Modern, cloud-ready application (e.g. containerised microservices, stateless apps)**       | **Replatform (Minor modifications)**             | Take advantage of Azure’s managed services (AKS, App Service, Azure SQL Database, etc.) to improve ops and scalability. The app can be moved with some tweaks, leveraging cloud offerings for databases, caching, etc.    |
| **Mixed components (some parts legacy, some modern)**                                        | **Hybrid approach** (Mix of rehost & replatform) | You might rehost certain components and replatform others. For example, migrate the database to Azure via rehost, but move the front-end to an Azure App Service. Do the simplest thing for each component.               |

When deciding for a specific migration strategy, consider a combined approach. Your workload's database can be rehosted and your application servers replatformed. 


**Cutover Strategy

If feasible, perform the migration in small incremental steps rather than a big bang. An active-active multi-cloud setup during migration let's you migrate and test gradually and with reduced risk. This means you will continue to run your workload in AWS, build your Azure environment and workload up and then run it in parallel for a short time.

This approach will:
- reduce risks as problems can be caught and fixed with fallback available by routing the traffic back to AWS.
- enable live testing under real workload conditions.

Drawbacks are that you will incure costs temporarily on both clouds during the transition. Most teams however value the reduced risk and find it worth the temporary cost.


**Data Strategy**

Plan which data migration approach you want to use. This depends on the amount of data, type of data storage and usage requirements. Decide between offline migration, live replication and/or file storage. 

Learn more about migration strategies for migrating your [databases](- [Migrate databases from AWS to Azure](https://learn.microsoft.com/en-us/azure/migration/migrate-databases-from-aws)) and/or [storage](https://learn.microsoft.com/en-us/azure/migration/migrate-storage-from-aws) from AWS.

## Timeline assumptions

The migration of a workload can span several weeks or months. The duration depends on the complexity of the workload and the chosen migration strategy. The timeline below shows a typical workload migration for a moderately complex workload. The chosen migration strategy is lift-and-shift and/or light replatforming. Timelines will extend by a few weeks in case of significant refactoring.

![[Pasted image 20251120133135.png]]
- [ ] include timeline and details in graphic

**Before migration:** Plan & Prepare 2-4 weeks
- includes the gathering of requirements, design of the goal architecture, landing zone adjustments and assessments as well as proof of concept
**During migration:** Implementation and Execution 3-7 weeks
- setup of infrastructure, deployment of resources, migration of data and apps, testing and cutover
**After migration:** Validate and decommission 1-2 weeks
- Validate performance, optimize infrastructure and configuration, monitor stability, decommission AWS resources

*Guideline for a single moderately complex workload.*

## Prerequisites

Before you dive into the mgiration, ensure you have the following in place:

- [Azure Landing Zone](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/implementation) 
- Stakeholder alignment
- Project plan and timeline
- Tooling
- Support strategy in place (Support plan via Microsoft or free/community support)

In addition to above, is recommended to fill out a short [[Migration Readiness Assessment]] that scores your readiness to migrate across 10 dimensions.

To help with planning and successful execution of your workload migration, we will follow along in the following five phases.

## Plan

Goal of this phase is to **assess** the current state of the workload and the environment it is running in and then **design** the target state and architecture.

**Assess environment**

- Gather info, estimate cost and savings, dependencies
- Understand workload maturity
- Collect KPIs like performance, security and reliability targets
- Assess your team's skills: Ramp-up on Azure takes time, so it is recommended to include training in your timeline.
- Requirements: Current state of the workload as well as the target state in Azure. This includes compute, storage, connectivity and dependencies.
- Success criteria and KPIs: definition of what good looks like in terms of your workload running in Azure after a successful migration. This will include performance metrics (throughput, response times etc.) and also includes costs. 

For detailed guidance, see [CAF Plan migration](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/migrate/plan-migration).

**Design target architecture**

**Start with networking:** This includes not only the target architecture, but also the migration connectivity. Consider Virtual WAN, hubs/spokes, VPN to AWS VPC, DNS, NSGs. Learn more about how to [migrate networking from AWS](https://learn.microsoft.com/en-us/azure/migration/migrate-networking-from-aws). 

**Choose migration cutover model upfront:** Active-active vs big bang; design topology accordingly.

To **identify Azure services** that your workload consists of, look at the AWS to Azure component comparison:

- [Azure compute services map](https://learn.microsoft.com/en-us/azure/architecture/aws-professional/compute)
- [Azure data and AI services map](https://learn.microsoft.com/en-us/azure/architecture/aws-professional/data-ai)
- [Azure database services map](https://learn.microsoft.com/en-us/azure/architecture/aws-professional/databases)
- [Azure messaging services map](https://learn.microsoft.com/en-us/azure/architecture/aws-professional/messaging)
- [Azure networking services mapping](https://learn.microsoft.com/en-us/azure/architecture/aws-professional/networking)
- [Azure security services map](https://learn.microsoft.com/en-us/azure/architecture/aws-professional/security-identity)
- [Azure storage services map](https://learn.microsoft.com/en-us/azure/architecture/aws-professional/storage)

- **Document** what you won’t migrate and any architecture decisions you made. 
- **Reduce risks:** Identify any high-risk components and perform and PoCs as needed.
- **Check availability:** always check Azure service availability and capacity in your preferred region, specifically if these are specialized resouces.
- Ensure **compliance and security** requirements are taken care off. Learn more about [migrating security from AWS](https://learn.microsoft.com/en-us/azure/migration/migrate-security-from-aws).

**Choose migration approach per component**

Use the decision framework above and decide your strategy for each component. Allocate time for refactoring of any code. 

**Write a migration plan and runbook**

Document the sequence of steps on a high level. We recommend a phased approach. That requires phasing the cutover. If you are planning to use the big bang approach, plan the exact steps, order and timing of the move and the outage window needed. Consider inclusion of a dry-run, especially for complex cutovers. Document your rollback strategy, DNS TTLs and how to test success metrics.

**Review**

Especially if multiple stakeholders are involved, it is advisable to review the plan with them and reconcile differing expectations. Include IT security and risk management teams from the start and ensure they are signing off on the plan. A joint workshop at this stage can be useful to avoid delays in later stages.

**Tools**

- Well Architected Framework Review (on both platforms)
- Azure Migrate
- AWS tools

Before moving to the next stage, ensure all plans have received green light from the relevant stakeholders and decision-makers.

## Prepare

In this phase you build out your Azure environment, implement any changes if refactoring is required, setup your CI/CD tooling and pipelines and perform tests.

- **Setup Azure Infrastructure**: We recommend to use Infrastructure as Code (IaC) to deploy your resources, as this ensures consistency and repeatability. If you teams are used to Terraform on AWS, they can continue using it, however you will need to write new Terraform scripts/modules for your Azure resources. Focus on non-prod environment first and validate everything before moving on to staging and production environments.
- **Build or use existing Landing Zone**: Deploy Virtual WAN, hubs, VPN, AKS cluster; test connectivity both ends.
- **Refactor workload early**: Enable multi-cloud mode with config flags; validate in Azure.
- **Set up operational plumbing**: Traffic Manager, CI/CD, identity mapping, monitoring.

For guidance on preparing your workloads and building your Azure environment, see [CAF Prepare workloads](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/migrate/prepare-workloads-cloud).

## Execute

- **Execute Data migration** as per your migration plan and chosen strategy. 
- **Deploy your application's components**: this can mean launching your webservers on Azure VMs or containers. Configure them to point to their dependencies, some of which might still be on AWS initially. In an incremental migration approach, your database might still be in AWS and will be replicated later.
- **Connectivity and networking tweaks:** Take care that your Azure resources can reach anything that still remains in AWS and vice versa if needed. Adjust your firewall rules and NSGs as well as routing as required. Troubleshooting this component can be tricky. Take your time and check everything step by step. Especially security group rules are a common pitfall.
- **Testing** includes functional testing, performance testing as well as failure testing
- **Iterate and fix** any issues you encounter. Common pitfalls include paths in scripts or APIs calls, Azure service limits and quotas that might need increasing. Some Azure resource features may require different implementations in Terraform.
- **Cutover to Azure:** How you will execute this depends on the chosen strategy. In the recommended, incremental active-active approach, you will gradually increase the proportion of the traffic that gets sent to Azure until 100% is sent to Azure. In the big bang approach you will switch all traffic at once during a cutover time. You have to ensure all data is synced and everything is ready in Azure. Then you will switch all connections to Azure and bring up your Azure environment as primary. A maintenance window is recommended in which you briefly pause traffic/the application to avoid inconsistencies. Automate any health checks and monitor in real time during cutover.
- **Follow runbook**: In either scenarios, follow your runbook and communicate to stakeholders about cutover timing and any expected impact.
- **Exploit active-active design**: Remove AWS components gradually without downtime.
- **Post-cutover verification:** Keep monitoring metrics in Azure and if they degrade severly or a citical bug appears, execute your rollback plan and be ready to revert traffic back to AWS. Run a full regression test in production if possible and check all components, run smoke tests for major functionality, keep an eye on security logs and ensure all monitoring and alerts are green. After a day or two, monitor cost and usage to ensure there are no runaway resources occuring cost. 

For detailed cutover guidance, see [CAF Execute migration](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/migrate/execute-migration).

## Validate & Optimize

Now that the workload is running on Azure - congratulations! In this final phase, focus on ensuring that the deployment has been smooth, cost-effective, the workload is running stable and after validation and optimization, shutting down resources in AWS.

- **Monitor and fine-tune** your workload by closely watching for any errors, performance bottlenecks or unusual patterns, especially in the first 1-2 weeks. This step includes right sizing of components, ensuring auto-scale is working as intended, watching budgets/alerts and checking/validating disaster recovery and backups. Ensure any security issues are closed immediately.
- **Measure against baselines**: Check and verify that the agreed KPIs are adhered to, like throughput, latency, error rates vs AWS. 
- **Consider to backlog** any items that are not urgent, like opportunities for cost optimization and resilience improvements.
- **Celebrate milestones**: Sign-off when minimum viable cutover has been achieved and all tests validate a successful migration outcome.

**Tools**
Microsoft Defender for Cloud

For post-migration tuning and cost optimization, see [CAF Optimize workloads after migration](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/migrate/optimize-workloads-after-migration).
## Decommission

This is the final step in the workload migration. Proceed once you are confident in how your workload operates in Azure. 

- **Finalize data cutover:** If you run active/active and in parallel, especially if your primary database was still in AWS, decide when to cut the cord and then switch your apps to use the Azure database. Decommission any sync processes.
- **Take any final backups and snapshots** for archival purposes or just in case.
- **Plan sunset date** and remove AWS resources after validation. Stop and/or delete any AWS ECS instances, databases and services that are no longer needed. Check nothing critical is still running in AWS before deleting.
- **Clean up artifacts**: Update CMDB, billing, documentation.

For decommissioning steps, see [CAF Decommission source workload](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/migrate/decommission-source-workload).

**Checklist**

- [ ] Confirm cutover success
- [ ] Notify stakeholders
- [ ] Archive backups
- [ ] Turn off replication
- [ ] Delete AWS resources
- [ ] Update internal documents


## Challenges and solutions

| ⚠️ **Challenge / Pitfall**                                                                 | ✅ **Solution / Recommendation**                                                                                   |
|--------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------|
| Networking, identity, cost, and Well Architected Framework (WAF) challenges                | Review WAF pillars early; validate identity mappings, cost estimates, and network architecture before execution   |
| Communication gaps during migration                                                       | Set up daily or weekly sync calls or a dedicated 'war room' for critical migrations                               |
| Assuming AWS IaC (e.g. Terraform) works seamlessly in Azure                                | Review and rewrite Terraform modules for Azure; validate provider differences and syntax                          |
| Troubleshooting at connectivity boundaries                                                 | Allocate time for detailed network testing; validate NSGs, firewalls, DNS, and routing step-by-step               |
| Lack of familiarity with Azure APIs and tooling                                            | Schedule time for team training; use sandbox environments to explore Azure tools and SDKs                         |
| Migration strategy not framed early (lift vs replatform, cutover model)                   | Decide migration and cutover strategy upfront; document rationale and align with stakeholders                     |
| No structured tracking of progress or readiness                                            | Use checklists and measurable metrics for each phase to track progress and validate readiness                     |
| Missing key roles or expertise (e.g. security, platform teams)                             | Identify and engage all necessary roles early; fill gaps with external support if needed                          |
| Pitfalls not made explicit (e.g. Terraform rewrite, steep learning curve, multi-cloud)    | Document known risks and limitations; share lessons learned and mitigation plans with the team                    |
| Unrealistic timelines or underestimating training/troubleshooting effort                  | Build buffer time into the schedule; plan for training, testing, and issue resolution realistically               |

## Conclusion

Migrating a workload, especially if it is the first, is an intensive project. With this guide and the right approach it can be executed smoothly and with confidence. With a concrete and well thought out plan, relevant stakeholders on board, a solid target architecture, the right migration strategy for each component of the workload and following a phased approach with clear checklists, you set the stage for success. 

Remember to embrace an incremental switch over if possible to reduce risk and anxiety for everyone involved. 

This is not just a technical challenge, it is also a learning journey for your whole team, especially if this is the first workload.

Migrations require a lot of work and coordination as well as cooperation across teams with often late hours to verify everything works as intended. In the end, after a successful migration and after decommissioning your AWS workloads, celebrate your win! 

## Next steps

Consider conducting a [Well-Architected Review](https://learn.microsoft.com/en-us/azure/well-architected/) on your new Azure workload to ensure you are following best practices.


## Tools & References 

- [Azure for AWS professionals](https://learn.microsoft.com/en-us/azure/architecture/aws-professional/)
- [Azure Migrate documentation](https://learn.microsoft.com/en-us/azure/migrate/)

## Training

- [Introduction to migrating from Amazon Web Services to Microsoft Azure](https://learn.microsoft.com/en-us/training/modules/introduction-to-migrating-aws-to-azure/)
- [Configure and migrate to Azure Database for PostgreSQL](https://learn.microsoft.com/en-us/training/paths/microsoft-learn-azure-database-for-postgresql/)
- [Migrate to Azure Database for PostgreSQL](https://learn.microsoft.com/en-us/training/modules/migrate-azure-database-postgresql-flexible-server/)
## Example workload migrations

- [Migrate AWS Lambda to Azure Functions](https://learn.microsoft.com/en-us/azure/azure-functions/migration/lambda-functions-migration-overview)
- [Migrate Amazon RDS for PostgreSQL to Azure Database for PostgreSQL (offline)](https://learn.microsoft.com/en-us/azure/postgresql/migrate/migration-service/tutorial-migration-service-aws-offline)
- [Migrate Amazon Aurora PostgreSQL to Azure Database for PostgreSQL (offline)](https://learn.microsoft.com/en-us/azure/postgresql/migrate/migration-service/tutorial-migration-service-aurora-offline)
- [AKS for Amazon EKS professionals](https://learn.microsoft.com/en-us/azure/architecture/aws-professional/eks-to-aks/)
- [Copy data from Amazon S3 to Azure Storage (AzCopy)](https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-s3)
- [Copy data from Amazon S3 to Azure Storage (Azure Data Factory)](https://learn.microsoft.com/en-us/azure/data-factory/data-migration-guidance-s3-azure-storage)
- [Connect AWS and Azure using a BGP-enabled VPN gateway](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-aws-bgp)
- [Migrate Amazon API Gateway to Azure API Management](https://learn.microsoft.com/en-us/azure/api-management/migrate-amazon-api-gateway-to-api-management)
- [Discover, assess, and migrate Amazon Web Services (AWS) VMs to Microsoft Azure](https://learn.microsoft.com/en-us/azure/migrate/tutorial-migrate-aws-virtual-machines)




