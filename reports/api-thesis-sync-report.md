# Relatório de Sincronização: API vs. Tese

**Data:** 2026-05-04  
**Arquivos analisados:**
- `/workspaces/tcc/src/main.typ` (tese principal, 1088 linhas)
- `/workspaces/tcc/techtoniccms-api/TechtonicCmsApi/` (código-fonte da API)
- `/workspaces/tcc/src/refs.yml` (bibliografia)
- `/workspaces/tcc/reports/thesis-base-document.md` (documento base da tese)

---

## 1. Resumo Executivo

A tese (`main.typ`) está **parcialmente sincronizada** com a API. O **Capítulo 4 (Implementação)** está razoavelmente alinhado com o código, mas o **Capítulo 3 (Conceito e Design)** contém seções desatualizadas, conceitos que não existem na API, e omite funcionalidades implementadas. O **Capítulo 2 (Referencial Teórico)** carece de referências que fundamentam conceitos usados na implementação.

---

## 2. Funcionalidades da API NÃO Mencionadas na Tese

### 2.1 Agendamento de Publicação (`EntrySchedules`)
- **API:** Entidade `EntrySchedules` com `ScheduledAction` enum (`Publish`, `Unpublish`, `Archive`, `Restore`, `Delete`) e `SchedulerService` (background service que executa a cada 1 minuto).
- **Tese:** Não mencionada em nenhum lugar. O design fala em estados (`DRAFT`, `PUBLISHED`, `ARCHIVED`, `DELETED`) mas não explica como as transições agendadas funcionam.
- **Impacto:** Médio — é uma funcionalidade significativa de workflow de conteúdo.

### 2.2 Autenticação por API Key
- **API:** Entidade `ApiKey` com `KeyHash`, `KeyPrefix`, `ExpiresAt`, `IsActive`, `LastUsedAt`. Handler `ApiKeyAuthenticationHandler` implementa scheme `ApiKey` com header `X-Api-Key`. Sistema de multi-auth (`MultiAuth` policy scheme) escolhe entre JWT e API Key.
- **Tese:** Menciona API keys apenas em passagem no capítulo de implementação ("autenticação via API Key" no caso de uso blog). Não há seção de design sobre API keys, nem referencial teórico sobre autenticação por chave de API.
- **Impacto:** Alto — é um mecanismo de autenticação completo e independente.

### 2.3 Rate Limiting
- **API:** Três tiers configurados em `Program.cs`: `Login` (10 req/min, fixed window), `Upload` (token bucket, 10 tokens / 5 replenish), `GeneralApi` (1000 req/min). `QueueLimit = 0` com rejeição imediata (HTTP 429).
- **Tese:** Mencionado apenas no capítulo de implementação. Não há seção de design sobre rate limiting, nem no referencial teórico.
- **Impacto:** Médio — importante para segurança e disponibilidade.

### 2.4 Security Headers Middleware
- **API:** `SecurityHeadersMiddleware` adiciona `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Referrer-Policy: strict-origin-when-cross-origin`, `Strict-Transport-Security`.
- **Tese:** Mencionado no capítulo de implementação, mas não no design.
- **Impacto:** Baixo — é um detalhe de implementação.

### 2.5 Serviço de Agendamento (`SchedulerService`)
- **API:** `BackgroundService` que processa `EntrySchedules` pendentes a cada minuto.
- **Tese:** Não mencionado.
- **Impacto:** Médio — é um componente arquitetural ativo.

### 2.6 Geração de Slug
- **API:** `DynamicCollectionHelpers.GenerateSlug()` — gera slugs a partir de nomes com regex.
- **Tese:** Não mencionado.
- **Impacto:** Baixo — detalhe de implementação.

### 2.7 Validação de Dados de Entrada
- **API:** `DynamicCollectionHelpers.ValidateEntryData()` valida: (a) unicidade de campos `IsUnique`, (b) existência de targets em relacionamentos.
- **Tese:** Menciona "validação em tempo real" na interface administrativa, mas não descreve as regras de validação do backend.
- **Impacto:** Médio.

### 2.8 Interceptor de Conexões (`CollectionConnectionTypeInterceptor`)
- **API:** `CollectionConnectionTypeInterceptor` implementa `OnAfterCompleteType` para construir tipos de conexão GraphQL dinamicamente.
- **Tese:** Mencionado brevemente no capítulo 4.
- **Impacto:** Baixo.

