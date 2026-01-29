---
title: OpenTelemetry Configuration
description: Learn how to integrate OpenTelemetry (OTEL) support within Azure IoT Operations.
author: sethmanheim
ms.author: sethm
ms.reviewer: sethm
ms.date: 01/29/2026
ms.topic: how-to
---

# OpenTelemetry Configuration

Azure IoT Operations enables organizations to connect, monitor, and manage industrial assets using open standards like MQTT, OPC UA, and OTEL, while using Azure Arc for deployment. Azure IoT Operations supports real-time data ingestion and processing at the edge, with seamless routing to Azure services such as Event Hub, Microsoft Fabric, and Azure Monitor.

Azure IoT Operations now supports OpenTelemetry (OTEL) dataflow endpoints so you can export telemetry data to OTEL‑compatible observability backends. OTEL endpoints let you reuse existing telemetry streams and integrate with your monitoring pipeline without modifying devices or connectors. This article explains how OTEL dataflow endpoints appear, how to create them using supported authentication options, and where they can be used.

## Overview

OpenTelemetry plays a critical role in the Azure IoT Operations observability stack. It enables consistent metrics, logs, and traces from edge workloads. OTEL collectors are deployed within Arc-enabled Kubernetes clusters to capture telemetry from industrial assets and services, which is then visualized using Azure Managed Grafana and monitored via Azure Monitor 5 6. This integration enhances site reliability engineering by providing deep visibility into system behavior, performance bottlenecks, and operational health. In Azure IoT Operations, OpenTelemetry helps you:

- Monitor the performance of your IoT applications.
- Trace requests across distributed systems.
- Collect and export telemetry data to your preferred observability platform.
- Troubleshoot issues in your IoT deployments.

This configuration guide covers the essential steps to configure OpenTelemetry in your Azure IoT Operations environment, from initial setup to data collection and visualization.

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

The dataflow endpoint is a new endpoint in the list of available dataflow endpoints in the Azure IoT Operations experience. This addition ensures that you can easily identify and select the OTEL endpoint when configuring telemetry pipelines, promoting better integration and visibility across monitoring tools. By surfacing the OTEL endpoint along with other dataflow options, you can more efficiently route telemetry data and maintain consistent observability standards across assets.

:::image type="content" source="media/open-telemetry/dataflow-endpoints.png" alt-text="Screenshot showing endpoints screen." lightbox="media/open-telemetry/dataflow-endpoints.png":::

## Create an OTEL dataflow endpoint

This section explains how you can create, configure, and use OpenTelemetry dataflow endpoints in Azure IoT Operations to export telemetry for monitoring and observability.

### Anonymous authentication

You can create an OTEL dataflow endpoint using anonymous authentication. This option requires only the host name and does not require credentials. Anonymous authentication is useful in scenarios where authentication is handled externally or isn't required by the destination backend.

:::image type="content" source="media/open-telemetry/anonymous-authentication.png" alt-text="Screenshot showing setting for anonymous authentication." lightbox="media/open-telemetry/anonymous-authentication.png":::

### Service account token authentication

OTEL dataflow endpoints support service account token authentication, allowing services to authenticate using a pre‑issued token rather than user credentials. This option enables secure, non‑interactive access to telemetry pipelines and is commonly used for automated or service‑to‑service integrations.

:::image type="content" source="media/open-telemetry/service-account-token.png" alt-text="Screenshot showing service account token." lightbox="media/open-telemetry/service-account-token.png":::

### X.509 certificate authentication

For enhanced security, OTEL dataflow endpoints can be created using X.509 certificate‑based authentication. This authentication method uses certificates and asymmetric key pairs to validate identity without exposing private keys. Certificate‑based authentication is suitable for scenarios that require strong identity validation.

:::image type="content" source="media/open-telemetry/certificate-credentials.png" alt-text="Screenshot showing x509 certificate setting." lightbox="media/open-telemetry/certificate-credentials.png":::

### Configure advanced settings for an OTEL endpoint

When you create an OTEL dataflow endpoint, you can configure advanced settings to tailor the endpoint configuration to your operational needs. Validation is applied to ensure values stay within supported limits.

:::image type="content" source="media/open-telemetry/advanced-settings.png" alt-text="Screenshot showing advanced settings." lightbox="media/open-telemetry/advanced-settings.png":::

### Use OTEL endpoints in dataflow graphs

OTEL dataflow endpoints can be selected as destinations in modern dataflow graphs, allowing metrics and logs to be routed directly to OTEL‑compatible backends. OTEL endpoints aren't available as destinations in classic dataflows. This restriction ensures compatibility with backends that don't support OTEL endpoints.

:::image type="content" source="media/open-telemetry/dataflow-graphs.png" alt-text="Screenshot showing dataflow graphs." lightbox="media/open-telemetry/dataflow-graphs.png":::

:::image type="content" source="media/open-telemetry/dataflow-graphs-destination.png" alt-text="Screenshot showing endpoint destination properties.":::

## Walkthrough: Configure OTEL dataflow endpoint

This section provides a step‑by‑step walkthrough to create and configure an OTEL dataflow endpoint in Azure IoT Operations.

### Step 1: Create a new OTEL dataflow endpoint

When you create a new dataflow endpoint, select "OpenTelemetry (OTEL)" as the endpoint type, and make sure the host is prefixed with `http://`.

:::image type="content" source="media/open-telemetry/create-dataflow.png" alt-text="Screenshot showing configuration of new endpoint." lightbox="media/open-telemetry/create-dataflow.png":::

Follow the steps in [Deploy observability resources and set up logs](howto-configure-observability.md).

### Step 2: Create a dataflow graph using the OTEL endpoint

Create a dataflow with the asset as the source. Make sure the metric you want to send to OTEL is a datapoint in the asset. The following example uses a temperature value.
Select OTEL dataflow graph:

:::image type="content" source="media/open-telemetry/add-graph.png" alt-text="Screenshot of operations experience showing dataflow graph." lightbox="media/open-telemetry/add-graph.png":::

:::image type="content" source="media/open-telemetry/add-graph-2.png" alt-text="Screenshot of source node in graph." lightbox="media/open-telemetry/add-graph-2.png":::

### Step 3: Configure the OTEL endpoint as the destination

Select the source node and fill in the details. In this example, the temperature metric is selected as the datapoint to send to the OTEL endpoint.

:::image type="content" source="media/open-telemetry/endpoint-details.png" alt-text="Screenshot showing details screen." lightbox="media/open-telemetry/endpoint-details.png":::

Select **OTEL** as the destination and fill in the required details.

:::image type="content" source="media/open-telemetry/destination.png" alt-text="Screenshot showing otel as the destination." lightbox="media/open-telemetry/destination.png":::

:::image type="content" source="media/open-telemetry/destination-alternate.png" alt-text="Screenshot showing destination details." lightbox="media/open-telemetry/destination-alternate.png":::

