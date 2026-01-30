---
author: dlepow
ms.service: azure-api-management
ms.topic: include
ms.date: 01/29/2026
ms.author: danlep
ms.custom:
---


#### Configure DNS record

Set up either a CNAME record *or* TXT record with your DNS provider. 

To add a CNAME record:

1. Sign in to your domain registrar's or DNS provider's management portal.
1. Go to the section for managing DNS records (for example, "DNS Management", "Manage Domains", "DNS Zone Editor").
1. Create a new DNS record:
   
    | Setting | Value |
    |---------|-------|
    | Type | Select CNAME. |
    | Name/Host/Alias | Enter the subdomain you want to use for your API (for example, `api` if you want `api.yourdomain.com`). If you're using an apex domain, some providers might require `@` or leave it blank (check your provider's specific instructions for this, since A records might be needed instead). |
    | Value/Target/Points to | Enter the default Azure API Management hostname you retrieved from the Azure portal (for example, `your-apim-service-name.azure-api.net`). |
    | TTL (Time to Live) | Set an appropriate time, a common value is 1 hour (3600 seconds). |

When you configure the custom domain in the Azure portal, you might need to add a TXT record for verification. The portal provides the specific `_dnsauth` or `asuid` prefixed value needed. 

To add a TXT record for domain verification:

1. Sign in to your domain registrar's or DNS provider's management portal.
1. Go to the section for managing DNS records (for example, "DNS Management", "Manage Domains", "DNS Zone Editor").
1. Create a new DNS record:

    | Setting | Value |
    |---------|-------|
    | Type | Select TXT. |
    | Name/Host | Enter the value specified by Azure (for example, `_dnsauth.api` or `asuid`). |
    | Value | Enter the domain verification code provided by Azure. |

> [!CAUTION]
> When you use the free, managed certificate and configure a CNAME record with your DNS provider, make sure that it resolves to the default API Management service hostname (`yourapim-service-name.azure-api.net`). Currently, API Management doesn't automatically renew the certificate if the CNAME record doesn't resolve to the default API Management hostname. For example, if you're using the free, managed certificate and you use Cloudflare as your DNS provider, make sure that DNS proxy isn't enabled on the CNAME record.     

#### Add DigiCert as an authorized certificate authority (CA) in Azure DNS

To add DigiCert as an authorized CA in Azure DNS, add a specific CAA record set within your domain's DNS zone by using the Azure portal or other management tools.

To add the CAA record in Azure DNS:

1. Sign in to the Azure portal.
1. In the search bar, type *DNS zones* and select it from the services.
1. Select the specific DNS zone (your domain name) to which you want to add the CAA record.
1. Add a new CAA record set:
    1. On the DNS zone page, locate the **Record sets** section at the top.
    1. Select **+ Add record set**.
    1. Configure the record set details:

        | Setting | Value |
        |---------|-------|
        | Name | For the root or apex domain (for example, `yourdomain.com`), enter `@` or leave it blank. For a specific subdomain (for example, `www.yourdomain.com`), enter `www`. |
        | Type | Select **CAA** from the dropdown list. |
        | TTL | Use the default value (for example, 1 hour) or specify as needed. |
        | Tag | Select **issue** from the dropdown list to allow general certificate issuance. |
        | CA domain name | Enter `digicert.com`. |
    1. Select **Add** to create the CAA record set.
