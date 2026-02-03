---
title: Industry-wide certificate changes impacting Azure App Service
description: Learn about upcoming industry-wide TLS certificate changes that affect Azure App Service Managed Certificates and App Service Certificates, including timelines and required customer actions.
author: azure-app-service
ms.author: azcontent
ms.date: 2026-02-03
ms.topic: conceptual
ms.service: app-service
---

# Industry-wide certificate changes impacting Azure App Service

In early 2026, industry-wide changes mandated by browser applications and the CA/Browser Forum (CA/B Forum) will affect how public TLS certificates are issued and validated. Azure App Service is aligning with these requirements for App Service Managed Certificates (ASMC) and App Service Certificates (ASC). [1](https://techcommunity.microsoft.com/blog/appsonazureblog/industry-wide-certificate-changes-impacting-azure-app-service-certificates/4477924)

For most customers, these changes are applied automatically and no action is required. Action is required only if applications pin certificates or certificate chains, or if App Service certificates are used for client authentication (mutual TLS). [1](https://techcommunity.microsoft.com/blog/appsonazureblog/industry-wide-certificate-changes-impacting-azure-app-service-certificates/4477924)

## Who this article applies to

This article applies to:

- Azure App Service administrators
- Security and compliance teams
- Developers responsible for TLS certificate configuration or application security

[1](https://techcommunity.microsoft.com/blog/appsonazureblog/industry-wide-certificate-changes-impacting-azure-app-service-certificates/4477924)

## Summary of changes

The following table summarizes the changes and when customer action is required.

| Area | App Service Managed Certificates (ASMC) | App Service Certificates (ASC) | Customer action |
|-----|-----------------------------------------|--------------------------------|-----------------|
| Certificate chain | Migrates to a new certificate chain | Migrates to a new certificate chain | Remove certificate or chain pinning if used |
| Client authentication EKU | No longer supported | No longer supported | Transition to an alternative authentication method if mTLS is used |
| Certificate validity | No change (already compliant) | Validity shortened with overlapping certificates | None |

If certificates are not pinned and are not used for client authentication, no changes are required. [1](https://techcommunity.microsoft.com/blog/appsonazureblog/industry-wide-certificate-changes-impacting-azure-app-service-certificates/4477924)

## Timeline

| Timeframe | Change | Customer action |
|----------|--------|-----------------|
| Mid-January 2026 and later | ASMC migrates to a new certificate chain.<br/>ASMC no longer supports the client authentication EKU. | Remove certificate pinning if used.<br/>Transition from mTLS if applicable. |
| March 2026 and later | ASC certificate validity is shortened.<br/>ASC migrates to a new certificate chain.<br/>ASC no longer supports the client authentication EKU. | Remove certificate pinning if used.<br/>Transition from mTLS if applicable. |

[1](https://techcommunity.microsoft.com/blog/appsonazureblog/industry-wide-certificate-changes-impacting-azure-app-service-certificates/4477924)

## Required actions

### Review certificate usage

Review how certificates are used by your App Service applications. If certificates are not pinned and are not used for client authentication, no changes are required. [1](https://techcommunity.microsoft.com/blog/appsonazureblog/industry-wide-certificate-changes-impacting-azure-app-service-certificates/4477924)

### Certificate pinning

If certificate or certificate chain pinning is used, remove pinning before the applicable migration dates to avoid service disruption. [1](https://techcommunity.microsoft.com/blog/appsonazureblog/industry-wide-certificate-changes-impacting-azure-app-service-certificates/4477924)

### Client authentication (mutual TLS)

If App Service certificates are used for client authentication, transition to an alternative authentication mechanism before the applicable migration dates. Client authentication EKU will no longer be supported for these certificates. [1](https://techcommunity.microsoft.com/blog/appsonazureblog/industry-wide-certificate-changes-impacting-azure-app-service-certificates/4477924)

## Why these changes are required

These updates are required by browser programs and standards defined by the CA/B Forum. The changes apply across the industry and affect all public certificate authorities, not only Azure App Service. [1](https://techcommunity.microsoft.com/blog/appsonazureblog/industry-wide-certificate-changes-impacting-azure-app-service-certificates/4477924)

## Next steps

- Review certificate usage across App Service apps.