### 2.9 Hash de Senha com Argon2id e Fallback SHA256
- **API:** `PasswordService` usa Argon2id (OWASP 2023: 64MB, 3 iterações, 4 lanes) com fallback transparente para SHA256 legado — migração automática de hashes.
- **Tese:** Mencionado no capítulo 4. Não há referencial teórico sobre Argon2 ou gestão de senhas.
- **Impacto:** Médio.

### 2.10 S3/MinIO para Assets
- **API:** `S3Service` com configuração S3-compatível (MinIO).
- **Tese:** Mencionado no capítulo 4.
- **Impacto:** Baixo.

---

## 3. Conceitos na API NÃO Fundamentados no Capítulo 2 (Referencial Teórico)

| Conceito na API | Onde aparece na API | Status na Tese |
|-----------------|---------------------|----------------|
| **Agendamento de tarefas / Job Scheduling** | `SchedulerService`, `EntrySchedules` | ✅ Resolvido em 2026-05-04 — Seção 2.5, subseção "Agendamento e Processamento Assíncrono" |
| **API Keys / Autenticação por chave** | `ApiKeyAuthenticationHandler`, `ApiKeyService` | ✅ Resolvido em 2026-05-04 — Seção 2.3, subseção "Autenticação e Autorização em APIs" |
| **Rate Limiting / Throttling** | `Program.cs` (AddRateLimiter) | ✅ Resolvido em 2026-05-04 — Seção 2.3, subseção "Rate Limiting e Controle de Tráfego" |
| **Argon2id / Password Hashing Moderno** | `PasswordService` | ✅ Resolvido em 2026-05-04 — Seção 2.4, subseção "Armazenamento Seguro de Credenciais" |
| **Redis / Cache em memória** | `SessionService`, `RedisService` | ✅ Resolvido em 2026-05-04 — Seção 2.4, subseção "Cache em Memória para Sessões" |
| **JSONB / Tipos JSON em banco relacional** | `Entry.Data` (JsonDocument) | ✅ Resolvido em 2026-05-04 — Seção 2.5, subseção "Abordagens Híbridas Modernas" |
| **Stored Procedures / Funções de banco** | `CmsDbFunctions` (cms_extract_text, etc.) | ✅ Resolvido em 2026-05-04 — item "Funções de Banco de Dados para Consultas Dinâmicas" em 2.5, com citações `@krosing2013server` e `@postgresql2024jsonfunctions` |
| **Expression Trees / Reflection dinâmica** | `UseAbacRowCheckAttribute` | ⚠️ Pós-cap. 2 — referências adicionadas em `refs.yml` para uso nos capítulos 3/4 |
| **Background Services / Hosted Services** | `SchedulerService` | ✅ Resolvido em 2026-05-04 — coberto junto com agendamento |
| **Multi-factor Authentication (conceito)** | Não implementado | N/A |
| **Content Security Policy / Security Headers** | `SecurityHeadersMiddleware` | ✅ Resolvido em 2026-05-04 — subseção "Headers de Segurança HTTP" em 2.4, com citação `@owasp2026secureheaders` |
| **Connection Pooling** | `AddPooledDbContextFactory` | ✅ Resolvido em 2026-05-04 — citação no Cap. 3 com `@microsoft2025sqlserverpooling` e `@postgresql2014connections` |

### Verificação de Referências em `refs.yml`

✅ **Verificação realizada em 2026-05-04** — Todas as referências citadas em `main.typ` existem em `src/refs.yml`:

1. ✅ `@postgresql2024json` — existe (linha 531)
2. ✅ `@fowler2002patterns` — existe (linha 602)
3. ✅ `@graphql2015facebook` — existe (linha 467)
4. ✅ `@batra2016eav` — existe (linha 487)
5. ✅ `@nadkarni2007eav` — existe (linha 468)

**Pendências menores:**
- `batra2016eav` vs. "Batra et al., 2017" — inconsistência de ano a ser verificada (o PDF da referência indica 2017).
- Atribuição da figura EAV: "Dinu e Nadkarni (2007)" — Dinu é coautor da figura mas não consta na entrada `nadkarni2007eav` do `refs.yml`.

