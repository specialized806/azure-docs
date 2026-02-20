---
title: Azure Service Bus Geo-Replication | Microsoft Docs
description: How to use geographical regions to promote between regions in Azure Service Bus for metadata and data
ms.topic: article
ms.date: 07/15/2025
ms.custom:
  - references_regions
---

# Azure Service Bus Geo-Replication (Preview)

The Service Bus Geo-Replication feature is one of the options to [insulate Azure Service Bus applications against outages and disasters](service-bus-outages-disasters.md). It provides replication of both metadata (entities, configuration, properties) and data (message data and message property or state changes).

> [!NOTE]
> This feature is available for the Premium tier of Azure Service Bus.

The Geo-Replication feature continuously replicates the metadata and data of a namespace from a primary region to one or more secondary regions. It replicates:
- Queues, topics, subscriptions, and filters.
- Data that resides in the entities.
- All state changes and property changes executed against the messages within a namespace.
- Namespace configuration.

> [!NOTE]
> Currently, only a single secondary is supported.

This feature allows you to promote any secondary region to primary, at any time. Promoting a secondary repoints the namespace to the selected secondary region, and switches the roles between the primary and secondary region. The promotion is nearly instantaneous once initiated. 

> [!IMPORTANT]
> - This feature is currently in public preview, and as such shouldn't be used in production scenarios.
> - This feature is currently available on new namespaces. If a namespace had this feature enabled before, you can disable it by removing the secondary regions, and re-enable it.
> - You can't use this feature in combination with the [Azure Service Bus Geo-Disaster Recovery](service-bus-geo-dr.md) feature.
> - The following features currently aren't supported. The product team is continuously working on bringing more features and will update this list with the latest status.
>     - Large message support.
> - When you enable Event Grid integration on a namespace that uses Geo-Replication, note the following.
>   - Event Grid replicates to the [geo-paired location](/azure/reliability/reliability-event-grid#set-up-disaster-recovery), not the secondary region set up for geo-replication.
>   - [Promotion](#promotion-flow) of a secondary region for Service Bus doesn't initiate a failover of Event Grid. Consequently, after promotion, Service Bus is now running in the new primary region, but Event Grid is still running in the initial primary region.
>   - If you [remove](#delete-secondary-region) the initial primary region from the Geo-Replication configuration, this action breaks the Event Grid integration.

## Scenarios
You can use the Geo-replication feature to implement different scenarios.

### Disaster recovery
Data and metadata are continuously synchronized between the primary and secondary regions. If a region lags or is unavailable, you can promote a secondary region as the primary. This promotion allows for the uninterrupted operation of workloads in the newly promoted region. Such a promotion might be necessary because of degradation of Service Bus or other services within your workload, particularly if you aim to run the various components together. Depending on the severity and impacted services, the promotion can be planned or forced. In case of planned promotion, in-flight messages are replicated before finalizing the promotion, while with forced promotion, this step is immediate.

### Region migration
You might want to migrate your Service Bus workloads to run in a different region. For example, when Azure adds a new region that is geographically closer to your location, users, or other services. Alternatively, you might want to migrate when the regions where most of your workloads run is shifted. The Geo-Replication feature also provides a good solution in these cases. In this case, you set up Geo-Replication on your existing namespace with the desired new region as secondary region and wait for the synchronization to complete. At this point, you start a planned promotion, allowing any in-flight messages to be replicated. Once the promotion is completed you can now optionally remove the old region, which is now the secondary region, and continue running your workloads in the desired region.

## Basic concepts

The Geo-Replication feature implements metadata and data replication in a primary-secondary replication model. At a given time there’s a single primary region, which serves both producers and consumers. The secondaries act as hot stand-by regions, meaning that you can't interact with these secondary regions. However, they run in the same configuration as the primary region, allowing for fast promotion, and meaning your workloads can immediately continue running after promotion has been completed. The Geo-Replication feature is available for the [Premium tier](service-bus-premium-messaging.md).

Some of the key aspects of Geo-Replication feature are: 
- Service Bus services perform fully managed replication of metadata, message data, and message state and property changes across regions adhering to the replication consistency configured at the namespace.
- Single namespace hostname; Upon successful configuration of a Geo-Replication enabled namespace, users can use the namespace hostname in their client application. The hostname behaves agnostic of the configured primary and secondary regions, and always points to the primary region.
- When a customer initiates a promotion, the hostname points to the region selected to be the new primary region. The old primary becomes a secondary region.
- You can't read or write on the secondary regions.
- Synchronous and asynchronous replication modes, further described [here](#replication-modes).
- Customer-managed promotion from primary to secondary region, providing full ownership and visibility for outage resolution. Metrics are available, which can help to automate the promotion from customer side.
- Secondary regions can be added or removed at the customer's discretion.

## Replication modes

There are two replication modes, synchronous and asynchronous. It's important to know the differences between the two modes.

### Asynchronous replication

When you use asynchronous replication, the primary commits all requests and then sends an acknowledgment to the client. Replication to the secondary regions happens asynchronously. You can configure the maximum acceptable amount of lag time. The lag time is the service side offset between the latest action on the primary and the secondary regions. The service continuously replicates the data and metadata, ensuring the lag remains as small as possible. If the lag for an active secondary grows beyond the user configured maximum replication lag, the primary starts throttling incoming requests.

### Synchronous replication

When you use synchronous replication, the system replicates all requests to the secondary. The secondary must commit and confirm the operation before the primary commits. Your application publishes at the rate it takes to publish, replicate, acknowledge, and commit. This process also means your application depends on the availability of both regions. If the secondary region lags or is unavailable, the primary doesn't acknowledge or commit messages and throttles incoming requests.

### Replication mode comparison

With **synchronous** replication:
- Latency is longer because of the distributed commit operations.
- Availability depends on the availability of two regions.

On the other hand, synchronous replication provides the greatest assurance that your data is safe. If you use synchronous replication, the commit operation commits in all of the regions you configured for Geo-Replication, providing the best data assurance.

With **asynchronous** replication:
- Latency is minimally impacted.
- The loss of a secondary region doesn't immediately impact availability. However, availability gets impacted once the configured maximum replication lag is reached.

As such, asynchronous replication doesn't provide the absolute guarantee that all regions have the data before the commit like synchronous replication does, and data loss or duplication might occur. However, as a single region lag or unavailability no longer immediately impacts you, application availability improves, in addition to having lower latency.

| Capability                     | Synchronous replication                                      | Asynchronous replication                                           |
|--------------------------------|--------------------------------------------------------------|--------------------------------------------------------------------|
| Latency                        | Longer because of distributed commit operations              | Minimally impacted                                                 |
| Availability                   | Depends on availability of secondary regions                 | Loss of a secondary region doesn't immediately impact availability |
| Data consistency               | Data always committed in both regions before acknowledgment  | Data committed in primary only before acknowledgment               |
| RPO (Recovery Point Objective) | RPO 0, no data loss on promotion                             | RPO > 0, possible data loss on promotion                           |

You can change the replication mode after configuring Geo-Replication. You can switch from synchronous to asynchronous or from asynchronous to synchronous. If you switch from asynchronous to synchronous, your secondary is configured as synchronous after lag reaches zero. If you're running with a continual lag for any reason, you might need to pause your publishers so that lag reaches zero and your mode can switch to synchronous. The reasons to enable synchronous replication instead of asynchronous replication are tied to the importance of the data, specific business needs, or compliance reasons, rather than availability of your application.

> [!NOTE]
> If a secondary region lags or becomes unavailable, the application can no longer replicate to this region and starts throttling once the replication lag is reached. To continue using the namespace in the primary location, remove the afflicted secondary region. If you remove all secondary regions, the namespace continues without Geo-Replication enabled. You can add additional secondary regions at any time.
> Top-level entities, which are queues and topics, are replicated synchronously, regardless of the replication mode you configure. However, topic subscriptions follow the selected replication mode. Therefore, it's crucial to take them into account when deciding on the appropriate replication mode.

## Secondary region selection

To enable the Geo-Replication feature, use primary and secondary regions where the feature is enabled. The Geo-Replication feature depends on replicating published messages from the primary to the secondary regions. If the secondary region is on another continent, this choice has a major impact on replication lag from the primary to the secondary region. If you use Geo-Replication for availability reasons, choose secondary regions that are at least on the same continent where possible. To get a better understanding of the latency induced by geographic distance, see [Azure network round-trip latency statistics](/azure/networking/azure-network-latency).

## Geo-Replication management

The Geo-Replication feature enables you to configure a secondary region towards which to replicate metadata and data. As such, you can perform the following management tasks:
- Configure Geo-Replication; You can configure secondary regions on any new or existing namespace in a region with the Geo-Replication feature enabled.
> [!NOTE]
> Currently, only new namespaces are supported in the public preview.
- Configure the replication consistency; Set synchronous and asynchronous replication when you configure Geo-Replication. You can also switch these settings later.
- Trigger promotion; All promotions are customer initiated.
- Remove a secondary; If you want to remove a secondary region, you can do so. The data in the secondary region is deleted.

## Setup

### Using Azure portal

The following section provides an overview to set up the Geo-Replication feature on a new namespace through the Azure portal.

1. Create a new premium-tier namespace.
1. Check the **Enable Geo-replication checkbox** under the *Geo-Replication (preview)* section.
1. Select the **Add secondary region** button, and choose a region.
1. Either check the **Synchronous replication** checkbox, or specify a value for the **Async Replication - Max Replication lag** value in seconds.
:::image type="content" source="./media/service-bus-geo-replication/create-namespace-with-geo-replication.png" alt-text="Screenshot showing the Create Namespace experience with Geo-Replication enabled.":::

### Using a template

To create a namespace with the Geo-Replication feature enabled, add the *geoDataReplication* properties section.

# [Bicep](#tab/bicep)

```bicep
@description('Name of the Service Bus namespace')
param serviceBusName string

@description('Primary location for the namespace')
param primaryLocation string

@description('Secondary location for geo-replication')
param secondaryLocation string

@description('Maximum replication lag in seconds for async replication')
param maxReplicationLagInSeconds int

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2025-05-01-preview' = {
  name: serviceBusName
  location: primaryLocation
  sku: {
    name: 'Premium'
    tier: 'Premium'
    capacity: 1
  }
  properties: {
    geoDataReplication: {
      maxReplicationLagDurationInSeconds: maxReplicationLagInSeconds
      locations: [
        {
          locationName: primaryLocation
          roleType: 'Primary'
        }
        {
          locationName: secondaryLocation
          roleType: 'Secondary'
        }
      ]
    }
  }
}
```

# [ARM template](#tab/arm)

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "serviceBusName": {
            "type": "string",
            "metadata": {
                "description": "Name of the Service Bus namespace"
            }
        },
        "primaryLocation": {
            "type": "string",
            "metadata": {
                "description": "Primary location for the namespace"
            }
        },
        "secondaryLocation": {
            "type": "string",
            "metadata": {
                "description": "Secondary location for geo-replication"
            }
        },
        "maxReplicationLagInSeconds": {
            "type": "int",
            "metadata": {
                "description": "Maximum replication lag in seconds for async replication"
            }
        }
    },
    "resources": [
        {
            "type": "Microsoft.ServiceBus/namespaces",
            "apiVersion": "2025-05-01-preview",
            "name": "[parameters('serviceBusName')]",
            "location": "[parameters('primaryLocation')]",
            "sku": {
                "name": "Premium",
                "tier": "Premium",
                "capacity": 1
            },
            "properties": {
                "geoDataReplication": {
                    "maxReplicationLagDurationInSeconds": "[parameters('maxReplicationLagInSeconds')]",
                    "locations": [
                        {
                            "locationName": "[parameters('primaryLocation')]",
                            "roleType": "Primary"
                        },
                        {
                            "locationName": "[parameters('secondaryLocation')]",
                            "roleType": "Secondary"
                        }
                    ]
                }
            }
        }
    ]
}
```

---

## Management

After you create a namespace with the Geo-Replication feature enabled, you can manage the feature from the **Geo-Replication (preview)** blade. 

### Switch replication mode

To switch between replication modes or update the maximum replication lag, select the link under **Replication consistency**. Select the checkbox to enable or disable synchronous replication, or update the value in the text box to change the asynchronous maximum replication lag.
:::image type="content" source="./media/service-bus-geo-replication/update-namespace-geo-replication-configuration.png" alt-text="Screenshot showing how to update the configuration of the Geo-Replication feature.":::

### Delete secondary region

To remove a secondary region, select the **...**-ellipsis next to the region, and select **Delete**. Follow the instructions in the pop-up blade to delete the region.
:::image type="content" source="./media/service-bus-geo-replication/delete-secondary-region-from-geo-replication.png" alt-text="Screenshot showing how to delete a secondary region.":::

### Promotion flow

A customer manually triggers a promotion, either explicitly through a command or through client owned business logic that triggers the command. Azure never triggers a promotion. This approach gives the customer full ownership and visibility for outage resolution on Azure's backbone. When you choose **Planned** promotion, the service waits to catch up the replication lag before initiating the promotion. When you choose **Forced** promotion, the service immediately initiates the promotion. The namespace is in read-only mode from the time that a promotion is requested until the time that the promotion completes. You can do a forced promotion at any time after a planned promotion initiates. This process puts you in control to expedite the promotion when a planned failover takes longer than desired.

> [!IMPORTANT]
> When you use **Forced** promotion, you might lose any data or metadata that isn't replicated. Additionally, as specific state changes aren't replicated yet, this action might also result in duplicate messages being received. For example, duplicate messages can occur when a Complete or Defer state change isn't replicated.

After the promotion initiates:

1. The hostname updates to point to the secondary region, which can take up to a few minutes.
    > [!NOTE]
    > You can check the current primary region by initiating a ping command:
    > ping *your-namespace-fully-qualified-name*

1. Clients automatically reconnect to the secondary region.

:::image type="content" source="./media/service-bus-geo-replication/promotion-flow.png" alt-text="Screenshot of the portal showing the flow of promotion from primary to secondary region." lightbox="./media/service-bus-geo-replication/promotion-flow.png":::

You can automate promotion either with monitoring systems or with custom-built monitoring solutions. However, such automation takes extra planning and work, which is out of the scope of this article.

### Using Azure portal

In the portal, select the **Promote** icon, and follow the instructions in the pop-up blade to delete the region. 

:::image type="content" source="./media/service-bus-geo-replication/promote-secondary-region.png" alt-text="Screenshot showing the flow to promote secondary region." lightbox="./media/service-bus-geo-replication/promote-secondary-region.png":::

### Using Azure CLI

Run the Azure CLI command to start the promotion. The **Force** property is optional and defaults to **false**.

```azurecli
az rest --method post --url https://management.azure.com/subscriptions/<subscriptionId>/resourceGroups/<resourceGroup>/providers/Microsoft.ServiceBus/namespaces/<namespaceName>/failover?api-version=2024-01-01 --body "{'properties': {'PrimaryLocation': '<newPrimaryLocation>', 'api-version':'2024-01-01', 'Force':'false'}}"
```

### Monitoring data replication
You can monitor the progress of the replication job by checking the replication lag metric in Log Analytics.
- Enable Metrics logs in your Service Bus namespace as described in [Monitor Azure Service Bus](monitor-service-bus.md). 
- After enabling Metrics logs, you need to produce and consume data from the namespace for a few minutes before you start to see the logs. 
- To view Metrics logs, go to the Monitoring section of Service Bus and select the **Logs** blade. You can use the following query to find the replication lag (in seconds) between the primary and secondary regions. 

```kusto
AzureMetrics
| where TimeGenerated > ago(1h)
| where MetricName == "ReplicationLagDuration"
```

### Publishing data
Publishing applications can send data to geo replicated namespaces through the namespace hostname of the Geo-Replication enabled namespace. The publishing approach is the same as the non-Geo-Replication case. You don't need to make any changes to data plane SDKs or client applications. 
Publishing might not be available during the following circumstances:
- After requesting promotion of a secondary region, the existing primary region rejects any new messages that are published to Service Bus until promotion finishes.
- When replication lag between primary and secondary regions reaches the max replication lag duration, the publisher ingress workload might get throttled. 

Publisher applications can't directly access any namespaces in the secondary regions. 

### Consuming Data 
Consuming applications can consume data by using the namespace hostname of a namespace with the Geo-Replication feature enabled. Consumer operations aren't supported from the moment that promotion starts until promotion finishes.

## Considerations

Keep the following considerations in mind when using this feature:

- In your promotion planning, consider the time factor. For example, if you lose connectivity for longer than 15 to 20 minutes, you might decide to initiate the promotion.
- You should [rehearse](/azure/architecture/reliability/disaster-recovery#disaster-recovery-plan) promoting a complex distributed infrastructure at least once.

## Pricing
You pay for the Premium tier of Service Bus based on the number of [Messaging Units](service-bus-premium-messaging.md#how-many-messaging-units-are-needed). When you use the Geo-Replication feature, secondary regions run on the same number of MUs as the primary region, and you calculate pricing over the total number of MUs. Additionally, there's a charge based on the published bandwidth times the number of secondary regions.

You calculate the total cost as follows:
</br>
(number of instances × number of MUs configured on primary × hours × hourly rate) + (number of GBs replicated × Geo-Replication Data Transfer rate for the zone where the primary region was located at the time).

For example, if you have a namespace with 2 MU configured on the primary namespace, and you have 10 GB of data transfer, the calculation looks as follows:
</br>
(2 × 2 × hours × hourly rate) + (10 × Geo-Replication Data Transfer rate).

## Criteria to trigger promotion
A promotion from secondary to primary region might be triggered in the following cases:
- **Regional outage:** If a regional outage affects the primary region, promote the secondary region to ensure business continuity and minimize downtime.
- **Maintenance activities:** During planned maintenance activities in the primary region, promoting the secondary region helps maintain high availability for mission-critical applications.
- **Disaster recovery:** In the event of a disaster affecting the primary region, promoting the secondary region ensures that your data remains accessible and your applications continue to function.
- **Performance issues:** If the primary region experiences performance issues that impact the availability or reliability of your namespace, promoting the secondary region helps mitigate these issues.

Periodically test failover mechanisms to ensure the business continuity plan is effective and your applications can seamlessly switch to the secondary region when needed.

## Migration
To migrate from [Geo-Disaster Recovery](service-bus-geo-dr.md) to Geo-Replication, first break the pairing on your primary namespace.

:::image type="content" source="./media/service-bus-geo-replication/break-geo-dr-pairing.png" alt-text="Screenshot showing to click the Break pairing button in the Geo-DR overview.":::

After you break the pairing, follow the [setup](#setup) to enable Geo-Replication.

## Private endpoints

This section provides additional considerations when using Geo-Replication with namespaces that use private endpoints. For general information on using private endpoints with Service Bus, see [Integrate Azure Service Bus with Azure Private Link](private-link-service.md).

When you implement Geo-Replication for a Service Bus namespace that uses private endpoints, create private endpoints for both the primary and secondary regions. Configure these endpoints against virtual networks that host both primary and secondary instances of your application. For example, if you have two virtual networks, VNET-1 and VNET-2, you need to create two private endpoints on the Service Bus namespace, using subnets from VNET-1 and VNET-2 respectively. Set up the virtual networks with [cross-region peering](/azure/virtual-network/virtual-network-peering-overview), so that clients can communicate with either of the private endpoints. Finally, manage the [DNS](/azure/private-link/private-endpoint-dns) so all clients get the DNS information that points the namespace endpoint (namespacename.servicebus.windows.net) to the IP address of the private endpoint in the current primary region.

> [!IMPORTANT]
> When [promoting](#promotion-flow) a secondary region for Service Bus, update the DNS entry to point to the corresponding endpoint. If you manage your DNS on-premises to point to the private endpoint for a given namespace, you need to update your on-premises DNS server when you perform a failover.

:::image type="content" source="./media/service-bus-geo-replication/geo-replication-private-endpoints.png" alt-text="Screenshot showing two VNETs with their own private endpoints and VMs connected to an on-premises instance and a Service Bus namespace.":::

The advantage of this approach is that failover can occur independently at the application layer or on the Service Bus namespace:

- Application-only failover: In this scenario, the application moves from VNET-1 to VNET-2. Since private endpoints are configured on both VNET-1 and VNET-2 for both primary and secondary namespaces, the application continues to function seamlessly.
- Service Bus namespace-only failover: Similarly, if the failover occurs only at the Service Bus namespace level, the application remains operational because private endpoints are configured on both virtual networks.

By following these guidelines, you can ensure robust and reliable failover mechanisms for your Service Bus namespaces that use private endpoints.

## Next steps

To learn more about Service Bus messaging, see the following articles:

* [Service Bus queues, topics, and subscriptions](service-bus-queues-topics-subscriptions.md)
* [Get started with Service Bus queues](service-bus-dotnet-get-started-with-queues.md)
* [How to use Service Bus topics and subscriptions](service-bus-dotnet-how-to-use-topics-subscriptions.md)
* [REST API](/rest/api/servicebus/)
