# Thesis Review Report — Chapter 2 (Referencial Teórico)

**Date**: 2026-05-11
**Scope**: `src/chapter-2.typ` — all 41 unique `@key` citations
**Method**: PDF text extraction via `pdftotext`, live web verification, cross-reference against `src/refs.yml`

---

## Summary

| Metric | Count |
|--------|-------|
| Total unique citations | 41 |
| ✅ Fully supported | 22 |
| ⚠️ Partial / Indirect | 7 |
| ❌ Not supported / Misapplied | 4 |
| ⚠️ Unverifiable (web only) | 8 |
| Missing PDFs in `references/` | 7 |
| Writing quality issues | 10+ |

---

## Citation Verification by Batch

### Batch 1: CMS, Headless, Architecture (10 citations)

| Citation | Verdict | refs.yml | Notes |
|----------|---------|----------|-------|
| `@boiko2005` | ✅ Supported | ✅ Complete | "Control panel" metaphor is reasonable paraphrase of Boiko's "dashboard" |
| `@headless2021decoupled` | ✅ Supported | ✅ Complete | All claims verified against PDF |
| `@caoxuanan2023headless` | ✅ Supported | ✅ Complete | **PDF missing from `references/`** — download from Theseus |
| `@manish2008content` | ❌ NOT SUPPORTED | ⚠️ Year mismatch | Source is a technical Java CMS comparison, not a layperson definition. Filename suggests 2010; refs.yml says 2008 |
| `@sommerville2015` | ✅ Supported | ✅ Complete | Standard textbook reference |
| `@fielding2000architectural` | ⚠️ Partial | ✅ Complete | Fielding discusses decoupling principles but never mentions CMS. Indirect application |
| `@w3techs2024usage` | ✅ Supported | ✅ Complete | Live verification: 42.2% |
| `@wordpress2024docs` | ⚠️ Unverifiable | ✅ Complete | Web reference |
| `@joomla2024docs` | ⚠️ Unverifiable | ✅ Complete | Web reference |
| `@strapi2024docs` | ⚠️ Unverifiable | ✅ Complete | Web reference |

### Batch 2: GraphQL & APIs (8 citations)

| Citation | Verdict | refs.yml | Notes |
|----------|---------|----------|-------|
| `@banks2018learning` | ✅ Supported | ✅ Complete | CMS-specific claim is author's extrapolation |
| `@graphql2015facebook` | ✅ Supported | ✅ Complete | Public release date verified |
| `@graphqlspec2025` | ✅ Supported | ✅ Complete | Three operation types confirmed |
| `@martins2022graphql` | ✅ Supported | ✅ Complete | Dynamic schema generation confirmed |
| `@deshpande2026living` | ✅ Supported | ✅ Complete | Conditional propagation confirmed |
| `@jones2015jwt` | ⚠️ Partial | ✅ Complete | RFC defines claims format, not authentication pattern |
| `@rfc6750` | ⚠️ Partial | ✅ Complete | Conflates OAuth 2.0 bearer tokens with generic API keys |
| `@rfc6585` | ✅ Supported | ✅ Complete | HTTP 429 definition confirmed |

### Batch 3: ABAC, RBAC, Security Models (11 citations)

| Citation | Verdict | refs.yml | Notes |
|----------|---------|----------|-------|
| `@sandhu1996role` | ✅ Supported | ✅ Complete | RBAC role definition confirmed |
| `@ferraiolo2003role` | ⚠️ Partial | ⚠️ **Date mismatch** | PDF is 2nd edition **© 2007**, not 2003 |
| `@nist2014abac` | ✅ Supported | ✅ Complete | All claims verified against PDF |
| `@servos2017abac` | ⚠️ Partial | ✅ Complete | Four-category taxonomy is from NIST, not Servos (who lists five categories) |
| `@coyne2013abac` | ⚠️ Partial | ✅ Complete | Dynamic attributes supported; fine-grained control is implied, not explicit |
| `@oasis2013xacml` | ⚠️ Unverifiable | ✅ Complete | Web reference |
| `@combiningpolicies2009` | ❌ **PDF MISSING** | ⚠️ **Incomplete** | Missing `parent`, `publisher`, `location` fields |
| `@openpolicyagentcontributors2024opa` | ⚠️ Unverifiable | ✅ Complete | Web reference |
| `@casbin2024docs` | ⚠️ Unverifiable | ✅ Complete | Web reference |
| `@aws2024abac` | ⚠️ Unverifiable | ✅ Complete | Web reference |
| `@ranger2024docs` | ⚠️ Unverifiable | ✅ Complete | Web reference |

