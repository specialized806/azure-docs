---
title: Register a client application in Microsoft Entra ID for the Azure Health Data Services
description: How to register a client application in the Microsoft Entra ID and add a secret and API permissions to the Azure Health Data Services
author: chachachachami
ms.service: azure-health-data-services
ms.subservice: fhir
ms.topic: tutorial
ms.date: 03/16/2026
ms.author: chrupa
ms.reviewer: v-catheribun
ms.custom: sfi-image-blocked
---

# Register a client application in Microsoft Entra ID

In this article, you learn how to register a client application in Microsoft Entra ID to access Azure Health Data Services. For more information, see [Register an application with the Microsoft identity platform](../active-directory/develop/quickstart-register-app.md).

## Register a new application

1. In the [Azure portal](https://portal.azure.com), select **Microsoft Entra ID**.
2. Select **App registrations**.
    :::image type="content" source="media/register-application-new-app-registration.png" alt-text="Screen shot of new app registration window." lightbox="media/register-application-new-app-registration.png":::

3. Select **New registration**.
4. For Supported account types, select **Accounts in this organization directory only**. Don't change the other options.
   :::image type="content" source="media/register-application-account-types.png" alt-text="Screenshot of new registration account options." lightbox="media/register-application-account-types.png":::

5. Select **Register**.

## Application ID (client ID)

After registering a new application, you can find the application (client) ID and Directory (tenant) ID in the **Overview** menu option. Make a note of the values for use later.

:::image type="content" source="media/register-application-app-overview.png" alt-text="Screenshot of client ID overview panel." lightbox="media/register-application-app-overview.png":::


## Authentication setting: confidential vs. public

Select **Authentication** and the **Settings** tab to review the settings. The default value for **Allow public client flows** is **Disabled**.

If you keep this default value, the application registration is a **confidential client application** and requires a certificate or secret.

:::image type="content" source="media/register-application-allow-public-client-flows.png" alt-text="Screenshot of confidential client application."::: ](media/register-application-allow-public-client-flows.png#lightbox)


If you enable the **Allow public client flows** option, the application registration is a public client application and doesn't require a certificate or secret. Public client applications are useful when you want to use the OAuth 2.0 authorization protocol or features as described in [Public client and confidential client applications](/entra/identity-platform/msal-client-applications#when-should-you-enable-a-public-client-flow-in-your-app-registration).

For tools that require a redirect URI, such as [OAuth 2.0](/entra/identity-platform/v2-app-types), go to the **Redirect URI configuration** tab and select **Add Redirect URI** to configure the platform.

:::image type="content" source="media/register-application-select-platform.png" alt-text="Screenshot of select a platform." lightbox="media/register-application-select-platform.png":::


For example, when you choose **Mobile and desktop applications**, you select the redirect URI for that platform.

:::image type="content" source="media/register-application-add-redirect-uri-mobile-desktop-platform.png" alt-text="Screenshot of configure other platform." lightbox="media/register-application-add-redirect-uri-mobile-desktop-platform.png":::




## Certificates and secrets

To create a new client secret, use the following steps.

1. Go to **Certificates & Secrets** > **Client secrets**.
1. Select **New Client Secret**. 
1. In **Add a client secret**, enter a **Description**.
1. Accept the recommended 180-day value in the **Expires** field, or select a different value from the list.
1. Select **Add**.
    :::image type="content" source="media/register-application-new-client-secret.png" alt-text="Screenshot of certificates and secrets." lightbox="media/register-application-new-client-secret.png":::

1. Copy the secret value by selecting the copy button next to the **Value**.
    :::image type="content" source="media/register-application-copy-client-secret.png" alt-text="Screenshot of copy client secret." lightbox="media/register-application-copy-client-secret.png":::


>[!NOTE]
>It's important that you save the secret value, not the secret ID.


Optionally, you can upload a certificate (public key) and use the Certificate ID, a GUID value associated with the certificate. For testing purposes, you can create a self-signed certificate by using tools such as the PowerShell command `New-SelfSignedCertificate`, and then export the certificate from the certificate store. For more information, see [Create a self-signed public certificate to authenticate your application](/entra/identity-platform/howto-create-self-signed-certificate)  

## API permissions

The following steps are required for the DICOM service, but optional for the FHIR service. In addition, you manage user access permissions or role assignments for Azure Health Data Services through RBAC. For more information, see [Configure Azure RBAC for Azure Health Data Services](configure-azure-rbac.md).

1. Select **API permissions**.

   :::image type="content" source="dicom/media/dicom-add-apis-permissions.png" alt-text="Screenshot of API permission page with Add a permission button highlighted." lightbox="dicom/media/dicom-add-apis-permissions.png":::

2. Select **Add a permission**.

   If you're using Azure Health Data Services, add a permission to the DICOM service by searching for **Azure API for DICOM** under **APIs my organization** uses. 

   :::image type="content" source="dicom/media/dicom-search-apis-permissions.png" alt-text="Screenshot of Search API permissions page with the APIs my organization uses tab selected." lightbox="dicom/media/dicom-search-apis-permissions.png":::

   The search result for Azure API for DICOM appears only if you already deployed the DICOM service in the workspace.

   If you're referencing a different resource application, select your DICOM API Resource Application Registration that you created previously under **APIs my organization**.

3. Select scopes (permissions) that the confidential client application asks for on behalf of a user. Select **Dicom.ReadWrite**, and then select **Add permissions**.

   :::image type="content" source="dicom/media/dicom-select-scope.png" alt-text="Screenshot of scopes (permissions) that the client application will ask for on behalf of a user." lightbox="dicom/media/dicom-select-scope.png":::

>[!NOTE]
>Use `grant_type` of `client_credentials` when getting an access token for the FHIR service by using tools such as REST Client. For more information, see [Accessing Azure Health Data Services using the REST Client Extension in Visual Studio Code](./fhir/using-rest-client.md).
>>Use `grant_type` of `client_credentials` or `authentication_code` when getting an access token for the DICOM service. For more information, see [Using DICOM with cURL](dicom/dicomweb-standard-apis-curl.md).

## Next steps

>[!NEXT STEPS]
> - [Grant permissions to the client application](configure-azure-rbac.md)
> - [Access Azure Health Data Services](access-healthcare-apis.md)