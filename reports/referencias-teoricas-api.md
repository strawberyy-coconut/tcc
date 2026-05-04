# Relatório de Referências Teóricas para a API TechtonicCMS

**Data:** 2026-05-04  
**Objetivo:** Fundamentar conceitos implementados na API (`techtoniccms-api`) que não possuem referência no Capítulo 2 (Referencial Teórico) da tese.  
**Formato:** Entradas em Hayagriva YAML compatíveis com `src/refs.yml`.

---

## 1. Agendamento de Tarefas (Background Job Scheduling)

### Conceito
O sistema implementa `SchedulerService`, um serviço de background que executa periodicamente (a cada 60 segundos) para processar agendamentos de conteúdo (`EntrySchedules`). Isso permite transições automáticas de estado (publicar, arquivar, deletar) em horários pré-determinados, sem intervenção do usuário.

### Relevância
É um padrão arquitetural essencial para workflows de conteúdo com publicação programada. A tese menciona estados (`DRAFT`, `PUBLISHED`, `ARCHIVED`, `DELETED`) mas não explica o mecanismo de transição temporal. Sem fundamentação teórica, o leitor pode assumir que as transições são apenas manuais.

### Onde inserir no Capítulo 2
Nova subseção em **2.4 Dynamic Data Modeling** ou seção dedicada **2.X Task Scheduling in Content Management**.

### Referência recomendada

```yaml
prakash2016performance:
  type: conference
  title: "Performance optimisation of web applications using in-memory caching and asynchronous job queues"
  author:
    - Prakash, Sidharth S.
    - Kovoor, B. C.
  parent:
    type: proceedings
    title: IEEE International Conference on Advances in Computer Engineering and Applications
    publisher: IEEE
  date: 2016
  doi: 10.1109/ICACEA.2016.7830234
  note: "Acesso em: 04 mai. 2026"
```

**Citação sugerida:** _"Sistemas modernos de gerenciamento de conteúdo empregam filas de tarefas assíncronas e serviços de agendamento em background para executar operações pesadas — como publicação programada e processamento de mídia — sem bloquear a thread principal da aplicação @prakash2016performance."_

---

## 2. Autenticação por API Key

### Conceito
Além de JWT, a API implementa autenticação por API Key (`ApiKeyAuthenticationHandler`) usando header `X-Api-Key`. O hash da chave é armazenado (SHA256), com prefixo para identificação, suporte a expiração e rastreamento de último uso.

### Relevância
É o mecanismo padrão para integração machine-to-machine (M2M) em APIs headless. A tese menciona API keys apenas no caso de uso do blog, sem explicar o modelo de ameaças, o hash-only storage, ou a distinção com JWT (session-based vs. token perpetuo).

### Onde inserir no Capítulo 2
Subseção em **2.5 ABAC** ou nova seção **2.X Authentication Mechanisms for APIs**, distinguindo sessão (JWT) de integração (API Key).

### Referência recomendada

```yaml
rfc6750:
  type: report
  title: "The OAuth 2.0 Authorization Framework: Bearer Token Usage"
  author:
    - Jones, Michael B.
    - Hardt, Dick
  organization: Internet Engineering Task Force
  number: "RFC 6750"
  date: 2012-10
  url: https://www.rfc-editor.org/info/rfc6750
  note: "Acesso em: 04 mai. 2026"
```

> **Nota:** O RFC 6750 já é a base do OAuth 2.0 Bearer Token. A API Key do TechtonicCMS segue o mesmo padrão de transmissão via header `Authorization`. Se desejar uma referência específica sobre API Keys em CMS, sugere-se também:

```yaml
habib2025gateway:
  type: article
  title: "API Gateway Patterns in Spring Boot Microservices: Routing, Load Balancing, and Rate Limiting"
  author:
    - Habib, Osaid
  date: 2025
  url: https://www.researchgate.net/publication/400829975
  note: "Acesso em: 04 mai. 2026"
```

**Citação sugerida:** _"Para integração entre sistemas (machine-to-machine), APIs frequentemente empregam chaves de acesso (API keys) transmitidas via header de autorização, seguindo o padrão Bearer definido pelo OAuth 2.0 @rfc6750. Este modelo differencia-se de tokens de sessão (JWT) por ser stateless do ponto de vista do cliente, embora o servidor mantenha metadados de controle @habib2025gateway."_

---

## 3. Rate Limiting / Throttling