---

## 4. Análise do Capítulo 3 (Conceito e Design) — Problemas Encontrados

### 4.1 Seções Duplicadas ou Conflitantes

O capítulo 3 possui **duplicação de conteúdo** com o capítulo 4:
- A seção "APIs e Protocolos de Comunicação" no capítulo 3 repete quase verbatim conteúdo que depois aparece no capítulo 4.
- A seção "Tecnologias, Segurança e Performance" no capítulo 3 deveria ser atemporal (conforme instrução do usuário), mas menciona tecnologias específicas (Hot Chocolate 14+, PostgreSQL 15+, etc.) que já estão no capítulo 4.

### 4.2 Conceitos no Design que NÃO Existem na API

| Conceito no Design | Onde aparece na tese | Status na API |
|--------------------|----------------------|---------------|
| `sensitivityLevel` em `Field` | Design → Entidades Principais → Fields | ❌ Não existe. `Field` não tem `sensitivityLevel`, `isPii`, `isPublic` |
| `isPii` em `Field` | Design → Entidades Principais → Fields | ❌ Não existe |
| `isPublic` em `Field` | Design → Entidades Principais → Fields | ❌ Não existe |
| `ScopeType` enum | Mencionado no enum list | ⚠️ Existe na API mas não é usado em lugar nenhum visível |
| "Criptografia em repouso para campos sensíveis" | Design → Segurança | ❌ Não implementada |
| "Índices GIN" | Design → Estratégia de Armazenamento | ⚠️ Mencionado como "possível otimização" mas não confirmado na implementação |
| Cache ABAC "em memória" | Design → Camadas Arquiteturais | ❌ Incorreto. O cache ABAC é em **PostgreSQL** (`abac_evaluation_cache`), não em memória. Apenas sessões usam Redis |
| API REST para autenticação | Design → Endpoints Não-GraphQL | ❌ Incorreto. Autenticação é **exclusivamente GraphQL** |

### 4.3 Diagramas e Figuras Potencialmente Desatualizados

- **Figura 3.2 (`database-diagram.svg`)** — precisa ser regenerado para refletir o schema real (17 tabelas, 12 enums).
- **Figura 3.3 e 3.4 (`simplified_security_related_to_content.png`, `security.png`)** — precisam refletir o schema real. Notavelmente, `entry_schedules` e `api_keys` não aparecem.

### 4.4 Inconsistências de Enum

A tese lista `permission_actions` com: `create`, `read`, `update`, `delete`, `publish`, `configure_fields`, `upload`.

A API (`PermissionAction` enum) tem:
```csharp
Create, Read, Update, Delete, Publish, Unpublish, Schedule, Archive, Restore, Activate, Deactivate, Upload, Download, ManageSchema, Wildcard
```

**Diferenças:**
- API tem `Unpublish`, `Schedule`, `Archive`, `Restore`, `Activate`, `Deactivate`, `Download`, `ManageSchema` que a tese não menciona.
- Tese menciona `configure_fields` que na API é `ManageSchema`.

### 4.5 Inconsistências de Tipos de Campo

A tese lista: `text`, `number`, `boolean`, `date_time`, `rich_text`, `json`, `asset`, `relation`.

A API (`FieldDataType` enum) tem:
```csharp
Text, Boolean, Number, DateTime, Relation, Asset, Object
```

**Diferenças:**
- API não tem `rich_text` — tem `Text` genérico.
- API não tem `json` — tem `Object`.
- API não tem `date_time` — tem `DateTime`.

---

## 5. Análise do Capítulo 4 (Implementação) — Acertos e Erros

### ✅ Acertos

