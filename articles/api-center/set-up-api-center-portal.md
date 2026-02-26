---
title: Set Up the API Center Portal
description: How to set up the API Center portal, a managed website that enables discovery of the API inventory in your Azure API center.

ms.service: azure-api-center
ms.topic: how-to
ms.date: 02/25/2026
ms.update-cycle: 180-days
 
ms.custom: 
ms.collection: 
# Customer intent: As an API program manager, I want to enable an Azure-managed portal for developers and other API stakeholders in my organization to discover the APIs in my organization's API center.
---

# Set up and customize your API Center portal

This article shows you how to set up and customize the *API Center portal* (preview), an Azure-managed website that developers and other stakeholders in your organization use to discover the APIs, MCP servers, and related assets in your [API center](overview.md). 

The API Center portal supports and streamlines the work of developers who use and create APIs within your organization. Users with access can:

* **Search for APIs** by name or use AI-assisted semantic search.
* **Filter APIs** by type or lifecycle stage.
* **View API details and definitions** including endpoints, methods, parameters, and response formats.
* **Download API definitions** to a local computer or open them in Visual Studio Code.
* **Try out APIs** that support API key authentication or OAuth 2.0 authorization.

:::image type="content" source="media/self-host-api-center-portal/api-center-portal-signed-in.png" alt-text="Screenshot of the API Center portal after user sign-in.":::

> [!NOTE]
> The API Center portal is currently in preview.

> [!TIP]
> Both Azure API Management and Azure API Center provide API portal experiences for developers. [Compare the portals](#api-management-and-api-center-portals).

[!INCLUDE [api-center-portal-prerequisites](includes/api-center-portal-prerequisites.md)]

## Configure access to the API Center portal

First, choose how you want users to access the API Center portal. You can set up Microsoft Entra ID as an identity provider or allow anonymous access.

### Option 1: Configure Microsoft Entra ID authentication for the portal (recommended)

[!INCLUDE [api-center-portal-app-registration](includes/api-center-portal-app-registration.md)]

### Option 2: Allow anonymous access to the portal

To set up the API Center portal with anonymous access enabled, follow these steps.

> [!CAUTION]
> If you configure anonymous access, anyone can view the APIs in your API center without signing in. Don't expose sensitive information in API definitions or settings.

1. In the [Azure portal](https://portal.azure.com), go to your API center.
1. In the sidebar menu, select **API Center portal** > **Settings**.
1. On the **Access** tab, select **Allow anonymous access**.

    :::image type="content" source="media/set-up-api-center-portal/configure-access-anonymous.png" alt-text="Screenshot showing configuration of anonymous access in the portal.":::
1. To configure access, select **Confirm and Enable**.

## View the portal

After configuring access, go to the API Center portal in your browser.

* On the portal's **Settings** page, select **View API Center portal** to open the portal in a new tab. 
* Or, enter the following URL in your browser, replacing `<service-name>` and `<location>` with the name of your API center and the location where it's deployed:<br/>
    `https://<service-name>.portal.<location>.azure-apicenter.ms`

By default, the portal home page is reachable publicly. If Microsoft Entra ID is configured for access, a **Sign-in** page appears in the portal, and users must sign in to access APIs. See [Enable sign-in to portal by Microsoft Entra users and groups](#enable-sign-in-to-portal-by-microsoft-entra-users-and-groups) for details on how to configure user access to the portal.

## Enable sign-in to portal by Microsoft Entra users and groups 

[!INCLUDE [api-center-portal-user-sign-in](includes/api-center-portal-user-sign-in.md)]

## Customize the API Center portal

The following sections show you how to customize the API Center portal experience for users. For more extensive customization, you can also choose to [self-host the API Center portal](self-host-api-center-portal.md).

> [!IMPORTANT]
> Select **Save + publish** on the API Center portal's **Settings** page each time that you make changes to the settings. Until you publish, your changes aren't visible in the API Center portal.
> :::image type="content" source="media/set-up-api-center-portal/save-and-publish.png" alt-text="Screenshot of Save + Publish button in the Azure portal.":::

### Site profile

On the **Site profile** tab of the API Center portal settings, optionally provide a custom name that appears in the top bar of the published portal.

:::image type="content" source="media/set-up-api-center-portal/custom-name.png" alt-text="Screenshot of custom name in API Center portal.":::

### API visibility

On the **Visibility** tab, control which APIs are discoverable (visible) to API Center portal users. Visibility settings apply to all users of the API Center portal.

> [!NOTE]
> The API Center portal uses the [Azure API Center data plane API](/rest/api/dataplane/apicenter/operation-groups) to retrieve and display APIs in your API center, and by default shows all APIs for users with access. 
> 

To make only specific APIs visible, add filter conditions for APIs based on built-in properties. For example, choose to display APIs only of certain types, like REST or GraphQL, or based on certain specification formats, such as OpenAPI.

:::image type="content" source="media/set-up-api-center-portal/add-visibility-condition.png" alt-text="Screenshot of adding API visibility conditions in the portal.":::

### Semantic search

If you enable semantic search on the **Semantic search** tab, the API Center portal supplements basic name-based API search with AI-assisted *semantic search* built on API names, descriptions, and optionally custom metadata. Semantic search is available in the **Standard** plan only.

Users can search for APIs by using natural language queries, making it easier to find APIs based on their intent. For example, if a developer searches for "I need an API for inventory management," the portal can suggest relevant APIs, even if the API names or descriptions don't include those exact words.

> [!TIP]
> When using the **Free** plan of Azure API Center, you can [upgrade](frequently-asked-questions.yml#how-do-i-upgrade-my-api-center-from-the-free-plan-to-the-standard-plan) to the **Standard** plan to enable full service features including semantic search in the API Center portal.

To use AI-assisted search when signed in to the API Center portal, select the search box, choose **Search with AI**, and enter a query.

:::image type="content" source="media/set-up-api-center-portal/semantic-search.png" alt-text="Screenshot of semantic search results in API Center portal.":::

### Custom metadata

On the **Metadata** tab, optionally select [custom metadata](metadata.md) properties that you want to expose in API details and semantic search.

## Enable access to test console for APIs

You can configure user settings to granularly authorize access to APIs and their specific versions in your API center. For example, configure certain API versions to use API keys for authentication, and create an access policy that permits only specific users to authenticate by using those keys. 

Access policies also apply to the "Try this API" capability for APIs in the API Center portal, ensuring that only portal users with the appropriate access policy can use the test console for those API versions. [Learn more about authorizing access to APIs](authorize-api-access.md).

[!INCLUDE [api-center-portal-compare-apim-dev-portal](includes/api-center-portal-compare-apim-dev-portal.md)]

## Related content

* [Enable and view Azure API Center portal in Visual Studio Code](enable-api-center-portal-vs-code-extension.md)
* [Self-host the API Center portal](self-host-api-center-portal.md)
