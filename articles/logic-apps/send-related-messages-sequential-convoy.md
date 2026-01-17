---
title: Send Service Bus Messages in a Specific Order
description: Learn how to send related Azure Service Bus messages in a specific order by using the sequential convoy pattern in Azure Logic Apps.
services: logic-apps
ms.suite: integration
ms.reviewer: apseth, divswa, azla
ms.topic: how-to
ms.custom: sfi-image-nochange
ms.date: 01/14/2026
#Customer intent: As developer who works with Azure Logic Apps, I want to send related messages from different Service Bus sessions in a specific order for processing in my workflow.
---

# Send related Service Bus messages in a specific order by using a sequential convoy in Azure Logic Apps

[!INCLUDE [logic-apps-sku-consumption-standard](../../includes/logic-apps-sku-consumption-standard.md)]

Some scenarios require your workflow to process session-related messages in a specific order from an Azure Service Bus [queue](../service-bus-messaging/service-bus-queues-topics-subscriptions.md). These messages have a property that define the relationship with each other, such as a [*session* ID](../service-bus-messaging/message-sessions.md). To process these messages by session, set up a [*sequential convoy* pattern](/azure/architecture/patterns/sequential-convoy) in your workflow.

For example, suppose you have a Service Bus queue that receives messages from multiple sessions. You have 10 messages from a session named *Session 1* and 5 messages from a session named *Session 2*. You can create a workflow that alternates between sessions to process messages from the queue. When the trigger first fires, the workflow run handles all the messages from Session 1. When the trigger fires again, the workflow run handles all the messages from Session 2.

:::image type="content" source="./media/send-related-messages-sequential-convoy/sequential-convoy-pattern-general.png" alt-text="Diagram shows the general sequential convoy pattern.":::

This guide shows how to create a workflow that sets up the sequential convoy pattern to perform the following high-level steps:

