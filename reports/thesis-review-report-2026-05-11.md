# Thesis Review Report — 11 de Maio de 2026

## Escopo da Revisão

Capítulos analisados: 1, 2, 3, 4, 5
Método: extração automatizada de citações `@key` + verificação cruzada com PDFs em `references/` + checagem de `refs.yml`

---

## Resumo por Capítulo

| Capítulo | Citações | Verificadas (PDF) | Problemas Críticos | Problemas Menores |
|----------|----------|-------------------|--------------------|--------------------|
| 1        | 7        | 5                 | 0                  | 0                  |
| 2        | ~50      | 17                | 2                  | 3                  |
| 3        | 3        | 3                 | 1                  | 2                  |
| 4        | 0        | 0                 | 0                  | 0                  |
| 5        | 0        | 0                 | 0                  | 0                  |

---

## Verificação de Citações

### Capítulo 1 — Introdução

| Citação | PDF Encontrado | Verificação | Observação |
|---------|---------------|-------------|------------|
| `@boiko2005` | ✅ Content Management Bible...pdf | ✅ Suportada | Conceitos de CMS e arquitetura monolítica confirmados no texto |
| `@caoxuanan2023headless` | ❌ Não disponível | ⚠️ Não verificável | Tese de mestrado finlandesa; entrada em `refs.yml` completa |
| `@fielding2000architectural` | ✅ fielding_dissertation.pdf | ✅ Suportada | Arquitetura cliente-servidor e separação de camadas confirmadas |
| `@headless2021decoupled` | ✅ headless2021decoupled.pdf | ✅ Suportada | Arquitetura headless e omnichannel confirmados no abstract |
| `@kleppmann2017designing` | ✅ Designing Data-Intensive Applications...pdf | ✅ Suportada | Arquiteturas shared-nothing e consistência em sistemas distribuídos confirmadas |
| `@nist2014abac` | ✅ nist.sp.800-162.pdf | ✅ Suportada | Conceitos de ABAC, PDP, PEP, PIP, PAP confirmados |
| `@w3techs2024usage` | ❌ Não disponível | ⚠️ Não verificável | Fonte web dinâmica; entrada em `refs.yml` completa |

### Capítulo 2 — Referencial Teórico