1. **Arquitetura exclusivamente GraphQL** — correto. A tese afirma corretamente que não há API REST para CRUD, auth, ou admin.
2. **Pipeline de middleware** — correto. A descrição dos 8 estágios corresponde ao `Program.cs`.
3. **Registro de serviços** — correto. `AddPooledDbContextFactory`, `CollectionTypeModule`, `AbacService` scoped, etc.
4. **Modelo de entidades** — correto. `Entry` com `JsonDocument Data`, `EntryRelation`, etc.
5. **Funções de banco JSONB** — correto. `CmsDbFunctions` e tradução LINQ-to-SQL.
6. **Autenticação GraphQL** — correto. Mutations `auth.login`, `auth.refresh`, etc.
7. **JWT RS256** — correto. Claims, `ClockSkew = TimeSpan.Zero`, `sub` = sessionId.
8. **Refresh tokens single-use** — correto.
9. **ABAC em 3 níveis** — correto. Inline checks, `[AbacRequirePermission]`, `[UseAbacRowCheck]`.
10. **Motor ABAC formal** — correto. Modelo matemático, deny-overrides, PDP/PIP/PEP.
11. **Cache em PostgreSQL** — correto. SHA256 checksum, invalidação lazy por `PolicyVersions`, TTL diferenciado.
12. **Argon2id** — correto. Parâmetros OWASP 2023 e fallback SHA256.
13. **Rate limiting** — correto. Três tiers com valores exatos.
14. **Headers de segurança** — correto.
15. **Modelo de ameaças** — correto e bem estruturado.

### ❌ Erros ou Imprecisões

1. **Referência a commits fixos** — a tese menciona commits (`935083f`, `505bdc9`) e caminhos (`/tmp/techtoniccms-api/`). Isso é frágil e pode ficar desatualizado.
2. **Tabela de stack tecnológico** — contém versões específicas que podem mudar. Recomenda-se mover para um apêndice ou usar linguagem atemporal.
3. **Menciona `BenchmarkDotNet` e `K6`** — são mencionados mas os resultados dos benchmarks não aparecem no texto visível da tese.
4. **"Apêndice A"** — mencionado como contendo o diagrama ER completo, mas não está visível no texto da tese analisado.

---

## 6. Recomendações por Capítulo

### Capítulo 2 (Referencial Teórico)

✅ **FINALIZADO em 2026-05-04** — Todas as referências teóricas foram adicionadas e o capítulo foi reorganizado por domínio de conhecimento.

**Ações realizadas:**
1. ✅ **Agendamento de tarefas** — subseção "Agendamento e Processamento Assíncrono" em 2.5, com citação `@prakash2016performance`.
2. ✅ **Autenticação por API Key** — subseção "Autenticação e Autorização em APIs" em 2.3, com citações `@rfc6750` e `@habib2025gateway`.
3. ✅ **Rate Limiting** — subseção "Rate Limiting e Controle de Tráfego" em 2.3, com citações `@rfc6585` e `@serbout2023patterns`.
4. ✅ **Password Hashing (Argon2id)** — subseção "Armazenamento Seguro de Credenciais" em 2.4, com citações `@biryukov2015argon2` e `@owasp2023argon2`.
5. ✅ **Redis / Cache em memória** — subseção "Cache em Memória para Sessões" em 2.4, com citação `@redis2024docs`.
6. ✅ **Referências adicionadas ao `refs.yml`:** `prakash2016performance`, `rfc6750`, `habib2025gateway`, `rfc6585`, `serbout2023patterns`, `ms2024expressiontrees`, `nagel2014codegen`, `schiavio2023dynq`.
7. ✅ **Reorganização do capítulo** — eliminada a seção genérica "Conceitos Técnicos Fundamentais"; conteúdo distribuído em seções temáticas: 2.3 APIs e Protocolos, 2.4 Segurança e Acesso, 2.5 Modelagem de Dados.

**Pendências menores (não críticas para o Cap. 2):**
- `batra2016eav` vs. "Batra et al., 2017" — inconsistência de ano a ser verificada.
- Atribuição da figura EAV: "Dinu e Nadkarni (2007)" vs. referência `nadkarni2007eav`.

### Capítulo 3 (Conceito e Design)

**Reescrever para ser atemporal e consistente com a API:**
1. **Remover menções a tecnologias específicas** (Hot Chocolate 14+, PostgreSQL 15+, Redis 7+, etc.) — estas vão para o capítulo 4.
2. **Adicionar seção sobre Agendamento de Conteúdo** — descrever `EntrySchedules` e estados de transição.
3. **Adicionar seção sobre Autenticação** — descrever os dois mecanismos (sessão JWT + API Key) como abstrações, não tecnologias.
4. **Corrigir entidade `Field`** — remover `sensitivityLevel`, `isPii`, `isPublic` ou implementá-los na API.
5. **Corrigir tipos de campo** — alinhar com `FieldDataType` da API: `Text`, `Boolean`, `Number`, `DateTime`, `Relation`, `Asset`, `Object`.
6. **Corrigir `PermissionAction`** — alinhar com a API.
7. **Corrigir descrição do cache** — o cache ABAC é persistente (banco), não "em memória". Sessões é que são em memória (Redis).
8. **Remover duplicação** com capítulo 4. O capítulo 3 deve focar em *o que* o sistema faz e *por que*, não *como*.
9. **Adicionar `entry_schedules` e `api_keys`** aos diagramas ER.
10. **Revisar enum `ScopeType`** — se não é usado, remover da tese. Se é usado, documentar.

