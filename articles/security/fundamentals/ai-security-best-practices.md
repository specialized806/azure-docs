---
title: Azure AI security best practices | Microsoft Docs
description: This article provides best practices for securing AI workloads in Azure, including Azure OpenAI Service, Azure AI Foundry, and Azure Machine Learning.
services: security
author: msmbaldwin
ms.assetid: 
ms.service: security
ms.subservice: security-fundamentals
ms.topic: article
ms.date: 02/12/2026
ms.author: mbaldwin
ai-usage: ai-assisted
---

# Azure AI security best practices

This article provides best practices for securing artificial intelligence (AI) workloads specifically in Azure. As organizations adopt AI capabilities at an unprecedented rate, security teams must proactively gain visibility into AI usage and implement appropriate controls to mitigate risks.

This article focuses on Azure-specific AI security considerations. For comprehensive, platform-agnostic AI security guidance—including organizational strategy, governance frameworks, and the full AI security lifecycle—see [Security for AI](/security/security-for-ai/) in the Microsoft Security documentation.

For each best practice, we explain:

- What the best practice is
- Why you want to enable that best practice
- What might be the result if you fail to enable that best practice
- How you can learn to enable the best practice

This article complements the [AI shared responsibility model](shared-responsibility-ai.md), which explains the division of security responsibilities between you and Microsoft for AI workloads. For prescriptive security controls with Azure Policy enforcement, see [Microsoft Cloud Security Benchmark v2 - Artificial Intelligence Security](/security/benchmark/azure/mcsb-v2-artificial-intelligence-security).

## Enable visibility into AI workloads and usage

Before you can secure AI workloads, you need visibility into what AI applications are being used and built in your organization.

**Best practice**: Use Microsoft Defender for Cloud to discover AI workloads in your Azure environment.
**Detail**: The Defender Cloud Security Posture Management (CSPM) plan provides AI security posture management capabilities, including discovering the generative AI Bill of Materials (AI BOM), built-in security recommendations, and attack path analysis. For more information, see [AI security posture management with Defender for Cloud](/azure/defender-for-cloud/ai-security-posture).

**Best practice**: Use Microsoft Defender for Cloud Apps to discover SaaS AI applications.
**Detail**: The Defender for Cloud Apps catalog includes more than a thousand generative AI apps. You can view risk assessments, sanction or block apps, and create policies to detect new AI apps. For more information, see [Govern discovered apps](/defender-cloud-apps/governance-discovery).

**Best practice**: Track AI agent identities with Microsoft Entra Agent ID.
**Detail**: Microsoft Entra Agent ID provides a unified directory of agent identities created across Microsoft Copilot Studio and Azure AI Foundry, helping you manage agent lifecycle and permissions.

## Secure Azure OpenAI Service deployments

Azure OpenAI Service provides REST API access to powerful language models. Securing these deployments is critical for protecting your data and preventing misuse.

**Best practice**: Use private endpoints for network isolation.
**Detail**: Configure Azure OpenAI Service to use private endpoints, removing the public endpoint and restricting access to your virtual network. For more information, see [Network and access configuration for Azure OpenAI](/azure/ai-foundry/openai/how-to/on-your-data-configuration).

**Best practice**: Use managed identity for authentication.
**Detail**: Configure applications to authenticate using Microsoft Entra managed identities instead of API keys, eliminating the need to manage and rotate secrets. For more information, see [Configure Azure OpenAI Service with Microsoft Entra ID authentication](/azure/ai-services/openai/how-to/managed-identity).

**Best practice**: Implement multi-layered content filtering.
**Detail**: Deploy content filtering at multiple stages to create defense-in-depth:

- **Input filtering**: Use Azure AI Content Safety to analyze prompts for malicious content, including prompt injection attempts and jailbreak attacks
- **Output filtering**: Configure Azure OpenAI content filtering to block harmful responses before delivery
- **API gateway controls**: Use Azure API Management to enforce rate-limiting and schema validation

For more information, see [Content filtering](/azure/ai-services/openai/concepts/content-filter) and [Azure AI Content Safety](/azure/ai-services/content-safety/overview).

**Best practice**: Use safety meta-prompts to guide model behavior.
**Detail**: Design system prompts that clearly define the model's role, include explicit instructions to reject malicious inputs, and instruct the model to prioritize system instructions over user inputs. Use spotlighting techniques to isolate untrusted data within prompts and integrate [Prompt Shields](/azure/ai-services/content-safety/concepts/jailbreak-detection) to detect jailbreak attempts.

**Best practice**: Monitor usage with diagnostic logs.
**Detail**: Enable diagnostic logging to track API requests, token usage, content filtering results, and errors. Send logs to Azure Monitor for analysis and alerting. For more information, see [Monitor Azure OpenAI](/azure/ai-foundry/openai/how-to/monitor-openai).

## Secure Azure AI Foundry and Azure Machine Learning

Azure AI Foundry and Azure Machine Learning provide platforms for building and deploying AI applications. Securing these environments requires attention to network isolation, access control, and model governance.

