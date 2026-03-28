# TechtonicCMS

**A Headless Content Management System** — Undergraduate thesis (TCC) for the Computer Science program at Centro Universitário do Distrito Federal (UDF).

## About

This thesis presents the design of TechtonicCMS, a headless CMS that combines an API-first decoupled architecture with attribute-based access control (ABAC), offering fine-grained authorization down to individual content fields. The document covers the theoretical foundations of content management systems, access control models (RBAC and ABAC), and modern web architectures, alongside the system's database modeling, API specification, and implementation plan.

## Prerequisites

- [Typst](https://github.com/typst/typst) — the typesetting system used to compile the document

## Building

```bash
# One-time compilation (outputs to build/tcc.pdf)
./project.sh build

# Watch mode — recompiles on every file change
./project.sh dev

# Remove build artifacts
./project.sh clean
```

Equivalent direct commands:

```bash
typst compile src/main.typ build/tcc.pdf
typst watch src/main.typ build/tcc.pdf
```

## Project Structure

```
src/
  main.typ                  # Main document — all thesis content
  refs.yml                  # Bibliography (Hayagriva YAML)
  diagramas/                # Figures and diagrams
  udf-tcc-template/         # UDF/ABNT Typst template
references/                 # PDF references for citation verification
project.sh                  # Build script (build/dev/clean)
build/                      # Compiled output (gitignored)
```

## Author

**Gustavo Medeiros Lima** — Ciência da Computação, Centro Universitário do Distrito Federal (UDF), 2025.
