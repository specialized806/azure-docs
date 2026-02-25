---
title: Getting started - Entra ID based access for Azure Blob Storage SFTP
author: Jeevan Manoj
ms.date: 02/24/2026
ms.author: normesta

---
Getting started - Entra ID based access for Azure Blob Storage SFTP

**This feature is currently in public preview and once enabled it is applicable across all storage accounts within the entire subscription. This feature is currently in public preview and once enabled it is applicable across all storage accounts within the entire subscription. **

Azure Blob Storage SFTP now supports Entra ID-based access in public preview. Previously, Azure Blob Storage SFTP only supported local user-based access, requiring either a password or an SSH private key for authentication. With this new feature, users can leverage their Entra ID or Entra External Identities to connect to Azure storage accounts via SFTP without the need to create and maintain local users.  

Entra ID-based access brings a host of benefits, including Role Based Access Control (RBAC), Multi-factor Authentication, and Entra ID Access Control Lists (ACLs) to Azure Blob Storage SFTP. 

# Key benefits

1. Eliminate Local User Management

With Entra ID-based access, there is no need to create, rotate, or maintain local SFTP users per storage account. Authentication is handled entirely by Entra ID, significantly reducing operational overhead and configuration sprawl

1. Enterprisegrade Identity & Security

SFTP access is backed by Entra ID, enabling:

- Centralized identity lifecycle management
- Strong authentication (including MFA via Entra ID)
- Consistent security posture aligned with enterprise IAM standards
- This improves security compared to static, longlived local credentials

1. Native Azure RBAC, ABAC & ACL Integration

Authorization for SFTP mirrors Azure Blob Storage's existing access control model:

- RoleBased Access Control (RBAC)
- AttributeBased Access Control (ABAC)
- POSIXstyle Access Control Lists (ACLs)
- Users can apply the same roles and permissions used for REST, SDK, and Portal access—now extended seamlessly to SFTP. 

1. Faster SFTP Onboarding

Because Entra ID accounts are ubiquitous, users can:

- Reuse existing users, groups, and service principals
- Avoid timeconsuming local user creation and key distribution
- Get SFTP up and running faster with fewer setup steps
- This significantly shortens timetovalue for SFTPbased workflows. 

1. Secure External Collaboration

Using Entra ID External Identities, customers can securely grant SFTP access to partners and vendors without managing separate identity systems—while maintaining full control and auditability.

## Overview

Below is a high-level overview of the key steps involved in this process. In summary, you'll first authenticate using Entra ID, then obtain an OpenSSH certificate, and finally connect to Azure Blob Storage SFTP using a compatible client or SDK. Each of these steps is outlined in more detail in the following sections.

 

1. Authenticate with Entra ID via Azure CLI, PS, SDK etc.
2. Get an OpenSSH Certificate from Entra ID by passing a public key
3. Use any SFTP Client/SDK which supports OpenSSH certificates to connect to Azure Storage with the OpenSSH Certificate and the public key from step 2. 

> [!NOTE]
> For Step 3 Password based authentication won't be supported since there are no SFTP clients that have native Entra ID integration to allow an Entra ID UX to accept the passwords.

:::image type="content" source="media/secure-file-transfer-protocol-support-entra-id-based-access/overview-flow-chart.png" alt-text="Flow chart demonstrating the Open SSH certificate workflow":::



# **Connecting to Azure Blob Storage with Entra IDs **

## **Register for the preview feature 'SFTP Entra ID Support' on your Azure subscription**

You can register for public preview features by following this [guide](/azure/azure-resource-manager/management/preview-features). Looks for a preview feature named" SFTP Entra ID Support".    

## **Generate OpenSSH certificate**

# [Azure CLI](#tab/azurecli)

Generate the OpenSSH certificate with az cli  [az sftp](/cli/azure/sftp) as below 

    az login
    az sftp cert --file /my_cert.pub

> [!NOTE]
> The certificate will be valid only for 65 minutes for security reasons & the command will have to be rerun to obtain certificate again.

> [!NOTE]
> Currently, retrieving SSH certificates is only supported with [az cli](/cli/azure/ssh) or Azure PowerShell. We do not yet have Azure Portal support for downloading SSH certificates.

    
Optionally, you can generate your own SSH key pair and use them while downloading the certificate as follows. 