### Conceito
A API implementa três tiers de rate limiting: `Login` (10 req/min, janela fixa), `Upload` (token bucket, 10 tokens / 5 replenish), e `GeneralApi` (1000 req/min). Rejeição imediata com HTTP 429 e `QueueLimit = 0`.

### Relevância
Protege contra credential stuffing, DoS por brute force, e exaustão de recursos. A tese não fundamenta por que 10 req/min para login ou por que token bucket para upload.

### Onde inserir no Capítulo 2
Nova subseção **2.X Rate Limiting and Availability** ou integrado à seção de segurança.

### Referências recomendadas

```yaml
rfc6585:
  type: report
  title: "Additional HTTP Status Codes"
  author:
    - Nottingham, Mark
    - Fielding, Roy T.
  organization: Internet Engineering Task Force
  number: "RFC 6585"
  date: 2012-04
  url: https://www.rfc-editor.org/info/rfc6585
  note: "Acesso em: 04 mai. 2026"

serbout2023patterns:
  type: conference
  title: "API Rate Limit Adoption--A pattern collection"
  author:
    - Serbout, Souhaila
    - El Malki, Achraf
    - Pautasso, Cesare
    - Zdun, Uwe
  parent:
    type: proceedings
    title: Proceedings of the 28th European Conference on Pattern Languages of Programs
    publisher: ACM
  date: 2023
  doi: 10.1145/3628034.3628039
  note: "Acesso em: 04 mai. 2026"
```

**Citação sugerida:** _"Rate limiting constitui uma camada de defesa contra abuso de APIs e negação de serviço. O código HTTP 429 (Too Many Requests), padronizado na RFC 6585 @rfc6585, sinaliza que o cliente excedeu sua cota. Padrões arquiteturais documentados por @serbout2023patterns descrevem estratégias como janela fixa, token bucket e sliding window, cada uma com trade-offs entre precisão e overhead computacional."_

---

## 4. Argon2id / Password Hashing Moderno

### Conceito
O `PasswordService` utiliza Argon2id (vencedor da Password Hashing Competition 2015) com parâmetros OWASP 2023: 64 MB de memória, 3 iterações, 4 lanes. Inclui fallback transparente para SHA256 legado, com migração automática de hashes.

### Relevância
A tese menciona Argon2id no Capítulo 4 mas não o fundamenta no Capítulo 2. Não explica por que Argon2id (memória-hard) é superior a bcrypt/PBKDF2 em cenários de GPU cracking, nem o conceito de "upgrading legacy hashes".

### Onde inserir no Capítulo 2
Nova subseção **2.X Password Storage and Hashing** ou dentro da seção de segurança.

### Referências recomendadas

```yaml
biryukov2016argon2:
  type: conference
  title: "Argon2: new generation of memory-hard functions for password hashing and other applications"
  author:
    - Biryukov, Alex
    - Dinu, Daniel
    - Khovratovich, Dmitry
  parent:
    type: proceedings
    title: 2016 IEEE European Symposium on Security and Privacy (EuroS&P)
    publisher: IEEE
  date: 2016
  doi: 10.1109/EuroSP.2016.36
  note: "Acesso em: 04 mai. 2026"

owasp2024password:
  type: web
  title: "OWASP Cheat Sheet Series: Password Storage"
  author: OWASP Foundation
  url: https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html
  date: 2024
  note: "Acesso em: 04 mai. 2026"
```

**Citação sugerida:** _"Argon2id, vencedor da Password Hashing Competition de 2015 @biryukov2016argon2, é atualmente o algoritmo recomendado pelo OWASP para armazenamento de senhas, configurado como função memory-hard que resiste a ataques paralelizados em GPU @owasp2024password. A migração transparente de hashes legados (ex: SHA-256 → Argon2id) ao autenticar o usuário é uma prática defensiva reconhecida para elevar a segurança sem forçar reset de senhas em massa @owasp2024password."_

---

## 5. PostgreSQL JSON / JSONB

### Conceito
A entidade `Entry` armazena conteúdo dinâmico em uma coluna `jsonb`. O sistema usa stored procedures (`cms_extract_text`, `cms_extract_number`, etc.) para filtragem e ordenação a nível de banco.

### Relevância
A tese menciona JSONB mas sem referência bibliográfica. É necessário fundamentar por que `jsonb` (binário, indexável via GIN) é preferível a `json` (texto puro) para queries frequentes.

### Onde inserir no Capítulo 2
Subseção **2.4 Dynamic Data Modeling** (já existe, mas sem citação).