1. When the Service Bus trigger named **When a message is received in a queue (peek-lock)** fires, run the workflow.

   For more information about *peek-lock* mode, see [Receive modes](../service-bus-messaging/service-bus-queues-topics-subscriptions.md#receive-modes) and [Peek lock](../service-bus-messaging/message-transfers-locks-settlement.md#peeklock).

1. Initialize a session based on the message that the trigger reads from the Service Bus queue.

1. Read and process all the messages from the same session in the queue during the current workflow run.

For Standard logic apps, you can create a workflow by using the template named **Azure Service Bus: Process related messages from a session-enabled queue for the same workflow instance - Sequential convoy pattern**.

For Consumption workflows, no workflow template is available in the designer, so you have to manually build the workflow. You can also review the template for Standard workflows or the JSON file for the formerly available template named **Correlated in-order delivery using service bus sessions** available in [GitHub: service-bus-sessions.json](https://github.com/Azure/logicapps/blob/master/templates/service-bus-sessions.json).

## Prerequisites

- An Azure account and subscription. [Get a free Azure account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).

- A Service Bus namespace (Standard or Premium pricing tier) and a Service Bus *session-enabled* queue.

  - These items and your logic app resource must use the same Azure subscription.

  - When you create your queue, make sure that you select **Enable sessions**.

  For more information, see [Create a Service Bus namespace and queue](../service-bus-messaging/service-bus-create-namespace-portal.md).

- The logic app resource where you want to set up the sequential convoy pattern.

  For more information, see:

  - [Create a Consumption logic app workflow](../logic-apps/quickstart-create-example-consumption-workflow.md)
  - [Create a Standard logic app workflow](../logic-apps/create-single-tenant-workflows-azure-portal.md)

  Your logic app resource also needs permissions to your Service Bus namespace. To check these permissions, see [Check access to Service Bus namespace](#permissions-connection-strong).

<a name="permissions-connection-string"></a>

## Check access to Service Bus namespace

Your logic app resource and workflow need permissions to access your Service Bus namespace. If you're unsure whether your workflow has permissions, check them now.

1. In the [Azure portal](https://portal.azure.com), find and select your Service Bus namespace.

1. On the sidebar menu, under **Settings**, select **Shared access policies**. Check that you have **Manage** permissions for that namespace.

   :::image type="content" source="./media/send-related-messages-sequential-convoy/check-service-bus-permissions.png" alt-text="Screenshot shows the Shared access policies page for a Service Bus namespace." lightbox="./media/send-related-messages-sequential-convoy/check-service-bus-permissions.png":::

1. Get the connection string for your Service Bus namespace by following these steps:

   1. On the **Shared access policies** page, under **Policy**, select **RootManageSharedAccessKey**.
   
   1. On the **SAS Policy: RootManageSharedAccessKey** pane, next to the primary connection string, select the copy button.

      :::image type="content" source="./media/send-related-messages-sequential-convoy/copy-service-bus-connection-string.png" alt-text="Screenshot shows the Shared access policies where you can copy a Service Bus namespace connection string.":::

      > [!TIP]
      >
      > To make sure that your connection string is associated with your Service Bus namespace and not a messaging entity, such as a queue, check the connection string for the `EntityPath` parameter. If you find this parameter, the connection string is for a specific entity, and isn't the correct string to use with your workflow.

   1. Save the connection string for later use when you connect from your workflow to the namespace.

## Create a sequential convoy workflow

Based on whether your logic app resource is Standard or Consumption, follow the corresponding steps.

### [Standard](#tab/standard)

These steps create a workflow from the template named **Azure Service Bus: Process related messages from a session-enabled queue for the same workflow instance - Sequential convoy pattern**. The template includes the trigger and actions to implement this workflow pattern. You also create a connection to your Service Bus namespace and specify the name for the Service Bus queue that you want to use.

1. In the [Azure portal](https://portal.azure.com), open your Standard logic app resource.

1. On the sidebar menu, under **Workflows**, select **Workflows**.

1. On the **Workflows** toolbar, select **Create** > **Create from Template**.

1. Under **Templates**, select the template named **Azure Service Bus: Process related messages from a session-enabled queue for the same workflow instance - Sequential convoy pattern**, then select **Use this template**.

   The following example partially shows the workflow templates gallery:

   :::image type="content" source="./media/send-related-messages-sequential-convoy/select-workflow-template.png" alt-text="Screenshot shows a page where you can select a service bus sessions template." lightbox="./media/send-related-messages-sequential-convoy/select-workflow-template.png":::

1. On the **Create a new workflow from template** pane, follow these steps:

   1. On the **Basics** tab, follow these steps:

      1. Provide a name for your workflow.

         The name must start with a letter and can contain only letters, numbers, dashes, and underscores.

      1. Select **Stateful** or **Stateless**, based on your scenario.

      1. Select **Next**.

   1. On the **Connections** tab, follow these steps:

      1. For Service Bus, in **Connection** column, select **Connect**.

         :::image type="content" source="./media/send-related-messages-sequential-convoy/connect-service-bus.png" alt-text="Screenshot shows pane to start connecting to Azure Service Bus namespace.":::

      1. Provide the following information:

         | Parameter | Value | Description |
         |-----------|-------|-------------|
         | **Connection Name** | <*connection-name*> | The name for the connection to your Service Bus namespace. |
         | **Authentication Type** | **Connection String** | The authentication type to use. |
         | **Connection String** | <*namespace-connection-string*> | The connection string that you saved earlier from your Service Bus namespace. |

          :::image type="content" source="./media/send-related-messages-sequential-convoy/service-bus-connection-standard.png" alt-text="Screenshot shows Service Bus connection pane in Standard workflow":::

      1. When you're done, select **Add connection** > **Next**.

   1. On the **Parameters** tab, follow these steps:

      1. Provide the following information:

         | Parameter | Description |
         |-----------|-------------|
         | **Queue name** | The name for the Service Bus session-enabled queue with the messages to process. |
         | **Maximum batch size** | The maximum number of messages to get as a batch. |

      1. When you're done, select **Next**.

   1. Review the provided information, and select **Create**.

   The designer shows a workflow prepopulated with the trigger named **When messagse are available in a queue (peek-lock)** and various actions, for example:

   :::image type="content" source="./media/send-related-messages-sequential-convoy/workflow-from-template.png" alt-text="Screenshot shows workflow with all operations.":::

   This workflow includes cross-environment parameters that are predefined to abstract values that change across various environments where your workflow runs, for example, development, test, and production. Many operations in the workflow use these parameters instead of hardcoded values.

   The following table describes these cross-environment parameters:

   | Name | Type | Value | Description |
   |------|------|-------|-------------|
   | `delayInMinutes_<workflow-name>` | **Integer** | `0` | The number of minutes to wait before renewing |
   | `messageBatchSize_<workflow-name>` | **Integer** | `50` | The number of messages for the current batch. |
   | `queueName_<workflow-name>` | **String** | `<Service-Bus-queue-name>` | The name for your Service Bus queue. |

   For more information, see [Create cross-environment parameters for workflow inputs](create-parameters-workflows.md).

1. To complete the workflow by providing the required values, continue to the next section.

#### Complete the workflow

To learn about the workflow operations and provide the required values, follow these steps. You must provide all the required values, which are marked by an asterisk (**\***), before you can save the workflow.


1. For the Service Bus built-in trigger named [**When messages are available in a queue (peek-lock)**](azure/logic-apps/connectors/built-in/reference/servicebus/#when-messages-are-available-in-a-queue-(peek-lock)), provide the following values:


   This trigger waits for messages to arrive in the specified Service Bus queue. If a message exists in the queue, the trigger fires and runs a workflow instance. The term *peek-lock* means that the trigger sends a request to retrieve a message from the queue. If a message exists, the trigger retrieves and locks the message so that no other processing happens on that message until the lock period expires.

1. For the variable named **Initialize Process Complete Flag**

   1.  | This [**Initialize variable** action](logic-apps-create-variables-store-values.md#initialize-variable) creates a Boolean variable named `processCompleted` with the default value set to **false**. The variable indicates when the following conditions are true: <br><br>- No more messages exist in the session for processing. <br>- The session lock no longer needs to be renewed so the current workflow instance can finish running. |
| **Scope** | This [**Scope** action](logic-apps-control-flow-run-steps-group-scopes.md) contains the actions that run to process a message. If a problem happens in this scope, the subsequent actions outside this **Scope** action handles that problem. |
| **Business Logic Scope**| This [**Scope** action](logic-apps-control-flow-run-steps-group-scopes.md) contains the business actions that run based on the current message. |
| **Business Logic** | This action is a placeholder, so replace this action with the actions to process the current message, based on your scenario's business logic. |
| **Process Finished** | This action changes the `processCompleted` variable value from **false** to **true** to indicate that message processing completed. <br><br>Make sure This action's settings also sets the **Run after** values for **Business Logic Scope** to **Is successful**, **Has timed out**, **Is skipped**, and **Has failed**. |



   1. On the **Settings** tab, in the **Run after** section, expand **Business Logic Scope**.

   1. Select all the unselected statuses: **Has timed out**, **Is skipped**, and **Has failed**, for example:

      :::image type="content" source="./media/send-related-messages-sequential-convoy/run-after-settings.png" alt-text="Screenshot shows the run after settings for Process Finished.":::



For more information, see:

- [Evaluate actions with scopes and their results](error-exception-handling.md#evaluate-actions-with-scopes-and-their-results)
- [Logic Apps: Try-Catch Pattern, Nested Scopes, and Compensating Transaction Pattern](https://andrewilson.co.uk/post/2025/01/logic-app-nested-scopes-and-compensating-transaction-pattern/)

### [Consumption](#tab/consumption)

These steps manually create a workflow that uses an Azure Service Bus trigger and actions to implement the sequential convoy pattern. Your workflow creates a connection to your Service Bus namespace and specifies the name for the Service Bus queue that you want to use.

#### Add parameters to your workflow

In this section, create cross-environment parameters to abstract values that change across various environments where your workflow runs, for example, development, test, and production. Later, you add various actions that use these parameters in your workflow.

Follow these [general steps](create-parameters-workflows.md) to create the cross-environment parameters in this table:

| Name | Type | Value | Description |
|------|------|-------|-------------|
| `delayInMinutes_<workflow-name>` | **Integer** | `0` | The number of minutes to wait before renewing |
| `messageBatchSize_<workflow-name>` | **Integer** | `50` | The number of messages for the current batch. |
| `queueName_<workflow-name>` | **String** | `<Service-Bus-queue-name>` | The name for your Service Bus queue. |

When you're done, your cross-environment parameters look like the following example:

:::image type="content" source="./media/send-related-messages-sequential-convoy/workflow-parameters.png" alt-text="Screenshot shows cross-environment parameters.":::

#### Add a Service Bus trigger

These steps add a Service Bus trigger that initializes sessions and checks the specified Service Bus queue for messages, based on the specified schedule. If a message exists in the queue, the trigger fires and runs the workflow.

1. In the [Azure portal](https://portal.azure.com), open your Consumption logic app resource and blank workflow in the designer.

1. Follow the [general steps](add-trigger-action-workflow.md#add-trigger) to add a Service Bus trigger named **When one or more messages arrive in a queue (peek-lock)**.

   The term *peek-lock* means that the trigger sends a request to retrieve a message from the queue. If a message exists, the trigger retrieves and locks the message so that no other processing happens on that message until the lock period expires.

1. On the connection pane, provide the folowing information:

   | Parameter | Value | Description |
   |-----------|-------|-------------|
   | **Connection Name** | <*connection-name*> | The name for the connection to your Service Bus namespace. |
   | **Authentication Type** | **Access key** | The authentication type to use. |
   | **Connection String** | <*namespace-connection-string*> | The connection string that you saved earlier from your Service Bus namespace. |

   :::image type="content" source="./media/send-related-messages-sequential-convoy/service-bus-connection-consumption.png" alt-text="Screenshot shows Service Bus connection pane in Consumption workflow.":::

1. When you're done, select **Create new**.

1. After the trigger information pane opens, on the **Parameters** tab, provide the following values:

   1. Select inside the **Queue name** box, then select the lightning icon to open the dynamic content list.

   1. From the list, select `queueName_<workflow-name>`.

      This previously created workflow parameter specifies the name for your Service Bus queue.

   1. For **Queue type**, keep the default type set to **Main**.

      This type refers to your primary Service Bus queue.

   1. Under **Advanced parameters**, for **Session id**, select **Next available**.

      The following table describes more information about the **Session id** values:

      | Session id | Descrption |
      |------------|------------|
      | **None** | The default value, which results in no sessions and can't be used for implementing the sequential convoy pattern. |
      | **Next available** | This value specifies that when the trigger fires, the trigger gets a session based on the session ID from the message in the Service Bus queue.  The workflow's subsequent actions process all the messages associated with the same session. <br><br>The session is locked so that no other workflow or client can process messages related to the same session. |
      | **Enter custom value** | A known, static session ID that you want the trigger to always use. |

      > [!NOTE]
      >
      > The Service Bus connector can save a limited number of unique sessions at a time to the connector cache from Azure Service Bus. If the session count exceeds this limit, old sessions are removed from the cache. For more information, see [Exchange messages in the cloud with Azure Logic Apps and Azure Service Bus](../connectors/connectors-create-api-servicebus.md#connector-reference).

   1. Select inside the **Maximum message count** box, then select the lightning icon to open the dynamic content list.

   1. From the list, select `messageBatchSize_<workflow-name>`.

   The completed trigger looks like the following example:

   :::image type="content" source="./media/send-related-messages-sequential-convoy/when-messages-arrive-trigger.png" alt-text="Screenshot shows the completed Service Bus trigger.":::

   The trigger outputs a [ServiceBusMessage object](/connectors/servicebus/#servicebusmessage).

   > [!NOTE]
   >
   > Initially, the polling interval is set to three minutes so that the logic app doesn't run more frequently than you expect and result in unanticipated billing charges. Ideally, set the interval and frequency to 30 seconds so that the logic app triggers immediately when a message arrives.

   For more information, see [Service Bus - When one or more messages arrive in a queue (peek-lock)](/connectors/servicebus/#when-one-or-more-messages-arrive-in-a-queue-(peek-lock)).

#### Add a variable to check whether more messages exist

To help your workflow determine whether any more messages from a session need processing, create a Boolean variable with the default value set to `false`. This variable indicates when the following conditions are true:

- No more messages exist in the session for processing.
- The session lock no longer needs to be renewed so the current workflow instance can finish running.

1. In the designer, under the trigger, follow the [general steps](add-trigger-action-workflow.md#add-action) to add a **Variables** action named **Initialize variables**.

1. Rename the action to `Initialize Process Complete Flag`.

1. In the action information pane, provide the following values:

   | Parameter | Value | Description |
   |-----------|-------|-------------|
   | **Name** | <*variable-name*> | The name for the variable. For this example, the name is `processCompleted`. |
   | **Type** | **Boolean** | The data type for the variable. |
   | **Value** | **false** | The initial default value for the variable. |

   When you're done, your workflow looks like the following example:

   :::image type="content" source="./media/send-related-messages-sequential-convoy/initialize-process-complete.png" alt-text="Screenshot shows the information for Initalize Process Complete Flag.":::

   For more information, see [Initialize the session](#initialize-session).

1. Continue to the next section to add a scope for message handling.

#### Add actions to process each message

These steps add a [**Scope** action](logic-apps-control-flow-run-steps-group-scopes.md) to the workflow. Inside this **Scope** action, another scope contains the actions for message processing, based on your scenario's business logic. If a problem happens in these scopes, the actions outside the outermost **Scope** action handle that problem.

1. In the designer, under the `Initialize Process Complete Flag` action, follow the [general steps](add-trigger-action-workflow.md#add-action) to add a **Scope** action.

1. Rename the scope action to `Process message`, for example:

   :::image type="content" source="./media/send-related-messages-sequential-convoy/process-message-scope.png" alt-text="Screenshot shows the workflow with the Process Message scope.":::

1. In the **Process message** scope, add another **Scope** action.

   1. Change the second scope name to `Business Logic Scope`, for example:

      :::image type="content" source="./media/send-related-messages-sequential-convoy/business-logic-scope.png" alt-text="Screenshot shows the workflow with Business Logic Scope.":::

   1. Inside `Business Logic Scope`, add the actions to process the current message, based on your scenario's business logic.

1. Outside `Business Logic Scope`, add a **Variables** action named **Set variable**.

   1. Change **Set variable** to `Process Finished`.

   1. On the **Parameters** tab, provide the following information:

      | Parameter | Value | Description |
      |-----------|-------|-------------|
      | **Name** | <*variable-name*> | The name for the variable. For this example, the name is `processCompleted`. |
      | **Value** | **true** | The updated value to indicate that message processing completed. |

      When the message finishes processing, the `Processed Finished` action updates the value in the `processCompleted` variable from **false** to **true**.

   1. On the **Settings** tab, in the **Run after** section, expand **Business Logic Scope**.

   1. Select all the unselected statuses: **Has timed out**, **Is skipped**, and **Has failed**, for example:

      :::image type="content" source="./media/send-related-messages-sequential-convoy/run-after-settings.png" alt-text="Screenshot shows the run after settings for Process Finished.":::

1. At the same level as the **Business Logic Scope**, add a parallel branch to determine whether any other messages exist in the same session.

   1. Between `Process message` and `Business Logic Scope`, select the plus sign (**+**), then select **Add a parallel branch**.

   1. In the **Add an action** pane, add a **Control** action named **Until**, which is a type of loop, for example:

      :::image type="content" source="./media/send-related-messages-sequential-convoy/parallel-branch-until-loop.png" alt-text="Screenshot shows the parallel branch with the Until loop.":::

   1. On the **Until** action information pane, provide the condition that stops running the loop.

      This **Until** loop makes sure the session lock is held while messages exist or until one hour passes. To change the loop's time limit, edit the loop's advanced parameter named **Timeout**, which is set to **PT1H**.

      1. On the **Parameters** tab, select inside the leftmost **Choose a value** box, then select the expression editor (function icon).

      1. In the expression editor, enter the following expression:

         `variables('processCompleted')`

      1. When you're done, select **Add**.

         The expression resolves, and the partially completed condition looks like the following example:

         :::image type="content" source="./media/send-related-messages-sequential-convoy/process-completed-until-loop.png" alt-text="Screenshot shows the resolved expression for processCompleted variable.":::

      1. In the middle list, make sure the operation set to the equal sign (**=**).

      1. In the rightmost **Chose a value** box, enter the value `true`.

         The completed condition looks like the following example:

         :::image type="content" source="./media/send-related-messages-sequential-convoy/until-loop-completed.png" alt-text="Screenshot shows the completed Until loop.":::

   1. Add actions for message detection to the **Until** loop by following these steps:

      1. Follow the [general steps](add-trigger-action-workflow.md#add-action) to add a Service Bus action named **Renew lock on the message in a queue**.

      1. After the Service Bus action information pane opens, provide the following values:

         1. Select inside the **Queue name** box, then select the lightning icon to open the dynamic content list.

         1. From the list, select `queueName_<workflow-name>`.

         1. Select inside the **Lock token of the message** box, then select the lightning icon to open the dynamic content list.

         1. From the list, select `messageBatchSize_<workflow-name>`.

         1. From the list, under **When one or more messages arrive in a queue**, select **Lock Token**.

         The following example shows the completed Service Bus action:

         :::image type="content" source="./media/send-related-messages-sequential-convoy/renew-lock-on-message-complete.png" alt-text="Screenshot shows the completed renew lock action.":::

      1. Under the Service Bus action, add a **Schedule** action named **Delay**.

         1. Change the action name to `Wait for Process to Complete`.

         1. On the **Parameters** tab, the action information pane, select inside the **Count** box, then select the lightning icon.

         1. From the list, select `delayInMinutes_<workflow-name>`.

            Make sure this delay value is less than the lock timeout duration for the queue. The minimum lock duration is 30 seconds.

         1. For **Unit**, set the time unit for the delay.

            This example uses **Minute**.

         The following example shows the completed delay duration:

         :::image type="content" source="./media/send-related-messages-sequential-convoy/wait-process-complete.png" alt-text="Screenshot shows the completed delay duration.":::

      When you're done, the **Until** loop looks like the following example:

      :::image type="content" source="./media/send-related-messages-sequential-convoy/until-loop-actions.png" alt-text="Screenshot shows the actions in the Until loop.":::

      [!INCLUDE [Warning about creating infinite loops](../../includes/connectors-infinite-loops.md)]

#### Add action for exception handling




---


## Run the workflow

After you complete customizing the template, you can save your logic app. On the designer toolbar, select **Save**.

To test your logic app, send messages to your Service Bus queue. 

## Related content

- [Service Bus connector operations](/connectors/servicebus/)
