#import "@preview/mmdr:0.2.2": mermaid

#pagebreak()

= Implementação

Este capítulo apresenta a realização concreta do sistema TechtonicCMS, articulando as decisões de design do Capítulo 3 com o código-fonte de produção. Todas as referências são aos arquivos do repositório API (`/tmp/techtoniccms-api/`, commit `935083f`) e App (`techtoniccms-app/`, commit `505bdc9`). O foco recai sobre a camada API — a interface GraphQL que constitui o contrato externo primário do sistema — pois é onde as contribuições deste trabalho (geração dinâmica de schemas e autorização ABAC) se manifestam em código de produção.

Uma decisão arquitetural fundamental que permeia toda a implementação é a ausência de API REST para operações de conteúdo, autenticação e autorização. O sistema é *exclusivamente GraphQL*: todas as operações de CRUD, autenticação, gerenciamento de sessões e administração de políticas transitam pelo endpoint `/graphql`. Os únicos endpoints não-GraphQL são quatro rotas auxiliares mapeadas via `app.MapPost`/`app.MapGet`: upload de assets (`POST /assets/upload`), download de assets (`GET /assets/{id}`), documentação de schema (`GET /llms.md`) e health check (`GET /healthcheck`).

== Stack Tecnológico

A #linebreak() escolha das tecnologias seguiu o princípio de adequação às restrições do problema: tipagem estática para correção em schemas dinâmicos, banco relacional com suporte nativo a JSON para armazenamento híbrido, e cache em memória para sessões e decisões ABAC.

#table(
  columns: 4,
  [*Domínio*], [*Tecnologia*], [*Versão*], [*Função*],
  [Runtime], [.NET], [10], [Plataforma de hospedagem],
  [GraphQL], [Hot Chocolate], [14+], [Motor de schema, sistema de tipos, resolvers],
  [ORM], [Entity Framework Core], [9+], [Acesso a dados, migrations, mapeamento JSONB],
  [Banco de Dados], [PostgreSQL], [15+], [Store relacional, JSONB, enums nativos],
  [Cache / Sessões], [Redis], [7+], [Armazenamento de sessões, tokens de refresh],
  [Armazenamento Binário], [S3-compatível (MinIO)], [—], [Persistência de assets],
  [Autenticação], [JWT RSA (RS256)], [—], [Tokens de acesso + refresh],
  [Hash de Senha], [Argon2id + SHA256 fallback], [—], [Migração transparente de hashes legados],
  [Benchmarks], [BenchmarkDotNet], [0.14+], [Micro-benchmarks],
  [Teste de Carga], [K6], [—], [Testes HTTP de throughput]
)

A interface administrativa é implementada em SvelteKit com TypeScript, Tailwind CSS v4 e shadcn-svelte. O GraphQL Code Generator produz documentos tipados a partir do schema dinâmico. O caso de uso consumidor (blog) utiliza Astro com server-side rendering e um content loader customizado.

== Bootstrap da Aplicação e Pipeline de Middleware

=== Registro de Serviços

O ponto de entrada `Program.cs` configura o contêiner de DI do ASP.NET Core e o pipeline de middleware:

