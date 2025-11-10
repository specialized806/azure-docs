---
title: Deploy your Python apps to Azure Functions
description: Understand how to build and deploy your Python code projects to Azure Functions.
ms.topic: how-to
ms.date: 11/10/2025
ms.devlang: python
ms.custom: 
  - py-devguide-refactor
---

# Deploy your Python apps to Azure Functions

Azure Functions supports several build and deployment options for publishing your Python apps to Azure. Choose your deployment method based on your build environment, app dependencies, and runtime requirements. 

## Quick comparison

| Deployment type                    | Where dependencies are installed             | Typical use case                            |
|------------------------------------|----------------------------------------------|---------------------------------------------|
| [Remote build](#remote-build) (recommended)         | Azure (App Service)                          | Default, recommended for most users         |
| [Local build](#local-build)                        | Your machine                                 | Linux/macOS devs, limited Windows scenarios |
| [Zip deploy with prebuilt dependencies](#zip-deploy) | Already packaged locally                  | Pipelines, GitHub Actions, custom prebuilds           |
| [Portal create](#portal-create)                    | External dependencies aren't supported       | Editing without third-party dependencies    |
| [Custom dependencies](#custom-dependencies)                | Handled via extra index URL or local install | Non-PyPI dependencies                       |
| [Custom containers](#custom-containers)                  | Fully self-managed image                     | Native libraries, when full control is required   |
| [Continuous](./functions-continuous-deployment.md)             | Automated in pipelines                       | Enterprise deployments                      |

The rest of this article details deployment options for your Python apps. For a general overview of deployment, see [Deployment technologies in Azure Functions](functions-deployment-technologies.md).

## Remote Build 

> Remote build is the recommended approach for a code-only deployment of your Python app to Functions.

When you choose a remote build, package dependencies are installed in Azure by Functions. This ensures compatibility with the remote 
runtime environment and results in a smaller deployment package.

Remote build is used by default when you publish your Python app using these tools: 

- [**Azure Functions Core Tools**](./functions-run-local.md): the [`func azure functionapp publish`](./functions-core-tools-reference.md#func-azure-functionapp-publish) requests a remote build by default when publishing Python apps. 

- [**Visual Studio Code**](./functions-develop-vs-code.md): the **Azure Functions: Deploy to Azure...** command always uses a remote build.

Remote build also supports custom package indexes when by using the [`PIP_EXTRA_INDEX_URL`](./functions-app-settings.md#pip_extra_index_url) app setting. For more information, see [Remote build](functions-deployment-technologies.md#remote-build).

## Local build

If you don't request a remote build, then dependencies are instead installed on your machine. The entire local project and dependencies are then packaged locally and deployed to your function app. Using local build results in a larger package upload. 


```bash
func azure functionapp publish <APP_NAME> --build local
```
Use local build when:

- You're developing locally on Linux or macOS.
- Remote build isn't available or is restricted.

>[!IMPORTANT]  
>When developing your Python apps on a Windows computer, don't use local build. Packages built on a Windows computer often have issues being deployed to and running on Linux in Azure Functions. 

## Zip deploy 

Zip deployment is the method for publishing your code to Azure. You can create a compressed package (.zip) of your app directory, with dependencies already installed, and deploy it by using deployment APIs. 

To create and deploy your app by using zip deployment:

1. Run this `pip` command to install required dependencies in the local `site-packages` folder:

    ```bash
    pip install --target="./.python_packages/lib/site-packages" -r requirements.txt
    ```

    >[!IMPORTANT]  
    >When developing your Python apps on a Windows computer, don't build your deployment package by using locally installed dependencies. Packages built on a Windows computer often have issues being deployed to and running on Linux in Azure Functions.     

1. Run the `func pack` command from the project root to create the deployment package based on the local project folder: 

    ```bash
    func pack
    ```

1. Deploy the package by using [`az functionapp deployment source config-zip`](/cli/azure/functionapp/deployment/source#az-functionapp-deployment-source-config-zip) command, which initiates a [push deployment](./deployment-zip-push.md):

    ```azure-cli 
    az functionapp deployment source config-zip --src <ZIP_FILE_PATH>
    ```

You can also package and deploy prebuilt dependencies in one step by using the `--no-build` option in Core Tools:

```bash
func azure functionapp publish <APP_NAME> --no-build
```

## Portal create

You can create and test a basic function directly within the [Azure portal](https://portal.azure.com), which saves setup time and is useful for quick experiments or demos. To learn more, follow the [Getting Started in the Azure portal Guide](./functions-create-function-app-portal.md).

> [!NOTE]  
> Portal editing doesn't support third-party dependencies, and it isn't recommended for creating production apps. You can't install or reference packages outside `azure-functions` and the built-in Python standard library.

## Custom dependencies 

Azure Functions supports custom and other non-PyPI dependencies by using the [`PIP_EXTRA_INDEX_URL`] app setting or by creating a local build on a Linux or macOS computer.

### Remote build with an extra index URL

When your private packages are available online, you can request a remote build after setting the private package location by using the [`PIP_EXTRA_INDEX_URL`] app setting. Use this [`az functionapp config appsettings set`](/cli/azure/functionapp/config/appsettings#az-functionapp-config-appsettings-set) command to set a remote package URL:

```azure-cli
az functionapp config appsettings set \
  --name <APP_NAME> \
  --resource-group <RESOURCE_GROUP> \
  --settings PIP_EXTRA_INDEX_URL=https://your-private-feed.contoso.com/simple
```
When you set [`PIP_EXTRA_INDEX_URL`], remote builds use this package feed during deployment.

### Local packages or wheels

Use these steps on a Linux or macOS computer when your dependencies are only available locally:

1. Set the dependencies in your `requirements.txt` file, which might look like this:

    ```text
    # Installing a custom wheel
    <my_package_wheel>.whl
    
    # Installing a local package
    path/to/my/package
    ```

1. Run this `pip` command to install custom packages in your local project:

    ```bash
    pip install --target="./.python_packages/lib/site-packages" -r requirements.txt
    ```

1. Build and publish the deployment package by using the `--no-build` option in Core Tools:

    ```bash
    func azure functionapp publish <APP_NAME> --no-build
    ```

## Custom containers

Create and deploy your Python app in a custom container when you need:

- Native operating system-level dependencies
- Full control of the runtime environment
- Preconfigured language versions

For more information, see [Deploy with a custom container](./functions-how-to-custom-container.md).

## Continuous publishing 

Automate deployment of your app by using these continuous technologies:

- [GitHub Actions](./functions-how-to-github-actions.md)
- [Azure Pipelines](./functions-how-to-azure-devops.md)
- [Other continuous integration tools](./functions-continuous-deployment.md)

Your deployment pipeline can:

- Run local builds.
- Deploy with `--no-build` when using prebuilt dependencies.
- Deploy to Azure by using managed identities.

For more information, see [Continuous delivery with Azure Pipelines](./functions-how-to-azure-devops.md).

## Related articles

- [Azure Functions Developer Reference Guide (Python)](functions-reference-python.md)
- [Deployment technologies in Azure Functions](functions-deployment-technologies.md)

[`PIP_EXTRA_INDEX_URL`]: ./functions-app-settings.md#pip_extra_index_url