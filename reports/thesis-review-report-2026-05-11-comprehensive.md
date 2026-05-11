# Thesis Review Report — Comprehensive Citation Audit

**Date:** 2026-05-11
**Scope:** Chapters 1, 2, 3 (citation verification against source PDFs + refs.yml completeness)
**Method:** Agent-assisted PDF text extraction + manual claim-to-source cross-reference

---

## Summary

| Chapter | Citations Reviewed | Verified | Partial | Issue / Not Supported |
|---------|-------------------|----------|---------|----------------------|
| 1 | 5 | 1 | 3 | 1 |
| 2 | 12 | 4 | 5 | 3 |
| 3 | 0 | — | — | — |

**Total citations reviewed:** 17 (all citations with available PDFs)
**Total issues found:** 11

---

## Chapter 1 — Introdução

### @boiko2005 — Content Management Bible (2nd ed.)
- **Claim:** Monolithic CMS limitations, omnichannel distribution, personalization at scale
- **Verdict:** ⚠️ **PARTIAL**
- **Evidence:** Boiko discusses monolithic CMS as a hurdle, multi-channel delivery, and large-scale content management. However, the specific architectural framing of "backend/frontend coupling" is anachronistic for 2005 and belongs to later headless discourse. The term "omnichannel" does not appear in the source.
- **Refs.yml:** ✅ Complete

### @fielding2000architectural — Architectural Styles and the Design of Network-based Software Architectures
- **Claim:** Decoupling content management from presentation via APIs; multi-channel distribution
- **Verdict:** ✅ **VERIFIED** (with caveat)
- **Evidence:** Fielding explicitly establishes separation of UI concerns from data storage, client-server independence, and decoupling through uniform interfaces (REST). Multi-channel distribution is not explicitly discussed (term did not exist in 2000), but "portability across multiple platforms" provides indirect support.
- **Refs.yml:** ✅ Complete

### @headless2021decoupled — Headless CMS and the Decoupled Frontend Architecture
- **Claim:** Headless architecture decouples backend/frontend; omnichannel delivery; traditional CMS limitations
- **Verdict:** ✅ **VERIFIED**
- **Evidence:** Source explicitly supports all three claims: decoupling, omnichannel, and traditional CMS tight coupling limitations.
- **Refs.yml:** ⚠️ **Issues found:**
  - Author uses initial only: `Jain, V.` → should be `Jain, Vivek`
  - Missing `url` field (journal website or ResearchGate link)
  - Missing access date `note` for web/online source

### @kleppmann2017designing — Designing Data-Intensive Applications
- **Claim:** Monolithic CMS with tightly coupled backend/frontend has limitations for omnichannel and personalization
- **Verdict:** ⚠️ **PARTIAL**
- **Evidence:** The book does not mention CMS, content management, frontend, backend, omnichannel, or personalization. It discusses tight coupling as a general software complexity symptom, but this is not specific to CMS architecture.
- **Recommendation:** Consider replacing this citation in this specific sentence with a more CMS-specific source.
- **Refs.yml:** ✅ Complete

### @nist2014abac — NIST SP 800-162
- **Claim:** Compliance requirements demand granular ABAC with contextual attributes (creator, publication state, time, IP address)
- **Verdict:** ⚠️ **PARTIAL**
- **Evidence:** NIST strongly supports ABAC using subject/object attributes and environment conditions (time is explicitly listed). Creator/author is supported as an object attribute. However, **IP address** and **publication state** are **not mentioned** in the source.
- **Refs.yml:** ❌ **Incorrect author name:**
  - `Schnitzer, Arthur` → should be **`Schnitzer, Adam`**

---

## Chapter 2 — Referencial Teórico

### @sandhu1996role — Role-based access control models (IEEE Computer)
- **Claim:** RBAC associates permissions with organizational roles; a user with role "Editor" receives all permissions defined for that role
- **Verdict:** ✅ **VERIFIED**
- **Evidence:** Source explicitly describes RBAC as creating roles according to job functions, granting permissions to roles, and assigning users to predefined roles.
- **Refs.yml:** ⚠️ **Incomplete author list:**
  - Lists `Sandhu, Ravi S.` followed by `et al.`
  - Actual authors: **Ravi S. Sandhu, Edward J. Coyne, Hal L. Feinstein, Charles E. Youman**

### @servos2017abac — Current research and open problems in attribute-based access control (ACM Computing Surveys)
- **Claim:** ABAC evaluates subject, resource, action, and environment attributes (time, location)
- **Verdict:** ✅ **VERIFIED**
- **Evidence:** Source directly supports all four attribute dimensions. Explicitly mentions time, IP address, and physical location as environmental/connection attributes.
- **Refs.yml:** ✅ Complete

