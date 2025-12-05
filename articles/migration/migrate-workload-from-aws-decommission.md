---
title: Migrate a Workload from Amazon Web Services (AWS) - Decommission
description: Learn how to decommission AWS resources after migrating a single workload from AWS to Azure
ms.author: rhackenberg
ai-usage: ai-assisted
ms.date: 11/24/2025
ms.topic: concept-article
ms.service: azure
ms.collection:
 - migration
 - aws-to-azure
---

# Migrate a workload from Amazon Web Services (AWS) - Decommission

This step is the final step in the workload migration. Proceed when you're confident in how your workload operates in Azure. 

The goal of this phase is to safely retire AWS dependencies, remove redundant resources, and complete the transition to Azure.

> [!WARNING]
>
> If you prematurely delete AWS resources, overlook hidden dependencies, or skip final data and access checks, you risk data loss, unexpected downtime, compliance violations, or lingering cost from orphaned assets.

- **Finalize your data cutover:** If you took an active-active approach with AWS and Azure running in parallel, and especially if you kept your primary database instance in AWS, decide when to fully remove the AWS instance from the workflow and switch your apps to only use the Azure database. Take into consideration the RPO you documented in the planning phase. Decommission any data synchronization or replication processes.
- **Take any final backups and snapshots** for archival purposes or just in case.
- **Retire AWS workload resources:**  Plan the sunset date. Stop and delete any AWS EC2 instances, databases, and services that you no longer need. Ensure that nothing critical is still running in AWS before deleting.
- **Check everything is deleted:** [AWS Config](https://docs.aws.amazon.com/config/latest/developerguide/WhatIsConfig.html) maintains an inventory of all your AWS resources and you can use it during the decommission phase to ensure no resources related to your workload are left active.
- **Clean up artifacts:** Update your configuration management database (CMDB), billing, and documentation.

For a thorough review of decommissioning steps, see the [CAF Decommission source workload](/azure/cloud-adoption-framework/migrate/decommission-source-workload) guide.

## Checklist

| &nbsp;  | Deliverable tasks                |
| ------- | -------------------------------- |
| &#9744; | Finalize data cutover            |
| &#9744; | Take final backups and snapshots |
| &#9744; | Retire AWS resources             |
| &#9744; | Check successful deletion        |
| &#9744; | Clean up artifacts               |

## Next step

> [!div class="nextstepaction"]
> [Conclusion](migrate-workload-from-aws-conclusion.md)