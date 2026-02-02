---
title: "Connect an MCP server on Azure Functions to Foundry Agent Service"
author: im-samz
description: Learn how to connect your MCP server hosted on Azure Functions to Azure AI Foundry Agent Service, enabling your agents to use custom tools.
ms.author: samuelzhang
ms.reviewer: glenga
ms.topic: how-to
ms.date: 02/02/2026
ms.collection: ce-skilling-ai-copilot

#Customer intent: As a developer, I want to learn how to connect an Azure Functions-hosted MCP server to Foundry Agent Service, so that my agent has access to my MCP tools.
---

# Connect an MCP server on Azure Functions to a Foundry Agent Service agent

This article shows you how to connect your [Model Context Protocol](https://modelcontextprotocol.io/docs/getting-started/intro) (MCP) server hosted on Azure Functions to Microsoft Foundry Agent Service. After completing this guide, your agent can discover and invoke the tools exposed by your MCP server.

This article follows this basic process for configuring the MCP server connection from Foundry Agent Service: 

> [!div class="checklist"]
> * Create and deploy an MCP server to your function app in Azure.
> * Get the MCP server endpoint URL.
> * Get the authentication credentials (as required).
> * Add an MCP server tool connection to an existing agent. 

## Prerequisites

Before you begin, make sure you have these resources in place:

* Deploy an MCP server to a function app in Azure by using one of these supported hosting options:
  * [Using the Azure Functions MCP extension](scenario-custom-remote-mcp-server.md).
  * [Self-host a server that uses standard MCP SDKs](scenario-host-mcp-server-sdks.md).
* [Configure built-in authentication](./functions-mcp-tutorial.md#configure-authentication-on-server-app), when using Microsoft Entra ID-based authentication.
* [An existing Foundry project and model](/azure/ai-foundry/tutorials/quickstart-create-foundry-resources?view=foundry&tabs=portal&preserve-view=true).
* [An existing agent](/azure/ai-foundry/quickstarts/get-started-code?view=foundry&preserve-view=true#create-an-agent).

## Review connection options

This table summarizes the currently supported options for authenticating your agent connection to an MCP server in Foundry Agent Service: 

| Method | Description | Use case | Additional setup | Functions supportS |
| ------ | ----------- | -------- | ---------------- | ------------------- |
| **Key-based**<sup>*</sup> | Agent authenticates by passing a shared [function access key](./function-keys-how-to.md) in the request header. | During development or when the MCP server doesn't require Microsoft Entra authentication. | None | Yes |
| **Microsoft Entra** | Agent authenticates using either its own identity (*agent identity*) or the shared identity of the Foundry project (*project managed identity*). | Production-level security where users or agents share the same identity and permissions. | [Disable key-based authentication](functions-mcp-tutorial.md?tabs=mcp-extension#disable-key-based-authentication) and [configure built-in server authorization and authentication](functions-mcp-tutorial.md?tabs=mcp-extension#enable-built-in-server-authorization-and-authentication). | Project managed identity |
| **OAuth identity passthrough** | Agent prompts users to sign in and authorize access, using the provided token to authenticate. | Production when each user must authenticate with their own identity and user context must be persisted. | Not yet determined | No |
| **Unauthenticated access** | Agent makes unauthenticated calls. | During development or when your MCP server accesses only public information. | [Disable key-based authentication](functions-mcp-tutorial.md?tabs=mcp-extension#disable-key-based-authentication). | Yes |

<sup>*</sup>Default for Functions-hosted MCP servers.

To learn more about the MCP server authentication options that the Foundry Agent Service supports, see [Set up authentication for MCP tools](/azure/ai-foundry/agents/how-to/mcp-authentication?view=foundry&preserve-view=true).

## Get the remote MCP server endpoint

Before you can connect the agent to a Functions-hosed MCP server, you must get the endpoint URL for the service. The specific URL format depends on how you created and deployed the MCP server:

| MCP server type | Endpoint format |
| --------------- | --------------- |
| [MCP extension](./functions-bindings-mcp.md)-based server | `https://<FUNCTION_APP_NAME>.azurewebsites.net/runtime/webhooks/mcp` |
| Self-hosted MCP server | `https://<FUNCTION_APP_NAME>.azurewebsites.net/mcp` (unless you changed the route) |

For more information, see [Remote MCP servers](./functions-create-ai-enabled-apps.md#remote-mcp-servers).

## Get required credentials

The credentials that your agent needs to connect to the MCP server depend on the way you plan to secure the connection. Choose the tab that indicates your connection option.

### [Key-based](#tab/key-based)

When you use an access key to connect to your MCP server endpoint, you use a shared secret key to make it more difficult for random agents to connect to your server.

>[!IMPORTANT]
>While access keys provide some mitigation against unwanted access, consider using a positive authentication option to secure your MCP server endpoints in production.   

The access key you need depends on how you built your MCP server:

| MCP server type | Key name | Key type |
| --------------- | -------- | -------- |
| MCP extension server | `mcp_extension` | System key |
| Self-hosted MCP server | `default` | Host key |

To get the key from the Azure portal:

1. Go to your function app resource in the [Azure portal](https://portal.azure.com).
1. Expand the **Functions** dropdown in the left menu.
1. Select **App keys**.
1. Copy either the `mcp_extension` key (under **System keys**) or the `default` key (under **Host keys**), depending on your MCP server type.

For more information, see [Work with access keys in Azure Functions](function-keys-how-to.md).

### [Microsoft Entra](#tab/entra)

Both **Agent Identity** and **Project Managed Identity** use Microsoft Entra authentication. Currently, Functions only supports **Project managed identity**, which requires your server to be configured by using built-in authentication and authorization. The required audience is the Application ID URI from your function app's Entra app registration. You get this value during the [built-in authentication configuration](functions-mcp-tutorial.md?tabs=mcp-extension#configure-protected-resource-metadata-preview).

To get the Application ID URI from the Azure portal:

1. Go to your function app resource in the [Azure portal](https://portal.azure.com).
1. Select **Settings** > **Authentication** from the left menu.
1. Select the name of the Entra app next to **Microsoft**. This selection takes you to the Entra app resource.
1. In the left menu, select **Manage** > **Expose an API**.
1. Copy the **Application ID URI** at the top of the page. This ID value looks like `api://00001111-aaaa-2222-bbbb-3333cccc4444`.

### [Unauthenticated](#tab/unauthenticated)

Because unauthenticated access requires no shared secrets or authentication, you can skip to the next section. 

>[!IMPORTANT]  
>This option allows any client or agent to access your MCP server endpoint and should only be used for tools that return read-only public information or during private development.

---

## Add your MCP server

The way that you create the agent connection to the MCP server depends on your specific endpoint authentication options.

### [Key-based](#tab/key-based)

When you use key-based authentication, the agent authenticates with your MCP server by passing a function access key in the request header.

To connect to your MCP server endpoint:

1. Go to the [Foundry portal (new Foundry)](https://ai.azure.com/nextgen).

1. Select the **Build** tab at the top. This selection opens the **Agents** page.

1. From the table, select the agent you want to equip with MCP tools. This selection brings you to the Agent Builder.

1. Under **Playground**, expand the **Tools** dropdown and select **Add**.

1. Select **+ Add a new tool** > **Custom** tab.

1. Select **Model Context Protocol (MCP)** > **Create**.

1. In **Add Model Content Protocol tool**, provide information from this table to configure an access key-based connection: 

    | Field | Description | Example |
    | ----- | ----------- | ------- |
    | **Name** | A unique identifier for your MCP server. You can use your function app name as the default. | `my-mcp-function-app` |
    | **Remote MCP Server endpoint** | The URL endpoint for your MCP server. | `https://my-mcp-function-app.azurewebsites.net/runtime/webhooks/mcp` |
    | **Authentication** | The authentication method to use. | `Key-based` |
    | **Credential** | The key-value pair to authenticate with your function app. | `x-functions-key`: `aaaaaaaa-0b0b-1c1c-2d2d-333333333333` |

1. Select **Connect** to create a connection to your MCP server endpoint. You should now see your server name listed under **Tools**. 

1. Select **Save** to save the MCP tool configuration in your agent.

### [Microsoft Entra](#tab/entra)

When you use Microsoft Entra authentication, the agent authenticates by using a managed identity to connect to your MCP server.

To connect to your MCP server endpoint:

1. Go to the [Foundry portal (new Foundry)](https://ai.azure.com/nextgen).

1. Select the **Build** tab at the top. This selection opens the **Agents** page.

1. From the table, select the agent you want to equip with MCP tools. This selection brings you to the Agent Builder.

1. Under **Playground**, expand the **Tools** dropdown and select **Add**.

1. Select **+ Add a new tool** > **Custom** tab.

1. Select **Model Context Protocol (MCP)** > **Create**.

1. In **Add Model Content Protocol tool**, enter the information from this table to configure a Microsoft Entra-based connection:

    | Field | Description | Example |
    | ----- | ----------- | ------- |
    | **Name** | A unique identifier for your MCP server. You can use your function app name. | `my-mcp-functions` |
    | **Remote MCP Server endpoint** | The URL endpoint for your MCP server. | `https://my-mcp-functions.azurewebsites.net/runtime/webhooks/mcp` |
    | **Authentication** | The authentication method to use. | `Microsoft Entra` |
    | **Type** | The identity type the agent uses to authenticate. | `Project Managed Identity` |
    | **Audience** | The Application ID URI of your function app's Entra registration. This value tells the identity provider which app the token is intended for. | `api://00001111-aaaa-2222-bbbb-3333cccc4444` |

1. Select **Connect** to create a connection to your MCP server endpoint. You should now see your server name listed under **Tools**.

1. Select **Save** to save the MCP tool configuration in your agent.

### [Unauthenticated](#tab/unauthenticated)

Use unauthenticated access only when your MCP server doesn't require authentication and accesses only public information.

To connect to your MCP server endpoint:

1. Go to the [Foundry portal (new Foundry)](https://ai.azure.com/nextgen).

1. Select the **Build** tab at the top. This selection opens the **Agents** page.

1. From the table, select the agent you want to equip with MCP tools. This selection brings you to the Agent Builder.

1. Under **Playground**, expand the **Tools** dropdown and select **Add**.

1. Select **+ Add a new tool** > **Custom** tab.

1. Select **Model Context Protocol (MCP)** > **Create**.

1. In **Add Model Content Protocol tool**, provide information from this table to configure an unauthenticated connection:

    | Field | Description | Example |
    | ----- | ----------- | ------- |
    | **Name** | A unique identifier for your MCP server. You can use your function app name. | `my-mcp-functions` |
    | **Remote MCP Server endpoint** | The URL endpoint for your MCP server. | `https://my-mcp-functions.azurewebsites.net/runtime/webhooks/mcp` |
    | **Authentication** | The authentication method to use. | `Unauthenticated` |

1. Select **Connect** to create an unauthenticated connection to your MCP server endpoint. You should now see your server name listed under **Tools**.

1. Select **Save** to save the MCP tool configuration in your agent.

---

## Test your MCP tools

After connecting your MCP server to your agent, verify that the tools work correctly.

1. In the Agent Builder, find the chat window under **Playground**.
1. Enter a prompt that should trigger one of your MCP tools. For example, if your MCP server has a greeting tool, try: `Use the greeting tool to say hello`.
1. When the agent requests to invoke an MCP tool, review the tool name and arguments, and select **Approve** to allow the call.
1. Verify the tool returns the expected result.

Your agent can now use the tools exposed by your MCP server hosted on Azure Functions.

## Related articles

These additional articles can help you build your agent and function app capabilities:

### [Agent development](#tab/foundry)

- [Learn more about Foundry Agent Service and the agent development lifecycle](/azure/ai-foundry/agents/overview?view=foundry&preserve-view=true)
- [Equip your agent with built-in tools from the Foundry tool catalog](/azure/ai-foundry/agents/concepts/tool-catalog?view=foundry&preserve-view=true)
- [Enrich your agent with access to your enterprise knowledge bases](/azure/ai-foundry/agents/concepts/what-is-foundry-iq?view=foundry&preserve-view=true&tabs=portal)

### [Function app operations](#tab/functions)

- [Set up continuous deployment with GitHub Actions](./functions-how-to-github-actions.md)
- [Monitor Azure Functions with OpenTelemetry](./opentelemetry-howto.md)
- [Keep iterating according to Azure Functions best practices](./functions-best-practices.md)

### [Tool sharing](#tab/tools)

- [Register your MCP server in the organizational tool catalog](./register-mcp-server-api-center.md)

---