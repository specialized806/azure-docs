---
title: Python developer reference for Azure Functions
description: Understand how to develop, validate, and deploy your Python code projects to Azure Functions using the Python library for Azure Functions.
ms.topic: article
ms.date: 11/09/2025
ms.devlang: python
ms.custom:
  - devx-track-python
  - devdivchpfy22
  - ignite-2024
  - build-2025
  - py-devguide-refactor
zone_pivot_groups: python-mode-functions
#customer intent: As a Python developer, I want to reference the supported features, syntax, and limitations for developing Azure Functions so that I can build and deploy Python serverless apps effectively.
---

# Azure Functions Developer Reference Guide (Python)

Azure Functions is a serverless compute service that enables you to run event-driven code without provisioning or managing infrastructure. Function executions are triggered by events such as HTTP requests, queue messages, timers, or changes in storage—and scale automatically based on demand.

This guide focuses specifically on building Python-based Azure Functions and helps you:
- Create and run function apps locally
- Understand the Python v2 programming model
- Organize and configure your application
- Deploy and monitor your app in Azure
- Apply best practices for scaling and performance

If you're new to Azure Functions, start with the [Quickstart tutorials](#getting-started) in 
the next section.
> Looking for a conceptual overview? See the [Azure Functions Developer Reference](functions-reference.md).
>
> Interested in real-world use cases? Explore the [Scenarios & Samples](functions-scenarios.md?pivots=programming-language-python) page.

## Getting started
Choose the environment that fits your workflow and jump into Azure Functions for Python:
::: zone pivot="python-mode-configuration"
- [Visual Studio Code Quickstart](./how-to-create-function-vs-code.md?pivot=programming-language-python?pivots=python-mode-configuration)
- [Core Tools Quickstart](./how-to-create-function-azure-cli.md?pivots=programming-language-python,python-mode-configuration)
::: zone-end  
::: zone pivot="python-mode-decorators"
- [Visual Studio Code Quickstart](./how-to-create-function-vs-code.md?pivot=programming-language-python?pivots=python-mode-decorators)
- [Core Tools Quickstart](./how-to-create-function-azure-cli.md?pivots=programming-language-python,python-mode-decorators)
::: zone-end  

---

## Building your function app

This section covers the essential components for creating and structuring your Python function app, including programming models, project organization, triggers, bindings, and dependency management.

### Programming model
::: zone pivot="python-mode-configuration"
In the Python v1 programming model, each function is defined as a global, stateless `main()` method inside a file named `__init__.py`.
The function’s triggers and bindings are configured separately in a `function.json` file, and the binding `name` values are used as parameters in your `main()` method.

**Example**

Here's a simple function that responds to an HTTP request:
```python
# __init__.py
def main(req):
    user = req.params.get('user')
    return f'Hello, {user}!'
```

Here's the corresponding `function.json` file:
:::code language="json" source="~/functions-quickstart-templates/Functions.Templates/Templates/HttpTrigger-Python/function.json":::

You can also use **type annotations** to improve IntelliSense and editor support:
```python
def http_trigger(req: func.HttpRequest) -> str:
```

### Alternative entry point

You can change the default behavior of a function by optionally specifying the `scriptFile` and `entryPoint` properties in the `function.json` file. For example, 
the following `function.json` tells the runtime to use the `custom_entry()` method in the `main.py` file as the entry point for your Azure function.

```json
{
  "scriptFile": "main.py",
  "entryPoint": "custom_entry",
  "bindings": [
      ...
  ]
}
```

### Folder structure
Use the following structure for a Python Azure Functions project:

