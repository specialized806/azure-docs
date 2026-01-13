---
title: Send Correlated Messages in a Specific Order
description: Learn how to send related Azure Service Bus messages in a specific order by using the sequential convoy pattern in Azure Logic Apps.
services: logic-apps
ms.suite: integration
ms.reviewer: apseth, divswa, azla
ms.topic: how-to
ms.custom: sfi-image-nochange
ms.date: 01/14/2026
#Customer intent: As developer who works with Azure Logic Apps, I want to send related messages from different Service Bus sessions in a specific order for processing in my workflow.
---

# Send related Azure Service Bus messages in a specific order by using a sequential convoy in Azure Logic Apps

[!INCLUDE [logic-apps-sku-consumption-standard](includes/logic-apps-sku-consumption-standard.md)]

Some scenarios might require that you send *correlated messages* in a specific order. These messages have a property that lets you define the relationship between these messages, such as an ID for the [session](../service-bus-messaging/message-sessions.md). In [Azure Logic Apps](logic-apps/logic-apps-overview.md), when you use the [Azure Service Bus connector](../connectors/connectors-create-api-servicebus.md), you can set up a *sequential convoy* pattern to process these messages in the order you want.

For example, suppose you have a [Service Bus queue](../service-bus-messaging/service-bus-queues-topics-subscriptions.md) that receives messages from different sessions. You have 10 messages from a session named *Session 1* and 5 messages from a session named *Session 2*. You can create a logic app workflow that processes messages from the queue by alternating between sessions. So when the trigger first fires, the workflow run handles all the messages from Session 1. When the trigger fires again, the workflow run handles all the messages from Session 2.

:::image type="content" source="./media/send-related-messages-sequential-convoy/sequential-convoy-pattern-general.png" alt-text="Diagram shows the general sequential convoy pattern.":::

This article shows how to create a logic app workflow that implements this pattern by using the **Correlated in-order delivery using service bus sessions** template. This template defines a workflow that starts with the Service Bus connector's **When a message is received in a queue (peek-lock)** trigger. The trigger receives messages from a [Service Bus queue](../service-bus-messaging/service-bus-queues-topics-subscriptions.md). Here are the high-level steps that this workflow performs:

- Initialize a session based on a message that the trigger reads from the Service Bus queue.

- Read and process all the messages from the same session in the queue during the current workflow run.

To review this template's JSON file, see [GitHub: service-bus-sessions.json](https://github.com/Azure/logicapps/blob/master/templates/service-bus-sessions.json).

For more information, see [Sequential convoy pattern - Azure Architecture Cloud Design Patterns](/azure/architecture/patterns/sequential-convoy).

## Prerequisites

- An Azure subscription. If you don't have a subscription, [sign up for a free Azure account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).

- A Service Bus namespace (Standard or Premium pricing tier) and a [Service Bus queue](../service-bus-messaging/service-bus-queues-topics-subscriptions.md), which is a messaging entity that you use in your logic app. These items and your logic app need to use the same Azure subscription. Make sure that you select **Enable sessions** when you create your queue. If you don't have these items, learn [how to create your Service Bus namespace and a queue](../service-bus-messaging/service-bus-create-namespace-portal.md).

  [!INCLUDE [Warning about creating infinite loops](../../includes/connectors-infinite-loops.md)]

- Basic knowledge about how to create logic apps. If you're new to Azure Logic Apps, see [Create a Consumption logic app workflow](../logic-apps/quickstart-create-example-consumption-workflow.md).

<a name="permissions-connection-string"></a>

## Check access to Service Bus namespace

If you're not sure whether your logic app has permissions to access your Service Bus namespace, confirm those permissions.

