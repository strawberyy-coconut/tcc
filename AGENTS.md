# AGENTS.md

Guide for agentic coding agents working in this repository.

## Project Overview

This is an academic thesis (TCC — Trabalho de Conclusão de Curso) for a Computer Science degree at Centro Universitário do Distrito Federal (UDF). The document is written in **Typst** (a modern typesetting system) and compiles to PDF. The thesis documents the design of "TechtonicCMS", a headless CMS with attribute-based access control (ABAC).

**This is a document project, not a software project.** There are no source code tests, linters, or typecheckers. The "build" compiles a Typst document to PDF.

## Build Commands

```bash
# One-time compilation (outputs to build/tcc.pdf)
./project.sh build

# Watch mode — recompiles on every file change
./project.sh dev

# Remove build artifacts
./project.sh clean

# Direct typst compilation (equivalent to build)
typst compile src/main.typ build/tcc.pdf

# Direct typst watch (equivalent to dev)
typst watch src/main.typ build/tcc.pdf
```

### Testing and Linting

There are **no tests or lint commands** for this project. The only validation is whether `typst compile` succeeds without errors. After making changes, always run `./project.sh build` to verify the document compiles cleanly.

## Repository Structure

```
├── .devcontainer/          # VS Code dev container config (Alpine + typst)
├── .opencode/              # OpenCode agent config and plugins
│   └── agents/
│       └── review.md       # Review agent — checks writing quality and citations
├── build/
│   └── tcc.pdf             # Compiled output (gitignored)
├── compose.dev.yaml        # Docker Compose for dev environment
├── Containerfile.dev       # Alpine image with typst, node, poppler-utils
├── project.sh              # Build script (build/dev/clean)
├── references/             # PDF references for citation verification
└── src/
    ├── main.typ            # Main document — all thesis content
    ├── refs.yml            # Bibliography in Hayagriva YAML format
    ├── diagramas/          # Figures and diagrams (PNG, SVG, drawio)
    └── udf-tcc-template/   # Custom UDF/ABNT Typst template
        ├── template.typ    # Template with cover, approval page, ABNT formatting
        ├── associacao-brasileira-de-normas-tecnicas.csl  # ABNT citation style
        └── udf-logo.png    # University logo
```

## Typst Style Conventions

### Imports and Template

The document uses a single import at the top of `main.typ`:

```typst
#import "./udf-tcc-template/template.typ": *
```

The template is applied via `#show: udf-paper.with(...)` with parameters for title, authors, course, etc. **Do not modify the template unless specifically asked.**

### Document Organization

- Chapter-level headings (`= Title`) correspond to major thesis sections
- Each chapter is preceded by a comment banner: `// ============...`
- Subsections use `==`, sub-subsections use `===`
- Headings are numbered automatically via the template (`set heading(numbering: "1.")`)

### Formatting Patterns

- **Line breaks between paragraphs**: Use `#linebreak()` to create spacing between distinct ideas within a section. Do not use blank lines for paragraph separation — use `#linebreak()`.
- **Inline formatting**: `*bold*` for emphasis on terms, `_italic_` for foreign words and technical terms in another language.
- **Section comments**: Use `// =====...` comment banners to separate major chapters visually in source.

### Citations and References

Citations use Typst's `@key` syntax referencing entries in `src/refs.yml`:

```typst
This is a claim @headless2021decoupled.
Multiple citations use semicolons: @headless2021decoupled; @boiko2005.
```

The bibliography file (`refs.yml`) uses **Hayagriva YAML format**. Each entry has a unique key and fields like `type`, `title`, `author`, `date`, etc. When adding references:

1. Add the entry to `src/refs.yml` with a descriptive key (e.g., `author2024topic`)
2. Cite in text with `@key`
3. Place the actual PDF in `references/` for verification
4. Include `note: "Acesso em: DD mes. YYYY"` for web references

### Figures and Tables

Figures follow ABNT formatting (handled by the template):

```typst
#figure(
  image("diagramas/filename.png", width: 70%),
  caption: [Descriptive caption]
) <fig-label>

#align(left)[#text(size: 10pt)[Fonte: Source attribution.]]
```

- Always include a `<fig-label>` for cross-references
- Always include a source line below the figure
- Width is specified as a percentage (common: `70%`, `90%`, `100%`)
- Images reference the `diagramas/` directory relative to `src/main.typ`

Tables use `#table()` with column definitions. ABNT styling (no vertical borders) is applied by the template.

### Code Blocks

Use triple backticks with language identifier:

```typst
```graphql
query { ... }
```
```

## Language and Writing Conventions

- **Language**: Brazilian Portuguese (pt-BR)
- **Academic register**: Formal, third person, passive voice preferred
- **ABNT compliance**: The template enforces ABNT norms (font sizes, margins, heading styles, citation format)
- **Technical terms in English**: Keep in English with `_italic_` on first mention (e.g., `_frontend_`, `_backend_`, `_headless_`)
- **Acronyms**: Spell out on first use, then abbreviate (e.g., "Sistema de Gerenciamento de Conteúdo (CMS)")

## Common Agent Tasks

### Adding Content to the Thesis

1. Edit `src/main.typ` — this is the single source file for all content
2. Add references to `src/refs.yml` if citing new sources
3. Place any new diagrams in `src/diagramas/`
4. Run `./project.sh build` to verify compilation

### Review Agent

A review agent is configured at `.opencode/agents/review.md`. It operates in read-only subagent mode (cannot edit files) and focuses on:

- **Writing quality**: Checks that prose is concise, grammatically correct, and maintains academic register (formal, third person, passive voice).
- **Citation verification**: Cross-references claims in `src/main.typ` against the actual PDFs stored in `references/` to confirm that cited sources support the assertions made. Uses bash commands (e.g., `pdftotext`) to extract and search PDF content when direct reading is not possible.

Invoke this agent when you want to validate new or existing content without making changes.

### Editing the Template

The template at `src/udf-tcc-template/template.typ` handles:
- Page layout (A4, ABNT margins: 3cm left, 2cm right, 3cm top, 2cm bottom)
- Cover page, title page, approval page
- Heading numbering and formatting
- Figure/table ABNT styling
- Bibliography rendering with ABNT CSL

## Dev Environment

- **Container**: Alpine Linux with `typst`, `bash`, `git`, `nodejs`, `poppler-utils`, and Microsoft core fonts
- **VS Code extensions**: tinymist (Typst LSP), PDF viewer, Copilot Vision, Foam
- **Required tools**: `typst` (installed in container, or install locally from https://github.com/typst/typst)

## Key Constraints

- Do NOT modify `src/udf-tcc-template/` unless explicitly asked
- Do NOT commit `build/` directory (it is gitignored)
- Always verify changes compile: run `./project.sh build` after edits
- Preserve `#linebreak()` usage between paragraphs — do not replace with blank lines
- Keep figure source attributions (`Fonte: ...`) consistent
- When adding citations, ensure the reference exists in `refs.yml` and the PDF exists in `references/`