### Referência recomendada

```yaml
postgresql2024json:
  type: web
  title: "PostgreSQL 15 Documentation: JSON Types"
  author: PostgreSQL Global Development Group
  url: https://www.postgresql.org/docs/15/datatype-json.html
  date: 2024
  note: "Acesso em: 04 mai. 2026"
```

**Citação sugerida:** _"O tipo `jsonb` do PostgreSQL armazena dados JSON em formato binário decomposto, eliminando a necessidade de reparsing a cada consulta e suportando indexação via GIN (Generalized Inverted Index) @postgresql2024json. Isso viabiliza filtragem e ordenação eficientes em schemas dinâmicos sem recorrer ao padrão EAV."_

---

## 6. Metadata Mapping (Fowler)

### Conceito
O sistema usa metadados de schema (tabelas `collections`, `fields`) interpretados por código genérico (`CollectionTypeModule`, `DynamicCollectionHelpers`) para gerar tipos GraphQL e validar dados em tempo de execução.

### Relevância
A tese menciona "Metadata Mapping" como `@fowler2002patterns` mas a referência **não existe** no `refs.yml`. É um conceito central para justificar a geração dinâmica de schemas sem recompilação.

### Onde inserir no Capítulo 2
Subseção **2.4 Dynamic Data Modeling**.

### Referência recomendada

```yaml
fowler2002patterns:
  type: book
  title: "Patterns of Enterprise Application Architecture"
  author: Fowler, Martin
  publisher: Addison-Wesley
  location: Boston
  date: 2002
  isbn: "978-0321127426"
```

**Citação sugerida:** _"O padrão Metadata Mapping, documentado por @fowler2002patterns, permite que mapeamentos objeto-relacional sejam definidos em metadados tabulares interpretados por código genérico, eliminando a necessidade de geração de código ou recompilação quando o schema evolui."_

---

## 7. GraphQL (Facebook 2015)

### Conceito
GraphQL foi criado pelo Facebook em 2012 e open-sourced em 2015. É a base de toda a API do TechtonicCMS.

### Relevância
A tese menciona `@graphql2015facebook` mas a referência **não existe** no `refs.yml`. É necessário para fundamentar a escolha do GraphQL sobre REST.

### Onde inserir no Capítulo 2
Seção **2.3 GraphQL for Content APIs** (já existe, mas sem citação original).

### Referência recomendada

```yaml
byron2015graphql:
  type: web
  title: "GraphQL: A data query language"
  author: Byron, Lee
  url: https://graphql.org/blog/2015-09-14-graphql/
  date: 2015
  note: "Acesso em: 04 mai. 2026"
```

**Citação sugerida:** _"GraphQL foi desenvolvido pelo Facebook em 2012 e publicado como open source em 2015 @byron2015graphql. Sua característica central é permitir que o cliente especifique exatamente os campos necessários, eliminando over-fetching e under-fetching inerentes a APIs REST tradicionais @banks2018learning."_

---

## 8. Redis / Cache em Memória

### Conceito
Redis é usado para armazenamento de sessões JWT (`SessionService`) e refresh tokens, com TTL automático e operações em batch (`CreateBatch`).

### Relevância
A tese menciona "cache em memória" mas sem referência. É necessário distinguir o cache de sessões (Redis, memória) do cache de avaliação ABAC (PostgreSQL, persistente).

### Onde inserir no Capítulo 2
Subseção sobre caching em **2.X Caching Strategies** ou dentro de **2.3 GraphQL**.

### Referência recomendada

```yaml
redis2024docs:
  type: web
  title: "Redis Documentation"
  author: Redis Team
  url: https://redis.io/documentation
  date: 2024
  note: "Acesso em: 04 mai. 2026"
```

**Citação sugerida:** _"Sistemas de cache em memória, como Redis, são empregados para armazenamento de sessões e tokens de curta duração, oferecendo TTL (time-to-live) automático e operações atômicas em batch @redis2024docs. Isso permite revogação instantânea de sessões sem consultas ao banco de dados relacional principal."_

---

## 9. JSON Web Token (JWT) — Verificação

### Conceito
A tese já cita `@jones2015jwt` (RFC 7519). Verificamos que esta referência **já existe** em `refs.yml` e está correta. Nenhuma ação necessária.

---

## 10. Manipulação de Árvores de Expressão (Expression Trees)

