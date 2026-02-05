---
title: Compare Azure Storage queues and Service Bus queues
description: Compare Azure Storage queues and Service Bus queues to determine the best fit for your application. Learn about their features, use cases, and differences.
#customer intent: As a solution architect, I want to compare Azure Storage queues and Service Bus queues so that I can choose the best option for my application requirements.
ms.topic: article
ms.date: 02/05/2025
---

# Storage queues and Service Bus queues - compared and contrasted
This article analyzes the differences and similarities between the two types of queues offered by Microsoft Azure: Storage queues and Service Bus queues. By using this information, you can make a more informed decision about which solution best meets your needs.

## Quick reference

Use this table to quickly identify which queue technology best fits your requirements:

| Requirement | Recommended solution |
| --- | --- |
| Simple, low-cost queuing | Storage queues |
| Queue size larger than 80 GB | Storage queues |
| Server-side transaction logs | Storage queues |
| Guaranteed FIFO delivery | Service Bus queues |
| Duplicate detection | Service Bus queues |
| Dead-letter queue support | Service Bus queues |
| Message sessions/grouping | Service Bus queues |
| Transactions across multiple messages | Service Bus queues |
| Publish-subscribe patterns | Service Bus queues |

## Common use cases

### Storage queues use cases

- **Background job processing**: Queue tasks like image resizing, report generation, or email sending for asynchronous processing.
- **Application decoupling**: Separate front-end web applications from back-end processing services.
- **Load leveling**: Buffer incoming requests during traffic spikes to protect back-end services.
- **Large-scale batch processing**: Process millions of messages for data pipeline or ETL operations.

### Service Bus queues use cases

- **Enterprise application integration**: Connect on-premises systems with cloud applications using reliable messaging.
- **Order processing systems**: Ensure exactly-once processing with duplicate detection and sessions.
- **Financial transactions**: Use transactions to guarantee atomic operations across multiple messages.
- **Workflow orchestration**: Implement complex business processes with message sessions and state management.
- **Microservices communication**: Enable reliable communication between microservices with dead-letter support for failed messages.

## Introduction
Azure supports two types of queue mechanisms: **Storage queues** and **Service Bus queues**.