### Batch 4: Data Modeling, Database, EAV (8 citations)

| Citation | Verdict | refs.yml | Notes |
|----------|---------|----------|-------|
| `@nadkarni2007eav` | ✅ Supported | ✅ Complete | Web/PMC reference |
| `@batra2017eav` | ✅ Supported | ✅ Complete | Flexibility claim confirmed |
| `@kleppmann2017designing` | ✅ / ❌ | ✅ Complete | Supported for data systems claims; **MISAPPLIED at line 220 for UI frameworks** |
| `@silberschatz2018database` | ✅ Supported | ✅ Complete | Both indexing and relationship claims confirmed |
| `@krosing2013server` | ❌ Not Verifiable | ✅ Complete | **PDF missing from `references/`** |
| `@postgresql2024json` | ✅ Supported | ✅ Complete | Web reference verified live |
| `@postgresql2024jsonfunctions` | ✅ Supported | ✅ Complete | Web reference verified live |
| `@fowler2002patterns` | ✅ Supported | ✅ Complete | Metadata Mapping pattern confirmed |

### Batch 5: Performance, Async, Frontend, Misc (13 citations)

| Citation | Verdict | refs.yml | Notes |
|----------|---------|----------|-------|
| `@prakash2016performance` | ⚠️ Unverifiable | ✅ Complete | **PDF missing** |
| `@levy1994predicate` | ✅ Supported | ✅ Complete | Predicate move-around confirmed |
| `@yan2023predicate` | ✅ Supported | ✅ Complete | Predicate pushdown confirmed |
| `@elmalki2022impact` | ⚠️ Unverifiable | ✅ Complete | **PDF missing** |
| `@serbout2023patterns` | ⚠️ Unverifiable | ✅ Complete | **PDF missing** |
| `@biryukov2015argon2` | ✅ Supported | ✅ Complete | Live web verification |
| `@owasp2023argon2` | ✅ Supported | ✅ Complete | Live web verification |
| `@owasp2026secureheaders` | ✅ Supported | ✅ Complete | Live web verification |
| `@redis2024docs` | ⚠️ Partial | ✅ Complete | Homepage too broad; does not detail TTL/batch operations |
| `@react2024docs` | ✅ Supported | ✅ Complete | Web reference |
| `@svelte2024docs` | ✅ Supported | ✅ Complete | Web reference |
| `@solidjs2024docs` | ✅ Supported | ✅ Complete | Web reference |
| `@nagel2014codegen` | ❌ **MISAPPLIED** | ✅ Complete | Database query code-gen paper cited for frontend frameworks. **Remove** |

---

## Bibliography Check (`src/refs.yml`)

### Missing Fields

| Citation | Missing Fields |
|----------|---------------|
| `@combiningpolicies2009` | `parent` (proceedings), `publisher`, `location` |
| `@manish2008content` | `page-range` |

### Date Discrepancies

| Citation | Issue |
|----------|-------|
| `@manish2008content` | Filename `nath2010.pdf` suggests 2010; refs.yml says 2008 |
| `@ferraiolo2003role` | PDF is 2nd edition © 2007; refs.yml says 2003 |

### Missing PDFs in `references/`

1. `caoxuanan2023headless` — Download from https://www.theseus.fi/bitstream/handle/10024/795367/Cao_Xuan-An.pdf
2. `combiningpolicies2009` — Li et al. (2009), "Access control policy combining: Theory meets practice"
3. `krosing2013server` — *PostgreSQL Server Programming* (Packt, 2013)
4. `prakash2016performance` — IEEE ICACEA 2016 paper
5. `elmalki2022impact` — IEEE SOSE 2022 paper
6. `serbout2023patterns` — EuroPLoP 2023 paper
7. `nagel2014codegen` — VLDB Endowment 2014 paper

---

## Writing Quality Notes