### @coyne2013abac — ABAC and RBAC: Scalable, flexible, and auditable access management (IT Professional)
- **Claim:** RBAC has limitations: role explosion, inability to consider dynamic attributes (time, location), difficulty implementing fine-grained control
- **Verdict:** ⚠️ **PARTIAL**
- **Evidence:** Source supports dynamic attributes and fine-grained control limitations. However, it **does not support** "role explosion" — in fact, it states the opposite: "A limited number of roles can represent many users or user types."
- **Recommendation:** Attribute "role explosion" to `@nist2014abac` or `@servos2017abac` instead.
- **Refs.yml:** ✅ Complete

### @hartig2018semantics — Semantics and Complexity of GraphQL (WWW 2018)
- **Claims:** (1) Over-fetching/under-fetching vs REST; (2) Union types and filtering arguments; (3) Dynamic schema generation from metadata; (4) Runtime type safety in dynamic schemas
- **Verdict:** ❌ **MOSTLY NOT SUPPORTED**
- **Evidence:**
  - Over-fetching/under-fetching vs REST: **NOT FOUND** — paper is formal semantics, not engineering comparison
  - Union types: ✅ **SUPPORTED** — formally defined
  - Filtering arguments: **NOT FOUND**
  - Dynamic schema generation: **NOT FOUND** — paper treats schema as static formal object
  - Runtime type safety: **NOT FOUND**
- **Recommendation:** `@hartig2018semantics` is cited 4 times in Chapter 2 but only legitimately supports the formal definition of union types. Remove or replace citations for all other claims.
- **Refs.yml:** ✅ Complete

### @banks2018learning — Learning GraphQL (O'Reilly)
- **Claims:** (1) Over-fetching/under-fetching as documented problems; (2) GraphQL eliminates them; (3) Two main operations (queries and mutations); (4) Resolvers; (5) Union types and filtering
- **Verdict:** ✅ / ⚠️ **MOSTLY VERIFIED with minor issues**
- **Evidence:**
  - Over-fetching/under-fetching: ✅ VERIFIED
  - GraphQL eliminates them: ✅ VERIFIED
  - Two main operations: ⚠️ **PARTIAL** — Banks lists **three** operation types (Query, Mutation, Subscription), not two
  - Resolvers: ✅ VERIFIED
  - Union types: ✅ VERIFIED
  - Filtering (text, numeric, date): ⚠️ **PARTIAL** — text and date filtering confirmed; numeric field filtering **not demonstrated**
- **Refs.yml:** ✅ Complete (minor: author order lists Banks first, but PDF copyright lists Porcello first)

### @fowler2002patterns — Patterns of Enterprise Application Architecture
- **Claim:** Metadata Mapping allows generic code to process ORM mappings for read/insert/update without repetitive code
- **Verdict:** ✅ **VERIFIED**
- **Evidence:** Source directly supports the claim with nearly identical wording. Fowler explicitly describes holding mapping information in the database itself.
- **Refs.yml:** ✅ Complete

### @sommerville2015 — Software Engineering (10th ed.)
- **Claims:** (1) Client-server architecture fundamentals; (2) Headless systems require understanding APIs, protocols, distributed architectures
- **Verdict:** ✅ / ⚠️ **VERIFIED / PARTIAL**
- **Evidence:**
  - Client-server definition: ✅ VERIFIED — nearly identical wording in source
  - Headless complexity: ⚠️ **PARTIAL** — source covers client-server and distributed systems concepts, but does not mention "headless" or modern APIs. Thesis extrapolates from foundational concepts.
- **Refs.yml:** ✅ Complete

### @ferraiolo2003role — Role-Based Access Control (Artech House)
- **Claim:** RBAC is widely used
- **Verdict:** ✅ **VERIFIED**
- **Evidence:** Source explicitly states RBAC is "widely used in many industries" and "being widely implemented as a major component of government and commercial IT infrastructures."
- **Refs.yml:** ⚠️ **Incorrect note:**
  - `note: "NIST Special Publication"` is **wrong**. This book is published by Artech House, not NIST. Remove or correct this note.

### @yan2023predicate — Predicate Pushdown for Data Science Pipelines (ACM SIGMOD)
- **Claim:** Predicate pushdown in systems with dynamic schemas translates predicates to native database clauses (WHERE, ORDER BY)
- **Verdict:** ⚠️ **PARTIAL**
- **Evidence:** Source supports general predicate pushdown definition and filtering before loading into memory. However, the paper's scope is **data science pipelines with non-relational operators and UDFs**, not general dynamic-schema systems. The description of translation to `WHERE`/`ORDER BY` is more characteristic of classical relational optimization, not this paper's contribution.
- **Refs.yml:** ✅ Complete

