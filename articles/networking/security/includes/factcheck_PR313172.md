# Fact-Check Report: PR #313172 — ZTA Networking Secure Recommendation Includes

**Date**: March 16, 2026
**PR**: [#313172](https://github.com/MicrosoftDocs/azure-docs-pr/pull/313172)
**Files reviewed**: 24 include files (IDs 25533–27020)
**Scope**: Public + internal documentation verification

---

## Executive summary

PR #313172 adds 24 Zero Trust Assessment (ZTA) secure recommendation include files covering Azure DDoS Protection, Azure Firewall, Application Gateway WAF, and Azure Front Door WAF. Overall, the content is **technically accurate and well-sourced**. However, I identified **2 inaccuracies, 2 potentially broken remediation links, and 3 items that could mislead readers** through omission of important context.

### Findings at a glance

| Status | Count | Description |
|--------|-------|-------------|
| ✅ Accurate | 18 | Claims match official documentation |
| ⚠️ Partially Accurate | 4 | Minor discrepancy or missing context |
| ❌ Inaccurate | 1 | Contradicts official sources |
| 🔗 Broken/Suspect Link | 2 | Remediation links may not resolve |

---

## Critical findings (action required)

### 1. ❌ 26885.md — Incorrect: DDoS Protection does NOT mitigate application-layer attacks

**Claim**: "automatically detecting and mitigating volumetric, protocol, and application-layer distributed denial of service (DDoS) attacks"

**Evidence**: Azure DDoS Protection provides L3/L4 protection only. The official docs explicitly state:
> "All L3/L4 attack vectors can be mitigated" ([DDoS Protection overview](https://learn.microsoft.com/azure/ddos-protection/ddos-protection-overview))
> "Customers can use Azure DDoS Protection service in combination with a Web Application Firewall (WAF) for protection both at the network layer (Layer 3 and 4, offered by Azure DDoS Protection) and at the application layer (Layer 7, offered by a WAF)" ([DDoS FAQ](https://learn.microsoft.com/azure/ddos-protection/ddos-faq))

**Fix**: Change "volumetric, protocol, and application-layer" to "volumetric and protocol-layer" OR clarify that L7 protection requires WAF in combination with DDoS Protection.

---

### 2. ⚠️ 27017.md — Missing disclosure: JavaScript challenge on App Gateway is in PREVIEW

**Claim**: File describes JavaScript challenge as a generally available feature for Application Gateway WAF.

**Evidence**: The official docs include a prominent preview notice:
> "Azure Web Application Firewall JavaScript challenge on Azure Application Gateway is currently in PREVIEW." ([JS challenge docs](https://learn.microsoft.com/azure/web-application-firewall/waf-javascript-challenge))

Additionally, the preview docs note key limitations:
- "The JavaScript challenge action on Application Gateway isn't supported for Rate Limit type custom rules during the preview"
- AJAX and API calls aren't supported
- POST body size restriction of 128 KB

**Fix**: Add a note that JavaScript challenge on Application Gateway WAF is currently in preview, or add a remediation link directly to the JS challenge article which contains the preview notice.

---

### 3. 🔗 27020.md — Suspect remediation link

**Current link**: `/azure/web-application-firewall/afds/waf-front-door-tuning#captcha-challenge`

**Issue**: The WAF tuning page doesn't appear to have a `#captcha-challenge` anchor. The dedicated CAPTCHA documentation exists at a different URL.

**Fix**: Replace with `/azure/web-application-firewall/afds/captcha-challenge`

---

### 4. 🔗 27019.md — Suspect remediation link

**Current link**: `/azure/web-application-firewall/afds/waf-front-door-tuning#javascript-challenge`

**Issue**: The WAF tuning page doesn't appear to have a `#javascript-challenge` anchor. The dedicated JS challenge docs are at a different URL.

**Fix**: Replace with `/azure/web-application-firewall/waf-javascript-challenge`

---

## Advisory findings (recommended but not blocking)

### 5. ⚠️ 25539.md & 25550.md — No mention that IDPS and TLS inspection require Azure Firewall Premium

These files accurately describe IDPS and TLS inspection capabilities but do not note these are **Premium SKU-only** features. The feature comparison table shows:

| Feature | Basic | Standard | Premium |
|---------|-------|----------|---------|
| Fully managed IDPS | — | — | ✓ |
| TLS inspection | — | — | ✓ |

Without this context, readers may wrongly expect these features on Standard or Basic SKUs.

**Recommendation**: Add a brief note such as "Azure Firewall Premium is required for IDPS" or add a remediation link to the feature comparison page.

### 6. ⚠️ 26882.md — Bot protection "classification" description slightly diverges from docs

**Claim**: "The Bot Manager rule set classifies bots into known good bots, known bad bots, and unknown bots"

**Actual (per official docs)**: The three categories are **Bad**, **Good**, and **Unknown** — with specific definitions:
- Bad bots: malicious IPs + falsified identities
- Good bots: trusted user agents with subcategories (search engines, link checkers, social media, advertising, content checkers, miscellaneous)
- Unknown bots: user agents without additional validation

The file says "known good/bad/unknown" but the actual category names are just "Good/Bad/Unknown." This is minor and essentially correct in meaning.

### 7. ⚠️ 27018.md — Rate limiting CAPTCHA action claim needs SKU context

**Claim**: "the WAF can block subsequent requests, log violations, issue CAPTCHA challenges, or redirect to a custom page"

**Context**: CAPTCHA is a Premium-tier-only feature for Azure Front Door WAF. The base custom rule actions are ALLOW, BLOCK, LOG, and REDIRECT. CAPTCHA and JS Challenge are additional actions only available on Premium. The claim is technically accurate for Premium but could mislead Standard tier users.

---

## Per-file verification results

### DDoS Protection (3 files)

| File | Title | Status | Notes |
|------|-------|--------|-------|
| 25533.md | DDoS Protection for public IPs | ✅ Accurate | IP Protection and Network Protection tiers correctly described. Protected resource types match [FAQ](https://learn.microsoft.com/azure/ddos-protection/ddos-faq) |
| 26885.md | Metrics for DDoS-protected IPs | ❌ Inaccurate | Claims "application-layer" DDoS mitigation — DDoS Protection is L3/L4 only per [overview](https://learn.microsoft.com/azure/ddos-protection/ddos-protection-overview) |
| 26886.md | Diagnostic logging for DDoS IPs | ✅ Accurate | Three log categories (DDoSProtectionNotifications, DDoSMitigationFlowLogs, DDoSMitigationReports) confirmed per [logging docs](https://learn.microsoft.com/azure/ddos-protection/ddos-view-diagnostic-logs) |

### Azure Firewall (5 files)

| File | Title | Status | Notes |
|------|-------|--------|-------|
| 25535.md | Outbound traffic through Firewall | ✅ Accurate | Centralized inspection, threat intelligence, IDPS, TLS, egress enforcement all confirmed |
| 25537.md | Threat intelligence deny mode | ✅ Accurate | IP/FQDN/URL filtering, rule processing order before NAT/network/application rules confirmed per [threat intel config](https://learn.microsoft.com/azure/firewall-manager/threat-intelligence-settings) |
| 25539.md | IDPS deny mode | ⚠️ Partially Accurate | Technical claims accurate (Layers 3-7, fully managed, inbound/spoke-to-spoke/outbound). Missing: Premium-only requirement. Per [premium features](https://learn.microsoft.com/azure/firewall/premium-features#idps) |
| 25550.md | TLS inspection | ⚠️ Partially Accurate | Technical claims accurate (decrypt/inspect/re-encrypt, CA cert in Key Vault, outbound + east-west). Missing: Premium-only requirement. Per [premium features](https://learn.microsoft.com/azure/firewall/premium-features#tls-inspection) |
| 26887.md | Diagnostic logging for Firewall | ✅ Accurate | Log categories (application rules, network rules, NAT, threat intel, IDPS, DNS proxy) confirmed per [monitoring docs](https://learn.microsoft.com/azure/firewall/monitor-firewall) |

### Application Gateway WAF (8 files)

| File | Title | Status | Notes |
|------|-------|--------|-------|
| 25541.md | WAF prevention mode | ✅ Accurate | Detection vs Prevention modes correctly described per [AG WAF overview](https://learn.microsoft.com/azure/web-application-firewall/ag/ag-overview#waf-modes) |
| 26879.md | Request body inspection | ✅ Accurate | Body inspection for malicious patterns correctly described per [request size limits](https://learn.microsoft.com/azure/web-application-firewall/ag/application-gateway-waf-request-size-limits#request-body-inspection) |
| 26881.md | Default rule set | ✅ Accurate | Microsoft DRS and OWASP CRS correctly described per [CRS rules docs](https://learn.microsoft.com/azure/web-application-firewall/ag/application-gateway-crs-rulegroups-rules) |
| 26882.md | Bot protection rule set | ✅ Accurate | Three categories (Good/Bad/Unknown) and Bot Manager rule set confirmed per [bot protection overview](https://learn.microsoft.com/azure/web-application-firewall/ag/bot-protection-overview) |
| 26888.md | Diagnostic logging | ✅ Accurate | Access, Performance, and Firewall logs confirmed per [diagnostics docs](https://learn.microsoft.com/azure/application-gateway/application-gateway-diagnostics) |
| 27015.md | HTTP DDoS rule set | ✅ Accurate | Microsoft HTTP DDoS Rule Set confirmed as an available managed rule set |
| 27016.md | Rate limiting | ✅ Accurate | Custom rules with RateLimitRule type confirmed per [rate limiting overview](https://learn.microsoft.com/azure/web-application-firewall/ag/rate-limiting-overview) |
| 27017.md | JavaScript challenge | ⚠️ Partially Accurate | Feature description is accurate but **PREVIEW status not disclosed**. Per [JS challenge docs](https://learn.microsoft.com/azure/web-application-firewall/waf-javascript-challenge), this is in preview with significant limitations |

### Azure Front Door WAF (8 files)

| File | Title | Status | Notes |
|------|-------|--------|-------|
| 25543.md | WAF prevention mode | ✅ Accurate | Detection vs Prevention at edge correctly described per [AFD WAF overview](https://learn.microsoft.com/azure/web-application-firewall/afds/afds-overview) |
| 26880.md | Request body inspection | ✅ Accurate | Consistent with [WAF policy settings](https://learn.microsoft.com/azure/web-application-firewall/afds/waf-front-door-policy-settings) |
| 26883.md | Default rule set | ✅ Accurate | Microsoft Default Rule Set correctly described per [DRS docs](https://learn.microsoft.com/azure/web-application-firewall/afds/waf-front-door-drs) |
| 26884.md | Bot protection rule set | ✅ Accurate | Premium SKU requirement and three categories confirmed per [AFD WAF overview](https://learn.microsoft.com/azure/web-application-firewall/afds/afds-overview#waf-rules) and [bot protection config](https://learn.microsoft.com/azure/web-application-firewall/afds/waf-front-door-policy-configure-bot-protection) |
| 26889.md | Diagnostic logging | ✅ Accurate | WAF Logs and Access Logs confirmed per [monitoring docs](https://learn.microsoft.com/azure/web-application-firewall/afds/waf-front-door-monitor) |
| 27018.md | Rate limiting | ⚠️ Partially Accurate | Claims CAPTCHA as rate limiting action — technically correct for Premium tier only. Standard actions are ALLOW/BLOCK/LOG/REDIRECT per [custom rules](https://learn.microsoft.com/azure/web-application-firewall/afds/waf-front-door-custom-rules) |
| 27019.md | JavaScript challenge | ✅ Accurate | Description matches [JS challenge docs](https://learn.microsoft.com/azure/web-application-firewall/waf-javascript-challenge). **Note**: Remediation link `#javascript-challenge` anchor may not resolve |
| 27020.md | CAPTCHA challenge | ✅ Accurate | Description matches [CAPTCHA docs](https://learn.microsoft.com/azure/web-application-firewall/afds/captcha-challenge). **Note**: Remediation link `#captcha-challenge` anchor may not resolve |

---

## Remediation link audit

All 24 files use relative Learn links (`/azure/...`). Key links verified:

| Link | Status |
|------|--------|
| `/azure/ddos-protection/ddos-protection-overview` | ✅ Valid |
| `/azure/ddos-protection/manage-ddos-protection` | ✅ Valid |
| `/azure/ddos-protection/ddos-protection-sku-comparison` | ✅ Valid |
| `/azure/ddos-protection/diagnostic-logging` | ✅ Valid |
| `/azure/firewall-manager/threat-intelligence-settings` | ✅ Valid |
| `/azure/firewall/premium-features` | ✅ Valid |
| `/azure/firewall/tutorial-firewall-deploy-portal` | ✅ Valid |
| `/azure/web-application-firewall/ag/ag-overview` | ✅ Valid |
| `/azure/web-application-firewall/afds/afds-overview` | ✅ Valid |
| `/azure/web-application-firewall/afds/waf-front-door-tuning#javascript-challenge` | 🔗 Suspect |
| `/azure/web-application-firewall/afds/waf-front-door-tuning#captcha-challenge` | 🔗 Suspect |

---

## Sources consulted

### Tier 1 — Primary (learn.microsoft.com)
- [Azure DDoS Protection overview](https://learn.microsoft.com/azure/ddos-protection/ddos-protection-overview)
- [DDoS Protection SKU comparison](https://learn.microsoft.com/azure/ddos-protection/ddos-protection-sku-comparison)
- [DDoS Protection FAQ](https://learn.microsoft.com/azure/ddos-protection/ddos-faq)
- [DDoS diagnostic logging](https://learn.microsoft.com/azure/ddos-protection/ddos-view-diagnostic-logs)
- [Azure Firewall threat intelligence configuration](https://learn.microsoft.com/azure/firewall-manager/threat-intelligence-settings)
- [Azure Firewall Premium features](https://learn.microsoft.com/azure/firewall/premium-features)
- [Azure Firewall features by SKU](https://learn.microsoft.com/azure/firewall/features-by-sku)
- [Azure Firewall monitoring](https://learn.microsoft.com/azure/firewall/monitor-firewall)
- [Application Gateway WAF overview](https://learn.microsoft.com/azure/web-application-firewall/ag/ag-overview)
- [WAF CRS rule groups and rules](https://learn.microsoft.com/azure/web-application-firewall/ag/application-gateway-crs-rulegroups-rules)
- [WAF request size limits](https://learn.microsoft.com/azure/web-application-firewall/ag/application-gateway-waf-request-size-limits)
- [Bot protection overview (App GW)](https://learn.microsoft.com/azure/web-application-firewall/ag/bot-protection-overview)
- [Rate limiting overview (App GW)](https://learn.microsoft.com/azure/web-application-firewall/ag/rate-limiting-overview)
- [JavaScript challenge docs](https://learn.microsoft.com/azure/web-application-firewall/waf-javascript-challenge)
- [Front Door WAF overview](https://learn.microsoft.com/azure/web-application-firewall/afds/afds-overview)
- [Front Door WAF DRS rules](https://learn.microsoft.com/azure/web-application-firewall/afds/waf-front-door-drs)
- [Front Door WAF custom rules](https://learn.microsoft.com/azure/web-application-firewall/afds/waf-front-door-custom-rules)
- [Front Door WAF bot protection config](https://learn.microsoft.com/azure/web-application-firewall/afds/waf-front-door-policy-configure-bot-protection)
- [Front Door WAF CAPTCHA](https://learn.microsoft.com/azure/web-application-firewall/afds/captcha-challenge)
- [WAF Azure Policy definitions](https://learn.microsoft.com/azure/web-application-firewall/shared/waf-azure-policy)

### Tier 2 — Secondary
- [Azure security benchmark — Network Security](https://learn.microsoft.com/security/benchmark/azure/mcsb-v2-network-security)
- [Zero Trust for hub VNet](https://learn.microsoft.com/security/zero-trust/azure-infrastructure-networking)

---

*Report generated by Content Developer Assistant fact-checker workflow*
