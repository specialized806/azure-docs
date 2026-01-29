---
title: Use App Service as a Model Context Protocol (MCP) server
description: Integrate your web app as a Model Context Protocol (MCP) server to extend the capabilities of leading personal AI agents such as GitHub Copilot Chat, Cursor, and Winsurf.
author: cephalin
ms.author: cephalin
ms.service: azure-app-service
ms.topic: how-to
ms.date: 01/29/2026
ms.custom:
  - build-2025
ms.collection: ce-skilling-ai-copilot
ms.update-cycle: 180-days
---

# App Service as Model Context Protocol (MCP) servers

Integrate your web app as a [Model Context Protocol (MCP)](https://modelcontextprotocol.io/introduction) server to extend the capabilities of leading personal AI agents such as GitHub Copilot Chat, Cursor, and Winsurf. By exposing your app's APIs through MCP, you can supercharge these agents with the unique features and business logic your web app already provides, without major development effort or rearchitecture.

## [.NET](#tab/dotnet)
- [Integrate an App Service app as an MCP Server for GitHub Copilot Chat (.NET)](tutorial-ai-model-context-protocol-server-dotnet.md)
- Sample: [Host a .NET MCP server on Azure App Service](https://github.com/Azure-Samples/remote-mcp-webapp-dotnet)

## [Java](#tab/java)
- [Integrate an App Service app as an MCP Server for GitHub Copilot Chat (Java)](tutorial-ai-model-context-protocol-server-java.md)

## [Node.js](#tab/nodejs)
- [Integrate an App Service app as an MCP Server for GitHub Copilot Chat (Node.js)](tutorial-ai-model-context-protocol-server-node.md)
- Sample: [Host a Node.js MCP server on Azure App Service](https://github.com/Azure-Samples/remote-mcp-webapp-node)

## [Python](#tab/python)
- [Integrate an App Service app as an MCP Server for GitHub Copilot Chat (Python)](tutorial-ai-model-context-protocol-server-python.md)
- Sample: [Host a Python MCP server on Azure App Service](https://github.com/Azure-Samples/remote-mcp-webapp-python)
- Sample: [Host a Python MCP server with key-based authorization on Azure App Service](https://github.com/Azure-Samples/remote-mcp-webapp-python-auth)
- Sample: [Host a Python MCP server with OAuth 2.0 authorization on Azure App Service](https://github.com/Azure-Samples/remote-mcp-webapp-python-auth-oauth) - Deploy an MCP server with Python and [Open Authorization (OAuth) 2.0 authorization with Microsoft Entra ID](/entra/architecture/auth-oauth2).
-----

## Related content

- [Integrate AI into your Azure App Service applications](overview-ai-integration.md)
- [Secure a Model Context Protocol server in Azure App Service](configure-authentication-mcp.md)
- [Secure Model Context Protocol calls to Azure App Service from Visual Studio Code with Microsoft Entra authentication](configure-authentication-mcp-server-vscode.md)