```csharp
var builder = WebApplication.CreateBuilder(args);

// Fábrica de DbContext (pooled)
builder.Services.AddPooledDbContextFactory<TechtonicCmsDbContext>(
    options => options.UseNpgsql(connectionString));

// Redis e serviços singleton
builder.Services.AddSingleton<RedisService>();
builder.Services.AddSingleton<CollectionTypeModule>();
builder.Services.AddScoped<SessionService>();

// Serviços de autenticação (scoped)
builder.Services.AddScoped<PasswordService>();
builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<AbacService>();
builder.Services.AddScoped<S3Service>();
builder.Services.AddScoped<ApiKeyService>();

// Servidor GraphQL
builder.AddGraphQL()
    .DisableIntrospection(false)
    .ModifyCostOptions(options => {
        options.MaxFieldCost = 20000;
        options.MaxTypeCost = 1000;
    })
    .AddMaxExecutionDepthRule(15)
    .AddAuthorization()
    .AddProjections()
    .AddFiltering()
    .AddSorting()
    .AddPagingArguments()
    .ModifyOptions(o => { o.EnableOneOf = true; })
    .ModifyRequestOptions(options => {
        options.IncludeExceptionDetails = builder.Environment.IsDevelopment();
    })
    .AddTypeModule<CollectionTypeModule>()
    .TryAddTypeInterceptor<CollectionConnectionTypeInterceptor>()
    .AddTypes();

// Handler de autorização ABAC
builder.Services.AddScoped<
    Microsoft.AspNetCore.Authorization.IAuthorizationHandler,
    AbacAuthorizationHandler>();

builder.Services.AddHttpContextAccessor();
builder.Services.AddHostedService<SchedulerService>();
```

Decisões arquiteturais notáveis: `AddPooledDbContextFactory` fornece instâncias pooled de `DbContext`; `CollectionTypeModule` é registrado via `AddTypeModule`, ponto de extensão do Hot Chocolate para registro dinâmico de tipos; `AbacService` é scoped pois recebe `TechtonicCmsDbContext` diretamente; `MaxExecutionDepthRule(15)` previne negação de serviço por queries profundamente aninhadas; `ModifyCostOptions` estabelece limites de complexidade de query (custo máximo de campo 20.000, custo máximo de tipo 1.000).

=== Pipeline de Middleware e Fluxo de Requisição

```csharp
var app = builder.Build();

using (var scope = app.Services.CreateScope()) {
    var dbContext = scope.ServiceProvider
        .GetRequiredService<TechtonicCmsDbContext>();
    dbContext.Database.Migrate();
    // ... bootstrap seeding
}

app.UseSecurityHeaders();
app.UseRateLimiter();
app.UseAuthentication();
app.UseAuthorization();

app.MapAssetEndpoints();
app.MapLlmsEndpoints();
app.MapGraphQL().RequireRateLimiting("GeneralApi");
app.MapGet("/healthcheck", () => Results.Ok("healthy"));

app.RunWithGraphQLCommands(args);
```

O fluxo de requisição GraphQL segue oito estágios: (1) recepção HTTP pelo ASP.NET Core; (2) adição de headers de segurança; (3) rate limiting (`GeneralApi`: 1.000 req/min, `Login`: 10 req/min); (4) autenticação via scheme `MultiAuth` que encaminha para `JwtBearer` ou `ApiKey`; (5) validação de sessão JWT contra Redis; (6) autorização via `[Authorize]` e políticas ASP.NET Core; (7) execução GraphQL por Hot Chocolate; (8) avaliação ABAC dentro dos resolvers.

== Camada de Banco de Dados

=== DbContext e Modelo de Entidades

O `TechtonicCmsDbContext` (`Contexts/TechtonicCmsDbContext.cs`) configura o EF Core com enums nativos do PostgreSQL, funções de banco para extração JSONB, e comportamentos de soft-delete.

O sistema utiliza 17 tabelas com 12 enums nativos do PostgreSQL. O schema completo encontra-se no diagrama ER (Apêndice A), gerado a partir das anotações `[Table]`, `[Column]`, `[Index]` e `[ForeignKey]` das classes de entidade. O mapeamento é direto: C\# enums são traduzidos para `CREATE TYPE` do PostgreSQL via `modelBuilder.HasPostgresEnum<T>()`, conferindo type safety a nível de banco.

=== Armazenamento JSONB e Tradução de Queries

A entidade `Entry` armazena conteúdo dinâmico em uma única coluna `jsonb`:

