---
title: Agent configuration
titleSuffix: Azure App Configuration
description: Learn how to store agent configuration in Azure App Configuration.
ms.service: azure-app-configuration
author: MaryanneNjeri
ms.author: mgichohi
ms.topic: how-to
ms.date: 11/10/2025
ms.update-cycle: 180-days
ms.collection: ce-skilling-ai-copilot
---

# Use agent configuration in a Python console app

## Prerequisites

- An Azure account with an active subscription. [Create one for free](https://azure.microsoft.com/free).
- An App Configuration store, as shown in the [tutorial for creating a store](./quickstart-azure-app-configuration-create.md#create-an-app-configuration-store).
- Python 3.8 or later - for information on setting up Python on Windows, see the [Python on Windows documentation](/windows/python/).
- Create the _example agent settings_ discussed in the [overview](./concept-agent-configuration.md#example-agent-settings)
- A model. [Add and configure models to Azure AI Foundry Models](/azure/ai-foundry/foundry-models/how-to/create-model-deployments).

## Console application

In this section, you create a console application and load your agent configurations from your App Configuration store. This console app builds on the [Azure AI Agent basic sample](https://github.com/microsoft/agent-framework/blob/main/python/samples/getting_started/agents/azure_ai_agent/azure_ai_basic.py). By storing your agent configuration in App Configuration, you can update your agent's behavior in real-time without redeploying or restarting your application.

1. Create a new folder for your project. In the new folder, install the following packages by using the `pip install` command:

    ```console
    pip install azure-appconfiguration-provider
    pip install agent-framework --pre
    pip install azure-identity
    ```

1. Create a new file called _app.py_, and add the following import statements:

    ```python
    import asyncio
    from agent_framework_azure_ai import AzureAIAgentClient
    from azure.identity import DefaultAzureCredential
    from azure.identity.aio import AzureCliCredential
    from azure.appconfiguration.provider import (load, SettingSelector, WatchKey)
    from typing import Annotated
    from pydantic import Field
    from random import randint
    import os
    ```

1. You can connect to App Configuration using either Microsoft Entra ID (recommended) or a connection string. In this example, you use Microsoft Entra ID with `DefaultAzureCredential` to authenticate to your App Configuration store. Follow these [instructions](./concept-enable-rbac.md#authentication-with-token-credentials) to assign the **App Configuration Data Reader** role to the identity represented by `DefaultAzureCredential`. Be sure to allow sufficient time for the permission to propagate before running your application.

    ```python
    endpoint = os.environ["AZURE_APPCONFIGURATION_ENDPOINT"]

    # Connect to Azure App Configuration using Microsoft Entra ID.
    credential = DefaultAzureCredential()

    # Use the default refresh interval of 30 seconds. It can be overridden via refresh_interval
    config = load(endpoint=endpoint, credential=credential, selects=[SettingSelector(key_filter="Agent:*")], refresh_on=[WatchKey("Agent:WeatherTool")])
    ```

1. Initialize the agent:

    ```python
    async def main() -> None:
        async with (
            AzureAIAgentClient(
                project_endpoint=config["Agent:ProjectEndpoint"], 
                model_deployment_name=config["Agent:ModelDeploymentName"],
                async_credential=AzureCliCredential()).create_agent(
                    instructions=config["Agent:Instructions"],
                    store=True
                ) as agent
        ):
    
            while True:
                user_input = input("How can I help? (type 'quit' to exit): ")
                
                if user_input.lower() in ['quit', 'exit', 'bye']:
                    break

                print(f"User: {user_input}")

                response = await agent.run(messages=user_input, tools=get_weather)

                print(f"Agent: {response.text}\n")
                input("Press Enter to continue...")
                
            print("Exiting.. Goodbye.")

    if __name__ == "__main__":
        asyncio.run(main())
    ```

1. Define the `get_weather` tool function:
    ```python
    def get_weather(
            location: Annotated[str, Field(description="The location to get the weather for.")]
    ) -> str:
        """Get the weather for a given location."""

        # Refresh the configuration from Azure App Configuration 
        config.refresh()

        condition = config["Agent:WeatherTool"]
        
        return f"The weather in {location} is {condition["name"]} with a high of {randint(10, 30)}°C. {condition["message"]}"
    ```

1. After completing the previous steps, your _app.py_ file should now contain the complete implementation as shown below:
    ```python
    import asyncio
    from agent_framework_azure_ai import AzureAIAgentClient
    from azure.identity import DefaultAzureCredential
    from azure.identity.aio import AzureCliCredential
    from azure.appconfiguration.provider import (load, SettingSelector, WatchKey)
    from typing import Annotated
    from pydantic import Field
    from random import randint
    import os

    endpoint = os.environ["AZURE_APPCONFIGURATION_ENDPOINT"]

    # Connect to Azure App Configuration using Microsoft Entra ID.
    credential = DefaultAzureCredential()

    # Use the default refresh interval of 30 seconds. It can be overridden via refresh_interval
    config = load(endpoint=endpoint, credential=credential, selects=[SettingSelector(key_filter="Agent:*")], refresh_on=[WatchKey("Agent:WeatherTool")])

    def get_weather(
            location: Annotated[str, Field(description="The location to get the weather for.")]
    ) -> str:
        """Get the weather for a given location."""

        # Refresh the configuration from Azure App Configuration 
        config.refresh()

        condition = config["Agent:WeatherTool"]
        
        return f"The weather in {location} is {condition["name"]} with a high of {randint(10, 30)}°C. {condition["message"]}"
        
    async def main() -> None:
        async with (
            AzureAIAgentClient(
                project_endpoint=config["Agent:ProjectEndpoint"], 
                model_deployment_name=config["Agent:ModelDeploymentName"],
                async_credential=AzureCliCredential()).create_agent(
                    instructions=config["Agent:Instructions"],
                    store=True) as agent
        ):
        
            while True:
                user_input = input("How can I help? (type 'quit' to exit): ")
                
                if user_input.lower() in ['quit', 'exit', 'bye']:
                    break

                print(f"User: {user_input}")
                response = await agent.run(messages=user_input, tools=get_weather)
                print(f"Agent: {response.text}\n")
                input("Press Enter to continue...")
                
            print("Exiting.. Goodbye.")

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
    $Env:AZURE_APPCONFIGURATION_ENDPOINT="<endpoint-of-your-app-configuration-store>"
    ```

    If you use macOS or Linux run the following command:
    ```bash
    export AZURE_APPCONFIGURATION_ENDPOINT='<endpoint-of-your-app-configuration-store>'
    ```

1. After the environment variable is properly set, run the following command to run the app locally:

    ```console
    python app.py
    ```

1. Type the message "What is the weather in Seattle?" when prompted with "How can I help?" and then press the Enter key.

    ```Output
    How can I help? (type 'quit' to exit): What is the weather in Seattle?
    User: What is the weather in Seattle?
    Agent: The weather in Seattle is currently sunny with a high of 17°C. It's a great day to be outside—don't forget sunscreen!

    Press Enter to continue...
    ```

1. In the Azure portal, select the App Configuration store instance that you created. From the **Operations** menu, select **Configuration explorer**, and update the **Agent:WeatherTool** value to:

    | Key                        | Value                                                                                                         |
    |----------------------------|---------------------------------------------------------------------------------------------------------------|
    | *Agent:WeatherTool*        | {"name": "stormy", "message":"Warning: Stay indoors!"}                                                        |

1.  Press the Enter key and type the same message when prompted with "How can I help?". Be sure to wait a few moments for the refresh interval to elapse, and then press the Enter key to see the updated AI response in the output.

    ```Output
    How can I help? (type 'quit' to exit): What is the weather in Seattle?
    User: What is the weather in Seattle?
    Agent: The weather in Seattle is currently sunny with a high of 17°C. It's a great day to be outside—don't forget sunscreen!

    Press Enter to continue...
    How can I help? (type 'quit' to exit): What is the weather in Seattle?
    User: What is the weather in Seattle?
    Agent: The weather in Seattle is currently stormy with a high of 29°C. There is a warning to stay indoors due to the stormy conditions.

    Press Enter to continue...
    ```

## Next steps

To learn how to use Chat completion configuration in your application, continue to this tutorial.

> [!div class="nextstepaction"]
> [Chat completion configuration](./howto-chat-completion-config.md)