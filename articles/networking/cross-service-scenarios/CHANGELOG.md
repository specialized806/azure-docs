# Changelog — Secure Network Foundation for Regional Web Applications

**Branch:** `mbender-ms/secure-web-app-network-foundation`  
**Base:** `main` (MicrosoftDocs/azure-docs-pr)  
**Last updated:** 2026-03-16

---

## Phase 1 — Architectural Drawing Research

**Date:** 2026-03-15  
**Output:** `Prompt response - Architectural Drawings.md` (committed, recommend deleting before merge)

- Surveyed Microsoft public and internal documentation for architectural diagrams relevant to a secure network foundation article.
- Compiled a ranked report of 8 Microsoft documentation sources with reusable diagrams.
- Report used as input for architecture section design in Phase 3.

---

## Phase 2 — Article Recommendations & Hub-Spoke Analysis

**Date:** 2026-03-15

- Analyzed hub-spoke topology complexity for SMB/startup audience.
- Concluded minimal hub-spoke (one hub VNet + one spoke VNet) is appropriate.
- Key decisions confirmed by author:
  - No Private Endpoints in scope
  - Placeholder diagram (production diagram planned)
  - No fact-check appendix
  - Single article format
  - SMB/startup focus

---

## Phase 3 — Full Article Creation

**Date:** 2026-03-15  
**Commit:** `dae49b4` — `docs: Add secure network foundation for regional web applications`  
**File:** `secure-web-app-network-foundation-layered-hub-spoke.md`  
**Word count:** ~4,304 words

Created the full hub-spoke article with the following sections:

| Section | Description |
|---|---|
| Introduction | SMB-focused framing, scope bullets, landing zone disclaimer |
| Architecture | Placeholder diagram, hub/spoke component table |
| Why hub-spoke | Comparison of single-VNet versus hub-spoke tradeoffs |
| Deployment steps | 10-step layered deployment order table |
| VNet and subnet planning | Hub subnet table, spoke subnet table, CIDR planning table, peering settings |
| NSG essentials | Default-deny rules, per-subnet guidance, flow log migration note |
| DDoS Protection | Decision flow, tier comparison table |
| Application Gateway with WAF | Sizing, WAF policy migration, TLS in Key Vault, v1 retirement notice |
| Azure Bastion | PaaS vs IaaS decision table, hub deployment pattern |
| Azure Firewall (optional) | Basic SKU recommendation, scenario comparison table |
| Identity and RBAC | Role assignments, managed identity guidance |
| Mistakes to avoid | 11-row anti-pattern table |
| Troubleshooting | 4 common failure scenarios with fixes |
| Related content | Links to canonical Microsoft documentation |

Also committed:
- `media/secure-azure-network-architecture-cross-service-scenarios-m365-copilot-v1/image1.jpg` (98 KB)
- `media/secure-azure-network-architecture-cross-service-scenarios-m365-copilot-v1/image2.png` (127 KB)

---

## Phase 4 — Viability Review

**Date:** 2026-03-16  
**Output:** `REVIEW-viability-assessment.md` (untracked — working document, not for merge)

### Initial assessment: High duplication risk

Identified 6 published Microsoft articles covering ~80% of the draft content:

1. [Hub-spoke network topology in Azure](/azure/architecture/networking/architecture/hub-spoke)
2. [Apply Zero Trust principles to a spoke virtual network](/security/zero-trust/azure-infrastructure-paas)
3. [Apply Zero Trust principles to a hub virtual network](/security/zero-trust/azure-infrastructure-networking)
4. [Secure your Application Gateway](/azure/application-gateway/secure-application-gateway)
5. [Choose a secure network topology](../secure-network-topology.md)
6. [Secure application delivery](../foundations/secure-application-delivery.md)

~10-20% of content identified as unique: deployment order table, anti-pattern table, troubleshooting consolidation, SMB framing.

### Revised assessment after author context

Author provided critical context that shifted the assessment:

