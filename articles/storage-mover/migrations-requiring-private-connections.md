---
title: Get started with Storage Mover Migrations requiring Private Connections
description: Learn how to migrate sources that require a private connection
author: stevenmatthew
ms.author: shaas
ms.service: azure-storage-mover
ms.topic: how-to
ms.date: 02/18/2026
--- 

# Get started with Storage Mover Migrations requiring Private Connections

## Overview

A private connection allows enterprise customers to securely migrate data between Azure Web Sservices (AWS) S3 and Azure Storage over private networks, keeping transfers off the public internet. By using Azure Private Link Service (PLS) and Private Endpoints (PE), this solution extends the Virtual private Cloud (VPC) network into Azure, supports strict security compliance, and helps protect sensitive information.

**Prerequisites For Setting up Storage Mover** 

Before you begin, ensure that you have:

[Understanding the Azure Storage Mover resource hierarchy | Microsoft Learn](/azure/storage-mover/resource-hierarchy)

A  [Storage Mover resource](/azure/storage-mover/storage-mover-create) deployed in your Azure subscription.

Completed the preparation from [Get started with cloud-to-cloud migration in Azure Storage Mover | Microsoft Learn](/azure/storage-mover/cloud-to-cloud-migration)

An active Azure subscription with [ permissions to create and manage Azure Storage mover and Azure Arc resources.](/azure/azure-arc/multicloud-connector/add-public-cloud)

**Prerequisite for Creating a Private Connection**

