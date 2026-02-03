# Update Python code samples to use mssql-python instead of pyodbc

## Summary

This PR updates all Python code samples in azure-docs-pr to use **mssql-python**, Microsoft's official Python driver for SQL Server, replacing the legacy pyodbc approach.

## Why this change?

**mssql-python** is Microsoft's new official Python driver for SQL Server that offers significant advantages:


### Key Benefits

- **No ODBC Driver installation** - mssql-python includes its own native implementation
- **Built-in Microsoft Entra authentication** - No need for azure-identity + manual token handling
- **Simpler installation** - Just `pip install mssql-python`
- **Cross-platform support** - Windows, macOS, and Linux (some Linux distros need standard system libs)

## Changes Made

### Files Updated (7 files)

| File | Description |
|------|-------------|
| `articles/service-connector/includes/code-sql-secret.md` | Secret/password authentication sample |
| `articles/service-connector/includes/code-sql-me-id.md` | Microsoft Entra ID authentication sample |
| `articles/service-connector/includes/code-fabricsql-me-id.md` | SQL database in Fabric managed identity sample |
| `articles/app-service/includes/tutorial-connect-msi-azure-database/code-sql-mi.md` | App Service managed identity sample |
| `articles/storage/common/multiple-identity-scenarios.md` | Multiple identity scenarios sample |
| `articles/app-service/troubleshoot-intermittent-outbound-connection-errors.md` | Updated reference link |
| `articles/azure-functions/recover-python-functions.md` | Added tip recommending mssql-python |

### Code Pattern Changes

**Before (pyodbc):**
```python
import pyodbc
from azure.identity import DefaultAzureCredential
import struct

# Manual token acquisition required
credential = DefaultAzureCredential()
token = credential.get_token("https://database.windows.net/.default").token.encode("UTF-16-LE")
token_struct = struct.pack(f'<I{len(token)}s', len(token), token)
SQL_COPT_SS_ACCESS_TOKEN = 1256

# Requires ODBC Driver to be installed on the system
conn_string = "Driver={ODBC Driver 18 for SQL Server};Server=server.database.windows.net;Database=mydb;"
conn = pyodbc.connect(conn_string, attrs_before={SQL_COPT_SS_ACCESS_TOKEN: token_struct})
```

**After (mssql-python):**
```python
from mssql_python import connect

# No ODBC driver needed, no manual token handling
connection_string = "Server=server.database.windows.net;Database=mydb;Authentication=ActiveDirectoryDefault;Encrypt=yes;"
conn = connect(connection_string)
```

### Authentication Methods Supported

| Method | Use Case |
|--------|----------|
| `ActiveDirectoryDefault` | Local dev (uses `az login` credentials) |
| `ActiveDirectoryMSI` | Azure hosted (App Service, Functions, VMs) |
| `ActiveDirectoryInteractive` | Interactive browser login |
| `ActiveDirectoryServicePrincipal` | Service principal with client ID/secret |

## Testing

All code samples have been validated:

- ✅ Python syntax validation passed for all 7 code blocks
- ✅ mssql-python import verified
- ✅ Live connection test to SQL database in Fabric successful
- ✅ `ActiveDirectoryDefault` authentication tested
- ✅ `ActiveDirectoryInteractive` authentication tested

## References

- [mssql-python GitHub](https://github.com/microsoft/mssql-python)
- [Microsoft Entra ID authentication wiki](https://github.com/microsoft/mssql-python/wiki/Microsoft-Entra-ID-support)
- [Installation guide](https://github.com/microsoft/mssql-python/wiki/Installation)