```csharp
public class Entry {
    [Key] public required Guid Id { get; set; }
    public required Guid CollectionId { get; set; }
    public required string Name { get; set; } = null!;
    public string? Slug { get; set; }
    public required EntryStatus Status { get; set; }
    public required Locale Locale { get; set; }
    public required Locale DefaultLocale { get; set; }
    public required Guid CreatedBy { get; set; }
    public required DateTime CreatedAt { get; set; }
    public required DateTime UpdatedAt { get; set; }
    public DateTime? PublishedAt { get; set; }
    public required JsonDocument Data { get; set; }  // JSONB
    public ICollection<EntryRelation> FromRelations { get; set; } = [];
    public ICollection<EntryRelation> ToRelations { get; set; } = [];
}
```

A propriedade `Data` é `JsonDocument`, serializando para PostgreSQL `jsonb`. Todos os valores de campos dinâmicos — texto, números, booleanos, datas, objetos — residem nesta coluna. A tabela `Field` define quais campos existem para cada coleção e seus tipos, mas os valores concretos habitam `Entry.Data`.

Para permitir filtragem e ordenação a nível de banco em campos dinâmicos, o sistema registra funções de banco mapeadas para stored procedures PostgreSQL:

```csharp
public static class CmsDbFunctions {
    public static string? CmsExtractText(JsonDocument data, string fieldName)
        => throw new NotSupportedException();
    public static bool? CmsExtractBoolean(JsonDocument data, string fieldName)
        => throw new NotSupportedException();
    public static double? CmsExtractNumber(JsonDocument data, string fieldName)
        => throw new NotSupportedException();
    public static DateTime? CmsExtractDateTime(JsonDocument data, string fieldName)
        => throw new NotSupportedException();
}
```

Quando a query LINQ `CmsDbFunctions.CmsExtractText(e.Data, "title") == "Hello"` é traduzida para SQL, torna-se `WHERE cms_extract_text(e."Data", 'title') = 'Hello'`. Isso permite filtragem em campos dinâmicos no banco, sem carregar todas as entradas em memória. O caminho de tradução é: árvore de expressões LINQ → pipeline EF Core → tradução PostgreSQL → execução com possível índice GIN.

=== Relacionamentos entre Entradas

Relacionamentos entre entradas utilizam tabela de junção com restrição de unicidade por campo:

```csharp
modelBuilder.Entity<EntryRelation>(e => {
    e.HasIndex(r => new { r.EntryId, r.FieldId }).IsUnique();
    e.HasOne(r => r.Entry)
        .WithMany(en => en.FromRelations)
        .HasForeignKey(r => r.EntryId)
        .OnDelete(DeleteBehavior.Cascade);
    e.HasOne(r => r.TargetEntry)
        .WithMany(en => en.ToRelations)
        .HasForeignKey(r => r.TargetEntryId)
        .OnDelete(DeleteBehavior.Cascade);
});
```

O índice único em `(EntryId, FieldId)` impõe que cada campo em uma entrada tenha no máximo um alvo de relacionamento. Essa decisão simplifica o sistema de tipos GraphQL: um campo de relacionamento retorna uma única entrada relacionada, não uma lista.

== API GraphQL

A API GraphQL é a interface exclusiva de conteúdo e autenticação. Todas as operações — CRUD de conteúdo, autenticação, gerenciamento de autorização, metadados de assets — transitam pelo endpoint `/graphql`.

=== Arquitetura do Sistema de Tipos Hot Chocolate

O Hot Chocolate 14+ implementa um pipeline de três fases: (1) *Discovery* — módulos `ITypeModule` (como `CollectionTypeModule`) são invocados via `RegisterTypesAsync()`, retornando instâncias `TypeSystemObjectBase`; (2) *Completion* — tipos descobertos são completados, campos resolvidos, referências ligadas; (3) *Merge* — tipos completados são fundidos em `ISchema`, cacheada por `IRequestExecutorResolver`.

