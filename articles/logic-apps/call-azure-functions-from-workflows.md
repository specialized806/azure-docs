---
title: Call Azure Functions from Workflows
description: Learn how to call and run Azure Functions from workflows in Azure Logic Apps. Extend workflows with custom code, advanced computations, and dynamic data processing.
services: logic-apps, azure-functions
ms.suite: integration
ms.reviewer: estfan, azla
ms.topic: how-to
ai.usage: ai-assisted
ms.date: 02/25/2026
ms.custom: sfi-image-nochange
#Customer intent: As an integration developer who works with Azure Logic Apps, I want to call and run functions created in Azure Functions from my logic app workflows.
---

# Call Azure Functions from workflows in Azure Logic Apps

[!INCLUDE [logic-apps-sku-consumption-standard](../../includes/logic-apps-sku-consumption-standard.md)]

Azure Logic Apps and Azure Functions work together so that you can extend and enhance your integration workflows with custom code execution, advanced computations, and dynamic data processing. When you create functions in Azure Functions, you can call and run these functions from your workflows. The Azure Functions platform lets you run code without building a complete app or setting up separate infrastructure and provides cloud-based computing that can perform tasks such as the following examples:

- Extend your workflow's behavior by running functions created by using C# or Node.js.
- Perform calculations in your workflow.
- Apply advanced formatting or compute fields in your workflow.

This guide shows how to call and run a function in Azure Functions from your workflow, whether you're using the Consumption or Standard plan. You'll also learn about prerequisites, limitations, and tips for working with Azure Functions to ensure seamless integration and optimal performance. For more information, see [Azure Functions](../azure-functions/functions-overview.md) and [Azure Logic Apps](logic-apps-overview.md).

> [!NOTE]
>
> If you want to run code without using Azure Functions, see:
>
> - [Run code snippets in workflows](logic-apps-add-run-inline-code.md)
> - [Create and run .NET Framework code from Standard workflows](create-run-custom-code-functions.md)

## Limitations

For Azure Functions to operate correctly in your workflow, the following limitations apply:

- Function app resources must use either the .NET or Node.js runtime stack.

- Functions must use either C# or JavaScript code.

- Functions must use the **HTTP trigger** template.

  The **HTTP trigger** template can accept and handle content with the `application/json` type as input from your workflow. When you add an Azure function to your workflow, the workflow designer shows any available custom functions created with this template in your Azure subscription.

