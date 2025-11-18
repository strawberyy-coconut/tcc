# TCC Project: Headless CMS with ABAC - AI Agent Instructions

## Project Overview
This is an **academic thesis (TCC)** documenting the design of a headless Content Management System with Attribute-Based Access Control. The repository contains a Typst-formatted academic paper, NOT application code.

**Author:** Gustavo Medeiros Lima | **Institution:** UDF (Brasília) | **Year:** 2024

## Critical Context: Document Structure

### Three-Chapter Architecture
1. **Chapter 1 (Introdução)**: Problem definition, objectives, methodology
2. **Chapter 2 (Referencial Teórico)**: ALL concept definitions and theoretical foundations  
   - ⚠️ **NEVER add design decisions to Chapter 2** - theory only
   - ALL claims MUST have citations (`@citation_key`)
3. **Chapter 3 (Conceito e Design)**: System design, architecture decisions, technical specifications

### Chapter Boundaries Rule
- Defining "what CMS is" → Chapter 2
- Explaining "how OUR CMS works" → Chapter 3
- If in doubt, check existing section placement in `src/main.typ`

## Working with Citations

### Citation Requirements
- **Every** definition, claim, or fact needs `@citation_key` from `src/refs.yml`
- Academic sources only (books, papers, standards) - NO blog posts
- If missing citations, ALERT the user immediately

### Citation Verification Workflow
When user requests citation validation:
1. Extract PDF text: `pdftotext '/workspaces/tcc/references/<filename>.pdf' -`
2. Search for relevant passages: `grep -i "keyword" /tmp/extracted.txt`
3. Verify claim accuracy against source material
4. Suggest text improvements if citation context doesn't match

### Common Citation Keys
- `@kleppmann2017designing` - "Designing Data-Intensive Applications" (systems architecture, scalability, distributed systems)
- `@boiko2005` - "Content Management Bible" (CMS fundamentals, frameworks)
- `@headless2021decoupled` - Headless CMS architecture paper
- `@nist2014abac` - ABAC standard specification
- `@banks2018learning` - GraphQL concepts

⚠️ **Kleppmann Context**: Focuses on data-intensive systems (databases, distributed systems), NOT web frontend/backend specifically. Use for general architectural principles, not web-specific patterns.

## Development Workflows

### Compilation Commands
```bash
# One-time build
./project.sh build          # → outputs to build/tcc.pdf

# Development mode (auto-recompile on save)
./project.sh dev            # watches src/main.typ

# Clean build artifacts
./project.sh clean
```

### Dev Container Environment
- **OS**: Alpine Linux v3.22
- **Key tools**: `typst` (document compiler), `pdftotext` (PDF text extraction for citation verification)
- **Extensions**: Tinymist (Typst LSP), PDF viewer, Copilot Vision

## Document Conventions

### Typst Syntax Patterns
- `#linebreak()` between major paragraphs (not after every sentence)
- Bold with `*text*`, italics with `_text_`
- Citations: `@citation_key` inline, multiple as `@source1; @source2`
- Code blocks: ` ```language ... ``` `
- Figures: `#figure(image("path.png"), caption: [...])` with labels `<fig-name>`

### Writing Style
- **Didactic explanations** with analogies (e.g., "CMS is like Microsoft Word for websites")
- Technical precision balanced with accessibility
- Portuguese language throughout
- Examples grounded in concrete use cases (hospitals, editors, etc.)

## Reference Management

### Bibliography File: `src/refs.yml`
```yaml
citation_key:
  type: book|article|conference
  title: "Title"
  author: Name | [Name1, Name2]
  publisher: Publisher
  date: YYYY
  doi: optional
```

### PDF Reference Files
Located in `/workspaces/tcc/references/` with naming pattern:
- Full titles with metadata
- Both `.pdf` and `.txt` (extracted) versions for some files

## System Architecture Documentation

The thesis describes a three-tier architecture:
1. **Persistence Layer**: PostgreSQL (relational + JSON), Redis (cache)
2. **Application Layer**: GraphQL API, REST endpoints, ABAC engine
3. **Presentation Layer**: Modern frontend framework (technology-agnostic)

### Key Design Patterns Documented
- **Hybrid data storage**: Typed tables for primitives + JSON for complex structures (avoids EAV anti-pattern)
- **ABAC components**: PDP (decision), PEP (enforcement), PIP (information), PAP (administration)
- **GraphQL schema**: Union types for flexible field values, resolver-level ABAC integration

## Diagrams
Located in `src/diagramas/`:
- System architecture overview
- Database schema (collections, entries, fields)
- Security/ABAC tables and relationships
- Use `.drawio` for editable versions, `.png` for compiled document

## Common Tasks

### Adding New Sections
1. Determine correct chapter (theory vs. design)
2. Check if related content exists elsewhere
3. Add appropriate heading level (`==` subsection, `===` subsubsection)
4. Include citations for all claims
5. Add `#linebreak()` between major paragraphs

### Validating Academic Rigor
1. Verify every claim has citation
2. Extract cited source: `pdftotext 'references/<source>.pdf' -`
3. Grep for relevant keywords in extracted text
4. Confirm claim aligns with source context
5. Suggest reformulations if needed

### Updating References
1. Add entry to `src/refs.yml` following existing format
2. Place PDF in `/workspaces/tcc/references/`
3. Use citation key in document: `@new_key`

## Red Flags to Watch For

❌ Design decisions in Chapter 2 (theory chapter)  
❌ Uncited claims or definitions  
❌ Blog posts as primary sources  
❌ Citations used out of context (especially Kleppmann for web-specific patterns)  
❌ Mixing Portuguese and English inconsistently  
❌ Breaking chapter boundary rules  

## When User Says...

- **"Validate this citation"** → Extract PDF, search for keywords, verify context
- **"Add to Chapter 2"** → Ensure it's theoretical, not design-specific
- **"Is this cited properly?"** → Check source context matches claim
- **"Compile document"** → `./project.sh build`
- **"Missing references?"** → Scan section for claims without `@citations`

## Thesis Conventions

- **Avoid**: "será implementado" (will be implemented) - this documents the DESIGN, not future work
- **Use**: Present or conditional tense for design descriptions
- **Analogies**: Encouraged for complex concepts (restaurants for GraphQL, theater for frontend/backend)
- **Academic tone**: Maintained but accessible to non-specialists
