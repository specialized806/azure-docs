---
title: Traffic Analytics with Microsoft Sentinel
description: Discover how Azure Traffic Analytics enriches flow logs with threat intelligence and geolocation to detect anomalies and assess network exposure.
author: halkazwini
ms.author: halkazwini
ms.service: azure-network-watcher
ms.topic: concept-article
ms.date: 03/17/2026

#customer intent: As a security analyst, I want to detect anomalies in network traffic so that I can assess potential risks and respond to unusual behavior.
---

# Traffic Analytics with Microsoft Sentinel

Traffic Analytics in Azure Network Watcher processes and aggregates Virtual Network Flow Logs to provide visibility into network flows, traffic patterns, and potential security risks. It enriches flow data with threat intelligence, geolocation attributes, and topology context to help identify anomalies and evaluate exposure across your environment.

Traffic Analytics also supports integration with Microsoft Sentinel. Microsoft Sentinel is a scalable, cloud-native Security Information and Event Management (SIEM) solution that provides cost-efficient security monitoring across multicloud and multiplatform environments. Sentinel uses [ASIM-based parsers](/azure/sentinel/normalization-about-schemas) to normalize incoming data, allowing Traffic Analytics flow data to be transformed into the required schema for correlation, investigation, and threat detection.

Together, Traffic Analytics and Microsoft Sentinel enable both proactive monitoring and reactive investigation. Flow-level telemetry highlights unexpected communication paths, unusual traffic volumes, and indicators of compromise, allowing you to detect deviations from baseline behavior and investigate events with reliable and structured insights.

# Prerequisites

- An Azure account with an active subscription.

- Traffic Analytics is enabled and sending data to a Log Analytics workspace

- You have **Contributor** or **Security Admin** access on the workspace

- **Microsoft Sentinel Contributor** to enable rules in Sentinel

# Key Capabilities

- Monitor and visualize network traffic:  
  Provides insights into flow patterns, protocol usage, top talkers, and communication paths using aggregated Virtual Network Flow Logs.

- Detect anomalies and assess potential risks:  
  Identifies unusual traffic behaviour by enriching flow data with threat intelligence, geolocation, and topology information.

- Correlate flow data across security tools:  
  Supports integration with Microsoft Sentinel through ASIM-based parsers, enabling normalized flow data for advanced detection and investigation.

- Simplify operational visibility:  
  Helps you evaluate baseline traffic, highlight deviations, and understand network exposure with minimal configuration effort.

# Integrating Microsoft Sentinel with Traffic Analytics

You can easily integrate Microsoft Sentinel with Traffic Analytics directly from the Azure portal.

## Step 1: Enable Microsoft Sentinel on the workspace

Start by enabling Microsoft Sentinel on the same Log Analytics workspace used by Traffic Analytics. This allows Sentinel to access and analyze Traffic Analytics data without requiring additional configuration or data movement.

- In the Azure portal, search for **Microsoft Sentinel**.

- Select **Create**, then choose the Log Analytics workspace used by Traffic Analytics.

- Select **Add** to enable Microsoft Sentinel on the workspace.

:::image type="content" source="media/traffic-analytics-sentinel/image1.png" alt-text="A screenshot of a computer AI-generated content may be incorrect.":::

## Step 2 : Install Network analytics content

Next, install the required network solution from the Microsoft Sentinel Content hub. This provides prebuilt workbooks, analytics rules, and hunting queries designed to analyze normalized network traffic data.

- In Microsoft Sentinel, go to **Content hub**.

- Search for **Network Session Essentials**.

- Select the solution and choose **Install with dependencies**.

:::image type="content" source="media/traffic-analytics-sentinel/image2.png" alt-text="A screenshot of a computer AI-generated content may be incorrect.":::

## Step 3 : Enable analytics rules

Finally, enable the relevant network analytics rules to start generating security alerts and incidents. These rules continuously evaluate Traffic Analytics data to detect suspicious or anomalous network behaviour.

- After installing the solution, return to **Content hub** under **Content management**.

- Filter by **Content type: Analytics rule**, then search for **Network** to view all available network-related detection rules that can be enabled in your workspace.

<!-- -->

- To enable an analytics rule, select the rule from the list and then select **Create rule**. This creates the rule in your workspace and starts generating alerts based on matching network activity. This opens the **Analytics rule wizard**

:::image type="content" source="media/traffic-analytics-sentinel/image3.png" alt-text="":::

- In the wizard, review the default rule configuration, including query logic, scheduling frequency, and lookback period. Adjust these settings if required.

:::image type="content" source="media/traffic-analytics-sentinel/image4.png" alt-text="A screenshot of a computer AI-generated content may be incorrect.":::

- Configure incident settings to control how alerts are grouped into incidents.

- Select **Review + create**, then save the rule to enable it.

Once enabled, the rule runs automatically on Traffic Analytics data and generates alerts and incidents when matching network activity is detected.

# Detect threats and use AI-assisted investigation capabilities

Microsoft Sentinel uses analytics rules and built-in intelligence to analyze Traffic Analytics data and detect suspicious or malicious network activity. Sentinel evaluates normalized network flow data to identify common threat patterns such as reconnaissance, lateral movement, abnormal traffic spikes, and communication with unexpected or high-risk endpoints.

Sentinel correlates Traffic Analytics signals with other data sources and threat intelligence to provide high-fidelity detections. By combining network traffic context with MITRE ATT&CK techniques, geolocation, and behavioural analysis, Sentinel reduces alert fatigue and surfaces actionable incidents for security teams.

When an incident is generated, Microsoft Sentinel provides AI-assisted investigation experiences that help analysts understand the scope and impact of the activity. Incidents are enriched with entities such as IP addresses, ports, protocols, and network locations derived from Traffic Analytics. Investigation graphs and timelines highlight relationships between network entities and related events.

By integrating Traffic Analytics with Microsoft Sentinel, you enable end-to-end network threat detection and investigation, combining large-scale network visibility with intelligent correlation and automated insights to accelerate response.

| **Detection rule** | **What does it do?** | **What does it indicate?** |
|----|----|----|
| Port scan | Identifies a source IP attempting to connect to multiple destination ports across one or more virtual networks based on Traffic Analytics flow data. | Malicious reconnaissance activity where an attacker is probing for open ports that can be exploited for initial access. |
| Port sweep | Identifies a source IP scanning the same destination port across multiple destination IPs using network flow logs. | Targeted scanning for specific vulnerable services exposed on multiple hosts within the environment. |
| Anomalous connection rate | Identifies an abnormal spike in allowed or denied connections between a source and destination based on behavioral baselines. | Potential brute force attempts, data exfiltration, or command-and-control activity deviating from normal traffic behavior. |
| Abnormal port-to-protocol usage | Identifies traffic where a well-known protocol is observed over a non-standard port using flow characteristics and behavioral analysis. | Malicious command-and-control or data exfiltration activity attempting to evade detection by disguising traffic patterns. |
| Geographic anomaly in traffic | Identifies network traffic originating from or communicating with unusual or previously unseen geographic locations. | Possible compromised workloads or unauthorized external communication from high-risk or unexpected regions. |
| Excessive failed connections | Identifies repeated failed connection attempts to specific destinations or ports over a defined time window. | Identifies repeated failed connection attempts to specific destinations or ports over a defined time window. |
| Suspicious inbound or outbound traffic volume | Identifies unusually large volumes of inbound or outbound traffic compared to historical baselines. | Potential data exfiltration, lateral movement, or denial-of-service–related activity within the network. |
