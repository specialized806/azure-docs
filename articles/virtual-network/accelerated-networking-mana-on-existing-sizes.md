---
title: Microsoft Azure Network Adapter (MANA) suppot for existing VM SKUs
description: Update for Microsoft Azure Network Adapter (MANA) support for existing VM SKUs
author: alisheriffMSFT
ms.service: azure-virtual-network
ms.topic: how-to # Need to determine what is the right value
ms.date: 02/02/2026
ms.author: mattmcinnes
# Customer intent: As a cloud administrator, I want to learn about Microsoft Azure Network Adapter, Accelerated Networking and how these work with non-V6 VM SKUs on Intel.
---

# MANA support for existing VM SKUs

The following documentation is for customers of existing VM SKUs and using Accelerated Networking. To learn more about Accelerated Networking and the Networking performance benefits it provides, please visit [Accelerated Networking Overview](https://aks.ms/accelnet) for more information.

Per the [announcement](https://aka.ms/announcemanasupportforexistingvms), General Purpose Compute VM deployments may allocate to compute hardware with the [Microsoft Azure Network Adapter](/azure/virtual-network/accelerated-networking-mana-overview). Initially, the scope will be for Intel based VM SKUs but will expand to ARM and AMD based VM SKUs as well in the future.

Microsoft Azure Network Adapter (MANA) was introduced in February 2025 as part of Azure Boost with the launch of the Intel v6 family of virtual machines. MANA is an Azure optimized, performance focused, Accelerated Networking enabled device that is an integral part of the newest Azure Boost offerings.

For optimal Accelerated Networking performance, the Virtual Machine (VM) should use an operating system that fully supports NVIDIA `ConnectX-3`, `ConnectX-4 Lx`, `ConnectX-5`, **and** `MANA`.

When a VM using an operating system which does not support MANA is deployed on MANA hardware, it will seamlessly leverages the NetVSC network adapter. In this scenario, the MANA Virtual Function (VF) will be visible but there no interfaces will be exposed by the MANA driver. Due to advancements in host infrastructure technology, the Accelerated Networking performance for a VM that receives the NetVSC network adapter, is expected to be close to SRIOV/VF mode NVIDIA `ConnectX-3`, `ConnectX-4 Lx`, `ConnectX-5`, but may still be slower especially for high number of connections.

While Azure has performed extensive testing across a wide range of use cases, there remains a rare possibility that virtual machines may experience intermittent connectivity or degraded performance.  

In such instances and for best performance and overall experience, it is highly recommended that customers migrate to the latest generation of VMs or at a minimum utilize operating systems that fully support MANA. 

## FAQ

### My workload doesn’t use Accelerated Networking. Can I expect any changes?
No. If your workload doesn’t support Accelerated Networking today, there is no impact or change to your workload. However, for the best performance, the recommendation is to use Accelerated Networking. [Accelerated Networking Overview](https://aks.ms/accelnet) has more information about Accelerated Networking.

### What VM sizes are impacted by this change?
Dsv5, Dv5, Ddsv5, Ddv5, Dlsv5, Dldsv5, Esv5, Ev5, Edsv5, Edv5, Ebsv5, Ebdsv5, Dsv4, Dv4, Ddsv4, Ddv4, Esv4, Ev4, Edsv4, Edv4, Dsv3, Dv3, Esv3, Ev3, Bsv2, Dv2, Dsv2, Av2, Fsv2, Fs, F, G, GS, Ls 

Please note that some of these VM sizes will soon be retired. It is highly recommended that customers utilize the latest generations of Azure VMs for improved performance, functionality, and resiliency. 

### Will existing VMs deployed on MANA hardware?
VMs already deployed will be eligible to land on MANA capable hardware following a “stop-deallocate and start” command, or through a redeploy operation. All new VMs in the series listed above will be eligible to be deployed on MANA capable hardware as well. 

### How will I know if my VM has been deployed on MANA capable hardware? 

To determine if your VM Guest Operating System supports MANA, please follow the instructions described in [Linux VMs with the Microsoft Azure Network Adapter](/azure/virtual-network/accelerated-networking-mana-linux). then you will see a PCIe device in the virtual machine as well as the bonded NIC. 

### What will be the performance implications for Accelerated Networking enabled VMs? 
If the VM’s underlying operating system supports all network devices used in Azure, there is no expected change in performance. This is because networking limits are associated with the VM Size as opposed to the underlying hosting infrastructure.  

If the VM’s underlying operating system is not fully compatible with MANA, it will seamlessly receive the NetVSC network adapter. In this scenario, due to advancements in host infrastructure technology, the Accelerated Networking performance is expected to be comparable to NVIDIA ConnectX-3, ConnectX-4 Lx, ConnectX-5.  

>[!Note] 
>While Azure has performed extensive testing across a wide range of use cases, there remains a rare possibility that virtual machines may experience intermittent connectivity or degraded performance. In such an instance, it is highly recommended to migrate to the latest generation of VMs or at a minimum, utilize operating systems that fully support MANA. You should see a PCIe device in the virtual machine as well as the bonded NIC.

### I use a DPDK-based application that does not yet support MANA, will there be any impact to my workload? 
Yes. We recommend that you update your DPDK-based applications to support MANA. Information on DPDK with MANA can be found in [Microsoft Azure Network Adapter (MANA) and DPDK on Linux](/azure/virtual-network/setup-dpdk-mana).

### What are the minimum requirements to support MANA and DPDK? 
Please visit [Microsoft Azure Network Adapter (MANA) and DPDK on Linux](/azure/virtual-network/setup-dpdk-mana) for the minimum requirements to support MANA and DPDK. 

### Are Network Virtual Appliances (NVAs) impacted by this change? 
NVAs based on the VM Sizes listed above may also be deployed on MANA capable hardware starting in March 2026. Please visit [NVA Support insert link to NVA doc page][def] for more information about MANA support for NVAs. 

### Where can I find more information about MANA? 
To learn more about MANA, please visit [Microsoft Azure Network Adapter](/azure/virtual-network/accelerated-networking-mana-overview). On this page you can learn more about operating system support for MANA, installing MANA device drivers (Windows), and more information about MANA capabilities.  

### What should I do if I have issues? 
We’re here to help. Please contact Microsoft Support, who can assist with troubleshooting, guidance, and next steps. You can open a support request through the Azure Portal by selecting Help + support, or visit the Microsoft Support site to start a new case. A support engineer will review your request, engage internal teams as needed, and keep you updated until the issue is resolved. 

## Additional Resources

- [Accelerated Networking Overview](https://aks.ms/accelnet)
- [How Accelerated Networking works in Linux and FreeBSD VMs](/azure/virtual-network/accelerated-networking-how-it-works)