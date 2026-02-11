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

# Secure Configuration Guide

FedRAMP Rev 5 has mandated the following Secure Configuration Guide requirements for all Cloud Service Providers at [Secure Configuration Guide](https://www.fedramp.gov/docs/rev5/balance/secure-configuration-guide/)

Azure provides the instructions and guidelines for the customers to meet these requirements 

## [Recommended Secure Configuration](https://www.fedramp.gov/docs/rev5/balance/secure-configuration-guide/#recommended-secure-configuration)

## SCG-CSO-RSC 

Providers MUST create, maintain, and make available recommendations for securely configuring their cloud services (the Secure Configuration Guide) that includes at least the following information:

1. Required: Instructions on how to securely access, configure, operate, and decommission top-level administrative accounts that control enterprise access to the entire cloud service offering.

1. Required: Explanations of security-related settings that can be operated only by top-level administrative accounts and their security implications.

1. Recommended: Explanations of security-related settings that can be operated only by privileged accounts and their security implications.

***Notes:***

- *These requirements and recommendations refer to this guidance as a Secure Configuration Guide but cloud service providers may make this guidance available in various appropriate forms that provide the best customer experience.*

- *This guidance should explain how top-level administrative accounts are named and referred to in the cloud service offering.*

### Azure's response with recommendation and instructions

Azure defines the below top-level administrative accounts

|     Category                  |     Account   Type                     |     Why   It’s Top‑Level                                           |
|-------------------------------|----------------------------------------|--------------------------------------------------------------------|
|     Tenant‑wide               |     Global Administrator (Entra ID)    |     Full identity and directory control                            |
|                               |     Privileged Role Administrator      |     Can assign all privileged roles, including Global Admin        |
|                               |     Emergency Access Accounts          |     Break‑glass, unrestricted access for outages                   |
|     Enterprise   Agreement    |     Enterprise Administrator           |     Controls all Azure accounts and billing under the EA           |
|                               |     Account Owner                      |     Creates subscriptions; controls subscription‑level   admins    |
|     Subscription‑level        |     Service Administrator              |     Full management permissions on each subscription               |

Azure publishes authoritative guidance for top-level admin roles via Microsoft Learn (Entra documentation), including privileged role definitions, emergency access (“break-glass”) account guidance, and FedRAMP High identity access controls, which customers can consume directly through public documentation at [RBAC and Directory Admin Roles](https://docs.azure.cn/en-us/role-based-access-control/rbac-and-directory-admin-roles)

### Privileged Administrative Role Definitions

Microsoft Learn documents the built‑in administrative roles that are authorized to change tenant‑wide security settings, including:

- Global Administrator

- Security Administrator

- Conditional Access Administrator

- Privileged Role Administrator

These roles have the ability to alter authentication requirements, disable protections, and grant or revoke privileged access, making their governance critical.

Microsoft Learn publicly documents tenant‑wide identity and access security settings that are **operated only by top‑level administrative roles** (for example, Global Administrator, Conditional Access Administrator). These settings have direct and significant security implications because they control how privileged accounts authenticate, how legacy attack paths are blocked, and how identity risk is mitigated across the tenant. The security settings are described below.

#### 1. Security Defaults (Tenant‑Wide Secure‑by‑Default Controls)

Security Defaults are Microsoft‑recommended tenant‑wide protections that enforce a baseline identity security posture. These controls are **enabled, disabled, and governed by top‑level administrative roles**.

Security Defaults enforce:

- Multifactor authentication (MFA) for administrators

- MFA registration for all users

- Blocking of legacy authentication protocols

- Protection of privileged access to administrative portals

#### 2. Blocking Legacy Authentication (Tenant‑Wide Risk Reduction)

Legacy authentication protocols (for example, IMAP, POP, SMTP AUTH) do not support modern protections such as MFA and are a primary entry point for account compromise. Microsoft documents blocking legacy authentication as a **critical tenant‑wide security control**.

Only privileged administrators can enforce blocking of legacy authentication through Security Defaults or Conditional Access policies.

Microsoft Learn documents that these controls significantly reduce common identity attacks such as password spray and phishing.

**Microsoft Learn:** [Security defaults in Microsoft Entra ID](/entra/fundamentals/security-defaults)

#### 3. Conditional Access (Tenant‑Wide Policy Enforcement Engine)

Conditional Access is Microsoft’s primary tenant‑wide policy engine for enforcing:

- MFA for privileged roles

- Risk‑based access controls

- Blocking insecure authentication paths

- Enforcement of Zero Trust principles

Conditional Access policies can only be created and modified by **privileged administrative roles**, and misconfiguration or absence of these policies materially increases identity compromise risk.

#### 4. Emergency Access (“Break‑Glass”) Accounts

Microsoft documents emergency access accounts as highly privileged accounts designed for tenant recovery when normal administrative access is unavailable. These accounts:

- Are configured only by top‑level administrators

- Bypass certain tenant‑wide controls by design

- Require strict monitoring and governance due to elevated risk

**Microsoft Learn:**  [Manage emergency access accounts in Microsoft Entra ID](/entra/identity/role-based-access-control/security-emergency-access)

#### 5. Identity Protection (Tenant‑Wide Risk Policies)

Microsoft Entra ID Protection provides tenant‑wide risk detection and enforcement for:

- Risky users

- Risky sign‑ins

- Automated remediation actions

Privileged administrators configure these policies, which directly protect high‑value and administrative accounts from compromise.

**Microsoft Learn:** [Microsoft Entra ID Protection overview](/entra/id-protection/overview-identity-protection)

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

[Securing Privileged Access](/security/privileged-access-workstations/overview)

[Configure identity access controls to meet FedRAMP High Impact level](/entra/standards/fedramp-access-controls)

[More specific guidance on configuring top-level accounts](/entra/identity/role-based-access-control/privileged-roles-permissions?tabs=admin-center)

[Azure RBAC documentation](/azure/role-based-access-control/best-practices)

[Emergency Accounts - Manage emergency access accounts in Microsoft Entra ID](/entra/identity/role-based-access-control/security-emergency-access)

[Conditional Access Overview](/entra/identity/conditional-access/overview)

[Back to the top](#secure-configuration-guide)

## [Use Instructions](https://www.fedramp.gov/docs/rev5/balance/secure-configuration-guide/#use-instructions)

## SCG-CSO-AUP

Providers MUST include instructions in the FedRAMP authorization package that explain how to obtain and use the Secure Configuration Guide.

***Note:** These instructions may appear in a variety of ways; it is up to the provider to do so in the most appropriate and effective ways for their specific customer needs*

#### Azure's response

Azure FedRAMP authorization packages will contain a word document with instructions to access and use the Secure Configuration Guide. *[Review comment Ateeque] Is a link needed at this point?*
[Back to the top](#secure-configuration-guide)
## [Public Guidance](https://www.fedramp.gov/docs/rev5/balance/secure-configuration-guide/#public-guidance)

## SCG-CSO-PUB

Providers SHOULD make the Secure Configuration Guide available publicly

### Azure's response

Azure's Secure Configuration Guide is available publicly and can be accessed at [Secure Configuration Guide](/azure/azure-government/compliance/azure-services-in-fedramp-auditscope?branch=pr-en-us-76518) *[Review comment Ateeque] this link currently points to the scope of the services but will be replaced by the link to the Guide.*

[Back to the top](#secure-configuration-guide)

## [Secure Defaults](https://www.fedramp.gov/docs/rev5/balance/secure-configuration-guide/#secure-defaults)

## SCG-CSO-SDF

Providers SHOULD set all settings to their recommended secure defaults for top-level administrative accounts and privileged accounts when initially provisioned.

### Azure's response

Azure supports and applies secure defaults for top-level administrative accounts at provisioning via policy initiatives, security baselines, and baseline-as-code applied through automation. Azure sets security‑hardened defaults the moment a tenant, subscription, or administrative role is created.

When the tenant is first provisioned Azure enforces 

1. **Privileged Identity Management (PIM)** eligibility, not permanent assignment

1. **Multi‑Factor Authentication (MFA)** required for all privileged accounts

1. **Conditional Access** controls (device requirements, session controls)

1. Configure two break-glass accounts with restricted usage and continuous monitoring.

1. Alignment to **Azure Policy** + **Defender for Cloud** FedRAMP initiatives

ensuring newly created admin or high‑privilege accounts never start in a weak or misconfigured state.

When identities, subscriptions, or resources are created, **Security defaults** + **Conditional Access** give a hardened starting posture; **Azure Policy** applies baseline guardrails at MG/sub scopes so new assets inherit secure defaults automatically.

**Microsoft Learn:** [Security defaults](/entra/fundamentals/security-defaults) · [Conditional Access Overview](/entra/identity/conditional-access/overview) · [Azure RBAC Overview](/azure/role-based-access-control/overview) · [Plan CA deployment](/entra/identity/conditional-access/plan-conditional-access) · [What is Azure Policy?](/azure/governance/policy/overview) 

[Back to the top](#secure-configuration-guide)

## [Enhanced Capabilities](https://www.fedramp.gov/docs/rev5/balance/secure-configuration-guide/#enhanced-capabilities)

These recommendations apply to all cloud service offerings in the FedRAMP Marketplace for enhanced capabilities related to the Secure Configuration Guide.

## [Comparison Capability](https://www.fedramp.gov/docs/rev5/balance/secure-configuration-guide/#comparison-capability)

## SCG-ENH-CMP

Providers SHOULD offer the capability to compare all current settings for top-level administrative accounts and privileged accounts to the recommended secure defaults.

### Azure's response

Azure satisfies this requirement through built‑in security baseline comparison capabilities across **Microsoft Entra ID** privileged accounts and tenant‑level security settings.

Azure provides multiple mechanisms that allow customers to compare the current configuration of privileged identities against Microsoft’s published secure‑by‑default baseline. Azure provides built‑in comparison tools—Secure Score, Microsoft Entra ID Protection, Privileged Identity Management (PIM), Access Reviews, and Defender for Cloud—that continuously evaluate the configuration of all top-level and privileged accounts against Microsoft’s published secure-by-default identity baselines. These services surface deviations, provide gap analyses, and supply prescriptive remediation guidance, ensuring customers can easily compare current settings to recommended secure defaults at any time

#### How Azure Fulfills This

#### 1. Microsoft Entra ID Protection Baseline

- Microsoft publishes secure configuration baselines for identity.

- Entra compares current tenant settings—including MFA enforcement, risky sign‑in detection, password protection, and conditional access posture—against Microsoft's recommended defaults.

- Deviations surface as alerts or “unmet recommendations.”

  [Entra ID Protection documentation hub](/entra/id-protection/)
  
  [Overview — What is Microsoft Entra ID Protection?](/entra/id-protection/overview-identity-protection)
  
  [Investigate Risk (Risky users, Risky sign](/entra/id-protection/howto-identity-protection-investigate-risk)[‑](/entra/id-protection/howto-identity-protection-investigate-risk)[ins)](/entra/id-protection/howto-identity-protection-investigate-risk)
  
  [Risk Detection Types](/entra/id-protection/concept-identity-protection-risks)
  
#### 2. Microsoft Secure Score

Secure Score automatically evaluates:

- Privileged roles assigned

- MFA status for all privileged accounts

- Conditional Access configurations for admins

- Standing vs. Just‑in‑Time privilege (Privileged Identity Management)

- Each control includes:

  - **Recommended default configuration**
  
  - **Current configuration**
  
  - **Gap analysis**
  
  - **Remediation guidance**
  
This directly meets the requirement to compare *“all current settings”* against recommended defaults.  

[Microsoft Entra Identity Secure Score](/entra/identity/monitoring-health/concept-identity-secure-score?toc=%2Fentra%2Ffundamentals%2Ftoc.json&bc=%2Fentra%2Ffundamentals%2Fbreadcrumb%2Ftoc.json)

#### 3. Azure AD (Entra ID) Access Reviews

- Reviews can be conducted specifically on:

  - **Global Administrators**
  
  - **Privileged Role Administrators**
  
  - **Any high‑privilege custom role**
  
- Review results show:

  - Who currently has access
  
  - Whether access conforms to least privilege and Azure’s recommended defaults
  
  - Whether administrators maintain unnecessary standing rights
  
    [What are Access Reviews?](/entra/id-governance/access-reviews-overview)
    
    [Manage access with Access Reviews](/entra/id-governance/manage-access-review)
    
#### 4. Privileged Identity Management (PIM) Policy Comparison

PIM provides a built‑in control comparison:

- Shows whether default protections (approval, MFA-on-activation, time-bound privilege) are enabled.

- Highlights discrepancies between your configuration and Microsoft’s baseline.

  [Privileged Identity Management documentation (Microsoft Entra)](/entra/id-governance/privileged-identity-management/pim-how-to-change-default-settings)
  
  [PIM configuration (What PIM does, how to configure)](/entra/id-governance/privileged-identity-management/pim-configure)
  
#### 5. Baseline Comparison via Defender for Cloud

For hybrid and cloud resources:

- Identity and entitlement management controls map to secure defaults.

- Defender for Cloud surfaces misconfigurations and recommends compliant baseline settings. Azure satisfies this requirement through built‑in security baseline comparison capabilities across **Azure AD (Entra ID)** privileged accounts and tenant‑level security settings.

  [Manage security posture with Microsoft Defender for Cloud (official Learn module)](/training/modules/microsoft-defender-cloud-security-posture/)
  
  [Interactive Guide — Manage your cloud security posture](https://mslearn.cloudguides.com/en-US/guides/Manage%20your%20cloud%20security%20posture%20with%20Microsoft%20Defender%20for%20Cloud)
  
[Back to the top](#secure-configuration-guide)

## [Export Capability](https://www.fedramp.gov/docs/rev5/balance/secure-configuration-guide/#export-capability)

## SCG-ENH-EXP

Providers SHOULD offer the capability to export all security settings in a machine-readable format.

### Azure's response

Azure meets this requirement through **multiple machine‑readable export paths**, all providing **structured JSON**.

Azure **meets and exceeds** SCG-ENH-EXP by offering **full security configuration export** in **machine‑readable JSON** across:

- Identity

- RBAC

- Conditional Access

- PIM

- Access Reviews

- Policy & Compliance

- Defender Secure Score

- Resource configurations

- IaC representations

This enables complete, verifiable evidence trails for:

- Audit

- Compliance

- Drift detection

- Automation pipelines

- Regulatory mapping

Different methods of exporting security settings in machine readable format are described below.

#### 1. Azure Policy — Machine‑Readable Configuration & Compliance Export

Azure Policy supports exporting:

- Policy Assignments

- Policy Definitions

- Compliance State

- Drift Results

- Export formats: **JSON (REST API, Azure CLI, ARM/Bicep)**

**Microsoft Learn:**

- [Azure Policy overview](/azure/governance/policy/overview)

- [How to get compliance data](/azure/governance/policy/how-to/get-compliance-data)

#### 2. Azure RBAC — Role Assignments & Privileged Access (JSON Export)

Exportable via Azure CLI / Microsoft Graph:

- Role assignments

- Principal identities (users, groups, service principals)

- Standing vs. privileged roles (Owner, UAA, etc.)

**Microsoft Learn:**

- [Role Assignments list](/azure/role-based-access-control/role-assignments-list-cli)

#### 3. Microsoft Entra ID — Identity Security Configuration Export

All identity configurations can be exported in **JSON** using Microsoft Graph:

- Conditional Access Policies

- Authentication Strength / MFA Settings

- Identity Protection Policies

- PIM (Privileged Identity Management) settings

- Access Reviews configuration

**Microsoft Learn:**

- **Entra ID Protection Documentation** [Microsoft Entra ID Protection documentation](/entra/id-protection/) 

- **What is Entra ID Protection?** [Overview: Microsoft Entra ID Protection](/entra/id-protection/overview-identity-protection) 

- **Risk Investigation** [Investigate risk with Entra ID Protection](/entra/id-protection/howto-identity-protection-investigate-risk) 

- **Risk Detection Types** [Identity Protection risk detections](/entra/id-protection/concept-identity-protection-risks) 

#### 4. Privileged Identity Management (PIM) — Machine‑Readable Role & Policy Export

PIM exports via Graph (JSON):

- Eligible vs. Active Roles

- Activation history

- MFA / Approval requirements

- Privileged Access Policies

**Microsoft Learn:**

- [PIM documentation](/entra/id-governance/privileged-identity-management/) 

- [Configure PIM](/entra/id-governance/privileged-identity-management/pim-configure) 

#### 5. Access Reviews — JSON Export for Privileged Access Governance

Exportable:

- Review definitions

- Reviewers

- Review decisions

- Remediation actions

**Microsoft Learn:**

- [Access Reviews Overview](/entra/id-governance/access-reviews-overview) 

- [Manage Access Reviews](/entra/id-governance/manage-access-review) 

#### 6. Microsoft Defender for Cloud — Posture, Recommendations & Secure Score Export

Exportable:

- Secure Score

- Resource configurations

- Identity posture

- Regulatory compliance mappings

- Security Assessment objects

**Microsoft Learn:**

- [Manage security posture with Defender for Cloud](/training/modules/microsoft-defender-cloud-security-posture/) 

- [Interactive Cloud Security Posture Guide](https://mslearn.cloudguides.com/en-US/guides/Manage%20your%20cloud%20security%20posture%20with%20Microsoft%20Defender%20for%20Cloud)

#### 7. Azure Resource Graph — Full Environment Export (JSON)

Export complete resource state:

- NSG rules

- Key Vault access policies

- Storage account configs

- Diagnostic settings

- Any resource’s full properties (ARM schema)

ARG supports KQL → JSON export.

**Microsoft Learn:**

- [Azure Resource Graph documentation](/azure/governance/resource-graph/)

#### 8. Infrastructure‑as‑Code (IaC) — Full Machine‑Readable Export

Azure supports exporting all deployed resources into:

- ARM Templates (JSON)

- Bicep (JSON‑transpiled)

- Terraform state (JSON)

These provide **100% environment configuration** in machine‑readable form.

**Microsoft Learn:**

- [ARM template documentation](/azure/azure-resource-manager/templates/)

[Back to the top](#secure-configuration-guide)

## [API Capability](https://www.fedramp.gov/docs/rev5/balance/secure-configuration-guide/#api-capability)

## SCG-ENH-API

Providers SHOULD offer the capability to view and adjust security settings via an API or similar capability.

### Azure's response

Azure fully satisfies this requirement by exposing *all major security configurations* through documented APIs (ARM, Microsoft Graph, Azure Policy, Defender for Cloud APIs, and Azure Resource Graph). 

Azure **fully meets and exceeds** SCG-ENH-API by providing comprehensive, documented, and secure APIs that allow organizations to:

- Programmatically **view** all security settings

- Programmatically **modify/enforce** security settings

- Automate governance, remediation, and compliance workflows

- Export full configuration state for audit evidence

- Integrate with Continuous Integration / Continuous Deployment (CI/CD), Security Orchestration, Automation, and Response (SOAR), Security Information and Event Management (SIEM), and Compliance pipelines

The combination of **ARM**, **Microsoft Graph**, **Azure Policy**, **RBAC APIs**, **Defender for Cloud APIs**, and **Azure Resource Graph** ensures **complete transparency, adjustability, and automation** of all security posture components.

Below is the description of each of the methods available to customers.

#### 1. Azure Resource Manager (ARM) — Security Configuration API

Azure Resource Manager (ARM) exposes **every Azure resource’s configuration** (including security settings) via REST API. This allows programmatic **view** (`GET`) and **adjust** (`PUT/PATCH`) operations for:

- Network Security Group (NSG) rules

- Key Vault access policies

- Storage encryption settings

- Diagnostic settings

- Azure Policy assignments

**Microsoft Learn:** [Azure Resource Manager](/rest/api/resources/)

---
#### 2. Microsoft Graph API — Identity & Access Security Settings

Microsoft Graph exposes the **entire identity security plane**, enabling automation to view/adjust:

- Conditional Access policies

- Authentication Strength (MFA) policies

- Identity Protection risk policies, risky users, risky sign‑ins

- Privileged Identity Management (PIM) settings

- Access Review definitions, decisions, and remediation actions

**Microsoft Learn:**

- [Authorization and the Microsoft Graph Security API](/graph/security-authorization)

#### 3. Azure Policy API — Secure Defaults, Baselines, Compliance

Programmatically enforce and adjust secure settings using Policy APIs:

- Assign / unassign policy definitions

- Enforce secure baselines

- Evaluate compliance state

- Detect drift

- Export compliance state (JSON)

**Microsoft Learn:**

- [Azure Policy documentation](/azure/governance/policy/)

#### 4. Azure RBAC — View & Adjust Role Assignments (JSON Export)

Azure exposes all RBAC assignments and allows programmatic adjustments using:

Azure CLI (JSON Export)

- **Microsoft Learn:** [List Azure role assignments using Azure CLI](/azure/role-based-access-control/role-assignments-list-cli)

#### 5. Microsoft Defender for Cloud APIs — Secure Score & Recommendations

View and adjust cloud security posture via API:

- Secure Score export

- Recommendations retrieval

- Regulatory compliance mapping

- Automated remediation

**Microsoft Learn:**

- [Manage security posture with Microsoft Defender for Cloud](/training/modules/microsoft-defender-cloud-security-posture/)

- [Interactive security posture guide (Cloud Security Posture UX)](https://thinkcloudly.com/blog/azure/defender-for-cloud-implementation-guide/)

#### 6. Azure Resource Graph — Full Security Inventory (JSON Export)

ARG enables querying and exporting:

- RBAC assignments

- NSG exposure

- Encryption settings

- Diagnostic settings

- Identity configurations

- Compliance posture

**Microsoft Learn:** [Azure Resource Graph documentation](/azure/governance/resource-graph/)

#### 7. Integration With CI/CD, SOAR, SIEM & Compliance Pipelines (Expanded)

#### Continuous Integration / Continuous Deployment (CI/CD)

Azure’s APIs integrate with:

- GitHub Actions

- Azure DevOps

- GitLab CI

Enables pipelines to:

- Pull security configuration

- Validate RBAC & Policy compliance before deployment

- Enforce secure defaults using IaC

#### Security Orchestration Automation & Response (SOAR)

Using Microsoft Sentinel & Defender XDR automation:

- Pull risk events via Graph

- Trigger remediation workflows

- Auto‑adjust Conditional Access / RBAC

- Update policies on drift

#### Security Information & Event Management (SIEM)

Microsoft Sentinel, Splunk, QRadar can ingest:

- RBAC assignment exports

- Identity Protection alerts

- Defender for Cloud posture data

Enables:

- Real‑time misconfiguration detection

- Compliance verification

- Long‑term audit logging

#### Compliance / GRC Pipelines

Supports automated:

- Export of configuration evidence

- Comparison with NIST 800‑53, FedRAMP, CIS, ISO 27001

- Drift detection

- Auditor‑ready JSON bundles

[Back to the top](#secure-configuration-guide)

## [Machine-Readable Guidance](https://www.fedramp.gov/docs/rev5/balance/secure-configuration-guide/#machine-readable-guidance)

## SCG-ENH-MRG

Providers SHOULD also provide the Secure Configuration Guide in a machine-readable format that can be used by customers or third-party tools to compare against current settings.

#### Azure's Response

Azure satisfies this requirement by providing customers Secure Configuration Guide through multiple Microsoft‑documented APIs and export mechanisms that deliver **JSON‑structured secure configuration data** across identity, RBAC, policy, and security‑posture layers.

Below are the various channels that Azure provides this machine-readable data in

#### 1. Microsoft Defender for Cloud — Secure Configuration Baselines (Machine‑Readable JSON)

Azure Defender for Cloud provides:

- Secure Score recommendations (JSON)

- Configuration assessments (JSON)

- Regulatory compliance mappings (JSON)

- Security control baseline definitions (JSON)

These can be exported programmatically and used by comparison tools.

**Microsoft Learn:** [Manage security posture by using Microsoft Defender for Cloud](https://m365corner.com/m365-glossary/privileged-identity-management.html) [Interactive Cloud Security Posture Guide (Cloud Security UX)](https://thinkcloudly.com/blog/azure/defender-for-cloud-implementation-guide/)

#### 2. Azure Policy — Secure Baseline Definitions (JSON)

Azure Policy provides the backbone for Azure secure configuration guides:

- Built‑in secure baseline initiatives (e.g., Azure Security Benchmark)

- Machine‑readable policy definitions (JSON)

- Machine‑readable compliance state (JSON)

- Drift detection exports

Third‑party engines can run diff/comparison logic on exported JSON.

**Microsoft Learn:** [Azure Policy overview](/azure/governance/policy/overview)

#### 3. Microsoft Entra ID  — Identity Security Baselines (JSON via Microsoft Graph)

Microsoft Graph exposes **identity security configuration** in machine‑readable JSON:

- **Conditional Access policies**

- **Authentication Strength (MFA) settings**

- **Identity Protection risk policies**

- **Privileged Identity Management (PIM) settings**

- **Access Reviews definitions**

**Microsoft Learn:**

- [Top Level – Microsoft Entra Documentation](/entra/)

- [What is Microsoft Entra ID Protection?](/entra/id-protection/overview-identity-protection)

#### 4. Azure RBAC — Role Assignments (JSON Export)

Azure supports complete JSON export of RBAC access configuration via Azure CLI, Microsoft Graph, or Resource Graph.

- JSON listing of **role assignments**

- JSON mapping of **principals → scopes → roles**

- Used by identity governance and drift/comparison tools

**Microsoft Learn:** [List Azure role assignments using Azure CLI](/azure/role-based-access-control/role-assignments-list-cli)

#### 5. Azure Resource Graph — Full Machine‑Readable Security State (JSON)

ARG provides a **tenant‑wide**, machine‑readable export of:

- RBAC assignments

- NSG rules / exposure

- Encryption configuration

- Diagnostic settings

- Policy compliance

- Identity configuration

- VM and resource security metadata

All exportable as **JSON**, ideal for third‑party security baselines and configuration comparison engines.

**Microsoft Learn:** [Azure Resource Graph documentation](/azure/governance/resource-graph/)

#### 6. How Third‑Party Tools Compare Against Azure Machine‑Readable Guides

Using the above machine‑readable feeds, external tools can:

- Compare actual Azure config vs. **Secure Configuration Guide JSON**

- Detect misconfigurations, drift, or non‑compliant security settings

- Generate auditor‑ready compliance evidence

- Automate remediation workflows

[Back to the top](#secure-configuration-guide)

## [Versioning and Release History](https://www.fedramp.gov/docs/rev5/balance/secure-configuration-guide/#versioning-and-release-history)

## SCG-ENH-VRH

Providers SHOULD provide versioning and a release history for recommended secure default settings for top-level administrative accounts and privileged accounts as they are adjusted over time.

#### Azure's Response

Azure fully satisfies the requirement through 

- **Versioned security baselines** 

- **Versioned identity / privileged access protections** 

- **Versioned PIM governance settings** 

- **Versioned Secure Score recommendations** 

- **Machine‑readable JSON for comparison tooling** 

- **APIs for change tracking & automated drift detection**

with clear change histories.

The combination of Entra ID Protection, PIM, Azure RBAC JSON exports, Defender for Cloud posture, and Azure Resource Graph delivers a complete versioning story for secure‑default controls.

#### 1. Azure Security Baselines — Versioned & Change‑Tracked

Microsoft publishes **versioned Security Baselines** for Azure and Microsoft cloud services. Each baseline includes:

- Recommended secure default settings

- Version history & changes

- Deprecated controls

- Updated controls

**Microsoft Learn:** [Security Baselines](/windows/security/operating-system-security/device-management/windows-security-configuration-framework/windows-security-baselines)

#### 2. Microsoft Entra ID — Secure Defaults Version Evolution

Azure (Microsoft Entra ID) maintains evolving **Secure Default** protections for privileged accounts, including:

- MFA for administrators

- Blocking legacy authentication

- Privileged Identity Protection controls

- Updated secure‑by‑default identity posture

**Microsoft Learn**:

**Microsoft Entra ID Protection documentation** [Microsoft Entra ID Protection documentation](https://www.youtube.com/watch?v=QeXKv-N1zgk)

**What is Microsoft Entra ID Protection?** [Overview of Identity Protection](/entra/)

These pages collectively document:

- Updated secure defaults

- New risk detection types

- Changes in identity security posture

- Updated admin & privileged account protections

#### 3. Privileged Identity Management (PIM) — Policy Versioning

PIM provides:

- Versioned policies for privileged access

- MFA requirements

- Approval workflows

- Role activation conditions

- Expiration / justification governance

Each update in PIM documentation reflects secure‑default evolution for privileged accounts.

**Microsoft Learn hyperlink:** [Privileged Identity Management (PIM) Documentation](https://www.youtube.com/watch?v=z5OMEC0j2ns)

#### 4. Microsoft Defender for Cloud — Versioned Secure Recommendations

Defender for Cloud maintains:

- Versioned Secure Score recommendations

- Updated regulatory mappings

- Added & deprecated controls

- Evidence export capabilities

- Machine‑readable JSON recommendations

**Microsoft Learn:**

Defender for Cloud posture module [Manage security posture using Microsoft Defender for Cloud](https://m365corner.com/m365-glossary/privileged-identity-management.html)

Interactive Cloud Security UX / Guide [Interactive Cloud Security Posture Guide](https://thinkcloudly.com/blog/azure/defender-for-cloud-implementation-guide/)

#### 5. Machine‑Readable Versioned JSON for Comparisons

Azure provides versioned JSON accessible through:

**Azure RBAC JSON Export** [List Azure role assignments using Azure CLI](/azure/role-based-access-control/role-assignments-list-cli)

**Azure Resource Graph (ARG) — Full environment state JSON** <u>[Quickstart: Execute a Resource Graph Query Using Azure CLI](/azure/governance/resource-graph/first-query-azurecli)</u>

ARG enables diffing:

- RBAC changes

- Policy updates

- Diagnostic settings

- Encryption configuration

- Identity settings

- Drift from secure baselines

[Back to the top](#secure-configuration-guide)