---
title: Authentication Options for API Management Self-hosted Gateway
description: Options for the Azure API Management self-hosted gateway to authenticate to the cloud-based API Management instance.
services: api-management
author: dlepow

ms.service: azure-api-management
ms.topic: concept-article
ms.date: 02/19/2026
ms.author: danlep
---

# Self-hosted gateway authentication options

The gateway container's [configuration settings](self-hosted-gateway-settings-reference.md) provide the following options for authenticating the connection between the self-hosted gateway and the cloud-based API Management instance's configuration endpoint.

|Option  |Considerations  |
|---------|---------|
| [Microsoft Entra ID workload identity authentication](self-hosted-gateway-enable-workload-identity.md)   | No secrets or certificates to manage - uses federated identity credentials.<br/><br/>Automatic token rotation with short-lived tokens.<br/><br/>Native integration with Azure Kubernetes Service.        |
| [Microsoft Entra ID authentication with client secret](self-hosted-gateway-enable-azure-ad.md)   | Configure Microsoft Entra apps with client secrets or certificates.<br/><br/>Manage access per app with custom role assignments.<br/><br/>Configure secret expiration times per your organization's policies.<br/><br/>Use standard Microsoft Entra procedures to rotate secrets.        |
| [Microsoft Entra ID workload identity authentication](self-hosted-gateway-enable-workload-identity.md)   | No secrets or certificates to manage - uses federated identity credentials.<br/><br/>Automatic token rotation with short-lived tokens.<br/><br/>Native integration with Azure Kubernetes Service.        |
API Management generates events when a self-hosted gateway access token is near expiration or expires. Use these events to ensure that deployed gateways can always authenticate by using their associated API Management instance. For more information, see [Azure API Management as an Event Grid source](/azure/event-grid/event-schema-api-management).
API Management generates events when a self-hosted gateway access token is near expiration or expires. Use these events to ensure that deployed gateways can always authenticate by using their associated API Management instance. For more information, see [Azure API Management as an Event Grid source](/azure/event-grid/event-schema-api-management).
| [Access token](self-hosted-gateway-default-authentication.md). (Also called gateway token or an authentication key.)    |  Token expires at least every 30 days and must be renewed.<br/><br/>Backed by a gateway key that you can rotate independently.<br/><br/>Regenerating the gateway key invalidates all access tokens.<br/><br/>System events are generated when a self-hosted gateway access token is near expiration or expires.      |

