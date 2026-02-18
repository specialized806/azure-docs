---
title: MCP resource trigger for Azure Functions
description: Learn how you can use a trigger endpoint to expose functions as model context protocol (MCP) server resources in Azure Functions.
ms.topic: reference
ms.date: 02/18/2026
ms.update-cycle: 180-days
ai-usage: ai-assisted
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

The following code creates an endpoint to expose a resource named `readme` that reads a markdown file and returns its contents as plain text. Clients can access this resource using the `file://readme.md` URI.

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

In this example, a folder called `assets` containing the `readme` is bundled with the function app at build time because the following directive is added to the `.csproj` file:

```xml
<ItemGroup>
  <None Update="assets\**\*">
    <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
  </None>
</ItemGroup>
```

The `PreserveNewest` directive copies everything under `assets` into the build output, preserving the folder structure. When deployed to Azure Functions, these files are extracted to the function app's root directory (`%HOME%\site\wwwroot`), so a file at `assets/readme.md` in the project is accessible at runtime via `Path.Combine(AppContext.BaseDirectory, "assets", "readme.md")`. This works the same way both locally and when deployed to Azure. The asset files are packaged with the deployment artifact rather than uploaded separately to external storage. For the complete code example, see the [Azure Functions MCP Extension repo](https://github.com/Azure/azure-functions-mcp-extension/tree/main/test/TestAppIsolated). 

::: zone-end

::: zone pivot="programming-language-java"
The MCP extention in Java does not support resource today. 
::: zone-end

::: zone pivot="programming-language-javascript"  
Example code for JavaScript isn't currently available. See the TypeScript example for general guidance.
::: zone-end  

::: zone pivot="programming-language-typescript"

The following code registers a resource named `Weather Widget` that serves an interactive weather display as bundled HTML content. The resource uses the `ui://` scheme to indicate it's an MCP App UI resource.

```typescript
import { app, InvocationContext, arg } from "@azure/functions";
import * as fs from "fs";
import * as path from "path";

// Constants for the Weather Widget resource
const WEATHER_WIDGET_URI = "ui://weather/index.html";
const WEATHER_WIDGET_NAME = "Weather Widget";
const WEATHER_WIDGET_DESCRIPTION = "Interactive weather display for MCP Apps";
const WEATHER_WIDGET_MIME_TYPE = "text/html;profile=mcp-app";

// Metadata for the resource (as valid JSON string)
const RESOURCE_METADATA = JSON.stringify({
  ui: {
    prefersBorder: true
  }
});

app.mcpResource("getWeatherWidget", {
  uri: WEATHER_WIDGET_URI,
  resourceName: WEATHER_WIDGET_NAME,
  description: WEATHER_WIDGET_DESCRIPTION,
  mimeType: WEATHER_WIDGET_MIME_TYPE,
  metadata: RESOURCE_METADATA,
  handler: getWeatherWidget,
});
```

The following is the `getWeatherWidget` handler:

```typescript
export async function getWeatherWidget(
  resourceContext: unknown,
  context: InvocationContext
): Promise<string> {
  context.log("Getting weather widget");

  try {
    const filePath = path.join(__dirname, "..", "..", "..", "src", "app", "dist", "index.html");
    return fs.readFileSync(filePath, "utf-8");
  } catch (error) {
    context.log(`Error reading weather widget file: ${error}`);
    return `<!DOCTYPE html>
      <html>
      <head><title>Weather Widget</title></head>
      <body>
      <h1>Weather Widget</h1>
      <p>Widget content not found. Please ensure the app/dist/index.html file exists.</p>
      </body>
      </html>`;
  }
}
```

A tool can reference this resource by declaring a `resourceUri` in its metadata. When the tool is invoked, the MCP host fetches the resource and renders it:

```typescript
// Metadata for the tool (as valid JSON string)
const TOOL_METADATA = JSON.stringify({
  ui: {
    resourceUri: "ui://weather/index.html"
  }
});

app.mcpTool("getWeather", {
  toolName: "GetWeather",
  description: "Returns current weather for a location via Open-Meteo.",
  toolProperties: {
    location: arg.string().describe("City name to check weather for (e.g., Seattle, New York, Miami)")
  },
  metadata: TOOL_METADATA,
  handler: getWeather,
});
```

For the complete code example, see [weatherMcpApp.ts](https://github.com/Azure-Samples/remote-mcp-functions-typescript/blob/McpAppDemo/src/functions/weatherMcpApp.ts).
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

> [!NOTE]
> The MCP resource trigger for TypeScript requires version `4.12.0-preview.2` or later of the [`@azure/functions`](https://www.npmjs.com/package/@azure/functions/v/4.12.0-preview.2) package, which is in extension bundle version `[4.32.0, 5.0.0)`. Check `host.json` to make sure the correct bundle version is specified:
>
> ```json
> "extensionBundle": {
>   "id": "Microsoft.Azure.Functions.ExtensionBundle",
>   "version": "[4.32.0, 5.0.0)"
> }
> ```

The trigger supports these binding options, which are defined in your code: 

| Options | Description |
|-----------------------|-------------|
| **type** | Must be set to `mcpResourceTrigger`. Only used with generic definitions. |
| **uri** | (Required) The URI of the MCP resource exposed by the function endpoint. Must be an absolute URI. |
| **resourceName** | (Required) The human-readable name of the MCP resource exposed by the function endpoint. |
| **title** | An optional title for display purposes in MCP client interfaces. |
| **description**  | A description of the MCP resource exposed by the function endpoint.  |
| **mimeType** | The MIME type of the content returned by the resource. For example, `text/html;profile=mcp-app`. |
| **size** | The expected size of the resource content in bytes, if known. |
| **metadata** | A JSON-serialized string of additional metadata for the resource. |
| **handler** | The method that contains the actual function code. |

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

::: zone pivot="programming-language-java,programming-language-python"

Usage details for this language aren't currently available. See the C# documentation for general guidance.

::: zone-end

::: zone pivot="programming-language-javascript,programming-language-typescript"

The resource handler function has two parameters: 

| Parameter | Type | Description |
| --- | --- | --- |
| **messages** | `T` (defaults to `unknown`) | The trigger payload passed by the MCP extension. (The sample above code names this parameter `resourceContext`.) |
| **context** | `InvocationContext` | The Azure Functions invocation context, which provides logging and other runtime information. |

The function should return a `string` containing the resource content (for example, HTML, JSON, or plain text).

::: zone-end

For more information, see [Examples](#example).

## host.json settings

The host.json file contains settings that control MCP trigger behaviors. See the [host.json settings](functions-bindings-mcp.md#hostjson-settings) section for details regarding available settings.

## Related articles

[MCP tool trigger for Azure Functions](functions-bindings-mcp-tool-trigger.md)
