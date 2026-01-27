---
title: Open Telemetry Walkthrough
description: Learn how to integrate OpenTelemetry (OTEL) support within Azure IoT Operations.
author: sethmanheim
ms.author: sethm
ms.reviewer: sethm
ms.date: 01/26/2026
ms.topic: how-to
---

# Open Telemetry walkthrough

Azure IoT Operations enables organizations to connect, monitor, and manage industrial assets using open standards like MQTT, OPC UA, and OTEL, while leveraging Azure Arc for deployment. Azure IoT Operations supports real-time data ingestion and processing at the edge, with seamless routing to Azure services such as Event Hub, Microsoft Fabric, and Azure Monitor.

Azure IoT Operations supports OpenTelemetry (OTEL) dataflow endpoints so you can export telemetry data to OTEL‑compatible observability backends. OTEL endpoints let you reuse existing telemetry streams and integrate with your monitoring pipeline without modifying devices or connectors. This article explains how OTEL dataflow endpoints appear, how to create them using supported authentication options, and where they can be used.

## Overview

Open Telemetry (OTEL) plays a critical role in AIO's observability stack. It enables consistent metrics, logs, and traces from edge workloads. OTEL collectors are deployed within Arc-enabled Kubernetes clusters to capture telemetry from industrial assets and services, which is then visualized using Azure Managed Grafana and monitored via Azure Monitor 5 6. This integration enhances site reliability engineering by providing deep visibility into system behavior, performance bottlenecks, and operational health. In Azure IoT Operations, OpenTelemetry helps you:

- Monitor the performance of your IoT applications.
- Trace requests across distributed systems.
- Collect and export telemetry data to your preferred observability platform.
- Troubleshoot issues in your IoT deployments.

This walkthrough covers the essential steps to configure OpenTelemetry in your Azure IoT Operations environment, from initial setup to data collection and visualization.

## Terminology

| Term                    | Definition                                                                                                                                                                         |
|-------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| DOE (Dataflow Endpoint) | A configurable endpoint in Azure IoT Operations dataflows that defines where telemetry is sent (source or destination), including protocol, authentication, and advanced settings. |
| OTEL                    | OpenTelemetry is a set of APIs, libraries, agents, and instrumentation to provide observability for applications.                                                                  |
| OTLP                    | The OpenTelemetry Protocol (OTLP) is the default protocol for sending telemetry data to an OpenTelemetry Collector.                                                                |
| OTEL Collector          | A proxy that can receive, process, and export telemetry data to one or more backends.                                                                                              |
| OTEL Exporter           | A component that sends observability data to a destination backend.                                                                                                                |

## Prerequisites

Before you begin, ensure you have:

- An Azure IoT Operations instance deployed and running.
- Administrative access to your Azure IoT Operations cluster.
- Basic familiarity with observability concepts.

## OpenTelemetry (OTEL) Dataflow Endpoints

OTEL dataflow endpoints are first‑class endpoints in Azure IoT Operations. They appear in the list of available dataflow endpoints and can be selected when configuring modern dataflow graphs. This makes it straightforward to route telemetry to OTEL‑compatible backends while keeping a consistent configuration experience.

:::image type="content" source="media/open-telemetry/dataflow-endpoints.png" alt-text="Screenshot of portal showing alternate endpoints screen." lightbox="media/open-telemetry/dataflow-endpoints.png":::

:::image type="content" source="media/open-telemetry/dataflow-endpoints-variation.png" alt-text=":::image type="content" source="media/open-telemetry/dataflow-endpoints-variation.png" alt-text="Screenshot of portal showing alternate endpoints screen.":::":::

## Create an OTEL dataflow endpoint

This section explains how you can create, configure, and use OpenTelemetry (OTEL) dataflow endpoints in Azure IoT Operations to export telemetry for monitoring and observability.

### Anonymous authentication

You can create an OTEL dataflow endpoint using anonymous authentication. This option requires only the host name and does not require credentials. Anonymous authentication is useful in scenarios where authentication is handled externally or is not required by the destination backend.

:::image type="content" source="media/open-telemetry/anonymous-authentication.png" alt-text="Screenshot of portal showing setting for anonymous authentication." lightbox="media/open-telemetry/anonymous-authentication.png":::

:::image type="content" source="media/open-telemetry/anonymous-authentication-variation.png" alt-text=":::image type="content" source="media/open-telemetry/anonymous-authentication-variation.png" alt-text="Screenshot of portal showing alternate setting for anonymous authentication.":::":::

### Service account token authentication

OTEL dataflow endpoints support service account token authentication, allowing services to authenticate using a pre‑issued token rather than user credentials. This option enables secure, non‑interactive access to telemetry pipelines and is commonly used for automated or service‑to‑service integrations.

:::image type="content" source="media/open-telemetry/service-account-token.png" alt-text="Screenshot of portal showing service account token." lightbox="media/open-telemetry/service-account-token.png":::

### X.509 certificate authentication

For enhanced security, OTEL dataflow endpoints can be created using X.509 certificate‑based authentication. This authentication method uses certificates and asymmetric key pairs to validate identity without exposing private keys. It is suitable for scenarios that require strong identity validation.

:::image type="content" source="media/open-telemetry/certificate-credentials.png" alt-text="Screenshot of portal showing x509 certificate setting." lightbox="media/open-telemetry/certificate-credentials.png":::

### Configure advanced settings for an OTEL endpoint

When you create an OTEL dataflow endpoint, you can configure advanced settings to tailor the endpoint configuration to your operational needs. Validation is applied to ensure values stay within supported limits.

:::image type="content" source="media/open-telemetry/advanced-settings.png" alt-text="Screenshot of portal showing advanced settings." lightbox="media/open-telemetry/advanced-settings.png":::

### Use OTEL endpoints in dataflow graphs

OTEL dataflow endpoints can be selected as destinations in modern dataflow graphs, allowing metrics and logs to be routed directly to OTEL‑compatible backends. OTEL endpoints are not available as destinations in classic dataflows. This restriction ensures compatibility with backends that do not support OTEL endpoints.

:::image type="content" source="media/open-telemetry/dataflow-graphs.png" alt-text="Screenshot of portal showing dataflow graphs." lightbox="media/open-telemetry/dataflow-graphs.png":::

