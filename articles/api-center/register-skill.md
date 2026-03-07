---
title: Register Skills in Your API Center
description: Learn how to register skills in Azure API Center to create a centralized skills registry for your organization. 
ms.service: azure-api-center
ms.topic: how-to
ms.date: 03/06/2026
ai-usage: ai-assisted


ms.collection: ce-skilling-ai-copilot
ms.update-cycle: 180-days
# Customer intent: As an API program manager, I want to register skills in my API Center inventory so developers can discover and use them.
ms.custom:
---

# Register skills in your API inventory

This article describes how to use Azure API Center to register agent [skills](https://agentskills.io/home) as part of your API inventory. Skills are reusable capabilities that can be discovered and consumed by  AI agents to extend their functionality.

> [!NOTE]
> Registering skills in API Center is currently in preview.

By registering skills in your API center, you create a centralized registry that helps your organization:

- Discover available skills and their capabilities
- Access source code and documentation

## Prerequisites

- An API center. If you don't have an API center yet, see the quickstart to [Create an API center](set-up-api-center.md).
- One or more skills that you want to register, typically hosted in a source code repository such as GitHub.
- (For integration with a Git repository) A personal access token (PAT) to access the repository where your skill information is stored. The PAT must have appropriate permissions to read the repository content. If you want to integrate with GitHub, see [Create a fine-grained personal access token](https://docs.github.com/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token) for instructions. 

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
    | **Source URL** | Enter the URL to the skill's Git source code repository (for example, *https://github.com/org/repo/tree/main/docs*). |
    | **Compatibility** | Describe the requirements, dependencies, and prerequisites for using the skill (for example, required software or tools like git, docker, programming languages; system requirements; network access requirements; API keys or authentication requirements). |
    | **Allowed tools** | Select **+ Add tool** to specify the APIs or MCP servers from your API inventory that this skill can access. This helps ensure proper governance and security by explicitly defining what resources the skill can consume. |
    | **License** | Select **+ Add** to provide licensing information. Enter the license name (for example, *MIT*, *Apache 2.0*, or *Proprietary*), optionally provide a license URL, and add a description if needed to clarify licensing terms or restrictions. |
    | **Contact information** | Select **+ Add** to add contact points for support or inquiries. Enter a contact name or role (for example, *API Team* or *John Smith*), provide contact details such as email address, and optionally add a description to clarify when and why to contact this person or team. |

1. Select **Create** to register the skill in your API center.

After registration, the skill appears in your API inventory.

## Update a registered skill

You can update skill information at any time:

1. In your API center, go to **Inventory** > **Assets**.
1. Find and select the skill you want to update.
1. Select **Edit** to modify the skill's properties.
1. Make your changes and select **Save**.

## Integrate a Git repository to synchronize skills

To automate skill registration and updates, you can integrate a Git repository with your API center. This allows you to synchronize information about one or more skills from your repository to your API center inventory. Whenever you update the skill information in the repository, those updates automatically synchronize to your API center, ensuring that your skill registry stays current.

### Configure a managed identity for your API center

[!INCLUDE [enable-managed-identity](includes/enable-managed-identity.md)]

### Assign the managed identity the Key Vault Secrets User role

[!INCLUDE [configure-managed-identity-kv-secret-user](includes/configure-managed-identity-kv-secret-user.md)]mation about one or more skills from your repository.

[!INCLUDE [enable-managed-identity](includes/enable-managed-identity.md)]

## Assign the managed identity the Key Vault Secrets User role

[!INCLUDE [configure-managed-identity-kv-secret-user](includes/configure-managed-identity-kv-secret-user.md)]




To integrate a Git repository:

1. In your API center, go to **Platforms** > **Integrations**.
1. Select **+ New integration** and choose **From Git repository**.
1. Follow the prompts to authenticate with GitHub and select the repository that contains your skill information. You can specify a branch, folder path, or file pattern to target specific skill definition files in your repository.
## Related content

* [Register and discover MCP servers in your API inventory](register-discover-mcp-server.md)
* [Set up your API Center portal](set-up-api-center-portal.md)
* [Key concepts in Azure API Center](key-concepts.md)
