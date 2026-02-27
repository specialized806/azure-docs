---
title: "Quickstart: Create an app with Durable Task SDKs and Durable Task Scheduler"
description: Learn how to build a fan-out/fan-in orchestration using the Durable Task SDKs with the Durable Task Scheduler emulator.
ms.topic: how-to
ms.date: 07/22/2025
zone_pivot_groups: df-languages
---

# Quickstart: Create an app with Durable Task SDKs and Durable Task Scheduler

In this quickstart, you use the Durable Task SDKs to build and run a [fan-out/fan-in orchestration](../durable-functions-fan-in-fan-out.md) locally with the Durable Task Scheduler emulator. The fan-out/fan-in pattern processes multiple work items in parallel and aggregates the results.

::: zone pivot="csharp,python,java,javascript"

> [!div class="checklist"]
>
> - Set up and run the Durable Task Scheduler emulator for local development.
> - Run the worker and client projects.
> - Review orchestration status and history in the Durable Task Scheduler dashboard.

## Prerequisites

Before you begin:

::: zone-end

::: zone pivot="csharp"

- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0) or later.
- [Docker](https://www.docker.com/products/docker-desktop/) for running the emulator.
- Clone the [Durable Task Scheduler samples repository](https://github.com/Azure-Samples/Durable-Task-Scheduler).

::: zone-end

::: zone pivot="python"

- [Python 3.9](https://www.python.org/downloads/) or later.
- [Docker](https://www.docker.com/products/docker-desktop/) for running the emulator.
- Clone the [Durable Task Scheduler samples repository](https://github.com/Azure-Samples/Durable-Task-Scheduler).

::: zone-end

::: zone pivot="java"

- [Java 21 SDK](https://www.java.com/en/download/) or later.
- [Docker](https://www.docker.com/products/docker-desktop/) for running the emulator.
- Clone the [Durable Task Scheduler samples repository](https://github.com/Azure-Samples/Durable-Task-Scheduler).

::: zone-end

::: zone pivot="javascript"

- [Node.js 22](https://nodejs.org/) or later.
- [Docker](https://www.docker.com/products/docker-desktop/) for running the emulator.
- Clone the [Durable Task Scheduler samples repository](https://github.com/Azure-Samples/Durable-Task-Scheduler).

::: zone-end

::: zone pivot="csharp,python,java,javascript"

## Set up the Durable Task Scheduler emulator

The emulator simulates a scheduler and task hub in a Docker container. If no deployed scheduler is found, the sample code automatically falls back to the emulator.

1. Pull the Docker image for the emulator.

     ```bash
     docker pull mcr.microsoft.com/dts/dts-emulator:latest
     ```

1. Run the emulator. The container might take a few seconds to be ready.

     ```bash
     docker run --name dtsemulator -d -p 8080:8080 -p 8082:8082 mcr.microsoft.com/dts/dts-emulator:latest
     ```

The sample code uses the default emulator settings, so you don't need to set any environment variables:

- Endpoint: `http://localhost:8080`
- Task hub: `default`

> [!TIP]
> The emulator is for local development and testing only. When you're ready to run in Azure, [create a Durable Task Scheduler and task hub resource in Azure](./develop-with-durable-task-scheduler.md).

## Run the quickstart

::: zone-end

::: zone pivot="csharp"

1. From the repository root, navigate to the sample directory.

     ```bash
     cd samples/durable-task-sdks/dotnet/FanOutFanIn
     ```

1. Start the worker.

     ```bash
     cd Worker
     dotnet run
     ```

1. In a separate terminal, from the `FanOutFanIn` directory, run the client.

     ```bash
     cd Client
     dotnet run
     ```

### Understanding the output

The worker output shows registration of the orchestrator and activities, log entries for each activity call, parallel processing of work items, and the final aggregation.

The client output shows the orchestration starting with a list of work items, the unique orchestration instance ID, and the final aggregated results with a total count of processed items.

#### Example output

```
Starting Fan-Out Fan-In Pattern - Parallel Processing Client
Using local emulator with no authentication
Starting parallel processing orchestration with 5 work items
Work items: ["Task1","Task2","Task3","LongerTask4","VeryLongTask5"]
Started orchestration with ID: 7f8e9a6b-1c2d-3e4f-5a6b-7c8d9e0f1a2b
Waiting for orchestration to complete...
Orchestration completed with status: Completed
Processing results:
Work item: Task1, Result: 5
Work item: Task2, Result: 5
Work item: Task3, Result: 5
Work item: LongerTask4, Result: 11
Work item: VeryLongTask5, Result: 13
Total items processed: 5
```

::: zone-end

::: zone pivot="python"

1. From the repository root, navigate to the sample directory.

     ```bash
     cd samples/durable-task-sdks/python/fan-out-fan-in
     ```

1. Create and activate a Python virtual environment.

      # [Linux/macOS](#tab/linux)

      ```bash
      python -m venv venv
      source ./venv/bin/activate
      ```

      # [Windows](#tab/windows)

      ```bash
      python -m venv venv
      venv\Scripts\activate
      ```

      ---

1. Install the required packages.

     ```bash
     pip install -r requirements.txt
     ```

1. Start the worker.

     ```bash
     python worker.py
     ```

1. In a new terminal, activate the virtual environment and run the client.

      # [Linux/macOS](#tab/linux)

      ```bash
      source ./venv/bin/activate
      python client.py
      ```

      # [Windows](#tab/windows)

      ```bash
      venv\Scripts\activate
      python client.py
      ```

      ---

     You can optionally specify the number of work items. The default is 10.

     ```bash
     python client.py 15
     ```

### Understanding the output

The worker output shows parallel processing of each work item with random delays (between 0.5 and 2 seconds) and the final aggregation of results.

The client output shows the orchestration starting with the specified number of work items, the unique orchestration instance ID, and the aggregated result, including total items, sum, and average.

#### Example output

```
Starting fan out/fan in orchestration with 10 items
Waiting for 10 parallel tasks to complete
Processing work item: 1
Processing work item: 2
Processing work item: 3
...
All parallel tasks completed, aggregating results
Aggregating results from 10 items
Orchestration completed with status: COMPLETED
```

::: zone-end

::: zone pivot="java"

1. From the repository root, navigate to the sample directory.

     ```bash
     cd samples/durable-task-sdks/java/fan-out-fan-in
     ```

1. Build and run the application using Gradle. The Java sample runs the worker and client in a single process.

     ```bash
     ./gradlew runFanOutFanInPattern
     ```

     > [!TIP]
     > If you get the error `zsh: permission denied: ./gradlew`, run `chmod +x gradlew` first.

### Understanding the output

The output shows the worker connecting, scheduling the orchestration, processing each word count activity in parallel, and returning the final aggregated word count.

#### Example output

```
> Task :runFanOutFanInPattern
Durable Task worker is connecting to sidecar at localhost:8080.
Started new orchestration instance
Orchestration completed: [Name: 'FanOutFanIn_WordCount', ID: '<instance-id>', RuntimeStatus: COMPLETED, CreatedAt: 2025-04-25T15:24:47.170Z, LastUpdatedAt: 2025-04-25T15:24:47.287Z, Input: '["Hello, world!","The quick brown fox jumps over t...', Output: '60']
Output: 60
```

::: zone-end

::: zone pivot="javascript"

1. From the repository root, navigate to the sample directory.

     ```bash
     cd samples/durable-task-sdks/javascript/fan-out-fan-in
     ```

1. Install dependencies.

     ```bash
     npm install
     ```

1. Start the worker.

     ```bash
     npm run worker
     ```

1. In a separate terminal, from the same directory, run the client.

     ```bash
     npm run client
     ```

     You can optionally specify the number of work items. The default is 10.

     ```bash
     npm run client -- 15
     ```

### Understanding the output

The worker output shows parallel execution of `processWorkItem` activities and aggregation through `aggregateResults`.

The client output shows the scheduled orchestration instance ID, the final runtime status, and the aggregated output JSON that contains total items, sum, average, and per-item results.

::: zone-end

::: zone pivot="csharp,python,java,javascript"

## View orchestration status and history

View the orchestration status and history through the [Durable Task Scheduler dashboard](./durable-task-scheduler-dashboard.md). The emulator runs the dashboard on port 8082.

1. Go to `http://localhost:8082` in your web browser.
1. Select the **default** task hub. The orchestration instance you created is in the list.
1. Select the orchestration instance ID to view execution details, including:
   - The parallel execution of multiple activity tasks
   - The fan-in aggregation step
   - The input and output at each step
   - The time taken for each step

::: zone-end

::: zone pivot="csharp"

:::image type="content" source="./media/quickstart-portable-durable-task-sdks/review-dashboard-dotnet.png" alt-text="Screenshot showing the orchestration instance's details for the .NET sample.":::

::: zone-end

::: zone pivot="python"

:::image type="content" source="./media/quickstart-portable-durable-task-sdks/review-dashboard-python.png" alt-text="Screenshot showing the orchestration instance's details for the Python sample.":::

::: zone-end

::: zone pivot="java"

:::image type="content" source="./media/quickstart-portable-durable-task-sdks/review-dashboard-java.png" alt-text="Screenshot showing the orchestration instance's details for the Java sample.":::

::: zone-end

::: zone pivot="csharp,python,java,javascript"

## Understand the code structure

::: zone-end

::: zone pivot="csharp"

Each sample has a **worker** (hosts the orchestration and activity logic) and a **client** (schedules and monitors orchestration instances).

### Worker

The worker registers an orchestration and two activities, then connects to the scheduler. The orchestration uses the fan-out/fan-in pattern to create a parallel task for each work item, wait for all tasks to complete, and then aggregate the results.

```csharp
public override async Task<Dictionary<string, int>> RunAsync(
    TaskOrchestrationContext context, List<string> workItems)
{
    // Fan out: create a task for each work item
    var processingTasks = new List<Task<Dictionary<string, int>>>();
    foreach (string workItem in workItems)
    {
        processingTasks.Add(
            context.CallActivityAsync<Dictionary<string, int>>(
                nameof(ProcessWorkItemActivity), workItem));
    }

    // Wait for all parallel tasks to complete
    Dictionary<string, int>[] results = await Task.WhenAll(processingTasks);

    // Fan in: aggregate all results
    return await context.CallActivityAsync<Dictionary<string, int>>(
        nameof(AggregateResultsActivity), results);
}
```

The worker uses `Microsoft.Extensions.Hosting` to register the orchestration and activities and connect to the scheduler.

```csharp
builder.Services.AddDurableTaskWorker()
    .AddTasks(registry =>
    {
        registry.AddOrchestrator<ParallelProcessingOrchestration>();
        registry.AddActivity<ProcessWorkItemActivity>();
        registry.AddActivity<AggregateResultsActivity>();
    })
    .UseDurableTaskScheduler(connectionString);
```

### Client

The client schedules an orchestration instance with a list of work items and waits for the result.

```csharp
List<string> workItems = new() { "Task1", "Task2", "Task3", "LongerTask4", "VeryLongTask5" };

string instanceId = await client.ScheduleNewOrchestrationInstanceAsync(
    "ParallelProcessingOrchestration", workItems);

OrchestrationMetadata instance = await client.WaitForInstanceCompletionAsync(
    instanceId, getInputsAndOutputs: true, cts.Token);
```

::: zone-end

::: zone pivot="python"

Each sample has a **worker** (hosts the orchestration and activity logic) and a **client** (schedules and monitors orchestration instances).

### Worker

The worker registers an orchestration and two activities, then connects to the scheduler. The orchestrator fans out by creating a parallel task for each work item, waits for all tasks to complete, and then fans in by aggregating the results.

```python
def fan_out_fan_in_orchestrator(ctx, work_items: list) -> dict:
    # Fan out: create a task for each work item
    parallel_tasks = []
    for item in work_items:
        parallel_tasks.append(ctx.call_activity("process_work_item", input=item))

    # Wait for all tasks to complete
    results = yield task.when_all(parallel_tasks)

    # Fan in: aggregate all the results
    final_result = yield ctx.call_activity("aggregate_results", input=results)
    return final_result
```

The worker connects to the scheduler using `DurableTaskSchedulerWorker`.

```python
from durabletask.azuremanaged.worker import DurableTaskSchedulerWorker

with DurableTaskSchedulerWorker(
    host_address=endpoint,
    secure_channel=endpoint != "http://localhost:8080",
    taskhub=taskhub_name,
    token_credential=credential
) as worker:
    worker.add_activity(process_work_item)
    worker.add_activity(aggregate_results)
    worker.add_orchestrator(fan_out_fan_in_orchestrator)
    worker.start()
```

### Client

The client schedules an orchestration instance with a list of work items and waits for the result.

```python
from durabletask.azuremanaged.client import DurableTaskSchedulerClient

client = DurableTaskSchedulerClient(
    host_address=endpoint,
    secure_channel=endpoint != "http://localhost:8080",
    taskhub=taskhub_name,
    token_credential=credential
)

instance_id = client.schedule_new_orchestration(
    "fan_out_fan_in_orchestrator", input=work_items)

result = client.wait_for_orchestration_completion(instance_id, timeout=60)
```

::: zone-end

::: zone pivot="java"

The Java sample runs the worker and client in a single process. The orchestrator fans out by scheduling a `CountWords` activity for each input string, waits for all tasks to complete, and then sums the results.

### Worker

```java
DurableTaskGrpcWorker worker = DurableTaskSchedulerWorkerExtensions
    .createWorkerBuilder(connectionString)
    .addOrchestration(new TaskOrchestrationFactory() {
        @Override
        public String getName() { return "FanOutFanIn_WordCount"; }

        @Override
        public TaskOrchestration create() {
            return ctx -> {
                List<?> inputs = ctx.getInput(List.class);
                List<Task<Integer>> tasks = inputs.stream()
                    .map(input -> ctx.callActivity(
                        "CountWords", input.toString(), Integer.class))
                    .collect(Collectors.toList());
                List<Integer> results = ctx.allOf(tasks).await();
                int totalWordCount = results.stream()
                    .mapToInt(Integer::intValue).sum();
                ctx.complete(totalWordCount);
            };
        }
    })
    .addActivity(new TaskActivityFactory() {
        @Override
        public String getName() { return "CountWords"; }

        @Override
        public TaskActivity create() {
            return ctx -> {
                String input = ctx.getInput(String.class);
                return new StringTokenizer(input).countTokens();
            };
        }
    })
    .build();

worker.start();
```

### Client

```java
DurableTaskClient client = DurableTaskSchedulerClientExtensions
    .createClientBuilder(connectionString).build();

List<String> listOfStrings = Arrays.asList(
    "Hello, world!",
    "The quick brown fox jumps over the lazy dog.",
    "If a tree falls in the forest and there is no one there to hear it, does it make a sound?",
    "The greatest glory in living lies not in never falling, but in rising every time we fall.",
    "Always remember that you are absolutely unique. Just like everyone else.");

String instanceId = client.scheduleNewOrchestrationInstance(
    "FanOutFanIn_WordCount",
    new NewOrchestrationInstanceOptions().setInput(listOfStrings));

OrchestrationMetadata completedInstance = client.waitForInstanceCompletion(
    instanceId, Duration.ofSeconds(30), true);
```

::: zone-end

::: zone pivot="javascript"

Each sample has a **worker** (hosts the orchestration and activity logic) and a **client** (schedules and monitors orchestration instances).

### Worker

The worker registers an orchestration and two activities, then connects to the scheduler. The orchestrator fans out by scheduling `processWorkItem` for each input, waits for all tasks to complete using `whenAll`, and then calls `aggregateResults` to produce the final output.

```javascript
import { whenAll } from "@microsoft/durabletask-js";
import { createAzureManagedWorkerBuilder } from "@microsoft/durabletask-js-azuremanaged";

const processWorkItem = async (_ctx, workItem) => {
  const item = Number(workItem);
  const delayMs = 500 + Math.floor(Math.random() * 1500);
  await new Promise((resolve) => setTimeout(resolve, delayMs));
  return { item, result: item * item };
};

const aggregateResults = async (_ctx, results) => {
  const sum = results.reduce((acc, cur) => acc + cur.result, 0);
  return { totalItems: results.length, sum, average: sum / results.length, results };
};

const fanOutFanInOrchestrator = async function* (ctx, workItems) {
  const tasks = workItems.map((item) => ctx.callActivity(processWorkItem, item));
  const processedResults = yield whenAll(tasks);
  return yield ctx.callActivity(aggregateResults, processedResults);
};

const worker = createAzureManagedWorkerBuilder(connectionString)
  .addOrchestrator(fanOutFanInOrchestrator)
  .addActivity(processWorkItem)
  .addActivity(aggregateResults)
  .build();

await worker.start();
```

### Client

The client schedules an orchestration instance with a list of work items and waits for the result.

```javascript
import { createAzureManagedClient } from "@microsoft/durabletask-js-azuremanaged";

const client = createAzureManagedClient(connectionString);

const workItems = Array.from({ length: 10 }, (_, i) => i + 1);
const instanceId = await client.scheduleNewOrchestration(
  "fanOutFanInOrchestrator", workItems);

const state = await client.waitForOrchestrationCompletion(instanceId, true, 120);
```

::: zone-end

::: zone pivot="csharp,python,java,javascript"

## Next steps

::: zone-end

Now that you've run the sample locally using the Durable Task Scheduler emulator, try creating a scheduler and task hub resource, and deploying to Azure Container Apps.

> [!div class="nextstepaction"]
> [Deploy Durable Task Scheduler hosted on Azure Container Apps to Azure](./quickstart-container-apps-durable-task-sdk.md)