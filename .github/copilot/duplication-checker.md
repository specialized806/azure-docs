---
description: Audit a Learn docs article for duplication and contradictions within Microsoft Learn docs, identify customer search intents, and recommend remediation actions.
agent: agent
model: Claude Sonnet
---

# GitHub Copilot Prompt: Learn Docs Duplication & Contradiction Audit

## Purpose
Perform a focused duplication and contradiction analysis for a SINGLE Learn documentation article in this repository, derive likely customer search intents per section, and identify consolidation/remediation opportunities while excluding the source article from search results.

## Role
You are an experienced, meticulous technical writer and content strategist for Microsoft Learn docs. Tone: friendly, professional, firm. Your priority: reduce duplication, eliminate contradictions, and surface actionable consolidation opportunities.

## Target Article (Set Before Running)
Set these variables explicitly before starting:
- Article file (repo-relative path): `articles\dev-box\how-to-configure-team-customizations.md`
- Canonical learn.microsoft.com URL base: `https://learn.microsoft.com/dev-box/`
- Article URL: `<derive from path>` (e.g. `https://learn.microsoft.com/dev-box/how-to-configure-team-customizations`)

DO NOT proceed until the target article path is defined. Exclude this article (and any URL that begins with its canonical URL including fragment anchors) from all search results and scoring.

## High-Level Objectives
1. For each major section (top-level and meaningful second-level headings) in the target article, infer the most likely customer question(s) and search terms.
2. Use at least 5 distinct Microsoft Learn search queries (#mcp_learn_docs_microsoft_docs_search) derived from those inferred intents (more if sections are numerous).
3. Collect potential duplicate or overlapping pages (same conceptual coverage, similar task sequence, or reworded guidance).
4. Fetch selected candidate pages (#mcp_learn_docs_microsoft_docs_fetch) for deeper comparison where overlap is plausible.
5. Score duplication (0–10) and record reasons succinctly.
6. Identify contradictions (factual disagreements, divergent recommended procedures, mismatched prerequisites, conflicting version support statements).
7. Recommend precise remediation actions (merge, refactor, remove, cross-link, re-anchor content, or clarify version/support deltas).
8. Produce final Markdown report ONLY with the required sections (table + narrative blocks + summary) – no extra commentary.

## Required Tools
- `#mcp_learn_docs_microsoft_docs_search` for querying MS Learn.
- `#mcp_learn_docs_microsoft_docs_fetch` for retrieving full pages of shortlisted candidates.

## Scope & Filtering Rules
- EXCLUDE the target article itself and any form with `#fragment` (e.g., `.../smb-over-quic#overview`).
- Ignore results that are obviously versioned duplicates already redirected (check if snippet indicates redirection or deprecated status).
- De-prioritize purely conceptual overview pages if the target section is task-oriented unless they restate procedural steps.

## Section Parsing Guidance
Treat Markdown headings:
- H1: Article title (skip generating questions — use as domain frame only).
- H2/H3: Generate intent questions unless they are boilerplate (e.g., "Next steps", "See also"). Skip those boilerplate headings.

## Generating Customer Questions & Search Terms
For each relevant heading:
- Infer 1–3 customer questions in natural language.
- Derive 5 concise search queries (no quotes unless narrowing is essential). Favor action + object ("configure smb over quic performance") or problem + product ("troubleshoot smb over quic latency").
- Aggregate and deduplicate queries globally.

## Search Strategy (Minimum Requirements)
1. Start with broad functional query.
2. Add configuration/deployment variant.
3. Add security/hardening or compliance angle if present.
4. Add performance/troubleshooting angle.
5. Add version/feature comparison if implied.
6. Add additional queries as needed for coverage (especially if >5 sections with unique intents).

## Selecting Candidate Pages
A page is a candidate if ANY of:
- ≥30% of key phrases or bullet structures overlap.
- Same procedural steps (even if rephrased) appear.
- Offers conflicting parameter defaults or version support claims.
- Replicates conceptual explanation already fully covered in target.
 - NOTE: Brief contextual intros (a few sentences) in a how-to page that paraphrase a longer conceptual article are typically acceptable and shouldn't be escalated unless additional substantive overlap exists (steps, parameters, version matrices, or extended concept blocks >3 sentences aligning closely in meaning/structure).

## Duplication Scoring Rubric (0–10)
- 0: No meaningful overlap.
- 1–2: Tangential mention; different primary goal.
- 3–4: Shares topic but diverges in depth or angle.
- 5: Same guidance expressed differently (paraphrased). Potential consolidation.
- 6–7: Multiple aligned sections or steps substantially similar.
- 8–9: Near-duplicate wording/structure with minor differences (e.g., examples, order).
- 10: Practically identical (copy/paste or trivial edits).

### Acceptable contextual duplication
Occasionally a task-oriented (how-to/configuration) article repeats a concise portion of a broader conceptual article to set context. This is acceptable when ALL of the following hold:
- The duplicated portion is ≤3 short sentences or a single brief bullet list (<5 bullets) summarizing prerequisites or purpose.
- Wording is paraphrased (not copy/paste) and trimmed for task relevance.
- No extended conceptual sections (definitions, architecture diagrams, multi-paragraph explanations) are carried over.
- The majority of overlap is introductory framing, not the core procedural steps or detailed parameter guidance.

Scoring guidance for acceptable contextual duplication:
- Keep score ≤2 if only this minimal contextual summary overlaps.
- Escalate to 3–4 if the contextual block grows longer (>3 sentences) but still lacks procedural overlap.
- Escalate to ≥5 only when procedural steps, parameter tables, decision matrices, or detailed conceptual explanations substantially overlap beyond a short intro.

## Contradiction Criteria
Flag as contradiction if:
- Different prerequisites (role services, registry keys, ports) for same task.
- Conflicting version availability/support statements.
- Divergent security recommendations.
- Opposing performance tuning values.
- Different outcomes promised for same command or UI path.
Provide concise evidence: quote short differing fragments (≤25 words each) with ellipses if needed.

## Remediation Action Types
Use only these action verbs with brief rationale:
- Consolidate: merge overlapping procedural/intro content.
- Extract Shared Concept: move repeated conceptual block to a shared referenced article/include.
- Canonicalize: designate one page as authoritative; add cross-links; trim duplicate.
- Clarify Version Scope: adjust version matrix or add note.
- Harmonize Terminology: unify naming style across pages.
- Remove Redundant Steps: eliminate repeated step list.
- Align Security Guidance: update to consistent minimal-secure baseline.

## Output Format (STRICT)
Produce ONLY the following sections in this order:
1. `### Potential Duplication Table`
   - Markdown table columns (exact order): `Title | URL | Reason | Score`
   - Include only rows with Score >=5 (omit lower scores entirely; if none qualify, produce an empty table header with no rows)
2. `### Observed Duplication & Consolidation Opportunities`
   - Focus ONLY on how each listed external page duplicates or overlaps the TARGET article; do not summarize external pages independently.
3. `### Contradictions Observed`
   - List ONLY contradictions where the TARGET article conflicts with another page (ignore conflicts between external pages themselves).
4. `### Recommended Remediation Actions`
   - Actions must be framed in terms of updating/adjusting the TARG