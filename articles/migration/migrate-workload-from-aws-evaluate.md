---
title: Evaluate your Workload from Amazon Web Services (AWS) After Migration to Azure
description: Learn how to evaluate the migration of a single workload from AWS to Azure. Monitor performance, verify baselines, and confirm data cutover.
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
# Evaluate your workload from Amazon Web Services (AWS) after migration to Azure

This article is part of a series about [how to migrate a workload from Amazon Web Services (AWS) to Azure](/azure/migration/migrate-workload-from-aws-introduction). 

Congratulations, your workload is serving its users from Azure!

The evaluate phase consists of these steps:

> [!div class="checklist"]
> * Validate the cutover.
> * Sign off on the migration.

:::image type="icon" source="images/goal.svg" alt-text="Goal icon"::: The goal of this phase is to confirm that your workload in Azure meets the functional, performance, reliability, security, and cost baselines that you established in the planning phase on AWS.

> [!IMPORTANT] 
> Incomplete monitoring, insufficient performance testing, or ineffective cost and security reviews can hide problems that can cause outages, data exposure, or budget overruns later.

## Validate successful cutover

- **Monitor and fine-tune the workload.** Closely track your workload trends for any errors, performance bottlenecks, or unusual patterns, especially in the first one to two weeks. Rightsize components, ensure that your scaling strategy works as intended, monitor budget thresholds, and check and validate your disaster recovery configurations and backups. Prioritize the remediation of any security problems. Work with your operations team to fine-tune alert thresholds and dashboard views as needed.

- **Measure against baselines.** Verify that you meet the baseline key performance indicators (KPIs) you documented in the planning phase, like throughput, latency, and error rates. The KPIs should be comparable to the AWS measurements.

- **Validate cutover via AWS logs.** [AWS CloudTrail](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-user-guide.html) logs every API call and console action in your AWS account. It exposes any of your workload's components that still call any AWS service. Check and validate that these logs don't show any unintended workload traffic.

- **Check firewall and network flow logs.** Review firewall and network flow logs in Azure to ensure that only the anticipated network traffic occurs. As part of your equivalent migration, specific network traffic allowances might be obsolete now. You can remove them from the network allowlists.

- **Confirm your data cutover.** Confirm that all production writes and reads are served from Azure (based on your cutover strategy). If you're using continuous replication or synchronization, stop it after you confirm Azure has the authoritative copy of the data.

- **Perform key operation.** Perform key routine operations, such as rotating certificates or taking an off-site backup. Exercise any gated operations access, such as JIT admin elevation. These validations ensure your workload ops team or automation has sufficient management control over the environment.

- **Schedule disaster recovery failover test:** If your workload supports it, schedule a disaster recovery failover test after the core of the workload is stabilized.

## Sign-off

- **Update architectural knowledge base:** Ensure your workload's knowledge base reflects any last-minute changes to the infrastructure or operational procedures that deviated from the original plan.

- **Complete handover to operations:** Before final sign-off, hold a handover meeting with the operations team. Ensure they acknowledge full responsibility for the Azure workload’s monitoring and support. Review the new alerting setup (Azure Monitor alerts, Azure Service Health notifications) and confirm the team is comfortable with the updated runbooks and dashboards.

- **Sign-off milestones**: Sign off only after meeting all predefined success criteria and once testing confirms the migration was successful. Refer back to the acceptance criteria defined in the [planning phase](/azure/migration/migrate-workload-from-aws-plan).

- **Conduct a post-mortem/retrospective:** Conduct a post-mortem that captures lessons learned from the workload migration. Have the migration team discuss what went well, what can be improved next time, and any unexpected issues that came up. Document the findings and share them with the stakeholders and other teams in your organization that are planning a workload migration.

- **Plan for future improvements:** Create work items in your backlog for any non-urgent improvements like opportunities for cost optimization, added resilience, or introduced technical debt.

## Checklist

| &nbsp;  | Deliverable tasks                        |
| ------- | ---------------------------------------- |
| &#9744; | Monitor and fine-tune                    |
| &#9744; | Measure against baselines                |
| &#9744; | Validate successful cutover              |
| &#9744; | Check firewall and network flow logs     |
| &#9744; | Confirm data cutover                     |
| &#9744; | Perform key operations                   |
| &#9744; | Schedule disaster recovery failover test |
|         | Update architectural knowledge base      |
| &#9744; | Complete handover to operations          |
| &#9744; | Sign-off milestones                      |
| &#9744; | Conduct post-mortem/retrospective        |
| &#9744; | Plan future improvements                 |

## Next step

> [!div class="nextstepaction"]
> [Decommission your AWS resources](./migrate-workload-from-aws-decommission.md)