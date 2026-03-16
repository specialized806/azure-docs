# Viability Assessment: secure-web-app-network-foundation-layered-hub-spoke.md

**Reviewed by:** GitHub Copilot (ms-learn-factcheck mode)
**Date:** March 16, 2026
**Article under review:** `secure-web-app-network-foundation-layered-hub-spoke.md`
**Word count:** ~4,300 words (~17-21 min reading time)

---

## Executive summary

The article is well-written and contains genuinely useful unique content (deployment order, anti-pattern table, troubleshooting consolidation). However, ~80% of the content restates guidance from higher-authority sources. After factoring in customer feedback ("cross-service articles are hard to find; customers piece partial solutions together"), the planned architecture diagram, and the planned Bicep/Terraform template, the article **has a viable niche** — but only if substantially shortened to eliminate duplication and lean on links to canonical sources.

**Recommendation:** Shorten from ~4,300 words to ~2,300 words. Publish as a cross-service scenario article in the Networking TOC. Deprecate and redirect the aging `create-zero-trust-network-web-apps.md` once stats confirm low/declining traffic.

---

## 1. Overlap analysis — existing published content

Six published articles collectively cover the majority of this draft:

| Existing article | Owner | URL | Overlap | Coverage estimate |
|---|---|---|---|---|
| **Hub-spoke network topology in Azure** | Architecture Center | [learn.microsoft.com/azure/architecture/networking/architecture/hub-spoke](https://learn.microsoft.com/azure/architecture/networking/architecture/hub-spoke) | Hub VNet, spoke VNet, peering, subnet naming/sizing, Bastion in hub, Firewall in hub, CIDR planning, UDR guidance | **~60%** |
| **Apply Zero Trust principles to a spoke VNet (IaaS)** | Security team | [learn.microsoft.com/security/zero-trust/azure-infrastructure-iaas](https://learn.microsoft.com/security/zero-trust/azure-infrastructure-iaas) | NSG default-deny per subnet, ASGs, App Gateway + WAF in spoke, RBAC, flow logging, IDPS | **~30%** |
| **Secure your Azure Application Gateway** | App Gateway team | [learn.microsoft.com/azure/application-gateway/secure-application-gateway](https://learn.microsoft.com/azure/application-gateway/secure-application-gateway) | Dedicated subnet, NSGs, DDoS Protection, WAF policies, Key Vault TLS, diagnostics | **~20%** |
| **Deploy a Zero Trust network for web apps** | Your team (same TOC) | `create-zero-trust-network-web-apps.md` | Hub-spoke + App Gateway + Firewall + NSGs + Key Vault — step-by-step portal deployment | **~40%** |
| **Choose a secure network topology** | Your team (same TOC) | `secure-network-topology.md` | Decision tree for hub-spoke vs. Virtual WAN | Conceptual overlap |
| **Choose a secure application delivery service** | Your team (same TOC) | `secure-application-delivery.md` | Decision tree for App Gateway vs. Front Door vs. others | Conceptual overlap |

### Key finding

The Architecture Center hub-spoke reference architecture covers hub/spoke VNet design, subnet sizing, Bastion placement, Firewall placement, peering configuration, and CIDR planning — with a downloadable Visio and deployable Bicep/ARM template. The current draft restates much of this without a deployment artifact.

---

## 2. What's unique in the draft (the ~10-20% that doesn't exist elsewhere)

| Unique element | Value |
|---|---|
| **10-step deployment order table** (layered sequencing with "why this order") | **High** — no existing article sequences deployment dependency order as an explicit checklist |
| **"Mistakes to avoid" anti-pattern table** (11 rows) | **High** — scattered across existing docs but never consolidated for this scenario |
| **"Why hub-spoke instead of a single VNet?" comparison** | **Medium-High** — doesn't exist as a focused comparison elsewhere |
| **"When things go wrong" troubleshooting** (4 consolidated entries) | **Medium** — individual service troubleshooting exists, but the consolidated "check first" format is useful |
| **DDoS "Do you need it?" decision flow** | **Medium** — tier comparison exists in DDoS docs but the contextual decision flow is new |
| **SMB/startup audience framing** | **Low-Medium** — the only article in the library explicitly targeting small/midsize organizations, but it's a framing choice, not substantive technical differentiation |
| **Bastion PaaS vs IaaS decision table** | **Medium** — not stated this clearly elsewhere |

---

## 3. Customer feedback signals

### Direct demand signals

**No GitHub Issues found** on `MicrosoftDocs/azure-docs` matching this topic across multiple query variations (hub-spoke beginner, secure network foundation, web app network guide, SMB startup network, deployment order). Zero matching issues.

### Indirect demand signals (from conversation context)

The author reports consistent customer feedback that:

- Cross-service articles are hard to find in the library
- Customers take multiple articles with partial solutions and piece them together
- No existing article in the Networking area tells customers "here's how these 6 services connect, deploy in this order, avoid these mistakes"

This indirect signal is strong — the gap is real even if not formally documented in GitHub Issues.

---

## 4. Assessment of the existing `create-zero-trust-network-web-apps.md`

This article in the same Networking TOC is a strong deprecation candidate:

| Signal | Detail |
|---|---|
| **`ms.date: 12/31/2022`** | 3+ years stale |
| **`ms.author: chplut`** | Author attribution doesn't match current team ownership |
| **`.NET 6 (LTS)` in code** | EOL since November 2024 |
| **`../active-directory/` link paths** | Pre-Entra ID rename — may be silently redirecting |
| **Portal-only how-to** | No Bicep/Terraform/ARM, no CLI — purely portal steps which decay fastest |
| **Requires custom domain + wildcard cert** | Extremely high barrier for SMB/startup audience |
| **Only article under "Security" in How-to** | Isolated in the TOC, no surrounding context |

**Recommendation:** Check traffic stats. If low/declining, deprecate and redirect to the new article.

---

## 5. Structural concerns with the current draft

| Concern | Detail |
|---|---|
| **Same TOC area, overlapping scope** | `create-zero-trust-network-web-apps.md` covers the same hub-spoke + App Gateway + Firewall + NSGs pattern. A reader finding both will be confused about which to follow. |
| **Concept article without deployment artifact** | The AAC hub-spoke ref arch has Visio + deployable Bicep/ARM. The draft has a placeholder `<!-- TODO -->` for diagram and no IaC. (Author confirms both are planned — this resolves when delivered.) |
| **No TOC entry** | The file is in `cross-service-scenarios/` but there's no TOC node for it in the Networking TOC. It would be orphaned without a TOC update. |
| **Identity and access control section** | 3 bullets that restate RBAC docs. Low value — can be cut entirely. |
| **VNet peering detail** | Key settings table and nontransitive explanation restate the [VNet peering overview](/azure/virtual-network/virtual-network-peering-overview). |
| **NSG prose paragraphs** | Restate App Gateway infrastructure and Bastion NSG docs at length. |

---

## 6. Revised viability assessment (with context)

With the customer feedback context, planned diagram, and planned IaC template, the article fills a real gap — **if** it stays focused on integration and deployment order rather than restating individual service docs.

### What makes a viable cross-service networking article

| Attribute | Current draft | Shortened version (proposed) |
|---|---|---|
| Unique deployment order | Yes (10-step table) | Yes — kept in full |
| Cross-service integration focus | Partial — mixed with service-specific prose | Yes — service sections become bullet essentials + links |
| Anti-pattern consolidation | Yes (11 rows) | Yes — kept in full |
| Architecture diagram | Placeholder TODO | Planned — high value when delivered |
| Deployable IaC template | None | Planned — becomes strongest differentiator |
| Word count | ~4,300 (too long for the unique value) | ~2,300 (right-sized) |
| Duplication with canonical sources | ~80% | ~20% (links replace restated prose) |

---

## 7. Recommendations

### Primary recommendation: Shorten to ~2,300 words

**Keep in full:**
- Intro with SMB/startup audience framing
- Architecture diagram + component table
- "Why hub-spoke instead of a single VNet?" comparison
- 10-step deployment order table
- CIDR planning table
- "Mistakes to avoid" anti-pattern table (all 11 rows)
- "When things go wrong" troubleshooting (all 4 entries)

**Shrink to bullet essentials + links:**
- NSG section → 5-6 bullets + links to App Gateway NSG and Bastion NSG docs
- DDoS section → Decision flow + compact tier table + link to tier comparison
- Application Gateway section → 5 essentials bullets + links to security guide
- Bastion section → Decision table + 3-sentence hub rationale + links
- Azure Firewall section → When-to-add table + 4 bullets + link to SKU guide

**Cut entirely:**
- Identity and access control section (3 bullets restating RBAC docs)
- VNet peering detail (key settings table, nontransitive explanation → 1 sentence + link)
- Hub/spoke subnet sizing tables with full detail → keep only unique entries (AzureFirewallManagementSubnet for Basic SKU)

**Add:**
- "Deploy this scenario" section linking to Bicep/Terraform template when ready

### Secondary recommendations

1. **Deprecate `create-zero-trust-network-web-apps.md`** once stats confirm. Set up a redirect to the new article.
2. **Create TOC entry** under a new cross-service scenarios node.
3. **Delete `Prompt response - Architectural Drawings.md`** from the branch before merging — it's a working document, not publishable content.

---

## 8. Proposed TOC placement

```yaml
- name: Cross-service scenarios
  items:
  - name: Secure network foundation for web applications
    href: cross-service-scenarios/secure-web-app-network-foundation-layered-hub-spoke.md
```

---

## 9. Verification sources used

### Primary Microsoft documentation sources
- [Hub-spoke network topology in Azure](https://learn.microsoft.com/azure/architecture/networking/architecture/hub-spoke) — Canonical hub-spoke reference architecture
- [Apply Zero Trust principles to a spoke VNet (IaaS)](https://learn.microsoft.com/security/zero-trust/azure-infrastructure-iaas) — NSG default-deny, ASG patterns, RBAC for spoke VNets
- [Secure your Azure Application Gateway](https://learn.microsoft.com/azure/application-gateway/secure-application-gateway) — App Gateway security best practices
- [Azure DDoS Protection tier comparison](https://learn.microsoft.com/azure/ddos-protection/ddos-protection-sku-comparison) — DDoS tier selection guidance
- [VNet peering overview](https://learn.microsoft.com/azure/virtual-network/virtual-network-peering-overview) — Peering configuration and nontransitive behavior
- [Bastion NSG requirements](https://learn.microsoft.com/azure/bastion/configuration-settings#nsg) — Required NSG rules for Bastion subnets
- [App Gateway infrastructure configuration](https://learn.microsoft.com/azure/application-gateway/configuration-infrastructure#network-security-groups) — NSG and subnet requirements

### Workspace sources analyzed
- `articles/networking/TOC.yml` — Current TOC structure
- `articles/networking/create-zero-trust-network-web-apps.md` — Existing overlapping article
- `articles/networking/secure-network-topology.md` — Decision tree for topology
- `articles/networking/secure-application-delivery.md` — Decision tree for app delivery
- `articles/networking/fundamentals/networking-overview.md` — Fundamentals overview
- `articles/networking/foundations/network-foundations-overview.md` — Network foundations overview
- `.openpublishing.redirection.networking.json` — Redirect configuration

### GitHub search (MicrosoftDocs/azure-docs)
- Searched: "hub-spoke network beginner", "secure network foundation web application", "web application network security guide beginner", "network security startup small business beginner Azure", "Application Gateway WAF hub spoke network security"
- **Result:** Zero matching customer issues found
