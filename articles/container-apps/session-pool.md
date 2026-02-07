---
title: Use session pools in Azure Container Apps
description: Learn to use and manage session pools in Azure Container Apps.
services: container-apps
author: craigshoemaker
ms.service: azure-container-apps
ms.topic: conceptual
ms.date: 04/07/2025
ms.author: cshoe
---

# Use session pools in Azure Container Apps

Session pools provide subsecond session allocation times and manage the lifecycle of each session.

## Common concepts for both pools

The process for creating a pool is slightly different depending on whether you're creating a code interpreter session pool or a custom container pool. The following concepts apply to both.

To create session pools using the Azure CLI, ensure you have the latest versions of the Azure CLI and the Azure Container Apps extension:

```bash
# Upgrade the Azure CLI
az upgrade

# Install or upgrade the Azure Container Apps extension
az extension add --name containerapp --upgrade --allow-preview true -y
```

Common session pool commands include:

- `az containerapp sessionpool create`
- `az containerapp sessionpool show`
- `az containerapp sessionpool list`
- `az containerapp sessionpool update`
- `az containerapp sessionpool delete`

Use `--help` with any command to see available arguments and supported values.

To check the status of a session pool, use the `az containerapp sessionpool show` command:

```bash
az containerapp sessionpool show \
    --name <SESSION_POOL_NAME> \
    --resource-group <RESOURCE_GROUP> \
    --query "properties.poolManagementEndpoint" \
    --output tsv
```

When you create or update a pool, you can set a maximum number of concurrent sessions, an idle cooldown period, and whether outbound network traffic is allowed for sessions.

> [!IMPORTANT]
> If you enable egress, code running in the session can access the internet. Use caution when the code is untrusted because it can be used to perform malicious activities such as denial-of-service attacks.

## Code interpreter session pool

# [Azure CLI](#tab/azure-cli)

Use the `az containerapps sessionpool create` command to create the pool. The following example creates a Python code interpreter session pool named `my-session-pool`. Make sure to replace `<RESOURCE_GROUP>` with your resource group name before you run the command.

```bash
az containerapp sessionpool create \
    --name my-session-pool \
    --resource-group <RESOURCE_GROUP> \
    --location westus2 \
    --container-type PythonLTS \
    --max-sessions 100 \
    --cooldown-period 300 \
    --network-status EgressDisabled
```

You can define the following settings when you create a session pool:

| Setting | Description |
|---------|-------------|
| `--container-type` | The type of code interpreter to use. Supported values include `PythonLTS`, `NodeLTS`, `Shell`, and `CustomContainer`. |
| `--max-sessions` | The maximum number of allocated sessions allowed concurrently. The maximum value is `600`. |
| `--cooldown-period` | The number of allowed idle seconds before termination. The idle period is reset each time the session's API is called. The allowed range is between `300` and `3600`. |
| `--network-status` | Specifies whether outbound network traffic is allowed from the session. Valid values are `EgressDisabled` (default) and `EgressEnabled`. |

# [Azure portal](#tab/azure-portal)

> [!NOTE]
> Azure portal steps for creating a code interpreter session pool are being updated. Check back soon.

---

### Code interpreter management endpoint

To use code interpreter sessions with LLM framework integrations or by calling the management API endpoints directly, you need the pool's management API endpoint.

The endpoint is in the format `https://<REGION>.dynamicsessions.io/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP>/sessionPools/<SESSION_POOL_NAME>`.

To retrieve the management API endpoint for a session pool, see the common section above for an example command.

The following endpoints are available for managing sessions in a pool:

| Endpoint path | Method | Description |
|----------|--------|-------------|
| `code/execute` | `POST` | Execute code in a session. |
| `files/upload` | `POST` | Upload a file to a session. |
| `files/content/{filename}` | `GET` | Download a file from a session. |
| `files` | `GET` | List the files in a session. |

You build the full URL for each endpoint by concatenating the pool's management API endpoint with the endpoint path. The query string must include an `identifier` parameter containing the session identifier, and an `api-version` parameter with the value `2024-02-02-preview`.

For example: `{sessionManagementEndpoint}code/execute?api-version=2024-02-02-preview&identifier=<IDENTIFIER>`