O `CollectionTypeModule` implementa `TypeModule`, ponto de extensão para registro dinâmico de tipos em tempo de execução. Diferentemente de definições estáticas (classes C\# com `[ObjectType]`), o módulo constrói tipos dinamicamente a partir de metadados do banco de dados.

=== Pipeline de Geração de Schema

A geração de schema em tempo de execução é implementada em `CollectionTypeModule.cs`. O módulo utiliza `ObjectType.CreateUnsafe` e objetos `ObjectTypeDefinition` brutos, pois os tipos não são conhecidos em tempo de compilação.

Para cada coleção no banco de dados, o módulo executa um algoritmo de geração com complexidade $O(n dot m)$, onde $n$ é o número de coleções e $m$ é o número médio de campos por coleção. O processo constrói: (1) mapa de tipos `ToPascalCase(slug)` → nome de tipo; (2) definição de tipo de dados com campos escalares (resolvers de dicionário) e relacionamentos (resolvers de banco); (3) definição de tipo de entrada com campos estáticos (`id`, `name`, `slug`, `status`, `data`); (4) campos de query com resolvers `IQueryable<Entry>`; (5) definições de input para filtros e ordenação; (6) mutations para create, update, delete, publish, unpublish, archive, restore.

O tipo de dados usa `Dictionary<string, object>` como tipo runtime. Quando o resolver do campo `data` executa, desserializa o JSONB em dicionário e o injeta como objeto pai. Campos escalares resolvem via lookup no dicionário; campos de relacionamento executam query na tabela `EntryRelations`. A injeção de `__entryId` é uma decisão crítica: torna o ID da entrada disponível a resolvers aninhados de relacionamento, que precisam dele para consultar `EntryRelations`.

#figure(
  mermaid("classDiagram\n    class AbacService {\n        +CheckPermissionAsync(userId, resource, action, resourceData) bool\n        +RequirePermissionAsync(userId, resource, action, resourceData) void\n        +IsRestrictedToOwnResourcesAsync(userId, resource, action) bool\n        -GetApplicablePoliciesAsync(userId, resource, action) List~AbacPolicy~\n        -EvaluatePolicyRulesAsync(policy, context) bool\n        -LookupCacheAsync(userId, resource, resourceId, action) bool?\n        -WriteCacheAsync(...) void\n        -WriteAuditAsync(...) void\n    }\n\n    class AuthService {\n        +GenerateAccessTokenAsync(userId, name, status) (string, string)\n        +GenerateRefreshTokenAsync(userId, sessionId) string\n        +ValidateAccessToken(token) ClaimsPrincipal\n        +ValidateRefreshToken(token) ClaimsPrincipal\n    }\n\n    class SessionService {\n        +CreateSessionAsync(sessionId, userId, name, status) SessionData\n        +GetSessionAsync(sessionId) SessionData?\n        +DeleteSessionAsync(sessionId, userId) void\n        +DeleteAllUserSessionsAsync(userId) void\n    }\n\n    class PasswordService {\n        +HashPassword(password) string\n        +VerifyPassword(password, existingHash) (bool, string?)\n        +ValidatePasswordStrength(password) void\n    }\n\n    class CollectionTypeModule {\n        +RegisterTypesAsync(context, cancellationToken) IEnumerable~TypeSystemObjectBase~\n        -BuildCollectionTypeMap(collections) Dictionary\n        -BuildQueryTypesAsync(...) void\n        -BuildMutationTypes(collections, types) void\n    }\n\n    class CollectionConnectionTypeInterceptor {\n        +OnAfterCompleteType(context, definition) void\n        -BuildConnectionTypes(...) (ObjectTypeDefinition, ObjectTypeDefinition)\n    }\n\n    AbacService --> AuthService : uses for identity\n    AuthService --> SessionService : manages sessions\n    CollectionTypeModule --> CollectionConnectionTypeInterceptor : coordinates\n"),
  caption: [Diagrama de classes — serviços core do TechtonicCMS]
) <fig-class-diagram>

