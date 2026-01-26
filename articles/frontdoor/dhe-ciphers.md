---
title: DHE ciphers
titleSuffix: Azure Front Door
description: Learn about how to stop using DHE ciphers on Azure Front Door and CDN
author: halkazwini
ms.author: halkazwini
ms.service: azure-frontdoor
ms.topic: concept-article
ms.date: 01/26/2025
zone_pivot_groups: front-door-tiers
---

# TLS_DHE cipher suites on Azure Front Door and Azure CDN

On April 1, 2026, Azure Front Door (Standard, Premium, and Classic) and Azure CDN from Microsoft (Classic) services will stop negotiating the following weak DHE cipher suites for both client to service and service to origin TLS connections:
* TLS_DHE_RSA_WITH_AES_256_GCM_SHA384
* TLS_DHE_RSA_WITH_AES_128_GCM_SHA256

## Who is affected?

You are affected if any of the following are true:
* Your clients (browsers/agents/devices) must require one of the DHE cipher suites when connecting to your Front Door/CDN endpoint.
* Your origins must require one of the retired DHE cipher suites when Front Door/ CDN connects to your origin.

## How will I know if I am impacted?
* Impacted subscriptions and resources will receive Azure service health notification and email notifications.

## What is the impact if I do not act?
* Connections that can only use the retired DHE ciphers will fail the TLS handshake (for clients) or fail on service to origin negotiation (for origins). 
* Typical symptoms include handshake failure / no shared cipher errors / invalid cipher error in clients or origin server logs.

## Action required
1.	Ensure your origin servers disable DHE ciphers and enable the recommended cipher suites. 
2.	Inform your clients to disable DHE ciphers and enable the recommended cipher suites.

## Recommended cipher suites
For best compatibility and security on Azure Front Door / Azure CDN endpoints and origins, we recommend using the following cipher suites:
* TLS_AES_256_GCM_SHA384 (TLS 1.3 only)
* TLS_AES_128_GCM_SHA256 (TLS 1.3 only)
* TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
* TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
* TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384
* TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256

## Frequently asked questions
1. Does this affect both client and origin connections?
* Yes. The retirement applies to both the client to service and service to origin legs. Update both sides to avoid issues.
2. What if I still need legacy client compatibility?
* Migrate clients to support TLS 1.2/1.3 with ECDHE. If you operate controlled clients, update their TLS policy. 
3. Should I make any changes to my Front Door or CDN profiles?
* As an optional measure, for Front Door Standard/Premium profiles, you can also use the [Configure Azure Front Door TLS policy](/articles/frontdoor/standard-premium/tls-policy.md) feature to disable the DHE ciphers in advance before 1 April 2026. This option is not available for other tiers. 
* For all Front Door (Standard, Premium, Classic) and Azure CDN from Microsoft (Classic) profiles, Microsoft team will disable the DHE ciphers after 1 April 2026.




