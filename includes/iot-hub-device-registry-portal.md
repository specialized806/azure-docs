---
title: Create an IoT hub with Certificate Management in Azure Device Registry using Azure portal
description: This article explains how to create an IoT hub with Azure Device Registry and Certificate Management integration using the Azure portal.
author: SoniaLopezBravo
ms.author: sonialopez
ms.service: azure-iot-hub
ms.topic: include
ms.date: 11/05/2025
---

## Overview

Use the Azure portal to create an IoT hub with Azure Device Registry and Certificate Management integration.

The setup process in this article includes the following steps:

1. Create an IoT hub with a linked namespace.
1. Create an ADR namespace.
1. Create a DPS instance linked to the ADR namespace and IoT hub.
1. Create a credential and policy and associate them to the namespace.
1. Sync your credential and policies to ADR namespace.
1. Create an enrollment group and link to your policy to enable device onboarding.
1. Assign an ADR role, set up the right privileges, and create a user-assigned managed identity.

> [!IMPORTANT]
> During the preview period, IoT Hub with ADR and Certificate Management features enabled on top of IoT Hub are available **free of charge**. Device Provisioning Service (DPS) is billed separately and isn't included in the preview offer. For details on DPS pricing, see [Azure IoT Hub pricing](https://azure.microsoft.com/pricing/details/iot-hub/).

## Prerequisites

Have an Azure account. If you don't have an Azure account, create a [free account](https://azure.microsoft.com/free/).

## Create an IoT hub and ADR namespace in Azure portal

In this section, you create a new IoT hub instance with a new ADR namespace and user-assigned managed identity assigned to it.

