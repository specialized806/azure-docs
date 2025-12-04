---
title: Migrate a Workload from Amazon Web Services (AWS) - Execute
description: Learn how to execute migration of a single workload from AWS to Azure
ms.author: rhackenberg
ai-usage: ai-assisted
ms.date: 11/24/2025
ms.topic: concept-article
ms.service: azure
ms.collection:
  - migration
  - aws-to-azure
---

# Migrate a workload from Amazon Web Services (AWS) - Execute

The execute phase consists of three steps: **before** cutover, **during** cutover, and **after** cutover. 

> [!div class="checklist"]
> * before cutover
> * during cutover
> * after cutover

The goal of this phase is to migrate your workload to Azure with minimal downtime and disruption. Follow your runbook closely and communicate with stakeholders throughout the process.

> [!WARNING]
> Don't rush testing or skip validation steps. 
> 
> The execute phase carries the highest risk of service disruption. Data synchronization issues, network misconfigurations, or unexpected application behaviors can cause outages or data loss. 


## Before cutover

1. **Execute your data migration:** Align the order of operations with the cutover model you selected.
	- For active replication scenarios, start with the setup of your continuous data synchronization between AWS and Azure. This approach ensures minimal downtime and data consistency during cutover. 
	- For backup-and-restore models, start with a full backup of your AWS data. Securely transfer the backup to Azure, then restore it into the target environment. Validate the integrity of the data before you proceed with the next step.
2. **Configure your application's components:** Point components to their dependencies, some of which might still be on AWS initially. In an incremental migration approach, your database might still be in AWS and will be replicated later.
3. **Connectivity and networking modifications:** Ensure that your Azure resources can reach anything that still remains in AWS and vice versa if needed. Adjust your firewall and Network Security Groups (NSGs) rules and policies as well as routing as required. Troubleshooting this component can be tricky. Take your time and check everything step-by-step. Security group misconfigurations are a common pitfall.
4. **Testing:** Perform functional testing, performance testing, and failure testing. Use [**Azure Chaos Studio**](/azure/chaos-studio/) to simulate potential faults, such as VM or networking outages. Validate that the migrated workload remains resilient under those circumstances.
5. **Iterate and fix** any issues you encounter. Common pitfalls include paths in scripts or APIs calls, Azure service limits, and quotas that might need to increase. Some Azure resource features can require different implementations in Terraform.

## During cutover

> [!IMPORTANT]
> Follow your runbook and communicate with stakeholders about cutover progress and any expected impact to the timeline or any other issues they should be aware of.

How you execute this step depends on your chosen strategy. In the recommended, incremental active-active approach, you gradually shift traffic from AWS to Azure based on a given criteria (criteria could include regions, user types, or application features). In the all-at-once approach, you switch all traffic at once during a cutover time. You must ensure that all data is synced and all components are prepared to accept production traffic. Then you switch all connections to Azure and bring up your Azure environment as primary. A maintenance window is recommended in which you briefly pause traffic or the application to avoid inconsistencies. Automate any health checks and monitor in real time during the cutover.

## After cutover

- **Take advantage of the active-active design**: Deallocate AWS components gradually without downtime.
- **Update CI/CD pipelines for Azure:** Update deployment pipelines to stop targeting AWS and only target Azure.
- **Post-cutover verification:** Closely monitor your workload metrics in Azure, and if they degrade severely or if you detect a critical bug, execute your rollback plan and be ready to revert traffic back to AWS. Run a full regression test in production if possible and check all components. Run smoke tests for critical functions, watch your security logs, and ensure all monitoring signals and alerts are green. After a day or two, monitor costs and usage to ensure there are no runaway resources incurring costs. 
I realized we don't talk about post-mortems. It could fit here or in the conclusion article...I think here might be better because the conclusion probably won't get the level of attention that this article will.
For detailed cutover guidance, see the [CAF Execute migration](/azure/cloud-adoption-framework/migrate/execute-migration) guide.

## Next step

> [!div class="nextstepaction"]
> [Evaluate your migration status](./migrate-workload-from-aws-evaluate.md)