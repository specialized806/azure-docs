---
title: Agent configuration
titleSuffix: Azure App Configuration
description: Learn how to store agent configuration in Azure App Configuration.
ms.service: azure-app-configuration
author: MaryanneNjeri
ms.author: mgichohi
ms.topic: how-to
ms.date: 10/27/2025
ms.update-cycle: 180-days
ms.collection: ce-skilling-ai-copilot
---

# Agent configuration in Azure App Configuration

Agents are software systems that autonomously perform tasks using Large Language Models (LLMs) to process user input and execute actions on behalf of users. These agents leverage tools and Model Context Protocol (MCP) servers to carry out operations and generate intelligent responses. Agent configuration enables you to define and manage how these agents behave and respond within your application environment.

## Prerequisites

- An Azure account with an active subscription. [Create one for free](https://azure.microsoft.com/free)
- An App Configuration store, as shown in the [tutorial for creating a store](./quickstart-azure-app-configuration-create.md#create-an-app-configuration-store).
- Python 3.8 or later - for information on setting up Python on Windows, see the [Python on Windows documentation](/windows/python/)
- An Azure AI project. [Create a project for Azure AI Foundry](/azure/ai-foundry/how-to/create-projects)

## Add a model 
<!-- TODO: Add content on how to deploy a model and connect Grounding with Bing Search resource -->

## Add key-values

You successfully deployed a model and connected Grounding with Bing Search resource to your Azure AI project in the previous section.

1. Navigate to your App Configuration store and add the following key-values. Leave **Label** and **Content Type** with their default values. For more information about how to add key-values to a store using the Azure portal or the CLI, go to [Create a key-value](./quickstart-azure-app-configuration-create.md#create-a-key-value).

| Key                        | Value                                                              |
|----------------------------|--------------------------------------------------------------------|
| *Agent:Endpoint*          | *Paste the resource endpoint you copied in the previous step*      |
| *Agent:DeploymentName*    | *Paste the model deployment name you copied in the previous step*  |
| *Agent:Instructions*      | *"You are a helpful assistant"*                                      |

1.  Add a feature flag called _Beta_ to the App Configuration store and leave **Label** and **Description** with their default values. For more information about how to add feature flags to a store using the Azure portal or the CLI, go to [Create a feature flag](./manage-feature-flags.md#create-a-feature-flag).

> [!div class="mx-imgBorder"]
> ![Screenshot of enable feature flag named Beta.](media/add-beta-feature-flag.png)

## Console application

In this section, you will create a console application that builds on the [Azure AI Agent sample app](https://github.com/microsoft/agent-framework/blob/main/python/samples/getting_started/agents/azure_ai/azure_ai_with_bing_grounding.py)

1. Create a new forlder for your project. In the new folder, install the following packages by using the `pip install` command:

    ```console
    pip install azure-appconfiguration-provider
    pip install featuremanagement
    pip install agent-framework --pre
    pip install azure-identity
    ```

1. Create a new file called _app.py_, and add the following import statements:

    ```console
    import asyncio
    from typing import Annotated
    from pydantic import Field
    from agent_framework import ChatAgent, HostedWebSearchTool
    from agent_framework_azure_ai import AzureAIAgentClient
    from azure.identity import DefaultAzureCredential
    from azure.identity.aio import AzureCliCredential
    from azure.appconfiguration.provider import (load, SettingSelector)
    from featuremanagement import FeatureManager
    import os
    ```

1. You can connect to App Configuration using either Microsoft Entra ID (recommended) or a connection string. In this example, you can use Microsoft Entra ID with `DefaultAzureCredential` to authenticate to your App Configuration store. Follow these instructions to assing the **App Configuration Deata Reader** role to the identity represented by `DefaultAzureCredential`. Be sure to allow sufficient time for the permission to propagate before running the application.

    ```python
    endpoint = os.environ["APP_CONFIGURATION_ENDPOINT"]

    # Connect to Azure App Configuration using Microsoft Entra ID.
    credential = DefaultAzureCredential()

    # Use the default refresh interval of 30seconds. It can be overrriden via refresh_interval
    config = load(endpoint=endpoint, credential=credential, selects={SettingSelector(key_filter="Agent:*")}, feature_flag_enabled=True, feature_flag_refresh_enabled=True)
    feature_manager = FeatureManager(config)
    ```

1. Create an agent using `ChatAgent` with `AzureAIAgentClient`:

    ```python
    async def main()-> None:
        async with (
            AzureAIAgentClient(model_deployment_name=config["Agent:DeploymentName"], project_endpoint=config["Agent:Endpoint"], async_credential=AzureCliCredential()) as client,
            ChatAgent(
                chat_client=client,
                instructions=config["Agent:Instructions"],
                store=True
            ) as agent,
        ):
            print("=== Azure AI Agent with Bing Grounding Search ===\n")
    if __name__ == "__main__":
        asyncio.run(main())
    ```

1. Update _app.py_ file to add a function tool `get_weather` and a helper method `get_tools` to :

    ```python
    def get_weather(
        location: Annotated[str, Field(description="The location to get the weather for")]
    ) -> str:

        return f"The weather in {location} is sunny."
    
    def get_tools():
        config.refresh()

        if feature_manager.is_enabled("Beta"):
            return HostedWebSearchTool()
        else:
            return get_weather

    ```

1. Next, update the existing code in _app.py_ to refresh configuration from Azure App Configuration:

    ```python
    async def main()-> None:
        async with (
            AzureAIAgentClient(model_deployment_name=config["Agent:DeploymentName"], project_endpoint=config["Agent:Endpoint"], async_credential=AzureCliCredential()) as client,
            ChatAgent(
                chat_client=client,
                instructions=config["Agent:Instructions"],
                store=True
            ) as agent,
        ):
            print("=== Azure AI Agent with Bing Grounding Search ===\n")
            
            while True:
                user_input = input("How can I help? (type 'quit' to exit): ")
                
                # Clear/check for exit condition
                if user_input.lower() in ['quit', 'exit', 'bye']:
                    break
                    
                print(f"User: {user_input}")
                response = await agent.run(messages=user_input, tools=get_tools())
                print(f"Agent:{response.text}\n")
                input("Press enter to continue...")  # User must press Enter to continue
                
            print("Exiting.. Goodbye...")
    ```

1. After completing the previous steps, your _app.py_ file should now contain the complete implementation as shown below:
    ```python
    import asyncio
    from typing import Annotated
    from pydantic import Field
    from agent_framework import ChatAgent, HostedWebSearchTool
    from agent_framework_azure_ai import AzureAIAgentClient
    from azure.identity import DefaultAzureCredential
    from azure.identity.aio import AzureCliCredential
    from azure.appconfiguration.provider import (load, SettingSelector)
    from featuremanagement import FeatureManager
    import os

    endpoint = os.environ["APP_CONFIGURATION_ENDPOINT"]

    # Connect to Azure App Configuration using Microsoft Entra ID.
    credential = DefaultAzureCredential()

    # Use the default refresh interval of 30seconds. It can be overrriden via refresh_interval
    config = load(endpoint=endpoint, credential=credential, selects={SettingSelector(key_filter="Agent:*")}, feature_flag_enabled=True, feature_flag_refresh_enabled=True)
    feature_manager = FeatureManager(config)

    def get_weather(
        location: Annotated[str, Field(description="The location to get the weather for")]
    ) -> str:

        return f"The weather in {location} is sunny."

    def get_tools():
        config.refresh()

        if feature_manager.is_enabled("Beta"):
            return HostedWebSearchTool()
        else:
            return get_weather

    async def main()-> None:
        async with (
            AzureAIAgentClient(model_deployment_name=config["Agent:DeploymentName"], project_endpoint=config["Agent:Endpoint"], async_credential=AzureCliCredential()) as client,
            ChatAgent(
                chat_client=client,
                instructions=config["Agent:Instructions"],
                store=True
            ) as agent,
        ):
            print("=== Azure AI Agent with Bing Grounding Search ===\n")
            
            while True:
                user_input = input("How can I help? (type 'quit' to exit): ")
                
                # Clear/check for exit condition
                if user_input.lower() in ['quit', 'exit', 'bye']:
                    break
                    
                print(f"User: {user_input}")
                response = await agent.run(messages=user_input, tools=get_tools())
                print(f"Agent:{response.text}\n")
                input("Press enter to continue...")  # User must press Enter to continue
                
            print("Exiting.. Goodbye...")

    if __name__ == "__main__":
        asyncio.run(main())
    ```

## Build and run the app

1. Set the environment variable named **AZURE_APPCONFIGURATION_ENDPOINT** to the endpoint of your App Configuration store found under the *Overview* of your store in the Azure portal.

    If you use the Windows command prompt, run the following command and restart the command prompt to allow the change to take effect:

    ```cmd
    setx AZURE_APPCONFIGURATION_ENDPOINT "<endpoint-of-your-app-configuration-store>"
    ```

    If you use PowerShell, run the following command:
    ```powershell
    $Env:AZURE_APPCONFIGURATION_ENDPOINT = "<endpoint-of-your-app-configuration-store>"
    ```

    If you use macOS or Linux run the following command:
    ```bash
    export AZURE_APPCONFIGURATION_ENDPOINT ='<endpoint-of-your-app-configuration-store>'
    ```

1. After the envrionment variable is properly set, run the following command to run the app locally:

    ```python
    python app.py
    ```

1. Type the message "What is the weather in Seattle today?" when prompted with "How can I help?" and then press the Enter key.

    ```Output
    How can I help? (type 'quit' to exit): What is the weather in Seattle today ?
    User: What is the weather in Seattle today ?
    Agent:The weather in Seattle today is sunny.

    Press enter to continue...
    ```

1.  In Azure portal, select the App Configuration store instance that you created. From the **Operations** menu, select **Feature Manager**, and change the state of the **Beat** feature flag to **On**, using the toggle in the **Enabled** column.

    | Key | State |
    |---|---|
    | Beta | On |

1. Press enter and type the same message when prompted with "How can I help?". Be sure to wait a few moments for the refresh interval to elapse, and then press the Enter key to see the updated AI response in the output.

    ```Output
    === Azure AI Agent with Bing Grounding Search ===

    How can I help? (type 'quit' to exit): What is the weather in Seattle today ?
    User: What is the weather in Seattle today ?
    Agent:The weather in Seattle today is sunny.

    Press enter to continue...
    How can I help? (type 'quit' to exit): What is the weather in Seattle today ?
    User: What is the weather in Seattle today ?
    Agent:Today's weather in Seattle will feature a mix of clouds and sun, with a high of around 60°F and tonight will be mainly clear with a low near 45°F. Winds will be light, and there's no significant chance of rain today. The air quality is fair, suitable for most people to be outdoors. Get ready for heavier rain starting Friday morning and continuing into Saturday morning, so enjoy the pleasant weather while it lasts!【3:0†source】.

    Press enter to continue...
    ```