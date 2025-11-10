---
title: Deploying Python Azure Functions
description: Understand how to build and deploy your Python code projects to Azure Functions.
ms.topic: article
ms.date: 08/19/2025
ms.devlang: python
ms.custom:
  - devx-track-python
  - devdivchpfy22
  - ignite-2024
  - build-2025
---

# Deploying Python Azure Functions

Azure Functions supports multiple build and deployment options for Python apps. Choose your 
deployment method based on your build environment, dependency needs, and runtime 
requirements.
>  **Recommended for most apps:** Remote build using `func azure functionapp publish`.


## Quick Comparison

| Deployment Type                    | Where dependencies are installed             | Typical Use Case                            |
|------------------------------------|----------------------------------------------|---------------------------------------------|
| Remote Build                       | Azure (App Service)                          | Default, recommended for most users         |
| Local Build                        | Your machine                                 | Linux/macOS devs, limited Windows scenarios |
| Zip Deploy (Prebuilt Dependencies) | Already packaged locally                     | CI/CD pipelines, custom prebuilds           |
| Portal Creation                    | External dependencies are NOT supported      | Editing without third-party dependencies    |
| Custom Dependencies                | Handled via extra index URL or local install | Non-PyPI dependencies                       |
| Custom Container                   | Fully self-managed image                     | Native libraries, full control              |
| CI / CD                            | Automated in pipelines                       | Enterprise deployments                      |

## Remote Build (Recommended)
Remote build installs your dependencies on the Azure platform, ensuring compatibility with the 
runtime environment. This process results in a smaller deployment package.
```bash
func azure functionapp publish <APP_NAME>
```
Remote build is the default for:
- Azure Functions Core Tools
- Visual Studio Code publish actions

Remote build also supports custom package indexes via `PIP_EXTRA_INDEX_URL`.

## Local Build
Local build installs dependencies on your machine, then deploys the entire app, including 
dependencies. Using local build results in a larger package upload.
```bash
func azure functionapp publish <APP_NAME> --build local
```
Use local build when:
- You’re developing on Linux/macOS.
- Remote build is unavailable or restricted.
> This is not recommended on Windows, as the local environment may differ from Azure's Linux runtime.

## Zip Deploy (Prebuilt Dependencies)
You can zip your app directory (with dependencies already installed) and deploy it using 
Zip Deploy or `az functionapp deployment source config-zip`.

Prepare your package:
```bash
pip install --target="./.python_packages/lib/site-packages" -r requirements.txt
```

Deploy with:
```bash
func azure functionapp publish <APP_NAME> --no-build
```

## Portal Creation
You can instantly create and test a basic Azure Function directly within the Azure portal, which saves setup time 
and is useful for quick experiments or demos. To learn more, follow the [Getting Started in the Azure portal Guide](./functions-create-function-app-portal.md).

> Portal editing does not support third-party dependencies. You can't install or reference packages outside `azure-functions` 
and the built-in Python standard library.

## Custom Dependencies (Non-PyPI, Local, Wheels)
Azure Functions supports non-PyPI dependencies in two ways:

### Remote Build with Extra Index URL
If your private packages are available online, set the `PIP_EXTRA_INDEX_URL` app setting:
```bash
az functionapp config appsettings set \
  --name <APP_NAME> \
  --resource-group <RESOURCE_GROUP> \
  --settings PIP_EXTRA_INDEX_URL=https://your-private-feed.example.com/simple
```
Azure’s remote build uses this feed during deployment.

### Local Packages or Wheels
If dependencies are only available locally:
1. Include them in your `requirements.txt` file:
```text
# Installing a wheel
<my_package_wheel>.whl

# Installing a local package
path/to/my/package
```
2. Install them in your project:
```bash
pip install --target="./.python_packages/lib/site-packages" -r requirements.txt
```
3. Deploy using the `--no-build` option:
```bash
func azure functionapp publish <APP_NAME> --no-build
```

## Custom Containers
Build and deploy your app as a Docker image when you need:
- Native OS-level dependencies
- Full control of the runtime
- Preconfigured language versions

Learn more: [Deploy with a custom container](./functions-how-to-custom-container.md)

## CI / CD Pipelines
You can automate deployments using:
- GitHub Actions
- Azure Pipelines
- Other CI / CD tools

Your pipeline can:
- Run local builds
- Deploy with `--no-build` if prebuilding dependencies
- Publish to Azure using managed identity
Learn more: [Continuous delivery with Azure Pipelines](./functions-how-to-azure-devops.md)


