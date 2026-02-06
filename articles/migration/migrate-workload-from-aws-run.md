---
title: Run Your Migration from Amazon Web Services (AWS) to Azure
description: Learn how to run the migration from AWS to Azure. Follow proven cutover strategies, sync data, validate workloads, and ensure rollback readiness.
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
#  Run your workload migration from Amazon Web Services (AWS) to Azure

This article is part of a series about [how to migrate a workload from Amazon Web Services (AWS) to Azure](/azure/migration/migrate-workload-from-aws-introduction). 

The run phase consists of these stages:

> [!div class="checklist"]
> * Before cutover
> * During cutover
> * After cutover

:::image type="icon" source="images/goal.svg" alt-text="Goal icon"::: The goal of this phase is to migrate the AWS workload to Azure within the agreed upon downtime and data loss constraints. Follow your runbook closely and communicate with stakeholders throughout the process.

> [!IMPORTANT] 
> Don't rush testing or skip validation steps.
> 
> The run phase carries the highest risk of service disruption. Data synchronization problems, network misconfigurations, or unexpected application behaviors can cause outages or data loss.

## Before cutover

1. **Open your negotiated maintenance window.**

1. **Run your data migration.** Align the order of operations with your cutover model. Fully script and test all data migration steps in nonproduction environments before you start to help ensure that these steps run reliably during cutover.

   - For live, or active, replication scenarios, set up continuous data synchronization between AWS and Azure. This approach minimizes downtime and helps ensure data consistency during cutover.

   - For backup-and-restore models, back up all of your AWS data. Securely transfer the backup to Azure and then restore it in the target environment. Validate the integrity of the data before you take the next step.

1. **Configure your application's components.** Point components to their dependencies. Some of these dependencies might still be on AWS. In a phased migration approach, for example, you might keep your database on AWS initially and migrate it later.

1. **Modify connectivity and networking.** Ensure that your Azure resources can reach dependencies on AWS and, conversely, that your AWS resources can reach dependencies on Azure if needed. Adjust your firewall and network security group (NSG) rules and policies as well as routing to meet requirements. Test and validate all connectivity changes in earlier phases to minimize troubleshooting in this phase.

1. **Run simple tests.** Do functional testing, performance testing, and failure testing. Keep these tests simple. Do extensive functional or load testing in the preceding phases.

1. **Iterate and fix problems early.** Plan thoroughly to help minimize fixes during this stage. If you run into problems, resolve them now. Common pitfalls include invalid paths in scripts or API calls, exceeding Azure service limits, and meeting quotas that you might need to increase. If you use Terraform, some Azure resource features might require different implementations.

1. **Reduce the time to live (TTL).** Reduce the TTL before cutover and account for propagation delay in your rollback planning.

1. **Update fully qualified domain names (FQDNs) and Domain Name System (DNS) routing.** Apply the FQDN transition plan that you defined during the planning phase. Update DNS records to point existing FQDNs to Azure endpoints or modify application configurations to use new Azure FQDNs. For public-facing services, carefully coordinate DNS cutover to minimize downtime.

## During cutover

> [!IMPORTANT]
> Follow your runbook and communicate with stakeholders about cutover progress. Include any expected changes to the timeline or other problems that they should be aware of.

How you complete this step depends on your chosen strategy. In the recommended, blue-green approach, you switch all traffic at the same time during a cutover window. You must sync all data and prepare components to accept production traffic. Then you switch all connections to Azure and bring up your Azure environment as the primary environment. We recommend a maintenance window during which you briefly pause traffic or the application to avoid inconsistencies. Automate health checks and monitor in real time during the cutover.

Work closely with operations teams to ensure that you address any emerging problems immediately. The migration team and operations engineers should actively monitor a real-time health dashboard by using Azure Monitor or custom telemetry. Any anomalies should trigger immediate alerts and responses. Prepare to roll back if you can't resolve problems within the rollback criteria that you defined in the [planning phase](/azure/migration/migrate-workload-from-aws-plan).

## After cutover

- **Maintain rollback readiness.** Keep the AWS environment available during your validation window in case you need to roll back. When you're confident in the Azure environment, proceed to decommission AWS resources.

- **Do post-cutover verification.** Closely monitor your workload metrics in Azure. If they degrade severely or if you detect a critical bug, implement your rollback plan and be ready to revert traffic back to AWS. Run a full regression test in production if possible and check all components. Run smoke tests for critical functions, watch your security logs, and ensure that all monitoring signals and alerts are green. After a day or two, monitor costs and usage to find any runaway resources that might incur unnecessary costs.

- **Update continuous integration and continuous delivery (CI/CD) pipelines for Azure.** Update deployment pipelines to stop targeting AWS and only target Azure.

- **Update documentation and procedures.** Revise all production runbooks, support documents, and operational procedures to reflect the new Azure environment.

- **Hand off operational monitoring.** Confirm that the operations team assumes ownership of monitoring the Azure environment. They should now use Azure Monitor dashboards and alerts configured earlier to monitor the workload's health. Address any knowledge gaps as the team transitions into primary support for the Azure deployment.

For more information, see [Migrate to the cloud](/azure/cloud-adoption-framework/migrate/execute-migration).

## Checklist

| &nbsp;  | Deliverable tasks                   |
| ------- | ----------------------------------- |
| &#9744; | Migrate data                        |
| &#9744; | Configure application components    |
| &#9744; | Modify connectivity and networking  |
| &#9744; | Do functional tests                 |
| &#9744; | Do performance tests                |
| &#9744; | Do failure testing                  |
| &#9744; | Fix all problems                    |
| &#9744; | Reduce the TTL                      |
| &#9744; | Update FQDNs and DNS routing        |
| &#9744; | Maintain rollback readiness         |
| &#9744; | Update CI/CD pipelines for Azure    |
| &#9744; | Do post-cutover verification        |
| &#9744; | Update documentation and procedures |
| &#9744; | Hand off operational monitoring     |

## Next step

> [!div class="nextstepaction"]
> [Evaluate your migration status](./migrate-workload-from-aws-evaluate.md)