#align(left)[#text(size: 10pt)[Fonte: Criação do autor.]]

=== Autenticação via GraphQL

Todas as operações de autenticação são mutations e queries GraphQL. Não existem endpoints REST de autenticação.

As mutations de autenticação (`Types/Auth/AuthMutations.cs`) expõem: `login(name, password)`, `refresh(refreshToken)`, `logout`, `logoutAll`. O fluxo de login realiza: busca do usuário por nome; verificação de senha via Argon2id (ou SHA256 para hashes legados, com migração transparente); validação de status (`Inactive` ou `Banned` causam revogação de todas as sessões e erro); geração de token de acesso JWT (RS256, TTL 15 minutos) com `sub` = sessionId; geração de token de refresh (TTL 30 dias); criação de sessão no Redis.

Tokens de acesso usam RS256 (RSA + SHA256). A estrutura JWT segue a RFC 7519, com claims: `sub` (session ID, não user ID — permitindo revogação per-session), `userId`, `name`, `status`, `iss`, `aud`, `iat`, `exp`, `jti`. O `ClockSkew = TimeSpan.Zero` na validação assegura que tokens expiram exatamente no tempo `exp`, sem tolerância.

Tokens de refresh possuem a mesma estrutura com claim adicional `type: "refresh"`. São armazenados no Redis com TTL de 30 dias e são *single-use*: ao serem utilizados, são imediatamente deletados e substituídos por um novo, prevenindo ataques de replay.

Sessões são armazenadas no Redis com dois padrões de chave: `session:{sessionId}` (string serializada com TTL 15 min) e `user:sessions:{userId}` (set Redis com todos os IDs de sessão ativos). As operações `CreateSessionAsync` e `DeleteSessionAsync` usam `IDatabase.CreateBatch()` para atomicidade de multi-key.

=== Integração ABAC nos Resolvers

A autorização ABAC opera em três níveis: (1) *Checks inline* — resolvers chamam `AbacService.RequirePermissionAsync` com contexto de recurso; (2) *Atributos declarativos* — `[AbacRequirePermission]` realiza verificação coarse-grained antes da execução do resolver; (3) *Filtragem row-level* — `[UseAbacRowCheck]` intercepta o resultado do resolver e injeta cláusula `Where` via árvore de expressões.

A construção AST para row-level filtering usa reflection e expression trees: `Expression.Parameter(entityType, "x")` cria parâmetro; `Expression.Property(param, "CreatedBy")` acessa propriedade; `Expression.Constant(userId)` cria constante; `Expression.Equal` compara; `Expression.Lambda` fecha; `Queryable.Where<T>(queryable, lambda)` aplica. O EF Core traduz para SQL `WHERE "CreatedBy" = 'user-id'`.

=== Execução de Query e Tradução LINQ-to-SQL

Uma query GraphQL completa flui por múltiplas camadas de transformação antes de tornar-se SQL. Considerando:

```graphql
query {
  collections {
    entries {
      blogPosts(where: { data: { title: { eq: "Hello" } } }, first: 10) {
        edges { node { id name data { title } } }
      }
    }
  }
}
```

O pipeline: (1) documento GraphQL → AST Hot Chocolate; (2) validação de schema; (3) execução do resolver `blogPosts` retornando `IQueryable<Entry>`; (4) filtro row-level via `[UseAbacRowCheck]` se restrito; (5) filtro de coleção `Where(e => e.CollectionId == id)`; (6) `UseFiltering` parseia `where` e compõe `CmsDbFunctions.CmsExtractText(e.Data, "title") == "Hello"`; (7) `UseSorting` compõe `OrderBy`; (8) `UsePaging` compõe `Skip`/`Take`; (9) EF Core traduz a query composta para SQL único; (10) Hot Chocolate monta a conexão com `edges`, `nodes` e `pageInfo`.

A propriedade fundamental é que todo o pipeline (autorização, filtragem, ordenação, paginação) é expresso como query LINQ única composta, traduzida para SQL único. Nenhum dado é materializado em memória até a projeção final.

