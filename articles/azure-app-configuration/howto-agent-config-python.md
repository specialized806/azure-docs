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

# Agent configuration in Azure App Configuration

Agents are software systems that autonomously perform tasks using Large Language Models (LLMs) to process user input and execute actions on behalf of users. These agents leverage tools and Model Context Protocol (MCP) servers to carry out operations and generate intelligent responses. Agent configuration enables you to define and manage how these agents behave and respond within your application environment. Storing agent configurations in Azure App Configuration provides a centralized store where configurations for your agent are kept in one place and can be consumed by multiple application instances. App Configuration lets you update your agent's settings dynamically without redeploying or restarting your application, and use feature flags to safely roll out new agent features or behaviors to targeted environments.

Here are some agent configurations that can be stored on Azure App Configuration:

 - Model deployment name
 - Instructions
 - Endpoint
 - Agent name
 - Model parameters - temperature, top_p, max_tokens, frequency_penalty, presence_penalty, response_format and stop sequences.

## Prerequisites

- An Azure account with an active subscription. [Create one for free](https://azure.microsoft.com/free).
- An App Configuration store, as shown in the [tutorial for creating a store](./quickstart-azure-app-configuration-create.md#create-an-app-configuration-store).
- Python 3.8 or later - for information on setting up Python on Windows, see the [Python on Windows documentation](/windows/python/).
- A model. [Add and configure models to Azure AI Foundry Models](/azure/ai-foundry/foundry-models/how-to/create-model-deployments).

## Add key-values

1. Navigate to your App Configuration store and add the following key-values. Leave **Label** and **Content Type** with their default values. For more information about how to add key-values to a store using the Azure portal or the CLI, go to [Create a key-value](./quickstart-azure-app-configuration-create.md#create-a-key-value).

| Key                              | Value                                                               |
|----------------------------------|---------------------------------------------------------------------|
| *Agent:ProjectEndpoint*          | *Paste the project endpoint*                                        |
| *Agent:ModelDeploymentName*      | *Paste the model deployment name*                                  |
| *Agent:Instructions*             | *"You are a helpful assistant"*                                     |

## Console application

In this section, you will create a console application and load your agent configurations from your App Configuration store.

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
    import os
    ```

1. You can connect to App Configuration using either Microsoft Entra ID (recommended) or a connection string. In this example, you can use Microsoft Entra ID with `DefaultAzureCredential` to authenticate to your App Configuration store. Follow these instructions to assign the **App Configuration Data Reader** role to the identity represented by `DefaultAzureCredential`. Be sure to allow sufficient time for the permission to propagate before running the application.

    ```python
    endpoint = os.environ["AZURE_APPCONFIGURATION_ENDPOINT"]

    # Connect to Azure App Configuration using Microsoft Entra ID.
    credential = DefaultAzureCredential()

    # Use the default refresh interval of 30 seconds. It can be overridden via refresh_interval
    config = load(endpoint=endpoint, credential=credential, selects=[SettingSelector(key_filter="Agent:*")], feature_flag_enabled=True, feature_flag_refresh_enabled=True)
    ```

1. Create the agent:

    ```python
    async def main()-> None:
        async with (
            AzureAIAgentClient(project_endpoint=config["Agent:ProjectEndpoint"], model_deployment_name=config["Agent:ModelDeploymentName"] ,async_credential=AzureCliCredential()).create_agent() as agent
        ):
    
            while True:
                # Refresh the configuration from Azure App Configuration
                config.refresh()

                user_input = input("How can I help? (type 'quit' to exit): ")
                
                if user_input.lower() in ['quit', 'exit', 'bye']:
                    break

                print(f"User: {user_input}")

                response = await agent.run(messages=user_input, additional_chat_options={"instructions": config["Agent:Instructions"]})

                print(f"Agent: {response.text}\n")
                input("Press Enter to continue...")
                
            print("Exiting.. Goodbye.")

    if __name__ == "__main__":
        asyncio.run(main())
    ```

1. After completing the previous steps, your _app.py_ file should now contain the complete implementation as shown below:
    ```python
    import asyncio
    from agent_framework_azure_ai import AzureAIAgentClient
    from azure.identity import DefaultAzureCredential
    from azure.identity.aio import AzureCliCredential
    from azure.appconfiguration.provider import (load, SettingSelector, WatchKey)
    import os

    endpoint = os.environ["AZURE_APPCONFIGURATION_ENDPOINT"]

    # Connect to Azure App Configuration using Microsoft Entra ID.
    credential = DefaultAzureCredential()

    # Use the default refresh interval of 30 seconds. It can be overridden via refresh_interval
    config = load(endpoint=endpoint, credential=credential, selects=[SettingSelector(key_filter="Agent:*")], refresh_on=[WatchKey("Agent:Instructions")])

    async def main()-> None:
        async with (
            AzureAIAgentClient(project_endpoint=config["Agent:ProjectEndpoint"], model_deployment_name=config["Agent:ModelDeploymentName"] ,async_credential=AzureCliCredential()).create_agent() as agent
        ):
        
            while True:
                # Refresh the configuration from Azure App Configuration
                config.refresh()

                user_input = input("How can I help? (type 'quit' to exit): ")
                
                if user_input.lower() in ['quit', 'exit', 'bye']:
                    break

                print(f"User: {user_input}")
                response = await agent.run(messages=user_input, additional_chat_options={"instructions": config["Agent:Instructions"]})
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

1. Type the message "What is your name?" when prompted with "How can I help?" and then press the Enter key.

    ```Output
    How can I help? (type 'quit' to exit): What is your name?
    User: What is your name?
    Agent: I'm called ChatGPT! I'm an AI assistant created by OpenAI. How can I help you today?
    ```

1. In Azure portal, select the App Configuration store instance that you created. From the **Operations** menu, select **Configuration explorer**, and update the **Agent:Instructions** value to "You are French and your name is Jon Pierre."

1. Press the Enter key and type the same message when prompted with "How can I help?". Be sure to wait a few moments for the refresh interval to elapse, and then press the Enter key to see the updated AI response in the output.

    ```Output
    How can I help? (type 'quit' to exit): What is your name?
    User: What is your name?
    Agent: I'm called ChatGPT! I'm an AI assistant created by OpenAI. How can I help you today?

    Press Enter to continue...
    How can I help? (type 'quit' to exit): What is your name?
    User: What is your name?
    Agent: Bonjour ! Mon nom est Jon Pierre. Comment puis-je vous aider aujourd'hui?
    ```


## Next steps

To learn how to use Chat completion configuration in your application, continue to this tutorial.

> [!div class="nextstepaction"]
> [Chat completion configuration](./howto-chat-completion-config.md)