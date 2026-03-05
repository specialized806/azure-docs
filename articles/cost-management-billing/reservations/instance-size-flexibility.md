---
title: VM instance size flexibility for Azure Reservations
description: Learn how instance size flexibility works for Azure VM reservations and how discount matching is calculated.
author: pri-mittal
ms.author: primittal
ms.reviewer: primittal
ms.service: cost-management-billing
ms.subservice: reservations
ms.topic: conceptual
ms.date: 03/05/2026
---

# Instance size flexibility (ISF)

Instance Size Flexibility (ISF) is an Azure Reservations capability that allows a single reservation purchase to automatically apply across multiple SKUs, rather than being locked to one exact size. Instead of requiring customers to predict and reserve a specific SKU, ISF applies reservation benefits dynamically based on usage, as long as the resources belong to the same flexibility group. This ensures customers continue to receive reserved pricing even when workloads scale up, scale down, or shift across compatible sizes, reducing operational overhead and improving reservation utilization.

## How instance size flexibility works

Each reservation-enabled service defines instance size flexibility groups where ISF is supported. Only SKUs in the same flexibility group can share a reservation benefit. For example, multiple VM sizes in the same VM family can be in one group, while sizes in a different family aren't.

Within a flexibility group, each SKU has a relative ratio that represents its capacity footprint compared to other sizes in that group:

- Smaller sizes have lower ratios.
- Larger sizes have higher ratios.

Each reservation provides a fixed amount of ratio capacity. Azure applies reservation benefit to running eligible usage until it's consumed. Ratios are relative units, not prices.

Azure continuously evaluates running usage and applies reservation discounts to eligible resources on a first-come, first-served basis within the reservation scope. If usage exceeds the purchased ratio capacity, the remaining usage is billed at pay-as-you-go rates. No manual assignment is required.

## Examples

### VM example

Assume you buy a VM reservation that provides four ratio units per hour for a VM size flexibility group.

- Two running small VMs consume one ratio unit each.
- One running larger VM in the same group consumes two ratio units.

Total ratio usage is four units, so all matching usage gets reservation pricing for that hour. If usage grows beyond four ratio units, the excess is billed at pay-as-you-go rates.

### Microsoft Foundry example

Assume you buy a 300-PTU Global reservation for Microsoft Foundry Provisioned Throughput.

- If you deploy 250 Global PTUs in an hour, all 250 PTUs are covered by the reservation.
- If you deploy 340 Global PTUs in an hour, 300 PTUs are covered and 40 PTUs are billed at pay-as-you-go rates.

Global, Data Zone, and Regional reservations aren't interchangeable, so each deployment type needs its own matching reservation.

## Other services

Reservation benefit matching isn't limited to VM reservations. Similar service-specific reservation behavior also exists for other services, including:

- [Red Hat Enterprise Linux software plans](understand-rhel-reservation-charges.md)
- [Azure Cosmos DB reserved capacity](understand-cosmosdb-reservation-charges.md)
- [Microsoft Foundry Provisioned Throughput reservations](microsoft-foundry.md)

## When the discount applies

For VM reservations, the discount applies when these attributes match:

- VM size group
- Region
- Reservation term
- Scope (single subscription, shared scope, or management group scope)

If there isn't enough matching usage in a given hour, the unused portion of that reservation hour is lost.

## Optimize setting for VM reservations

When you purchase or manage a VM reservation, you can choose an optimize setting:

- **Instance size flexibility**: Prioritizes discount coverage across sizes in the same VM size group.
- **Capacity priority**: Prioritizes capacity reservation for the exact size/region, instead of flexibility across sizes.

For steps to change this setting, see [Change optimize setting for Reserved VM Instances](manage-reserved-vm-instance.md#change-optimize-setting-for-reserved-vm-instances).

## Related content

- [How a reservation discount is applied](reservation-discount-application.md)
- [Understand VM reservation charges](../manage/understand-vm-reservation-charges.md)
- [Virtual machine size flexibility with Reserved VM Instances](/azure/virtual-machines/reserved-vm-instance-size-flexibility)