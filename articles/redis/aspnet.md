---
title: Create an ASP.NET Core web app with an Azure Redis cache
description: In this quickstart, you learn how to create an ASP.NET Core web app with an Azure Redis cache.
ms.date: 01/30/2026
ms.topic: quickstart
ms.devlang: csharp
zone_pivot_groups: redis-type
appliesto:
  - ✅ Azure Cache for Redis
# Customer intent: As an ASP.NET developer, new to Azure Redis, I want to create a new Node.js app that uses Azure Managed Redis or Azure Cache for Redis.
---

# Azure Managed Redis Sample - ASP.NET Core Web API

This sample demonstrates how to connect an ASP.NET Core Web API to **Azure Managed Redis** using **Microsoft Entra ID authentication** (formerly Azure Active Directory) with the `DefaultAzureCredential` flow. The application avoids traditional connection string-based authentication in favor of token-based, identity-driven access—aligning with modern security best practices.

## Overview

The application is a minimal ASP.NET Core 8.0 Web API that:

1. Establishes a secure, authenticated connection to Azure Managed Redis at startup
2. Exposes a simple REST endpoint that reads and writes data to the cache
3. Demonstrates proper Redis connection lifecycle management with dependency injection

## Prerequisites

- [.NET 8.0 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- An **Azure Managed Redis** instance provisioned in your Azure subscription
- Your Azure user or service principal must have the appropriate **Data Access Policy** assigned on the Redis resource (e.g., `Data Owner`, `Data Contributor`, or a custom policy with read/write permissions)
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) for local development authentication

## Required NuGet Packages

| Package | Purpose |
| --------- | --------- |
| `Microsoft.Azure.StackExchangeRedis` | Extension methods for StackExchange.Redis that enable Microsoft Entra ID token-based authentication to Azure Managed Redis |
| `StackExchange.Redis` | The underlying Redis client library for .NET |
| `Azure.Identity` | Provides `DefaultAzureCredential` and other credential types for authenticating with Azure services |
| `Swashbuckle.AspNetCore` | Swagger/OpenAPI support for API documentation and testing |

Install the primary package:

```bash
dotnet add package Microsoft.Azure.StackExchangeRedis
```

This package transitively brings in `StackExchange.Redis` and `Azure.Identity`.

## Configuration

The application reads the Redis endpoint from configuration. Update `appsettings.Development.json`:

```json
{
  "Redis": {
    "Endpoint": "<your-redis-name>.<region>.redis.azure.net:10000"
  }
}
```

> **Note:** Azure Managed Redis uses port `10000` by default. The endpoint format follows `<cache-name>.<region>.redis.azure.net:10000`.

## Authentication Flow

### Local Development

Before running the application locally, authenticate with Azure:

```bash
az login
```

The `DefaultAzureCredential` will automatically pick up your Azure CLI credentials and use them to obtain an access token for the Redis resource. This eliminates the need to manage or rotate secrets locally.

### Production Environments

In Azure-hosted environments (App Service, Container Apps, AKS, etc.), `DefaultAzureCredential` will leverage:

- **Managed Identity** (system-assigned or user-assigned)
- **Workload Identity** (for Kubernetes scenarios)
- **Environment variables** (for service principal authentication)

No code changes are required—the same `DefaultAzureCredential` seamlessly adapts to the environment.

## Architecture

### Redis Service (`Services/Redis.cs`)

The `Redis` class encapsulates the connection lifecycle:

```csharp
var options = new ConfigurationOptions()
{
    EndPoints = { endpoint },
    LoggerFactory = _loggerFactory,
};

await options.ConfigureForAzureWithTokenCredentialAsync(new DefaultAzureCredential());

_connection = await ConnectionMultiplexer.ConnectAsync(options);
```

Key points:

- `ConfigureForAzureWithTokenCredentialAsync` is the extension method from `Microsoft.Azure.StackExchangeRedis` that configures token-based authentication
- The `DefaultAzureCredential` handles the token acquisition and refresh automatically
- The connection is established once at startup and shared across requests

### Dependency Injection (`Program.cs`)

The Redis service is registered as a singleton and initialized during application startup:

```csharp
builder.Services.AddSingleton<Redis>();

// Initialize Redis connection
using (var scope = app.Services.CreateScope())
{
    var redis = scope.ServiceProvider.GetRequiredService<Redis>();
    var endpoint = app.Configuration.GetValue<string>("Redis:Endpoint");
    await redis.ConnectAsync(endpoint);
}
```

### API Controller (`Controllers/SampleController.cs`)

The controller injects the `Redis` service and demonstrates basic cache operations:

- **GET `/Sample`**: Reads the previous visit timestamp from the cache and updates it with the current time

## Running the Application

1. Ensure you're authenticated:

   ```bash
   az login
   ```

1. Update the Redis endpoint in `appsettings.Development.json`

1. Run the application:

  ```bash
   dotnet run
   ```

1. Navigate to `https://localhost:<port>/swagger` to access the Swagger UI

## Expected Output

When invoking the `GET /Sample` endpoint:

**First request:**

```bash
Previous visit was at: 
(Empty value since no previous visit exists)
```

```bash
**Subsequent requests:**
Previous visit was at: 2026-01-30T14:23:45
(Returns the ISO 8601 formatted timestamp of the previous request)
```

The console logs will display:

```bash
info: Microsoft.Azure.StackExchangeRedis.Sample.AspNet.Controllers.SampleController
      Handled GET request. Previous visit time: 2026-01-30T14:23:45
```

## Key Implementation Details

1. **Token Refresh**: The `Microsoft.Azure.StackExchangeRedis` library automatically handles token refresh before expiration—no manual intervention required.

1. **Connection Resilience**: The `ConnectionMultiplexer` from StackExchange.Redis handles reconnection logic internally.

1. **Resource Cleanup**: The `Redis` service implements `IDisposable` to properly close the connection when the application shuts down.

1. **Logging Integration**: The Redis client integrates with .NET's `ILoggerFactory` for unified logging output.

## Troubleshooting

| Issue | Resolution |
| ------- | ------------ |
| `No connection is available` | Verify the endpoint format and port (`10000`). Ensure the Redis instance is provisioned and accessible. |
| `AuthenticationFailedException` | Run `az login` to refresh credentials. Verify your identity has the required Data Access Policy on the Redis resource. |
| `Unauthorized` | Ensure your Microsoft Entra ID identity is assigned a data access role on the Azure Managed Redis instance. |

## Additional Resources

- [Azure Managed Redis documentation](https://learn.microsoft.com/azure/azure-cache-for-redis/)
- [Microsoft Entra ID authentication for Azure Cache for Redis](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-azure-active-directory-for-authentication)
- [DefaultAzureCredential overview](https://learn.microsoft.com/dotnet/azure/sdk/authentication#defaultazurecredential)
- [StackExchange.Redis documentation](https://stackexchange.github.io/StackExchange.Redis/)
