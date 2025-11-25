---
title: Azure App Configuration support for Agent Configuration
description: Introduction to Agent Configuration support using App Configuration
author: MaryanneNjeri
ms.author: mgichohi
ms.service: azure-app-configuration
ms.topic: concept-article
ms.date: 11/25/2025
ms.update-cycle: 180-days
ms.collection: ce-skilling-ai-copilot
---

# Agent configuration in Azure App Configuration

Agents are software systems that autonomously perform tasks using Large Language Models (LLMs) to process user input and execute actions on behalf of users. These agents use tools and Model Context Protocol (MCP) servers to carry out operations and generate intelligent responses. Agent configuration enables you to define and manage how these agents behave and respond within your application environment. Azure App Configuration provides a centralized store where configurations for your agent are kept in one place and can be shared across multiple application instances. Using Azure App Configuration allows you to update your agent's settings dynamically without redeploying or restarting your application and use feature flags to safely roll out new agent features or behaviors to targeted environments.

Here are some agent configurations that can be stored on Azure App Configuration:

 - Instructions
 - Endpoint
 - Agent name
 - Model parameters - temperature, top_p, max_tokens, frequency_penalty, presence_penalty, response_format and stop sequences.


## Example agent settings

1. Navigate to your App Configuration store and add the following key-values. Leave **Label** with its default value. For more information about how to add key-values to a store using the Azure portal or the CLI, go to [Create a key-value](./quickstart-azure-app-configuration-create.md#create-a-key-value).

    | Key                        | Value                                                               | Content type                                  |
    |----------------------------|---------------------------------------------------------------------|----------------------------------------------|
    | *Agent:ProjectEndpoint*    | *Paste the project endpoint*                                        |                                              |
    | *Agent:ModelDeploymentName*| *Paste the model deployment name*                                   |                                              |
    | *Agent:Instructions*       | *You're a helpful weather agent*                                    |                                              |
    | *Agent:WeatherTool*        | *{"name":"sunny", "message":"Don't forget sunscreen!"}*             |application/json                              |


1. Continue to the following instructions to implement the agent configuration into your application for the language or platform you're using.

    - [Python](./howto-agent-config-python.md)