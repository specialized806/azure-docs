---
title: Shared variable file pattern
description: Describes the shared variable file pattern.
author: johndowns
ms.author: jodowns
ms.topic: conceptual
ms.custom: devx-track-bicep
ms.date: 04/28/2025
---

# Shared variable file pattern

Reduce the repetition of shared values in your Bicep files. Instead, load those values from a shared JSON file within your Bicep file. When using arrays, concatenate the shared values with deployment-specific values in your Bicep code.

## Context and problem

When you write your Bicep code, you might have common variables that you reuse across a set of Bicep files. You could duplicate the values each time you declare the resource, such as by copying and pasting the values between your Bicep files. However, this approach is error-prone, and when you need to make changes you need to update each resource definition to keep it in sync with the others.

Furthermore, when you work with variables defined as arrays, you might have a set of common values across multiple Bicep files and also need to add specific values for the resource that you're deploying. When you mix the shared variables with the resource-specific variables, it's harder for someone to understand the distinction between the two categories of variables.

## Solution

Create a JSON file that includes the variables you need to share. Use the [`loadJsonContent()` function](bicep-functions-files.md#loadjsoncontent) to load the file and access the variables. For array variables, use the [`concat()` function](bicep-functions-array.md#concat) to combine the shared values with any custom values for the specific resource.

## Example 1: Naming prefixes

Suppose you have multiple Bicep files that define resources. You need to use a consistent naming prefix for all of your resources.

Define a JSON file that includes the common naming prefixes that apply across your company:

::: code language="json" source="~/azure-docs-bicep-samples/samples/patterns-shared-variable-file/shared-prefixes.json" :::

In your Bicep file, declare a variable that imports the shared naming prefixes:

::: code language="bicep" source="~/azure-docs-bicep-samples/samples/patterns-shared-variable-file/example-1.bicep" range="1" :::

When you define your resource names, use string interpolation to concatenate the shared name prefixes with unique name suffixes:

::: code language="bicep" source="~/azure-docs-bicep-samples/samples/patterns-shared-variable-file/example-1.bicep" range="3-4" :::

## Example 2: Network security group rules

Suppose you have multiple Bicep files that define their own network security groups (NSG). You have a common set of security rules that must be applied to each NSG, and then you have application-specific rules that must be added.

Define a JSON file that includes the common security rules that apply across your company:

::: code language="json" source="~/azure-docs-bicep-samples/samples/patterns-shared-variable-file/shared-rules.json" :::

In your Bicep file, declare a variable that imports the shared security rules:

::: code language="bicep" source="~/azure-docs-bicep-samples/samples/patterns-shared-variable-file/example-2.bicep" range="5" :::

Create a variable array that represents the custom rules for this specific NSG:

::: code language="bicep" source="~/azure-docs-bicep-samples/samples/patterns-shared-variable-file/example-2.bicep" range="6-21" :::

Define the NSG resource. Use the `concat()` function to combine the two arrays together and set the `securityRules` property:

::: code language="bicep" source="~/azure-docs-bicep-samples/samples/patterns-shared-variable-file/example-2.bicep" range="23-29" highlight="5" :::

## Considerations

- When you use this approach, the JSON file will be included inside the ARM template generated by Bicep. The JSON ARM templates generated by Bicep have a file limit of 4MB, so it's important to avoid using large shared variable files.
- Ensure your shared variable arrays don't conflict with the array values specified in each Bicep file. For example, when using the configuration set pattern to define network security groups, ensure you don't have multiple rules that define the same priority and direction.

## Next steps

[Learn about the configuration set pattern.](patterns-configuration-set.md)