### Conceito
O `[UseAbacRowCheck]` constrói dinamicamente filtros LINQ em tempo de execução usando `System.Linq.Expressions`: cria parâmetro (`Expression.Parameter`), acessa propriedade (`Expression.Property`), compara com constante (`Expression.Equal`), e fecha em lambda (`Expression.Lambda`). O EF Core traduz a árvore para SQL.

### Relevância
A tese descreve o resultado ("filtragem row-level via árvore de expressões") mas não fundamenta *como* ou *por que* expression trees são usadas. É necessário explicar que elas permitem composição de queries em runtime mantendo tradução para SQL — diferente de filtrar em memória após materialização.

### Onde inserir no Capítulo 2
Nova subseção **2.X Dynamic Query Construction** ou dentro de **2.5 ABAC** ao explicar row-level filtering.

### Referências recomendadas

```yaml
nagel2014codegen:
  type: conference
  title: "Code generation for efficient query processing in managed runtimes"
  author:
    - Nagel, Fabian
    - Bierman, Gavin M.
    - Viglas, Stratis D.
  parent:
    type: proceedings
    title: Proceedings of the VLDB Endowment
    publisher: VLDB
  date: 2014
  doi: 10.14778/2735461.2735463
  note: "Acesso em: 04 mai. 2026"

schiavio2023dynq:
  type: article
  title: "DynQ: a dynamic query engine with query-reuse capabilities embedded in a polyglot runtime"
  author:
    - Schiavio, Fabio
    - Bonetta, Daniele
    - Binder, Walter
  parent:
    type: periodical
    title: The VLDB Journal
    volume: 32
    issue: 6
  page-range: 1-25
  date: 2023
  doi: 10.1007/s00778-023-00784-2
  note: "Acesso em: 04 mai. 2026"

ms2024expressiontrees:
  type: web
  title: "Expression Trees (C# Programming Guide)"
  author: Microsoft
  url: https://learn.microsoft.com/en-us/dotnet/csharp/advanced-topics/expression-trees/
  date: 2024
  note: "Acesso em: 04 mai. 2026"
```

**Citação sugerida:** _"A construção dinâmica de consultas em runtime — essencial para filtros de segurança que dependem de atributos avaliados em tempo de execução — pode ser realizada através de árvores de expressão (_expression trees_), estruturas de dados que representam código como uma hierarquia de nós navegáveis e modificáveis @ms2024expressiontrees. Nagel et al. @nagel2014codegen demonstram que a geração de código a partir de árvores de expressão permite que motores de consulta traduzam predicates dinâmicos para SQL eficiente, eliminando a necessidade de materializar dados em memória antes da filtragem. Schiavio et al. @schiavio2023dynq estendem este conceito a runtimes poliglotas, demonstrando reuso de planos de execução para queries parametrizadas dinamicamente."_

---

## Bloco Consolidado para `src/refs.yml`

Copie as entradas abaixo diretamente para o arquivo `src/refs.yml`, mantendo a ordem alfabética por chave:

