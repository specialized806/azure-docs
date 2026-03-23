---
title: 'Connection policy'
titleSuffix: Azure Virtual WAN
description: Learn about  Azure Virtual WAN connection policies.
author: wtnlee
ms.service: azure-virtual-wan
ms.topic: how-to
ms.date: 03/18/2026
ms.author: wellee
---

The following document describes how to configure connection policy in Azure Virtual WAN.

## Background

Connection policies provide a way to group multiple Virtual WAN connections and apply common configuration to them. Connection poicies are designed to make bulk-management easier by allowing you to apply configurations to a group of Virtual Network connections as one atomic operation. Connection policies also provide enforcement. Properties configured through connection policies are prioritized by Virtual WAN and overrides connection-specific configurations. This allows you to ensure that the correct configuration is applied to all connections under the policy and prevent accidental misconfiguration of individual connections. 

Connection policies are not designed to be a replacement for all connection-level configuration properties, and there may be some connection-specific properties that can't be configured through connection policies. For example, static routes require next hop IP addresses that are specific to each connection and can't be repeated across multiple connections.

## Application scope

Connection policies are scoped to the Virtual WAN hub on which the policy is created. As a result, connection policies can only manage connections connected to the same Virtual WAN hub. In addition, connection policies can only be applied to **Virtual Network connections**.

Connection policies can manage the following properties of Virtual Network connections. Other properties such as static routes are connection-specific and bulk management is not applicable.

* **Enable internet security**: Controls whether or not Virtual WAN advertises the default route (0.0.0.0/0) to the Virtual Network connection.
* **Associated route table**: Specifies which Virtual WAN route table is associated with the Virtual Network connection.
* **Propgated route table**: Specifies which Virtual WAN route table  Virtual Network connection propagates rotues to.
* **Propagated labels**: Specifies which labels the Virtual Network connection propagates to.
* **Inbound/Outbound route maps**: Specifies which route maps are applied to routes learnt from or advertised to the Virtual Network connection.

## Considerations

* A Virtual network connection can only be managed by one connection policy at a time. If you have different groups of connections with different configurations, create multiple connection policies and group the connections accordingly.
* Routing intent automatically configures the associations and propagations for Virtual Network connections. Connection policies can't override the associated and propagated route tables and labels for Virtual Network connections to hubs configured with routing intent.
* Connection policies can't be used to create new Virtual Network connections. Create the Virtual Network connections and then add the new connection to an existing connection policy, or use Azure Virutual Network Manager to facilitate the creation of new Virtual network connections to Virtual WAN.
* Connection policies don't overwrite existing connection-level settings. Instead, connection policies are applied on top of connection-level settings. If there are conflicting settings between a connection policy and connection-level settings, the connection policy settings will take precedence. This ensures that you can easily roll-back any changes by simply removing the connection from the connection policy.

## Create a connection policy

## Update a connection policy
1. Select the three dots on the right side of the connection policy you want to modify, and select **Edit Connection Policy**.
1. Change any of the available properties of the connection policy. 
1. Review the **Virtual Network Connections** tab to see which connections will be impacted by the changes to the connection policy.
1. Select **Save** to apply the changes to the connection policy and propagate the changes to all Virtual Network connections utilizing the connection policy.

## Add new Virtual Network connections to connection policy
1. 

## Remove Virtual Network connections from connection policy



<!-- Content to be added. -->





