```cmd
<project_root>/
│
├── .venv/                   # (Optional) Local Python virtual environment
├── .vscode/                 # (Optional) VS Code workspace settings
│
├── my_first_function/       # Function directory
│   └── __init__.py          # Function code file
│   └── function.json        # Function binding configuration file
│
├── my_second_function/
│   └── __init__.py  
│   └── function.json 
│
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

#### Key files and folders

| File / Folder           | Description                                                                                                  | Required in production             |
|-------------------------|--------------------------------------------------------------------------------------------------------------|------------------------------------|
| `.venv/`                | Local virtual environment for Python (excluded from deployment).                                             | ❌                                  |
| `.vscode/`              | Editor config for Visual Studio Code. Not required for deployment.                                           | ❌                                  |
| `my_first_function/`    | Directory for a single function.                                                                             | ✅                                  |
| `__init__.py/`          | Main script where the `my_first_function` function code is defined.                                          | ✅                                  |
| `function.json/`        | Contains the binding configuration for the `my_first_function` function.                                     | ✅                                  |
| `shared/`               | Holds helper code shared across the Function App project                                                     | ❌                                  |
| `additional_functions/` | Used for modular code organization—typically with [blueprints](#organizing-with-blueprints).                 | ❌                                  |
| `tests/`                | Unit tests for your function app. Not published to Azure.                                                    | ❌                                  |
| `.funcignore`           | Specifies files and folders to exclude from deployment (for example, `.venv/`, `tests/`, `local.settings.json`). | ❌ (recommended)                    |
| `host.json`             | Global configuration for all functions in the app. Required and published.                                   | ✅                                  |
| `local.settings.json`   | Local-only app settings and secrets (never published).                                                       | ❌ (required for local development) |
| `requirements.txt`      | Python dependencies installed during publish.                                                                | ✅                                  |
| `Dockerfile`            | Defines a custom container for deployment.                                                                   | ❌                                  |

#### Deployment considerations
- When you deploy the app to Azure, you package the contents of your project folder and not the folder itself.
- Ensure `host.json` is at the **root of the deployment package**, not nested in a subfolder.
- Keep `tests/`, `.vscode/`, and `.venv/` excluded by using `.funcignore`.
> For guidance on unit testing, see [Unit Testing](./python-testing.md).
> For container deployments, see [Deploy with custom containers](./functions-how-to-custom-container.md).

::: zone-end
::: zone pivot="python-mode-decorators"
In the Python v2 programming model, Azure Functions uses a **decorator-based approach** to define triggers 
and bindings directly in your code. Each function is implemented as a **global, stateless method** within 
a `function_app.py` file.

**Example**

Here's a simple function that responds to an HTTP request:
```python
import azure.functions as func

app = func.FunctionApp()

@app.function_name(name="HttpTrigger1")
@app.route(route="http_trigger")
def http_trigger(req):
    user = req.params.get("user")
    return f"Hello, {user}!"
```
You can also use **type annotations** to improve IntelliSense and editor support:
```python
def http_trigger(req: func.HttpRequest) -> str:
```

### Organizing with blueprints
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

With blueprints, you can:
- Break up your app into reusable modules
- Keep related functions grouped by file or feature
- Extend or share blueprints across projects

> [!NOTE]
> Durable Functions also supports blueprints using [`azure-functions-durable`](https://pypi.org/project/azure-functions-durable). 
> [View sample →](https://github.com/Azure/azure-functions-durable-python/tree/dev/samples-v2/blueprint)

---

### Folder structure
Use the following structure for a Python Azure Functions project:

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

#### Key files and folders

| File / Folder           | Description                                                                                                  | Required in production             |
|-------------------------|--------------------------------------------------------------------------------------------------------------|------------------------------------|
| `.venv/`                | Local virtual environment for Python (excluded from deployment).                                             | ❌                                  |
| `.vscode/`              | Editor config for Visual Studio Code. Not required for deployment.                                           | ❌                                  |
| `function_app.py`       | Main script where Azure Functions and triggers are defined using decorators.                                 | ✅                                  |
| `shared/`               | Holds helper code shared across the Function App project                                                     | ❌                                  |
| `additional_functions/` | Used for modular code organization—typically with [blueprints](#organizing-with-blueprints).                 | ❌                                  |
| `tests/`                | Unit tests for your function app. Not published to Azure.                                                    | ❌                                  |
| `.funcignore`           | Specifies files and folders to exclude from deployment (for example, `.venv/`, `tests/`, `local.settings.json`). | ❌ (recommended)                    |
| `host.json`             | Global configuration for all functions in the app. Required and published.                                   | ✅                                  |
| `local.settings.json`   | Local-only app settings and secrets (never published).                                                       | ❌ (required for local development) |
| `requirements.txt`      | Python dependencies installed during publish.                                                                | ✅                                  |
| `Dockerfile`            | Defines a custom container for deployment.                                                                   | ❌                                  |

#### Deployment considerations
- When you deploy the app to Azure, you package the contents of your project folder and not the folder itself.
- Ensure `host.json` is at the **root of the deployment package**, not nested in a subfolder.
- Keep `tests/`, `.vscode/`, and `.venv/` excluded by using `.funcignore`.
> For guidance on unit testing, see [Unit Testing](./python-testing.md).
> For container deployments, see [Deploy with custom containers](./functions-how-to-custom-container.md).

::: zone-end

---

### Triggers and bindings
Azure Functions uses **triggers** to start function execution and **bindings** to connect your code to other services 
like storage, queues, and databases. In the Python v2 programming model, you declare bindings by using decorators.

There are two main types of bindings:
- **Triggers** (input that starts the function)
- **Inputs and outputs** (extra data sources or destinations)

To learn more about the available triggers and bindings, see [Triggers and Bindings in Azure Functions](./functions-triggers-bindings.md).

**Example: HTTP Trigger with Cosmos DB Input and Event Hub Output**

This function:
- Triggers on an HTTP request
- Reads from a Cosmos DB
- Writes to an Event Hub output
- Returns an HTTP response

::: zone pivot="python-mode-configuration"
```python
# __init__.py
import azure.functions as func

