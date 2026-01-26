---
author: dlepow
ms.service: azure-api-management
ms.topic: include
ms.date: 01/26/2026
ms.author: danlep
ms.custom:
---

### Allow access to DigiCert IP addresses

Starting January 2026, Azure API Management needs inbound access on port 80 to [specific DigiCert IP addresses](https://knowledge.digicert.com/alerts/ip-address-domain-validation?utm_medium=organic&utm_source=docs-digicert&referrer=https://docs.digicert.com/en/certcentral/manage-certificates/domain-control-validation-methods/automatic-domain-control-validation-check.html&utm_medium=organic&utm_source=docs-digicert&referrer=https://docs.digicert.com/en/certcentral/manage-certificates/domain-control-validation-methods/automatic-domain-control-validation-check.html) to renew (rotate) your managed certificate.  
If your API Management instance restricts incoming IP addresses, remove or update existing IP restrictions by using one of the following methods based on your deployment architecture.

### Remove or edit IP filter policies in API Management

If you implemented IP address restrictions by using the built-in [ip-filter](../articles/api-management/ip-filter-policy.md) policy:

1. Sign in to the Azure portal and go to your API Management instance.
1. Under **APIs**, select the API where the policy applies (or **All APIs** for a global change).
1. On the **Design** tab, in **Inbound processing**, select the code editor (`</>`) icon.
1. Locate the IP restriction policy statement.
1. Do one of the following:
   - Delete the entire XML snippet to remove the restriction completely.
   - Edit the `<ip-filter>` or `<check-header>` elements to add the DigiCert IP addresses to the allow list.
1. Select **Save** to apply changes immediately to the gateway.

<!-- What configuration in check-header would be needed to allowlist DigiCert IPs? -->

### Modify network security group in virtual network deployment

If you deploy your API Management instance in a [virtual network in external mode](../articles/api-management/api-management-using-with-vnet.md), modify the network security group that you configured on the subnet to allow inbound access from DigiCert IP addresses on port 80.

1. In the Azure portal, go to **Network security groups**.
1. Select the network security group associated with your API Management subnet.
1. Under **Settings** > **Inbound security rules**, locate rules blocking traffic.
1. Do one of the following:
   - Delete the restrictive rule.
   - Edit the rule: change **Source** to add the DigiCert IP addresses to the allow list on port 80.
1. Select **Save** and test API access to confirm the change.

### Internal virtual network deployment

If you deploy your API Management instance in a [virtual network in internal mode](../articles/api-management/api-management-using-with-internal-vnet.md) and front it by using Application Gateway, Azure Front Door, or Traffic Manager, make sure that the entire request path preserves the host header and that DigiCert IP addresses are allowed on port 80.

**Architecture:** Azure Front Door / Traffic Manager → Application Gateway → API Management (internal virtual network)

Both the Application Gateway and API Management instances must be injected in the same virtual network. [Learn more about integrating Application Gateway with API Management](../articles/api-management/api-management-howto-integrate-internal-vnet-appgateway.md).

**Step 1: Configure Application Gateway in front of API Management service and allow DigiCert traffic in network security group**
   1. In the Azure portal, go to **Network security groups** and select the network security group for your API Management subnet.
   1. Under **Settings** > **Inbound security rules**, locate rules blocking traffic.
1. Do one of the following:
   - Delete the restrictive rule.
   - Edit the rule: change **Source** to add the DigiCert IP addresses to the allow list on port 80.
1. Select **Save**.

**Step 2: Preserve target custom domain/hostname from the traffic manager through to the API management instance**
   - **Azure Front Door (classic):** Set **Backend host header** to the API Management hostname (not the Application Gateway FQDN), or select **Preserve the incoming host header** when using custom domains.
    - **Azure Front Door Standard/Premium:** In the **Route > Origin > Origin settings** blade, enable **Forward Host Header** and select **Original host header**.
   - **Application Gateway:** In HTTP settings, do one of the following to ensure that Application Gateway acts as a reverse proxy without rewriting the host header:
       - Set **Override host name** to **No**, -OR-
       - If you use hostname override, select **Pick hostname from incoming request** (recommended).

   - **API Management:** Ensure that a matching custom domain is configured in API Management (API Management requires a matching hostname even in internal mode).

**Step 3:Verify host header consistency**

- Client → Azure Front Door: `api.contoso.com`
- Azure Front Door → Application Gateway: `api.contoso.com`
- Application Gateway → API Management: `api.contoso.com`

API Management rejects requests if the hostname doesn't match a configured custom domain.

### Azure Firewall deployment

If an Azure Firewall protects your API Management instance, modify the firewall's network rules to allow inbound access from DigiCert IP addresses on port 80:

1. Go to your **Azure Firewall** instance.
1. Under **Settings** > **Rules** (or **Network rules**), locate the rule collection and the specific rule that restricts inbound access to the API Management instance.
1. Edit or delete the rule to add the DigiCert IP addresses on port 80.
1. Select **Save** and test API access.