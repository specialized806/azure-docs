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

FedRAMP Rev 5 has mandated recommended Secure Configuration requirements for all Cloud Service Providers at [https://www.fedramp.gov/docs/rev5/balance/secure-configuration-guide/](https://www.fedramp.gov/docs/rev5/balance/secure-configuration-guide/)

Azure provides the following instructions and guidelines for the customers to meet these requirements.

#### **SCG-CSO-RSC**

Providers MUST create, maintain, and make available recommendations for securely configuring their cloud services (the Secure Configuration Guide) that includes at least the following information:

Required: Instructions on how to securely access, configure, operate, and decommission top-level administrative accounts that control enterprise access to the entire cloud service offering.

Required: Explanations of security-related settings that can be operated only by top-level administrative accounts and their security implications.

1. Recommended: Explanations of security-related settings that can be operated only by privileged accounts and their security implications.

***Notes:***

- *These requirements and recommendations refer to this guidance as a Secure Configuration Guide but cloud service providers may make this guidance available in various appropriate forms that provide the best customer experience.*

- *This guidance should explain how top-level administrative accounts are named and referred to in the cloud service offering.*

#### Azure's recommendation and Instructions

Azure defines the below top-level administrative accounts as below

|     Category                  |     Account   Type                     |     Why   It’s Top‑Level                                           |
|-------------------------------|----------------------------------------|--------------------------------------------------------------------|
|     Tenant‑wide               |     Global Administrator (Entra ID)    |     Full identity and directory control                            |
|                               |     Privileged Role Administrator      |     Can assign all privileged roles, including Global Admin        |
|                               |     Emergency Access Accounts          |     Break‑glass, unrestricted access for outages                   |
|     Enterprise   Agreement    |     Enterprise Administrator           |     Controls all Azure accounts and billing under the EA           |
|                               |     Account Owner                      |     Creates subscriptions; controls subscription‑level   admins    |
|     Subscription‑level        |     Service Administrator              |     Full management permissions on each subscription               |
Azure provides guidance to protect administrator sign-in, enforce MFA, conditional access, and protected admin workstations which detail how to securely access top-level administrative accounts in Azure. Instructions can be found at __[Privileged roles and permissions](/entra/identity/role-based-access-control/privileged-roles-permissions?branch=main&tabs=admin-center)__

Azure defines critical roles (Global/Privileged Role Admin), separation of duties, and least‑privilege configuration to securely configure top-level administrative accounts with instructions to implement at [Microsoft cloud security benchmark – Privileged access](/security/benchmark/azure/mcsb-privileged-access) and [Azure identity & access security best practices](/azure/security/fundamentals/identity-management-best-practices)

Azure provides operational guardrails for privileged sessions, access reviews, activation workflows, and monitoring to securely operate top-level administrative accounts as well as lifecycle guidance to remove stale assignments and revoke credentials with least standing privilege to securely decommission (retire) top‑level administrative accounts.

Azure documents the impact of enabling MFA, PIM eligibility, conditional access, and session controls for admins to explain security-related settings for top-level administrative accounts.

Azure uses Risk‑based rationale for restricting privileged roles and avoiding persistent elevation to explain security implications of privileged account configuration choices. 

Instructions to implement the above are explained at [Secure access practices for administrators (Entra ID)](/entra/identity/role-based-access-control/security-planning) and [Microsoft cloud security benchmark – Privileged access](/security/benchmark/azure/mcsb-privileged-access)

