---
title: Python developer reference for Azure Functions
description: Understand how to develop, validate, and deploy your Python code projects to Azure Functions using the Python library for Azure Functions.
ms.topic: article
ms.date: 12/29/2024
ms.devlang: python
ms.custom:
  - devx-track-python
  - devdivchpfy22
  - ignite-2024
  - build-2025
---

# Azure Functions Developer Reference Guide (Python)

Azure Functions is a serverless compute service that enables you to run event-driven code without provisioning or 
managing infrastructure. Functions are triggered by events such as HTTP requests, queue messages, timers, or 
changes in storage—and scale automatically based on demand.

This guide focuses specifically on building Python-based Azure Functions and is intended to help you:
- Create and run function apps locally
- Understand the Python v2 programming model
- Organize and configure your application
- Deploy and monitor your app in Azure
- Apply best practices for scaling and performance

If you’re new to Azure Functions, we recommend starting with the [Quickstart tutorials](TODO:link) in 
the next section.
> Looking for a conceptual overview? See the [Azure Functions Developer Reference](TODO:link).
>
> Interested in real-world use cases? Explore the [Scenarios & Samples](TODO:link) page.

## Getting Started
Jump into Azure Functions for Python with the most common entry points:

### Quickstarts
Choose the environment that fits your workflow:
- [Visual Studio Code](TODO:link)
- [Core Tools](TODO:link)
- [Portal](TODO:link)

---

## Building Your Function App 

### Programming Model
In the Python v2 programming model, Azure Functions uses a **decorator-based approach** to define triggers 
and bindings directly in your code. Each function is implemented as a **global, stateless method** within 
a `function_app.py` file.

**Example**
Here's a simple function that responds to an HTTP request:
```python
import azure.functions as func

app = func.FunctionApp()

@app.function_name(name="HttpTrigger1")
@app.route(route="req")
def http_trigger(req):
    user = req.params.get("user")
    return f"Hello, {user}!"
```
You can also use **type annotations** to improve IntelliSense and editor support:
```python
def http_trigger(req: func.HttpRequest) -> str:
```

### Organizing with Blueprints
For larger or modular apps, use **blueprints** to define functions in separate Python files 
and register them with your main app. This separation keeps your code organized and reusable.

**Step 1: Define a blueprint in another file (for example, `http_blueprint.py`):**
```python
import azure.functions as func

bp = func.Blueprint()

@bp.route(route="default_template")
def default_template(req: func.HttpRequest) -> func.HttpResponse:
    return func.HttpResponse("Hello World!")
```

**Step 2: Register the blueprint in `function_app.py`:**
```python
import azure.functions as func
from http_blueprint import bp

app = func.FunctionApp()
app.register_functions(bp)
```

Blueprints allow you to:
- Break up your app into reusable modules
- Keep related functions grouped by file or feature
- Extend or share blueprints across projects

