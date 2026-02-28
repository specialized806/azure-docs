---
title: Deploy custom container using Azure Pipelines
description: Learn how to deploy your custom Windows container app stored in Azure Repos to Azure App Service via an Azure Pipelines CI/CD pipeline.
ms.topic: how-to
ms.date: 02/27/2026
author: jefmarti
ms.author: jefmarti
ms.service: azure-app-service 
# As a developer, I want to use Azure Pipelines to deploy a Windows container app to App Service so that I can deploy my containerized apps stored in Azure Repos to App Service using CI/CD.
---

# Deploy a custom container using Azure Pipelines

This article describes how to deploy a Windows container application stored in an Azure Repos Git repository to Azure App Service using continuous integration and continuous delivery (CI/CD) via Azure Pipelines. Azure Repos and Azure Pipelines are complimentary services in the integrated Azure DevOps suite that enables you to host, build, plan, and test your code using any platform and cloud. You store the definition file for your CI/CD pipeline in the root directory of your app's repository.

## Prerequisites

- An Azure account with an Azure Container Registry registry instance and a Web App created in Azure App Service. [Create an Azure account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- An Azure DevOps organization and project with Azure Repos and Azure Pipelines activated. [Create an Azure DevOps organization for free](/azure/devops/pipelines/get-started/pipelines-sign-up). 
- A Windows app that runs in a Docker container and a supporting Dockerfile checked into an [Azure Repos](https://docs.github.com/get-started/quickstart/create-a-repo) repository in your Azure DevOps project.
- The appropriate user roles or permissions to create and manage Azure and Azure DevOps projects, pipelines, repos, and service connections. For more information, see [Manage security in Azure Pipelines](/azure/devops/pipelines/policies/permissions).

## Add a service connection

Before creating your pipeline, you must create an Azure service connection to use for connecting to your Azure Container Registry. In **Project Settings** for your Azure DevOps project, create the service connection by following the instructions at [Create a service connection](/azure/devops/pipelines/library/service-endpoints#create-a-service-connection). For this service connection, choose **Docker Registry** and then choose **Azure Container Registry** as the registry type. After you create the service connection, copy its **ID** to use in a later step.

## Create a new pipeline

Create your pipeline by following these steps:

1. In your Azure DevOps project, select **Pipelines** from the left navigation menu and then select **Create** or **Create Pipeline**.
1. On the **Where is your code** screen, select **Azure Repos Git**.
1. On the **Choose a repository** screen, select the repository that contains your app.
1. On the **Configure your pipeline** screen, select **Starter pipeline**.
1. Select the dropdown arrow next to **Save and run** at upper right, and select **Save**.

### Create variables for secrets

Create variables for your pipeline for frequently used information or to protect secure information you don't want others to access. For more information, see [Define variables](/azure/devops/pipelines/process/variables).

1. On the pipeline editing screen, select **Variables** at upper right.
1. On the **Variables** screen, select **New variable**.
1. Enter the following name/value pairs using your own information. Select **OK** after adding each variable and then select **+** to add the next variable. If the value is a secret, select the checkbox to **Keep this value secret**.

   - vmImageName: windows-latest
   - imageRepository: <repository-name>
   - dockerfilePath: $(Build.SourcesDirectory)/<folder-path>/Dockerfile>
   - dockerRegistryServiceConnection: <service-connection-ID>

1. After adding all variables, select **Save** on the **Variables** screen.
1. On the pipeline page, select **Save and run**, and then select **Save and run** again to set up builds for your pipeline.

## Build and push to Azure Container Registry

Configure the pipeline to run the steps for building the container, pushing to the registry, and deploying the image to App Service.

1. Select your pipeline from the **Pipelines** page, and then select **Edit** at upper right on the pipeline page.
1. Replace all the existing code in the *azure-pipelines.yml* file with the following code that adds the Docker task to build the image. The code calls the variables you set up earlier by using the `$(variable-name>` syntax.

```yaml
trigger:
  - main

pool:
  vmImage: 
   $(vmImageName) 

stages:
- stage: Build
  displayName: Build and push stage
  jobs:  
  - job: Build
    displayName: Build job
    pool:
      vmImage: $(vmImageName)
    steps:
    - task: Docker@2
      displayName: Build and push an image to container registry
      inputs:
        command: buildAndPush
        repository: $(imageRepository)
        dockerfile: $(dockerfilePath)
        containerRegistry: $(dockerRegistryServiceConnection)
```

## Add the App Service deploy task

Next, set up the deploy task to Azure App Service. This task requires you to enter your Azure subscription name, web app name, and container registry name. 

1. Add the deployment stage to the *azure-pipelines.yml* file by adding the following code to the end of the file.

   ```yaml
   - stage: Deploy
     displayName: Deploy to App Service
     jobs:
     - job: Deploy
       displayName: Deploy
       pool:
         vmImage: $(vmImageName)
       steps:
   ```

1. Place your cursor on a new line at the end of the file, and if necessary, select the **Show assistant** icon at right to show the **Tasks** pane. Search for and select the **Azure App Service deploy** task.
1. On the **Azure App Service deploy** form, complete the following information:

   - **Connection type**: Select **Azure Resource Manager**.
   - **Azure subscription**: Select  your Azure subscription name and ID. If necessary, select **Authorize**.
   - **App Service type**: Select **Web App for Containers (Windows)**.
   - **App Service name**: Select or enter your App Service web app name.
   - **Registry or Namespace**: Enter your Azure Container Registry instance name.
   - **Image**: Enter the repository name where your code is stored.

1. Select **Add**. The following code appends to the end of the file.

   ```yaml
   - task: AzureRmWebAppDeployment@4
     inputs:
       ConnectionType: 'AzureRM'
       azureSubscription: 'my-subscription-name'
       appType: 'webAppHyperVContainer'
       WebAppName: 'my-app-name'
       DockerNamespace: 'myregsitry.azurecr.io'
       DockerRepository: 'dotnetframework:12'
   ```

## Run the pipeline

The pipeline is now ready to run.

1. Select **Validate and save**, and select **Save** again. 
1. Select **Run**, and select **Run** again.

The pipeline goes through the steps to build and push the Windows container image to Azure Container Registry and deploy the image to App Service.

The following code shows the full *azure-pipelines.yml* pipeline definition file.

```yaml
trigger:
  - main

pool:
  vmImage: 
   $(vmImageName) 

stages:
- stage: Build
  displayName: Build and push stage
  jobs:  
  - job: Build
    displayName: Build job
    pool:
      vmImage: $(vmImageName)
    steps:
    - task: Docker@2
      displayName: Build and push an image to container registry
      inputs:
        command: buildAndPush
        repository: $(imageRepository)
        dockerfile: $(dockerfilePath)
        containerRegistry: $(dockerRegistryServiceConnection)

- stage: Deploy
  displayName: Deploy to App Service
  jobs:
  - job: Deploy
    displayName: Deploy
    pool:
      vmImage: $(vmImageName)
    steps:
    - task: AzureRmWebAppDeployment@4
      inputs:
        ConnectionType: 'AzureRM'
        azureSubscription: 'mysubscription(00000000-0000-0000-0000-000000000000)'
        appType: 'webAppHyperVContainer'
        WebAppName: 'WindowsDockerSample'
        DockerNamespace: 'myontainerregistry'
        DockerRepository: 'myrepository'
```