**Best practice**: Use managed network isolation.
**Detail**: Create Azure AI Foundry hubs and Azure Machine Learning workspaces with managed virtual networks that provide private endpoints for dependent services and outbound traffic control. For more information, see [Managed network isolation for Azure AI Foundry](/azure/ai-studio/how-to/configure-managed-network) and [Configure a private endpoint for Azure Machine Learning](/azure/machine-learning/how-to-configure-private-link).

**Best practice**: Implement least-privilege access control.
**Detail**: Configure RBAC using built-in roles and assign permissions at the project or workspace level. Use Microsoft Entra Agent ID for AI agent identity management, applying scoped, short-lived tokens for agent function access. For more information, see [Role-based access control for Microsoft Foundry](/azure/ai-foundry/concepts/rbac-foundry).

**Best practice**: Deploy only approved AI models.
**Detail**: Use Azure Machine Learning model registry to track model provenance, verification status, and approval history. Configure automated scanning to validate model integrity and test against adversarial inputs before deployment. Deploy the "[Preview]: Azure Machine Learning Deployments should only use approved Registry Models" Azure Policy to enforce governance. For more information, see [Model management and deployment](/azure/machine-learning/concept-model-management-and-deployment).

**Best practice**: Secure compute resources.
**Detail**: Configure compute instances without public IPs, use managed identity authentication, enable user isolation for shared clusters, and encrypt disks with customer-managed keys. For more information, see [Secure an Azure Machine Learning training environment](/azure/machine-learning/how-to-secure-training-vnet).

## Implement AI-specific threat protection

AI workloads face unique threats including prompt injection, jailbreak attacks, and model manipulation. Implement threat detection and continuous testing specifically designed for AI.

**Best practice**: Use Microsoft Defender for Cloud AI threat protection.
**Detail**: Deploy Microsoft Defender for AI Services to detect prompt injection attacks, sensitive data exposure, and anomalous API usage patterns. For more information, see [AI threat protection with Microsoft Defender for Cloud](/azure/defender-for-cloud/ai-threat-protection).

**Best practice**: Implement continuous AI red teaming.
**Detail**: Conduct regular adversarial testing using specialized tools:

- [PyRIT (Python Risk Identification Tool for GenAI)](https://azure.github.io/PyRIT/) for automated adversarial testing
- [Azure AI Red Teaming Agent](https://devblogs.microsoft.com/foundry/ai-red-teaming-agent-preview/) for targeted attack simulations

Integrate red teaming into CI/CD pipelines to validate security before deployment. Test against known attack patterns from [MITRE ATLAS](https://atlas.mitre.org/) and the [OWASP Top 10 for LLM](https://owasp.org/www-project-top-10-for-large-language-model-applications/).

**Best practice**: Implement human-in-the-loop for critical actions.
**Detail**: For high-risk AI operations such as external data transfers or system configuration changes, design workflows using Azure Logic Apps or Power Automate that pause for human review and approval before execution.

**Best practice**: Monitor for risky AI usage patterns.
**Detail**: Use Microsoft Purview Insider Risk Management with the Risky AI usage policy template to detect and investigate risk activities related to AI. For more information, see [Insider risk management policy templates](/purview/insider-risk-management-policy-templates#risky-ai-usage-preview).

## Protect sensitive data in AI interactions

AI applications often interact with sensitive data. Implement data protection controls to prevent data loss and ensure compliance.

**Best practice**: Use Microsoft Purview Data Security Posture Management (DSPM) for AI.
**Detail**: DSPM for AI provides insights into AI activity, ready-to-use policies to protect data in prompts, and data risk assessments for potential oversharing. For more information, see [Data Security Posture Management for AI](/purview/ai-microsoft-purview).

**Best practice**: Apply sensitivity labels and DLP policies.
**Detail**: Extend Microsoft Purview sensitivity labels to data accessed by AI applications and configure DLP policies to detect and block sensitive data in AI prompts. For more information, see [Get started with sensitivity labels](/purview/get-started-with-sensitivity-labels).

## Govern AI for compliance

AI applications must comply with regulatory requirements and organizational policies.

**Best practice**: Implement responsible AI controls.
**Detail**: Follow Microsoft's responsible AI principles for fairness, transparency, privacy, and accountability. For more information, see [Microsoft Responsible AI Standard](https://www.microsoft.com/ai/principles-and-approach/).

**Best practice**: Maintain audit trails.
**Detail**: Enable auditing for AI services: Microsoft Purview Audit captures Copilot interactions, Azure Monitor tracks Azure AI service usage, and Defender for Cloud Apps monitors SaaS AI activity. For more information, see [Audit log activities](/purview/audit-log-activities).

## Next steps

- Learn about the [AI shared responsibility model](shared-responsibility-ai.md)
- Review [Microsoft Cloud Security Benchmark v2 - Artificial Intelligence Security](/security/benchmark/azure/mcsb-v2-artificial-intelligence-security)
- Explore [Security for AI](/security/security-for-ai/) for comprehensive AI security guidance
