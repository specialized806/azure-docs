---
title: Configure host scaling
titleSuffix: Azure Bastion
description: Learn how to add more instances (scale units) to Azure Bastion.
author: abell
ms.service: azure-bastion
ms.topic: how-to
ms.date: 03/13/2026
ms.author: abell
# Customer intent: As a network administrator, I want to configure scale units and understand what the impact it will be on my cloud environment.

---

# Configure host scaling for Azure Bastion

This article helps you add scale units (instances) to your Azure Bastion deployment so you can support more concurrent client connections. Each instance supports 20 concurrent RDP connections and 40 concurrent SSH connections for medium workloads. For more information about host scaling, see [Instances and host scaling](configuration-settings.md#instance).

> [!IMPORTANT]
> Host scaling requires the Standard SKU tier or higher. Any changes to scale units will disrupt active Bastion connections.

## Configuration steps

# [Azure portal](#tab/portal)

1. Sign in to the [Azure portal](https://portal.azure.com).
1. Go to your Bastion host.
1. On the **Configuration** page, for **SKU**, verify the SKU is **Standard** or higher. If the SKU is Basic, select a higher SKU.
1. Adjust the **Instance count**. Each instance is a scale unit.
1. Select **Apply** to apply changes.

# [PowerShell](#tab/powershell)

1. Get the target Bastion resource. Use the following example, modifying the values as needed.

   ```azurepowershell-interactive
   $bastion = Get-AzBastion -Name bastion -ResourceGroupName bastion-rg
   ```

1. Set the target scale unit, also known as "instance count". In the following example, the scale units are set to 5.

   ```azurepowershell-interactive
   $bastion.ScaleUnit = 5
   Set-AzBastion -InputObject $bastion
   ```

1. Confirm **Y** to overwrite the resource. After the resource is overwritten, the specified value is shown in the output for **Scale Units**.

---

## Next steps

* Learn about [Azure Bastion configuration settings](configuration-settings.md).