### @silberschatz2018database — Database System Concepts (7th ed.)
- **Claims:** (1) Typed tables for primitives enable efficient indexing; (2) Junction tables preserve referential integrity with varied cardinalities
- **Verdict:** ✅ **VERIFIED**
- **Evidence:** Both claims directly supported by the textbook (SQL data types and schemas; referential integrity; mapping cardinalities; representation of relationship sets).
- **Refs.yml:** ✅ Complete

### @edwards2024schema — Schema Evolution in Interactive Programming Systems
- **Claim:** Techniques for schema evolution propagate structural changes incrementally, minimizing impact on already connected clients
- **Verdict:** ❌ **NOT SUPPORTED**
- **Evidence:** The paper is a **problem-framing/challenge paper** for interactive programming systems. The words "incremental", "client", and "connected" do **not appear** anywhere in the source. The paper identifies schema evolution as a barrier to feedback loops, not as a solved problem with incremental propagation techniques.
- **Recommendation:** Replace with a source that actually discusses incremental schema propagation in APIs, or rephrase the claim.
- **Refs.yml:** ❌ **Multiple issues:**
  - **DOI incorrect:** `.../9/1` → should be `.../9/2`
  - **Page range incorrect:** `1-28` → should be `34` pages (article 2)
  - **Author order incorrect:** PDF order is Edwards, Litt, Petricek, van der Storm; YAML order is Edwards, Petricek, van der Storm, Litt

### @levy1994predicate — Query Optimization by Predicate Move-Around (VLDB 1994)
- **Claims:** (1) Predicate move-around generalizes pushdown across query blocks (views, subqueries); (2) Particularly relevant for large volumes of semi-structured data
- **Verdict:** ✅ / ⚠️ **VERIFIED / PARTIAL**
- **Evidence:**
  - Predicate move-around across views/subqueries: ✅ VERIFIED — explicitly stated in abstract and introduction
  - Semi-structured data relevance: ⚠️ **NOT DIRECTLY SUPPORTED** — paper focuses exclusively on **relational SQL queries** in decision-support systems
- **Refs.yml:** ❌ **URL incorrect:**
  - `url` points to a Hellerstein SIGMOD 1993 paper, not the Levy et al. VLDB 1994 paper

---

## Chapter 3 — Não verificado nesta rodada

Citations `@edwards2024schema`, `@levy1994predicate`, and `@yan2023predicate` appear in Chapter 3 but were verified in the Chapter 2 context above.

---

## Chapter 4 — Falso Positivo

The extraction script identified `@preview` as a citation in `src/chapter-4.typ`. This is a **false positive** — it is the Typst package import `#import "@preview/mmdr:0.2.2": mermaid`, not a bibliographic citation.

---

## Bibliography Check (refs.yml)

### Critical Errors (must fix)
| Entry | Issue | Correction |
|-------|-------|------------|
| `nist2014abac` | Wrong author name | `Schnitzer, Arthur` → `Schnitzer, Adam` |
| `levy1994predicate` | Wrong URL | Replace with correct VLDB 1994 URL |
| `edwards2024schema` | Wrong DOI | `.../9/1` → `.../9/2` |
| `edwards2024schema` | Wrong page range | `1-28` → `34` pages / article 2 |
| `edwards2024schema` | Wrong author order | Match PDF: Edwards, Litt, Petricek, van der Storm |
| `ferraiolo2003role` | Incorrect note | Remove `note: "NIST Special Publication"` or correct it |

### Minor Issues (should fix)
| Entry | Issue | Correction |
|-------|-------|------------|
| `headless2021decoupled` | Incomplete author | `Jain, V.` → `Jain, Vivek` |
| `headless2021decoupled` | Missing URL | Add journal or ResearchGate URL |
| `headless2021decoupled` | Missing access note | Add `note: "Acesso em: ..."` |
| `sandhu1996role` | Truncated authors | List all four authors instead of `et al.` |

### Citation-Source Mismatches (should fix text or citation)
| Citation | Problem | Recommendation |
|----------|---------|----------------|
| `@kleppmann2017designing` (Ch.1) | Source does not discuss CMS | Replace with CMS-specific source or remove |
| `@coyne2013abac` (Ch.2) | "Role explosion" not in source | Attribute to `@nist2014abac` or `@servos2017abac` |
| `@hartig2018semantics` (Ch.2) | Cited for engineering claims; only supports union types formally | Remove from over-fetching, filtering, dynamic schema, and type-safety claims |
| `@edwards2024schema` (Ch.2) | Source is challenge paper, not incremental propagation technique | Replace with appropriate source or rephrase claim |
| `@yan2023predicate` (Ch.2) | Scope is data science pipelines, not general dynamic schemas | Weaken claim or replace with general query optimization reference |
| `@levy1994predicate` (Ch.2) | "Semi-structured data" not in source | Remove that qualifier or attribute to a different source |

