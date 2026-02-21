---
author: ggailey777
ms.service: azure-functions
ms.topic: include
ms.date: 02/20/2026
ms.author: glenga
---

When you're done working with your MCP server and related resources, use this command to delete the function app and its related resources from Azure to avoid incurring further costs:

```console
azd down 
```

> [!NOTE]  
> The `--no-prompt` option instructs `azd` to delete your resource group without confirmation from you. This command doesn't affect your local code project.