Generate SSH key pair: You must use RSA keys, since Entra only supports generating RSA certificates. 

    ssh-keygen -t rsa
1. key files will be generated once the above is executed. They are:

| **File Name** | **Key Type** |
|---|---|
| **id_rsa** | Private key |
| **id_rsa.pub** | Public key |

    
Use the command below to generate the SSH certificate with the keys generated 

`az login`<br>az sftp cert --public-key-file /id_rsa.pub --file /my_cert.pub

If you are using a Service Principal, you can login either using a Client Secret or a Certificate:

    Certificate:
    az login --service-principal -u <application_id_or_client_id> --tenant <tenant_id> --certificate <path_to_certificate>
    Client Secret:
    az login --service-principal -u <application_id_or_client_id> -p <secret_value> --tenant <tenant_id>
    Afer this you can just run the same command to download the certificate:
az sftp cert --public-key-file /id_rsa.pub --file /my_cert.pub
    
# [Azure PowerShell](#tab/azurepowershell)

Generate the OpenSSH certificate with [PowersShell Az.Sftp](https://www.powershellgallery.com/packages/Az.Sftp/0.1.0)  as below
    
    Connect-AzAccount
    New-AzSftpCertificate -CertificatePath "\my_cert.cert"
Optionally, use the command below to generate the OpenSSH certificate with your SSH keys

    New-AzSftpCertificate -PublicKeyFile "\id_rsa.pub" -CertificatePath "\my_cert.cert"
Learn more about the PowerShell module [here](/powershell/module/az.sftp/).

> [!NOTE]
> Powershell currently does not support Service Principals and managed Identity Sign ins. 

### MSAL.NET

```dotnetcli
using Microsoft.Identity.Client;
using Microsoft.Identity.Client.SSHCertificates;
using Newtonsoft.Json;
using System.Security.Cryptography;
using System.Text;
public class Program
{
    private const string AZURE_CLI_CLIENT_ID = "<your-azure-cli-client-id>";
    private const string MY_TENANT_ID = "<your-tenant-id>";
    public static async Task Main(string[] args)
    {
        var options = new PublicClientApplicationOptions
        {
            ClientId = AZURE_CLI_CLIENT_ID,
        };
        var app = PublicClientApplicationBuilder.CreateWithApplicationOptions(options)
            .WithTenantId(MY_TENANT_ID)
            .WithDefaultRedirectUri()
            .Build();
        var scopes = new string[]
        {
            "`<https://pas.windows.net/CheckMyAccess/Linux/.default>`",
        };
        var keyId = new byte[32];
        Random.Shared.NextBytes(keyId);
        var rsa = RSA.Create();
        var key = rsa.ExportParameters(includePrivateParameters: true);
        if (key.Modulus == null || key.Exponent == null)
            throw new InvalidOperationException("RSA key generation failed: Modulus or Exponent is null.");
        var localKey = new
        {
            kty = "RSA",
            n = Convert.ToBase64String(key.Modulus).Replace("+", "-").Replace("/", "_"),
            e = Convert.ToBase64String(key.Exponent).Replace("+", "-").Replace("/", "_"),
            kid = BitConverter.ToString(keyId).Replace("-", string.Empty).ToLower(),
        };
        var localKeyJson = JsonConvert.SerializeObject(localKey);
        Console.WriteLine("RSA Key:");
        Console.WriteLine(localKeyJson);
        Console.WriteLine();

        // Get SSH certificate

        AuthenticationResult result = await app.AcquireTokenInteractive(scopes)
            .WithSSHCertificateAuthenticationScheme(localKeyJson, localKey.kid)
            .ExecuteAsync();

        // Define output directory and certificate path

        var sshDir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), ".ssh", "entra");
        Directory.CreateDirectory(sshDir);
        var certPath = Path.Combine(sshDir, "id_rsa-cert.pub");

        // Remove read-only attribute if certificate already exists so it can be overwritten

        if (File.Exists(certPath))
        {
            File.SetAttributes(certPath, FileAttributes.Normal);
        }
        // Save the certificate
        var cert = `[$"ssh-rsa-cert-v01@openssh.com](mailto:$%22ssh-rsa-cert-v01@openssh.com)` {result.AccessToken}";
        await File.WriteAllTextAsync(certPath, cert);
        File.SetAttributes(certPath, FileAttributes.ReadOnly);
        // Dump certificate content to console
        Console.WriteLine("Cert");
        Console.WriteLine(cert);
        Console.WriteLine();
   }
}
```

## Verify the contents of the OpenSSH certificate [Optional]

Use the following command to view the OpenSSH certificate.

`ssh-keygen -L -f my_cert.pub`
Username is captured in the _Principals_ section highlighted in red

:::image type="content" source="media/secure-file-transfer-protocol-support-entra-id-based-access/verify-opensshcert.jpg" alt-text="Screenshot of the OpenSSH certificate output showing the Principals section highlighted in red.":::

For security reasons, the OpenSSH certificate is valid for 65 minutes. After this period, you will need to request a new certificate to initiate any further transactions. For security reasons, the OpenSSH certificate is valid for 65 minutes. After this period, you will need to request a new certificate to initiate any further transactions.

## Connect to the Storage Account with OpenSSH

### SFTP command


    C:\Users\username> sftp -o PubkeyAcceptedKeyTypes="rsa-sha2-256-cert-v01@openssh.com,rsa-sha2-256" -o IdentityFile="C:\path\to\key\.ssh\id_rsa" -o CertificateFile="C:\path\to\cert\.ssh\my_cert.pub" storageaccountname.username@storageaccountname.blob.core.windows.net
    Connected to storageaccountname.blob.core.windows.net.
    sftp>

> [!NOTE]
> If the Principal is in the format [username@domain.com](mailto:username@domain.com), make sure you don't add the domain section in the command and only use the username portion.

> [!NOTE]
> [Both User and Service principals](/entra/identity-platform/app-objects-and-service-principals) are supported. In the case of Service principals, use the service principal id in place of the username in the connection string.

> [!NOTE]
> Adding the container name directly into the connection string or setting it up via Home Directory is currently NOT supported.

Once connected, use the following to upload a file to the Azure Storage via SFTP.

`sftp> put 'C:\path\to\blob\blog.jpeg'`

If you get a permission denied error, please make sure you have the necessary RBAC roles such as Storage Blob Data Contributor or Storage Blob Data Owner

### SFTP desktop clients

OpenSSH based login is supported by SFTP clients such as WinSCP and PuTTY. Steps to connect via WinSCP below.

1. WinSCP: Support for OpenSSH certificates for user authentication was implemented in version 6.0. (<https://winscp.net/tracker/1873>)
2. Obtain the OpenSSH certificate from step 3 above (3. Generate OpenSSH certificate)
3. In WinSCP enter the Host name Username and click on Advanced

:::image type="content" source="media/secure-file-transfer-protocol-support-entra-id-based-access/winscp-login.png" alt-text="Screenshot of the WinSCP login dialog showing the Host name, Username fields, and the Advanced button.":::

1. Navigate to the Authentication section in the SSH Tab on the left and attach the Private Key and Certificate files obtained from the earlier sections and Click 'Ok.'

:::image type="content" source="media/secure-file-transfer-protocol-support-entra-id-based-access/winscp-advanced-settings.png"  alt-text="Screenshot of the WinSCP Advanced Site Settings dialog showing the Authentication section with Private Key and Certificate file fields.":::

1. Click 'Login' to Login with the Entra ID account and OpenSSH certificate

:::image type="content" ssource="media/secure-file-transfer-protocol-support-entra-id-based-access/winscp-login-highlight.png" alt-text="Screenshot of the WinSCP login dialog with the Login button to connect using the Entra ID account and OpenSSH certificate.":::

# [Azure CLI](#tab/azurecli)

Use the following command to connect by using the OpenSSH certificate obtained in the previous steps  

az sftp connect --storage-account `<<account_name>>` --certificate-file /my_cert.pub

Additionally, you can also get the OpenSSH certificate and connect to SFTP with a single command as follows

`az sftp connect`
`az sftp connect --storage-account <<account_name>>`

More information regarding the commands, see [here](/cli/azure/sftp)

# [Azure PowerShell](#tab/azurepowershell)

Use the following command to connect by using the OpenSSH certificate obtained in the previous steps  

Connect-AzSftp -StorageAccount `"<<account_name>>"` -CertificateFile "/my_cert.pub"

Additionally, you can also get the OpenSSH certificate and connect to SFTP with a single command as follows

Connect-AzAccount
Connect-AzSftp –StorageAccount "<<account_name>>"

More information regarding the commands, see [here](/powershell/module/az.sftp/connect-azsftp)

## Entra ID based access control model in Azure Blob Storage SFTP

| **Mechanism** | **Status** | **Tutorial** |
|---|---|---|
| Role-based access control (Azure RBAC) | Supported | [Access control model for Azure Data Lake Storage - Azure Storage &#124; Microsoft Learn](/azure/storage/blobs/data-lake-storage-access-control-model) |
| Access control lists (ACLs) | Supported | [Access control model for Azure Data Lake Storage - Azure Storage &#124; Microsoft Learn](/azure/storage/blobs/data-lake-storage-access-control-model) |
| Attribute-based access control (Azure ABAC) | Not supported in private preview. If any ABAC rule exists, for SFTP it will be ignored. |  |

## How permissions are evaluated

**SFTP mirrors the Azure Blob Storage's access control explained** [**here**](/azure/storage/blobs/data-lake-storage-access-control-model)** except that during the private preview, ABAC support is partial. Learn more in the Known issues and limitations section. **

## Sharing access to users outside of the home Entra ID tenant

Organizations often need to share Azure Blob Storage SFTP access with external partners and customers. Entra External Identities can address this requirement by allowing Azure Blob Storage SFTP to provide secure access to external collaborators. This feature enables efficient and secure connections and interactions with storage resources. By using Entra ID External Identity capabilities, organizations can maintain strong access control and security measures while enabling collaboration with external entities. Learn more [here](/entra/external-id/b2b-quickstart-add-guest-users-portal).


## Known issues & limitations

Entra ID support is limited to SSH certificates and public key authentication.

Only RSA certificates are supported. ECDSA is not supported.

1. [ABAC](/azure/storage/blobs/storage-auth-abac-attributes) behavior is inconsistent when using with the Storage Blob Data Owner role (RBAC) and may lead to timeout errors. To use ABAC, choose the Storage Blob Data Contributor role, or use the Storage Blob Data Owner role without ABAC.

ABAC  [sub-operations](/azure/storage/blobs/storage-auth-abac-attributes) are unsupported and will behave incorrectly. Specific behaviours of the sub operations are listed below. 

List blobs (Blob.List): Users can list Blobs without any restrictions, and the ABAC condition expression(s) are ignored.

Read a blob (NOT Blob.List): Works as expected on the given ABAC condition expression(s). However, for all the other cases, List blobs (Blob.List) action will also inadvertently fail in addition to the expected failure of Read a blob (NOT Blob.List). 

_(Deprecated)_ Read content from a blob with tag conditions (Blob.Read.WithTagConditions): The ABAC condition expression(s) are ignored. 

Sets the access tier on a blob (Blob.Write.Tier): The ABAC condition expression(s) are ignored. 

Write to a blob with blob index tag (Blob.Write.WithTagHeaders): The ABAC condition expression(s) are ignored.

Setting a home directory is not supported.

The connection string cannot include the container name. The user will connect to the root of the Storage Account and then navigate to the destination container and directories with 'change directory' (cd) commands.

Currently, `chown` & `chgrp` require either superuser and manage ownership, or manage ownership, read, and write. In the future, only manage ownership or superuser roles will suffice.

For `chmod`, the current requirement is either superuser and modify permissions, or modify permissions, read, and write. It will later require only modify permissions or superuser.

## Troubleshooting

- Connections to Storage Accounts via WinSCP works and the list of containers are visible after logging in. However, opening any container fails with Access denied
  - **Why**: WinSCP automatically tries to **canonicalize every directory** it enters.  That means — for _every_ `cd` or directory listing, it sends one or more extra protocol requests to figure out the "true" absolute path.
    - The **root directory** shows _containers_
    - Each container is **a virtual chroot** — once inside it, you can't go above or outside it.
    - Paths are **virtual**, not physical, and Azure doesn't support `/`-based absolute traversal above containers.
  - **Fix**: There are two options to resolve this issue
    - Disable "Resolve Symbolic Links"
      - Advanced->Environment->Directories -> Untick "Resolve Symbolic Links"
    - Set Remote Directory
      - Advanced->Environment->Directories -> Set "Remote Directory" to "\\<container-name>"
      - By setting this you will directly enter the specified container after logging in
