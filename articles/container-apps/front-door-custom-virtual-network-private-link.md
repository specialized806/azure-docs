---
title: Azure Container Apps with Azure Front Door Premium using Private Link
description: Deploy Azure Container Apps in a custom virtual network with internal ingress and expose them securely using Azure Front Door Premium via Private Link.
#customer intent: As a cloud architect, I want to deploy Azure Container Apps in a secure virtual network so that I can ensure private access using Azure Front Door Premium with Private Link.
author: kkaushal24011982
ms.author: kkaushal
ms.reviewer: cshoe
ms.service: azure-container-apps
ms.topic: conceptual
ms.date: 03/05/2026
---

# Use Azure Front Door with Azure Container Apps and Private Link

This article explains how to deploy an Azure Container Apps environment by using workload profiles in a custom virtual network with an internal virtual IP (internal load balancer) and public network access disabled. It also covers how to expose your container apps privately through Azure Front Door Premium by using Private Link and private endpoints. This configuration enables a secure inbound path while maintaining zone redundancy.

## Prerequisites

- An Azure account with an active subscription.
- Permissions to create resources: resource groups, virtual networks, private endpoints, Azure Container Apps, Log Analytics workspaces, and Azure Front Door profiles.
- An Azure Container Apps environment that uses **workload profiles**. This environment type is required for combining VNet integration, private endpoints, and zone redundancy.
- **Azure Front Door Premium**. This SKU is required to configure Private Link origins.
- A dedicated subnet for private endpoints (separate from the delegated Container Apps subnet).

For more information about networking requirements, see [Custom virtual network subnet address range restrictions](./custom-virtual-networks.md).

## Architecture

This guide focuses on the **workload profiles** environment type, which supports the combination of virtual network integration, private endpoints, and zone redundancy.

### Traffic flow

1. A user connects to Azure Front Door (edge).
2. Azure Front Door forwards traffic to the origin over Private Link.
3. Traffic arrives at the private endpoint IP address in the workload virtual network (for example, `10.0.2.4`).
4. The private endpoint connects to the internal Azure Container Apps environment.
5. Within the virtual network, the environment uses an internal load balancer (ILB) virtual IP (for example, `10.0.0.165`) to reach the ingress controller.
6. The ingress controller routes traffic to the correct container app, revision, and replica based on host headers and ingress configuration.

### Design considerations

| Decision | Value | Reason |
|----------|-------|--------|
| Container Apps subnet size | /23 | Allows room for scaling. |
| Front Door SKU | Premium | Required for Private Link support. |

## Deployment procedure

### 1. Create the virtual network and subnets

Create a virtual network with two subnets: one for the container apps environment and one for private endpoints.

1. In the Azure portal, search for **Virtual networks** and select **Create**.
2. Select your **Resource group** and enter a **Virtual network name**.
3. Select the target **Region**.
4. On the **IP addresses** tab, configure the address space (for example, `10.0.0.0/16`).
5. Create two subnets:
   - **Container Apps subnet**: Delegate to `Microsoft.App/environments`. Size according to your scaling needs (for example, `/23`).
   - **Private Endpoint subnet**: Don't delegate. This subnet hosts private endpoints (for example, `/24`).
6. Select **Review + create**, and then select **Create**.

### 2. Create the container app and environment

1. Search for **Container Apps** in the portal and select **Create**.
2. Choose your **Resource group** and enter a **Container app name**.
3. For **Container Apps environment**, select **Create new**.

#### Configure the environment

1. On the **Basics** tab of the environment creation page:
   - Enter an **Environment name**.
   - Select the **Region**.
   - Enable **Zone redundancy** (if available and required).
2. On the **Workload profiles** tab, add at least one profile (for example, **D4**). Set the autoscaling instance count range.
3. On the **Networking** tab:
   - Set **Public network access** to **Disabled**.
   - Set **Use your own virtual network** to **Yes**.
   - Select the virtual network and the delegated **Container Apps subnet** you created.
   - Set **Virtual IP** to **Internal**.
   - Set **Private endpoints** to **Enabled**.
   - Select **Azure Private DNS zone** to automatically configure DNS.
4. Select **Create** to create the environment.

#### Configure the container app

1. On the **Create Container App** page, go to the **Container** tab.
2. Uncheck **Use quickstart image** if you want to use your own image, or leave it checked for testing.
3. Select **Review + create**, and then select **Create**.

### 3. Verify deployment

1. Go to your resource group and verify the resources you created.
2. Open the **Container Apps environment** resource.
3. Go to **Networking**.
4. Verify that **Public network access** is **Disabled**.
5. Verify that **Virtual IP** is **Internal** and note the IP address.
6. Verify that a **Private endpoint** connection exists and is approved (if created automatically).

### 4. Create Azure Front Door Premium with Private Link

Create an Azure Front Door profile to securely access your internal container app.

1. Search for **Azure Front Door and CDN profiles** and select **Create**.
2. Select **Azure Front Door** and then **Quick create**.
3. Select **Premium** as the SKU.
4. Choose your **Resource group**.
5. Enter a **Profile name** and **Endpoint name**.
6. For **Origin type**, select **Container Apps**.
7. In **Origin host name**, select your container app environment.
8. Ensure **Private Link** is enabled.
9. Select the **Region** of your container app.
10. In **Private link approval message**, enter a message (for example, "Allow Front Door").
11. Select **Review + create**, and then select **Create**.

### 5. Approve the private endpoint connection

After you deploy Azure Front Door, approve the private endpoint connection request.

1. Go to your **Container Apps environment** resource in the Azure portal.
2. Select **Networking** > **Private endpoint connections**.
3. Select the pending connection with the description you provided (for example, "Allow Front Door").
4. Select **Approve**.
5. Wait for the status to change to **Approved**.

## Validation

1. Access the Azure Front Door endpoint URL from a browser or client.
2. Verify that your application loads correctly.
3. Confirm that direct access to the container app's default domain fails (since public access is disabled).
4. Verify that DNS resolution for the environment domain resolves to the private IP address within the virtual network.

## Troubleshooting

- **Subnet validation errors**: Ensure the Container Apps subnet is delegated to `Microsoft.App/environments` and meets size requirements.
- **Private endpoint failure**: Ensure the private endpoint is in a separate, nondelegated subnet.
- **Front Door origin error**: Check that the private endpoint connection is approved in the Container Apps environment. It might take a few minutes for the connection to be established.
- **Public access still works**: Verify that **Public network access** is set to **Disabled** in the Container Apps environment networking settings.

## Next steps

- [Networking in Azure Container Apps](./networking.md)
- [Private endpoints](./how-to-use-private-endpoint.md)
