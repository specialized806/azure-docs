---
title: Industry-wide certificate changes impacting Azure App Service
description: Describes industry-wide TLS certificate changes that affect Azure App Service Managed Certificates and App Service Certificates, including scope, timelines, and required actions.
author: msangapu-msft
ms.author: msangapu
ms.date: 02/03/2026
ms.topic: conceptual
ms.service: azure-app-service
---

# Industry-wide certificate changes impacting Azure App Service

Industry-wide requirements defined by browser programs and the CA/Browser Forum (CA/B Forum) change how public TLS certificates are issued and validated. Azure App Service applies these requirements to App Service Managed Certificates (ASMC) and App Service Certificates (ASC), as described in the [Azure App Service announcement on industry-wide certificate changes](https://techcommunity.microsoft.com/blog/appsonazureblog/industry-wide-certificate-changes-impacting-azure-app-service-certificates/4477924).

The platform enforces these requirements except in specific scenarios described in this article.

## Scope

This article applies to Azure App Service apps that use:

- App Service Managed Certificates
- App Service Certificates
- Certificate pinning
- Client authentication (mutual TLS) using App Service certificates

Apps that don't pin certificates and don't use App Service certificates for client authentication aren't impacted by these changes.

## Changes by certificate type

| Area | App Service Managed Certificates (ASMC) | App Service Certificates (ASC) |
|-----|-----------------------------------------|--------------------------------|
| Certificate chain | Migrates to a new certificate chain | Migrates to a new certificate chain |
| Client authentication EKU | Not supported | Not supported |
| Certificate validity | No change | Validity shortened with overlapping certificates |

## Timeline

| Timeframe | Change |
|----------|--------|
| Mid-January 2026 and later | ASMC migrates to a new certificate chain.<br/>ASMC no longer supports the client authentication extended key usage (EKU). |
| March 2026 and later | ASC certificate validity is shortened.<br/>ASC migrates to a new certificate chain.<br/>ASC no longer supports the client authentication EKU. |

## Impact and required actions

### Certificate pinning

To avoid service disruption, apps that pin certificates or certificate chains must remove pinning before the migration dates. This requirement applies to both ASMC and ASC.

### Client authentication (mutual TLS)

App Service certificates no longer support the client authentication EKU. Apps that rely on App Service certificates for mutual TLS must transition to an alternative authentication mechanism before the migration dates.

## Background

To comply with updated certificate issuance and validation standards adopted across the industry, these changes are required. The requirements apply to all public certificate authorities, not only to Azure App Service.

## Related documentation

- App Service Managed Certificates
- App Service Certificates
- Configure TLS/SSL bindings in Azure App Service