| Citação | PDF Encontrado | Verificação | Observação |
|---------|---------------|-------------|------------|
| `@manish2008content` | ❌ | ⚠️ Não verificável | Entrada `refs.yml` completa |
| `@boiko2005` | ✅ | ✅ Suportada | Funções de CMS (Collection, Management, Publishing) confirmadas p. 72 |
| `@wordpress2024docs` / `@joomla2024docs` | ❌ | ⚠️ Não verificável | Fontes web |
| `@w3techs2024usage` | ❌ | ⚠️ Não verificável | Fonte web |
| `@headless2021decoupled` | ✅ | ✅ Suportada | Três tipos de CMS (tradicional, headless, híbrido) confirmados |
| `@caoxuanan2023headless` | ❌ | ⚠️ Não verificável | Tese de mestrado |
| `@sommerville2015` | ✅ Sommerville...pdf | ✅ Suportada | Arquitetura cliente-servidor confirmada seção 17.2 |
| `@fielding2000architectural` | ✅ | ✅ Suportada | Client-server como estilo arquitetural mais frequente confirmado |
| `@kleppmann2017designing` | ✅ | ✅ Suportada | Arquiteturas shared-nothing (p. 17) e consistência em sistemas distribuídos confirmadas |
| `@banks2018learning` | ✅ Learning-GraphQL...pdf | ⚠️ Parcial | Conceitos de over-fetching/under-fetching confirmados; **analogia do restaurante NÃO está no livro** — é original da tese |
| `@graphql2015facebook` | ❌ | ⚠️ Não verificável | Fonte web |
| `@hartig2018semantics` | ✅ Semantics and Complexity...pdf | ❌ **NÃO SUPORTADA** | O artigo afirma explicitamente: *"we do not consider mutation types"* (p. 3). Citar este artigo para "queries e mutations como duas operações principais" é **factualmente incorreto** |
| `@jones2015jwt` | ✅ rfc7519.pdf | ✅ Suportada | Definição de JWT como compacto e assinado digitalmente confirmada no abstract |
| `@rfc6750` | ❌ | ⚠️ Não verificável | Fonte web/RFC |
| `@elmalki2022impact` | ❌ | ⚠️ Não verificável | Artigo acadêmico sem PDF |
| `@rfc6585` | ❌ | ⚠️ Não verificável | Fonte web/RFC |
| `@serbout2023patterns` | ❌ | ⚠️ Não verificável | Artigo acadêmico sem PDF |
| `@biryukov2015argon2` | ❌ | ⚠️ Não verificável | Relatório técnico sem PDF |
| `@owasp2023argon2` / `@owasp2026secureheaders` / `@redis2024docs` | ❌ | ⚠️ Não verificável | Fontes web |
| `@sandhu1996role` | ✅ Role-Based Access Control Models.pdf | ✅ Suportada | RBAC com permissões associadas a papéis confirmado p. 38 |
| `@ferraiolo2003role` | ✅ Role-Based Access Control.pdf | ⚠️ Parcial | "Amplamente utilizado" é implícito pela discussão de padronização, mas não explicitamente afirmado no texto |
| `@coyne2013abac` | ✅ coyne2013.pdf | ✅ Suportada | Limitações do RBAC (atributos dinâmicos, granularidade) confirmadas |
| `@nist2014abac` | ✅ nist.sp.800-162.pdf | ✅ Suportada | Arquitetura ABAC com PDP, PEP, PIP, PAP confirmada p. 14 |
| `@servos2017abac` | ✅ servos2017.pdf | ✅ Suportada | Atributos de sujeito, recurso, ação e ambiente confirmados p. 2 |
| `@oasis2013xacml` / `@combiningpolicies2009` / `@openpolicyagentcontributors2024opa` / `@casbin2024docs` / `@aws2024abac` / `@ranger2024docs` | ❌ | ⚠️ Não verificável | Fontes web ou sem PDF |
| `@nadkarni2007eav` | ❌ | ⚠️ Não verificável | Artigo acadêmico sem PDF |
| `@batra2017eav` | ✅ Entity Attribute Value...pdf | ✅ Suportada | Flexibilidade de schema e evolução sem alterações estruturais confirmadas no abstract |
| `@silberschatz2018database` | ✅ Database System Concepts.pdf | ✅ Suportada | Indexação eficiente e integridade referencial confirmadas |
| `@postgresql2024json` / `@postgresql2024jsonfunctions` / `@krosing2013server` | ❌ | ⚠️ Não verificável | Fontes web ou sem PDF |
| `@fowler2002patterns` | ✅ Patterns-of-Enterprise...pdf | ✅ Suportada | Padrão "Metadata Mapping" confirmado capítulo 13, p. 306 |
| `@prakash2016performance` | ❌ | ⚠️ Não verificável | Artigo acadêmico sem PDF |
| `@levy1994predicate` | ✅ Query Optimization...pdf | ⚠️ Parcial | O artigo menciona predicate pushdown como contexto, mas sua **contribuição central é predicate move-around**, uma generalização. A tese cita a fonte para "predicate pushdown como estratégia central", o que é parcialmente desalinhado |
| `@wang2001schema` | ⚠️ Schema Evolution...pdf | ❌ **PDF ERRADO** | O PDF em `references/` é **"Schema Evolution in Interactive Programming Systems"** (Edwards et al., 2024/2025), NÃO o artigo de Wang, Bing (2001). A entrada em `refs.yml` descreve um artigo completamente diferente do arquivo físico |
| `@nagel2014codegen` | ❌ | ⚠️ Não verificável | Artigo acadêmico sem PDF |
| `@react2024docs` / `@solidjs2024docs` / `@svelte2024docs` / `@strapi2024docs` | ❌ | ⚠️ Não verificável | Fontes web |

### Capítulo 3 — Conceito e Design do Sistema

| Citação | PDF Encontrado | Verificação | Observação |
|---------|---------------|-------------|------------|
| `@wang2001schema` | ⚠️ PDF é Edwards et al. 2024/2025 | ⚠️ Parcial (conteúdo correto, metadados errados) | O conteúdo do PDF realmente discute evolução de schema em sistemas interativos, mas **não é o Wang (2001)** descrito em `refs.yml` |
| `@kleppmann2017designing` | ✅ | ⚠️ Parcial | Kleppmann discute evolução de schema em bancos de dados, mas **NÃO discute sistemas de programação interativos** ou "propagação incremental sem interromper clientes conectados". A citação está estendida além do escopo da fonte |
| `@levy1994predicate` | ✅ | ⚠️ Parcial | Mesmo problema do Capítulo 2: o artigo é sobre predicate move-around, não predicate pushdown |

---

## Checagem de Bibliografia (`refs.yml`)

### Entradas Estruturalmente Completas

Todas as entradas em `refs.yml` possuem os campos obrigatórios para o formato Hayagriva:
- Fontes web: `title`, `author`, `url`, `date`, `note` (com "Acesso em")
- Livros: `title`, `author`, `publisher`, `date`
- Artigos: `title`, `author`, `parent` (periódico/proceedings), `date`
- Relatórios: `title`, `author`, `organization`/`institution`, `date`

### Problemas Identificados