- Functions can't use custom routes unless they also have corresponding [OpenAPI definitions](../azure-functions/functions-openapi-definition.md).

  If your function has an OpenAPI definition, the workflow designer gives you a richer experience when you work with function parameters. Before your workflow can find and access functions that have OpenAPI definitions, [set up your function app with these steps](#open-ai-definition).

- For Azure function call authentication, only Consumption workflows currently support managed identity authentication with Microsoft Entra. For more information, see [how to enable authentication for Azure function calls](#enable-authentication-functions). 

  Standard workflows currently don't support managed identity authentication.

- Azure Logic Apps doesn't support using Azure Functions with deployment slots enabled.

  Although this scenario might sometimes work, this behavior is unpredictable and might result in authorization problems when your workflow tries call the Azure function.

## Prerequisites

- Azure account and subscription. [Get a free Azure account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).

- An [Azure function app resource](../azure-functions/functions-get-started.md), which can contain one or more Azure functions.

  Make sure to use the same Azure subscription for your function app resource and logic app resource.

- The Azure function to call from your workflow.

  - To create this function, use any of the following tools:

    - [Azure portal](../azure-functions/functions-create-function-app-portal.md)
    - [Visual Studio](../azure-functions/functions-create-your-first-function-visual-studio.md)
    - [Visual Studio Code](../azure-functions/how-to-create-function-vs-code.md?pivot=programming-language-csharp)
    - [Azure CLI](/cli/azure/functionapp/app)
    - [Azure PowerShell](/powershell/module/az.functions)
    - [ARM template](/azure/templates/microsoft.web/sites/functions)

  - Your function code must include the response and payload that you want returned to your workflow after the function completes.

    This guide uses the following sample function named **FabrikamAzureFunction**. The `context` object in this sample function refers to the message that your workflow sends through the Azure Functions action parameter named **Request Body** and is later explained in this guide:

    ```javascript
    module.exports = function (context, data) {

       var input = data;

       // Function processing logic
       // Function response for later use
       context.res = {
          body: {
            content:"Thank you for your feedback: " + input
          }
       };
       context.done();
    }
    ```

    To access the `context` object's properties from inside your function, use the following syntax:

    `context.body.<property-name>`

    For example, to reference the `content` property in the `context` object, use the following syntax:

    `context.body.content`

    This code also includes an `input` variable, which stores the value from the `data` parameter so that your function can perform operations on that value. Inside JavaScript functions, the `data` variable is also a shortcut for `context.body`.

    > [!NOTE]
    >
    > The `body` property mentioned here applies to the `context` object and differs from the **Body** value in an action's output, which you might also pass to your function.

- A Consumption or Standard logic app workflow that starts with any trigger.

  The examples in this guide use the Office 365 Outlook trigger named **When a new email arrives**.

- To create and call an Azure function that calls another workflow, make sure that secondary workflow starts with a trigger that provides a callable endpoint.

  For example, you can start the workflow with the general **HTTP** or **Request** trigger, or you can use a service-based trigger, such as **Azure Queues** or **Event Grid**. Inside your function, send an HTTP POST request to the trigger's URL and include the payload that you want your secondary workflow to process. For more information, see [Call, trigger, or nest logic app workflows](logic-apps-http-endpoint.md).

## Tips for working with Azure functions

<a name="open-ai-definition"></a>

### Find functions with OpenAPI definitions

To set up your function app so that your workflow can find and use functions that have OpenAPI definitions, follow these steps:

1. In the [Azure portal](https://portal.azure.com), open your function app. Make sure that the function app is actively running.

1. On your function app, set up [Cross-Origin Resource Sharing (CORS)](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing) so that all origins are permitted by following these steps:

   1. On the function app sidebar, under **API**, select **CORS**.

   1. Under **Allowed Origins**, add the asterisk (*) wildcard character, but remove any and all other origins in the list, and select **Save**.

      :::image type="content" source="media/call-azure-functions-from-workflows/function-cors-origins.png" alt-text="Screenshot shows Azure portal, CORS pane, and the * wildcard character entered under Allowed Origins." lightbox="media/call-azure-functions-from-workflows/function-cors-origins.png":::

### Access the property values in HTTPS requests

Webhook-based functions can accept HTTPS requests as inputs and pass these requests to other functions.

For example, although Azure Logic Apps has [functions that convert DateTime values](workflow-definition-language-functions-reference.md), the following basic sample JavaScript function shows how you can access a property in a request object that passes to the function and perform operations on that property value.

To access properties in objects, this example uses the [dot (.) operator](https://developer.mozilla.org/docs/Web/JavaScript/Reference/Operators/Property_accessors):

```javascript
function convertToDateString(request, response){
   var data = request.body;
   response = {
      body: data.date.ToDateString();
   }
}
```

The following steps describe what happens in this function:

1. The function creates a `data` variable and assigns the `body` object, which is in the `request` object, to the variable. To reference the `body` object in the `request` object, the function uses the dot (**.**) operator:

   ```javascript
   var data = request.body;
   ```

1. The function can now access the `date` property through the `data` variable.

   The function converts the property value from **DateTime** type to **DateString** type by calling the `ToDateString()` function. The function returns the result through the `body` property in the function's response:

   ```javascript
   body: data.date.ToDateString();
   ```

1. After you create your function in Azure Functions, follow the [steps to add an Azure function to your workflow](#add-function-logic-app).

### Pass URI parameters to a function

If you have to pass a URI parameter to your function, you can use query parameters in the function's endpoint URL.

1. In the workflow designer with the function information pane open, from the **Advanced parameters** list, select **Queries**.

   A table appears where you can enter parameter input as key-value pairs.

1. Enter the key-value pair for your parameter, for example:

   :::image type="content" source="media/call-azure-functions-from-workflows/queries-parameter.png" alt-text="Screenshot shows function information pane with Queries parameter and example key-value inputs.":::

<a name="add-function-logic-app"></a>

## Add a function to your workflow (Consumption + Standard workflows)

To call an Azure function from your workflow, add that function like any other action in the workflow designer.

### [Consumption](#tab/consumption)

1. In the [Azure portal](https://portal.azure.com), open your Consumption logic app resource. Open the workflow in the designer.

1. In the designer, follow the [general steps](create-workflow-with-trigger-or-action.md?tabs=consumption#add-action) to add the **Azure Functions** action named **Choose an Azure function**.

1. In the **Add an action** pane, follow these steps:

   1. From the function apps list, select your function app.

   1. Select the function, and then select **Add action**, for example:

      :::image type="content" source="media/call-azure-functions-from-workflows/select-function-app-function-consumption.png" alt-text="Screenshot shows the Consumption workflow designer with a selected function app and function.":::

1. After the function's information box appears, follow these steps:

   1. For **Request Body**, enter your function's input, which must use the format for a JavaScript Object Notation (JSON) object, for example:

      `{"context": <selected-input> }`

      This input is the *context object* payload or message that your workflow sends to your function.

      - To select output values from previous steps in the workflow, select inside the **Request Body** box, and then select the option that opens the dynamic content list (lightning icon).

      - To create an expression, select inside the **Request Body** box, and then select the option that opens the expression editor (function icon).

      The following example specifies a JSON object with the `content` attribute and the **From** output value from the email trigger as the **Request Body** value:

      :::image type="content" source="media/call-azure-functions-from-workflows/function-request-body-example-consumption.png" alt-text="Screenshot shows a Consumption workflow and a function with a Request Body example for the context object payload.":::

      In this case, the context object isn't cast as a string. The object's content is directly added to the JSON payload. The following image shows the finished example:

      :::image type="content" source="media/call-azure-functions-from-workflows/request-body-example-complete.png" alt-text="Screenshot shows Consumption workflow and a function with a complete Request Body example for the context object payload.":::

      If you enter a context object other than a JSON token that passes a string, a JSON object, or a JSON array, you get an error. However, you can cast the context object as a string by enclosing the token in quotation marks (" "), for example, if you wanted to use the **Received Time** output value:

      :::image type="content" source="media/call-azure-functions-from-workflows/function-request-body-string-cast-example.png" alt-text="Screenshot shows a Consumption workflow and a Request Body example that casts context object as a string.":::

   1. To enter other information such as the method to use, request headers, query parameters, or authentication, open the **Advanced parameters** list, and select the parameters you want.
   
      For authentication, your options differ based on your selected function. For more information, see [Enable authentication for functions](#enable-authentication-functions).

### [Standard](#tab/standard)

1. In the [Azure portal](https://portal.azure.com), open your Standard logic app resource. Open the workflow you want in the designer.

1. In the designer, follow the [general steps](create-workflow-with-trigger-or-action.md?tabs=standard#add-action) to add the **Azure Functions** action named **Call an Azure function**.

1. After the **Create connection** pane opens, follow these steps:

   1. Enter a **Connection Name** for the connection to your function app.

   1. From the function apps list, select your function app.

   1. Select the function, and then select **Create new**, for example:

      :::image type="content" source="media/call-azure-functions-from-workflows/select-function-app-function-standard.png" alt-text="Screenshot shows the Standard workflow designer with selected function app and function.":::

1. After the function's information box appears, follow these steps:

   1. From the **Method** list, select the HTTP method required to call the selected function.

   1. For **Request body**, enter your function's input, which must use the format for a JavaScript Object Notation (JSON) object, for example:

      `{"context": <selected-input> }`

      This input is the *context object* payload or message that your workflow sends to your function.

      - To select output values from previous steps in the workflow, select inside the **Request body** box, and then select the option that opens the dynamic content list (lightning icon).

      - To create an expression, select inside the **Request body** box, and then select the option that opens the expression editor (function icon).

      The following example specifies a JSON object with the `content` attribute and the **From** output value from the email trigger as the **Request body** value:

      :::image type="content" source="media/call-azure-functions-from-workflows/function-request-body-example-standard.png" alt-text="Screenshot shows a Standard workflow and a function with a Request body example for the context object payload.":::

      In this case, the context object isn't cast as a string. The object's content is directly added to the JSON payload. The following image shows the finished example:

      :::image type="content" source="media/call-azure-functions-from-workflows/request-body-example-complete.png" alt-text="Screenshot shows a Standard workflow and a function with a complete Request body example for the context object payload.":::

      If you provide a context object other than a JSON token that passes a string, a JSON object, or a JSON array, you get an error. However, you can cast the context object as a string by enclosing the token in quotation marks (**""**), for example, if you wanted to use the **Received Time** token:

      :::image type="content" source="media/call-azure-functions-from-workflows/function-request-body-string-cast-example.png" alt-text="Screenshot shows Standard workflow and a Request Body example that casts context object as a string.":::

   1. To specify other details such as the method to use, request headers, query parameters, or authentication, open the **Advanced parameters** list, and select the parameters that you want. For authentication, your options differ based on your selected function. For more information, review [Enable authentication for functions](#enable-authentication-functions).

---

<a name="enable-authentication-functions"></a>

## Enable authentication for Azure function calls (Consumption workflows only)

Your Consumption workflow can use a [managed identity](../active-directory/managed-identities-azure-resources/overview.md) to authenticate an Azure function call and access resources protected by Microsoft Entra ID. The managed identity can authenticate access without you having to sign in and provide credentials or secrets. Azure manages this identity for you and helps secure your credentials because you don't have to provide or rotate secrets. You can set up the system-assigned identity or a manually created, user-assigned identity at the logic app resource level. The Azure function that's called from your workflow can use the same managed identity for authentication.

> [!NOTE]
> 
> Only Consumption workflows support authentication for an Azure function call using 
> a managed identity and Microsoft Entra authentication. Standard workflows currently 
> don't include this support when you use the action to call an Azure function.

For more information, see the following documentation:

* [Authenticate access with managed identities](create-managed-service-identity.md)
* [Add authentication to outbound calls](logic-apps-securing-a-logic-app.md#add-authentication-outbound)

To set up your function app and function so they can use your Consumption logic app's managed identity, follow these high-level steps:

1. [Enable and set up your logic app's managed identity](create-managed-service-identity.md).

1. [Set up your function for anonymous authentication](#set-authentication-function-app).

1. [Find the required values to set up Microsoft Entra authentication](#find-required-values).

1. [Create an app registration for your function app](#create-app-registration).

<a name="set-authentication-function-app"></a>

### Set up your function for anonymous authentication (Consumption workflows only)

For your function to use your Consumption logic app's managed identity, you must set your function's authentication level to **`anonymous`**. Otherwise, your workflow throws a **BadRequest** error.

1. In the [Azure portal](https://portal.azure.com), find and select your function app.

   The following steps use an example function app named **FabrikamFunctionApp**.

1. On the function app resource menu, under **Development tools**, select **Advanced Tools** > **Go**.

   :::image type="content" source="media/call-azure-functions-from-workflows/open-advanced-tools-kudu.png" alt-text="Screenshot shows function app menu with selected options for Advanced Tools and Go." lightbox="media/call-azure-functions-from-workflows/open-advanced-tools-kudu.png":::

1. After the **Kudu Plus** page opens, on the Kudu website's title bar, from the **Debug Console** menu, select **CMD**.

   :::image type="content" source="media/call-azure-functions-from-workflows/open-debug-console-kudu.png" alt-text="Screenshot shows Kudu Services page with opened Debug Console menu and selected option named CMD." lightbox="media/call-azure-functions-from-workflows/open-debug-console-kudu.png":::

1. After the next page appears, from the folder list, select **site** > **wwwroot** > *your-function*.

   The following steps use an example function named **FabrikamAzureFunction**.

   :::image type="content" source="media/call-azure-functions-from-workflows/select-site-wwwroot-function-folder.png" alt-text="Screenshot shows folder list with the opened folders for the site, wwwroot, and your function." lightbox="media/call-azure-functions-from-workflows/select-site-wwwroot-function-folder.png":::

1. Open the **function.json** file for editing.

   :::image type="content" source="media/call-azure-functions-from-workflows/edit-function-json-file.png" alt-text="Screenshot shows the function.json file with selected edit command." lightbox="media/call-azure-functions-from-workflows/edit-function-json-file.png":::

1. In the **bindings** object, check whether the **authLevel** property exists. If the property exists, set the property value to **`anonymous`**. Otherwise, add that property, and set the value.

   :::image type="content" source="media/call-azure-functions-from-workflows/set-authentication-level-function-app.png" alt-text="Screenshot shows bindings object with authLevel property set to anonymous." lightbox="media/call-azure-functions-from-workflows/set-authentication-level-function-app.png":::

1. When you're done, save your settings. Continue to the next section.

<a name="find-required-values"></a>

### Find the required values to set up Microsoft Entra authentication (Consumption workflows only)

Before you can set up your function app to use the managed identity and Microsoft Entra authentication, you need to find and save the following values by following the steps in this section.

1. [Find the tenant ID for your Microsoft Entra tenant](#find-tenant-id).

1. [Find the object ID for your managed identity](#find-object-id).

1. [Find the application ID for the Enterprise application associated with your managed identity](#find-enterprise-application-id).

<a name="find-tenant-id"></a>

#### Find the tenant ID for your Microsoft Entra tenant

Either run the PowerShell command named [**Get-AzContext**](/powershell/module/az.accounts/get-azcontext), or in the Azure portal, follow these steps:

1. In the [Azure portal](https://portal.azure.com), open your Microsoft Entra tenant.

   This guide uses **Fabrikam** as the example tenant.

1. On the tenant menu, select **Overview**.

1. Copy and save your tenant ID for later use, for example:

   :::image type="content" source="media/call-azure-functions-from-workflows/tenant-id.png" alt-text="Screenshot shows Microsoft Entra ID Properties page with tenant ID's copy button selected." lightbox="media/call-azure-functions-from-workflows/tenant-id.png":::

<a name="find-object-id"></a>

#### Find the object ID for your managed identity

After you enable the managed identity for your Consumption logic app resource, find the object for your managed identity. You'll use this ID to find the associated Enterprise application in your Microsoft Entra tenant.

1. On the logic app menu, under **Settings**, select **Identity**, and then select either **System assigned** or **User assigned**.

   - **System assigned**

     Copy the identity's **Object (principal) ID**:

     :::image type="content" source="media/call-azure-functions-from-workflows/system-identity-consumption.png" alt-text="Screenshot shows Consumption logic app's Identity page with selected tab named System assigned." lightbox="media/call-azure-functions-from-workflows/system-identity-consumption.png":::

   - **User assigned**

     1. Select the identity:

        :::image type="content" source="media/call-azure-functions-from-workflows/user-identity-consumption.png" alt-text="Screenshot shows Consumption logic app's Identity page with selected tab named User assigned." lightbox="media/call-azure-functions-from-workflows/user-identity-consumption.png":::

     1. Copy the identity's **Object (principal) ID**:

        :::image type="content" source="media/call-azure-functions-from-workflows/user-identity-object-id.png" alt-text="Screenshot shows Consumption logic app's user-assigned identity Overview page with the object (principal) ID selected." lightbox="media/call-azure-functions-from-workflows/user-identity-object-id.png":::

<a name="find-enterprise-application-id"></a>

### Find the application ID for the Azure Enterprise application associated with your managed identity

When you enable a managed identity on your logic app resource, Azure automatically creates an associated [Azure Enterprise application](/entra/identity/enterprise-apps/add-application-portal) that has the same name. You now need to find the associated Enterprise application and copy its **Application ID**. Later, you use this application ID to add an identity provider for your function app by creating an app registration.

1. In the [Azure portal](https://portal.azure.com), find and open your Microsoft Entra tenant.

1. On the tenant menu, under **Manage**, select **Enterprise applications**.

1. On the **All applications** page, in the search box, enter the object ID for your managed identity. From the results, find the matching enterprise application, and copy the **Application ID**:

   :::image type="content" source="media/call-azure-functions-from-workflows/find-enterprise-application-id.png" alt-text="Screenshot shows Microsoft Entra tenant page named All applications, with enterprise application object ID in search box, and selected matching application ID." lightbox="media/call-azure-functions-from-workflows/find-enterprise-application-id.png":::

1. Now, use the copied application ID to [add an identity provider to your function app](#create-app-registration).

<a name="create-app-registration"></a>

### Add identity provider for your function app (Consumption workflows only)

Now that you have the tenant ID and the application ID, you can set up your function app to use Microsoft Entra authentication by adding an identity provider and creating an app registration.

1. In the [Azure portal](https://portal.azure.com), open your function app.

1. On the function app menu, under **Settings**, select **Authentication**, and then select **Add identity provider**.

   :::image type="content" source="media/call-azure-functions-from-workflows/add-identity-provider.png" alt-text="Screenshot shows function app menu with Authentication page and selected option named Add identity provider." lightbox="media/call-azure-functions-from-workflows/add-identity-provider.png":::

1. On the **Add an identity provider** pane, under **Basics**, from the **Identity provider** list, select **Microsoft**.

1. Under **App registration**, for **App registration type**, select **Provide the details of an existing app registration**, and enter the values that you previously saved.

   | Property | Required | Value | Description |
   |----------|----------|-------|-------------|
   | **Application (client) ID** | Yes | <*application-ID*> | The unique identifier to use for this app registration. For this example, use the application ID that you copied for the Enterprise application associated with your managed identity. |
   | **Client secret** | Optional, but recommended | <*client-secret*> | The secret value that the app uses to prove its identity when requesting a token. The client secret is created and stored in your app's configuration as a slot-sticky [application setting](../app-service/configure-common.md#configure-app-settings) named **MICROSOFT_PROVIDER_AUTHENTICATION_SECRET**. <br><br>- Make sure to regularly rotate secrets and store them securely. For example, manage your secrets in Azure Key Vault where you can use a managed identity to retrieve the key without exposing the value to an unauthorized user. You can update this setting to use [Key Vault references](../app-service/app-service-key-vault-references.md). <br><br>- If you provide a client secret value, sign-in operations use the hybrid flow, returning both access and refresh tokens. <br><br>- If you don't provide a client secret, sign-in operations use the [OAuth 2.0 implicit grant flow](/entra/identity-platform/v2-oauth2-implicit-grant-flow). This method directly returns only an ID token or access token. These tokens are sent by the provider and stored in the EasyAuth token store. <br><br>**Important**: Due to security risks, the implicit grant flow is [no longer a suitable authentication method](/entra/identity-platform/v2-oauth2-implicit-grant-flow#prefer-the-auth-code-flow). Instead, use either [authorization code flow with Proof Key for Code Exchange (PKCE)](/entra/msal/dotnet/advanced/spa-authorization-code) or [single-page application (SPA) authorization codes](/entra/msal/dotnet/advanced/spa-authorization-code). |
   | **Issuer URL** | No | **<*authentication-endpoint-URL*>/<*Microsoft-Entra-tenant-ID*>/v2.0** | This URL redirects users to the correct Microsoft Entra tenant and downloads the appropriate metadata to determine the appropriate token signing keys and token issuer claim value. For apps that use Azure AD v1, omit **/v2.0** from the URL. <br><br>For this scenario, use the following URL: **`https://sts.windows.net/`<*Microsoft-Entra-tenant-ID*>** |
   | **Allowed token audiences** | No | <*application-ID-URI*> | The application ID URI (resource ID) for the function app. For a cloud or server app where you want to allow authentication tokens from a web app, add the application ID URI for the web app. The configured client ID is always implicitly considered as an allowed audience. <br><br>For this scenario, the value is **`https://management.azure.com`**. Later, you can use the same URI in the **Audience** property when you [set up your function action in your workflow to use the managed identity](create-managed-service-identity.md#authenticate-access-with-identity). <br><br>**Important**: The application ID URI (resource ID) must exactly match the value that Microsoft Entra ID expects, including any required trailing slashes. |

   At this point, your version looks similar to this example:

   :::image type="content" source="media/call-azure-functions-from-workflows/identity-provider-authentication-settings.png" alt-text="Screenshot shows app registration for your logic app and identity provider for your function app." lightbox="media/call-azure-functions-from-workflows/identity-provider-authentication-settings.png":::

   If you're setting up your function app with an identity provider for the first time, the **App Service authentication settings** section also appears. These options determine how your function app responds to unauthenticated requests. The default selection redirects all requests to log in with the new identity provider. You can customize this behavior now or adjust these settings later from the main **Authentication** page by selecting **Edit** next to **Authentication settings**. To learn more about these options, review [Authentication flow - Authentication and authorization in Azure App Service and Azure Functions](../app-service/overview-authentication-authorization.md#authentication-flow).

   Otherwise, you can continue with the next step.

1. To finish creating the app registration, select **Add**.

   When you're done, the **Authentication** page now lists the identity provider and the app registration's application (client) ID. Your function app can now use this app registration for authentication.

1. Copy the app registration's **App (client) ID** to use later in the Azure Functions action's **Audience** property for your workflow.

   :::image type="content" source="media/call-azure-functions-from-workflows/identity-provider-application-id.png" alt-text="Screenshot shows new identity provider for function app." lightbox="media/call-azure-functions-from-workflows/identity-provider-application-id.png":::

1. Return to the designer and follow the [steps to authenticate access with the managed identity](create-managed-service-identity.md#authenticate-access-with-identity) by using the built-in Azure Functions action.

## Next steps

* [Authentication access to Azure resources with managed identities in Azure Logic Apps](create-managed-service-identity.md#authenticate-access-with-identity)
