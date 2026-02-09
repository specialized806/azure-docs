---
# Required metadata
# For more information, see https://learn.microsoft.com/en-us/help/platform/learn-editor-add-metadata
# For valid values of ms.service, ms.prod, and ms.topic, see https://learn.microsoft.com/en-us/help/platform/metadata-taxonomies

title: FedRAMP Rev5 Recommended Secure Configuration
description: Azure Response to FedRAMP Rev5 Recommended Secure Configuration
author:      amohad # GitHub alias
ms.author:   atmoha # Microsoft alias
ms.service: azure-government
ms.topic: article
ms.date:     02/06/2026
---

# Recommended Secure Configuration

FedRAMP Rev 5 has mandated recommended Secure Configuration requirements for all Cloud Service Providers at [Secure Configuration Guide](https://www.fedramp.gov/docs/rev5/balance/secure-configuration-guide/)

Azure provides the following instructions and guidelines for the customers to meet these requirements.

### SCG-CSO-RSC

Providers MUST create, maintain, and make available recommendations for securely configuring their cloud services (the Secure Configuration Guide) that includes at least the following information:

1. Required: Instructions on how to securely access, configure, operate, and decommission top-level administrative accounts that control enterprise access to the entire cloud service offering.

1. Required: Explanations of security-related settings that can be operated only by top-level administrative accounts and their security implications.

1. Recommended: Explanations of security-related settings that can be operated only by privileged accounts and their security implications.

***Notes:***

- *These requirements and recommendations refer to this guidance as a Secure Configuration Guide but cloud service providers may make this guidance available in various appropriate forms that provide the best customer experience.*

- *This guidance should explain how top-level administrative accounts are named and referred to in the cloud service offering.*

#### Azure's response with recommendation and Instructions

Azure defines the below top-level administrative accounts

|     Category                  |     Account   Type                     |     Why   It’s Top‑Level                                           |
|-------------------------------|----------------------------------------|--------------------------------------------------------------------|
|     Tenant‑wide               |     Global Administrator (Entra ID)    |     Full identity and directory control                            |
|                               |     Privileged Role Administrator      |     Can assign all privileged roles, including Global Admin        |
|                               |     Emergency Access Accounts          |     Break‑glass, unrestricted access for outages                   |
|     Enterprise   Agreement    |     Enterprise Administrator           |     Controls all Azure accounts and billing under the EA           |
|                               |     Account Owner                      |     Creates subscriptions; controls subscription‑level   admins    |
|     Subscription‑level        |     Service Administrator              |     Full management permissions on each subscription               |
Azure publishes authoritative guidance for top-level admin roles via Microsoft Learn (Entra documentation), including privileged role definitions, emergency access (“break-glass”) account guidance, and FedRAMP High identity access controls, which customers can consume directly through public documentation.

Microsoft Learn documents which tenant-wide security settings exist, which privileged roles can change them, and why those settings matter (e.g., Security Defaults, blocking legacy auth), allowing customers to understand and securely manage top-level controls.

Azure provides guidance to protect administrator sign-in, enforce MFA, conditional access, and protected admin workstations which detail how to securely access top-level administrative accounts in Azure. Instructions can be found at __[Privileged roles and permissions](/entra/identity/role-based-access-control/privileged-roles-permissions?branch=main&tabs=admin-center)__

Azure defines critical roles (Global/Privileged Role Admin), separation of duties, least‑privilege configuration and provides guidance to manage emergency access admin accounts in Entra ID – Guidance on creating and managing highly privileged “break-glass” global admin accounts (for emergency scenarios) to securely configure top-level administrative accounts with instructions to implement at [Microsoft cloud security benchmark – Privileged access](/security/benchmark/azure/mcsb-privileged-access) and [Azure identity & access security best practices](/azure/security/fundamentals/identity-management-best-practices)

Azure provides operational guardrails for privileged sessions, access reviews, activation workflows, and monitoring to securely operate top-level administrative accounts as well as lifecycle guidance to remove stale assignments and revoke credentials with least standing privilege to securely decommission (retire) top‑level administrative accounts.

Azure documents the impact of enabling MFA, PIM eligibility, conditional access, and session controls for admins to explain security-related settings for top-level administrative accounts.

Azure uses Risk‑based rationale for restricting privileged roles and avoiding persistent elevation to explain security implications of privileged account configuration choices. 

Instructions to implement the above are explained at [Secure access practices for administrators (Entra ID)](/entra/identity/role-based-access-control/security-planning) and [Microsoft cloud security benchmark – Privileged access](/security/benchmark/azure/mcsb-privileged-access)

More detailed instructions to securely access, configure, operate, and decommission top-level administrative accounts that control enterprise access to the entire cloud service offering are explained the below Microsoft Learn Links

[Top Level – Microsoft Entra Documentation](/entra/)

[What is Microsoft Entra Privileged Identity Management](/entra/id-governance/privileged-identity-management/pim-configure)

[Start using Privileged Identity Management](/entra/id-governance/privileged-identity-management/pim-getting-started)

[Plan a Privileged Identity Management deployment](/entra/id-governance/privileged-identity-management/pim-deployment-plan)

[Configure Privileged Identity Management role settings](/security/privileged-access-workstations/overview)

[Securing Privileged Access](/security/privileged-access-workstations/overview)

[Configure identity access controls to meet FedRAMP High Impact level](/entra/standards/fedramp-access-controls)

[More specific guidance on configuring top-level accounts](/entra/identity/role-based-access-control/privileged-roles-permissions?tabs=admin-center)

__[Azure RBAC documentation](/azure/role-based-access-control/best-practices)__

__[Emergency Accounts - Manage emergency access accounts in Microsoft Entra ID](/entra/identity/role-based-access-control/security-emergency-access)__

### Use Instructions

#### SCG-CSO-AUP

Providers MUST include instructions in the FedRAMP authorization package that explain how to obtain and use the Secure Configuration Guide.

***Note:** These instructions may appear in a variety of ways; it is up to the provider to do so in the most appropriate and effective ways for their specific customer needs*

#### Azure's response

Azure FedRAMP authorization packages will contain a word document with instructions to access and use the Secure Configuration Guide. *[Review comment Ateeque] Is a link needed at this point?*

### Public Guidance

#### SCG-CSO-PUB

Providers SHOULD make the Secure Configuration Guide available publicly

#### Azure's response 

Azure's Secure Configuration Guide is available publicly and can be accessed at [Secure Configuration Guide](/azure/azure-government/compliance/azure-services-in-fedramp-auditscope?branch=pr-en-us-76518) *[Review comment Ateeque] this link currently points to the scope of the services but will be replaced by the link to the Guide.*

### Secure Defaults

#### SCG-CSO-SDF

Providers SHOULD set all settings to their recommended secure defaults for top-level administrative accounts and privileged accounts when initially provisioned.

#### Azure's response

Azure supports and applies secure defaults for top-level administrative accounts at provisioning via policy initiatives, security baselines, and baseline-as-code applied through automation. Azure sets security‑hardened defaults the moment a tenant, subscription, or administrative role is created.

When the tenant is first provisioned Azure enforces 

1. **Privileged Identity Management (PIM)** eligibility, not permanent assignment

1. **Multi‑Factor Authentication (MFA)** required for all privileged accounts

1. **Conditional Access** controls (device requirements, session controls)

1. Alignment to **Azure Policy** + **Defender for Cloud** FedRAMP initiatives

ensuring newly created admin or high‑privilege accounts never start in a weak or misconfigured state.

When identities, subscriptions, or resources are created, **Security defaults** + **CA** give a hardened starting posture; **Azure Policy** applies baseline guardrails at MG/sub scopes so new assets inherit secure defaults automatically.

Learn: [Security defaults](/entra/fundamentals/security-defaults) · [Conditional Access Overview](/entra/identity/conditional-access/overview). [Plan CA deployment](/entra/identity/conditional-access/plan-conditional-access) · [What is Azure Policy?](/azure/governance/policy/overview) 