**Storage queues** are part of the [Azure Storage](https://azure.microsoft.com/services/storage/) infrastructure. They allow you to store large numbers of messages. You access messages from anywhere in the world via authenticated calls using HTTP or HTTPS. A queue message can be up to 64 KB in size. A queue might contain millions of messages, up to the total capacity limit of a storage account. Queues are commonly used to create a backlog of work to process asynchronously. For more information, see [What are Azure Storage queues](../storage/queues/storage-queues-introduction.md).

**Service Bus queues** are part of a broader [Azure messaging](https://azure.microsoft.com/services/service-bus/) infrastructure that supports queuing, publish/subscribe, and more advanced integration patterns. They're designed to integrate applications or application components that might span multiple communication protocols, data contracts, trust domains, or network environments. For more information about Service Bus queues/topics/subscriptions, see the [Service Bus queues, topics, and subscriptions](service-bus-queues-topics-subscriptions.md).


## Technology selection considerations
Storage queues and Service Bus queues have a slightly different feature set. You can choose either one or both, depending on the needs of your particular solution.

When determining which queuing technology fits the purpose of a given solution, solution architects and developers should consider these recommendations. 

### Consider using Storage queues
As a solution architect or developer, **consider using Storage queues** when:

* Your application must store over 80 gigabytes of messages in a queue.
* Your application wants to track progress for processing a message in the queue. This feature is useful if the worker processing a message crashes. Another worker can then use that information to continue from where the prior worker left off.
* You require server side logs of all of the transactions executed against your queues.

### Consider using Service Bus queues
As a solution architect or developer, **consider using Service Bus queues** when:

* Your solution needs to receive messages without having to poll the queue. With Service Bus, you can achieve it by using a long-polling receive operation using the TCP-based protocols that Service Bus supports.
* Your solution requires the queue to provide a guaranteed first-in-first-out (FIFO) ordered delivery.
* Your solution needs to support automatic duplicate detection.
* You want your application to process messages as parallel long-running streams (messages are associated with a stream using the **session ID** property on the message). In this model, each node in the consuming application competes for streams, as opposed to messages. When a stream is given to a consuming node, the node can examine the state of the application stream state using transactions.
* Your solution requires transactional behavior and atomicity when sending or receiving multiple messages from a queue.
* Your application handles messages that can exceed 64 KB but won't likely approach the 256 KB or 1 MB limit, depending on the chosen [service tier](service-bus-premium-messaging.md) (although Service Bus queues can [handle messages up to 100 MB](service-bus-premium-messaging.md#large-messages-support)).
* You need to provide a role-based access model to the queues, and different rights and permissions for senders and receivers. For more information, see the following articles:
    - [Authenticate with managed identities](service-bus-managed-service-identity.md)
    - [Authenticate from an application](authenticate-application.md)
* Your queue size won't grow larger than 80 GB.
* You want to use the AMQP 1.0 standards-based messaging protocol. For more information about AMQP, see [Service Bus AMQP Overview](service-bus-amqp-overview.md).
* You envision an eventual migration from queue-based point-to-point communication to a publish-subscribe messaging pattern. This pattern enables integration of additional receivers (subscribers). Each receiver receives independent copies of either some or all messages sent to the queue. 
* Your messaging solution needs to support the "At-Most-Once" and the "At-Least-Once" delivery guarantees without the need for you to build the additional infrastructure components.
* Your solution needs to publish and consume batches of messages.

## Foundational capabilities
The tables in the following sections provide a logical grouping of queue features. They let you compare, at a glance, the capabilities available in both Azure Storage queues and Service Bus queues.

This section compares some of the fundamental queuing capabilities provided by Storage queues and Service Bus queues.

| Comparison criteria | Storage queues | Service Bus queues |
| --- | --- | --- |
| Ordering guarantee | No <br/><br>For more information, see the first note in the [Foundational capabilities - details](#foundational-capabilities---details) section.</br> | Yes - First-In-First-Out (FIFO)<br/><br>(by using [message sessions](message-sessions.md)) |
| Delivery guarantee |At-Least-Once |At-Least-Once (using PeekLock receive mode. It's the default) <br/><br/>At-Most-Once (using ReceiveAndDelete receive mode) <br/> <br/> Learn more about various [Receive modes](service-bus-queues-topics-subscriptions.md#receive-modes)  |
| Atomic operation support |No |Yes<br/><br/> |
| Receive behavior |Nonblocking<br/><br/>(completes immediately if no new message is found) |Blocking with or without a timeout<br/><br/>(offers long polling)<br/><br/>Nonblocking<br/><br/>(using .NET managed API only) |
| Push-style API |No |Yes<br/><br/>Our .NET, Java, JavaScript, and Go SDKs provide push-style API. |
| Receive mode |Peek & Lease |Peek & Lock<br/><br/>Receive & Delete |
| Exclusive access mode |Lease-based |Lock-based |
| Lease/Lock duration |30 seconds (default)<br/><br/>7 days (maximum) (You can renew or release a message lease using the [UpdateMessage](/dotnet/api/microsoft.azure.storage.queue.cloudqueue.updatemessage) API.) |30 seconds (default)<br/><br/>You can renew the message lock for the same lock duration each time manually or use the automatic lock renewal feature where the client manages lock renewal for you. |
| Lease/Lock precision |Message level<br/><br/>Each message can have a different time-out value, which you can then update as needed while processing the message, by using the [UpdateMessage](/dotnet/api/microsoft.azure.storage.queue.cloudqueue.updatemessage) API. |Queue level<br/><br/>(each queue has a lock precision applied to all of its messages, but the lock can be renewed as described in the previous row) |
| Batched receive |Yes<br/><br/>(explicitly specifying message count when retrieving messages, up to a maximum of 32 messages) |Yes<br/><br/>(implicitly enabling a prefetch property or explicitly by using transactions) |
| Batched send |No |Yes<br/><br/>(by using transactions or client-side batching) |

### Foundational capabilities - details

<!-- Move content from "Additional information" here, renaming to avoid duplicate H3 headings -->
* Messages in Storage queues are typically first-in-first-out, but sometimes they can be out of order. For example, when the visibility timeout duration of a message expires because a client application crashed while processing a message. When the visibility timeout expires, the message becomes visible again on the queue for another worker to dequeue it. At that point, the newly visible message might be placed in the queue to be dequeued again.
* The guaranteed FIFO pattern in Service Bus queues requires the use of messaging sessions. If the application crashes while it's processing a message received in the **Peek & Lock** mode, the next time a queue receiver accepts a messaging session, it starts with the failed message after the session's lock duration expires.
* Storage queues are designed to support standard queuing scenarios, such as the following ones:
    - Decoupling application components to increase scalability and tolerance for failures
    - Load levelingding message handling in the context of Service Bus sessions by using session state to store the application's state relative to the progress of handling the session's message sequence, and by using transactions around settling received messages and updating the session state. This kind of consistency feature is sometimes labeled *exactly once processing* in other vendor's products. Any transaction failures cause messages to be redelivered and that's why the term isn't exactly adequate.
    - Building process workflows.
| Automatic dead lettering |No |Yes | for local transactions in the context of a single queue.
| Increasing queue time-to-live value |Yes<br/><br/>(via in-place update of visibility time-out) |Yes<br/><br/>(provided via a dedicated API function) |mode supported by Service Bus provides the ability to reduce the messaging operation count (and associated cost) in exchange for lowered delivery assurance.
| Poison message support |Yes |Yes | ability to extend the leases for messages. This feature allows the worker processes to maintain short leases on messages. If a worker crashes, another worker can quickly process the message. Also, a worker can extend the lease on a message if it needs to process it longer than the current lease time.
| In-place update |Yes |Yes |
| Server-side transaction log |Yes |No |
| Storage metrics |Yes<br/><br/>Minute Metrics provides real-time metrics for availability, TPS, API call counts, error counts, and more. They're all in real time, aggregated per minute, and reported within a few minutes from what just happened in production. For more information, see [About Storage Analytics Metrics](/rest/api/storageservices/fileservices/About-Storage-Analytics-Metrics). |Yes<br/><br/>For information about metrics supported by Azure Service Bus, see [Message metrics](monitor-service-bus-reference.md#message-metrics). |Service Bus enables a queue client to batch multiple messages into a single send operation. Batching is only available for asynchronous send operations.
| State management |No |Yes (Active, Disabled, SendDisabled, ReceiveDisabled. For details on these states, see [Queue status](entity-suspend.md#queue-status)) |ize accounts) and unlimited queues make it an ideal platform for SaaS providers.
| Message autoforwarding |No |Yes |s control mechanism.
| Purge queue function |Yes |[Yes](/azure/service-bus-messaging/batch-delete)|
| Message groups |No |Yes<br/><br/>(by using messaging sessions) |
| Application state per message group |No |Yes |ilities provided by Storage queues and Service Bus queues.
| Duplicate detection |No |Yes<br/><br/>(configurable on the sender side) |
| Browsing message groups |No |Yes || Comparison criteria | Storage queues | Service Bus queues |
| Fetching message sessions by ID |No |Yes |
| Scheduled delivery |Yes |Yes |
### Advanced capabilities - details
e-out) |Yes<br/><br/>(provided via a dedicated API function) |
<!-- Move content from "Additional information" here -->
* Both queuing technologies enable a message to be scheduled for delivery at a later time.
* Queue autoforwarding enables thousands of queues to autoforward their messages to a single queue, from which the receiving application consumes the message. You can use this mechanism to achieve security, control flow, and isolate storage between each message publisher.
* Storage queues provide support for updating message content. You can use this functionality for persisting state information and incremental progress updates into the message so that it can be processed from the last known checkpoint, instead of starting from scratch. With Service Bus queues, you can enable the same scenario by using message sessions. For more information, see [Message session state](message-sessions.md#message-session-state). availability, TPS, API call counts, error counts, and more. They're all in real time, aggregated per minute, and reported within a few minutes from what just happened in production. For more information, see [About Storage Analytics Metrics](/rest/api/storageservices/fileservices/About-Storage-Analytics-Metrics). |Yes<br/><br/>For information about metrics supported by Azure Service Bus, see [Message metrics](monitor-service-bus-reference.md#message-metrics). |
* Service Bus queues support [dead lettering](service-bus-dead-letter-queues.md). It can be useful for isolating messages that meet the following criteria:
    - Messages can't be processed successfully by the receiving application. 
    - Messages can't reach their destination because of an expired time-to-live (TTL) property. The TTL value specifies how long a message remains in the queue. With Service Bus, the message moves to a special queue called $DeadLetterQueue when the TTL period expires.
* To find "poison" messages in Storage queues, when dequeuing a message the application examines the [DequeueCount](/dotnet/api/microsoft.azure.storage.queue.cloudqueuemessage.dequeuecount) property of the message. If **DequeueCount** is greater than a given threshold, the application moves the message to an application-defined "dead letter" queue.
* Storage queues enable you to obtain a detailed log of all of the transactions executed against the queue, and aggregated metrics. Both of these options are useful for debugging and understanding how your application uses Storage queues. They're also useful for performance-tuning your application and reducing the costs of using queues.
* [Message sessions](message-sessions.md) supported by Service Bus enable messages that belong to a logical group to be associated with a receiver. It creates a session-like affinity between messages and their respective receivers. You can enable this advanced functionality in Service Bus by setting the session ID property on a message. Receivers can then listen on a specific session ID and receive messages that share the specified session identifier.| Duplicate detection |No |Yes<br/><br/>(configurable on the sender side) |
* The duplication detection feature of Service Bus queues automatically removes duplicate messages sent to a queue or topic, based on the value of the message ID property.ups |No |Yes |

## Capacity and quotas
This section compares Storage queues and Service Bus queues from the perspective of [capacity and quotas](service-bus-quotas.md) that might apply.

| Comparison criteria | Storage queues | Service Bus queues |
| --- | --- | --- |
| Maximum queue size |5 PiB<br/><br/>(limited to a [single storage account capacity](../storage/common/storage-introduction.md#queue-storage)) |1 GB to 80 GB<br/><br/>(Premium or Standard tier with partitioning)|single queue, from which the receiving application consumes the message. You can use this mechanism to achieve security, control flow, and isolate storage between each message publisher.
| Maximum message size |64 KB<br/><br/>(48 KB when using Base 64 encoding)<br/><br/>Azure supports large messages by combining queues and blobs – at which point you can enqueue up to 200 GB for a single item. |256 KB, 1 MB, or 100 MB<br/><br/>(including both header and body, maximum header size: 64 KB).<br/><br/>Depends on the [service tier](service-bus-premium-messaging.md). |cremental progress updates into the message so that it can be processed from the last known checkpoint, instead of starting from scratch. With Service Bus queues, you can enable the same scenario by using message sessions. For more information, see [Message session state](message-sessions.md#message-session-state).
| Maximum message TTL |Infinite (api-version 2017-07-27 or later) |TimeSpan.MaxValue |dead-letter-queues.md). It can be useful for isolating messages that meet the following criteria:
| Maximum number of queues |Unlimited |10,000 (Standard tier)<br/>1,000 / Messaging Unit (Premium tier)<br/>(per service namespace) |    - Messages can't be processed successfully by the receiving application. 
| Maximum number of concurrent clients |Unlimited |5,000 |destination because of an expired time-to-live (TTL) property. The TTL value specifies how long a message remains in the queue. With Service Bus, the message moves to a special queue called $DeadLetterQueue when the TTL period expires.
* To find "poison" messages in Storage queues, when dequeuing a message the application examines the [DequeueCount](/dotnet/api/microsoft.azure.storage.queue.cloudqueuemessage.dequeuecount) property of the message. If **DequeueCount** is greater than a given threshold, the application moves the message to an application-defined "dead letter" queue.
### Capacity and quotas - detailsall of the transactions executed against the queue, and aggregated metrics. Both of these options are useful for debugging and understanding how your application uses Storage queues. They're also useful for performance-tuning your application and reducing the costs of using queues.
sten on a specific session ID and receive messages that share the specified session identifier.
<!-- Move content from "Additional information" here -->
* Service Bus enforces queue size limits. The maximum queue size is specified when creating a queue. It can be between 1 GB and 80 GB. If the queue's size reaches this limit, Service Bus rejects additional incoming messages and the caller receives an exception. For more information about quotas in Service Bus, see [Service Bus Quotas](service-bus-quotas.md).
* In the Standard messaging tier, you can create Service Bus queues and topics in 1 (default), 2, 3, 4, or 5-GB sizes. When you enable partitioning in the Standard tier, Service Bus creates 16 copies (16 partitions) of the entity, each of the same size specified. As such, if you create a queue that's 5 GB in size, with 16 partitions the maximum queue size becomes (5 * 16) = 80 GB. You can see the maximum size of your partitioned queue or topic in the [Azure portal].
* With Storage queues, if the content of the message isn't XML-safe, then it must be **Base64** encoded. If you **Base64**-encode the message, the user payload can be up to 48 KB, instead of 64 KB.
* With Service Bus queues, each message stored in a queue is composed of two parts: a header and a body. The total size of the message can't exceed the maximum message size supported by the service tier.
* When clients communicate with Service Bus queues over the TCP protocol, the maximum number of concurrent connections to a single Service Bus queue is limited to 100. This number is shared between senders and receivers. If this quota is reached, requests for additional connections are rejected and the calling code receives an exception. This limit isn't imposed on clients connecting to the queues by using REST-based API.| Comparison criteria | Storage queues | Service Bus queues |
* To scale beyond 10,000 queues with Service Bus Standard Stock Keeping Unit (SKU) or 1,000 queues per Messaging Unit with Service Bus Premium SKU, you can also create additional namespaces by using the [Azure portal].
common/storage-introduction.md#queue-storage)) |1 GB to 80 GB<br/><br/>(Premium or Standard tier with partitioning)|
## Management and operations| Maximum message size |64 KB<br/><br/>(48 KB when using Base 64 encoding)<br/><br/>Azure supports large messages by combining queues and blobs – at which point you can enqueue up to 200 GB for a single item. |256 KB, 1 MB, or 100 MB<br/><br/>(including both header and body, maximum header size: 64 KB).<br/><br/>Depends on the [service tier](service-bus-premium-messaging.md). |
This section compares the management features provided by Storage queues and Service Bus queues.ter) |TimeSpan.MaxValue |
 queues |Unlimited |10,000 (Standard tier)<br/>1,000 / Messaging Unit (Premium tier)<br/>(per service namespace) |
| Comparison criteria | Storage queues | Service Bus queues |
| --- | --- | --- |
| Management protocol | REST over HTTP/HTTPS | REST over HTTPS |
| Runtime protocol | REST over HTTP/HTTPS | REST over HTTPS<br/><br/>AMQP 1.0 Standard (TCP with TLS) |
| .NET API | Yes<br/><br/>(.NET Storage Client API) |Yes<br/><br/>(.NET Service Bus API) |Additional information" here -->
| Native C++ | Yes | Yes |queue size limits. The maximum queue size is specified when creating a queue. It can be between 1 GB and 80 GB. If the queue's size reaches this limit, Service Bus rejects additional incoming messages and the caller receives an exception. For more information about quotas in Service Bus, see [Service Bus Quotas](service-bus-quotas.md).
| Java API | Yes | Yes | tier, you can create Service Bus queues and topics in 1 (default), 2, 3, 4, or 5-GB sizes. When you enable partitioning in the Standard tier, Service Bus creates 16 copies (16 partitions) of the entity, each of the same size specified. As such, if you create a queue that's 5 GB in size, with 16 partitions the maximum queue size becomes (5 * 16) = 80 GB. You can see the maximum size of your partitioned queue or topic in the [Azure portal].
| PHP API | Yes | Yes |the message isn't XML-safe, then it must be **Base64** encoded. If you **Base64**-encode the message, the user payload can be up to 48 KB, instead of 64 KB.
| Node.js API | Yes | Yes |he service tier.
| Arbitrary metadata support | Yes | No |0. This number is shared between senders and receivers. If this quota is reached, requests for additional connections are rejected and the calling code receives an exception. This limit isn't imposed on clients connecting to the queues by using REST-based API.
| Queue naming rules | Up to 63 characters long<br/><br/>(Letters in a queue name must be lowercase.) | Up to 260 characters long <br/><br/>(Queue paths and names are case-insensitive.) |es with Service Bus Standard Stock Keeping Unit (SKU) or 1,000 queues per Messaging Unit with Service Bus Premium SKU, you can also create additional namespaces by using the [Azure portal].
| Get queue length function | Yes<br/><br/>(Approximate value if messages expire beyond the TTL without being deleted.) |Yes<br/><br/>(Exact, point-in-time value.) |
| Peek function | Yes | Yes |
This section compares the management features provided by Storage queues and Service Bus queues.
### Management and operations - details

<!-- Move content from "Additional information" here -->
* Storage queues support arbitrary attributes that you can apply to the queue description as name/value pairs.
* Both queue technologies offer the ability to peek a message without locking it, which can be useful when implementing a queue explorer or browser tool.
* The Service Bus .NET brokered messaging APIs use full-duplex TCP connections for better performance compared to REST over HTTP, and they support the AMQP 1.0 standard protocol.
* Storage queue names can be 3-63 characters long and can contain lowercase letters, numbers, and hyphens. For more information, see [Naming Queues and Metadata](/rest/api/storageservices/fileservices/Naming-Queues-and-Metadata).| Native C++ | Yes | Yes |
* Service Bus queue names can be up to 260 characters long and have less restrictive naming rules. Service Bus queue names can contain letters, numbers, periods, hyphens, and underscores.

## Authentication and authorization| Node.js API | Yes | Yes |
This section discusses the authentication and authorization features supported by Storage queues and Service Bus queues.
s | Up to 63 characters long<br/><br/>(Letters in a queue name must be lowercase.) | Up to 260 characters long <br/><br/>(Queue paths and names are case-insensitive.) |
| Comparison criteria | Storage queues | Service Bus queues |
| --- | --- | --- |
| Authentication | [Symmetric key](../storage/common/storage-account-keys-manage.md) and [Role-based access control (RBAC)](../storage/queues/assign-azure-role-data-access.md) |[Symmetric key](service-bus-authentication-and-authorization.md#shared-access-signature) and [Role-based access control (RBAC)](service-bus-authentication-and-authorization.md#microsoft-entra-id) |
| Identity provider federation | Yes | Yes |

### Authentication and authorization - details

<!-- Move content from "Additional information" here -->
* Every request to either of the queuing technologies must be authenticated. Public queues with anonymous access aren't supported. 
* Using shared access signature (SAS) authentication, you can create a shared access authorization rule on a queue that can give users a write-only, read-only, or full access. For more information, see [Azure Storage - SAS authentication](../storage/common/storage-sas-overview.md) and [Azure Service Bus - SAS authentication](service-bus-sas.md).* Storage queue names can be 3-63 characters long and can contain lowercase letters, numbers, and hyphens. For more information, see [Naming Queues and Metadata](/rest/api/storageservices/fileservices/Naming-Queues-and-Metadata).
* Both queues support authorizing access by using Microsoft Entra ID. Authorizing users or applications by using an OAuth 2.0 token returned by Microsoft Entra ID provides superior security and ease of use over shared access signatures (SAS). When you use Microsoft Entra ID, you don't need to store the tokens in your code and risk potential security vulnerabilities. For more information, see [Azure Storage - Microsoft Entra authentication](../storage/queues/assign-azure-role-data-access.md) and [Azure Service Bus - Microsoft Entra authentication](service-bus-authentication-and-authorization.md#microsoft-entra-id). mes can be up to 260 characters long and have less restrictive naming rules. Service Bus queue names can contain letters, numbers, periods, hyphens, and underscores.

## Cost considerations
This section discusses the authentication and authorization features supported by Storage queues and Service Bus queues.
When evaluating costs, consider the following factors:
ia | Storage queues | Service Bus queues |
| Factor | Storage queues | Service Bus queues |
| --- | --- | --- |e.md) and [Role-based access control (RBAC)](../storage/queues/assign-azure-role-data-access.md) |[Symmetric key](service-bus-authentication-and-authorization.md#shared-access-signature) and [Role-based access control (RBAC)](service-bus-authentication-and-authorization.md#microsoft-entra-id) |
| Pricing model | Pay per operation and storage | Pay per operation, with tier-based pricing |
| Free tier availability | Included in Azure free account | Limited free tier |
| Cost for high-volume scenarios | Generally lower | Higher, but includes advanced features |- details

For current pricing information, see:
- [Azure Storage pricing](https://azure.microsoft.com/pricing/details/storage/queues/)* Every request to either of the queuing technologies must be authenticated. Public queues with anonymous access aren't supported. 
- [Azure Service Bus pricing](https://azure.microsoft.com/pricing/details/service-bus/)d access signature (SAS) authentication, you can create a shared access authorization rule on a queue that can give users a write-only, read-only, or full access. For more information, see [Azure Storage - SAS authentication](../storage/common/storage-sas-overview.md) and [Azure Service Bus - SAS authentication](service-bus-sas.md).
ns in your code and risk potential security vulnerabilities. For more information, see [Azure Storage - Microsoft Entra authentication](../storage/queues/assign-azure-role-data-access.md) and [Azure Service Bus - Microsoft Entra authentication](service-bus-authentication-and-authorization.md#microsoft-entra-id). 
## Conclusion
By understanding the two technologies, you can make a more informed decision about which queue technology to use and when. The decision on when to use Storage queues or Service Bus queues depends on many factors. These factors depend heavily on the individual needs of your application and its architecture. 

You might prefer to choose Storage queues for reasons such as the following ones:

- Your application already uses the core capabilities of Microsoft Azure 
- You require basic communication and messaging between services | --- | --- | --- |
- You need queues that can be larger than 80 GB in size
| Free tier availability | Included in Azure free account | Limited free tier |
Service Bus queues provide many advanced features such as the following ones. So, they might be a preferred choice if you're building a hybrid application or if your application otherwise requires these features.| Generally lower | Higher, but includes advanced features |

- [Sessions](message-sessions.md)
- [Transactions](service-bus-transactions.md)etails/storage/queues/)
- [Duplicate detection](duplicate-detection.md)
- [Automatic dead-lettering](service-bus-dead-letter-queues.md)
- [Durable publish and subscribe capabilities](service-bus-queues-topics-subscriptions.md#topics-and-subscriptions) ## Performance considerations

haracteristics vary based on workload patterns and configuration:

## Next steps| Metric | Storage queues | Service Bus queues |
The following articles provide more guidance and information about using Storage queues or Service Bus queues.

* [Get started with Service Bus queues](service-bus-dotnet-get-started-with-queues.md)
* [How to Use the Queue Storage Service](/azure/storage/queues/storage-quickstart-queues-dotnet?tabs=passwordless%2Croles-azure-portal%2Cenvironment-variable-windows%2Csign-in-azure-cli)| Scalability | Scales with storage account limits | Scales with messaging units (Premium) or partitions (Standard) |
* [Best practices for performance improvements using Service Bus brokered messaging](service-bus-performance-improvements.md)ss) | AMQP (persistent connections) for better performance |



[Azure portal]: https://portal.azure.comFor optimal Service Bus performance, see [Best practices for performance improvements](service-bus-performance-improvements.md).

## Migration considerations

When migrating between queue technologies, consider the following:

| Consideration | Storage queues to Service Bus | Service Bus to Storage queues |
| --- | --- | --- |
| Message format | May need to update message serialization | Simplify message structure |
| Error handling | Implement dead-letter queue handling | Build custom poison message handling |
| Session support | Design session-based processing if needed | Remove session dependencies |
| Transactions | Leverage atomic operations | Implement compensating transactions |
| Authentication | Update to Service Bus SAS or Microsoft Entra ID | Update to Storage account keys or Microsoft Entra ID |

> [!TIP]
> When migrating, run both queue systems in parallel during a transition period to validate behavior before full cutover.

## Conclusion
By understanding the two technologies, you can make a more informed decision about which queue technology to use and when. The decision on when to use Storage queues or Service Bus queues depends on many factors. These factors depend heavily on the individual needs of your application and its architecture. 

You might prefer to choose Storage queues for reasons such as the following ones:

- Your application already uses the core capabilities of Microsoft Azure 
- You require basic communication and messaging between services 
- You need queues that can be larger than 80 GB in size

Service Bus queues provide many advanced features such as the following ones. So, they might be a preferred choice if you're building a hybrid application or if your application otherwise requires these features.

- [Sessions](message-sessions.md)
- [Transactions](service-bus-transactions.md)
- [Duplicate detection](duplicate-detection.md)
- [Automatic dead-lettering](service-bus-dead-letter-queues.md)
- [Durable publish and subscribe capabilities](service-bus-queues-topics-subscriptions.md#topics-and-subscriptions) 



## Next steps
The following articles provide more guidance and information about using Storage queues or Service Bus queues.

* [Get started with Service Bus queues](service-bus-dotnet-get-started-with-queues.md)
* [How to Use the Queue Storage Service](/azure/storage/queues/storage-quickstart-queues-dotnet?tabs=passwordless%2Croles-azure-portal%2Cenvironment-variable-windows%2Csign-in-azure-cli)
* [Best practices for performance improvements using Service Bus brokered messaging](service-bus-performance-improvements.md)

[Azure portal]: https://portal.azure.com
