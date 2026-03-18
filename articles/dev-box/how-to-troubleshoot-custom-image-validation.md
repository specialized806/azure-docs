---
title: Troubleshoot custom image validation for Microsoft Dev Box
titleSuffix: Microsoft Dev Box
description: Learn how to troubleshoot custom image validation failures in Microsoft Dev Box, including how to test images with equivalent VMs, understand Dev Box architecture differences, and resolve common validation errors.
services: dev-box
ms.service: dev-box
author: RoseHJM
ms.author: rosemalcolm
ms.date: 03/18/2026
ms.topic: troubleshooting
ai-usage: ai-assisted

#customer intent: As a platform engineer, I want to troubleshoot custom image validation failures in Microsoft Dev Box so that I can identify and fix issues that prevent my image from being used in dev box definitions.
---

# Troubleshoot custom image validation for Microsoft Dev Box

This article helps you diagnose custom image validation failures when your image appears to meet requirements and works when deployed as an Azure VM, but fails Dev Box definition validation.

## Prerequisites

- Permissions to read and manage the Azure Compute Gallery image and related resources, such as **Owner** or **Contributor** on the subscription or resource group that contains the gallery.
- Permissions to create or update Dev Box resources, such as **DevCenter Project Admin** (or higher) on the dev box project.

## Verify your image meets requirements

Start by verifying that your image meets Dev Box requirements (Trusted Launch, Generation 2, generalized, Windows 10/11 Enterprise, and required disk configuration).

For a complete preparation walkthrough, see [Prepare a custom image for Microsoft Dev Box](how-to-prepare-custom-image-dev-box.md).

## Test the image with an equivalent VM

If Dev Box validation fails, deploy a test VM using the same SKU family used for Dev Box validation. If the VM fails to boot, inspect boot diagnostics to identify the failure.

The following example deploys a test VM using `Standard_D4s_v5`. You can also test with `Standard_D4as_v5`.

These examples use Bash-style variables (for example, Azure Cloud Shell).

```azurecli
az login

RESOURCE_GROUP="test-image-rg"
LOCATION="eastus"
VM_NAME="test-devbox-image"
SUBSCRIPTION_ID="<subscription-id>"
GALLERY_RG="your-gallery-rg"
GALLERY_NAME="your-gallery"
IMAGE_DEF="your-image-definition"
IMAGE_VERSION="1.0.0"

az account set --subscription "$SUBSCRIPTION_ID"

az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

IMAGE_ID="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$GALLERY_RG/providers/Microsoft.Compute/galleries/$GALLERY_NAME/images/$IMAGE_DEF/versions/$IMAGE_VERSION"

az vm create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --image "$IMAGE_ID" \
  --size "Standard_D4s_v5" \
  --security-type "TrustedLaunch" \
  --enable-secure-boot true \
  --enable-vtpm true \
  --admin-username "azureuser" \
  --admin-password "<secure-password>" \
  --public-ip-sku Standard \
  --boot-diagnostics-storage ""
```

If you want to test with an AMD-based SKU, create a second VM:

```azurecli
az vm create \
  --resource-group "$RESOURCE_GROUP" \
  --name "${VM_NAME}-amd" \
  --image "$IMAGE_ID" \
  --size "Standard_D4as_v5" \
  --security-type "TrustedLaunch" \
  --enable-secure-boot true \
  --enable-vtpm true \
  --admin-username "azureuser" \
  --admin-password "<secure-password>" \
  --boot-diagnostics-storage ""
```

### View boot diagnostics

If the VM fails to start, review boot diagnostics.

```azurecli
az vm boot-diagnostics get-boot-log \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME"
```

