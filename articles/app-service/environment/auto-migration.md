---
title: Troubleshoot App Service Environment Automigration
titleSuffix: App Service Environment
description: Troubleshoot issues after automigration of App Service Environment v1 or v2 to App Service Environment v3. Learn how you can select manual migration.
author: seligj95
ms.topic: upgrade-and-migration-article 
ms.date: 03/10/2026
ms.author: jordanselig
ms.custom: references_regions
ms.service: azure-app-service
#customer intent: As an App Service developer, I want to address issues after automigration of my App Service Environment v1 or v2 to App Service Environment v3, so I can continue to use my existing apps and other resources.
---
# Troubleshoot automigration to App Service Environment v3

Microsoft automatically migrates all App Service Environment v1 and v2 resources to App Service Environment v3. The automigration helps ensure the App Service Environment runs on a supported platform.

> [!IMPORTANT]
> App Service Environment v1 and v2 are retired and no longer supported.
>
> As of September 1, 2024, Microsoft automigrates App Service Environment v1 and v2 on a best-effort basis. Microsoft makes no claim or guarantees about application availability after automigration. You might need to perform manual configuration to complete the migration or optimize your App Service plan SKU choice to meet your needs.
>
> If automigration isn't feasible, your resources and associated app data are deleted.

Automigration causes about one hour of downtime for your resources. The inbound and outbound IP addresses of your App Service Environment might change during the migration. The downtime can be longer if you have dependencies on the IP addresses or you use features that are unsupported in App Service Environment v3.

This article provides guidance on how you can address any issues after automigration of App Service Environment v1 or v2 to App Service Environment v3.

## Automigration limitations

The following limitations apply to automigrations:

- The new App Service Environment v3 is in the same subnet as the v1 or v2 environment.

- The new App Service Environment v3 is in the same region as the v1 or v2 environment.

- The new App Service Environment v3 is in the same resource group as the v1 or v2 environment.

- All App Service Environment resources maintain the same names and resource identifiers.

- IP-based TLS/SSL bindings aren't supported in App Service Environment v3.

   If you have App Service Environment v1 or v2 apps with IP-based TLS/SSL bindings, you must remove the bindings after the migration completes. Your apps don't work until you remove the bindings.

- App Service Environment v1 in a [Classic virtual network](/previous-versions/azure/virtual-network/create-virtual-network-classic) isn't supported for migration.

   If you have an App Service Environment v1 in a Classic virtual network, you must migrate the resource manually.

   > [!NOTE]
   > The App Service Environment v1 resource is eligible for deletion at any time.

- The in-place migration feature isn't available in China East 2 and China North 2. App Service Environment v3 isn't available in these regions, so automigration isn't possible.

   If you have an App Service Environment v1 or v2 in these regions, you must migrate the resource manually to a supported region, such as China East 3 or China North 3.

   > [!NOTE]
   > Your App Service Environment v1 or v2 resource is eligible for deletion at any time.

### Ineligible for automigration

There are two scenarios where a resource might be ineligible for automigration.

- The App Service Environment resource is in a region that doesn't support App Service Environment v3.
- The resource is an App Service Environment v1 located in a Classic virtual network.

If the resource is ineligible for automigration and can never automigrate, the portal displays a message with the reason about the ineligibility. You must migrate the resource manually.

> [!NOTE]
> Your App Service Environment is eligible for deletion at any time.

In some cases, you might be temporarily blocked from automigrating the resource, but you can resolve the blocking issue and enable automigration. For example, if you have a resource lock on your App Service Environment, you can remove the resource lock to enable automigration. An automigration blocked by a resource lock, Azure Policy, or networking configuration is automatically suspended. If you need to unsuspend your App Service Environment, open a support ticket.

The following errors might be displayed in the Azure portal when a resource is ineligible for automigration:

| Error | Recommendation |
|---|---|
| The App Service Environment v1 is in a Classic virtual network. Classic virtual networks don't support App Service Environment v3. | You must migrate the resource manually. |
| A resource lock exists on the App Service Environment or a connected resource (virtual network, resource group, or subscription) that's preventing the migration. | To enable automigration, remove the resource lock. |
| An [Azure Policy](/azure/governance/policy/overview) is preventing the migration. | To enable automigration, remove any Azure Policy that blocks resource modifications or deletions for the App Service Environment or the virtual network for the environment. |
| The App Service Environment is in a region that doesn't support automigration. | You must migrate the resource manually. |

## Options for suspended App Service Environments

If your App Service Environment is suspended, you have three options.

### Unsuspend and self-migrate

To migrate the resource manually, open a support ticket.