- **Customer feedback:** Cross-service articles are hard to find; customers piece together partial solutions from multiple articles.
- **Planned artifacts:** Architecture diagram and Bicep/Terraform template in development.
- **TOC placement:** Will go under a new "Cross-service scenarios" node, not alongside canonical single-service docs.
- **Zero Trust article candidate for deprecation:** `create-zero-trust-network-web-apps.md` (ms.date: 12/31/2022, .NET 6 LTS EOL, pre-Entra ID, portal-only).

**Revised verdict:** Article has a viable niche IF shortened from ~4,300 to ~2,300 words, preserving unique-value content and linking to canonical docs for service-specific detail.

---

## Phase 5 — Shortened Article Version

**Date:** 2026-03-16  
**File:** `secure-web-app-network-foundation-layered-hub-spoke-SHORT.md` (untracked — for review and comparison)  
**Word count:** ~2,633 words (39% reduction from full version)

### Section-by-section changes

| Section | Full version | Short version | Change |
|---|---|---|---|
| Introduction | ~300 words | ~200 words | Tighter SMB framing |
| Architecture | Component table + prose | Same table, trimmed prose | Minor trim |
| Why hub-spoke | Paragraph format | Bullet comparison | Condensed |
| Deployment steps | 10-step table | 10-step table | **Kept in full** (unique content) |
| VNet/subnet planning | 3 tables + peering config | CIDR table only | Cut hub/spoke subnet tables and peering settings |
| NSG essentials | Full prose | Bullet list + links | Shrunk to essentials |
| DDoS Protection | Prose + decision flow | Compact table + link | Condensed |
| Application Gateway WAF | Full prose | 5-point list + alternatives | Shrunk to essentials |
| Azure Bastion | Full prose | Decision table + 1 paragraph | Condensed |
| Azure Firewall | Full prose | Scenario table + 1 paragraph | Condensed |
| Identity and RBAC | Full section (~200 words) | — | **Cut entirely** |
| Mistakes to avoid | 11-row table | 11-row table | **Kept in full** (unique content) |
| Troubleshooting | 4 entries | 4 entries | **Kept in full** (unique content) |
| Deploy this scenario | Not present | Placeholder for Bicep/Terraform | **New section** |

### Design principles for the shortened version

- **Keep unique content in full:** Deployment order table, anti-pattern table, troubleshooting — these aren't available in any single canonical source.
- **Shrink service sections to bullet essentials + links:** NSG, DDoS, App Gateway, Bastion, Firewall — link to canonical docs instead of duplicating.
- **Cut content covered elsewhere:** Identity/RBAC, VNet peering configuration details, subnet sizing tables.
- **Add deployment entry point:** "Deploy this scenario" section for planned Bicep/Terraform templates.

---

## File inventory

| File | Status | Purpose | Include in PR? |
|---|---|---|---|
| `secure-web-app-network-foundation-layered-hub-spoke.md` | Committed | Full article (~4,304 words) | Yes (or replace with SHORT version) |
| `secure-web-app-network-foundation-layered-hub-spoke-SHORT.md` | Untracked | Shortened article (~2,633 words) for comparison | Author decision |
| `REVIEW-viability-assessment.md` | Untracked | Viability assessment with findings and sources | No — working document |
| `CHANGELOG.md` | Untracked | This file | No — working document |
| `Prompt response - Architectural Drawings.md` | Committed | Phase 1 research | No — delete before merge |
| `media/.../image1.jpg` | Committed | Placeholder diagram | Yes |
| `media/.../image2.png` | Committed | Placeholder diagram | Yes |

---

## Open decisions

- [ ] **Which version to publish?** Full (~4,304 words) or shortened (~2,633 words)?
- [ ] **Deprecate Zero Trust article?** `create-zero-trust-network-web-apps.md` — check page view stats, then decide.
- [ ] **Architecture diagram** — Production diagram to replace placeholder.
- [ ] **Bicep/Terraform template** — Links needed for "Deploy this scenario" section.
- [ ] **TOC placement** — Confirm "Cross-service scenarios" node location in Networking TOC.
- [ ] **Delete `Prompt response - Architectural Drawings.md`** from branch before PR.