1. Sign in to the [Azure portal](https://portal.azure.com), search for and select **Azure IoT Hub**.
1. In the **IoT Hub** page, select **+ Create** to create a new IoT hub.
1. On the **Basics** tab, complete the fields as follows:

   [!INCLUDE [iot-hub-pii-note-naming-hub](iot-hub-pii-note-naming-hub.md)]

   | Property | Value |
   | ----- | ----- |
   | **Subscription** | Select the subscription to use for your hub. |
   | **Resource group** | Select a resource group or create a new one. To create a new one, select **Create new** and fill in the name you want to use.|
   | **IoT hub name** | Enter a name for your hub. This name must be globally unique, with a length between 3 and 50 alphanumeric characters. The name can also include the dash (`'-'`) character.|
   | **Region** | ADR and Certificate Management functionalities are in **preview** and only available in **certain regions**. See the [supported regions](../articles/iot-hub/iot-hub-what-is-new.md#supported-regions) and select the region, closest to you, where you want your hub to be located.|
   | **Tier** | Select the **Preview** tier. To compare the features available to each tier, select **Compare tiers**.|
   | **Daily message limit** | Select the maximum daily quota of messages for your hub. The available options depend on the tier you select for your hub. To see the available messaging and pricing options, select **See all options** and select the option that best matches the needs of your hub. For more information, see [IoT Hub quotas and throttling](/azure/iot-hub/iot-hub-devguide-quotas-throttling).|
   | **ADR namespace** | Select an existing ADR namespace or create a new one. To create a new one, select **Create new** and fill in the name you want to use.|
   | **User managed identity** | Select a user-assigned managed identity to link to your IoT hub. This identity is used to securely access other Azure resources, such as ADR namespace and DPS. If you don't have a user-assigned managed identity, you can create one in the Azure portal. For more information, see [Create a user-assigned managed identity in the Azure portal](/entra/identity/managed-identities-azure-resources/manage-user-assigned-managed-identities-azure-portal). |
 

   :::image type="content" source="../articles/iot-hub/media/device-registry/iot-hub-gen-2-basics.png" alt-text="Screen capture that shows how to create an IoT hub in the Azure portal.":::

   > [!NOTE]
   > Prices shown are for example purposes only.

### Create a new ADR namespace with system-assigned managed identity

Creating namespace with system-assigned managed identity also creates a credential, known as root CA, and a default policy, known as intermediate CA. [Certificate Management](../articles/iot-hub/iot-hub-certificate-management-overview.md) uses these credentials and policies to onboard devices to the namespace.

When you select **Create new** in the **ADR namespace** field, a new pane appears to create your ADR namespace.

1. In the Basics tab of Add a new namespace page, fill in the fields as follows:

    | Property | Value |
    | ----- | ----- |
    | **Subscription** | Select the subscription to use for your ADR namespace. |
    | **Resource group** | Select the resource group you used for your IoT hub. |
    |**Name**| Enter a name for your ADR namespace. Your namespace name can only contain lowercase letters and hyphens ('-') in the middle of the name, but not at the beginning or end. For example, the name "msft-namespace" is valid. |

    :::image type="content" source="../articles/iot-hub/media/device-registry/iot-hub-namespace-1.png" alt-text="Screen capture that shows how to fill the basics tab for an ADR namespace in the Azure portal.":::

1. Select the **Next: Identity >** button to continue creating your ADR namespace.
1. In the **Identity** tab, you can choose to enable a system-assigned managed identity and a credential resource for your namespace. To enable these features, toggle the switch to **Enabled**. For more information about how ADR works with managed identities and credential resources, see [What is Certificate Management](../articles/iot-hub/iot-hub-certificate-management-overview.md).

    - Managed identities allow your namespace to authenticate to Azure services without storing credentials in your code. 
    - Credential resources securely store and manage device authentication credentials, such as API keys or certificates, for devices connecting to your namespace. When you enable this feature, you can set policies to control how certificates are issued and managed for your devices.

    :::image type="content" source="../articles/iot-hub/media/device-registry/iot-hub-namespace-2.png" alt-text="Screen capture that shows how to enable a system-assigned managed identity for an ADR namespace in the Azure portal.":::

1. Select the **Next: Tags >** button to continue creating your ADR namespace.
1. In the Tags tab, you can optionally **add tags** to organize your ADR namespace. Tags are key-value pairs that help you manage and identify your resources. You can use tags to filter and group your resources in the Azure portal.

    :::image type="content" source="../articles/iot-hub/media/device-registry/iot-hub-namespace-3.png" alt-text="Screen capture that shows how to create tags for an ADR namespace in the Azure portal.":::

1. Select the **Review + create >** button to continue creating your ADR namespace.
1. Review your settings, and then select **Create** to create your ADR namespace.

    > [!NOTE]
    > The creation of the namespace with system-assigned managed identity might take up to 5 minutes.

1. Once created, you can view and select your ADR namespace from the **ADR namespace** dropdown.

### Configure the networking, management, and add-ons settings

Once you complete the **Basics** tab, you can continue configuring your IoT hub by following these steps:

1. Select **Next: Networking** to continue creating your hub.
1. On the **Networking** tab, complete the fields as follows:

   | Property | Value |
   | ----- | ----- |
   | **Connectivity configuration** | Choose the endpoints that devices can use to connect to your IoT hub. Accept the default setting, **Public access**, for this example. You can change this setting after the IoT hub is created. For more information, see [IoT Hub endpoints](/azure/iot-hub/iot-hub-devguide-endpoints). |
   | **Minimum TLS Version** | Select the minimum [TLS version](/azure/iot-hub/iot-hub-tls-support#tls-12-enforcement-available-in-select-regions) supported by your IoT hub. Once the IoT hub is created, this value can't be changed. Accept the default setting, **1.0**, for this example. |

   :::image type="content" source="./media/iot-hub-include-create-hub/iot-hub-create-network-screen.png" alt-text="Screen capture that shows how to choose the endpoints that can connect to a new IoT hub.":::

1. Select **Next: Management** to continue creating your hub.
1. On the **Management** tab, accept the default settings. If desired, you can modify any of the following fields:

   | Property | Value |
   | ----- | ----- |
   | **Permission model** | Part of role-based access control, this property decides how you *manage access* to your IoT hub. Allow shared access policies or choose only role-based access control. For more information, see [Control access to IoT Hub by using Microsoft Entra ID](/azure/iot-hub/iot-hub-dev-guide-azure-ad-rbac). |
   | **Assign me** | You might need access to IoT Hub data APIs to manage elements within an instance. If you have access to role assignments, select **IoT Hub Data Contributor role** to grant yourself full access to the data APIs.<br><br>To assign Azure roles, you must have `Microsoft.Authorization/roleAssignments/write` permissions, such as [User Access Administrator](/azure/role-based-access-control/built-in-roles#user-access-administrator) or [Owner](/azure/role-based-access-control/built-in-roles#owner). |
   | **Device-to-cloud partitions** | This property relates the device-to-cloud messages to the number of simultaneous readers of the messages. Most IoT hubs need only four partitions. |

   :::image type="content" source="./media/iot-hub-include-create-hub/iot-hub-management.png" alt-text="Screen capture that shows how to set the role-based access control and scale for a new IoT hub.":::

1. Select **Next: Add-ons** to continue to the next screen.
1. On the **Add-ons** tab, accept the default settings. If desired, you can modify any of the following fields:

   | Property | Value |
   | -------- | ----- |
   | **Enable Device Update for IoT Hub** | Turn on Device Update for IoT Hub to enable over-the-air updates for your devices. If you select this option, you're prompted to provide information to provision a Device Update for IoT Hub account and instance. For more information, see [What is Device Update for IoT Hub?](/azure/iot-hub-device-update/understand-device-update) |
   | **Enable Defender for IoT** | Turn Defender for IoT on to add an extra layer of protection to IoT and your devices. This option isn't available for hubs in the free tier. For more information, see [Security recommendations for IoT Hub](/azure/defender-for-iot/device-builders/concept-recommendations) in [Microsoft Defender for IoT](/azure/defender-for-iot/device-builders) documentation. |

   :::image type="content" source="./media/iot-hub-include-create-hub/iot-hub-create-add-ons.png" alt-text="Screen capture that shows how to set the optional add-ons for a new IoT hub.":::

   > [!NOTE]
   > Prices shown are for example purposes only.

1. Select **Next: Tags** to continue to the next screen.

    Tags are name/value pairs. You can assign the same tag to multiple resources and resource groups to categorize resources and consolidate billing. In this document, you don't add any tags. For more information, see [Use tags to organize your Azure resources and management hierarchy](/azure/azure-resource-manager/management/tag-resources).

    :::image type="content" source="./media/iot-hub-include-create-hub/iot-hub-create-tags.png" alt-text="Screen capture that shows how to assign tags for a new IoT hub.":::

1. Select **Next: Review + create** to review your choices.
1. Select **Create** to start the deployment of your new hub. Your deployment might progress for a few minutes while the hub is being created. Once the deployment is complete, select **Go to resource** to open the new hub.

At this point, you created an IoT hub with an ADR namespace and user-assigned managed identity.

## Create a new DPS instance and assign the ADR namespace

Once your IoT hub and your namespace are created, you can create a new DPS instance and link your namespace to enable device provisioning with Certificate Management. 

1. In the [Azure portal](https://portal.azure.com), search for and select **Device Provisioning Service**.
1. In the **Device Provisioning Services** page, select **+ Create** to create a new DPS instance.
1. On the **Basics** tab, complete the fields as follows:

    |Property|Value|
    |-----|-----|
    |**Subscription**|Select the subscription to use for your Device Provisioning Service instance.|
    |**Resource group**|Select the same resource group that contains the IoT hub that you created in the previous steps. By putting all related resources in a group together, you can manage them together.|
    |**Name**|Provide a unique name for your new Device Provisioning Service instance. If the name you enter is available, a green check mark appears.|
    |**Region**|Select the same region where you created your IoT hub and ADR namespace in the previous steps.|
    |**Device registry**|Select the ADR namespace you created in the previous steps from the dropdown list.|

    :::image type="content" source="../articles/iot-hub/media/device-registry/iot-hub-link-namespace.png" alt-text="Screenshot of the basics tab for a new Device Provisioning Service instance with the Azure Device Registry namespace selected." lightbox="../articles/iot-hub/media/device-registry/iot-hub-link-namespace.png":::


1. Select **Review + create** to validate your provisioning service.
1. Select **Create** to start the deployment of your Device Provisioning Service instance.
1. After the deployment successfully completes, select **Go to resource** to view your Device Provisioning Service instance.


## Link the IoT hub and your Device Provisioning Service instance

Add a configuration to the DPS instance that sets the IoT hub to which the instance provisions IoT devices.

1. In the **Settings** menu of your DPS instance, select **Linked IoT hubs**.
1. Select **Add**.
1. On the **Add link to IoT hub** panel, provide the following information: 

    | Property | Value |
    | --- | --- |
    | **Subscription** | Select the subscription containing the IoT hub that you want to link with your new Device Provisioning Service instance. |
    | **IoT hub** | Select the IoT hub to link with your new Device Provisioning System instance. |
    | **Access Policy** | Select **iothubowner (RegistryWrite, ServiceConnect, DeviceConnect)** as the credentials for establishing the link with the IoT hub. |

    :::image type="content" source="../articles/iot-dps/media/quick-setup-auto-provision/link-iot-hub-to-dps-portal.png" alt-text="Screenshot showing how to link an IoT hub to the Device Provisioning Service instance in the portal."::: 

1. Select **Save**.
1. Select **Refresh**. You should now see the selected hub under the list of **Linked IoT hubs**.

## Create a custom policy for your namespace

Create custom policies within your ADR namespace to define how certificates are issued and managed for your devices. Policies allow you to set parameters such as certificate validity periods and subjects.

1. In the [Azure portal](https://portal.azure.com), search for and select **Azure Device Registry**.
1. Go to the **Namespaces** page.
1. Select your ADR namespace.
1. In the namespace page, under **Namespace resources**, select **Credential policies (Preview)**.

    :::image type="content" source="../articles/iot-hub/media/device-registry/custom-policy.png" alt-text="Screenshot of Azure Device Registry custom policy page in the Azure portal." lightbox="../articles/iot-hub/media/device-registry/custom-policy.png":::

1. Select **Enable**  to turn on credential policies for your namespace, if they aren’t already active.
1. In the **Credential policies** page, select **+ Create** to create a new policy.
1. A pane appears where you can configure the policy settings. In the **Basics** tab, complete the fields as follows:
    
    | Property | Value |    
    | -------- | ----- |
    | **Name** | Enter a unique name for your policy. The name must be between 3 and 50 alphanumeric characters and can include hyphens (`'-'`). |
    | **Validity period (days)** | Enter the number of days the issued certificates are valid. The validity period must be between 1 and 3,650 days (10 years). |

1. Select **Review + create** to review your settings.
1. The new policy appears in the list of policies for your namespace. You can select the policy to view its details.
1. In the policy overview page, you can see the policy name, validity period, and status, which should be enabled.

> [!NOTE]
> Editing or disabling a policy isn't supported in public preview.

At this point, you created a new hub, a new Device Provisioning Service (DPS) instance, and linked your Azure Device Registry (ADR) namespace to your hub and DPS instance. You can now proceed to create enrollments and assign the policy to manage device onboarding. Follow the steps in the next section to complete the setup.

## Create an enrollment group and assign a policy

To provision devices with leaf certificates, you need to create an enrollment group and assign the policy created within your ADR namespace. The allocation-policy defines the onboarding authentication mechanism DPS uses before issuing a leaf certificate. The default attestation mechanism is a symmetric key.

1. In the **Settings** menu of your DPS instance, select **Manage enrollment**.
1. In the **Manage enrollments** page, select either the **Enrollment groups** or **Individual enrollments** tab based on your provisioning needs.
1. Select **+ Add enrollment group** or **+ Add individual enrollment** to create a new enrollment.
1. In the **Registration + provisioning** page, complete the fields as follows:
    
    | Property | Value |    
    | -------- | ----- |
    | **Attestation mechanism** | Select **X.509 intermediate certificate** as the attestation method. |
    | **X.509 certificate settings** | Upload the intermediate certificate files. Enrollments have one or two certificates, known as primary and secondary certificate files. |
    | **Group name** | Enter a name for your enrollment group. Skip this field if you're creating an individual enrollment. |
    | **Provisioning status** | Select **Enabled** to enable the enrollment from provisioning. |
    | **Reprovision policy** | Specify the reprovisioning policy for the enrollment. This policy determines how the enrollment behaves during device reprovisioning. |

1. Go to the **Credential policies (Preview)** tab.
1. Select the **policy** you want to assign to the enrollment group or individual enrollment.

    :::image type="content" source="../articles/iot-hub/media/device-registry/add-enrollment-group-policy.png" alt-text="Screenshot of Azure Device Registry assigning a policy to an enrollment group in the Azure portal." lightbox="../articles/iot-hub/media/device-registry/add-enrollment-group-policy.png":::

1. Complete the remaining fields in the enrollment creation process and select **Create** to finalize the enrollment.

## Sync policies to IoT hubs

Synchronize a policy created within your ADR namespace to the IoT hub linked to that namespace. This synchronization enables IoT Hub to trust any devices authenticating with a leaf certificate issued by the policy's issuing CA (ICA).

1. Go to the **Namespaces** page.
1. Select the namespace you want to sync policies for.
1. In the namespace page, under **Namespace resources**, select **Credential policies (Preview)**.
1. In the **Credential policies** page, you can view your policies, validity periods, intervals, and status.
1. Select the policies you want to sync. You can sync more than one policy at a time.
1. Select **Sync**.

    :::image type="content" source="../articles/iot-hub/media/device-registry/sync-policies.png" alt-text="Screenshot of the namespace page in Azure portal that shows the sync option." lightbox="../articles/iot-hub/media/device-registry/sync-policies.png":::

If you select to sync more than one policy, policies are synced to their respective IoT hubs. You can't undo a sync operation after it's done.

