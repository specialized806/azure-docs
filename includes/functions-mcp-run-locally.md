---
author: ggailey777
ms.service: azure-functions
ms.topic: include
ms.date: 02/20/2026
ms.author: glenga
---

Visual Studio Code integrates with [Azure Functions Core tools](../articles/azure-functions/functions-run-local.md) to let you run this project on your local development computer by using the Azurite emulator.

1. To start the function locally, press <kbd>F5</kbd> or the **Run and Debug** icon in the left-hand side Activity bar. The **Terminal** panel displays the output from Core Tools. Your app starts in the **Terminal** panel, and you can see the name of the functions that are running locally.

1. Make a note of the local MCP server endpoint (like `http://localhost:7071/runtime/webhooks/mcp`), which you use to configure GitHub Copilot in Visual Studio Code. 
