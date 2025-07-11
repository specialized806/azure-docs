---
title: Phone Number Management for Denmark
titleSuffix: An Azure Communication Services concept document
description: Learn about subscription Eligibility and Number Capabilities for PSTN and SMS Numbers in Denmark.
author: krkutser
manager: rcole
services: azure-communication-services

ms.author: krkutser
ms.date: 03/30/2023
ms.topic: conceptual
ms.service: azure-communication-services
ms.custom: references_regions
---

# Phone number management for Denmark
Use the below tables to find all the relevant information on number availability, eligibility and restrictions for phone numbers in Denmark.

## Number types and capabilities availability

| Number Type | Send SMS             | Receive SMS          | Make Calls           | Receive Calls          |
| :---------- | :------------------- | :------------------- | :------------------- | :--------------------- |
| Toll-Free   | -  | - | General Availability | General Availability\* |
| Local       | -                    | -                    | General Availability | General Availability\* |
| Mobile                    | General Availability\**       | General Availability\**       | -                    | -                      |
| Alphanumeric Sender ID\**       | General Availability                         | -                    | - | - |

\* Please refer to [Inbound calling capabilities page](../telephony/inbound-calling-capabilities.md) for details.

\** Please refer to [SMS Concepts page](../sms/concepts.md) for supported destinations for this service.

## Subscription eligibility

To acquire a phone number, you need to be on a paid Azure subscription. Phone numbers can't be acquired by Azure free credits. Also, due to regulatory reasons phone number availability is dependent on your Azure subscription billing location.

More details on eligible subscription types are as follows:

| Number Type                      | Eligible Azure Agreement Type                                                                             |
| :------------------------------- | :-------------------------------------------------------------------------------------------------------- |
| Toll-Free, Local (Geographic/National), Mobile | Modern Customer Agreement (Field and Customer Led), Modern Partner Agreement (CSP), Enterprise Agreement, Pay-As-You-Go |

\** Applications from all other subscription types are reviewed and approved on a case-by-case basis. Reach out to acstns@microsoft.com for assistance with your application.


## Azure subscription billing locations where Denmark phone numbers are available
| Country/region |
| :---------- |
|Australia|
|Canada|
|Denmark|
|France|
|Germany|
|Ireland|
|Italy|
|Japan|
|Netherlands|
|Spain|
|Sweden|
|United Kingdom|
|United States|

[!INCLUDE [Azure Prepayment](../../includes/azure-prepayment.md)]

## Azure subscription billing locations where Denmark mobile numbers are available
| Country/Region |
| :---------- |
| Australia       |
| Belgium         |
| Denmark         |
| Finland         |
| Ireland         |
| Latvia          |
| Netherlands     |
| Poland          |
| Sweden          |
| United Kingdom  |
| United States  |

## Azure subscription billing locations where Denmark alphanumeric sender IDs are available
| Country/Region |
| :---------- |
| Australia |
| Austria |
| Denmark |
| France |
| Germany |
| India |
| Ireland |
| Italy |
| Netherlands |
| Poland |
| Portugal |
| Puerto Rico |
| Spain |
| Sweden |
| Switzerland |
| United Kingdom |
| United States |

## Find information about other countries/regions

[!INCLUDE [Country Dropdown](../../includes/country-dropdown.md)]

## Next steps

For more information about Azure Communication Services' telephony options, see the following pages:

- [Learn more about Telephony](../telephony/telephony-concept.md)
- Get a Telephony capable [phone number](../../quickstarts/telephony/get-phone-number.md)