For more information, see [Azure boot diagnostics](https://learn.microsoft.com/azure/virtual-machines/boot-diagnostics).

### Clean up test resources

```azurecli
az group delete --name "$RESOURCE_GROUP" --yes --no-wait
```

## Understand Dev Box architectural differences

Even if a VM deployment succeeds, Dev Box validation can fail because Dev Box provisioning and validation operate differently than direct VM creation in your subscription.

### Hosted on-behalf-of architecture

Dev boxes are hosted in a Microsoft-managed subscription on your behalf. The dev box connects to your network connection, but the underlying resources aren't deployed into your subscription.

This architecture affects validation and provisioning in the following ways:

- Dev Box must access your Azure Compute Gallery across subscription boundaries.
- Image replication is performed by the service.
- Validation checks image definition metadata (for example, Trusted Launch security type and generalized OS state) and can reject images that a direct VM deployment might still accept.

### Identity and permissions

Dev Box uses the dev center managed identity for image validation and replication. This identity is different from your user account and any service principal used to build the image.

Common identity-related causes of validation failures include:

- The dev center managed identity doesn't have the **Contributor** role on the gallery.
- A cross-subscription gallery is attached without granting the dev center managed identity access in the gallery subscription.
- Network restrictions (firewalls, private endpoints) prevent the dev center managed identity or the Microsoft.DevCenter resource provider from accessing dependent resources.

### Network connectivity

Dev boxes use Azure Virtual Desktop for connectivity and require outbound access to Microsoft endpoints during provisioning. When you use a network connection, DNS and outbound rules are enforced by your virtual network configuration.

Common network-related causes of provisioning failures include:

- Outbound traffic is blocked to required endpoints.
- DNS settings prevent resolution of required public endpoints.
- NSG rules block HTTPS (443) egress.

### Common scenarios where VM deployments succeed but Dev Box validation fails

| Scenario | Why a VM deployment might succeed | Why Dev Box validation might fail |
|---|---|---|
| Image definition missing Trusted Launch metadata | You can deploy a VM if the image version is otherwise usable | Dev Box checks image definition metadata and rejects the image |
| Dev center identity lacks gallery permissions | Not applicable because you use your own credentials | Dev Box can't read or replicate the image |
| Image isn't replicated to required region | You might deploy a VM in a region where the image is already available | Dev Box can't replicate the image to target regions without permissions |
| Image definition is specialized | You can deploy a specialized image as a VM | Dev Box requires a generalized image |
| Hyper-V generation mismatch | Some deployments might succeed depending on VM size and boot mode | Dev Box requires Generation 2 images |

## Known issues and solutions

### Issue: Image validation fails when using a disk encryption set (customer-managed keys)

**Symptoms:**

- Dev Box definition validation fails with a `SourceImageInvalid` error.
- The same image deploys successfully as an Azure VM.

**Root cause:**

Dev Box supports platform-managed keys (PMK) for disk encryption. Customer-managed keys (CMK) via disk encryption sets aren't supported for Dev Box images.

If your build process associates the image to a disk encryption set, validation fails.

The following example shows a Packer `azure-arm` source configuration that can cause this problem:

```hcl
source "azure-arm" "devbox" {
  disk_encryption_set_id = local.image.diskEncryptionId
}
```

**Solution:**

- Rebuild the image without associating a disk encryption set.
- If you're using Packer, remove any disk encryption set configuration from the image build and produce a new image version.

The following example shows a corrected Packer `azure-arm` source configuration (with no disk encryption set association):

```hcl
source "azure-arm" "devbox" {
  secure_boot_enabled = true
  vtpm_enabled        = true
  security_type       = "TrustedLaunch"

  os_type      = "Windows"
  license_type = "Windows_Client"
  vm_size      = "Standard_D8s_v5"
}
```

**Prevention:**

- Avoid using disk encryption sets for Dev Box images until CMK support is available.
- Standardize your image pipeline so disk encryption set settings aren't reintroduced.

### Issue: The image exists in the gallery but doesn't appear in the Dev Box definition image list

**Symptoms:**

- The image and image version are visible in Azure Compute Gallery.
- When you create or edit a dev box definition, the image isn't shown.
- No error is displayed.

**Root cause:**

One or more of the following conditions can prevent the image from being listed:

- The dev center managed identity doesn't have **Contributor** on the gallery.
- The image isn't replicated to the dev center region or required network connection regions.
- The image definition doesn't meet required metadata settings and is filtered out.

**Solution:**

Verify permissions, replication targets, and image definition configuration.

If you use the Azure CLI commands in this section, install or upgrade the `devcenter` extension:

```azurecli
az extension add --name devcenter --upgrade
```

```azurecli
az devcenter admin devcenter show \
  --name "your-dev-center" \
  --resource-group "your-resource-group" \
  --query "identity.principalId" \
  -o tsv
```

```azurecli
az role assignment create \
  --assignee "<managed-identity-principal-id>" \
  --role "Contributor" \
  --scope "/subscriptions/<gallery-subscription>/resourceGroups/<gallery-rg>/providers/Microsoft.Compute/galleries/<gallery-name>"
```

```azurecli
az sig image-version show \
  --resource-group "your-gallery-rg" \
  --gallery-name "your-gallery" \
  --gallery-image-definition "your-image-definition" \
  --gallery-image-version "1.0.0" \
  --query "publishingProfile.targetRegions[].name" \
  -o tsv
```

```azurecli
az sig image-version update \
  --resource-group "your-gallery-rg" \
  --gallery-name "your-gallery" \
  --gallery-image-definition "your-image-definition" \
  --gallery-image-version "1.0.0" \
  --add publishingProfile.targetRegions name="<dev-center-region>"
```

```azurecli
az sig image-definition show \
  --resource-group "your-gallery-rg" \
  --gallery-name "your-gallery" \
  --gallery-image-definition "your-image-definition" \
  --query "{securityType:features[?name=='SecurityType'].value|[0],hyperVGeneration:hyperVGeneration,osState:osState}" \
  -o json
```

**Prevention:**

- Assign the dev center managed identity permissions before you attach the gallery.
- Replicate images to all required regions.
- Validate image definition configuration before you build new image versions.

## Related content

- [Prepare a custom image for Microsoft Dev Box](how-to-prepare-custom-image-dev-box.md)
- [Authenticate to Microsoft Dev Box](how-to-authenticate.md)
- [Configure Azure Compute Gallery for Microsoft Dev Box](how-to-configure-azure-compute-gallery.md)
- [Azure boot diagnostics](https://learn.microsoft.com/azure/virtual-machines/boot-diagnostics)
- [carmada-dev/demo-images](https://github.com/carmada-dev/demo-images)