def main(req: func.HttpRequest,
         documents: func.DocumentList,
         event: func.Out[str]) -> func.HttpResponse:
    
    # Content from HttpRequest and Cosmos DB input
    http_content = req.params.get("body")
    doc_id = documents[0]["id"] if documents else "No documents found"

    event.set(f"HttpRequest content: {http_content} | CosmosDB ID: {doc_id}")

    return func.HttpResponse(
        "Function executed successfully.",
        status_code=200
    )
```

```json
// function.json
{
  "scriptFile": "__init__.py",
  "entryPoint": "main",
  "bindings": [
    {
      "type": "httpTrigger",
      "direction": "in",
      "name": "req",
      "methods": ["get", "post"],
      "route": "file"
    },
    {
      "type": "http",
      "direction": "out",
      "name": "$return"
    },
    {
      "type": "cosmosDB",
      "direction": "in",
      "name": "documents",
      "databaseName": "test",
      "containerName": "items",
      "id": "cosmosdb-input-test",
      "connection": "COSMOSDB_CONNECTION_SETTING"
    },
    {
      "type": "eventHub",
      "direction": "out",
      "name": "event",
      "eventHubName": "my-test-eventhub",
      "connection": "EVENTHUB_CONNECTION_SETTING"
    }
  ]
}

```

#### Key concepts
- Each function has a single trigger, but it can have multiple bindings.
- Add inputs by specifying the `direction` as "in" in `function.json`. Outputs have a `direction` of `out`.
- You can access request details through the `HttpRequest` object and construct a custom `HttpResponse` with headers, status code, and body.

::: zone-end

::: zone pivot="python-mode-decorators"
```python
import azure.functions as func

app = func.FunctionApp()

@app.function_name(name="HttpTriggerWithCosmosDB")
@app.route(route="file")
@app.cosmos_db_input(arg_name="documents",
                     database_name="test",
                     container_name="items",
                     connection="COSMOSDB_CONNECTION_SETTING")
@app.event_hub_output(arg_name="event",
                      event_hub_name="my-test-eventhub",
                      connection="EVENTHUB_CONNECTION_SETTING")
def http_trigger_with_cosmosdb(req: func.HttpRequest,
                               documents: func.DocumentList,
                               event: func.Out[str]) -> func.HttpResponse:
    # Content from HttpRequest and Cosmos DB input
    http_content = req.params.get('body')
    doc_id = documents[0]['id']

    event.set("HttpRequest content: " + http_content
              + " | CosmosDB ID: " + doc_id)
    
    return func.HttpResponse(
        f"Function executed successfully.",
        status_code=200
    )
```
#### Key concepts
- Use `@route()` or trigger-specific decorators (`@timer_trigger`, `@queue_trigger`, etc.) to define how your function is invoked.
- Add inputs by using decorators like `@blob_input`, `@queue_input`, and others.
- Outputs can be:
   - Returned directly (if only one output)
   - Assigned by using `Out` bindings and the `.set()` method for multiple outputs.
- You can access request details through the `HttpRequest` object and construct a custom `HttpResponse` with headers, status code, and body.


**Example: Timer Trigger with Blob Input**

This function:
- Triggers every 10 minutes
- Reads from a Blob by using [SDK Type Bindings](#sdk-type-bindings)
- Caches results and writes to a temporary file

```python
import azure.functions as func
import azurefunctions.extensions.bindings.blob as blob
import logging
import os
import tempfile

CACHED_BLOB_DATA = None

app = func.FunctionApp()

@app.function_name(name="TimerTriggerWithBlob")
@app.schedule(schedule="0 */10 * * * *", arg_name="mytimer")
@app.blob_input(arg_name="client",
                path="PATH/TO/BLOB",
                connection="BLOB_CONNECTION_SETTING")
