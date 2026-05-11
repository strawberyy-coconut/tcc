---
name: thesis-review
description: "Thesis citation and quality review workflow. Use when: verifying thesis citations, checking ABNT references, running citation audits on Typst documents, validating claims against source PDFs."
user-invocable: true
---

# Thesis Review Workflow

Run a comprehensive review of the thesis citations, bibliography formatting, and writing quality.

## When to Use
- Before submitting a thesis chapter
- After adding new citations or references
- When verifying ABNT compliance of bibliography entries
- To audit whether claims in the text match their cited sources

## Scripts
- [extract-citations.sh](./scripts/extract-citations.sh) — Pull all `@key` citations from a Typst chapter file
- [verify-pdf.sh](./scripts/verify-pdf.sh) — Run `pdftotext` and search for keywords in a reference PDF

## Procedure

### 1. Identify Target Chapter(s)
Determine which chapter(s) to review. Common targets:
- `src/chapter-2.typ` (Referencial Teórico — usually citation-heavy)
- `src/chapter-1.typ` ( Introdução)
- All chapters: `src/chapter-*.typ`

### 2. Extract Citations
For each target chapter, run the extraction script:
```bash
./.github/skills/thesis-review/scripts/extract-citations.sh src/chapter-2.typ
```
This outputs a list of unique `@key` citations used in the chapter.

### 3. Delegate Verification to Agent
For each citation found, invoke the Thesis Reviewer agent:

> "Verify citation `@key` in `src/chapter-2.typ` against `references/<filename>.pdf`"

The agent will:
- Read the claim context in the chapter
- Extract text from the PDF (Use built in skills preferably)
- Determine if the source supports the claim
- Check the `refs.yml` entry for completeness

### 4. Compile Report
Aggregate all agent outputs into a single markdown report:

```markdown
# Thesis Review Report — Chapter 2

## Citation Verification
[Agent findings per citation]

## Bibliography Check
[Missing fields, extra entries]

## Writing Quality Notes
[Style and register issues]

## Summary
- Total citations: N
- Verified: N
- Issues: N
- Missing PDFs: list
```

### 5. Action Items
Create a todo list for the user based on findings:
- Fix incorrect citations
- Add missing fields to refs.yml
- Locate missing PDFs in `references/`
- Address writing quality issues

## Tips
- Start with Chapter 2 (Referencial Teórico) as it typically has the most citations
- The review agent is read-only — it cannot accidentally modify your thesis
- If pdf reading skills are not available use our scripts
- Run `pdftotext` manually if the script fails: `pdftotext references/file.pdf - | grep -i "keyword"`