### Capítulo 4 (Implementação)

**Ajustes menores:**
1. **Mover tabela de stack tecnológico** para apêndice ou introduzir com linguagem mais atemporal.
2. **Adicionar resultados de benchmarks** se existirem, ou remover menção a eles.
3. **Adicionar Apêndice A** com diagrama ER completo (se não existir).
4. **Evitar referências a commits/caminhos fixos** — usar linguagem genérica ("o repositório da API").

---

## 7. Lista de Verificação para Sincronização

### Entidades da API (17 tabelas)
- [x] `users` — documentado
- [x] `roles` — documentado
- [x] `user_roles` — documentado
- [x] `abac_policies` — documentado
- [x] `abac_policy_rules` — documentado
- [x] `role_policies` — documentado
- [x] `user_policies` — documentado
- [x] `resource_ownerships` — documentado
- [x] `abac_evaluation_cache` — documentado (mas descrição do cache está incorreta)
- [x] `abac_audit` — documentado
- [x] `collections` — documentado
- [x] `fields` — documentado (mas com atributos inexistentes: `sensitivityLevel`, `isPii`, `isPublic`)
- [x] `entries` — documentado
- [x] `entry_relations` — documentado
- [ ] `entry_schedules` — **NÃO documentado**
- [x] `assets` — documentado
- [ ] `api_keys` — **NÃO documentado**

### Enums da API (12 enums PostgreSQL)
- [x] `UserStatus` — documentado (`ACTIVE`, `INACTIVE`, `BANNED`)
- [x] `PermissionAction` — documentado (mas com valores desatualizados)
- [x] `BaseResource` — documentado
- [x] `PermissionEffect` — documentado
- [x] `AttributePath` — documentado
- [x] `OperatorType` — documentado
- [x] `ValueType` — documentado
- [x] `LogicalOperator` — documentado
- [x] `EntryStatus` — documentado
- [x] `Locale` — documentado
- [x] `FieldDataType` — documentado (mas com valores desatualizados)
- [x] `ScheduledAction` — parcialmente documentado (não há seção dedicada)
- [ ] `ScopeType` — documentado na API mas **não usado visivelmente**; confusão na tese

### Serviços da API
- [x] `AbacService` — documentado em detalhe
- [x] `AuthService` — documentado
- [x] `SessionService` — documentado
- [x] `PasswordService` — documentado
- [x] `S3Service` — mencionado
- [x] `ApiKeyService` — **NÃO documentado**
- [ ] `SchedulerService` — **NÃO documentado**
- [x] `RedisService` — mencionado
- [x] `CollectionTypeModule` — documentado
- [x] `AdminBootstrapService` — mencionado
- [x] `PolicyBootstrapService` — mencionado
- [x] `RoleBootstrapService` — mencionado

---

## 8. Conclusão

A tese está **funcionalmente descritiva** mas **tecnicamente desincronizada** em três áreas principais:

1. **Omissões significativas:** `entry_schedules`, `api_keys`, `SchedulerService`, e rate limiting não têm representação no design.
2. **Inconsistências de schema:** Atributos de `Field` (`sensitivityLevel`, `isPii`, `isPublic`) são descritos na tese mas não implementados na API. Enums (`PermissionAction`, `FieldDataType`) têm valores diferentes.
3. **Falta de fundamentação teórica:** Conceitos como agendamento, API keys, rate limiting, e Argon2 não são fundamentados no referencial teórico.

O **Capítulo 4 é o mais alinhado** com a API. O **Capítulo 3 precisa de reescrita significativa** para remover duplicações, corrigir inconsistências, e adotar uma linguagem atemporal focada em conceitos em vez de tecnologias.
