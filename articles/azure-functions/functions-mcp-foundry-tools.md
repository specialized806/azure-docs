---
title: "Connect an MCP server on Azure Functions to a Foundry agent"
author: samuelzhang
description: Learn how to connect your MCP server hosted on Azure Functions to Azure AI Foundry Agent Service, enabling your agents to use custom tools.
ms.author: samuelzhang
ms.topic: how-to
ms.date: 1/30/2026
ms.collection: 
  - ce-skilling-ai-copilot 

#Customer intent: As a developer, I want to learn how to connect an MCP server built on Azure Functions to Foundry Agent Service, so that my agent has access to my MCP tools.
---

# Connect an MCP server on Azure Functions to a Foundry agent

This article shows you how to connect your [Model Context Protocol](https://modelcontextprotocol.io/docs/getting-started/intro) (MCP) server hosted on Azure Functions to Microsoft Foundry Agent Service. After completing this guide, your Foundry agent can discover and invoke the tools exposed by your MCP server.

## Prerequisites

Before you begin, make sure you have completed the following:

> [!div class="checklist"]
> * [Deployed your MCP server to a function app](scenario-custom-remote-mcp-server.md).
> * [Configured your function app to use an authentication method](#authentication-methods) that works for your scenario.
> * [Created a Foundry project and model](/azure/ai-foundry/tutorials/quickstart-create-foundry-resources?view=foundry&tabs=portal&preserve-view=true).
> * [Created a Foundry agent](/azure/ai-foundry/quickstarts/get-started-code?view=foundry&tabs=portal&preserve-view=true).

## Authentication methods

Your function app should already be configured with an authentication method. The following table summarizes the available options to help you verify your configuration before connecting to Foundry.

| Method | Description | Use case | Additional setup |
| ------ | ----------- | -------- | ---------------- |
| **Key-based** | Agent authenticates by passing a function access key in the request header. | Prototyping or when the MCP server doesn't access proprietary data. | None. This authentication method is the default. |
| **Microsoft Entra - agent identity** | Agent authenticates using its own identity. | Prototyping or production when every user of the agent shares the same identity permissions. | [Disable key-based authentication](functions-mcp-tutorial.md?tabs=mcp-extension#disable-key-based-authentication) and [configure built-in server authorization and authentication](functions-mcp-tutorial.md?tabs=mcp-extension#enable-built-in-server-authorization-and-authentication). |
| **Microsoft Entra - project managed identity** | Agent authenticates using the shared identity of the Foundry project. | Prototyping when every user of the agent is allowed to access the same data. | [Disable key-based authentication](functions-mcp-tutorial.md?tabs=mcp-extension#disable-key-based-authentication) and [configure built-in server authorization and authentication](functions-mcp-tutorial.md?tabs=mcp-extension#enable-built-in-server-authorization-and-authentication). |
| **OAuth identity passthrough** | Agent prompts users to sign in and authorize access, using the provided token to authenticate. | Prototyping or production when each user must authenticate with their own identity and user context must be persisted. | [Disable key-based authentication](functions-mcp-tutorial.md?tabs=mcp-extension#disable-key-based-authentication) and [configure built-in server authorization and authentication](functions-mcp-tutorial.md?tabs=mcp-extension#enable-built-in-server-authorization-and-authentication). |
| **Unauthenticated access** | Agent makes unauthenticated calls. | Prototyping when your MCP server accesses only public information. | [Disable key-based authentication](functions-mcp-tutorial.md?tabs=mcp-extension#disable-key-based-authentication). |

Microsoft Entra and OAuth identity passthrough methods require the same function app configuration — all expect an authenticated token. The difference is which identity the agent presents to your function app.

For more information about authentication options from the Foundry perspective, see [Set up authentication for MCP tools](/azure/ai-foundry/agents/how-to/mcp-authentication?view=foundry&preserve-view=true).

## Connect to Foundry

After you verify your authentication configuration, you can connect your MCP server to a Foundry agent. Select the tab that matches your authentication method.

### [Key-based](#tab/key-based)

When using key-based authentication, the agent passes a function access key in the request header to authenticate with your MCP server.

:::image type="content" source="./media/functions-mcp/foundry-key-based-auth.png" alt-text="Screenshot of the Add Model Context Protocol tool dialog showing key-based authentication configuration.":::

The following table describes the fields required to connect your MCP server:

| Field | Description | Example |
| ----- | ----------- | ------- |
| **Name** | A unique identifier for your MCP server. You can default to your function app name. | `my-mcp-function-app` |
| **Remote MCP Server endpoint** | The URL endpoint for your MCP server. | `https://my-mcp-function-app.azurewebsites.net/runtime/webhooks/mcp` |
| **Authentication** | The authentication method to use. | `Key-based` |
| **Credential** | The key-value pair to authenticate with your function app. | `x-functions-key`: `{mcp_extension_key}` |

#### Get the remote MCP server endpoint

The endpoint URL depends on how you built your MCP server:

| MCP server type | Endpoint format |
| --------------- | --------------- |
| MCP extension server | `https://<FUNCTION_APP_NAME>.azurewebsites.net/runtime/webhooks/mcp` |
| Self-hosted MCP server | `https://<FUNCTION_APP_NAME>.azurewebsites.net/mcp` (unless you changed the route) |

For the differences in technology, see [Remote MCP servers](./functions-create-ai-enabled-apps#remote-mcp-servers.md).

#### Get the access key

The access key you need depends on how you built your MCP server:

| MCP server type | Key name | Key type |
| --------------- | -------- | -------- |
| MCP extension server | `mcp_extension` | System key |
| Self-hosted MCP server | `default` | Host key |

To get the key from the Azure portal:

1. Navigate to your function app resource in the [Azure portal](https://portal.azure.com).
1. Expand the **Functions** dropdown in the left menu.
1. Select **App keys**.
1. Copy either the `mcp_extension` key (under **System keys**) or the `default` key (under **Host keys**), depending on your MCP server type.

#### Connect your MCP server

1. Navigate to the [Foundry portal](https://ai.azure.com).
1. Ensure the **New Foundry** toggle is selected.
1. Select the **Build** tab at the top. This opens the **Agents** blade.
1. From the table, select the agent you want to equip with MCP tools. This brings you to the Agent Builder.
1. Under **Playground**, expand the **Tools** dropdown and select **Add**.
1. Select **+ Add a new tool**.
1. Select the **Custom** tab.
1. Select **Model Context Protocol (MCP)** and then select **Create**.
1. Ensure **Key-based** is selected for **Authentication**.
1. Fill out the form using the information you saved earlier, then select **Connect**.

You should now see the name you provided under **Tools**. Select **Save** in the top right to save the MCP tool to your agent.

### [Microsoft Entra](#tab/entra)

Both **Agent Identity** and **Project Managed Identity** use Microsoft Entra authentication. The difference is which identity the agent uses to authenticate with your MCP server:

- **Agent identity**: Uses the agent's own identity. All agents in a Foundry project share the same agent identity before publishing. After publishing, each agent gets a unique identity.
- **Project managed identity**: Uses the Foundry project's managed identity. Any role assignments must be configured on the project's managed identity.

:::image type="content" source="./media/functions-mcp/foundry-entra-auth.png" alt-text="Screenshot of the Add Model Context Protocol tool dialog showing Microsoft Entra authentication configuration.":::

The following table describes the fields required to connect your MCP server:

| Field | Description | Example |
| ----- | ----------- | ------- |
| **Name** | A unique identifier for your MCP server. You can default to your function app name. | `my-mcp-functions` |
| **Remote MCP Server endpoint** | The URL endpoint for your MCP server. | `https://my-mcp-functions.azurewebsites.net/runtime/webhooks/mcp` |
| **Authentication** | The authentication method to use. | `Microsoft Entra` |
| **Type** | The identity type the agent uses to authenticate. | `Agent Identity` or `Project Managed Identity` |
| **Audience** | The Application ID URI of your function app's Entra registration. This value tells the identity provider which app the token is intended for. | `api://abcd123-efg456-hijk-7890123` |

#### Get the remote MCP server endpoint

The endpoint URL depends on how you built your MCP server:

| MCP server type | Endpoint format |
| --------------- | --------------- |
| MCP extension server | `https://<FUNCTION_APP_NAME>.azurewebsites.net/runtime/webhooks/mcp` |
| Self-hosted MCP server | `https://<FUNCTION_APP_NAME>.azurewebsites.net/mcp` (unless you changed the route) |

For the differences in technology, see [Remote MCP servers](./functions-create-ai-enabled-apps#remote-mcp-servers.md).

#### Get the audience (Application ID URI)

The audience is the Application ID URI from your function app's Entra app registration. You find this value during the [built-in authentication configuration](functions-mcp-tutorial.md?tabs=mcp-extension#configure-protected-resource-metadata-preview).

To get the Application ID URI from the Azure portal:

1. Navigate to your function app resource in the [Azure portal](https://portal.azure.com).
1. Select **Settings** > **Authentication** from the left menu.
1. Select the name of the Entra app next to **Microsoft**. This takes you to the Entra app resource.
1. In the left menu, select **Manage** > **Expose an API**.
1. Copy the **Application ID URI** at the top of the page. It looks like `api://abcd123-efg456-hijk-7890123`.

#### Grant the agent identity access

Before connecting, ensure the agent identity or project managed identity has the required role assignments on your function app:

1. Navigate to your function app in the [Azure portal](https://portal.azure.com).
1. Select **Settings** > **Authentication** from the left menu.
1. Select the name of the Entra app next to **Microsoft**.
1. In the left menu, select **Manage** > **Expose an API**.
1. Under **Authorized client applications**, select **+ Add a client application**.
1. Enter the agent identity's or project managed identity's client ID.
1. Select the checkbox for the scope (for example, `api://abcd123-efg456-hijk-7890123/user_impersonation`).
1. Select **Add application**.

#### Connect your MCP server

1. Navigate to the [Foundry portal](https://ai.azure.com).
1. Ensure the **New Foundry** toggle is selected.
1. Select the **Build** tab at the top. This opens the **Agents** blade.
1. From the table, select the agent you want to equip with MCP tools. This brings you to the Agent Builder.
1. Under **Playground**, expand the **Tools** dropdown and select **Add**.
1. Select **+ Add a new tool**.
1. Select the **Custom** tab.
1. Select **Model Context Protocol (MCP)** and then select **Create**.
1. Select **Microsoft Entra** for **Authentication**.
1. Select either **Agent Identity** or **Project Managed Identity** for **Type**.
1. Fill out the form using the information you saved earlier, then select **Connect**.

You should now see the name you provided under **Tools**. Select **Save** in the top right to save the MCP tool to your agent.

### [OAuth identity passthrough](#tab/oauth)

OAuth identity passthrough prompts users interacting with your agent to sign in and authorize access to the MCP server. This method preserves user context across tool calls.

> [!NOTE]
> Detailed configuration for OAuth identity passthrough will be covered in a future update. For now, see [Set up authentication for MCP tools](/azure/ai-foundry/agents/how-to/mcp-authentication?view=foundry&preserve-view=true#oauth-identity-passthrough) for the latest guidance.

### [Unauthenticated](#tab/unauthenticated)

Use unauthenticated access only when your MCP server doesn't require authentication and accesses only public information.

:::image type="content" source="./media/functions-mcp/foundry-unauthenticated-auth.png" alt-text="Screenshot of the Add Model Context Protocol tool dialog showing unauthenticated access configuration.":::

The following table describes the fields required to connect your MCP server:

| Field | Description | Example |
| ----- | ----------- | ------- |
| **Name** | A unique identifier for your MCP server. You can default to your function app name. | `my-mcp-functions` |
| **Remote MCP Server endpoint** | The URL endpoint for your MCP server. | `https://my-mcp-functions.azurewebsites.net/runtime/webhooks/mcp` |
| **Authentication** | The authentication method to use. | `None` |

#### Get the remote MCP server endpoint

The endpoint URL depends on how you built your MCP server:

| MCP server type | Endpoint format |
| --------------- | --------------- |
| MCP extension server | `https://<FUNCTION_APP_NAME>.azurewebsites.net/runtime/webhooks/mcp` |
| Self-hosted MCP server | `https://<FUNCTION_APP_NAME>.azurewebsites.net/mcp` (unless you changed the route) |

For the differences in technology, see [Remote MCP servers](./functions-create-ai-enabled-apps#remote-mcp-servers.md).

#### Connect your MCP server

1. Navigate to the [Foundry portal](https://ai.azure.com).
1. Ensure the **New Foundry** toggle is selected.
1. Select the **Build** tab at the top. This opens the **Agents** blade.
1. From the table, select the agent you want to equip with MCP tools. This brings you to the Agent Builder.
1. Under **Playground**, expand the **Tools** dropdown and select **Add**.
1. Select **+ Add a new tool**.
1. Select the **Custom** tab.
1. Select **Model Context Protocol (MCP)** and then select **Create**.
1. Select **Unauthenticated** for **Authentication**.
1. Fill out the form using the information you saved earlier, then select **Connect**.

You should now see the name you provided under **Tools**. Select **Save** in the top right to save the MCP tool to your agent.

---

## Test your MCP tools

After connecting your MCP server to your Foundry agent, test that the tools work correctly.

1. In the Agent Builder, find the chat window under **Playground**.
1. Enter a prompt that should trigger one of your MCP tools. For example, if your MCP server has a greeting tool, try: `Use the greeting tool to say hello`.
1. When the agent requests to invoke an MCP tool, review the tool name and arguments, then select **Approve** to allow the call.
1. Verify the tool returns the expected result.

Congratulations! Your Foundry agent can now use the tools exposed by your MCP server hosted on Azure Functions.

## Next steps

Continue building your agent and function app capabilities:

### Agent development

- [Evaluate agent performance with evals](/azure/ai-foundry/agents/how-to/evaluate-agents?view=foundry&preserve-view=true)
- [Add guardrails to your agent](/azure/ai-foundry/agents/concepts/content-filtering?view=foundry&preserve-view=true)
- [Agent identity concepts in Foundry](/azure/ai-foundry/agents/concepts/agent-identity?view=foundry&preserve-view=true)

### Function app operations

- [Set up continuous deployment with GitHub Actions](./functions-how-to-github-actions.md)
- [Monitor Azure Functions with OpenTelemetry](./opentelemetry-howto.md)
- [Keep iterating according to Azure Functions best practices](./functions-best-practices.md)

### Tool sharing

- [Register your MCP server in the organizational tool catalog](./register-mcp-server-api-center.md)