For REST API references, see [Container Apps data-plane APIs](https://learn.microsoft.com/en-us/rest/api/containerapps/#data-plane-apis) and the [Container Apps data-plane operations overview](https://learn.microsoft.com/en-us/rest/api/data-plane/containerapps/operation-groups?view=rest-data-plane-containerapps-2025-10-02-preview).

## Custom session pool

To create a custom container session pool, you need to provide a container image and pool configuration settings.

You invoke or communicate with each session using HTTP requests. The custom container must expose an HTTP server on a port that you specify to respond to these requests.

# [Azure CLI](#tab/azure-cli)

Custom container session pools require a workload profiles-enabled Azure Container Apps environment. If you don't have an environment, use the `az containerapp env create -n <ENVIRONMENT_NAME> -g <RESOURCE_GROUP> --location <LOCATION>` command to create one.

Use the `az containerapp sessionpool create` command to create a custom container session pool.

The following example creates a session pool named `my-session-pool` with a custom container image `myregistry.azurecr.io/my-container-image:1.0`.

Before you send the request, replace the placeholders between the `<>` brackets with the appropriate values for your session pool and session identifier.

```bash
az containerapp sessionpool create \
    --name my-session-pool \
    --resource-group <RESOURCE_GROUP> \
    --environment <ENVIRONMENT> \
    --registry-server myregistry.azurecr.io \
    --registry-username <USER_NAME> \
    --registry-password <PASSWORD> \
    --container-type CustomContainer \
    --image myregistry.azurecr.io/my-container-image:1.0 \
    --cpu 0.25 --memory 0.5Gi \
    --target-port 80 \
    --cooldown-period 300 \
    --network-status EgressDisabled \
    --max-sessions 10 \
    --ready-sessions 5 \
    --env-vars "key1=value1" "key2=value2" \
    --location <LOCATION>
```

This command creates a session pool with the following settings:

| Parameter | Value | Description |
|---------|-------|-------------|
| `--name` | `my-session-pool` | The name of the session pool. |
| `--resource-group` | `my-resource-group` | The resource group that contains the session pool. |
| `--environment` | `my-environment` | The name or resource ID of the container app's environment. |
| `--container-type` | `CustomContainer` | The container type of the session pool. Must be `CustomContainer` for custom container sessions. |
| `--image` | `myregistry.azurecr.io/my-container-image:1.0` | The container image to use for the session pool. |
| `--registry-server` | `myregistry.azurecr.io` | The container registry server hostname. |
| `--registry-username` | `my-username` | The username to log in to the container registry. |
| `--registry-password` | `my-password` | The password to log in to the container registry. |
| `--cpu` | `0.25` | The required CPU in cores. |
| `--memory` | `0.5Gi` | The required memory. |
| `--target-port` | `80` | The session port used for ingress traffic. |
| `--cooldown-period` | `300` | The number of seconds that a session can be idle before the session is terminated. The idle period is reset each time the session's API is called. Value must be between `300` and `3600`. |
| `--network-status` | `EgressDisabled` | Specifies whether outbound network traffic is allowed from the session. Valid values are `EgressDisabled` (default) and `EgressEnabled`. |
| `--max-sessions` | `10` | The maximum number of sessions that can be allocated at the same time. |
| `--ready-sessions` | `5` | The target number of sessions that are ready in the session pool all the time. Increase this number if sessions are allocated faster than the pool is being replenished. |
| `--env-vars` | `"key1=value1" "key2=value2"` | The environment variables to set in the container. |
| `--location` | `"Supported Location"` | The location of the session pool. |

To update the session pool, use the `az containerapp sessionpool update` command.

# [Azure portal](#tab/azure-portal)

> [!NOTE]
> Azure portal steps for creating a custom container session pool are being updated. Check back soon.

# [Azure Resource Manager](#tab/arm)

To use Azure Resource Manager for session pools, see the [SessionPools REST API overview](https://learn.microsoft.com/en-us/rest/api/resource-manager/containerapps/container-apps-session-pools?view=rest-resource-manager-containerapps-2025-07-01).

---

> [!IMPORTANT]
> If the session is used to run untrusted code, don't include information or data that you don't want the untrusted code to access. Assume the code is malicious and has full access to the container, including its environment variables, secrets, and files.

## Configure a pool

Use `az containerapp sessionpool create --help` to see the latest CLI arguments for session pool configuration. This section focuses on advanced configuration options that apply across API versions.

### Session lifecycle configuration

When you create or update a session pool, you can configure how sessions are terminated by setting `properties.dynamicPoolConfiguration.lifecycleConfiguration`. Starting with API version `2025-01-01`, choose one of two lifecycle types.

For the full API specification, see the [SessionPools API spec](https://learn.microsoft.com/en-us/rest/api/resource-manager/containerapps/container-apps-session-pools/create-or-update?view=rest-resource-manager-containerapps-2025-07-01&tabs=HTTP).

#### Timed (default)

With the `Timed` lifecycle, a session is deleted after a period of inactivity. Any request sent to a session resets the cooldown timer, extending the session's time-to-live by `cooldownPeriodInSeconds`.

> [!NOTE]
> `Timed` is supported for all session pool types and works the same as `executionType: Timed` in earlier API versions.

```json
{
  "dynamicPoolConfiguration": {
    "lifecycleConfiguration": {
      "cooldownPeriodInSeconds": 600,
      "lifecycleType": "Timed"
    }
  }
}
```

| Property | Description |
| --- | --- |
| `cooldownPeriodInSeconds` | The session is deleted when there are no requests for this duration. |
| `maxAlivePeriodInSeconds` | Not supported for `Timed` lifecycle. |

#### OnContainerExit

With the `OnContainerExit` lifecycle, a session remains active until the container exits on its own or the maximum alive period is reached.

> [!NOTE]
> `OnContainerExit` is only supported for **Custom Container Session Pools**.

```json
{
  "dynamicPoolConfiguration": {
    "lifecycleConfiguration": {
      "maxAlivePeriodInSeconds": 6000,
      "lifecycleType": "OnContainerExit"
    }
  }
}
```

| Property | Description |
| --- | --- |
| `maxAlivePeriodInSeconds` | Maximum time the session can stay alive before being deleted. |
| `cooldownPeriodInSeconds` | Not supported for `OnContainerExit` lifecycle. |

### Container probes

Container probes let you define health checks for session containers so the pool can detect unhealthy sessions and replace them to keep the `readySessionInstances` target healthy.

> [!NOTE]
> Container probes are only supported in **Custom Container Session Pools** and require API version `2025-02-02-preview` or later.

Session pools support **Liveness** and **Startup** probes. For more information about probe behavior, see [Health probes in Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/health-probes?tabs=arm-template).

When creating or updating a session pool, specify probes in `properties.customContainerTemplate.containers`.

```json
{
  "properties": {
    "customContainerTemplate": {
      "containers": [
        {
          "name": "my-session-container",
          "image": "myregistry.azurecr.io/my-session-image:latest",
          "probes": [
            {
              "type": "Liveness",
              "httpGet": {
                "path": "/health",
                "port": 8080
              },
              "periodSeconds": 10,
              "failureThreshold": 3
            },
            {
              "type": "Startup",
              "httpGet": {
                "path": "/ready",
                "port": 8080
              },
              "periodSeconds": 5,
              "failureThreshold": 30
            }
          ]
        }
      ]
    },
    "dynamicPoolConfiguration": {
      "readySessionInstances": 5
    }
  }
}
```

If the pool isn't maintaining the expected number of healthy ready sessions, review probe paths and thresholds, and check session logs in [sessions usage logging](./sessions-usage.md#logging).

## Management endpoint

> [!IMPORTANT]
> The session identifier is sensitive information which requires a secure process as you create and manage its value. To protect this value, your application must ensure each user or tenant only has access to their own sessions.
>
> Failure to secure access to sessions could result in misuse or unauthorized access to data stored in your users' sessions. For more information, see [Session identifiers](./sessions-usage.md#identifiers)

All requests to the pool management endpoint must include an `Authorization` header with a bearer token. To learn how to authenticate with the pool management API, see [Authentication](sessions-usage.md#authentication).

Each API request must also include the query string parameter `identifier` with the session ID. This unique session ID enables your application to interact with specific sessions. To learn more about session identifiers, see [Session identifiers](sessions-usage.md#identifiers).

## Image caching

When a session pool is created or updated, Azure Container Apps caches the container image in the pool. This caching helps speed up the process of creating new sessions.

Any changes to the image aren't automatically reflected in the sessions. To update the image, update the session pool with a new image tag. Use a unique tag for each image update to ensure that the new image is pulled.

## Related content

- **Session types**: Learn about the different types of dynamic sessions:
  - [Code interpreter sessions](./sessions-code-interpreter.md)
  - [Custom container sessions](./sessions-custom-container.md)

- **Tutorials**: Work directly with the REST API or via an LLM agent:
  - Use an LLM agent:
    - [AutoGen](./sessions-tutorial-autogen.md)
    - [LangChain](./sessions-tutorial-langchain.md)
    - [LlamaIndex](./sessions-tutorial-llamaindex.md)
    - [Semantic Kernel](./sessions-tutorial-semantic-kernel.md)
  - Use the REST API
    - [JavaScript Code interpreter](./sessions-tutorial-nodejs.md)
