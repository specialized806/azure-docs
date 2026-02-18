---
title: MCP resource trigger for Azure Functions
description: Learn how you can use a trigger endpoint to expose functions as model context protocol (MCP) server resources in Azure Functions.
ms.topic: reference
ms.date: 02/18/2026
ms.update-cycle: 180-days
ms.custom: 
  - build-2025
ai-usage: ai-assisted
ms.collection: 
  - ce-skilling-ai-copilot
zone_pivot_groups: programming-languages-set-functions
---

# MCP resource trigger for Azure Functions

Use the MCP resource trigger to define resource endpoints in a [Model Content Protocol (MCP)](https://github.com/modelcontextprotocol) server. Clients can use resources to access information for context, such as file contents, database schemas, or API documentation.

For information on setup and configuration details, see the [overview](functions-bindings-mcp.md).

## Example 1

::: zone pivot="programming-language-csharp"  
>[!NOTE]  
> For C#, the Azure Functions MCP extension supports only the [isolated worker model](dotnet-isolated-process-guide.md). 

Example 1 shows how to leverage resource to implement the UI element of MCP Apps. 

The following code creates an endpoint to expose a resource named `Weather Widget` that serves an interactive weather display as bundled HTML content. The resource uses the `ui://` scheme to indicate it's an MCP App UI resource.

```csharp
// Optional resource metadata
private const string ResourceMetadata = """
    {
        "ui": {
            "prefersBorder": true
        }
    }
    """;

[Function(nameof(GetWeatherWidget))]
public string GetWeatherWidget(
    [McpResourceTrigger(
        "ui://weather/index.html",
        "Weather Widget",
        MimeType = "text/html;profile=mcp-app",
        Description = "Interactive weather display for MCP Apps")]
    [McpMetadata(ResourceMetadata)]
        ResourceInvocationContext context)
{
    var file = Path.Combine(AppContext.BaseDirectory, "app", "dist", "index.html");
    return File.ReadAllText(file);
}
```

A tool can reference this resource by declaring a `resourceUri` in its metadata, pointing to `ui://weather/index.html`. When the tool is invoked, the MCP host fetches the resource and renders it: 

```csharp
private const string ToolMetadata = """
    {
        "ui": {
            "resourceUri": "ui://weather/index.html"
        }
    }
    """;

[Function(nameof(GetWeather))]
public async Task<object> GetWeather(
    [McpToolTrigger(nameof(GetWeather), "Returns current weather for a location via Open-Meteo.")]
    [McpMetadata(ToolMetadata)]
        ToolInvocationContext context,
    [McpToolProperty("location", "City name to check weather for (e.g., Seattle, New York, Miami)")]
        string location)
{
    var result = await _weatherService.GetCurrentWeatherAsync(location);
    return result;
}
```

For the complete code example, see [WeatherFunction.cs](https://github.com/Azure-Samples/remote-mcp-functions-dotnet/blob/main/src/McpWeatherApp/WeatherFunction.cs).  

## Example 2

This code creates an endpoint to expose a resource named `readme` that reads a markdown file and returns its contents as plain text. Clients can access this resource using the `file://readme.md` URI.

```csharp
    [Function(nameof(GetTextResource))]
    public string GetTextResource(
        [McpResourceTrigger(
            "file://readme.md",
            "readme",
            Description = "Application readme file",
            MimeType = "text/plain")]
        [McpMetadata(ReadmeMetadata)]
        ResourceInvocationContext context)
    {
        _logger.LogInformation("Reading text resource from local file storage");
        var file = Path.Combine(AppContext.BaseDirectory, "assets", "readme.md");
        return File.ReadAllText(file);
    }
```

::: zone-end
::: zone pivot="programming-language-java"
Example code for Java isn't currently available. See the C# examples for general guidance.
::: zone-end
::: zone pivot="programming-language-javascript"  
Example code for JavaScript isn't currently available. See the C# examples for general guidance.
::: zone-end  
::: zone pivot="programming-language-typescript"
Example code for TypeScript isn't currently available. See the C# examples for general guidance.
::: zone-end  
::: zone pivot="programming-language-python"
Example code for Python isn't currently available. See the C# examples for general guidance.
::: zone-end
[!INCLUDE [functions-mcp-extension-powershell-note](../../includes/functions-mcp-extension-powershell-note.md)]  
::: zone pivot="programming-language-csharp"  
## Attributes

C# libraries use `McpResourceTriggerAttribute` to define the function trigger. 

The attribute's constructor takes the following parameters:

|Parameter | Description|
|---------|----------------------|
|**Uri**| (Required) The URI of the resource, which defines the resource's address. For example, `ui://weather/index.html` defines a static resource URI. |
|**ResourceName**| (Required) The name of the resource that's being exposed by the MCP resource trigger endpoint. |

The attribute also supports the following named properties:

|Property | Description|
|---------|----------------------|
|**Description**| (Optional) A friendly description of the resource endpoint for clients. |
|**MimeType**| (Optional) The MIME type of the content returned by the resource. For example, `text/html;profile=mcp-app` for MCP App UI resources, `text/plain` for plain text, or `application/json` for JSON data. |
|**Size**| (Optional) The size of the resource content in bytes. |
|**Metadata**| (Optional) A JSON-serialized string of metadata for the resource. You can also use the `McpMetadata` attribute as an alternative way to provide metadata. |

You can optionally apply the `McpMetadata` attribute alongside `McpResourceTriggerAttribute` to provide additional metadata for the resource, such as UI display preferences.

See [Usage](#usage) to learn how the resource trigger provides data to your function.

::: zone-end  
::: zone pivot="programming-language-java"  

## Annotations

Annotations for Java aren't currently available. See the C# documentation for general guidance.

::: zone-end  
::: zone pivot="programming-language-python"
## Decorators

Decorators for Python aren't currently available. See the C# documentation for general guidance.

::: zone-end
::: zone pivot="programming-language-javascript,programming-language-typescript"  
## Configuration

Configuration options for JavaScript and TypeScript aren't currently available. See the C# documentation for general guidance.

::: zone-end

::: zone pivot="programming-language-csharp,programming-language-java,programming-language-python,programming-language-javascript,programming-language-typescript"

See the [Example section](#example) for complete examples.

::: zone-end

## Usage

::: zone pivot="programming-language-csharp"  

The MCP resource trigger can bind to the following types:

| Type | Description |
| --- | --- |
| [ResourceInvocationContext] | An object representing the resource request, including the resource URI, session ID, and transport information. |

[ResourceInvocationContext]: https://github.com/Azure/azure-functions-mcp-extension/blob/main/src/Microsoft.Azure.Functions.Worker.Extensions.Mcp/Abstractions/ResourceInvocationContext.cs

The `ResourceInvocationContext` type provides the following properties:

| Property | Type | Description |
| --- | --- | --- |
| **Uri** | `string` | The URI of the resource being requested. |
| **SessionId** | `string?` | The session ID associated with the current resource invocation. |
| **Transport** | `Transport?` | Transport information for the current invocation. |

### Resource URIs

MCP resources use URIs to define the address of the resource. The URI uniquely identifies the resource and is what clients use to request it. You can use any URI scheme appropriate for your resource, such as `ui://` for UI resources or `file://` for file-based resources.

### Resource metadata

You can use the `McpMetadata` attribute to provide additional metadata for resources. This metadata is communicated to MCP clients and can influence how the resource content is displayed or processed.

For example, UI resources can include metadata about display preferences:

```csharp
private const string ResourceMetadata = """
    {
        "ui": {
            "prefersBorder": true
        }
    }
    """;
```

::: zone-end

::: zone pivot="programming-language-java,programming-language-python,programming-language-javascript,programming-language-typescript"

Usage details for this language aren't currently available. See the C# documentation for general guidance.

::: zone-end

For more information, see [Examples](#example).

## host.json settings

The host.json file contains settings that control MCP trigger behaviors. See the [host.json settings](functions-bindings-mcp.md#hostjson-settings) section for details regarding available settings.

## Related articles

[MCP tool trigger for Azure Functions](functions-bindings-mcp-tool-trigger.md)
