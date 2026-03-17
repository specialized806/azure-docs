---
title: Migrate Generation 2 VMs to Azure Trusted Launch Virtual Machines using Azure Migrate
description: Use Azure Migrate to migrate on prem Generation 2 VMs to Azure Trusted Launch VMs
author: dhananjayanr
ms.author: dhananjayanr
ms.topic: how-to
ms.service: azure-migrate
ms.reviewer: v-uhabiba
ms.date: 03/16/2026
ms.custom: engagement-fy26
# Customer intent: "As an IT administrator, I want to migrate servers to Azure Trusted Launch VMs so that I can ensure enhanced security for my VMs."
---

# Migrate Generation 2 VMs to Azure Trusted Launch Virtual Machines using Azure Migrate

Azure Migrate now supports migrating your Generation 2 VMs to Azure Virtual Machines with Trusted Launch. Trusted Launch uses UEFI-based Secure Boot and a virtual Trusted Platform Module (vTPM) to establish a trusted boot chain. This ensures that only approved and signed components load during startup, reducing the risk from bootkits, rootkits, and other low-level malware.

Trusted Launch is the default security type for supported Generation 2 VMs and virtual machine scale sets in Azure, where available. [Learn more](/azure/virtual-machines/trusted-launch) about Trusted Launch Virtual Machines.

## Supported operating systems
Azure Migrate supports all Operating systems that are supported for Trusted Launch in Azure. See [Azure supported OS list and VM sizes](/azure/virtual-machines/trusted-launch#operating-systems-supported) for more information.

>[!Note]
>Trusted Launch is a security feature for Generation 2 VMs. Generation 1 VMs use BIOS and MBR, and they do not support Secure Boot or vTPM by design. As a result, Generation 1 VMs cannot use Trusted Launch and Azure migrate does not support migrating Gen 1 VMs to Trusted Launch virtual Machines

## Secure boot
At the root of Trusted Launch is Secure Boot. Secure Boot is implemented in platform firmware and protects virtual machines from malware such as bootkits and rootkits.Secure Boot ensures that only signed operating systems and drivers can start. It establishes a trusted boot chain for the virtual machine.When Secure Boot is enabled, all operating system boot components—including the boot loader, kernel, and kernel drivers—must be signed by trusted publishers. Both Windows and supported Linux distributions support Secure Boot. If Secure Boot cannot verify a trusted signature, the virtual machine fails to boot.

>[!Note]
>Secure Boot is configured as part of the Trusted Launch settings on the target VM and isn’t inherited from the source VM. Even if Secure Boot was enabled on the source VM, it isn’t automatically enabled on the migrated Trusted Launch VM. You must explicitly enable Secure Boot in the Trusted Launch configuration during migration.

## How to migrate to trusted launch VMs using azure migrate:
This guide explains how to migrate your workloads to Trusted Launch VMs using Azure Migrate.See [how to migrate to Trusted Launch Virtual machines using Azure Migrate](articles/migrate/tutorial-migrate-vmware.md#set-up-the-azure-migrate-appliance) for more information.