def timer_trigger_with_blob(mytimer: func.TimerRequest,
                            client: blob.BlobClient,
                            context: func.Context) -> None:
    global CACHED_BLOB_DATA
    if CACHED_BLOB_DATA is None:
        # Download blob and save as a global variable
        CACHED_BLOB_DATA = client.download_blob().readall()

        # Create temp file prefix
        my_prefix = context.invocation_id
        temp_file = tempfile.NamedTemporaryFile(prefix=my_prefix)
        temp_file.write(CACHED_BLOB_DATA)
        logging.info(f"Cached data written to {temp_file.name}")
```
#### Key concepts
- Use SDK type bindings to work with rich types. For more information, see [SDK type bindings](#sdk-type-bindings).
- You can use global variables to cache expensive computations, but their state isn't guaranteed to persist across function executions.
- Temporary files are stored in `tmp/` and aren't guaranteed to persist across invocations or scale-out instances.
- You can access the invocation context of a function through the [Context class](/python/api/azure-functions/azure.functions.context).

### SDK type bindings
For select triggers and bindings, you can work with data types implemented by the underlying Azure SDKs and 
frameworks. These _SDK type bindings_ let you interact with binding data as if you were using the underlying service 
SDK.
> [!IMPORTANT]  
> SDK type bindings support for Python is only supported in the Python v2 programming model.


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
<sup>1</sup> For output scenarios in which you would use an SDK type, create and work with SDK clients directly instead of using an output binding.
<sup>2</sup> The Cosmos DB trigger uses the [Azure Cosmos DB change feed](/azure/cosmos-db/change-feed) and exposes change feed items as JSON-serializable types. The absence of SDK types is by-design for this scenario.
::: zone-end

### Environment variables
Environment variables in Azure Functions let you securely manage configuration values, connection strings, and app secrets without hardcoding them in your function code.

You can define environment variables:
- Locally: in the [local.settings.json file](functions-develop-local.md#local-settings-file)] file during local development.
- In Azure: as [Application Settings](functions-how-to-use-azure-function-app-settings.md#settings) in your Function App’s configuration page in the Azure portal.

You can access the variables directly in your code by using `os.environ` or `os.getenv`.
```python
setting_value = os.getenv("myAppSetting", "default_value")
```


### Package management

To use other Python packages in your Azure Functions app, list them in a `requirements.txt` file at the root of your project. You can then reference those packages as usual.
To learn more about building and deployment options with external dependencies, see [Deployment Options for Python Function Apps](./python-deployments.md).

For example, the following sample shows how the `requests` module is included and used in the function app.
```text
<requirements.txt>
requests==2.31.0
```
Install the package locally with `pip install -r requirements.txt`.

Once the package is installed, you can import and use it in your function code:

::: zone pivot="python-mode-configuration"

```python
import azure.functions as func
import requests

def main(req: func.HttpRequest) -> func.HttpResponse:
    r = requests.get("https://api.github.com")
    return func.HttpResponse(f"Status: {r.status_code}")