> [!NOTE]
> Durable Functions also supports blueprints using [`azure-functions-durable`](https://pypi.org/project/azure-functions-durable). 
> [View sample →](https://github.com/Azure/azure-functions-durable-python/tree/dev/samples-v2/blueprint)

---

### Folder Structure
A Python Azure Functions project is recommended to have the following structure:

```cmd
<project_root>/
│
├── .venv/                   # (Optional) Local Python virtual environment
├── .vscode/                 # (Optional) VS Code workspace settings
│
├── function_app.py          # Main function entry point (decorator model)
├── shared/                  # (Optional) Pure helper code with no triggers/bindings
│   └── utils.py
│
├── additional_functions/    # (Optional) Contains blueprints for organizing related Functions
│   └── blueprint_1.py  
│
├── tests/                   # (Optional) Unit tests for your functions
│   └── test_my_function.py
│
├── .funcignore              # Excludes files from being published
├── host.json                # Global function app configuration
├── local.settings.json      # Local-only app settings (not published)
├── requirements.txt         # Python dependencies
├── Dockerfile               # (Optional) For custom container deployment
```

**Key Files and Folders**

| File / Folder           | Description                                                                                                  |
|-------------------------|--------------------------------------------------------------------------------------------------------------|
| `.venv/`                | (Optional) Local virtual environment for Python (excluded from deployment).                                  |
| `.vscode/`              | (Optional) Editor config for VS Code. Not required for deployment.                                           |
| `function_app.py`       | Main script where Azure Functions and triggers are defined using decorators.                                 |
| `shared/`               | (Optional) Holds helper code shared across the Function App project                                          |
| `additional_functions/` | (Optional) Used for modular code organization—typically with [blueprints](TODO:blueprints).                  |
| `tests/`                | (Optional) Unit tests for your function app. Not published to Azure.                                         |
| `.funcignore`           | Specifies files/folders to exclude from deployment (for example, `.venv/`, `tests/`, `local.settings.json`). |
| `host.json`             | Global configuration for all functions in the app. Required and published.                                   |
| `local.settings.json`   | Local-only app settings and secrets (never published).                                                       |
| `requirements.txt`      | Python dependencies installed during publish.                                                                |
| `Dockerfile`            | (Optional) Defines a custom container for deployment.                                                        |

**Deployment Notes**
- When you're deploying the app to Azure, the **contents** of your project folder are packaged—not the folder itself.
- Ensure `host.json` is at the **root of the deployment package**, not nested in a subfolder.
- Keep `tests/`, `.vscode/`, and `.venv/` excluded using `.funcignore`.
> For guidance on unit testing, see [Unit Testing](TODO:unit testing link).
> For container deployments, see [Deploy with custom containers](TODO:link)

---

### Triggers & Bindings
Azure Functions uses **triggers** to start function execution and **bindings** to connect your code to other services 
like storage, queues, and databases. Bindings are declared using decorators in the Python v2 programming model.

There are two main types of bindings:
- **Triggers** (input that starts the function)
- **Inputs & Outputs** (extra data sources or destinations)

Bindings rely on connection strings, which are typically defined in `local.settings.json` for local development, 
and in application settings when deployed to Azure.

**Example: HTTP Trigger with Cosmos DB Input and Event Hub Output**
This function:
- Triggers on an HTTP request
- Reads from a Cosmos DB
- Writes to an Event Hub output
- Returns an HTTP response

```python
import azure.functions as func
import logging

app = func.FunctionApp()

@app.function_name(name="HttpTriggerWithCosmosDB")
@app.route(route="file")
@app.cosmos_db_input(
    arg_name="docs",
    database_name="test",
    container_name="items",
    id="cosmosdb-input-test",
    connection="COSMOSDB_CONNECTION_SETTING")
@app.event_hub_output(arg_name="event",
                      event_hub_name="my-test-eventhub",
                      connection="EVENTHUB_CONNECTION_SETTING")
def http_trigger_with_cosmosdb(req: func.HttpRequest, documents: func.DocumentList, event: func.Out[str]) -> func.HttpResponse:
    logging.info(f"Executing function...")
    
    http_content = req.params.get('body') # Content from HttpRequest
    doc_id = documents[0]['id'] # Content from CosmosDB input

    event.set("HttpRequest content: " + http_content + " | CosmosDB ID: " + doc_id)
    
    return func.HttpResponse(
        f"Function executed successfully.",
        status_code=200
    )
```
**Key Concepts**
- Use `@route()` or trigger-specific decorators (`@timer_trigger`, `@queue_trigger`, etc.) to define how your function is invoked.
- Inputs are added via decorators like `@blob_input`, `@queue_input`, etc.
- Outputs can be:
   - Returned directly (if only one output)
   - Assigned using `Out` bindings and the `.set()` method for multiple outputs.
- You can access request details via the `HttpRequest` object and construct a custom `HttpResponse` with headers, status code, and body.


**Example: Timer Trigger with Blob Input**
This function:
- Triggers every 10 minutes
- Reads from a Blob using [SDK Type Bindings](TODO:link)
- Writes to a temporary file in `tmp/`
- Accesses the function invocation ID
- Uses global and environment variables

```python
import azure.functions as func
import azurefunctions.extensions.bindings.blob as blob

import logging
import os
import tempfile

CACHED_BLOB_DATA = None

app = func.FunctionApp()

@app.function_name(name="TimerTriggerWithBlob")
@app.schedule(schedule="0 */10 * * * *",
              arg_name="mytimer",
              run_on_startup=False,
              use_monitor=False)
@app.blob_input(arg_name="client",
                path="PATH/TO/BLOB",
                connection="BLOB_CONNECTION_SETTING")
def timer_trigger_with_blob(mytimer: func.TimerRequest, client: blob.BlobClient, context: func.Context) -> None:
    logging.info(f"Executing function...")
    
    global CACHED_BLOB_DATA
    if CACHED_BLOB_DATA is None:
        CACHED_BLOB_DATA = client.download_blob(encoding='utf-8').readall() # Set global variable
        temp_file_path = tempfile.gettempdir()
        temp_file = tempfile.NamedTemporaryFile()
        temp_file.write(CACHED_BLOB_DATA)
        logging.info(f"Files list: {os.listdir(temp_file_path)}")

    invocation_id = context.invocation_id # Content from `context` arg
    logging.info(f'Current function invocation ID:{invocation_id}')

    my_app_setting_value = os.environ["myAppSetting"] # Reading from a setting named 'myAppSetting'
    my_second_app_setting = os.getenv("mySecondAppSetting") # Reading from a setting named 'mySecondAppSetting'
    logging.info(f'My app setting value:{my_app_setting_value}, and my second app setting value: {my_second_app_setting}')
    
    
```
**Key Concepts**
- SDK type Bindings are used to work with rich types. See more: [SDK type bindings](TODO:link).
- Global variables can be used to cache expensive computations, but their state isn’t guaranteed to persist across function executions.
- Use `tempfile.getemptydir()`, which returns `tmp/`, to store temporary files. However, those files aren't guaranteed to persist across invocations or scale-out instances.
- Invocation context of a function can be accessed through the [Context class](TODO:link).
- [Application Settings](TODO:link) are exposed as environment variables when the app is running. You can access them through `os.environ[]` or `os.getenv()`. For local development,
app settings are [maintained in the local.settings.json file](TODO:link).

### SDK type bindings
For select triggers and bindings, you can work with data types implemented by the underlying Azure SDKs and 
frameworks. These _SDK type bindings_ let you interact binding data as if you were using the underlying service 
SDK.
> [!IMPORTANT]  
> SDK type bindings support for Python is only supported in the Python v2 programming model.

**Prerequisites**
* [Azure Functions runtime version](functions-versions.md?pivots=programming-language-python) version 4.34, or a later version.
* A [supported version](#supported-python-versions) of [Python](https://www.python.org/downloads/).

**SDK Types**

| Service                                   | Trigger                          | Input binding                 | Output binding                           | Samples                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
|-------------------------------------------|----------------------------------|-------------------------------|------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [Azure Blobs][blob-sdk-types]             | **Generally available**          | **Generally available**       | _SDK types not recommended.<sup>1</sup>_ | [Quickstart](https://github.com/Azure-Samples/azure-functions-blob-sdk-bindings-python),<br/>[`BlobClient`](https://github.com/Azure/azure-functions-python-extensions/blob/dev/azurefunctions-extensions-bindings-blob/samples/blob_samples_blobclient/function_app.py),<br/>[`ContainerClient`](https://github.com/Azure/azure-functions-python-extensions/blob/dev/azurefunctions-extensions-bindings-blob/samples/blob_samples_containerclient/function_app.py),<br/>[`StorageStreamDownloader`](https://github.com/Azure/azure-functions-python-extensions/blob/dev/azurefunctions-extensions-bindings-blob/samples/blob_samples_storagestreamdownloader/function_app.py)             |
| [Azure Cosmos DB][cosmos-sdk-types]       | _SDK types not used<sup>2</sup>_ | **Preview**                   | _SDK types not recommended.<sup>1</sup>_ | [Quickstart](https://github.com/Azure-Samples/azure-functions-cosmosdb-sdk-bindings-python), <br/> [`ContainerProxy`](https://github.com/Azure/azure-functions-python-extensions/blob/dev/azurefunctions-extensions-bindings-cosmosdb/samples/cosmosdb_samples_containerproxy/function_app.py),<br/>[`CosmosClient`](https://github.com/Azure/azure-functions-python-extensions/tree/dev/azurefunctions-extensions-bindings-cosmosdb/samples/cosmosdb_samples_cosmosclient/function_app.py),<br/>[`DatabaseProxy`](https://github.com/Azure/azure-functions-python-extensions/tree/dev/azurefunctions-extensions-bindings-cosmosdb/samples/cosmosdb_samples_databaseproxy/function_app.py) |
| [Azure Event Hubs][eventhub-sdk-types]    | **Preview**                      | _Input binding doesn't exist_ | _SDK types not recommended.<sup>1</sup>_ | [Quickstart](https://github.com/Azure-Samples/azure-functions-eventhub-sdk-bindings-python), <br/> [`EventData`](https://github.com/Azure/azure-functions-python-extensions/blob/dev/azurefunctions-extensions-bindings-eventhub/samples/eventhub_samples_eventdata/function_app.py)                                                                                                                                                                                                                                                                                                                                                                                                       |
| [Azure Service Bus][servicebus-sdk-types] | **Preview**                      | _Input binding doesn't exist_ | _SDK types not recommended.<sup>1</sup>_ | [Quickstart](https://github.com/Azure/azure-functions-python-extensions/blob/dev/azurefunctions-extensions-bindings-servicebus/samples/README.md), <br/> [`ServiceBusReceivedMessage`](https://github.com/Azure/azure-functions-python-extensions/blob/dev/azurefunctions-extensions-bindings-servicebus/samples/servicebus_samples_single/function_app.py)                                                                                                                                                                                                                                                                                                                                |

[blob-sdk-types]: ./functions-bindings-storage-blob.md?pivots=programming-language-python#sdk-binding-types
[cosmos-sdk-types]: ./functions-bindings-cosmosdb-v2.md?pivots=programming-language-python#sdk-binding-types
[eventhub-sdk-types]: ./functions-bindings-event-hubs.md
[servicebus-sdk-types]: ./functions-bindings-service-bus.md?pivots=programming-language-python#sdk-binding-types
<sup>1</sup> For output scenarios in which you would use an SDK type, you should create and work with SDK clients directly instead of using an output binding.
<sup>2</sup> The Cosmos DB trigger uses the [Azure Cosmos DB change feed](/azure/cosmos-db/change-feed) and exposes change feed items as JSON-serializable types. The absence of SDK types is by-design for this scenario.

### Learn More
For a full list of supported triggers and bindings, configuration options, and code examples, 
see the [Triggers & Bindings reference page](TODO:link).
- For secure connection handling, see [Connections](TODO:link).
- For optimizing storage use, see [Storage account guidance](TODO:link).

### Package Management
To use third-party Python packages in your Azure Functions app, list them in a requirements.txt file at the root of your project. Those packages can then be referenced 
To learn more about building and deployment options with external dependencies, see [Deployment Options for Python Function Apps](TODO:link).

For example, the following sample shows how the `requests` module is included and used in the function app.
```text
<requirements.txt>
requests==2.31.0
```
Install the package locally with `pip install -r requirements.txt`.

Once the package is installed, you can import and use it in your function code:
```python
import azure.functions as func
import requests

app = func.FunctionApp()

@app.function_name(name="HttpExample")
@app.route(route="call_api")
def main(req: func.HttpRequest) -> func.HttpResponse:
    r = requests.get("https://api.github.com")
    return func.HttpResponse(f"Status: {r.status_code}")
```

**Key Considerations:**
- Conflicts with built-in modules:
   - Avoid naming your project folders after Python standard libraries (for example, `email/`, `json/`).
   - Don't include Python native libraries (like `logging`) in `requirements.txt.`
- Deployment:
   - To prevent ModuleNotFound errors, you should ensure all required dependencies are listed in `requirements.txt`.
   - If you update your app's Python version, you should rebuild and redeploy your app on the new Python version to avoid dependency conflicts with previously built packages.
- Non-PyPI Dependencies:
   - You can include dependencies that aren’t available on PyPI in your app. For example, this can include local packages, wheel files, or private feeds. See [Custom dependencies in Python  Azure Functions](TODO: link) for setup instructions.

---

## Running and Deploying

### Supported Python Versions
Azure Functions supports the following Python versions:

| Functions version |          Python\* versions           |
|-------------------|:------------------------------------:|
| 4.x               | 3.13<br/>3.12<br/>3.11<br/>3.10<br/> |

\* Official Python distributions

For more general information, see the [Azure Functions runtime support policy](./language-support-policy.md) 
and [Supported languages in Azure Functions](./supported-languages.md).

### Deployment
Learn more about the recommended deployment mechanism for your scenario: [Deployment Options](TODO:link)

---

## Observability and Testing

### Logging and Monitoring
Azure Functions exposes a root logger that you can use directly with Python’s built-in `logging` module. Any 
messages written using this logger are automatically sent to **Application Insights** when your app is running 
in Azure.

Logging allows you to capture runtime information and diagnose issues without needing any more setup.
**Logging Example with an HTTP Trigger**
```python
import logging
import azure.functions as func

app = func.FunctionApp()

@app.route(route="http_trigger")
def http_trigger(req) -> func.HttpResponse:
    logging.debug("Example debug log")
    logging.info("Example info log")
    logging.warning("Example warning")
    logging.error("Example error log")
    return func.HttpResponse("OK")
```
You can use the full set of logging levels (`debug`, `info`, `warning`, `error`, `critical`), and they appear 
in the Azure portal under Logs or Application Insights. For `debug` logs to appear, more setup is required. For more information, see [Enable Debug Logging in Python Function Apps](TODO:link).

To learn more about monitoring Azure Functions in the portal, see [Monitor Azure Functions](TODO:link).

**Logging from Background Threads**
If your function starts a new thread and needs to log from that thread, make sure to pass the `context` 
argument into the thread. The `context` contains thread-local storage and the current `invocation_id`, 
which must be set on the worker thread in order for logs to be associated properly with the function execution.
```python
import azure.functions as func
import logging
import threading

def main(req, context):
    logging.info("Function started")
    t = threading.Thread(target=log_from_thread, args=(context,))
    t.start()

def log_from_thread(context):
    # Associate the thread with the current invocation
    context.thread_local_storage.invocation_id = context.invocation_id  
    logging.info("Logging from a background thread")
```

### OpenTelemetry Support
Azure Functions for Python also supports **OpenTelemetry**, which enables you to emit traces, metrics, and logs 
in a standardized format. Using OpenTelemetry is especially valuable for distributed applications or scenarios where you want 
to export telemetry to tools outside of Application Insights (such as Grafana or Jaeger).
> See our [OpenTelemetry Quickstart for Azure Functions (Python)](TODO:link) for setup instructions and sample code.

### Unit Testing
Write and run unit tests for your functions using `pytest` or invoking the function directly.
→ [Guide: Unit Testing in Python Azure Functions](TODO:link)

---

## Optimization and Advanced Topics
- Scaling & Performance
- Web Frameworks
- Durable Functions
- HTTP Streaming

---

## Next Steps
- azure-functions API documentation
- Best Practices for Azure Functions
- HTTP and webhook bindings
