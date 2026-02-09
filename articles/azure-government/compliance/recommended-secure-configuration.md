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

Azure provides the following instructions and guidelines for the Customers to meet these requirements.

#### **SCG-CSO-RSC**

Providers MUST create, maintain, and make available recommendations for securely configuring their cloud services (the Secure Configuration Guide) that includes at least the following information:

Required: Instructions on how to securely access, configure, operate, and decommission top-level administrative accounts that control enterprise access to the entire cloud service offering.

Required: Explanations of security-related settings that can be operated only by top-level administrative accounts and their security implications.

Recommended: Explanations of security-related settings that can be operated only by privileged accounts and their security implications.

***Notes:***

- *These requirements and recommendations refer to this guidance as a Secure Configuration Guide but cloud service providers may make this guidance available in various appropriate forms that provide the best customer experience.*

- *This guidance should explain how top-level administrative accounts are named and referred to in the cloud service offering.*

#### Azure's recommendation and Instructions

1. Azure provides guidance to protect administrator sign-in, enforce MFA, conditional access, and protected admin workstations which detail how to securely access top-level administrative accounts in Azure. Instructions can be found at __[Securing privileged access for hybrid and cloud deployments in Microsoft Entra ID](/entra/identity/role-based-access-control/security-planning)__