1. In the [Azure portal](https://portal.azure.com), go to your **App Service Environment** resource, and select **Settings** > **Migration**.

1. In the **Migration** page, select the **Open support ticket** option.

   :::image type="content" source="./media/migration/suspended-support-ticket.png" border="false" alt-text="Screenshot that shows how to open a support ticket for a suspended App Service Environment in the Azure portal.":::

1. Fill out the form and submit the ticket.

> [!NOTE]
> Microsoft doesn't guarantee an environment can be unsuspended.

### Resume and unsuspend as App Service Environment v3

To expedite migration, you can resume the migration process to App Service Environment v3 and unsuspend the resource.

1. In the [Azure portal](https://portal.azure.com), go to your **App Service Environment** resource, and select **Settings** > **Migration**.

1. In the **Migration** page, select the **Migrate now** option to resume the migration of your environment.

   This action initiates the same process that's used for automigrations. The limitations, downtime, and other considerations are the same as for automigrations.

   :::image type="content" source="./media/migration/resume-as-asev3.png" alt-text="Screenshot that shows how to resume migration to App Service Environment v3 and unsuspend the resource in the Azure portal.":::

If you have more than one suspended App Service Environment resource, you need to resume and unsuspend each resource individually.

### Delete App Service Environment

If you no longer need your App Service Environment, you can delete your environment by using the Azure CLI. This option is the only available method to delete your environment.

> [!IMPORTANT]
> Deleting your environment also deletes the associated apps and App Service plans. This action is irreversible.

As needed, [install the Azure CLI](/cli/azure/install-azure-cli) or use [Azure Cloud Shell](https://shell.azure.com/) with a Bash shell. In the following command, replace the `<placeholder>` portions with the values of your subscription, App Service Environment name, and resource group.

```azurecli
az rest --method delete --url "https://management.azure.com/subscriptions/<SUBSCRIPTION-ID>/resourceGroups/<RESOURCE-GROUP>/providers/Microsoft.Web/hostingEnvironments/<APP-SERVICE-ENVIRONMENT-NAME>?api-version=2020-12-01" --url-parameters forceDelete=true --verbose
```

## Augmented automigration features

The augmented features of the automigration process help reduce the usual effects of migration:

- Automigration attempts to preserve the existing outbound IP address.
- The certificate for a custom domain suffix configuration is temporarily compatible with Azure Key Vault.
- Apps with IP-based TLS/SSL bindings are migrated, but they're nonfunctioning until you remove the bindings.

### Outbound IP address preservation

Previously, migration of App Service Environment v1 or v2 produced a different outbound IP address in App Service Environment v3. The augmented automigration features enable preservation of the App Service Environment v1 and v2 outbound IP address. The preserved address is used as an outbound IP address in App Service Environment v3.

> [!NOTE]
> Preservation of the outbound IP address isn't guaranteed after automigration.

However, App Service Environment v3 has two outbound IP addresses. As such, the augmented automigration process produces two outbound addresses:

- A _new_ outbound IP address
- An outbound IP address from the preserved App Service Environment v1 or v2 address 

If you have a custom domain suffix configuration and you connect to your key vault via the internet, you might need to account for the _new_ outbound IP address.

### Custom domain suffix compatibility for v2

Configuration of a [custom domain suffix on App Service Environment v3](how-to-custom-domain-suffix.md) is different than on App Service Environment v2. App Service Environment v2 uploads the domain certificate directly to the environment and allows nonwildcard certificates. App Service Environment v3 stores the certificate in an Azure key vault that must be accessible to the environment, and doesn't allow nonwildcard certificates.

The augmented automigration features provide a limited compatibility mode for App Service Environment v2 custom domain suffix configurations on App Service Environment v3. Custom domain suffix configuration on App Service Environment v2 migrates to App Service Environment v3. The migration uploads the certificate to App Service Environment v3 and updates the configuration to use the uploaded certificate.

This process provides a temporary solution that's valid only until the current certificate expires. You must [update the configuration to use Azure Key Vault](how-to-custom-domain-suffix.md) after the migration completes and before the certificate expires. If you don't update the configuration, then after the certificate expires, the custom domain suffix doesn't work.

> [!IMPORTANT]
> The custom domain suffix compatibility mode doesn't guarantee a working custom domain suffix configuration after automigration. Update the configuration to use an Azure key vault as soon as possible after the migration completes.

### Migration of IP-based TLS/SSL bindings

App Service Environment v3 doesn't support IP-based TLS/SSL bindings. Previously, you had to remove the bindings before proceeding with the migration. With the augmented automigration features, the automatic validation doesn't check for IP-based TLS/SSL bindings, so the migration can continue. After the migration completes, you must remove any IP-based TLS/SSL bindings from your migrated apps. Your apps don't work until you remove the bindings.

## Solutions for automigration issues 

The following sections describe issues you might encounter with your apps or services after automigration.

- Custom domain suffix configuration from App Service Environment v2 persists after migration.
- Apps with IP-based TLS/SSL bindings stop working after migration.
- Dependent resources point to an App Service Environment v1 or v2 _inbound_ IP address.
- Dependent resources use an App Service Environment v1 or v2 _outbound_ IP address.
- Features change or aren't compatible with App Service Environment v3.

If you have other issues and desire further assistance, contact [Azure Support](https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade).

### Custom domain suffix configuration persists

The augmented automigration features enable custom domain suffix configuration on App Service Environment v2 to persist after migration to App Service Environment v3. This process provides a temporary solution that's valid only until the current certificate expires. For more information, see [Custom domain suffix compatibility for v2](#custom-domain-suffix-compatibility-for-v2) earlier in this article.

### Apps with IP-based TLS/SSL bindings stop working

The augmented automigration features allow migration of App Service Environment v1 or v2 apps with IP-based TLS/SSL bindings. However, because these bindings aren't supported in App Service Environment v3, the apps stop working after migration. After migration completes, you must remove any IP-based TLS/SSL bindings from your migrated apps.

### Resources point to v1 or v2 inbound IP address

For internal load balancer (ILB) App Service Environment migrations, the inbound IP address is always preserved. This functionality remains the same during automigration. No action is required.

For external load balancer (ELB) App Service Environment migrations, the inbound IP address always changes. The change might affect existing `A` records that point to the inbound IP address of the App Service Environment. If you use `A` records, you must update the `A` records to point to the new inbound IP address after the migration completes. If you use `CNAME` records, you likely don't need to make any DNS changes. If you have other dependencies on the inbound IP address, you must update them accordingly. The App Service Environment v1 or v2 inbound IP address is no longer valid after the migration completes.

### Resources use v1 or v2 outbound IP address

The augmented automigration features preserve the App Service Environment v1 and v2 outbound IP address for use in App Service Environment v3.

> [!NOTE]
> Preservation of the outbound IP address isn't guaranteed after automigration.

App Service Environment v3 always has two outbound IP addresses, and the migration process produces two candidates: the _new_ address and the preserved address from App Service Environment v1 or v2. You need to account for both outbound IP addresses in your configuration.

If the App Service Environment v1 or v2 outbound IP address isn't preserved after migration, you must update your configuration to account for the change. For more information, see [Outbound IP address preservation](#outbound-ip-address-preservation) earlier in this article.

### Feature compatibility with App Service Environment v3

Most of the features in App Service Environment v1 and v2 are available and compatible in App Service Environment v3. However, there are some differences:

- IP-based TLS/SSL bindings aren't supported.
- Custom domain suffix configuration is different.
- Default domain is always maintained, even if you have a custom domain suffix.
- Nonwildcard certificates for custom domain suffix aren't allowed.
- App Service Environment v3 has two outbound IP addresses.
- The [available SKUs](https://azure.microsoft.com/pricing/details/app-service/windows/) are different sizes.
- The [pricing model](overview.md#pricing) is different.
- The [networking model](networking.md) is different.
- The FTPS endpoint structure is different. Access to an FTPS endpoint by using a custom domain suffix isn't supported.
- App Service Environment v3 doesn't fall back to Azure DNS, if the configured custom DNS servers in the virtual network aren't able to resolve a given name. If this behavior is required, ensure you have a forwarder to a public DNS or include Azure DNS in the list of custom DNS servers.

If you're using a feature that isn't supported or behaves differently on App Service Environment v3, update your apps accordingly.

## Pricing differences

There's no cost associated with automigrating your App Service Environment. You stop being charged for your previous App Service Environment as soon as it shuts down during the migration process. You start incurring charges for your new App Service Environment v3 after deployment completes. For more information about App Service Environment v3 pricing, see the [pricing details](overview.md#pricing).

When you migrate to App Service Environment v3 from previous versions, there are scenarios that you should consider that can potentially reduce your monthly cost. Consider [how reservation discounts apply to instances](/azure/cost-management-billing/reservations/reservation-discount-app-service#how-reservation-discounts-apply-to-instances) and [Azure savings plans for compute](/azure/cost-management-billing/savings-plan/savings-plan-compute-overview) to further reduce your costs.

> [!NOTE]
> Due to the conversion of App Service plans from Isolated to Isolated v2, your apps might be over-provisioned after the migration because the Isolated v2 tier has more memory and CPU per corresponding instance size. You have the opportunity to [scale up an app in Azure App Service](../manage-scale-up.md) as needed after migration completes. For more information, review the [Azure App Service on Windows pricing](https://azure.microsoft.com/pricing/details/app-service/windows/).

### Scaling options for App Service plans

The App Service plan SKUs available for App Service Environment v3 run on the Isolated v2 (Iv2) tier. The number of cores and amount of RAM are effectively doubled per corresponding tier compared the Isolated tier. When you migrate, your App Service plans are converted to the corresponding tier. For example, your I2 instances are converted to I2v2. While I2 has two cores and 7-GB RAM, I2v2 has four cores and 16-GB RAM. If you expect your capacity requirements to remain unchanged, your configuration is over-provisioned. You might be paying for compute and memory you're not using. In this scenario, you can scale down your I2v2 instance to I1v2 and access a similar number of cores and RAM.

## Support policy for App Service Environment v1 and v2

The following statement represents the Azure App Service Environment v1 and v2 support policy as of September 1, 2024. It doesn't apply to App Service Environment v3 configurations.

_**App Service Environment v1 and v2**_

_This support policy expires at the end of any extension or grace-period that you have been granted written approval by Microsoft to run the services past the scheduled retirement date. Failure to migrate by that date will result in all remaining Azure App Service Environments v1 and v2 being retired which may include but not be limited to deletion of the apps and data, automated in-place migration, and other retirement procedures._

The extended support policy for App Service Environment v1 and v2 includes the following items:
  
- As of September 1, 2024, the [Service Level Agreement (SLA)](https://aka.ms/postEOL/ASE/SLA) is no longer applicable for App Service Environment v1 and v2. Through continued use of the product beyond the retirement date, you acknowledge that Azure doesn't commit to the SLA of 99.95% for the retired environment.

- Microsoft is committed to maintaining the platform and allowing you to complete your migrations. Therefore, Customer Support Services (CSS) and Product Group (PG) support channels continue to handle support cases and Critical Response Incidents (CRIs) in a commercially reasonable manner. No new security and compliance investments are made in App Service Environment v1 and v2.

- App Service continues to patch the operating system and language runtimes in accordance with the platform update processes, as described in [Azure App Service OS and runtime patching](../overview-patch-os-runtime.md).

- App Service continues to test and validate App Service updates before rollout, and continues to follow safe deployment procedures for platform updates.

- App Service continues to actively monitor the production footprint of App Service Environment v1 and v2, and continues to respond to issues detected via this monitoring with the same urgency as today.

- Microsoft continues to accept App Service support cases and drive resolution of App Service issues in a timely manner.

- App Service continues to apply patches and hotfixes for critical App Service platform bugs that might arise.

> [!NOTE]
> You might experience a reduced ability to effectively mitigate issues that can arise from lower-level Azure dependencies. The retirement of App Service Environment v1 and v2 affects all Cloud services, and the management of Azure Services with RedDog Front End (RDFE) components.

To avoid disruption to your services, complete migration to App Service Environment v3 as soon as possible.

## Frequently asked questions

The following list provides answers to frequently asked questions regarding automigration of App Service Environment:

- **Why was my App Service Environment automigrated?**

   App Service Environment v1 and v2 are retired and no longer supported. The supporting infrastructure for App Service Environment v1 and v2 is being decommissioned. To ensure your App Service Environment is running on a supported platform, Microsoft initiates automigrations to App Service Environment v3.

- **Why are my apps not working after automigration?**

   After automigration to App Service Environment v3, you might encounter issues with your apps or services due to feature updates or incompatibilities. To address these issues, see [Solutions for automigration issues](#solutions-for-automigration-issues).

- **What is the downtime during the automigration process?**

   There's about one hour of downtime during the automigration process. The inbound and outbound IP addresses of your App Service Environment might change during the migration process. Downtime might be longer if you have dependencies on these IP addresses. Downtime might also be longer if you use features that aren't supported in App Service Environment v3.

- **Will I be charged for automigration?**

   There's no cost associated with automigrating your App Service Environment. You stop being charged for your previous App Service Environment as soon as it shuts down during the migration process. You start incurring charges for your new App Service Environment v3 after deployment completes.

- **Why was my App Service Environment deleted?**

   If automigration isn't feasible, your resources and associated app data are deleted. We strongly urge you to act now to avoid this scenario.

## Related content

- [Custom domain suffix on App Service Environment v3](how-to-custom-domain-suffix.md)
- [App Service Environment - Pricing model](overview.md#pricing)
- [App Service Environment - Networking](networking.md)