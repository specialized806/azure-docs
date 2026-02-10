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

[Azure RBAC documentation](/azure/role-based-access-control/best-practices)

[Emergency Accounts - Manage emergency access accounts in Microsoft Entra ID](/entra/identity/role-based-access-control/security-emergency-access)

[Conditional Access Overview](/entra/identity/conditional-access/overview)

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

1. Configure two break-glass accounts with restricted usage and continuous monitoring.

1. Alignment to **Azure Policy** + **Defender for Cloud** FedRAMP initiatives

ensuring newly created admin or high‑privilege accounts never start in a weak or misconfigured state.

When identities, subscriptions, or resources are created, **Security defaults** + **CA** give a hardened starting posture; **Azure Policy** applies baseline guardrails at MG/sub scopes so new assets inherit secure defaults automatically.

Learn: [Security defaults](/entra/fundamentals/security-defaults) · [Conditional Access Overview](/entra/identity/conditional-access/overview) · [Azure RBAC Overview](/azure/role-based-access-control/overview) · [Plan CA deployment](/entra/identity/conditional-access/plan-conditional-access) · [What is Azure Policy?](/azure/governance/policy/overview) 

### Enhanced Capabilities[¶](https://www.fedramp.gov/docs/rev5/balance/secure-configuration-guide/#enhanced-capabilities"Permanent link")

These recommendations apply to all cloud service offerings in the FedRAMP Marketplace for enhanced capabilities related to the Secure Configuration Guide.

#### Comparison Capability

#### SCG-ENH-CMP

Providers SHOULD offer the capability to compare all current settings for top-level administrative accounts and privileged accounts to the recommended secure defaults.

#### Azure's response

Azure satisfies this requirement through built‑in security baseline comparison capabilities across **Azure AD (Entra ID)** privileged accounts and tenant‑level security settings.

Azure provides multiple mechanisms that allow customers to compare the current configuration of privileged identities against Microsoft’s published secure‑by‑default baseline. Azure meets this requirement by providing built‑in comparison tools—Secure Score, Microsoft Entra ID Protection, PIM, Access Reviews, and Defender for Cloud—that continuously evaluate the configuration of all top-level and privileged accounts against Microsoft’s published secure-by-default identity baselines. These services surface deviations, provide gap analyses, and supply prescriptive remediation guidance, ensuring customers can easily compare current settings to recommended secure defaults at any time

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

- Secure Score automatically evaluates:

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
  
#### Export Capability[¶](https://www.fedramp.gov/docs/rev5/balance/secure-configuration-guide/#export-capability"Permanent link")

#### SCG-ENH-EXP

Providers SHOULD offer the capability to export all security settings in a machine-readable format.

#### Azure's response

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

## **1. Azure Policy — Machine‑Readable Configuration & Compliance Export**

Azure Policy supports exporting:

- Policy Assignments

- Policy Definitions

- Compliance State

- Drift Results

- Export formats: **JSON (REST API, Azure CLI, ARM/Bicep)**

**Microsoft Learn:**

- https://learn.microsoft.com/en-us/azure/governance/policy/overview

- https://learn.microsoft.com/en-us/azure/governance/policy/how-to/get-compliance-data

---
## **2. Azure RBAC — Role Assignments & Privileged Access (JSON Export)**

Exportable via Azure CLI / Microsoft Graph:

- Role assignments

- Principal identities (users, groups, service principals)

- Standing vs. privileged roles (Owner, UAA, etc.)

**Microsoft Learn:**

- https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-list

---
## **3. Microsoft Entra ID — Identity Security Configuration Export**

All identity configuration can be exported in **JSON** using Microsoft Graph:

- Conditional Access Policies

- Authentication Strength / MFA Settings

- Identity Protection Policies

- PIM (Privileged Identity Management) settings

- Access Reviews configuration

**Microsoft Learn:**

- **Entra ID Protection Documentation** [Microsoft Entra ID Protection documentation](/entra/id-protection/) [[learn.microsoft.com]](/entra/id-protection/howto-identity-protection-investigate-risk)

- **What is Entra ID Protection?** [Overview: Microsoft Entra ID Protection](/entra/id-protection/overview-identity-protection) [[bing.com]](https://bing.com/search?q=Microsoft+Learn+PIM+privileged+identity+management)

- **Risk Investigation** [Investigate risk with Entra ID Protection](/entra/id-protection/howto-identity-protection-investigate-risk) [[bing.com]](https://bing.com/search?q=Microsoft+Learn+PIM+privileged+identity+management)

- **Risk Detection Types** [Identity Protection risk detections](/entra/id-protection/concept-identity-protection-risks) [[bing.com]](https://bing.com/search?q=Microsoft+Learn+PIM+privileged+identity+management)

---
## **4. Privileged Identity Management (PIM) — Machine‑Readable Role & Policy Export**

PIM exports via Graph (JSON):

- Eligible vs. Active Roles

- Activation history

- MFA / Approval requirements

- Privileged Access Policies

**Microsoft Learn:**

- [PIM documentation](/entra/id-governance/privileged-identity-management/) [[learn.microsoft.com]](/entra/id-governance/privileged-identity-management/)

- [Configure PIM](/entra/id-governance/privileged-identity-management/pim-configure) [[bing.com]](https://bing.com/search?q=Microsoft+Learn+PIM+privileged+identity+management)

---
## **5. Access Reviews — JSON Export for Privileged Access Governance**

Exportable:

- Review definitions

- Reviewers

- Review decisions

- Remediation actions

**Microsoft Learn:**

- [Access Reviews Overview](/entra/id-governance/access-reviews-overview) [[bing.com]](https://bing.com/search?q=Microsoft+Learn+PIM+privileged+identity+management)

- [Manage Access Reviews](/entra/id-governance/manage-access-review) [[microsoftl....github.io]](https://microsoftlearning.github.io/SC-900-Microsoft-Security-Compliance-and-Identity-Fundamentals/Instructions/Labs/LAB_04_explore_pim.html)

---
## **6. Microsoft Defender for Cloud — Posture, Recommendations & Secure Score Export**

Exportable:

- Secure Score

- Resource configurations

- Identity posture

- Regulatory compliance mappings

- SecurityAssessment objects

**Microsoft Learn:**

- [Manage security posture with Defender for Cloud](/training/modules/microsoft-defender-cloud-security-posture/) [[bing.com]](https://bing.com/search?q=Microsoft+Learn+PIM+privileged+identity+management)

- [Interactive Cloud Security Posture Guide](https://mslearn.cloudguides.com/en-US/guides/Manage%20your%20cloud%20security%20posture%20with%20Microsoft%20Defender%20for%20Cloud) [[bing.com]](https://bing.com/search?q=Microsoft+Learn+PIM+privileged+identity+management)

---
## **7. Azure Resource Graph — Full Environment Export (JSON)**

Export complete resource state:

- NSG rules

- Key Vault access policies

- Storage account configs

- Diagnostic settings

- Any resource’s full properties (ARM schema)

ARG supports KQL → JSON export.

**Microsoft Learn:**

- https://learn.microsoft.com/en-us/azure/governance/resource-graph/

---
## **8. Infrastructure‑as‑Code (IaC) — Full Machine‑Readable Export**

Azure supports exporting all deployed resources into:

- ARM Templates (JSON)

- Bicep (JSON‑transpiled)

- Terraform state (JSON)

These provide **100% environment configuration** in machine‑readable form.

**Microsoft Learn:**

- https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/export-template