```

::: zone-end

::: zone pivot="python-mode-decorators"

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

::: zone-end

### Considerations
- Conflicts with built-in modules:
   - Avoid naming your project folders after Python standard libraries (for example, `email/`, `json/`).
   - Don't include Python native libraries (like `logging`) in `requirements.txt.`
- Deployment:
   - To prevent `ModuleNotFound` errors, ensure all required dependencies are listed in `requirements.txt`.
   - If you update your app's Python version, rebuild and redeploy your app on the new Python version to avoid dependency conflicts with previously built packages.
- Non-PyPI Dependencies:
   - You can include dependencies that aren't available on PyPI in your app, such as local packages, wheel files, or private feeds. See [Custom dependencies in Python  Azure Functions](./python-deployments.md#custom-dependencies) for setup instructions.

---

## Running and deploying

This section provides information about Python version support, deployment options, and runtime configuration to help you successfully run your function app in both local and Azure environments.

### Supported Python versions
Azure Functions supports the following Python versions:

| Functions version |          Python\* versions           |
|-------------------|:------------------------------------:|
| 4.x               | 3.13<br/>3.12<br/>3.11<br/>3.10<br/> |

\* Official Python distributions

For more general information, see the [Azure Functions runtime support policy](./language-support-policy.md) 
and [Supported languages in Azure Functions](./supported-languages.md).

### Deployment
Learn more about the recommended deployment mechanism for your scenario: [Deployment Options](./python-deployments.md)

[!INCLUDE [functions-linux-consumption-retirement](../../includes/functions-linux-consumption-retirement.md)]

### Python 3.13+ updates
Starting with Python 3.13, Azure Functions introduces several major runtime and performance improvements that affect how you build and run your apps.
Key changes include:

::: zone pivot="python-mode-decorators"

- Runtime version control: You can now optionally pin or upgrade your app to specific Python worker versions by referencing the `azure-functions-runtime` package in your `requirements.txt`.
   - Without version control enabled, your app runs on a default version of the Python runtime, which Functions manages. You must modify your *requirements.txt* file to request the latest released version, a prereleased version, or to pin your app to a specific version of the Python runtime.
   - You enable runtime version control by adding a reference to the Python runtime package to your *requirements.txt* file, where the value assigned to the package determines the runtime version used.
   - Avoid pinning any production app to prerelease (alpha, beta, or dev) runtime versions.
   - Review [Python runtime release notes](https://github.com/Azure/azure-functions-python-worker/releases) regularly to be aware of changes that are being applied to your app's Python runtime or to determine when to update a pinned version.  
   - The following table indicates the versioning behavior based on the version value of this setting in your *requirements.txt* file:
      
      | Version                      | Example                          | Behavior                                                                                                                                                                                                                                                                                                                                                                                                                            |
      |------------------------------|----------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
      | No value set                 | `azure-functions-runtime`        | Your Python 3.13+ app runs on the latest available version of the Functions Python runtime. This option is best for staying current with platform improvements and features, since your app automatically receives the latest stable runtime updates.                                                                                                                                                                               |
      | Pinned to a specific version | `azure-functions-runtime==1.2.0` | Your Python 3.13+ app stays on the pinned runtime version and doesn't receive automatic updates. You must instead manually update your pinned version to take advantage of new features, fixes, and improvements in the runtime. Pinning is recommended for critical production workloads where stability and predictability are essential. Pinning also lets you test your app on prereleased runtime versions during development. |
      | No package reference         | n/a                              | By not setting the `azure-functions-runtime`, your Python 3.13+ app runs on a default version of the Python runtime that is behind the latest released version. Updates are made periodically by Functions. This option ensures stability and broad compatibility. However, access to the newest features and fixes are delayed until the default version is updated.                                                               |

- Dependency isolation: Your app’s dependencies (like `grpcio` or `azure-functions`) are fully isolated from the worker’s dependencies by default, preventing version conflicts.
- Simplified HTTP streaming setup—no special app settings required.
- Removed support for worker extensions and shared memory features.

::: zone-end

::: zone pivot="python-mode-configuration"

- Runtime version control: You can now optionally pin or upgrade your app to specific Python worker versions by referencing the `azure-functions-runtime-v1` package in your `requirements.txt`.
   - Without version control enabled, your app runs on a default version of the Python runtime, which Functions manages. You must modify your *requirements.txt* file to request the latest released version, a prereleased version, or to pin your app to a specific version of the Python runtime.
   - You enable runtime version control by adding a reference to the Python runtime package to your *requirements.txt* file, where the value assigned to the package determines the runtime version used.
   - Avoid pinning any production app to prerelease (alpha, beta, or dev) runtime versions.
   - Review [Python runtime release notes](https://github.com/Azure/azure-functions-python-worker/releases) regularly to be aware of changes that are being applied to your app's Python runtime or to determine when to update a pinned version.  
   - The following table indicates the versioning behavior based on the version value of this setting in your *requirements.txt* file:
      
      | Version                      | Example                             | Behavior                                                                                                                                                                                                                                                                                                                                                                                                                            |
      |------------------------------|-------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
      | No value set                 | `azure-functions-runtime-v1`        | Your Python 3.13+ app runs on the latest available version of the Functions Python runtime. This option is best for staying current with platform improvements and features, since your app automatically receives the latest stable runtime updates.                                                                                                                                                                               |
      | Pinned to a specific version | `azure-functions-runtime-v1==1.2.0` | Your Python 3.13+ app stays on the pinned runtime version and doesn't receive automatic updates. You must instead manually update your pinned version to take advantage of new features, fixes, and improvements in the runtime. Pinning is recommended for critical production workloads where stability and predictability are essential. Pinning also lets you test your app on prereleased runtime versions during development. |
      | No package reference         | n/a                                 | By not setting the `azure-functions-runtime-v1`, your Python 3.13+ app runs on a default version of the Python runtime that is behind the latest released version. Updates are made periodically by Functions. This option ensures stability and broad compatibility. However, access to the newest features and fixes are delayed until the default version is updated.                                                            |

- Dependency isolation: Your app’s dependencies (like `grpcio` or `azure-functions`) are fully isolated from the worker’s dependencies by default, preventing version conflicts.
- Removed support for worker extensions and shared memory features.

::: zone-end

---

## Observability and testing

This section covers logging, monitoring, and testing capabilities to help you debug issues, track performance, and ensure the reliability of your Python function apps.

### Logging and monitoring
Azure Functions exposes a root logger that you can use directly with Python’s built-in `logging` module. Any 
messages written using this logger are automatically sent to **Application Insights** when your app is running 
in Azure.

Logging allows you to capture runtime information and diagnose issues without needing any more setup.

#### Logging example with an HTTP trigger

::: zone pivot="python-mode-configuration"

```python
import logging
import azure.functions as func

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.debug("Example debug log")
    logging.info("Example info log")
    logging.warning("Example warning")
    logging.error("Example error log")
    return func.HttpResponse("OK")
