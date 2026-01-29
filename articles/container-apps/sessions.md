---
title: Dynamic sessions in Azure Container Apps
description: Learn about dynamic sessions in Azure Container Apps.
services: container-apps
author: craigshoemaker
ms.service: azure-container-apps
ms.topic: conceptual
ms.date: 04/07/2025
ms.author: cshoe
ms.custom: references_regions, ignite-2024
---

# Dynamic Sessions in Azure Container Apps

## Overview
Azure Container Apps dynamic sessions provide fast access to secure sandboxed environments that are ideal for running code or applications that require strong isolation from other workloads.

Dynamic sessions offer prewarmed environments through a [session pools](./session-pool.md) that starts the container in milliseconds, scales on demand, and maintains strong isolation. This makes them ideal for interactive workloads, running LLM generated scripts, and secure execution of custom code.


## Benefits
With sessions, you get:

- **Secure isolation**: Hyper-V isolation and optional network controls protect your environment. Sessions are isolated from each other and from the host environment, providing enterprise-grade security and isolation.  
- **Sandboxed environments**: Each session runs in its own isolated environment, ensuring that workloads don't interfere with each other.
- **Instant Startup**: Prewarmed pools enable subsecond launch times for interactive workloads. New sessions are allocated in milliseconds thanks to pools of ready but unallocated sessions.  
- **Scalable by Design**: Handle hundreds or thousands of concurrent sessions without manual intervention. 
- **Managed lifecycle**: Sessions are automatically deprovisioned after use or after a configurable cooldown period, ensuring efficient resource usage. 
- **Simple Access**: Sessions are accessed through a REST API with a unique identifier. If a session doesn’t exist, a new one is automatically allocated. 
- **API Access**: Sessions are exposed to your application via a single HTTP endpoint.

---

## Common Scenarios
Dynamic sessions are useful in a variety of situations, including:
- **AI/LLM Workflows**: Safely execute AI-generated code in isolated environments without risking your production systems.
- **Interactive Development**: Provide developers with fast, disposable environments for testing scripts or prototypes without provisioning full apps.
- **Secure Code Execution**: Run untrusted or user-submitted code in a sandboxed environment with strong isolation.
- **Custom Compute Tasks**: Execute short-lived jobs that require custom dependencies or runtime environments without long startup times.
- **Burst Workloads**: Handle unpredictable spikes in demand by scaling sessions up and down automatically.

---

## Key Concepts
- **Session Pool**  
  A session pool is the foundation for dynamic sessions. It contains a set of prewarmed, ready-to-use sessions that enable nearinstant startup. When a request comes in, the system allocates a session from the pool instead of creating one from scratch, which dramatically reduces latency.  

- **Session**  
  A session is the actual execution environment where your code or container runs. Sessions are ephemeral and isolated, designed for short-lived tasks. When you create a session, it's allocated from the session pool, ensuring fast startup. After the task completes or the cooldown period expires, the session is destroyed and resources are cleaned up.  

- **Session Lifecycle**  
Sessions follow a clear flow from creation to cleanup:

1. **Request Received**: Your application calls the REST API to create or retrieve a session using a unique identifier.
2. **Pending**: The system validates the request and checks for available resources.
3. **Unallocated**: A session exists but isn't yet assigned to a workload. If a prewarmed session is available in the pool, it moves quickly to allocation.
4. **Allocated**: The session becomes active and runs your code or container. This is the execution phase.
5. **Destroyed**: After the task completes or the cooldown period expires, the session is terminated and resources are cleaned up automatically.

This lifecycle ensures fast startup, efficient resource use, and automatic cleanup without manual intervention.

- **Session Types**  
  - **Code Interpreter Sessions**: These are platform built-in containers that provide preconfigured environments for running code, including AI-generated scripts. Ideal for scenarios like LLM-driven workflows or secure code execution.
  - **Custom Container Sessions**: Bring-your-own-container for custom workloads that require specific dependencies or runtime environments.

---

#### Session Types Comparison

| | **Code Interpreter Session** | **Custom Container Session** |
|---------------|------------------------------|------------------------------|
| **Best For** | Running AI‑generated code, user-submitted scripts, or quick secure code execution without managing a runtime environment. | Workloads requiring a custom runtime, libraries, binaries, or specialized tools not supported by built-in interpreters. |
| **Environment** | Preconfigured with common runtimes and tools; no container build or image publishing required. | Fully customizable container image with your own dependencies, packages, and configuration. |
| **When to Choose** | Choose this for simplicity, fastest startup, and minimal setup. | Choose this when you need full control over the execution environment or rely on custom dependencies. |
| **Ideal Use Cases** | LLM workflows, code interpretation, educational/sandbox scenarios, safe execution of user code. | Custom compute tasks, proprietary interpreters, specialized environments, or workloads with specific OS/library requirements. |
| **Image Requirement** | None—uses platform built‑in interpreter environments. | Required—supply your own container image URI. |

For more information, see [Usage](./sessions-usage.md).

---

## Supported Regions

Dynamic sessions are available in the following regions. Both code interpreter and custom container sessions are supported in all listed regions.

| Americas | Europe | Asia Pacific | Middle East & Africa |
|----------|--------|--------------|----------------------|
| Brazil South | France Central | Australia East | South Africa North |
| Canada Central | Germany West Central | Australia Southeast | UAE North |
| Canada East | Italy North | Central India | |
| Central US | North Europe | East Asia | |
| East US | Norway East | Japan East | |
| East US 2 | Poland Central | Japan West | |
| North Central US | Sweden Central | Korea Central | |
| West Central US | Switzerland North | South India | |
| West US | Switzerland West | Southeast Asia | |
| West US 2 | UK South | | |
| West US 3 | UK West | | |
| | West Europe | | |

---

## Security
Dynamic sessions are designed to run untrusted code in isolated environments. For information about securing your sessions, see [Security](./sessions-usage.md#security).

---

## Billing
Custom container sessions are billed based on the resources consumed by the session pool. For more information, see [Azure Container Apps billing](./billing.md#dynamic-sessions).

---

## Next Steps
- Learn how to configure [Session pools](./session-pool.md) 
- Learn how to use [Dynamic sessions](./sessions-usage.md)

