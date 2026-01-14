---
title: Evaluate your workload from Amazon Web Services (AWS) after migration to Azure
description: Learn how to evaluate the migration of a single workload from AWS to Azure
ms.author: rhackenberg
ai-usage: ai-assisted
ms.date: 11/24/2025
ms.topic: concept-article
ms.service: azure
ms.collection:
  - migration
  - aws-to-azure
---
# Evaluate your workload from Amazon Web Services (AWS) after migration to Azure

This article is part of a series on [how to migrate a workload from AWS to Azure](/azure/migration/migrate-workload-from-aws-introduction). 

Congratulations, your workload is now running on Azure! 

The evaluate phase consists of two steps: 

> [!div class="checklist"]
> * validate cutover
> * sign-off

:::image type="icon" source="images/goal.svg" alt-text="Goal  icon"::: The goal of this phase is to confirm your workload in Azure meets functional, performance, reliability, security, and cost baselines you established in the planning phase on AWS.

> [!IMPORTANT] 
> Incomplete monitoring, insufficient performance testing, or weak cost and security reviews can hide issues that only surface later as outages, data exposure, or budget overruns.

## Validate successful cutover

- **Monitor and fine-tune:** Closely track your workload trends for any errors, performance bottlenecks, or unusual patterns, especially in the first one to two weeks. This step includes right-sizing components, ensuring your scaling strategy works as intended, watching budget thresholds, and checking and validating your disaster recovery configurations and backups. Prioritize the remediation of any security issues.
- **Measure against baselines**: Verify that the baseline KPIs you documented in the planning phase, like throughput, latency, and error rates, are met and compare favorably to the AWS measurements.
- **Validate cutover via AWS logs:** [AWS CloudTrail](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-user-guide.html) logs every API call and console action in your AWS account. Check and validate that these logs don't show any unintended workload traffic. If any of your workload's components still call any of the AWS services, CloudTrail exposes this.

## Sign-off

- **Sign-off milestones**: Sign off when you achieve your minimum viable cutover and all tests validate a successful migration outcome. Refer back to your sign-off acceptance criteria that you defined in the [planning phase](/azure/migration/migrate-workload-from-aws-plan).
- **Conduct a post-mortem/retrospective:** Conduct a post-mortem that captures lessons learned from the workload migration. Have the migration team discuss what went well, what can be improved next time, and any unexpected issues that came up. Document the findings and share them with the stakeholders.
- **Plan for future improvements:** Create a work backlog for any non-urgent improvements like opportunities for cost optimization and added resilience. Incorporate the lessons learned from the post-mortem in your processes for future workload migrations.

## Checklist

| &nbsp;  | Deliverable tasks                 |
| ------- | --------------------------------- |
| &#9744; | Monitor and fine-tune             |
| &#9744; | Measure against baselines         |
| &#9744; | Validate successful cutover       |
| &#9744; | Sign-off milestones               |
| &#9744; | Conduct post-mortem/retrospective |
| &#9744; | Plan future improvements          |

## Next step

> [!div class="nextstepaction"]
> [Decommission your AWS resources](./migrate-workload-from-aws-decommission.md)