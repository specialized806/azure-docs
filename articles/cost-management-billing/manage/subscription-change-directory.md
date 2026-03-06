---
title: Azure subscription change directory
description: This article helps you to complete the Azure subscription change directory two-party request and accept workflow. 
author: Nicholak-MS
ms.author: nicholak
ms.reviewer: nicholak
ms.service: cost-management-billing
ms.subservice: billing
ms.topic: concept-article
ms.date: 03/06/2026
service.tree.id: b69a7832-2929-4f60-bf9d-c6784a865ed8
---

## How to change the Entra directory of your Azure subscription

To change the Entra Directory of your Azure subscription, you need to complete the following two-party request and accept workflow. 

1. To initiate a change directory request you will need to be a subscription owner of the subscription in the source directory. 
2. To accept a change directory request you or another party will need to be an Entra tenant admin in the destination directory. 

Follow these steps to complete the change directory workflow.

### Step 1

1. Sign into the Azure portal of source directory as a subscription owner or Entra tenant admin and select the subscription you want to change from the [Subscriptions page in Azure portal](https://portal.azure.com/#blade/Microsoft_Azure_Billing/SubscriptionsBlade)  
2. Select **Change Directory**

    ![Change Directory highlighted](/media/subscription-change-directory/1-change-directory.png) 
3. The Change directory experience will open. 

### Step 2 - Initiate the directory change request

1. Read the information completely to understand the implications of the change directory action. 
2. Choose whether you or another party will be accepting the request in the destination directory. 
  1. Yes - if you are the acceptor in the destination
  2. No - if you are inviting another party to accept the invitation

    ![Change Directory choices](/media/subscription-change-directory/2-start.png) 

  If you are the acceptor select Yes and select the tenant ID of the destination directory in the dropdown and click Continue to complete the transfer. 

      ![Self Recipient](/media/subscription-change-directory/4-destination-selection.png)

  If you are sending the request to another party select No and enter the email address of the recipient and the tenant ID of the destination directory and click Continue to initiate the transfer invitation. 

    ![Other Recipient](/media/subscription-change-directory/3b-other-recipient.png)
  
### Step 3 - Accept the directory change request

1. If you initiated a request that you are also accepting you will be presented with a confirmation page to Continue the transfer.

 ![Self Accept](/media/subscription-change-directory/1-change-directory.png) 
    > [!NOTE]
    > If you don’t have access to the target directory it will not show. After the directory is changed for the subscription, you'll receive a success message.  
    ![A screenshot of the Change Directory validation page.](media/how-to-change-directory-tenants-visual-studio-azure/change-button.png "Select the directory from the dropdown and select the Change button.")
5. Select “Switch Directories” on the subscription page to access the new directory  

  ![A screenshot of the subscriptions page with Switch Directories highlighted.](media/how-to-change-directory-tenants-visual-studio-azure/switch-directories-outlined.png "Select Switch Directories to access the new directory.")

You can also access a target directory and change your tenancy by going to the target directory and adding an Admin. Follow [these instructions](/visualstudio/subscriptions/cloud-admin) on how to add an Admin to your subscription. Once that’s done, the Admin has access to both directories and can change the tenant directory for you.  
