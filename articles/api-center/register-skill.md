---
title: Register Skills in Your API Center
description: Learn how to register skills in Azure API Center to create a centralized skills registry for your organization. 
ms.service: azure-api-center
ms.topic: how-to
ms.date: 03/09/2026
ai-usage: ai-assisted


ms.collection: ce-skilling-ai-copilot
ms.update-cycle: 180-days
# Customer intent: As an API program manager, I want to register skills in my API Center inventory so developers can discover and use them.
ms.custom:
---

# Register skills in your API inventory

This article describes how to use Azure API Center to register agent [skills](https://agentskills.io/home) as part of your API inventory. Skills are reusable capabilities that AI agents can discover and consume to extend their functionality.

> [!NOTE]
> Registering skills in API Center is currently in preview.

By registering skills in your API center, you create a centralized registry that helps your organization:

- Discover available skills and their capabilities
- Access source code and documentation for the skills

## Prerequisites

- An API center. If you don't have an API center yet, see the quickstart to [Create an API center](set-up-api-center.md).
- One or more skills that you want to register, typically hosted in a source code repository such as GitHub.
- For integration with a Git repository for continuous synchronization of skill information (optional): 
    - An Azure key vault. If you need to create one, see [Quickstart: Create a key vault using the Azure portal](/azure/key-vault/general/quick-create-portal). To add or manage secrets in the key vault, you need at least the **Key Vault Secrets Officer** role or equivalent permissions. 
    - A personal access token (PAT) to access the repository where your skill information is stored. The PAT must have appropriate permissions to read the repository content. To create a PAT for GitHub, see [Create a fine-grained personal access token](https://docs.github.com/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token).  
    - For Azure CLI:.
        [!INCLUDE [include](~/reusable-content/azure-cli/azure-cli-prepare-your-environment-no-header.md)]

        > [!NOTE]
        > You can run Azure CLI command examples in this article in PowerShell or a bash shell. Where needed because of different variable syntax, separate command examples are provided for the two shells.

## Register a skill

To register a skill in your API center:

1. Sign in to the [Azure portal](https://portal.azure.com) and go to your API center.
1. In the sidebar menu, under **Inventory**, select **Assets**.
1. Select **+ Register an asset** > **Skill**.
1. In the **Register a skill** form, provide the information in the following table:

    | Field | Description |
    |-------|-------------|
    | **Title** | Enter a descriptive name for the skill (for example, *Code Review Skill*). |
    | **Identification** | API Center automatically generates an identifier based on the title (for example, *code-review-skill*). You can edit this if needed. |
    | **Summary** | Provide a brief one-line description of what the skill does (for example, *Performs automated code reviews using static analysis*). |
    | **Description** | Enter a more detailed description of the skill's capabilities, use cases, and behavior. |
    | **Lifecycle stage** | Select the current stage of the skill's lifecycle from the dropdown menu. |
    | **Source** | |
    | **Source URL** | Enter the Git repository URL for the skill source code (for example, `https://github.com/<org>/<repo>/tree/main/skills/<skill-name>`). |
    | **Compatibility** | Describe the requirements, dependencies, and prerequisites for using the skill (for example, required software or tools like git, docker, programming languages; system requirements; network access requirements; API keys or authentication requirements). |
    | **Allowed tools** | Select **+ Add tool** to specify the APIs or MCP servers from your API inventory that this skill can access. This approach helps ensure proper governance and security by explicitly defining what resources the skill can consume. |
    | **License** | Select **+ Add** to provide licensing information. Enter the license name (for example, *MIT*, *Apache 2.0*, or *Proprietary*), optionally provide a license URL, and add a description if needed to clarify licensing terms or restrictions. |
    | **Contact information** | Select **+ Add** to add contact points for support or inquiries. Enter a contact name or role (for example, *API Team* or *John Smith*), provide contact details such as email address, and optionally add a description to clarify when and why to contact this person or team. |

1. Select **Create** to register the skill in your API center.

After registration, the skill appears in your inventory on the **Inventory** > **Assets** page.

## Update a registered skill

You can update skill information at any time:

1. In your API center, go to **Inventory** > **Assets**.
1. Find and select the skill you want to update.
1. Select **Edit** to modify the skill's properties.
1. Make your changes and select **Save**.

## Integrate a Git repository to synchronize skills

To automate skill registration and updates, you can integrate a Git repository with your API center. This allows you to synchronize information about one or more skills from the repository to your API center inventory. Whenever the skill information updates in the repository, those updates automatically synchronize to your API center, ensuring that your skill registry stays current.

When you integrate a Git repository:

* An [environment](key-concepts.md#environment) is created in your API center, representing the repository as a source of skills.

### Store PAT in Azure Key Vault

Manually upload and securely store the PAT in Azure Key Vault as a secret, and take note of the secret's identifier URI (for example, `https://<your-vault-name>.vault.azure.net/secrets/<secret-name>`). You use this URI when integrating the Git repository with API Center to synchronize skills. 

For more information, see [Quickstart: Set and retrieve a secret from Azure Key Vault using the Azure portal](/azure/key-vault/secrets/quick-create-portal).

### Configure a managed identity for your API center

Your API center uses a managed identity to authenticate to Azure Key Vault and retrieve the PAT needed to access the Git repository.

When you set up the Git repository integration, API Center can automatically configure a managed identity for you and assign it the necessary permissions to access the Key Vault. Alternatively, you can manually configure a managed identity and assign it permissions before setting up the integration. For more information, see the following sections.

[!INCLUDE [enable-managed-identity](includes/enable-managed-identity.md)]

### Assign the managed identity the Key Vault Secrets User role

[!INCLUDE [configure-managed-identity-kv-secret-user](includes/configure-managed-identity-kv-secret-user.md)]

### Integrate a Git repository

To integrate a Git repository:

1. In the [Azure portal](https://portal.azure.com), go to your API center.
1. In the sidebar menu, select **Platforms** > **Integrations**.
1. Select **+ New integration** and choose **From Git repository**.
1. On **Integrate your Git repository**, provide the following information:

    | Field | Description |
    |-------|-------------|
    | **Configure Git repository source** ||
    | **Repository URL** | Enter the URL to the Git repository containing skill files, optionally specifying branch and subfolder (for example, `https://github.com/<org>/<repo>/tree/main/skills`). |
    | **Git provider** | Select the provider (for example, **GitHub**). |
    | **Asset type configuration** | API Center configures a default **skill** asset type with file pattern `**/skill.md.` <br/><br/>Select **+ Add asset type** to add one or more asset types to sync. |
    | **Personal access token (PAT)** | Select the Key Vault secret that contains the PAT to access the repository (for example, `https://<your-vault-name>.vault.azure.net/secrets/<secret-name>`). |
    | **Integration details** | Accept the generated link identifier or provide a custom ID for the integration link. |
    | **Environment details** | |
    | **Environment title** | Enter a friendly name for the repository environment (for example, *Git repository*). |
    | **Identification** | Enter an environment resource name (for example, *git-repository*). |
    | **Environment type** | Select the environment type (for example, **Production**). |
    | **Description** | Optionally add a description for the environment. |
    | **Asset details** | |
    | **Lifecycle** | Select the lifecycle stage for assets synced from the repository (for example, **Design**). |
1. Select **Create**.

The portal adds the environment to your API center. The portal adds the skills from the repository to the API center inventory.

## Related content

* [Register and discover MCP servers in your API inventory](register-discover-mcp-server.md)
* [Set up your API Center portal](set-up-api-center-portal.md)
* [Key concepts in Azure API Center](key-concepts.md)