---

## Missing PDFs

The following citations from Chapter 2 do **not** have corresponding PDFs in `references/`. This is acceptable for web sources, but academic sources should ideally be archived:

- `@aws2024abac` — AWS documentation (web)
- `@casbin2024docs` — GitHub repository (web)
- `@combiningpolicies2009` — ACM paper (academic — **recommend acquiring PDF**)
- `@elmalki2022impact` — IEEE conference paper (academic — **recommend acquiring PDF**)
- `@graphql2015facebook` — Facebook Engineering blog (web)
- `@graphqlspec2025` — GraphQL spec (web)
- `@graphql2024official` — GraphQL Foundation (web)
- `@joomla2024docs` — Joomla documentation (web)
- `@krosing2013server` — PostgreSQL Server Programming book (book — **recommend acquiring PDF**)
- `@manish2008content` — IEEE conference paper (academic — **recommend acquiring PDF**)
- `@nagel2014codegen` — VLDB paper (academic — **recommend acquiring PDF**)
- `@nadkarni2007eav` — International Journal of Medical Informatics (academic — **recommend acquiring PDF**)
- `@oasis2013xacml` — OASIS standard (web)
- `@openpolicyagentcontributors2024opa` — OPA website (web)
- `@owasp2023argon2` — OWASP cheat sheet (web)
- `@owasp2026secureheaders` — OWASP cheat sheet (web)
- `@postgresql2024json` — PostgreSQL docs (web)
- `@postgresql2024jsonfunctions` — PostgreSQL docs (web)
- `@prakash2016performance` — IEEE conference (academic — **recommend acquiring PDF**)
- `@ranger2024docs` — Apache Ranger (web)
- `@react2024docs` — React docs (web)
- `@redis2024docs` — Redis docs (web)
- `@rfc6585` — IETF RFC (web)
- `@rfc6750` — IETF RFC (web)
- `@serbout2023patterns` — ACM EuroPLoP (academic — **recommend acquiring PDF**)
- `@strapi2024docs` — Strapi docs (web)
- `@svelte2024docs` — Svelte docs (web)
- `@vue2024docs` — Vue docs (web)
- `@wordpress2024docs` — WordPress docs (web)
- `@contentful2024headless` — Contentful (web)
- `@solidjs2024docs` — SolidJS docs (web)
- `@biryukov2015argon2` — Argon2 spec (web/report)

---

## Action Items

### High Priority (fix before submission)
1. **Fix `nist2014abac` author name:** `Schnitzer, Arthur` → `Schnitzer, Adam`
2. **Fix `levy1994predicate` URL:** replace incorrect Hellerstein 1993 URL
3. **Fix `edwards2024schema` DOI, page range, and author order**
4. **Remove or correct `ferraiolo2003role` note:** delete `"NIST Special Publication"`
5. **Rewrite `@edwards2024schema` claim** in Chapter 2 — source does not support incremental propagation to connected clients
6. **Remove `@hartig2018semantics`** from over-fetching, filtering, dynamic schema, and type-safety claims in Chapter 2
7. **Attribute "role explosion"** to `@nist2014abac` or `@servos2017abac` instead of `@coyne2013abac`

### Medium Priority (improve accuracy)
8. **Complete `headless2021decoupled` author name** and add URL + access note
9. **Expand `sandhu1996role` author list** to include all four authors
10. **Reconsider `@kleppmann2017designing`** in Chapter 1 CMS context — replace with CMS-specific source
11. **Weaken `@yan2023predicate` claim** to reflect data-science-pipeline scope, or replace with general query optimization reference
12. **Remove "semi-structured data" qualifier** from `@levy1994predicate` claim, or attribute to different source
13. **Acknowledge subscriptions** when citing `@banks2018learning` for GraphQL operations, or change "duas operações principais" to "três operações principais"

### Low Priority (nice to have)
14. Acquire PDFs for missing academic sources: `@combiningpolicies2009`, `@elmalki2022impact`, `@manish2008content`, `@nagel2014codegen`, `@nadkarni2007eav`, `@prakash2016performance`, `@serbout2023patterns`
15. Verify remaining Chapter 3 citations in detail
