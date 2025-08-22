---
title: Architecture for building advanced execution pipelines with policy fragments
titleSuffix: Azure API Management
description: Foundational patterns for designing modular, scalable policy fragment architectures with clear separation of concerns.
services: api-management
author: nicolela

ms.service: azure-api-management
ms.topic: concept-article
ms.date: 08/19/2025
ms.author: nicolela 
---

# Architecture for building advanced execution pipelines with policy fragments

**Applies to:** All Azure API Management tiers

Advanced pipeline scenarios often need custom logic and behavior applied throughout the request lifecycle. [Policy fragments](policy-fragments.md) provide the building blocks to create these pipelines while maintaining performance and reliability. Fragments enable sophisticated workflows through these capabilities:

- **Phases**: Custom logic and behavior can be distributed across inbound, backend, outbound, and error phases using fragments.
- **Sequential processing**: Fragments execute in a deterministic order with clear dependencies, enabling business logic to unfold step by step. Each fragment must complete before the next starts, with no parallel execution.
- **Scalable architecture**: Fragments provide efficient execution and caching to support enterprise-scale scenarios. 
- **Maintainable design**: Clear separation of concerns between fragments makes the system easier to understand and maintain.

## Recommended patterns

Follow these four key patterns to build policy fragment pipelines:

### 1. Modularity

Design each fragment with a single, well-defined responsibility. Each fragment should focus on one specific concern such as authenticatoin, logging, or rate limiting. For example, a fragment named `Security-Authentication` should only contain authentication logic.

### 2. Data sharing

Establish clear communication patterns between fragments.

- **Define communication**: To enable fragments to communicate without tight coupling, create input/output contracts through [context variables](api-management-policy-expressions.md#ContextVariables). Each request maintains its own isolated `context.Variables` dictionary, ensuring thread-safe communication between fragments. See [Variable Management for Policy Fragments](fragment-variable-mgmt.md) for details.

- **Cache common metadata**: Use a central metadata cache to store common data accessed across fragments. This approach reduces parsing overhead and improves performance. See [Central Metadata Cache for Policy Fragments](fragment-metadata-cache.md) for implementation guidance.

### 3. Policy coordination

To handle request processing effectively, coordinate fragments across [product and API policies](api-management-howto-policies.md#scopes).

- **Sequential execution**: Inject fragments in the order they need to execute, enabling workflows where later fragments depend on variables set by earlier fragments.

- **Policy division**: Divide fragments across product and API policies according to scope of custom logic.

- **Shared fragments**: To avoid duplication and maintain consistent behavior, include common fragments in both product and API policy levels.

For detailed guidance on coordinating fragments across policy scopes, see [Policy Injection and Coordination with Fragments](fragment-policy-coordination.md).

### 4. Performance optimization

Optimize fragments for maximum performance.

- **Keep fragments under 32 KB**: Stay within the [32 KB limit](policy-fragments.md) to ensure fast in-memory parsing and avoid slower file-based processing. The limit includes all whitespace, comments, and XML markup - not just the code logic. To stay under the limit:
  - Extract lengthy values, such as multi-line JSON, to [Named Values](api-management-howto-properties.md).
  - Use shorter variable names.
  - Split complex fragments into smaller, focused ones.

- **Apply recommended patterns**: Follow the modularity, data sharing, and coordination patterns outlined previously to ensure optimal fragment design and execution. Most importantly:
  - Implement a central metadata cache to eliminate redundant parsing.
  - Use early exit patterns for health checks, authentication failures, variable existence, and other scenarios where definitive responses can be determined without further processing.
  - Follow processing optimizations such as minimizing variable access.

For comprehensive implementation details, see the specialized guidance in the [Next Steps](#next-steps) section.

## Next steps

- **[Variable management for policy fragments](fragment-variable-mgmt.md)** - Comprehensive guidance on context variable handling, safe access patterns, and inter-fragment communication.
- **[Central metadata cache for policy fragments](fragment-metadata-cache.md)** - Implementation guidance for shared metadata caching patterns across fragments.
- **[Policy injection and coordination with fragments](fragment-policy-coordination.md)** - Fragment injection patterns and coordination between product and API policies.