```

::: zone-end

::: zone pivot="python-mode-decorators"

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

::: zone-end

You can use the full set of logging levels (`debug`, `info`, `warning`, `error`, `critical`), and they appear 
in the Azure portal under Logs or Application Insights.

To learn more about monitoring Azure Functions in the portal, see [Monitor Azure Functions](functions-monitoring.md).

#### Logging from background threads

If your function starts a new thread and needs to log from that thread, make sure to pass the `context` 
argument into the thread. The `context` contains thread-local storage and the current `invocation_id`, 
which must be set on the worker thread in order for logs to be associated properly with the function execution.

::: zone pivot="python-mode-configuration"

```python
import logging
import threading
import azure.functions as func

def main(req: func.HttpRequest, context) -> func.HttpResponse:
    logging.info("Function started")
    t = threading.Thread(target=log_from_thread, args=(context,))
    t.start()
    return "okay"

def log_from_thread(context):
    # Associate the thread with the current invocation
    context.thread_local_storage.invocation_id = context.invocation_id  
    logging.info("Logging from a background thread")
```

::: zone-end

::: zone pivot="python-mode-decorators"

```python
import azure.functions as func
import logging
import threading

app = func.FunctionApp()

@app.route(route="http_trigger")
def http_trigger(req, context) -> func.HttpResponse:
    logging.info("Function started")
    t = threading.Thread(target=log_from_thread, args=(context,))
    t.start()
    return "okay"

def log_from_thread(context):
    # Associate the thread with the current invocation
    context.thread_local_storage.invocation_id = context.invocation_id  
    logging.info("Logging from a background thread")
```

::: zone-end

### OpenTelemetry support
Azure Functions for Python also supports **OpenTelemetry**, which enables you to emit traces, metrics, and logs 
in a standardized format. Using OpenTelemetry is especially valuable for distributed applications or scenarios where you want 
to export telemetry to tools outside of Application Insights (such as Grafana or Jaeger).
> See our [OpenTelemetry Quickstart for Azure Functions (Python)](./opentelemetry-howto.md?pivot=programming-language-python) for setup instructions and sample code.

### Unit testing
Write and run unit tests for your functions by using `pytest` or by invoking the function directly.
→ [Guide: Unit Testing in Python Azure Functions](./python-testing.md)

---

## Optimization and advanced topics

To learn more about optimizing your Python functions apps, see these articles:

- [Scaling & Performance](./python-scale-performance-reference.md)
- [Using Flask Framework with Azure Functions](/samples/azure-samples/flask-app-on-azure-functions/azure-functions-python-create-flask-app/)
- [Durable Functions](./durable/durable-functions-overview.md)
- [HTTP Streaming](./functions-bindings-http-webhook-trigger.md?tabs=python-v2&pivots=programming-language-python#http-streams-1)

---

## Related articles

For more information about Functions, see these articles:

* [Azure Functions package API documentation](/python/api/azure-functions/azure.functions)
* [Best practices for Azure Functions](functions-best-practices.md)
* [Azure Functions triggers and bindings](functions-triggers-bindings.md)
* [Blob Storage bindings](functions-bindings-storage-blob.md)
* [HTTP and webhook bindings](functions-bindings-http-webhook.md)
* [Queue Storage bindings](functions-bindings-storage-queue.md)
* [Timer triggers](functions-bindings-timer.md)

[Having issues with using Python? Tell us what's going on.](https://aka.ms/python-functions-ref-survey)
