---
title: Azure Functions Web PubSub bindings
description: Understand how to use Web PubSub bindings with Azure Functions.
ms.topic: reference
ms.custom: devx-track-extended-java, devx-track-js, devx-track-python
ms.date: 09/02/2024
zone_pivot_groups: programming-languages-set-functions-lang-workers
---

# Web PubSub bindings for Azure Functions

This set of articles explains how to authenticate, send real-time messages to clients connected to [Azure Web PubSub](https://azure.microsoft.com/products/web-pubsub/) by using Azure Web PubSub bindings in Azure Functions.

| Action | Type |
|---------|---------|
| Handle client events from Web PubSub  | [Trigger binding](./functions-bindings-web-pubsub-trigger.md) |
| Handle client events from Web PubSub with HTTP trigger, or return client access URL and token | [Input binding](./functions-bindings-web-pubsub-input.md)
| Invoke service APIs | [Output binding](./functions-bindings-web-pubsub-output.md) |

[Samples](https://github.com/Azure/azure-webpubsub/tree/main/samples/functions)

::: zone pivot="programming-language-csharp"

## Install extension

The extension NuGet package you install depends on the C# mode you're using in your function app:

# [Isolated worker model](#tab/isolated-process)

Functions execute in an isolated C# worker process. To learn more, see [Guide for running C# Azure Functions in an isolated worker process](dotnet-isolated-process-guide.md).

Add the extension to your project by installing this [NuGet package](https://www.nuget.org/packages/Microsoft.Azure.Functions.Worker.Extensions.WebPubSub/).

# [In-process model](#tab/in-process)

[!INCLUDE [functions-in-process-model-retirement-note](../../includes/functions-in-process-model-retirement-note.md)]

Functions execute in the same process as the Functions host. To learn more, see [Develop C# class library functions using Azure Functions](functions-dotnet-class-library.md).

Add the extension to your project by installing this [NuGet package].

---

::: zone-end

::: zone pivot="programming-language-javascript,programming-language-python,programming-language-powershell"

[!INCLUDE [functions-install-extension-bundle](../../includes/functions-install-extension-bundle.md)]

::: zone-end
::: zone pivot="programming-language-java"

> [!NOTE]
> The Web PubSub extensions for Java is not supported yet.

::: zone-end

## Key concepts

![Diagram showing the workflow of Azure Web PubSub service working with Function Apps.](../azure-web-pubsub/media/reference-functions-bindings/functions-workflow.png)

(1)-(2) `WebPubSubConnection` input binding with HttpTrigger to generate client connection.

(3)-(4) `WebPubSubTrigger` trigger binding or `WebPubSubContext` input binding with HttpTrigger to handle service request.

(5)-(6) `WebPubSub` output binding to request service do something.

## Connection string settings

By default, an application setting named `WebPubSubConnectionString` is used to store your Web PubSub connection string. When you choose to use a different setting name for your connection, you must explicitly set that as the key name in your binding definitions. During local development, you must also add this setting to the `Values` collection in the the [_local.settings.json_ file](./functions-develop-local.md#local-settings-file).

> [!IMPORTANT]
> A connection string includes the authorization information required for your application to access Azure Web PubSub service. The access key inside the connection string is similar to a root password for your service. For optimal security, your function app should use managed identities when connecting to the Web PubSub service instead of using a connection string. For more information, see [Authorize a managed identity request by using Microsoft Entra ID](../azure-web-pubsub/howto-authorize-from-managed-identity.md). 

For details on how to configure and use Web PubSub and Azure Functions together, refer to [Tutorial: Create a serverless notification app with Azure Functions and Azure Web PubSub service](../azure-web-pubsub/tutorial-serverless-notification.md).
::: zone pivot="programming-language-csharp"
> [!NOTE]
> When running in the isolated worker model, the Azure Web PubSub binding doesn't currently support Microsoft Entra ID authentication using managed identities. In the isolated model, you must continue to use a connection string, which includes a shared secret key.

## Identity-based connections

If you're using Web PubSub Functions Extensions v1.10.0 or higher, instead of using a connection string with an access key, you can configure your Azure Function app to authenticate to Azure Web PubSub using a Microsoft Entra identity.

This approach removes the need to manage secrets and is recommended for production workloads.

### Prerequisites

First, make sure the Microsoft Entra identity used by your Azure Function has been granted an appropriate Azure RBAC role on the target Web PubSub resource:

- Web PubSub Service Owner

### Configuration

By default, Web PubSub Functions Extensions look for settings with the prefix: `WebPubSubConnectionString`.

You can customize this prefix using the `connection` property in the binding configuration.

In identity-based connection mode, the settings consist of the following items:

| Property   | Environment variable template     | Description     |  Required  | Example value     |
|--------------|----------|-----|----------|
| Service URI | `WebPubSubConnectionString__serviceUri` | The URI of your service endpoint. When you only configure "Service URI", the extensions would attempt to use [DefaultAzureCredential](/dotnet/azure/sdk/authentication/credential-chains?tabs=dac#defaultazurecredential-overview) type to authenticate with the service.  |  Yes |  https://mysignalrsevice.service.signalr.net|
| Token Credential |  `WebPubSubConnectionString__credential` | Defines how a token should be obtained for the connection. This setting should be set to `managedidentity` if your deployed Azure Function intends to use managed identity authentication. This value is only valid when a managed identity is available in the hosting environment. | No   | managedidentity |
| Client ID | `WebPubSubConnectionString__clientId` | When `credential` is set to `managedidentity`, this property can be set to specify the user-assigned identity to be used when obtaining a token. The property accepts a client ID corresponding to a user-assigned identity assigned to the application. It's invalid to specify both a Resource ID and a client ID. If not specified, the system-assigned identity is used. This property is used differently in [local development scenarios](./functions-reference.md#local-development-with-identity-based-connections), when `credential` shouldn't be set. |   No |  00000000-0000-0000-0000-000000000000  |
| Resource ID | `WebPubSubConnectionString__managedIdentityResourceId` | When `credential` is set to `managedidentity`, this property can be set to specify the resource Identifier to be used when obtaining a token. The property accepts a resource identifier corresponding to the resource ID of the user-defined managed identity. It's invalid to specify both a resource ID and a client ID. If neither are specified, the system-assigned identity is used. This property is used differently in [local development scenarios](./functions-reference.md#local-development-with-identity-based-connections), when `credential` shouldn't be set. |   No |  /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mygroup/providers/Microsoft.SignalRService/SignalR/mysignalrservice   |

#### Example configuration

The following example shows how to configure identity-based authentication using a user-assigned managed identity:

```json
{
  "WebPubSubConnectionString__serviceUri": "https://your-webpubsub.webpubsub.azure.com",
  "WebPubSubConnectionString__credential": "managedidentity",
  "WebPubSubConnectionString__clientId": "your-managed-identity-client-id"
}
```

> [!NOTE]
> When using `local.settings.json` file at local, [Azure App Configuration](../azure-app-configuration/quickstart-azure-functions-csharp.md), or [Key Vault](/azure/key-vault/general/overview) to provide settings for identity-based connections, replace `__` with `:` in the setting name to ensure names are resolved correctly.
>
> For example, `WebPubSubConnectionString:serviceUri`.

::: zone-end
## Next steps

- [Handle client events from Web PubSub  (Trigger binding)](./functions-bindings-web-pubsub-trigger.md)
- [Handle client events from Web PubSub with HTTP trigger, or return client access URL and token (Input binding)](./functions-bindings-web-pubsub-input.md)
- [Invoke service APIs  (Output binding)](./functions-bindings-web-pubsub-output.md)

[NuGet package]: https://www.nuget.org/packages/Microsoft.Azure.WebJobs.Extensions.WebPubSub
[core tools]: ./functions-run-local.md
[extension bundle]: ./extension-bundles.md
[Update your extensions]: ./functions-bindings-register.md
[Azure Tools extension]: https://marketplace.visualstudio.com/items?itemName=ms-vscode.vscode-node-azure-pack