== Motor ABAC

O motor ABAC (`Services/AbacService.cs`, ~700 linhas) implementa a arquitetura NIST SP 800-162 com quatro componentes: PAP, PDP, PIP e PEP, conforme o modelo formal descrito no Capítulo 3.

=== Policy Information Point (PIP)

O método `BuildContextAsync` coleta atributos de múltiplas fontes: claims do token (ID, nome, status); roles do usuário via join `user_roles` + `roles` com expiração; contexto HTTP (IP, user-agent); e atributos do recurso passados pelo resolver. O contexto resultante é um dicionário flat de pares atributo-valor.

=== Policy Decision Point (PDP)

O algoritmo `CheckPermissionAsync` executa em seis fases: (1) resolve ID do recurso; (2) consulta cache (query indexada em `(UserId, ResourceType, ResourceId, ActionType)`); (3) se cache miss, busca políticas aplicáveis (via roles do usuário e políticas diretas); (4) ordena deny policies por prioridade descendente e avalia — match em deny policy causa negação imediata; (5) se não houver deny, ordena allow policies e avalia — match causa permissão; (6) se nenhuma allow policy corresponder, nega por padrão. Cada decisão é auditada com timestamp, contexto, políticas avaliadas, justificativa e métrica de tempo.

A complexidade temporal sem cache é $O(p dot q)$, onde $p$ é o número de políticas aplicáveis e $q$ é o número médio de regras por política. Com cache hit: $O(1)$.

=== Cache de Avaliação em Banco de Dados

O cache é persistido em PostgreSQL (tabela `abac_evaluation_cache`), não em memória, possibilitando persistência across restarts e compartilhamento entre réplicas da API. A chave de cache é hash SHA256 determinístico do contexto: $text{"cacheKey"} = text{"SHA256"}(text{"userId"} : text{"resourceType"} : text{"resourceId"} : text{"action"})$.

A invalidação de cache utiliza a estratégia *lazy* via campo `PolicyVersions`: string concatenando pares `(PolicyId:UpdatedAt)` de todas as políticas contribuintes. Quando uma política é modificada, seu `UpdatedAt` muda, a string `currentVersions` deixa de corresponder a `cached.PolicyVersions`, e a entrada é descartada na próxima leitura. TTL diferenciado: 5 minutos para decisões Allow, 2 minutos para Deny.

=== Auditoria

Toda decisão de autorização é persistida em `abac_audit`. O schema de auditoria inclui: usuário, recurso, ação, decisão, políticas avaliadas, políticas correspondentes, justificativa, tempo de avaliação em ms, contexto completo serializado como JSON, IP, user-agent e timestamp. A operação de escrita de auditoria está envolta em `try/catch`: falhas de auditoria nunca bloqueiam a decisão de autorização.

=== Probe de Filtragem Row-Level

`IsRestrictedToOwnResourcesAsync` determina se filtragem é necessária criando um recurso sintético com owner ID aleatório e avaliando `CheckPermissionAsync`. Se o veredicto for `false`, o usuário está restrito a recursos próprios; se `true`, tem acesso irrestrito.

== Segurança

=== Headers de Segurança

`SecurityHeadersMiddleware` adiciona: `X-Content-Type-Options: nosniff` (prevenção de MIME sniffing); `X-Frame-Options: DENY` (prevenção de clickjacking); `Referrer-Policy: strict-origin-when-cross-origin` (limitação de vazamento de referrer); `Strict-Transport-Security: max-age=31536000; includeSubDomains; preload` (forçamento de HTTPS).

=== Armazenamento e Hash de Senha