```yaml
# ============================================================
# Referências adicionadas em 2026-05-04 para fundamentar
# conceitos da API não cobertos no Capítulo 2
# ============================================================

biryukov2016argon2:
  type: conference
  title: "Argon2: new generation of memory-hard functions for password hashing and other applications"
  author:
    - Biryukov, Alex
    - Dinu, Daniel
    - Khovratovich, Dmitry
  parent:
    type: proceedings
    title: 2016 IEEE European Symposium on Security and Privacy (EuroS&P)
    publisher: IEEE
  date: 2016
  doi: 10.1109/EuroSP.2016.36
  note: "Acesso em: 04 mai. 2026"

byron2015graphql:
  type: web
  title: "GraphQL: A data query language"
  author: Byron, Lee
  url: https://graphql.org/blog/2015-09-14-graphql/
  date: 2015
  note: "Acesso em: 04 mai. 2026"

fowler2002patterns:
  type: book
  title: "Patterns of Enterprise Application Architecture"
  author: Fowler, Martin
  publisher: Addison-Wesley
  location: Boston
  date: 2002
  isbn: "978-0321127426"

habib2025gateway:
  type: article
  title: "API Gateway Patterns in Spring Boot Microservices: Routing, Load Balancing, and Rate Limiting"
  author:
    - Habib, Osaid
  date: 2025
  url: https://www.researchgate.net/publication/400829975
  note: "Acesso em: 04 mai. 2026"

owasp2024password:
  type: web
  title: "OWASP Cheat Sheet Series: Password Storage"
  author: OWASP Foundation
  url: https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html
  date: 2024
  note: "Acesso em: 04 mai. 2026"

postgresql2024json:
  type: web
  title: "PostgreSQL 15 Documentation: JSON Types"
  author: PostgreSQL Global Development Group
  url: https://www.postgresql.org/docs/15/datatype-json.html
  date: 2024
  note: "Acesso em: 04 mai. 2026"

prakash2016performance:
  type: conference
  title: "Performance optimisation of web applications using in-memory caching and asynchronous job queues"
  author:
    - Prakash, Sidharth S.
    - Kovoor, B. C.
  parent:
    type: proceedings
    title: IEEE International Conference on Advances in Computer Engineering and Applications
    publisher: IEEE
  date: 2016
  doi: 10.1109/ICACEA.2016.7830234
  note: "Acesso em: 04 mai. 2026"

ms2024expressiontrees:
  type: web
  title: "Expression Trees (C# Programming Guide)"
  author: Microsoft
  url: https://learn.microsoft.com/en-us/dotnet/csharp/advanced-topics/expression-trees/
  date: 2024
  note: "Acesso em: 04 mai. 2026"

nagel2014codegen:
  type: conference
  title: "Code generation for efficient query processing in managed runtimes"
  author:
    - Nagel, Fabian
    - Bierman, Gavin M.
    - Viglas, Stratis D.
  parent:
    type: proceedings
    title: Proceedings of the VLDB Endowment
    publisher: VLDB
  date: 2014
  doi: 10.14778/2735461.2735463
  note: "Acesso em: 04 mai. 2026"

redis2024docs:
  type: web
  title: "Redis Documentation"
  author: Redis Team
  url: https://redis.io/documentation
  date: 2024
  note: "Acesso em: 04 mai. 2026"

rfc6585:
  type: report
  title: "Additional HTTP Status Codes"
  author:
    - Nottingham, Mark
    - Fielding, Roy T.
  organization: Internet Engineering Task Force
  number: "RFC 6585"
  date: 2012-04
  url: https://www.rfc-editor.org/info/rfc6585
  note: "Acesso em: 04 mai. 2026"

serbout2023patterns:
  type: conference
  title: "API Rate Limit Adoption--A pattern collection"
  author:
    - Serbout, Souhaila
    - El Malki, Achraf
    - Pautasso, Cesare
    - Zdun, Uwe
  parent:
    type: proceedings
    title: Proceedings of the 28th European Conference on Pattern Languages of Programs
    publisher: ACM
  date: 2023
  doi: 10.1145/3628034.3628039
  note: "Acesso em: 04 mai. 2026"
```

---

## Resumo das Correções Necessárias em `refs.yml` Existente

| Chave existente | Problema | Ação |
|-----------------|----------|------|
| `@batra2016eav` | Documento base cita "Batra et al., 2017" (ano inconsistente) | Uniformizar para 2016 ou verificar edição correta |
| `@fowler2002patterns` | Citado no texto mas **não existe** no `refs.yml` | Adicionar do bloco consolidado |
| `@graphql2015facebook` | Citado no texto mas **não existe** no `refs.yml` | Substituir por `@byron2015graphql` do bloco consolidado |
| `@postgresql2024json` | Citado no texto mas **não existe** no `refs.yml` | Adicionar do bloco consolidado |
| `nadkarni2007eav` | Figura EAV atribui a "Dinu e Nadkarni (2007)" mas a ref é só Nadkarni | Corrigir atribuição da figura ou adicionar Dinu como coautor |

---

## Checklist de Inserção no Capítulo 2

- [ ] **Job Scheduling** — Nova subseção ou parágrafo em Dynamic Data Modeling
- [ ] **API Key Authentication** — Distinguir de JWT; mencionar hash-only storage
- [ ] **Rate Limiting** — Explicar HTTP 429, janela fixa, token bucket
- [ ] **Argon2id** — Fundamentar escolha do algoritmo e migração de hashes
- [ ] **PostgreSQL JSONB** — Diferença entre `json` e `jsonb`, indexação GIN
- [ ] **Metadata Mapping** — Fowler 2002 como base para geração dinâmica
- [ ] **GraphQL 2015** — Post original do Facebook como fonte primária
- [ ] **Redis** — Cache de sessões vs. cache ABAC (distinguir!)
- [ ] **Expression Trees** — Dynamic query construction para row-level filtering
