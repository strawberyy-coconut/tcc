# AGENTS.md

Guide for agentic coding agents working in this repository.

## Project Overview

This repository is a **monorepo** containing:

1. **An academic thesis (TCC)** for a Computer Science degree at Centro Universitário do Distrito Federal (UDF). The document is written in **Typst** and compiles to PDF. It documents the design of "TechtonicCMS", a headless CMS with attribute-based access control (ABAC).

2. **The TechtonicCMS implementation**, split into three subprojects:
   - `techtoniccms-api/` — .NET 10 API with Hot Chocolate GraphQL, PostgreSQL, Redis, and a custom ABAC engine
   - `techtoniccms-app/` — SvelteKit 5 management frontend (Deno-based)
   - `techtoniccms-blog/` — Astro blog frontend

Each subproject has its own `AGENTS.md` with detailed conventions. See the sections below for a quick reference and links.

---

## Thesis Document (`src/`, `udf-tcc-template/`)

### Build Commands

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

There are **no tests or lint commands** for the thesis. The only validation is whether `typst compile` succeeds without errors. After making changes, always run `./project.sh build` to verify the document compiles cleanly.

### Thesis Document Structure

```
src/
  main.typ                  # Main document — all thesis content
  refs.yml                  # Bibliography in Hayagriva YAML format
  diagramas/                # Figures and diagrams (PNG, SVG, drawio)
udf-tcc-template/           # Custom UDF/ABNT Typst template
  template.typ              # Template with cover, approval page, ABNT formatting
  associacao-brasileira-de-normas-tecnicas.csl  # ABNT citation style
  udf-logo.png              # University logo
references/                 # PDF references for citation verification
build/                      # Compiled output (gitignored)
```

## API (`techtoniccms-api/`)

A .NET 10 headless CMS API built with Hot Chocolate GraphQL, EF Core (PostgreSQL), Redis sessions, and S3-compatible asset storage. Authorization uses a custom ABAC engine with deny-first, priority-based policies.

**Quick commands:**
```bash
cd techtoniccms-api
dotnet build
docker compose -f compose.dev.yaml up -d   # Run infrastructure + app
dotnet tool restore
dotnet ef migrations add <Name> --project TechtonicCmsApi
dotnet ef database update --project TechtonicCmsApi
```

GraphQL endpoint: `http://localhost:5095/graphql`

**Key conventions:**
- PascalCase for C# types/methods; camelCase for GraphQL fields; UPPERCASE for enum string values
- Entity IDs always serialized as strings
- DateTimes always UTC ISO 8601
- GraphQL type pattern: root types are minimal partial classes extended via `[ExtendObjectType]`
- Authorization: `[Authorize]`, `[Authorize(Policy = "Resource:Action")]`, `[AllowAnonymous]`
- Error codes: `NOT_FOUND`, `CONFLICT`, `BAD_REQUEST`, `UNAUTHENTICATED`, `FORBIDDEN`, `INVALID_ENUM`

**See `techtoniccms-api/AGENTS.md` for full details.**

## Management App (`techtoniccms-app/`)

A SvelteKit 5 management UI for TechtonicCMS. Talks exclusively to the GraphQL API.

**Quick commands:**
```bash
cd techtoniccms-app
deno task dev               # Start dev server
deno task build             # Production build
deno task check             # Type-check with svelte-check
deno task lint              # Prettier format check
deno task format            # Auto-format with Prettier
deno task codegen:gql       # Regenerate GraphQL types from API schema
```

**Key conventions:**
- Uses **Deno** (NOT node/npm)
- Svelte 5 runes mode
- **Remote functions only** — do NOT use `load` functions or `+page.server.ts`. Use `query()` and `form()` from SvelteKit experimental remote functions
- GraphQL client in `src/lib/server/gql.ts` with `gqlFetch<TResult, TVariables>()` — always pass explicit generics
- Error handling via `handleGraphQLError()` and `handleGraphQLErrorForm()` helpers

**See `techtoniccms-app/AGENTS.md` for full details.**

## Blog (`techtoniccms-blog/`)

An Astro-based blog frontend for TechtonicCMS.

**Quick commands:**
```bash
cd techtoniccms-blog
npm run dev                 # Start dev server
npm run build               # Production build
npm run preview             # Preview production build
npm run codegen:gql         # Regenerate GraphQL types
```

**Key conventions:**
- Astro 6 with Tailwind CSS v4
- Node adapter (`@astrojs/node`)
- Uses the shared `techtonic-client-gql/` package for GraphQL types

---

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

### Working on the API, App, or Blog

Each subproject has its own build system and conventions. Always check the subproject's `AGENTS.md` before making changes. Use the quick commands listed in the sections above.

### Review Agent

A review agent is configured at `.opencode/agents/review.md`. It operates in read-only subagent mode (cannot edit files) and focuses on:

- **Writing quality**: Checks that prose is concise, grammatically correct, and maintains academic register (formal, third person, passive voice).
- **Citation verification**: Cross-references claims in `src/main.typ` against the actual PDFs stored in `references/` to confirm that cited sources support the assertions made. Uses bash commands (e.g., `pdftotext`) to extract and search PDF content when direct reading is not possible.

Invoke this agent when you want to validate thesis content without making changes.

### Editing the Template

The template at `src/udf-tcc-template/template.typ` handles:
- Page layout (A4, ABNT margins: 3cm left, 2cm right, 3cm top, 2cm bottom)
- Cover page, title page, approval page
- Heading numbering and formatting
- Figure/table ABNT styling
- Bibliography rendering with ABNT CSL

## Dev Environment

- **Container**: Alpine Linux with `typst`, `bash`, `git`, `nodejs`, `poppler-utils`, `dotnet-sdk-10.0`, `deno`, and Microsoft core fonts
- **VS Code extensions**: tinymist (Typst LSP), PDF viewer, Copilot Vision, Foam, C# Dev Kit
- **Required tools**:
  - `typst` — for thesis compilation
  - `dotnet` — for API development
  - `deno` — for management app development
  - `node` (v22+) — for blog development

## Key Constraints

- Do NOT modify `src/udf-tcc-template/` unless explicitly asked
- Do NOT commit `build/` directory (it is gitignored)
- Always verify changes compile: run `./project.sh build` after edits
- Preserve `#linebreak()` usage between paragraphs — do not replace with blank lines
- Keep figure source attributions (`Fonte: ...`) consistent
- When adding citations, ensure the reference exists in `refs.yml` and the PDF exists in `references/`
