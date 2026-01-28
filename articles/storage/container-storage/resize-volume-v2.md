---
title: Resize persistent volumes in Azure Container Storage
description: Resize persistent volumes in Azure Container Storage without downtime. Scale up by expanding volumes backed by Elastic SAN and local NVMe.
author: saurabh0501
ms.service: azure-container-storage
ms.topic: how-to
ms.date: 01/28/2026
ms.author: saurabsharma
# Customer intent: "As a cloud engineer, I want to resize persistent volumes in Azure Container Storage without downtime so that I can ensure my applications have the necessary storage resources as demand increases."
---

# Resize persistent volumes in Azure Container Storage without downtime

You can expand persistent volumes in Azure Container Storage to scale up quickly and without downtime. Shrinking persistent volumes isn't supported.

You can't increase a volume beyond the maximum capacity available in your Elastic SAN or the local NVMe storage available on your nodes. To expand the volume in case of insufficient capacity, first [increase your Elastic SAN capacity](elastic-san-expand.md) or [increase your ephemeral disk (local NVMe) capacity](use-container-storage-with-local-.md#manage-storage) by adding more nodes your AKS cluster. After doing so, you can expand the volume size accordingly.

## Prerequisites

- This article requires the latest version of the Azure CLI. See [How to install the Azure CLI](/cli/azure/install-azure-cli). If you're using Azure Cloud Shell, the latest version is already installed. If you plan to run the commands locally instead of in Azure Cloud Shell, be sure to run them with administrative privileges.

- This article assumes you've already installed Azure Container Storage v2.x.x on your AKS cluster, and that you've created a persistent volume claim (PVC) using either [Elastic SAN](use-container-storage-with-elastic-san-version-2.md‎) or [ephemeral disk (local NVMe)](use-container-storage-with-local-disk.md). 

## Expand a volume

Follow these instructions to resize a persistent volume. A built-in storage class supports volume expansion, so be sure to reference a PVC previously created by an Azure Container Storage storage class. For example, if you created the PVC for Elastic SAN, it might be called `elasticsanpvc`.

1. Run the following command to expand the PVC by increasing the `spec.resources.requests.storage` field. Replace `<pvc-name>` with the name of your PVC. Replace `<size-in-Gi>` with the new size, for example 100Gi.
   
   ```azurecli-interactive
   kubectl patch pvc <pvc-name> --type merge --patch '{"spec": {"resources": {"requests": {"storage": "<size-in-Gi>"}}}}'
   ```
   
1. Check the PVC to make sure the volume is expanded:
   
   ```azurecli-interactive
   kubectl describe pvc <pvc-name>
   ```
   
The output should reflect the new size.

## See also

- [What is Azure Container Storage (version 1.x.x)?](container-storage-introduction-version-1.md)