### Critical Issues

1. **Second-person voice (`você`)** — Used throughout Sections 2.2 and 2.3:
   - *"Pense no CMS como..."* (line ~10)
   - *"Você pode usar as melhores ferramentas..."* (line ~87)
   - *"Você oferece uma experiência unificada..."* (line ~102)
   - **Fix**: Replace with impersonal constructions (*"É possível"*, *"permite-se"*, passive voice)

2. **Misapplied citations**:
   - `@kleppmann2017designing` at line 220 cited for React/Vue/Svelte/SolidJS — Kleppmann's book is about data systems, not frontend frameworks. **Remove**.
   - `@nagel2014codegen` at line 220 cited for frontend frameworks — Nagel's paper is about database query code generation. **Remove**.
   - `@manish2008content` cited for layperson CMS definition — source is a technical Java CMS comparison. **Replace**.

3. **Incorrect attribution**:
   - `@servos2017abac` cited for four-category attribute taxonomy (subject, resource, action, environment) — Servos lists **five** categories. The four-category model is from `@nist2014abac`. **Reattribute**.

### Moderate Issues

4. **Fielding citation is indirect**: `@fielding2000architectural` supports decoupling principles but Fielding never discusses CMS. Rephrase to say his REST principles *underpin* decoupled design.

5. **RFC 6750 conflates concepts**: The text says API keys follow the Bearer pattern defined by OAuth 2.0, but RFC 6750 defines OAuth 2.0 access tokens, not generic API keys.

6. **Theater metaphor**: *"bastidores de um teatro"* / *"palco do teatro"* borders on informal for academic prose. Acceptable if used sparingly.

7. **Restaurant analogy** in GraphQL section (line 89) is informal but serves explanatory purpose.

8. **Uncited claim**: The last paragraph of Section 2.5.3 (predicate pushdown synthesis) makes specific technical claims without a citation.

9. **Dense citation clusters**: Four web references in a single sentence (ABAC implementations) makes prose list-like rather than analytical.

10. **Superlatives without attribution**: *"flexibilidade máxima"* (line 172) is authorial characterization, not Batra's. Acceptable but boundary should be clear.

---

## Action Items

### High Priority

- [ ] **Replace `@manish2008content`** for the definitional claim in the CMS introduction. Use `@boiko2005` alone or add an appropriate introductory source.
- [ ] **Remove `@kleppmann2017designing` and `@nagel2014codegen`** from the UI frameworks sentence (line 220). Replace with frontend-specific sources or remove the citation pair entirely.
- [ ] **Reattribute four-category taxonomy** from `@servos2017abac` to `@nist2014abac`.
- [ ] **Fix `@ferraiolo2003role`** — either update to 2007 2nd edition or locate the actual 2003 1st edition PDF.

### Medium Priority

- [ ] **Revise second-person voice** (`você`, `Pense`, imperative forms) throughout Chapter 2 to conform to formal academic register.
- [ ] **Add missing PDFs** to `references/`:
  - [ ] Cao_Xuan-An.pdf
  - [ ] Li et al. (2009) combining policies
  - [ ] Krosing 2013 PostgreSQL Server Programming
  - [ ] Prakash 2016 IEEE paper
  - [ ] El Malki 2022 IEEE SOSE paper
  - [ ] Serbout 2023 EuroPLoP paper
  - [ ] Nagel 2014 VLDB paper
- [ ] **Fix `@combiningpolicies2009` refs.yml** — add `parent`, `publisher`, `location` fields.
- [ ] **Clarify `@fielding2000architectural`** claim — rephrase to say REST principles *underpin* decoupled design rather than implying Fielding discusses headless CMS.
- [ ] **Fix RFC 6750 claim** — distinguish OAuth 2.0 bearer tokens from generic API keys.

### Low Priority

- [ ] **Add citation** for the predicate pushdown synthesis paragraph (Section 2.5.3, last paragraph) or qualify as author's own synthesis.
- [ ] **Break up dense citation clusters** (e.g., ABAC implementations sentence) into more analytical prose.
- [ ] **Tone down or remove** theater metaphor if aiming for very formal register.
- [ ] **Verify `@manish2008content` year** — confirm 2008 vs 2010 and align refs.yml.