1. Sign in to the [Azure portal](https://portal.azure.com). Find and select your Service Bus namespace.

1. On the namespace menu, under **Settings**, select **Shared access policies**. Check that you have **Manage** permissions for that namespace.

   :::image type="content" source="./media/send-related-messages-sequential-convoy/check-service-bus-permissions.png" alt-text="Screenshot shows the Shared access policies page for a Service Bus namespace." lightbox="./media/send-related-messages-sequential-convoy/check-service-bus-permissions.png":::

1. Get the connection string for your Service Bus namespace. You can use this string later when you create a connection to the namespace from your logic app.

   1. On the **Shared access policies** pane, under **Policy**, select **RootManageSharedAccessKey**.
   
   1. Next to your primary connection string, select the copy button. Save the connection string for later use.

      :::image type="content" source="./media/send-related-messages-sequential-convoy/copy-service-bus-connection-string.png" alt-text="Screenshot shows the Shared access policies where you can copy a Service Bus namespace connection string.":::

   > [!TIP]
   >
   > To confirm whether your connection string is associated with your Service Bus namespace or a messaging entity, such as a queue, search the connection string for the `EntityPath` parameter. If you find this parameter, the connection string is for a specific entity, and isn't the correct string to use with your logic app.

## Create logic app

In this section, create a logic app by using the **Correlated in-order delivery using service bus sessions** template, which includes the trigger and actions for implementing this workflow pattern. You also create a connection to your Service Bus namespace and specify the name for the Service Bus queue that you want to use.

1. In the [Azure portal](https://portal.azure.com), create a blank logic app. From the Azure home page, search for and select **Logic Apps**. In the **Logic Apps** page, select **+ Add**. For more detailed instructions, see [Create a Consumption logic app workflow](../logic-apps/quickstart-create-example-consumption-workflow.md).

1. After you create the logic app, in the resource menu, under **Development Tools**, select **Logic app templates**.

   :::image type="content" source="./media/send-related-messages-sequential-convoy/select-correlated-in-order-delivery-template.png" alt-text="Screenshot shows a page where you can select a service bus sessions template." lightbox="./media/send-related-messages-sequential-convoy/select-correlated-in-order-delivery-template.png":::

1. When the template gallery appears, select the template, **Correlated in-order delivery using service bus sessions**. Then select **Use this template**.

1. Select **Next** to enter your connection information.

1. Under **Connection**, select **Connect**.

   :::image type="content" source="./media/send-related-messages-sequential-convoy/connect-to-service-bus.png" alt-text="Screenshot shows the Logic App Designer where you can select Continue to connect to Azure Service Bus.":::

1. Enter a name. For **Authentication Type**, select **Connection String**.

1. Enter the connection string that you saved in the previous section and select **Add connection**.

   :::image type="content" source="./media/send-related-messages-sequential-convoy/provide-service-bus-connection-string.png" alt-text="Screenshot shows the Service Bus connection name and connection string to establish a connection.":::

1. Select **Review + create**, then select **Create**.

The Logic App Designer now shows the **Correlated in-order delivery using service bus sessions** template, which contains a prepopulated workflow with a trigger and actions. The workflow includes two scopes that implement error handling that follows the `Try-Catch` pattern.

You can either learn more about the trigger and actions in the template, or jump ahead to [provide the values for the logic app template](#complete-template).

<a name="template-summary"></a>

## Template summary

Here's the top-level workflow in the **Correlated in-order delivery using service bus sessions** template when the details are collapsed:

:::image type="content" source="./media/send-related-messages-sequential-convoy/template-top-level-flow.png" alt-text="Screenshot shows the template's top-level workflow.":::

| Name | Description |
|------|-------------|
| **`When a message is received in a queue (peek-lock)`** | Based on the specified recurrence, this Service Bus trigger checks the specified Service Bus queue for any messages. If a message exists in the queue, the trigger fires, which creates and runs a workflow instance. <br><br>The term *peek-lock* means that the trigger sends a request to retrieve a message from the queue. If a message exists, the trigger retrieves and locks the message so that no other processing happens on that message until the lock period expires. For details, [Initialize the session](#initialize-session). |
| **`Init isDone`** | This [**Initialize variable** action](../logic-apps/logic-apps-create-variables-store-values.md#initialize-variable) creates a Boolean variable with a value of `false`. It indicates when the following conditions are true: <br><br>- No more messages in the session are available to read. <br>- The session lock no longer needs to be renewed so that the current workflow instance can finish. <br><br>For details, see [Initialize the session](#initialize-session). |
| **`Try`** | This [**Scope** action](../logic-apps/logic-apps-control-flow-run-steps-group-scopes.md) contains the actions that run to process a message. If a problem happens in the `Try` scope, the subsequent `Catch` **Scope** action handles that problem. For more information, see [Try scope](#try-scope). |
| **`Catch`**| This [**Scope** action](../logic-apps/logic-apps-control-flow-run-steps-group-scopes.md) contains the actions that run if a problem happens in the preceding `Try` scope. For more information, see [Catch scope](#catch-scope). |

<a name="try-scope"></a>

### Try scope

Here's the top-level flow in the `Try` [scope action](../logic-apps/logic-apps-control-flow-run-steps-group-scopes.md) when the details are collapsed:

:::image type="content" source="./media/send-related-messages-sequential-convoy/try-scope-action.png" alt-text="Screenshot shows the Try scope action workflow.":::

| Name | Description |
|------|-------------|
| **`Send initial message to topic`** | You can replace this action with whatever action that you want to handle the first message from the session in the queue. The session ID specifies the session. <br><br>For this template, a Service Bus action sends the first message to a Service Bus topic. See [Handle the initial message](#handle-initial-message). |
| (parallel branch) | This [parallel branch action](../logic-apps/logic-apps-control-flow-branches.md) creates two paths: <br><br>- Branch #1: Continue processing the message. For more information, see [Branch #1: Complete initial message in queue](#complete-initial-message). <br><br>- Branch #2: Abandon the message if something goes wrong, and release for pickup by another trigger run. For more information, see [Branch #2: Abandon initial message from queue](#abandon-initial-message). <br><br>Both paths join up later in the **Close session in a queue and succeed** action, described in the next row. |
| **`Close a session in a queue and succeed`** | This Service Bus action joins the previously described branches and closes the session in the queue after either of the following events happen: <br><br>- The workflow finishes processing available messages in the queue. <br>- The workflow abandons the initial message because something went wrong. <br><br>For details, see [Close a session in a queue and succeed](#close-session-succeed). |

<a name="complete-initial-message"></a>

#### Branch #1: Complete initial message in queue

| Name | Description |
|------|-------------|
| `Complete initial message in queue` | This Service Bus action marks a successfully retrieved message as complete and removes the message from the queue to prevent reprocessing. For details, see [Handle the initial message](#handle-initial-message). |
| `While there are more messages for the session in the queue` | This [**Until** loop](../logic-apps/logic-apps-control-flow-loops.md#until-loop) continues to get messages while messages exist or until one hour passes. For more information about the actions in this loop, see [While there are more messages for the session in the queue](#while-more-messages-for-session). |
| **`Set isDone = true`** | When no more messages exist, this [**Set variable** action](../logic-apps/logic-apps-create-variables-store-values.md#set-variable) sets `isDone` to `true`. |
| **`Renew session lock until cancelled`** | This [**Until** loop](../logic-apps/logic-apps-control-flow-loops.md#until-loop) makes sure that the session lock is held by this logic app while messages exist or until one hour passes. For more information about the actions in this loop, see [Renew session lock until cancelled](#renew-session-while-messages-exist). |

<a name="abandon-initial-message"></a>

#### Branch #2: Abandon initial message from the queue

If the action that handles the first message fails, the Service Bus action, **Abandon initial message from the queue**, releases the message for another workflow instance run to pick up and process. For details, see [Handle the initial message](#handle-initial-message).

<a name="catch-scope"></a>

### "Catch" scope

If actions in the `Try` scope fail, the logic app must still close the session. The `Catch` [scope action](../logic-apps/logic-apps-control-flow-run-steps-group-scopes.md) runs when the `Try` scope action results in the status, `Failed`, `Skipped`, or `TimedOut`. The scope returns an error message that includes the session ID where the problem happened, and terminates the logic app.

Here's the top-level flow in the `Catch` scope action when the details are collapsed:

:::image type="content" source="./media/send-related-messages-sequential-convoy/catch-scope-action.png" alt-text="Screenshot shows the Catch scope action workflow.":::

| Name | Description |
|------|-------------|
| **`Close a session in a queue and fail`** | This Service Bus action closes the session in the queue so that the session lock doesn't stay open. For details, see [Close a session in a queue and fail](#close-session-fail). |
| **`Find failure msg from 'Try' block`** | This [**Filter Array** action](../logic-apps/logic-apps-perform-data-operations.md#filter-array-action) creates an array from the inputs and outputs from all the actions inside the `Try` scope based on the specified criteria. In this case, this action returns the outputs from the actions that resulted in `Failed` status. For details, see [Find failure msg from 'Try' block](#find-failure-message). |
| **`Select error details`** | This [**Select** action](../logic-apps/logic-apps-perform-data-operations.md#select-action) creates an array that contains JSON objects based on the specified criteria. These JSON objects are built from the values in the array created by the previous action, `Find failure msg from 'Try' block`. In this case, this action returns an array that contains a JSON object created from the error details returned from the previous action. For details, see [Select error details](#select-error-details). |
| **`Terminate`** | This [**Terminate** action](../logic-apps/logic-apps-workflow-actions-triggers.md#terminate-action) stops the run for the workflow, cancels any actions in progress, skips any remaining actions, and returns the specified status, the session ID, and the error result from the `Select error details` action. For details, see [Terminate logic app](#terminate-logic-app). |

<a name="complete-template"></a>

## Complete the template

To provide the values for the trigger and actions in the **Correlated in-order delivery using service bus sessions** template, follow these steps. You have to provide all the required values, which are marked by an asterisk (**\***), before you can save your workflow.

<a name="initialize-session"></a>

### Initialize the session

- The template initializes sessions by using the **Session id** property. For the **When a message is received in a queue (peek-lock)** trigger, provide this information.

  :::image type="content" source="./media/send-related-messages-sequential-convoy/service-bus-check-message-peek-lock-trigger.png" alt-text="Screenshot shows the Service Bus trigger details for When a message is received in a queue (peek-lock).":::

  > [!NOTE]
  > Initially, the polling interval is set to three minutes so that the logic app doesn't run more frequently than you expect and result in unanticipated billing charges. Ideally, set the interval and frequency to 30 seconds so that the logic app triggers immediately when a message arrives.

  | Parameter | Required for this scenario | Value | Description |
  |-----------|----------------------------|-------|-------------|
  | **Queue name** | Yes | <*queue-name*> | The name for your previously created Service Bus queue. This example uses *Fabrikam-Service-Bus-Queue*. |
  | **Queue type** | Yes | **Main** | Your primary Service Bus queue |
  | **Session id** | Yes | **Next available** | This option gets a session for each trigger run, based on the session ID from the message in the Service Bus queue. The session is also locked so that no other logic app or other client can process messages that are related to this session. The workflow's subsequent actions process all the messages that are associated with that session, as described later in this article. <br><br>Here's more information about the other **Session id** options: <br>- **None**: The default option, which results in no sessions and can't be used for implementing the sequential convoy pattern. <br>- **Enter custom value**: Use this option when you know the session ID that you want to use, and you always want to run the trigger for that session ID. <br>**Note**: The Service Bus connector can save a limited number of unique sessions at a time from Azure Service Bus to the connector cache. If the session count exceeds this limit, old sessions are removed from the cache. For more information, see [Exchange messages in the cloud with Azure Logic Apps and Azure Service Bus](../connectors/connectors-create-api-servicebus.md#connector-reference). |
  | **Interval** | Yes | <*number-of-intervals*> | The number of time units between recurrences before checking for a message. |
  | **Frequency** | Yes | **Second**, **Minute**, **Hour**, **Day**, **Week**, or **Month** | The unit of time for the recurrence to use when checking for a message. <br>**Tip**: To add a **Time zone** or **Start time**, select these properties from **Advanced parameters**. |

  For more trigger information, see [Service Bus - When a message is received in a queue (peek-lock)](/connectors/servicebus/#when-a-message-is-received-in-a-queue-(peek-lock)). The trigger outputs a [ServiceBusMessage](/connectors/servicebus/#servicebusmessage).

After it initializes the session, the workflow uses the **Initialize variable** action to create a Boolean variable that initially set to `false` and indicates when the following conditions are true: 

- No more messages in the session are available to read.

- The session lock no longer needs to be renewed so that the current workflow instance can finish.

:::image type="content" source="./media/send-related-messages-sequential-convoy/init-is-done-variable.png" alt-text="Screenshot shows the Initialize Variable action details for Init isDone.":::

In the **Try** block, the workflow performs actions on the first message that it reads.

<a name="handle-initial-message"></a>

### Handle the initial message

The first action is a placeholder Service Bus action, **Send initial message to topic**. You can replace this action with any action that you want to handle the first message from the session in the queue. The session ID specifies the session from where the message originated.

The placeholder Service Bus action sends the first message to a Service Bus topic that's specified by the **Session Id** property. That way, all the messages that are associated with a specific session go to the same topic. All **Session Id** properties for subsequent actions in this template use the same session ID value.

:::image type="content" source="./media/send-related-messages-sequential-convoy/send-initial-message-to-topic-action.png" alt-text="Screenshot shows the Service Bus action details for Send initial message to topic.":::

1. In the Service Bus action **Complete initial message in queue**, provide the name for your Service Bus queue. Keep the other default property values in the action.

   :::image type="content" source="./media/send-related-messages-sequential-convoy/complete-initial-message-queue.png" alt-text="Screenshot shows the Service Bus action details for Complete initial message in queue.":::

1. In the Service Bus action **Abandon initial message from the queue**, provide the name for your Service Bus queue. Keep the other default property values in the action.

   :::image type="content" source="./media/send-related-messages-sequential-convoy/abandon-initial-message-from-queue.png" alt-text="Screenshot shows the Service Bus action details for Abandon initial message from the queue.":::

Next, provide the necessary information for the actions that follow the **Complete initial message in queue** action. Start with the actions in the **While there are more messages for the session in the queue** loop.

<a name="while-more-messages-for-session"></a>

### While there are more messages for the session in the queue

This [**Until** loop](../logic-apps/logic-apps-control-flow-loops.md#until-loop) runs these actions while messages exist in the queue or until one hour passes. To change the loop's time limit, edit the loop's **Timeout** property value.

- Get other messages from the queue while messages exist.

- Check the number of remaining messages. If messages still exist, continue processing messages. If no more messages exist, the workflow sets the `isDone` variable to `true`, and exits the loop.

:::image type="content" source="./media/send-related-messages-sequential-convoy/while-more-messages-for-session-in-queue.png" alt-text="Screenshot shows the Until loop process messages while in queue.":::

1. In the Service Bus action, **Get additional messages from session**, provide the name for your Service Bus queue. Keep the other default property values in the action.

   > [!NOTE]
   > By default, the maximum number of messages is set to `175`. The message size and maximum message size property affect this limit in Service Bus. For more information, see [Message size for a queue](../service-bus-messaging/service-bus-quotas.md).

   :::image type="content" source="./media/send-related-messages-sequential-convoy/get-additional-messages-from-session.png" alt-text="Screenshot shows the Service Bus action Get additional messages from session.":::

   The workflow splits into these parallel branches:

   - If an error or failure happens while checking for more messages, set the `isDone` variable to `true`.

   - The **Process messages if we got any** condition checks whether the number of remaining messages is zero. If false and more messages exist, continue processing. If true and no more messages exist, the workflow sets the `isDone` variable to `true`.

   :::image type="content" source="./media/send-related-messages-sequential-convoy/process-messages-if-any.png" alt-text="Screenshot shows the condition Process messages if any." lightbox="./media/send-related-messages-sequential-convoy/process-messages-if-any.png":::

   In the **If false** section, a **For each** loop processes each message in first-in, first-out order. In the loop's **Settings**, the **Concurrency Control** setting is set to `1`, so only a single message is processed at a time.

   :::image type="content" source="./media/send-related-messages-sequential-convoy/for-each-additional-message.png" alt-text="Screenshot shows the for-each loop process each message one at a time." lightbox="./media/send-related-messages-sequential-convoy/for-each-additional-message.png":::

1. For the Service Bus actions, **Complete the message in a queue** and **Abandon the message in a queue**, provide the name for your Service Bus queue.

   :::image type="content" source="./media/send-related-messages-sequential-convoy/abandon-or-complete-message-in-queue.png" alt-text="Screenshot shows the Service Bus actions Complete the message in a queue and Abandon the message in a queue." lightbox="./media/send-related-messages-sequential-convoy/abandon-or-complete-message-in-queue.png":::

   After **While there are more messages for the session in the queue** is done, the workflow sets the `isDone` variable to `true`.

Next, provide the necessary information for the actions in the **Renew session lock until cancelled** loop.

<a name="renew-session-while-messages-exist"></a>

### Renew session lock until cancelled

This [**Until** loop](../logic-apps/logic-apps-control-flow-loops.md#until-loop) makes sure that the session lock is held by this logic app while messages exist in the queue or until one hour passes by running these actions. To change the loop's time limit, edit the loop's **Timeout** property value.

- Delay for 25 seconds or an amount of time that's less than the lock timeout duration for the queue that's being processed. The smallest lock duration is 30 seconds, so the default value is enough. You can optimize the number of times that the loop runs by adjusting appropriately.

- Check whether the `isDone` variable is set to `true`.

  - If `isDone` is set to `true`, the workflow is still processing messages, so the workflow renews the lock on the session in the queue, and checks the loop condition again.

    You need to provide the name for your Service Bus queue in the Service Bus action, [**Renew lock on the session in a queue**](#renew-lock-on-session).

  - If `isDone` is set to `true`, the workflow doesn't renew the lock on the session in the queue, and exits the loop.

  :::image type="content" source="./media/send-related-messages-sequential-convoy/renew-lock-until-session-cancelled.png" alt-text="Screenshot shows the Until loop Renew session lock until cancelled.":::

<a name="renew-lock-on-session"></a>

#### Renew lock on the session in a queue

This Service Bus action renews the lock on the session in the queue while the workflow is still processing messages.

- In the Service Bus action, **Renew lock on the session in a queue**, provide the name for your Service Bus queue.

  :::image type="content" source="./media/send-related-messages-sequential-convoy/renew-lock-on-session-in-queue.png" alt-text="Screenshot shows the Service Bus action Renew lock on session in the queue." lightbox="./media/send-related-messages-sequential-convoy/renew-lock-on-session-in-queue.png":::

Next, provide the necessary information for the Service Bus action, **Close a session in a queue and succeed**.

<a name="close-session-succeed"></a>

### Close a session in a queue and succeed

This Service Bus action closes the session in the queue after either the workflow finishes processing all the available messages in the queue, or the workflow abandons the initial message.

- In the Service Bus action, **Close a session in a queue and succeed**, provide the name for your Service Bus queue.

  :::image type="content" source="./media/send-related-messages-sequential-convoy/close-session-in-queue-succeed.png" alt-text="Screenshot shows the Service Bus action Close a session in a queue and succeed." lightbox="./media/send-related-messages-sequential-convoy/close-session-in-queue-succeed.png":::

The following sections describe the actions in the `Catch` section, which handle errors and exceptions that happen in your workflow.

<a name="close-session-fail"></a>

### Close a session in a queue and fail

This Service Bus action always runs as the first action in the `Catch` scope and closes the session in the queue.

- In the Service Bus action, **Close a session in a queue and fail**, provide the name for your Service Bus queue.

  :::image type="content" source="./media/send-related-messages-sequential-convoy/close-session-in-queue-fail.png" alt-text="Screenshot shows the Service Bus action Close a session in a queue and fail." lightbox="./media/send-related-messages-sequential-convoy/close-session-in-queue-fail.png":::

The workflow creates an array that has the inputs and outputs from all the actions in the `Try` scope so that the logic app can access information about the error or failure that happened.

<a name="find-failure-message"></a>

### Find failure msg from 'Try' block

This [**Filter Array** action](../logic-apps/logic-apps-perform-data-operations.md#filter-array-action) creates an array that has the inputs and outputs from all the actions inside the `Try` scope based on the specified criteria by using the [`result()` function](../logic-apps/workflow-definition-language-functions-reference.md#result). In this case, this action returns the outputs from the actions that have `Failed` status by using the [`equals()` function](../logic-apps/workflow-definition-language-functions-reference.md#equals) and [`item()` function](../logic-apps/workflow-definition-language-functions-reference.md#item).

:::image type="content" source="./media/send-related-messages-sequential-convoy/find-failure-message.png" alt-text="Screenshot shows the Filter array action Find failure msg from Try block." lightbox="./media/send-related-messages-sequential-convoy/find-failure-message.png":::

Here's the JSON definition for this action:

```json
"Find_failure_msg_from_'Try'_block": {
   "inputs": {
      "from": "@Result('Try')",
      "where": "@equals(item()['status'], 'Failed')"
   },
   "runAfter": {
      "Close_the_session_in_the_queue_and_fail": [
         "Succeeded"
      ]
   },
   "type": "Query"
},
```

The workflow creates an array with a JSON object that contains the error information in the array returned from the `Find failure msg from 'Try' block` action.

<a name="select-error-details"></a>

### Select error details

This [**Select** action](../logic-apps/logic-apps-perform-data-operations.md#select-action) creates an array that contains JSON objects based on the input array that's output from the previous action, `Find failure msg from 'Try' block`. Specifically, this action returns an array that has only the specified properties for each object in the array. In this case, the array contains the action name and error result properties.

:::image type="content" source="./media/send-related-messages-sequential-convoy/select-error-details.png" alt-text="Screenshot shows the Select action Select error details." lightbox="./media/send-related-messages-sequential-convoy/select-error-details.png":::

Here's the JSON definition for this action:

```json
"Select_error_details": {
   "inputs": {
      "from": "@body('Find_failure_msg_from_''Try''_block')[0]['outputs']",
      "select": {
         "action": "@item()['name']",
         "errorResult": "@item()"
      }
   },
   "runAfter": {
      "Find_failure_msg_from_'Try'_block": [
         "Succeeded"
      ]
   },
   "type": "Select"
},
```

The workflow stops the logic app run and returns the run status along with more information about the error or failure that happened.

<a name="terminate-logic-app"></a>

### Terminate logic app run

This [**Terminate** action](../logic-apps/logic-apps-workflow-actions-triggers.md#terminate-action) stops the logic app run and returns `Failed` as the status for this run along with the session ID and the error result from the `Select error details` action.

:::image type="content" source="./media/send-related-messages-sequential-convoy/terminate-logic-app-run.png" alt-text="Screenshot shows the Terminate action to stop logic app run." lightbox="./media/send-related-messages-sequential-convoy/terminate-logic-app-run.png":::

Here's the JSON definition for this action:

```json
"Terminate": {
   "description": "This Failure Termination only runs if the Close Session upon Failure action runs - otherwise the LA will be terminated as Success",
   "inputs": {
      "runError": {
         "code": "",
         "message": "There was an error processing messages for Session ID @{triggerBody()?['SessionId']}. The following error(s) occurred: @{body('Select_error_details')['errorResult']}"
         },
         "runStatus": "Failed"
      },
      "runAfter": {
         "Select_error_details": [
            "Succeeded"
         ]
      },
      "type": "Terminate"
   }
},
```

## Save and run logic app

After you complete customizing the template, you can save your logic app. On the designer toolbar, select **Save**.

To test your logic app, send messages to your Service Bus queue. 

## Next step

- Learn more about the [Service Bus connector's triggers and actions](/connectors/servicebus/)