* [**Create a Private Link Service Direct Connect**](https://docs.azure.cn/en-us/private-link/create-private-link-service-portal?tabs=dynamic-ip)
* **Networking Documentation **

**Limits**

The Virtual Private Cloud feature in Azure Storage Mover has the following limits:

* A Private Link Service Direct Connect, an IP based Private Link Service (PLS),  can't be created directly within Storage Mover; you must establish the Private Link Service (PLS) before initiating the creation of a private connection. 
* It's necessary to review your AWS S3 environment to determine whether it resides behind a Virtual Private Cloud, as this process doesn't validate the public or private status of your S3 bucket
* When configuring your PLS, ensure it accurately maps to the Virtual Private Cloud associated with your S3 resource, since this experience doesn't offer validation at that level.

## Step 1: Create a Private Connection

*Configure a Private Connection in Storage Endpoints *

1. Navigate to your Storage Mover instance in Azure.
2. Under Storage endpoints, select Private Connection → Create Private Connection.

:::image type="content" source="./media/private-connections/storage-endpoints.png" alt-text="Screenshot of navigation to private connections." lightbox="./media/private-connections/storage-endpoints.png":::
 

4. Insert a name for this Private Connection.
5. ***Note:**** This name matches the name of the Private Endpoint that you later approve to connect to the Private Link service.*
6. Select the appropriate Private Link Service Direct Connect that directs you to the correct AWS S3 bucket you want to migrate to Azure.

:::image type="content" source="./media/create-private-connection.png" alt-text="Screenshot displaying how to create a private connections." lightbox="./media/create-private-connection.png":::

8. Select Create and commit your changes.
9. ***Note***: *Creating this Private Connection takes 20-30 seconds. You may need to refresh manually to view it in the grid.*

:::image type="content" source="./media/confirm-create-pc.png" alt-text="Screenshot of notification that confirms the private connection was created." lightbox="./media/confirm-create-pc.png":::

:::image type="content" source="./media/private-connections-browse.png" alt-text="Screenshot of the private connection page." lightbox="./media/private-connections-browse.png":::

1. Repeat steps 1-4 to set up several Private Connections.
2. ***Note****: Create multiple private connections to avoid bandwidth limits and ensure efficient, successful data migration.*
3. ***Note:*** *There is currently a default limit of 10 private connections per subscription per region**** ***

:::image type="content" source="./media/private-connection-added.png" alt-text="Screenshot of multiple listed private connections." lightbox="./media/private-connection-added.png":::

## Step 2: Approve a Private Connection

*Select and approve your newly created Private Connection *

1. Select the checkbox for your newly created Private Connection. 
2. ***Note****: You're authorizing the connection between the Private Link service you specified during Private Connection setup and the corresponding private endpoint that has been automatically generated for you*.  
3. Click "Approve"  
4. ***Note****: Only a Private connection in Approved state can be used for a Migration job. Connections in pending, rejected, or disconnected states don't appear as options when creating a job.*

:::image type="content" source="./media/approve-private-connection.png" alt-text="Screenshot of a private connection approving the private endpoint." lightbox="./media/approve-private-connection.png":::

:::image type="content" source="./media/pc-approval-pending.png" alt-text="Screenshot of the pending approval of the private endpoint to the private connection." lightbox="./media/pc-approval-pending.png":::

:::image type="content" source="./media/pc-approved-private-endpoint.png" alt-text="Screenshot of the confirmed approval of the private endpoint to the private connection." lightbox="./media/pc-approved-private-endpoint.png":::

:::image type="content" source="./media/all-pc-approved.png" alt-text="Screenshot of the confirmed approval of all of the listed private connections." lightbox="./media/all-pc-approved.png":::

## Step 3: Create a Project

1. Provide a name for your Project 
2. Create your project

:::image type="content" source="./media/mover-projects.png" alt-text="Screenshot of the projects page in Storage Mover." lightbox="./media/mover-projects.png":::

:::image type="content" source="./media/create-project.png" alt-text="Screenshot of creating a new project." lightbox="./media/create-project.png":::

:::image type="content" source="./media/project-created.png" alt-text="Screenshot of a new project sucessfully created." lightbox="./media/project-created.png":::

## Step 4: Create a Job

*Create your Multi-cloud Migration job *

1. Navigate to the Projects page.
2. Once you click on one of your Projects, select "Create Job"

:::image type="content" source="./media/project-browse.png" alt-text="Screenshot of an available project opened to be able to create a job ." lightbox="./media/project-browse.png":::

1. In the "Basics" tab, select your desired Migration Type

:::image type="content" source="./media/create-job-basics.png" alt-text="Screenshot of the Create Job experience with the "Basics" tab open." lightbox="./media/create-job-basics.png":::

1. Source tab, select an existing or newly created source type
2. ***Note****: Ensure your selected source type is protected by a Virtual Private Cloud.*
3. Select a "Private" type
   * Some sources don't require you to click “Private,” but they do require you to add one or more private connections for the selected source.

:::image type="content" source="./media/create-job-source.png" alt-text="Screenshot of the Create Job experience with the "Source" tab open." lightbox="./media/create-job-source.png":::

1. Select your existing Private Connections
2. ***Note****: Select multiple private connections to avoid bandwidth limits and ensure efficient, successful data migration.*

:::image type="content" source="./media/select-private-connection.png" alt-text="Screenshot of the Create Job experience with the ability to select a private connection." lightbox="./media/select-private-connection.png":::

:::image type="content" source="./media/pc-selection-confirmed.png" alt-text="Screenshot of the Create Job experience with the selection of private connections confirmed." lightbox="./media/pc-selection-confirmed.png":::

:::image type="content" source="./media/pc-listed.png" alt-text="Screenshot of the Create Job experience with the selected private connections listed in the "Source" tab." lightbox="./media/pc-listed.png":::

1. Click "Next"
2. Select your Target resource, where you would like your data to be migrated to Azure. 

:::image type="content" source="./media/create-job-target.png" alt-text="Screenshot of the Create Job experience with the "Target" tab open." lightbox="./media/create-job-target.png":::

:::image type="content" source="./media/create-job-settings.png" alt-text="Screenshot of the Create Job experience with the "Settings" tab open." lightbox="./media/create-job-settings.png":::

:::image type="content" source="./media/job-setting-selected.png" alt-text="Screenshot of the Create Job experience with the settings configurations selected." lightbox="./media/job-setting-selected.png":::


1. Select the proper Settings for your migration.
2. Click "Create"

:::image type="content" source="./media/create-job-review.png" alt-text="Screenshot of the Create Job experience with the "Review" tab open." lightbox="./media/create-job-review.png":::

:::image type="content" source="./media/job-deploying.png" alt-text="Screenshot displaying the created job pending deployment." lightbox="./media/job-deploying.png":::

## Step 5: Edit a Job

*Create your Multi-cloud Migration job *

1. Navigate to the Job you created in your Project.

:::image type="content" source="./media/job-created.png" alt-text="Screenshot of a Job sucessfully created." lightbox="./media/job-created.png":::

1. Click on the "Edit" Icon
2. Select Private connections
   * You can either Delete or add new private connections by clicking the respective buttons
3. Click "Save"
   * **Note**: To locate errors related to private connections, go to the Job page and select the Monitoring tab after the job completes.
4. Run your job as usual once you confirm that all configurations are correct.

:::image type="content" source="./media/job-overview.png" alt-text="Screenshot of the overview page of the created Job." lightbox="./media/job-overview.png":::

:::image type="content" source="./media/edit-job.png" alt-text="Screenshot of the edit Job page." lightbox="./media/edit-job.png":::

:::image type="content" source="./media/edit-private-connections.png" alt-text="Screenshot of the "edit priavte connections" tab for a Job ." lightbox="./media/edit-private-connections.png":::

:::image type="content" source="./media/removed-private-connection.png" alt-text="Screenshot of the removal of a private connection from a Job ." lightbox="./media/removed-private-connection.png":::

:::image type="content" source="./media/added-private-connection.png" alt-text="Screenshot of the addition of a private connection from a Job ." lightbox="./media/added-private-connection.png":::

:::image type="content" source="./media/save-pc-edits.png" alt-text="Screenshot of the saved edits of a private connection for a Job ." lightbox="./media/save-pc-edits.png":::





