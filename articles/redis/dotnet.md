## Microsoft.Azure.StackExchangeRedis Sample Application

### Overview

This is a .NET 8 console application that demonstrates how to connect to **Azure Managed Redis** using **Microsoft Entra ID** (formerly Azure Active Directory) authentication. The core value proposition is **passwordless authentication** with automatic token refresh, providing a secure and modern approach to Redis connectivity.

### Required NuGet Packages

| Package | Purpose |
|---------|---------|
| `Microsoft.Azure.StackExchangeRedis` | Extension library that adds Entra ID authentication to StackExchange.Redis |
| `Azure.Identity` | Provides `DefaultAzureCredential` and other Azure identity implementations |
| `StackExchange.Redis` | The underlying Redis client (pulled in as a dependency) |
| `Microsoft.Extensions.Logging.Console` | Console logging for diagnostics |

---

### Authentication Methods

The extension supports multiple identity types, each with a corresponding `ConfigureForAzure*()` extension method:

1. **`DefaultAzureCredential`** — The recommended approach. It chains multiple credential sources (environment variables, managed identity, Azure CLI login, Visual Studio credentials, etc.) and uses the first one that works. Ideal for code that runs both locally and in Azure.

2. **User-Assigned Managed Identity** — For Azure-hosted apps where you explicitly specify which managed identity to use via its client ID.

3. **System-Assigned Managed Identity** — For Azure-hosted apps using the identity automatically assigned to the resource.

4. **Service Principal (Secret)** — Client ID + Tenant ID + secret for automated/CI scenarios.

5. **Service Principal (Certificate)** — Client ID + Tenant ID + X.509 certificate for higher security.

---

### How `DefaultAzureCredential` Works Locally

When developing locally, `DefaultAzureCredential` will attempt to authenticate using:

```bash
az login
```

This signs you into the Azure CLI with your Microsoft Entra ID account. The SDK detects your cached credentials and uses them to obtain tokens. Your Entra ID user must be configured as a **Redis User** on the Azure Managed Redis resource via the **Data Access Configuration** blade in the Azure portal.

---

### Key Implementation Patterns

**Connection Configuration:**

```csharp
ConfigurationOptions configurationOptions = new()
{
    Protocol = RedisProtocol.Resp3,  // Recommended for seamless re-auth
    LoggerFactory = loggerFactory,
    AbortOnConnectFail = true,       // Fail fast (use false in production)
    BacklogPolicy = BacklogPolicy.FailFast
};
```

**Entra ID Setup:**

```csharp
await configurationOptions.ConfigureForAzureWithTokenCredentialAsync(new DefaultAzureCredential());
var connection = await ConnectionMultiplexer.ConnectAsync(configurationOptions);
```

**Basic Redis Operations:**

```csharp
var database = connection.GetDatabase();
await database.StringSetAsync("key", "value");
var value = await database.StringGetAsync("key");
```

---

### Token Lifecycle & Automatic Re-authentication

The extension handles the OAuth2 token lifecycle automatically:

1. **Initial acquisition** — A token is obtained before connecting.
2. **Proactive refresh** — Before the token expires (~1 hour), a fresh token is acquired in the background.
3. **Re-authentication** — The connection is re-authenticated with the new token without dropping commands.

You can subscribe to token events for observability:

| Event | Purpose |
|-------|---------|
| `TokenRefreshed` | New token acquired |
| `TokenRefreshFailed` | Token refresh failed (still using old token) |
| `ConnectionReauthenticated` | Connection successfully re-authenticated |
| `ConnectionReauthenticationFailed` | Re-auth failed for a connection |

---

### RESP3 vs RESP2 Protocol

The sample uses **RESP3** (`Protocol = RedisProtocol.Resp3`) because:

- RESP2 creates separate connections for interactive commands and pub/sub.
- Only the interactive connection gets proactively re-authenticated.
- Pub/sub connections close when their token expires, causing brief interruptions.
- RESP3 multiplexes everything on one connection, avoiding these disruptions.

---

### Azure Prerequisites

1. **Create an Azure Managed Redis** instance.
2. **Enable Microsoft Entra ID authentication** under "Data Access Configuration."
3. **Add your identity as a Redis User** with the appropriate permissions (Data Owner, Data Contributor, etc.).
4. **Run `az login`** locally to authenticate with your Entra ID account.

---

### Redis Basics Refresher

| Concept | Description |
|---------|-------------|
| `ConnectionMultiplexer` | Singleton, thread-safe connection pool to Redis—create once, reuse for the app lifetime. |
| `IDatabase` | Interface for executing commands (`StringGet`, `StringSet`, `HashGet`, etc.). |
| Endpoint format | `endpoint:10000` (TLS) for Azure Managed Redis. |
| Commands | Redis is single-threaded per key—atomic operations like `INCR`, `SETNX` avoid race conditions. |

---

### Running the Sample

```powershell
az login
cd sample
dotnet run
```

Enter your Redis endpoint (e.g., `myredis.redis.azure.net`), choose authentication method **1** (DefaultAzureCredential), and watch the `+` characters print every second as commands succeed. Let it run for 60+ minutes to verify automatic token refresh works.

---

### Production Considerations

| Setting | Sample Value | Production Value |
|---------|--------------|------------------|
| `AbortOnConnectFail` | `true` | `false` (retry on startup) |
| `BacklogPolicy` | `FailFast` | `Default` (queue commands during transient failures) |
| Connection lifetime | Demo loop | Singleton via DI (`IConnectionMultiplexer`) |

---

This sample provides a complete reference implementation for secure, passwordless Entra ID authentication in any .NET application that uses Azure Managed Redis.