1. **`@wang2001schema` — MISMATCH CRÍTICO**
   - `refs.yml` descreve: Wang, Bing (2001), "A Formal Dynamic Schema Evolution Model for Hypermedia Databases", Springer
   - PDF real em `references/`: Edwards, Jonathan et al. (2024/2025), "Schema Evolution in Interactive Programming Systems", The Art, Science, and Engineering of Programming
   - **Ação**: Corrigir `refs.yml` para refletir o PDF real (Edwards et al., 2024/2025) OU obter o PDF correto de Wang (2001)

2. **`@ferraiolo2003role` — Nota informal**
   - Campo `note: "NIST Special Publication"` é ligeiramente informal para ABNT; idealmente usaria `series` ou `number`
   - **Impacto**: Baixo — aceitável na prática

3. **`@wang2001schema` em `refs.yml` — Campos ausentes**
   - `page-range` ausente
   - `location` ausente
   - **Nota**: Como o PDF não corresponde, estes campos são secundários

---

## Qualidade de Escrita

### Problemas de Registro Acadêmico

1. **Analogias coloquiais** (Capítulo 2, seção CMS):
   - "é como um painel de controle" — considerar "funciona como um painel de controle" ou voz passiva
   - "Pense no CMS como um editor de documentos" — voz ativa na segunda pessoa; considerar "O CMS pode ser conceituado como..."

2. **Metáforas teatrais** (Capítulo 2, seção Headless):
   - "bastidores de um teatro" / "palco do teatro" — pedagogicamente efetivas, mas desviam do registro acadêmico padrão

3. **Analogia do restaurante** (Capítulo 2, seção GraphQL):
   - A analogia do restaurante/salada para over-fetching/under-fetching **não está em @banks2018learning**
   - Deve ser apresentada como explicação original da tese, não atribuída à fonte

### Problemas Fáticos

1. **Datas do WordPress/Joomla em @boiko2005**:
   - Os anos de lançamento (2003, 2005) não foram confirmados no texto do Boiko
   - São conhecimento geral; considerar remover a citação específica ou adicionar uma fonte que confirme as datas

---

## Problemas Críticos (Requerem Ação Imediata)

### 1. ❌ `@wang2001schema` — PDF incorreto em `references/`

O arquivo `Schema Evolution in Interactive Programming Systems.pdf` é um artigo de 2024/2025 de Edwards et al., não o artigo de 2001 de Wang, Bing. Há duas opções de correção:

**Opção A**: Atualizar `refs.yml` para refletir o PDF real
```yaml
edwards2024schema:
  type: article
  title: "Schema Evolution in Interactive Programming Systems"
  author:
    - Edwards, Jonathan
    - Litt, Geoffrey
    - Petricek, Tomas
    - van der Storm, Tijs
  parent:
    type: periodical
    title: "The Art, Science, and Engineering of Programming"
    volume: 9
    issue: 1
  date: 2024
  note: "Acesso em: ..."
```

**Opção B**: Obter o PDF correto de Wang (2001) e substituir o arquivo em `references/`

### 2. ❌ `@hartig2018semantics` — Citação factualmente incorreta

O artigo de Hartig & Pérez (2018) afirma explicitamente: *"we do not consider mutation types"* (p. 3). Citar este artigo para "queries e mutations como as duas operações principais do GraphQL" é incorreto.

**Correção sugerida**:
- Remover `@hartig2018semantics` da frase sobre mutations
- Substituir por uma fonte que discuta mutations (ex: especificação GraphQL, `@banks2018learning`, ou `@graphqlspec2025`)

### 3. ⚠️ `@levy1994predicate` — Desalinhamento terminológico

A tese cita Levy et al. (1994) para "predicate pushdown", mas o artigo é sobre "predicate move-around" (uma generalização do pushdown).

**Correção sugerida**:
- Ou reescrever o texto para discutir "predicate move-around" como técnica de otimização
- Ou substituir a citação por uma fonte que trate especificamente de predicate pushdown

---

## Estatísticas Finais

| Métrica | Valor |
|---------|-------|
| Total de citações únicas no documento | ~55 |
| Citações com PDF disponível | ~21 |
| Citações verificadas com sucesso | 17 |
| Citações com suporte parcial | 6 |
| Citações não suportadas / incorretas | 3 |
| Citações não verificáveis (sem PDF) | 29 |
| Problemas críticos | 3 |
| Problemas menores | 5+ |

---

## Recomendações Gerais

1. **Priorizar correção dos 3 problemas críticos** antes de submissão
2. **Revisar analogias pedagógicas** para garantir que não sejam atribuídas a fontes
3. **Considerar arquivar PDFs de fontes web importantes** (RFCs, OWASP, PostgreSQL docs) para futura verificação
4. **Revisar registro acadêmico** no Capítulo 2 — há muitas construções informais (analogias, segunda pessoa, metáforas)
5. **Verificar se há citações órfãs** em `refs.yml` que não são usadas no texto