`PasswordService` utiliza Argon2id com parâmetros OWASP 2023: tipo `DataIndependentAddressing` (Argon2id), versão 0x13, `TimeCost = 3`, `MemoryCost = 65536` (64 MB), `Lanes = 4`, `Threads = 4`, `HashLength = 32`, salt de 16 bytes via `RandomNumberGenerator.GetBytes(16)`. A verificação retorna `(isValid, newHash)`: se o hash armazenado for SHA256 legado (64 hex chars), `newHash` conterá o hash Argon2id para migração transparente.

Validação de força de senha exige mínimo 12 caracteres, excedendo recomendações NIST SP 800-63B (8 caracteres) e alinhando-se a práticas modernas.

=== Rate Limiting

Três tiers: Login (janela fixa, 10 req/min, fila 0), Upload (token bucket, 10 tokens, 5/min refill, fila 0), General API (janela fixa, 1000 req/min, fila 0). `QueueLimit = 0` garante rejeição imediata com 429, prevenindo exaustão de recursos por requests enfileirados.

=== Modelo de Ameaças

#table(
  columns: 3,
  [*Ameaça*], [*Mitigação*], [*Implementação*],
  [Credential stuffing], [Rate limiting + Argon2id], [10 tentativas/min; 64MB memory cost],
  [Sequestro de sessão], [TTL curto + revogação per-session], [Tokens 15min; sessões em Redis com revogação instantânea],
  [Replay de token], [Refresh tokens single-use], [Deletado após primeiro uso],
  [Injeção SQL], [Queries parametrizadas], [Todas as queries via EF Core],
  [ReDoS], [Timeout em regex], [1 segundo em todas as avaliações regex],
  [DoS por complexidade de query], [Limite de profundidade + análise de custo], [Max depth 15; max field cost 20.000],
  [Clickjacking], [X-Frame-Options], [DENY em todas as respostas],
  [MIME sniffing], [X-Content-Type-Options], [nosniff em todas as respostas],
  [Man-in-the-middle], [HSTS], [max-age 1 ano com preload],
  [Ameaça interna], [Auditoria ABAC completa], [Toda decisão logada com contexto],
  [Exposição de API key], [Armazenamento hash-only], [Apenas SHA256 armazenado; prefixo para identificação]
)

== Frontend

A interface administrativa (`techtoniccms-app/`) é SvelteKit com TypeScript. Funções `load` server-side utilizam wrapper `query()` com GraphQL Client. O módulo `permissions.ts` espelha a lógica ABAC do servidor para gating de UI: `canManagePolicies` verifica roles e políticas do usuário. O componente `entry-editor.svelte` renderiza formulários dinamicamente a partir das definições de campos da coleção: `Text` → `Input`, `Boolean` → `Switch`, `Number` → `Input type="number"`, `DateTime` → `DatePicker`, `Relation` → `RelationPicker`, `Asset` → `AssetUploader`.

== Caso de Uso: Blog

O blog (`techtoniccms-blog/`) é Astro SSR. O `techtonicPostsLoader` implementa `LiveLoader` do Astro, consumindo a API GraphQL com autenticação via API Key (`X-Api-Key`). O proxy de assets (`/assets/{id}`) adiciona headers `Cache-Control: public, max-age=3600, immutable`.

== Benchmarks

O arquivo `Benchmarks.cs` implementa cinco benchmarks BenchmarkDotNet: (1) cache hit vs. miss; (2) escalabilidade por contagem de políticas (1, 5, 10, 25, 50); (3) overhead de filtro row-level (baseline vs. unrestricted vs. restricted); (4) tempo de decisão deny vs. allow; (5) custo de auditoria. O script K6 `schema-generation-benchmark.js` mede performance HTTP com estágios de carga (10→50 usuários concorrentes) e thresholds `p(95)<500ms`.

== DevOps e Deployment

O Dockerfile usa multi-stage build com usuário non-root (UID 10001, conforme CIS Docker Benchmark v1.6.0). O bootstrap de startup executa `Database.Migrate()` e seeding via `AdminBootstrapService`, `PolicyBootstrapService` e `RoleBootstrapService`.
