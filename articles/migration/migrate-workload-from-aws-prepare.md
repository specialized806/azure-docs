---
title: Migrate a Workload from Amazon Web Services (AWS) to Azure - Prepare
description: Learn how to prepare migration of a single workload from AWS to Azure
ms.author: rhackenberg
ai-usage: ai-assisted
ms.date: 11/24/2025
ms.topic: concept-article
ms.service: azure
ms.collection:
  - migration
  - aws-to-azure
---
# Migrate a workload from Amazon Web Services (AWS) to Azure - Prepare

The prepare phase consists of two steps: 

> [!div class="checklist"]
> * prepare environment
> * prepare application

During this phase, you build out your Azure environment, refactor any code if required, set up your CI/CD tooling and pipelines, and perform tests to complete a successful migration. Take your time during this phase as any misconfigured infrastructure, insufficient testing, or lack of your team's readiness can result in delays, security vulnerabilities, or failed deployments during execution.

## Prepare your environment

- **Provision application landing zones:** Ensure the platform team designs and provisions the **[Azure application landing zones](/azure/cloud-adoption-framework/ready/enterprise-scale/implementation)** for your preproduction and production workload environments with proper segregation of duties.
- **Set up migration tools:** If you plan to use Azure Migrate for the execution phase, deploy the Azure Migrate appliance early and configure your Azure Migrate project. This approach ensures all target Azure resources and discovery processes are ready before cutover.
- **Deploy and configure Azure infrastructure:** Use Infrastructure as Code (IaC) to deploy your resources. This approach ensures consistency and repeatability. If your teams want to continue writing deployment scripts using Terraform, they must write new scripts and modules for your Azure resources. If your existing deployment scripts use [CloudFormation](https://docs.aws.amazon.com/cloudformation/), consider using [Bicep](/azure/azure-resource-manager/bicep/) to deploy on Azure. Focus on nonproduction environments first and validate everything before moving on to production environments.
- **Update CI/CD pipelines for Azure to keep environments aligned:** 
	- Modify your deployment pipelines to target Azure services.
	- Configure the service connections and validate that your build and release workflows can deploy your selected Azure compute resources, such as Azure App Service, AKS, or VMs.
	- If you're using a blue/green approach, make sure you can deploy to both AWS and Azure during the transition (for example, to apply an urgent fix or to support a rollback).
- **Test your infrastructure:** Validate your Virtual WAN or hub network and any other foundational services like AWS Direct Connect and Azure ExpressRoute and/or VPN connections. Ensure they're configured to support both the target workload and the migration process. Validate that connectivity works end-to-end across your Azure and AWS environments.
- **Test your networking and security:** As you configure NSGs, firewalls, and policies, validate that the application can communicate with all required services. Perform connectivity tests to ensure that security settings are neither too restrictive nor too permissive. Adjust as needed to maintain both security and functionality.

## Prepare your application

- **Refactor your application's code:** Use feature flags to simplify version management between the AWS and Azure environments.
- **Prepare your operational functions:** Work with the platform team to implement workload monitoring. Collaborate with the security team to implement security monitoring and validate the Azure architecture.

For guidance on preparing your workloads and building your Azure environment, see the [CAF Prepare workloads](/azure/cloud-adoption-framework/migrate/prepare-workloads-cloud) guide.

## Checklist

| &nbsp;  | Deliverable tasks                         |
| ------- | ----------------------------------------- |
| &#9744; | Provision application landing zones       |
| &#9744; | Deploy and configure Azure infrastructure |
| &#9744; | Update CI/CD pipelines for Azure          |
| &#9744; | Test infrastructure                       |
| &#9744; | Refactor application's code               |
| &#9744; | Prepare operational functions             |
| &#9744; | Test your networking and security         |


## Next step

> [!div class="nextstepaction"]
> [Execute your migration](./migrate-workload-from-aws-execute.md)