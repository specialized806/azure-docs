---
author: ggailey777
ms.service: azure-functions
ms.topic: include
ms.date: 02/20/2026
ms.author: glenga
---

::: zone pivot="programming-language-csharp"

In a terminal window, start the Functions host:

```console
func start
```

::: zone-end
::: zone pivot="programming-language-java,programming-language-python,programming-language-typescript"

Visual Studio Code integrates with [Azure Functions Core tools](../articles/azure-functions/functions-run-local.md) to let you run this project on your local development computer. To start your Functions app locally, press <kbd>F5</kbd> or select the **Run and Debug** icon in the left-hand side Activity bar.

::: zone-end

The **Terminal** panel displays the output from Core Tools. Your app starts in the **Terminal** panel, and you can see the names of the functions running locally.
