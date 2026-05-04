# Chapter 4 — Implementation

This chapter bridges the architecture described in Chapter 3 with the concrete source code that realizes it. All references are to files in the TechtonicCMS API (`/tmp/techtoniccms-api/`, commit `935083f`) and the App (`techtoniccms-app/`, commit `505bdc9`). Where code excerpts are presented, they are drawn directly from the implementation. The focus is the API layer—the GraphQL interface that constitutes the system's primary external contract—since this is where the thesis contributions (dynamic schema generation and ABAC authorization) manifest in production code.

The system is **exclusively GraphQL** for all content, authentication, and authorization operations. The only non-GraphQL endpoints are minimal: asset upload/download (binary data), an auto-generated schema documentation endpoint, and a health check. There is no REST API for content management, CRUD, or authentication.

## 4.1 Technology Stack

| Concern | Technology | Version | Role |
|---------|-----------|---------|------|
| Runtime | .NET | 10 | Host platform |
| GraphQL | Hot Chocolate | 14+ | Schema engine, type system, resolvers |
| ORM | Entity Framework Core | 9+ | Database access, migrations, JSONB mapping |
| Database | PostgreSQL | 15+ | Relational store, JSONB, native enums |
| Cache / Sessions | Redis | 7+ | Session storage, refresh tokens |
| Storage | S3-compatible (MinIO) | — | Binary asset storage |
| Auth | RSA JWT (RS256) | — | Access + refresh tokens |
| Password Hashing | Argon2id + SHA256 fallback | — | Legacy migration support |
| Benchmarking | BenchmarkDotNet | 0.14+ | Micro-benchmarks |
| Load Testing | K6 | — | HTTP-level throughput tests |

The frontend administrative interface is SvelteKit with TypeScript, Tailwind CSS v4, and shadcn-svelte. GraphQL Code Generator produces typed documents from the live schema. The consumer use case (blog) is Astro with server-side rendering and a custom content loader.

## 4.2 Application Bootstrap and Middleware Pipeline

### 4.2.1 Service Registration

The entry point `Program.cs` configures the ASP.NET Core DI container and pipeline:

```csharp
// Excerpt from Program.cs
var builder = WebApplication.CreateBuilder(args);

// Database factory (per-request instances, not pooled)
builder.Services.AddDbContextFactory<TechtonicCmsDbContext>(
    options => options.UseNpgsql(connectionString)
        .UseQueryTrackingBehavior(QueryTrackingBehavior.NoTracking)
        .EnableSensitiveDataLogging(builder.Environment.IsDevelopment()));

// Redis
builder.Services.AddSingleton<RedisService>();
builder.Services.AddSingleton<SessionService>();

// GraphQL server
builder.Services.AddGraphQLServer()
    .AddQueryType<Query>()
    .AddMutationType<Mutation>()
    .AddAuthorization()
    .AddProjections()
    .AddFiltering()
    .AddSorting()
    .AddTypeModule<CollectionTypeModule>()
    .AddErrorFilter<CustomErrorFilter>();

// ABAC services
builder.Services.AddSingleton<AbacService>();

// Auth services
builder.Services.AddSingleton<AuthService>();
builder.Services.AddSingleton<SessionService>();
builder.Services.AddScoped<PasswordService>();
builder.Services.AddScoped<S3Service>();

// Security
builder.Services.AddSingleton<IAuthorizationHandler, AbacAuthorizationHandler>();
builder.Services.AddHttpContextAccessor();

// Rate limiting
builder.Services.AddRateLimiter(options => { ... });
```

**Key architectural decisions:**
- `AddDbContextFactory` (not pooled) provides per-request `DbContext` instances. GraphQL resolvers create contexts as needed rather than sharing a pooled instance.
- `CollectionTypeModule` is registered via `AddTypeModule`—a Hot Chocolate extension point for runtime type registration.
- `AbacService` is a singleton because it maintains no request-scoped state; it receives `IDbContextFactory` to create contexts on demand.
- `PasswordService` is scoped because it encapsulates per-request configuration.

### 4.2.2 Middleware Pipeline

```csharp
var app = builder.Build();

app.UseSecurityHeaders();
app.UseCors();
app.UseRateLimiter();
app.UseAuthentication();
app.UseAuthorization();
app.UseAbacMiddleware();

app.MapGraphQL();
app.MapAssetEndpoints();
app.MapLlmsEndpoints();
app.MapHealthChecks("/healthcheck");
```

**Request flow for GraphQL:**
1. `UseSecurityHeaders` — adds HSTS, X-Frame-Options, Referrer-Policy, X-Content-Type-Options
2. `UseCors` — allows configured origins (admin dashboard, blog)
3. `UseRateLimiter` — enforces per-endpoint quotas (login: 10/min, general: 1000/min)
4. `UseAuthentication` — extracts `Authorization` header; for JWT, validates RSA signature; for API Key, hashes and looks up in database
5. `UseAuthorization` — Hot Chocolate's `[Authorize]` attribute enforcement
6. `MapGraphQL` — Hot Chocolate parses, validates, and executes the GraphQL document
7. Inside resolvers: `RequirePermissionAsync` or `[AbacRequirePermission]` triggers ABAC evaluation

**Non-GraphQL endpoints:**
- `POST /assets/upload` — multipart form upload, returns asset metadata
- `GET /assets/{id}` — downloads the asset by ID
- `GET /llms.md` — auto-generated Markdown schema documentation
- `GET /healthcheck` — returns `{"status":"healthy"}`

## 4.3 Database Layer

### 4.3.1 DbContext and Entity Model

The `TechtonicCmsDbContext` (`Contexts/TechtonicCmsDbContext.cs`) configures EF Core with PostgreSQL native enums, database functions for JSONB extraction, and soft-delete behaviors.

```csharp
public class TechtonicCmsDbContext : DbContext
{
    public TechtonicCmsDbContext(DbContextOptions<TechtonicCmsDbContext> options) : base(options) { }

    public DbSet<User> Users => Set<User>();
    public DbSet<Role> Roles => Set<Role>();
    public DbSet<AbacPolicy> AbacPolicies => Set<AbacPolicy>();
    public DbSet<AbacPolicyRule> AbacPolicyRules => Set<AbacPolicyRule>();
    public DbSet<UserRole> UserRoles => Set<UserRole>();
    public DbSet<RolePolicy> RolePolicies => Set<RolePolicy>();
    public DbSet<UserPolicy> UserPolicies => Set<UserPolicy>();
    public DbSet<ResourceOwnership> ResourceOwnerships => Set<ResourceOwnership>();
    public DbSet<AbacEvaluationCache> AbacEvaluationCaches => Set<AbacEvaluationCache>();
    public DbSet<AbacAudit> AbacAudits => Set<AbacAudit>();
    public DbSet<Collection> Collections => Set<Collection>();
    public DbSet<Field> Fields => Set<Field>();
    public DbSet<Entry> Entries => Set<Entry>();
    public DbSet<EntryRelation> EntryRelations => Set<EntryRelation>();
    public DbSet<EntrySchedules> EntrySchedules => Set<EntrySchedules>();
    public DbSet<Asset> Assets => Set<Asset>();
    public DbSet<ApiKey> ApiKeys => Set<ApiKey>();
}
```

**Native PostgreSQL enums** are registered for all categorical types:

```csharp
private static void RegisterEnums(ModelBuilder modelBuilder)
{
    modelBuilder.HasPostgresEnum<UserStatus>();
    modelBuilder.HasPostgresEnum<PermissionAction>();
    modelBuilder.HasPostgresEnum<BaseResource>();
    modelBuilder.HasPostgresEnum<PermissionEffect>();
    modelBuilder.HasPostgresEnum<AttributePath>();
    modelBuilder.HasPostgresEnum<OperatorType>();
    modelBuilder.HasPostgresEnum<ValueType>();
    modelBuilder.HasPostgresEnum<LogicalOperator>();
    modelBuilder.HasPostgresEnum<EntryStatus>();
    modelBuilder.HasPostgresEnum<Locale>();
    modelBuilder.HasPostgresEnum<FieldDataType>();
    modelBuilder.HasPostgresEnum<ScheduledAction>();
}
```

This maps C# enums to PostgreSQL `CREATE TYPE` declarations, providing database-level type safety. Attempting to insert an invalid enum value raises a PostgreSQL error before EF Core sees it.

### 4.3.2 JSONB Content Storage

The `Entry` entity stores dynamic content in a single `jsonb` column:

```csharp
public class Entry
{
    public Guid Id { get; set; }
    public Guid CollectionId { get; set; }
    public string Name { get; set; } = null!;
    public string Slug { get; set; } = null!;
    public EntryStatus Status { get; set; }
    public Locale Locale { get; set; }
    public Locale DefaultLocale { get; set; }
    public Guid CreatedBy { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public DateTime? PublishedAt { get; set; }
    public JsonDocument Data { get; set; } = null!;  // JSONB
    
    public ICollection<EntryRelation> FromRelations { get; set; } = [];
    public ICollection<EntryRelation> ToRelations { get; set; } = [];
}
```

The `Data` property is `JsonDocument`, which serializes to PostgreSQL `jsonb`. This stores all dynamic field values—text, numbers, booleans, dates, objects—in a single column. The `Field` metadata table defines what fields exist for each collection and their types, but the actual values live in `Entry.Data`.

**Database functions for JSONB queries:**

```csharp
public static class CmsDbFunctions
{
    public static string? CmsExtractText(JsonDocument data, string fieldName) => throw new NotSupportedException();
    public static bool? CmsExtractBoolean(JsonDocument data, string fieldName) => throw new NotSupportedException();
    public static double? CmsExtractNumber(JsonDocument data, string fieldName) => throw new NotSupportedException();
    public static DateTime? CmsExtractDateTime(JsonDocument data, string fieldName) => throw new NotSupportedException();
}
```

These methods are registered as EF Core database functions mapping to PostgreSQL stored procedures:

```csharp
modelBuilder.HasDbFunction(functions.GetMethod(nameof(CmsDbFunctions.CmsExtractText))!)
    .HasName("cms_extract_text")
    .HasSchema("public");
```

The functions enable type-safe querying inside JSONB structures. When the LINQ query `CmsDbFunctions.CmsExtractText(e.Data, "title") == "Hello"` is translated to SQL, it becomes:

```sql
WHERE cms_extract_text(e."Data", 'title') = 'Hello'
```

This allows filtering and sorting on dynamic fields at the database level rather than loading all entries into memory and filtering in .NET.

### 4.3.3 Entry Relations

Relations between entries use a dedicated junction table with unique constraints per field:

```csharp
modelBuilder.Entity<EntryRelation>(e =>
{
    e.HasIndex(r => new { r.EntryId, r.FieldId }).IsUnique();
    
    e.HasOne(r => r.Entry)
        .WithMany(en => en.FromRelations)
        .HasForeignKey(r => r.EntryId)
        .OnDelete(DeleteBehavior.Cascade);
    
    e.HasOne(r => r.TargetEntry)
        .WithMany(en => en.ToRelations)
        .HasForeignKey(r => r.TargetEntryId)
        .OnDelete(DeleteBehavior.Cascade);
    
    e.HasOne(r => r.Field)
        .WithMany(f => f.EntryRelations)
        .HasForeignKey(r => r.FieldId)
        .OnDelete(DeleteBehavior.Restrict);
});
```

The unique index on `(EntryId, FieldId)` enforces that each field on an entry has at most one relation target—a design decision that makes the GraphQL type system simpler (a relation field returns a single related entry, not a list).

## 4.4 GraphQL API

The GraphQL API is the sole content and auth interface. All operations—content CRUD, authentication, authorization management, asset metadata—go through the `/graphql` endpoint.

### 4.4.1 Schema Generation Pipeline

The runtime schema generation is implemented in `CollectionTypeModule.cs`, a Hot Chocolate `TypeModule` that registers types dynamically at schema build time. The module uses `ObjectType.CreateUnsafe` and raw `ObjectTypeDefinition` objects rather than C# class-based type definitions, because the types are not known at compile time.

#### TypeModule Architecture

```csharp
public class CollectionTypeModule : TypeModule
{
    private readonly IDbContextFactory<TechtonicCmsDbContext> _dbFactory;
    private List<Collection>? _cachedCollections;

    public CollectionTypeModule(IDbContextFactory<TechtonicCmsDbContext> dbFactory)
    {
        _dbFactory = dbFactory;
    }

    public override async ValueTask<IEnumerable<TypeSystemObjectBase>> RegisterTypesAsync(
        ITypeDiscoveryContext context, CancellationToken cancellationToken)
    {
        if (_cachedCollections == null)
        {
            await using var db = await _dbFactory.CreateDbContextAsync();
            _cachedCollections = await db.Collections
                .AsNoTracking()
                .Include(c => c.Fields)
                .Where(c => !c.DeletedAt.HasValue)
                .OrderBy(c => c.CreatedAt)
                .ToListAsync();
        }

        var types = new List<TypeSystemMember>();
        var collectionTypeMap = BuildCollectionTypeMap(_cachedCollections);
        
        await BuildQueryTypesAsync(_cachedCollections, collectionTypeMap, context, types, cancellationToken);
        BuildMutationTypes(_cachedCollections, types);
        
        return types.OfType<TypeSystemObjectBase>();
    }
}
```

The module caches collection metadata in `_cachedCollections` after the first build. When an administrator modifies a collection, the cache is invalidated and the schema rebuilt. Hot Chocolate supports schema eviction and rebuild via `IRequestExecutorResolver`.

#### Naming Conventions

Collection slugs (kebab-case like `blog-posts`) are converted to PascalCase and camelCase for type names and field names:

```csharp
public static string ToPascalCase(string slug)
{
    return string.Concat(slug
        .Split('-', '_')
        .Select(part => char.ToUpper(part[0]) + part[1..].ToLower()));
}

public static string ToCamelCase(string slug)
{
    var parts = slug.Split('-', '_');
    return parts[0].ToLower() + string.Concat(
        parts[1..].Select(part => char.ToUpper(part[0]) + part[1..].ToLower()));
}
```

A collection with slug `blog-posts` generates types `BlogPostEntry`, `BlogPostEntryData`, `BlogPostEntryFilterInput`, `BlogPostEntrySortInput`, query field `blogPosts`, and mutation field `blogPosts`.

#### Stage 1: Data Type Definition

For each collection, a data type is built that maps collection fields to GraphQL scalar fields:

```csharp
public static ObjectTypeDefinition BuildEntryDataTypeDefinition(
    Collection collection, Dictionary<Guid, string> collectionTypeMap)
{
    var pascalName = ToPascalCase(collection.Slug);
    var dataTypeName = $"{pascalName}EntryData";

    var dataTypeDef = new ObjectTypeDefinition(dataTypeName)
    {
        Description = $"Dynamic data type for the '{collection.Name}' collection",
        RuntimeType = typeof(Dictionary<string, object>)
    };

    foreach (var field in collection.Fields.OrderBy(f => f.CreatedAt))
    {
        if (field.DataType == FieldDataType.Relation
            && field.RelatedCollectionId.HasValue
            && collectionTypeMap.TryGetValue(field.RelatedCollectionId.Value, out var relationTypeName))
        {
            // Relation field: resolver queries EntryRelations table
            var fieldId = field.Id;
            var fieldName = field.Name;

            dataTypeDef.Fields.Add(new ObjectFieldDefinition(
                field.Name,
                field.Description,
                TypeReference.Parse(relationTypeName),
                resolver: async ctx =>
                {
                    var data = ctx.Parent<Dictionary<string, object>>();
                    if (!data.TryGetValue("__entryId", out var rawEntryId) || rawEntryId is not Guid entryId)
                        return null;

                    var relationDb = ctx.Service<TechtonicCmsDbContext>();
                    var relation = await relationDb.EntryRelations
                        .Where(r => r.EntryId == entryId && r.FieldId == fieldId)
                        .Include(r => r.TargetEntry)
                        .FirstOrDefaultAsync();

                    return relation?.TargetEntry;
                }));
        }
        else
        {
            // Scalar field: extract from deserialized JSONB dictionary
            var graphqlType = MapFieldType(field.DataType);
            dataTypeDef.Fields.Add(new ObjectFieldDefinition(
                field.Name,
                field.Description,
                TypeReference.Parse(graphqlType),
                pureResolver: ctx =>
                    ctx.Parent<Dictionary<string, object>>().GetValueOrDefault(field.Name)));
        }
    }

    return dataTypeDef;
}
```

The data type uses `Dictionary<string, object>` as its runtime type. When the `data` field resolver executes, it deserializes the `Entry.Data` JSONB into a dictionary and passes it as the parent object. Scalar fields resolve via dictionary lookup; relation fields execute a database query against `EntryRelations`.

#### Stage 2: Entry Type Definition

The entry type wraps the data type with static system fields:

```csharp
public static ObjectTypeDefinition BuildEntryTypeDefinition(
    Collection collection, string dataTypeName)
{
    var pascalName = ToPascalCase(collection.Slug);
    var typeName = $"{pascalName}Entry";

    var entryTypeDef = new ObjectTypeDefinition(typeName)
    {
        Description = $"Dynamic entry type for the '{collection.Name}' collection",
        RuntimeType = typeof(Entry)
    };

    entryTypeDef.Fields.Add(new ObjectFieldDefinition(
        "id", "Unique identifier", TypeReference.Parse("ID!"),
        pureResolver: ctx => ctx.Parent<Entry>().Id));

    entryTypeDef.Fields.Add(new ObjectFieldDefinition(
        "name", "Entry name", TypeReference.Parse("String!"),
        pureResolver: ctx => ctx.Parent<Entry>().Name));

    entryTypeDef.Fields.Add(new ObjectFieldDefinition(
        "slug", "URL-friendly identifier", TypeReference.Parse("String"),
        pureResolver: ctx => ctx.Parent<Entry>().Slug));

    entryTypeDef.Fields.Add(new ObjectFieldDefinition(
        "status", "Entry status", TypeReference.Parse("EntryStatus!"),
        pureResolver: ctx => ctx.Parent<Entry>().Status));

    entryTypeDef.Fields.Add(new ObjectFieldDefinition(
        "createdAt", "Creation timestamp", TypeReference.Parse("DateTime!"),
        pureResolver: ctx => ctx.Parent<Entry>().CreatedAt));

    entryTypeDef.Fields.Add(new ObjectFieldDefinition(
        "updatedAt", "Last update timestamp", TypeReference.Parse("DateTime!"),
        pureResolver: ctx => ctx.Parent<Entry>().UpdatedAt));

    entryTypeDef.Fields.Add(new ObjectFieldDefinition(
        "publishedAt", "Publication timestamp", TypeReference.Parse("DateTime"),
        pureResolver: ctx => ctx.Parent<Entry>().PublishedAt));

    entryTypeDef.Fields.Add(new ObjectFieldDefinition(
        "data",
        $"Dynamic data for the '{collection.Name}' collection",
        TypeReference.Parse($"{dataTypeName}!"),
        resolver: ctx =>
        {
            var entry = ctx.Parent<Entry>();
            var dict = JsonSerializer.Deserialize<Dictionary<string, object>>(
                    entry.Data.RootElement.GetRawText(),
                    new JsonSerializerOptions { PropertyNameCaseInsensitive = true })
                ?? new Dictionary<string, object>();

            dict["__entryId"] = entry.Id;
            return new ValueTask<object?>(dict);
        }));

    return entryTypeDef;
}
```

The `__entryId` injection is a critical design choice: it makes the entry ID available to nested relation field resolvers, which need it to query the `EntryRelations` table. The double-underscore prefix follows GraphQL convention for system fields, and it is filtered out from the client-facing schema.

#### Stage 3: Query Field Construction

For each collection, a query field is added under the `entries` root:

```graphql
type Entries {
  blogPosts: [BlogPostEntry!]!  # dynamically generated
  products: [ProductEntry!]!    # dynamically generated
}
```

The resolver implementation:

```csharp
private static void BuildCollectionQueryField(
    Collection collection, IDescriptorContext context,
    ObjectTypeDefinition collectionEntriesTypeDef)
{
    var camelName = DynamicCollectionHelpers.ToCamelCase(collection.Slug);
    var pascalName = DynamicCollectionHelpers.ToPascalCase(collection.Slug);
    var typeName = $"{pascalName}Entry";
    var filterTypeName = $"{pascalName}EntryFilterInput";
    var sortTypeName = $"{pascalName}EntrySortInput";
    var collectionId = collection.Id;

    var collectionPropertyDef = new ObjectFieldDefinition(
        camelName,
        $"Access entries from the '{collection.Name}' collection",
        TypeReference.Parse(typeName))
    {
        ResultType = typeof(IQueryable<Entry>),
        Resolver = async ctx =>
        {
            var httpContextAccessor = ctx.Service<IHttpContextAccessor>();
            var readUserId = DynamicCollectionHelpers.GetUserId(httpContextAccessor);
            var readAbacService = ctx.Service<AbacService>();

            await readAbacService.RequirePermissionAsync(
                readUserId, BaseResource.Entries, PermissionAction.Read,
                new Dictionary<string, object?>
                {
                    ["ResourceEntryCollectionId"] = collectionId.ToString()
                });

            var innerDb = ctx.Service<TechtonicCmsDbContext>();

            var query = innerDb.Entries
                .Where(e => e.CollectionId == collectionId);

            var isRestricted = await readAbacService.IsRestrictedToOwnResourcesAsync(
                readUserId, BaseResource.Entries, PermissionAction.Read);
            if (isRestricted)
                query = query.Where(e => e.CreatedBy == readUserId);

            return query.AsQueryable();
        }
    };

    var fieldDescriptor = collectionPropertyDef.ToDescriptor(context)
        .UsePaging(options: new() { MaxPageSize = 100 },
            nodeType: typeof(ObjectType<Entry>),
            connectionName: pascalName + "Entry")
        .UseFiltering<Entry>(filterDesc =>
        {
            filterDesc.BindFieldsExplicitly();
            filterDesc.Name(filterTypeName);

            // Static entry fields
            filterDesc.Field(e => e.Name);
            filterDesc.Field(e => e.Slug);
            filterDesc.Field(e => e.Status);
            filterDesc.Field(e => e.CreatedAt);
            filterDesc.Field(e => e.UpdatedAt);
            filterDesc.Field(e => e.PublishedAt);

            // Dynamic jsonb fields via database functions
            foreach (var field in collection.Fields.OrderBy(f => f.CreatedAt))
                DynamicCollectionHelpers.AddDynamicFilterField(filterDesc, field);
        })
        .UseSorting<Entry>(sortDesc =>
        {
            sortDesc.BindFieldsExplicitly();
            sortDesc.Name(sortTypeName);

            // Static entry fields
            sortDesc.Field(e => e.Name);
            sortDesc.Field(e => e.Slug);
            sortDesc.Field(e => e.Status);
            sortDesc.Field(e => e.CreatedAt);
            sortDesc.Field(e => e.UpdatedAt);
            sortDesc.Field(e => e.PublishedAt);

            // Dynamic jsonb fields via database functions
            foreach (var field in collection.Fields.OrderBy(f => f.CreatedAt))
                DynamicCollectionHelpers.AddDynamicSortField(sortDesc, field);
        });

    collectionEntriesTypeDef.Fields.Add(fieldDescriptor.ToDefinition());
}
```

The resolver executes three operations in sequence:

1. **ABAC authorization** — `RequirePermissionAsync` checks if the user can read entries in this collection
2. **Base query construction** — filters to entries belonging to this collection
3. **Row-level filtering** — if `IsRestrictedToOwnResourcesAsync` returns true, injects `Where(e => e.CreatedBy == readUserId)`

The result is `IQueryable<Entry>`, not a materialized list. Hot Chocolate's `UsePaging`, `UseFiltering`, and `UseSorting` middleware then compose additional LINQ expressions on top of this queryable before EF Core translates the entire pipeline to SQL.

**Dynamic filter fields** use the JSONB extraction functions:

```csharp
public static void AddDynamicFilterField(IFilterInputTypeDescriptor<Entry> filterDesc, Field field)
{
    switch (field.DataType)
    {
        case FieldDataType.Text:
        case FieldDataType.Asset:
        case FieldDataType.Object:
            filterDesc.Field(e => CmsDbFunctions.CmsExtractText(e.Data, field.Name))
                .Name(field.Name);
            break;

        case FieldDataType.Boolean:
            filterDesc.Field(e => CmsDbFunctions.CmsExtractBoolean(e.Data, field.Name))
                .Name(field.Name);
            break;

        case FieldDataType.Number:
            filterDesc.Field(e => CmsDbFunctions.CmsExtractNumber(e.Data, field.Name))
                .Name(field.Name);
            break;

        case FieldDataType.DateTime:
            filterDesc.Field(e => CmsDbFunctions.CmsExtractDateTime(e.Data, field.Name))
                .Name(field.Name);
            break;

        case FieldDataType.Relation:
            var relFieldId = field.Id;
            filterDesc.Field(e => e.FromRelations
                    .Where(r => r.FieldId == relFieldId)
                    .Select(r => r.TargetEntryId)
                    .FirstOrDefault())
                .Name(field.Name);
            break;
    }
}
```

For text fields, `CmsDbFunctions.CmsExtractText(e.Data, "title")` generates SQL calling `cms_extract_text(e."Data", 'title')`. For relation fields, the filter uses the `FromRelations` navigation property to filter by target entry ID. This means a client can filter by a relation field's value as naturally as filtering by a scalar field.

#### Stage 4: Mutation Construction

Mutations are built with dynamic input types and per-operation resolvers. For each collection, the following mutations are generated: `create`, `update`, `delete`, `publish`, `unpublish`, `archive`, `restore`.

**Create mutation resolver:**

```csharp
private static ObjectFieldDefinition BuildCreateMutation(
    Collection collection, string createDataInputTypeName, string entryTypeName)
{
    var collectionId = collection.Id;

    var createFieldDef = new ObjectFieldDefinition(
        "create",
        $"Create a new entry in the '{collection.Name}' collection",
        TypeReference.Parse($"{entryTypeName}!"));

    createFieldDef.Arguments.Add(new ArgumentDefinition(
        "name", "Entry name", TypeReference.Parse("String!")));
    createFieldDef.Arguments.Add(new ArgumentDefinition(
        "slug", "URL-friendly identifier", TypeReference.Parse("String")));
    createFieldDef.Arguments.Add(new ArgumentDefinition(
        "locale", "Entry locale", TypeReference.Parse("Locale")));
    createFieldDef.Arguments.Add(new ArgumentDefinition(
        "status", "Entry status", TypeReference.Parse("EntryStatus")));
    createFieldDef.Arguments.Add(new ArgumentDefinition(
        "data", $"Dynamic data", TypeReference.Parse($"{createDataInputTypeName}!")));
    createFieldDef.Arguments.Add(new ArgumentDefinition(
        "schedulePublishFor", "Schedule publish at UTC time", TypeReference.Parse("DateTime")));

    createFieldDef.Resolver = async ctx =>
    {
        var mutationDb = ctx.Service<TechtonicCmsDbContext>();
        var abacService = ctx.Service<AbacService>();
        var httpContextAccessor = ctx.Service<IHttpContextAccessor>();

        var userId = DynamicCollectionHelpers.GetUserId(httpContextAccessor);
        await abacService.RequirePermissionAsync(userId, BaseResource.Entries, PermissionAction.Create,
            new Dictionary<string, object?>
            {
                ["ResourceEntryCollectionId"] = collectionId.ToString()
            });

        var name = ctx.ArgumentValue<string>("name");
        var slug = ctx.ArgumentValue<string?>("slug");
        var localeArg = ctx.ArgumentValue<Locale?>("locale");
        var statusArg = ctx.ArgumentValue<EntryStatus?>("status");
        var data = ctx.ArgumentValue<Dictionary<string, object?>>("data") ?? new();

        // Load collection fields for validation
        var collectionFields = await mutationDb.Fields
            .Where(f => f.CollectionId == collectionId)
            .ToListAsync();

        var (scalarData, relationValues) = SeparateFieldValues(data, collectionFields);

        ValidateRequiredFields(data, collectionFields);
        await DynamicCollectionHelpers.ValidateEntryData(scalarData, relationValues,
            collectionFields, mutationDb, collectionId, excludeEntryId: null);

        var entrySlug = slug ?? DynamicCollectionHelpers.GenerateSlug(name);
        var slugConflict = await mutationDb.Entries
            .AnyAsync(e => e.CollectionId == collectionId && e.Slug == entrySlug);
        if (slugConflict)
            entrySlug = $"{entrySlug}-{Guid.NewGuid().ToString("N")[..8]}";

        var now = DateTime.UtcNow;
        var json = JsonSerializer.Serialize(
            scalarData.Where(kvp => kvp.Value is not null)
                .ToDictionary(kvp => kvp.Key, kvp => kvp.Value));

        var entry = new Entry
        {
            Id = Guid.NewGuid(),
            Name = name,
            Slug = entrySlug,
            CollectionId = collectionId,
            CreatedBy = userId,
            Locale = localeArg ?? collection.DefaultLocale,
            DefaultLocale = collection.DefaultLocale,
            Status = statusArg ?? EntryStatus.Draft,
            Data = JsonDocument.Parse(json),
            CreatedAt = now,
            UpdatedAt = now,
            PublishedAt = statusArg == EntryStatus.Published ? now : null
        };

        mutationDb.Entries.Add(entry);

        foreach (var (fieldId, targetIdStr) in relationValues)
        {
            if (Guid.TryParse(targetIdStr, out var targetId))
            {
                mutationDb.EntryRelations.Add(new EntryRelation
                {
                    EntryId = entry.Id,
                    FieldId = fieldId,
                    TargetEntryId = targetId
                });
            }
        }

        await mutationDb.SaveChangesAsync();

        var schedulePublishFor = ctx.ArgumentValue<DateTime?>("schedulePublishFor");
        if (schedulePublishFor.HasValue && entry.Status != EntryStatus.Published)
        {
            await abacService.RequirePermissionAsync(userId, BaseResource.Entries,
                PermissionAction.Schedule, new Dictionary<string, object?>
                {
                    ["ResourceEntryId"] = entry.Id.ToString(),
                    ["ResourceEntryStatus"] = entry.Status.ToString(),
                    ["ResourceEntryCreatedBy"] = entry.CreatedBy.ToString(),
                    ["ResourceEntryCollectionId"] = entry.CollectionId.ToString(),
                    ["ResourceEntryLocale"] = entry.Locale.ToString(),
                    ["ResourceEntryPublishedAt"] = entry.PublishedAt?.ToString("O"),
                });

            mutationDb.EntrySchedules.Add(new EntrySchedules
            {
                EntryId = entry.Id,
                Action = ScheduledAction.Publish,
                ExecuteAt = schedulePublishFor.Value
            });
            await mutationDb.SaveChangesAsync();
        }

        return entry;
    };
}
```

The create resolver performs a complete workflow:

1. **ABAC check** — verifies create permission for entries in this collection
2. **Input extraction** — extracts name, slug, locale, status, and dynamic data
3. **Field separation** — splits the input dictionary into scalar values (stored in JSONB) and relation values (stored in `EntryRelations`)
4. **Validation** — checks required fields, unique constraints, and relation target existence
5. **Slug generation** — auto-generates from name if omitted; appends random suffix on conflict
6. **Entry creation** — builds the `Entry` entity with `Data` as serialized JSONB
7. **Relation persistence** — creates `EntryRelation` rows for relation fields
8. **Scheduling** — if `schedulePublishFor` is provided, validates schedule permission and creates an `EntrySchedules` row

**Update mutation** follows the same pattern but includes change tracking: it loads the existing entry, validates that the requesting user has update permission for that specific entry (via resource-level ABAC with `ResourceEntryId` and `ResourceEntryCreatedBy`), applies partial updates, and re-validates unique constraints with `excludeEntryId` set to the current entry.

**Publish/Unpublish/Archive/Restore mutations** are state-transition operations that validate the appropriate action permission and update `Entry.Status` and `PublishedAt`.

### 4.4.2 Authentication via GraphQL

All authentication operations are GraphQL mutations and queries. There are no REST auth endpoints.

**Auth mutations** (`Types/Auth/AuthMutations.cs`):

```graphql
type Mutation {
  auth: AuthMutation
}

type AuthMutation {
  login(name: String!, password: String!): LoginPayload
  refresh(refreshToken: String!): RefreshPayload
  logout: LogoutPayload
  logoutAll: LogoutPayload
}
```

**Login resolver:**

```csharp
[AllowAnonymous]
[EnableRateLimiting("Login")]
public async Task<LoginPayload> Login(
    string name, string password,
    [Service] TechtonicCmsDbContext db,
    [Service] PasswordService passwordService,
    [Service] AuthService authService,
    [Service] SessionService sessionService)
{
    var user = await db.Users.FirstOrDefaultAsync(u => u.Name == name);
    if (user is null)
        throw new GraphQLException(ErrorBuilder.New()
            .SetMessage("Invalid credentials")
            .SetCode("UNAUTHENTICATED")
            .Build());

    var (isValid, newHash) = passwordService.VerifyPassword(password, user.PasswordHash);
    if (!isValid)
        throw new GraphQLException(ErrorBuilder.New()
            .SetMessage("Invalid credentials")
            .SetCode("UNAUTHENTICATED")
            .Build());

    if (user.Status == UserStatus.Inactive || user.Status == UserStatus.Banned)
    {
        await sessionService.DeleteAllUserSessionsAsync(user.Id.ToString());
        var message = user.Status == UserStatus.Banned ? "Account is banned" : "Account is inactive";
        throw new GraphQLException(ErrorBuilder.New()
            .SetMessage(message)
            .SetCode("UNAUTHENTICATED")
            .Build());
    }

    if (newHash is not null)
    {
        user.PasswordHash = newHash;
        await db.SaveChangesAsync();
    }

    user.LastLoginTime = DateTime.UtcNow;
    await db.SaveChangesAsync();

    var (accessToken, sessionId) = await authService.GenerateAccessTokenAsync(user.Id, user.Name, user.Status);
    var refreshToken = await authService.GenerateRefreshTokenAsync(user.Id, sessionId);

    return new LoginPayload
    {
        AccessToken = new Token { TokenValue = accessToken, ExpiresAt = ... },
        RefreshToken = new Token { TokenValue = refreshToken, ExpiresAt = ... },
        User = user
    };
}
```

The login flow includes a **password hash migration** feature: `VerifyPassword` checks both Argon2id (modern) and SHA256 (legacy). If the stored hash is SHA256, it returns `(true, newHash)` where `newHash` is the Argon2id re-hash. The resolver updates the user's password hash in the database, transparently upgrading legacy accounts without requiring a password reset.

**Session management via Redis:**

```csharp
public async Task<SessionData> CreateSessionAsync(string sessionId, string userId, string userName, UserStatus status)
{
    var now = DateTime.UtcNow;
    var session = new SessionData(userId, userName, now, now.Add(SessionTtl), status);
    var json = JsonSerializer.Serialize(session);

    var batch = _db.CreateBatch();
    var setTask = batch.StringSetAsync($"session:{sessionId}", json, SessionTtl);
    var saddTask = batch.SetAddAsync($"user:sessions:{userId}", sessionId);
    batch.Execute();

    await setTask;
    await saddTask;

    return session;
}
```

Sessions are stored in Redis with 15-minute TTL. Each user has a Redis set (`user:sessions:{userId}`) containing all active session IDs. This enables efficient global logout: `DeleteAllUserSessionsAsync` retrieves all session IDs from the set and deletes them in a batch.

**Token structure:**

Access tokens use RS256 (RSA + SHA256) signing:
- Subject (`sub`): session ID (not user ID—this enables per-session revocation)
- Custom claim `userId`: the actual user GUID
- Custom claim `name`: user's display name
- Issuer, audience, expiration (15 minutes)

Refresh tokens also use RS256 but include a `type: refresh` claim. They are stored in Redis with 30-day TTL and are single-use (deleted after first use, replaced with a new one during refresh).

**Logout:**

```csharp
[Authorize]
public async Task<LogoutPayload> Logout(
    [Service] IHttpContextAccessor httpContextAccessor,
    [Service] AuthService authService,
    [Service] SessionService sessionService)
{
    var authHeader = httpContextAccessor.HttpContext?.Request.Headers.Authorization.FirstOrDefault();
    if (authHeader is null || !authHeader.StartsWith("Bearer "))
        return new LogoutPayload { Message = "Logged out" };

    var token = authHeader["Bearer ".Length..];
    var principal = authService.ValidateAccessToken(token);
    var sessionId = principal.FindFirst(JwtRegisteredClaimNames.Sub)?.Value;
    var userIdStr = principal.FindFirst("userId")?.Value;

    if (sessionId is not null && userIdStr is not null)
        await sessionService.DeleteSessionAsync(sessionId, userIdStr);

    return new LogoutPayload { Message = "Logged out" };
}
```

Logout extracts the session ID from the JWT's `sub` claim and deletes it from Redis. `LogoutAll` deletes all sessions for the user by enumerating the `user:sessions:{userId}` Redis set.

**Auth queries** (`Types/Auth/AuthQueries.cs`):

```graphql
type Query {
  auth: AuthQuery
}

type AuthQuery {
  me: User
  myKeys: [ApiKey!]!
}
```

The `me` query returns the current authenticated user. `myKeys` returns API keys owned by the current user, with pagination, filtering, and sorting.

### 4.4.3 ABAC Integration in Resolvers

ABAC authorization is integrated at three levels:

#### Level 1: Inline Permission Checks

Resolvers call `AbacService.RequirePermissionAsync` directly:

```csharp
await readAbacService.RequirePermissionAsync(
    readUserId, BaseResource.Entries, PermissionAction.Read,
    new Dictionary<string, object?>
    {
        ["ResourceEntryCollectionId"] = collectionId.ToString()
    });
```

`RequirePermissionAsync` is a convenience method that calls `CheckPermissionAsync` and throws a GraphQL exception if denied:

```csharp
public async Task RequirePermissionAsync(Guid userId, BaseResource resource,
    PermissionAction action, Dictionary<string, object?>? resourceData = null)
{
    var allowed = await CheckPermissionAsync(userId, resource, action, resourceData);
    if (!allowed)
        throw new GraphQLException(ErrorBuilder.New()
            .SetMessage("Access denied")
            .SetCode("FORBIDDEN")
            .Build());
}
```

#### Level 2: Declarative Attributes

The `[AbacRequirePermission]` attribute attaches middleware to resolver definitions:

```csharp
[AttributeUsage(AttributeTargets.Method)]
public class AbacRequirePermissionAttribute : DescriptorAttribute
{
    public BaseResource Resource { get; }
    public PermissionAction Action { get; }

    public AbacRequirePermissionAttribute(BaseResource resource, PermissionAction action)
    {
        Resource = resource;
        Action = action;
    }

    protected internal override void TryConfigure(
        IDescriptorContext context,
        IDescriptor descriptor,
        ICustomAttributeProvider element)
    {
        if (descriptor is not IObjectFieldDescriptor fieldDesc)
            return;

        fieldDesc.Use((next, def) => async ctx =>
        {
            var httpContext = ctx.Service<IHttpContextAccessor>().HttpContext;
            if (httpContext?.User?.Identity?.IsAuthenticated != true)
            {
                ctx.ReportError(GraphQLExceptionBuilder.Unauthenticated());
                return;
            }

            var userIdClaim = httpContext.User.FindFirst("userId")?.Value
                ?? httpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (userIdClaim is null || !Guid.TryParse(userIdClaim, out var userId))
            {
                ctx.ReportError(GraphQLExceptionBuilder.Unauthenticated());
                return;
            }

            var abacService = ctx.Service<AbacService>();
            var allowed = await abacService.CheckPermissionAsync(userId, Resource, Action);

            if (!allowed)
            {
                ctx.ReportError(GraphQLExceptionBuilder.Forbidden());
                return;
            }

            await next(ctx);
        });
    }
}
```

The attribute uses `fieldDesc.Use` to add middleware that runs before the resolver. It extracts the user ID from claims, calls `CheckPermissionAsync` without resource-level context (a coarse-grained check), and either continues or reports an error. This is appropriate for top-level mutations where the resource hasn't been loaded yet.

#### Level 3: Row-Level Filtering

The `[UseAbacRowCheck]` attribute wraps the resolver result and injects row-level filters for collection queries:

```csharp
[AttributeUsage(AttributeTargets.Method | AttributeTargets.Property)]
public class UseAbacRowCheckAttribute : DescriptorAttribute
{
    public BaseResource Resource { get; }
    public PermissionAction Action { get; }
    public string? OwnershipProperty { get; set; }

    protected internal override void TryConfigure(
        IDescriptorContext context,
        IDescriptor descriptor,
        ICustomAttributeProvider element)
    {
        if (descriptor is not IObjectFieldDescriptor fieldDesc)
            return;

        fieldDesc.Use((next, def) => async ctx =>
        {
            await next(ctx);

            var httpContextAccessor = ctx.Service<IHttpContextAccessor>();
            var abacService = ctx.Service<AbacService>();
            var userId = GetUserId(httpContextAccessor);

            if (ctx.Result is not IQueryable queryable)
                return;

            var entityType = queryable.ElementType;
            var ownershipProp = OwnershipProperty ?? "CreatedBy";
            var isRestricted = await abacService.IsRestrictedToOwnResourcesAsync(
                userId, Resource, Action);

            if (!isRestricted)
                return;

            // AST construction: x => x.CreatedBy == userId
            var param = Expression.Parameter(entityType, "x");
            var property = Expression.Property(param, ownershipProp);
            var constant = Expression.Constant(userId);
            var condition = Expression.Equal(property, constant);
            var lambda = Expression.Lambda(condition, param);

            var whereMethod = typeof(Queryable).GetMethods()
                .First(m => m.Name == "Where" && m.GetParameters().Length == 2)
                .MakeGenericMethod(entityType);

            var filteredQuery = whereMethod.Invoke(null, [queryable, lambda]);
            ctx.Result = filteredQuery;
        });
    }
}
```

This attribute runs `await next(ctx)` first, letting the resolver produce its result (an `IQueryable`), then modifies `ctx.Result` by injecting a `Where` clause via reflection and expression trees. The filter is applied after the resolver but before Hot Chocolate's pagination/sorting middleware, ensuring that filtering occurs at the database level.

The AST construction is identical to the approach described in the original chapter: `Expression.Parameter` → `Expression.Property` → `Expression.Constant` → `Expression.Equal` → `Expression.Lambda` → reflection invocation of `Queryable.Where<T>`. EF Core translates this to SQL `WHERE "CreatedBy" = '...'`.

### 4.4.4 Query Execution Flow

A complete GraphQL request flows through the following stages:

1. **HTTP Reception:** ASP.NET Core receives the POST request at `/graphql`.
2. **Security Headers:** `SecurityHeadersMiddleware` adds HSTS, X-Frame-Options, Referrer-Policy, X-Content-Type-Options.
3. **Rate Limiting:** `UseRateLimiter` checks endpoint quotas against client IP.
4. **Authentication:** `UseAuthentication` extracts the `Authorization` header. For JWT, `AuthService.ValidateAccessToken` verifies the RSA signature, issuer, audience, and expiration. For API Key, `ApiKeyAuthenticationHandler` hashes the key and looks it up in `ApiKeys`.
5. **JWT Session Validation:** Hot Chocolate's `[Authorize]` attribute triggers authorization. The access token's `sub` claim contains the session ID, which is checked against Redis via `SessionService.GetSessionAsync`. Revoked sessions return 401.
6. **GraphQL Parsing:** Hot Chocolate parses the document, validates syntax, and checks it against the live schema.
7. **Resolver Execution:** For each field, the corresponding resolver executes.
   - If `[AbacRequirePermission]` is present, coarse-grained ABAC runs before the resolver.
   - The resolver executes, typically returning `IQueryable<Entry>`.
   - If `[UseAbacRowCheck]` is present, the result is filtered via AST manipulation.
8. **Middleware Composition:** `UsePaging`, `UseFiltering`, `UseSorting` compose additional LINQ expressions on the queryable.
9. **Database Translation:** EF Core translates the composed LINQ expression to SQL, including JSONB function calls for dynamic fields.
10. **Result Assembly:** Hot Chocolate assembles resolver outputs into a JSON response.
11. **Audit Logging:** ABAC decisions are persisted to `AbacAudit` with evaluated policies, matching policies, duration, and request context.
12. **Response:** JSON is returned with HTTP 200 for success, 400 for validation errors, 401/403 for auth failures.

## 4.5 ABAC Engine Implementation

The ABAC engine (`Services/AbacService.cs`, ~700 lines) implements the complete NIST SP 800-162 reference architecture.

### 4.5.1 Service Interface

```csharp
public class AbacService
{
    private readonly IDbContextFactory<TechtonicCmsDbContext> _dbFactory;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public AbacService(IDbContextFactory<TechtonicCmsDbContext> dbFactory,
        IHttpContextAccessor httpContextAccessor)
    {
        _dbFactory = dbFactory;
        _httpContextAccessor = httpContextAccessor;
    }
}
```

The service is a singleton with no request-scoped state. It creates `DbContext` instances on demand via the factory.

### 4.5.2 Policy Information Point (PIP)

The `BuildContextAsync` method gathers all attributes needed for evaluation:

```csharp
private async Task<Dictionary<string, object?>> BuildContextAsync(
    Guid userId, PermissionAction action, Dictionary<string, object?>? resourceData)
{
    var context = new Dictionary<string, object?>
    {
        [AbacAttributePath.SubjectId] = userId.ToString(),
        [AbacAttributePath.ActionType] = action.ToString().ToUpperInvariant(),
        [AbacAttributePath.EnvironmentCurrentTime] = DateTime.UtcNow.ToString("o")
    };

    await using var db = await _dbFactory.CreateDbContextAsync();

    // Subject attributes
    var user = await db.Users
        .AsNoTracking()
        .Include(u => u.Roles)
        .ThenInclude(ur => ur.Role)
        .FirstOrDefaultAsync(u => u.Id == userId);

    if (user != null)
    {
        context[AbacAttributePath.SubjectStatus] = user.Status.ToString();
        context[AbacAttributePath.SubjectRole] = string.Join(",",
            user.Roles.Select(ur => ur.Role?.Name).Where(n => n != null));
    }

    // Environment attributes
    var httpContext = _httpContextAccessor.HttpContext;
    if (httpContext != null)
    {
        context[AbacAttributePath.EnvironmentIpAddress] =
            httpContext.Connection.RemoteIpAddress?.ToString();
        context[AbacAttributePath.EnvironmentUserAgent] =
            httpContext.Request.Headers.UserAgent.ToString();
    }

    // Resource attributes
    if (resourceData != null)
    {
        foreach (var (key, value) in resourceData)
            context[key] = value;
    }

    return context;
}
```

The context dictionary is flat. All attributes use string keys defined by the `AbacAttributePath` enum. The `resourceData` parameter allows resolvers to inject resource-level attributes (entry ID, collection ID, owner ID) for fine-grained checks.

### 4.5.3 Policy Resolution

```csharp
public async Task<List<AbacPolicy>> GetApplicablePoliciesAsync(
    Guid userId, BaseResource resource, PermissionAction action)
{
    await using var db = await _dbFactory.CreateDbContextAsync();

    var roleIds = await db.UserRoles
        .Where(ur => ur.UserId == userId
            && (ur.ExpiresAt == null || ur.ExpiresAt > DateTime.UtcNow))
        .Select(ur => ur.RoleId)
        .ToListAsync();

    var rolePolicyIds = await db.RolePolicies
        .Where(rp => roleIds.Contains(rp.RoleId))
        .Select(rp => rp.PolicyId)
        .ToListAsync();

    var userPolicyIds = await db.UserPolicies
        .Where(up => up.UserId == userId
            && (up.ExpiresAt == null || up.ExpiresAt > DateTime.UtcNow))
        .Select(up => up.PolicyId)
        .ToListAsync();

    var allPolicyIds = rolePolicyIds.Union(userPolicyIds).ToList();

    var policies = await db.AbacPolicies
        .AsNoTracking()
        .Where(p => allPolicyIds.Contains(p.Id)
            && p.IsActive
            && (p.BaseResource == resource || p.BaseResource == BaseResource.Wildcard)
            && (p.ActionType == action || p.ActionType == PermissionAction.Wildcard))
        .Include(p => p.Rules)
        .ToListAsync();

    return policies;
}
```

The query is split into three database queries to avoid complex JOINs that would duplicate policies when a user has multiple roles. The wildcard support (`BaseResource.Wildcard`, `PermissionAction.Wildcard`) enables broad policies for administrative roles.

### 4.5.4 PDP — Policy Decision Point

`CheckPermissionAsync` implements the full evaluation pipeline:

```csharp
public async Task<bool> CheckPermissionAsync(
    Guid userId, BaseResource resource, PermissionAction action,
    Dictionary<string, object?>? resourceData = null)
{
    // 1. Cache lookup
    var cached = await LookupCacheAsync(userId, resource, resourceId, action);
    if (cached != null) return cached.Value;

    // 2. Build context (PIP)
    var context = await BuildContextAsync(userId, action, resourceData);

    // 3. Resolve policies
    var policies = await GetApplicablePoliciesAsync(userId, resource, action);

    // 4. Separate deny and allow policies
    var denyPolicies = policies.Where(p => p.Effect == PermissionEffect.Deny)
        .OrderByDescending(p => p.Priority).ToList();
    var allowPolicies = policies.Where(p => p.Effect == PermissionEffect.Allow)
        .OrderByDescending(p => p.Priority).ToList();

    // 5. Evaluate deny policies first (short-circuit)
    foreach (var policy in denyPolicies)
        if (await EvaluatePolicyRulesAsync(policy, context))
            return false;

    // 6. Evaluate allow policies
    foreach (var policy in allowPolicies)
        if (await EvaluatePolicyRulesAsync(policy, context))
            return true;

    return false; // Default deny
}
```

This is the XACML deny-overrides combining algorithm: deny policies are evaluated first in priority order, and the first matching deny immediately rejects the request.

### 4.5.5 Rule Evaluation

```csharp
private static bool EvaluateRule(AbacPolicyRule rule, Dictionary<string, object?> context)
{
    var attributeKey = rule.AttributePath.ToString();
    var actualValue = context.TryGetValue(attributeKey, out var val) ? val : null;

    var actualStr = actualValue?.ToString();
    var actualNum = actualValue as double? ?? (actualValue as long?);
    var actualBool = actualValue as bool?;
    var actualDate = actualValue as DateTime?;

    return rule.Operator switch
    {
        OperatorType.Eq => rule.ValueType switch
        {
            ValueType.String => actualStr == rule.ExpectedStringValue,
            ValueType.Number => actualNum == rule.ExpectedNumberValue,
            ValueType.Boolean => actualBool == rule.ExpectedBooleanValue,
            ValueType.Uuid => actualStr == rule.ExpectedStringValue,
            ValueType.DateTime => actualDate == rule.ExpectedDateTimeValue,
            _ => false
        },
        OperatorType.Ne => !EvaluateEquals(rule, actualValue),
        OperatorType.In => rule.ExpectedArrayValue?.Contains(actualStr, StringComparer.OrdinalIgnoreCase) ?? false,
        OperatorType.NotIn => !(rule.ExpectedArrayValue?.Contains(actualStr, StringComparer.OrdinalIgnoreCase) ?? false),
        OperatorType.Gt => CompareNumeric(rule, actualValue) > 0,
        OperatorType.Gte => CompareNumeric(rule, actualValue) >= 0,
        OperatorType.Lt => CompareNumeric(rule, actualValue) < 0,
        OperatorType.Lte => CompareNumeric(rule, actualValue) <= 0,
        OperatorType.Contains => actualStr?.Contains(rule.ExpectedStringValue ?? "") ?? false,
        OperatorType.StartsWith => actualStr?.StartsWith(rule.ExpectedStringValue ?? "") ?? false,
        OperatorType.EndsWith => actualStr?.EndsWith(rule.ExpectedStringValue ?? "") ?? false,
        OperatorType.Regex => actualStr != null &&
            Regex.IsMatch(actualStr, rule.ExpectedStringValue ?? "", RegexOptions.Compiled),
        OperatorType.EqContextRef => EvaluateContextReference(rule, context),
        OperatorType.IsNull => actualValue == null,
        OperatorType.IsNotNull => actualValue != null,
        _ => false
    };
}
```

The switch handles 13 operators across 5 value types (string, number, boolean, UUID, datetime). `EqContextRef` compares one context attribute against another, enabling ownership checks.

### 4.5.6 Database-Backed Evaluation Cache

The cache is stored in PostgreSQL, not in-memory:

```csharp
private async Task<AbacEvaluationCache?> LookupCacheAsync(
    Guid userId, BaseResource resource, Guid? resourceId, PermissionAction action)
{
    var cacheKey = $"abac:{userId}:{resource}:{action}:{resourceId ?? Guid.Empty}";

    await using var db = await _dbFactory.CreateDbContextAsync();
    var cached = await db.AbacEvaluationCaches
        .AsNoTracking()
        .FirstOrDefaultAsync(c => c.CacheKey == cacheKey && c.ExpiresAt > DateTime.UtcNow);

    if (cached == null) return null;

    // Version validation
    var currentPolicies = await GetApplicablePoliciesAsync(userId, resource, action);
    var currentVersions = string.Join(",",
        currentPolicies.Select(p => $"{p.Id}:{p.UpdatedAt:O}"));

    if (cached.PolicyVersions != currentVersions)
        return null;

    return cached;
}
```

The cache uses the `AbacEvaluationCaches` table with TTL-based expiration. The `PolicyVersions` string is a concatenation of all contributing policies' `(Id, UpdatedAt)` pairs. When any policy is modified, its `UpdatedAt` changes, the version string mismatches, and the cache entry is discarded.

**Differential TTL:**
- Allow decisions: 5 minutes
- Deny decisions: 2 minutes

### 4.5.7 Audit Logging

Every authorization decision is persisted:

```csharp
private async Task WriteAuditAsync(
    Guid userId, BaseResource resource, Guid? resourceId, PermissionAction action,
    bool decision, List<AbacPolicy> evaluatedPolicies, List<AbacPolicy> matchingPolicies,
    string reason, long durationMs, Dictionary<string, object?> context)
{
    await using var db = await _dbFactory.CreateDbContextAsync();

    var audit = new AbacAudit
    {
        Id = Guid.NewGuid(),
        UserId = userId,
        Action = action,
        Resource = resource,
        ResourceId = resourceId,
        Decision = decision,
        EvaluatedPolicies = JsonDocument.Parse(JsonSerializer.Serialize(
            evaluatedPolicies.Select(p => p.Id))),
        MatchingPolicies = JsonDocument.Parse(JsonSerializer.Serialize(
            matchingPolicies.Select(p => p.Id))),
        Reason = reason,
        DurationMs = (int)durationMs,
        IpAddress = context.GetValueOrDefault(AbacAttributePath.EnvironmentIpAddress)?.ToString(),
        UserAgent = context.GetValueOrDefault(AbacAttributePath.EnvironmentUserAgent)?.ToString(),
        Timestamp = DateTime.UtcNow
    };

    db.AbacAudits.Add(audit);
    await db.SaveChangesAsync();
}
```

The audit record captures who, what, when, where, outcome, rationale, and performance. This implements non-repudiation and enables compliance reporting and policy optimization.

### 4.5.8 Row-Level Filtering Probe

`IsRestrictedToOwnResourcesAsync` determines if filtering is necessary:

```csharp
public async Task<bool> IsRestrictedToOwnResourcesAsync(
    Guid userId, BaseResource resource, PermissionAction action)
{
    var fakeOwnerId = Guid.NewGuid();
    var probeContext = new Dictionary<string, object?>
    {
        [AbacAttributePath.ResourceFieldId] = fakeOwnerId.ToString(),
        [AbacAttributePath.ResourceUserId] = fakeOwnerId.ToString()
    };

    var allowed = await CheckPermissionAsync(userId, resource, action, probeContext);
    return !allowed;
}
```

The probe creates a synthetic resource with a random owner ID. If access is denied, the user is restricted to their own resources.

## 4.6 Non-GraphQL Endpoints

The system provides four minimal non-GraphQL endpoints. These exist because GraphQL is text-based and inefficient for binary data transfer, or because they serve infrastructure purposes.

### 4.6.1 Asset Upload and Download

```csharp
public static IEndpointRouteBuilder MapAssetEndpoints(this IEndpointRouteBuilder app)
{
    app.MapPost("/assets/upload", async (
        IFormFile file,
        [Service] S3Service s3,
        [Service] TechtonicCmsDbContext db,
        [Service] IHttpContextAccessor httpContextAccessor) =>
    {
        var userId = Guid.Parse(httpContextAccessor.HttpContext!.User
            .FindFirst("userId")!.Value);

        await using var dbContext = await db.GetContext();
        // ... validation, S3 upload, DB persistence
    });

    app.MapGet("/assets/{id:guid}", async (
        Guid id,
        [Service] S3Service s3,
        [Service] TechtonicCmsDbContext db) =>
    {
        var asset = await db.Assets.FindAsync(id);
        if (asset == null) return Results.NotFound();

        var stream = await s3.DownloadAsync(asset.S3Key);
        if (stream == null) return Results.NotFound();

        return Results.Stream(stream, asset.MimeType, asset.FileName);
    });

    return app;
}
```

Upload uses multipart form data (the standard for binary file uploads). Download streams the S3 object directly to the response. There is no ABAC on download in the current implementation; asset visibility is controlled by the `IsPublic` flag.

### 4.6.2 Schema Documentation Endpoint

```csharp
app.MapGet("/llms.md", async (IRequestExecutorResolver executorResolver) =>
{
    var executor = await executorResolver.GetRequestExecutorAsync();
    var schema = executor.Schema;
    var markdown = GenerateSchemaMarkdown(schema);
    return Results.Text(markdown, "text/markdown");
});
```

This endpoint auto-generates Markdown documentation from the live introspected schema, useful for LLM context windows and developer documentation.

### 4.6.3 Health Check

```csharp
app.MapGet("/healthcheck", () => Results.Ok("healthy"));
```

Returns a plain text `healthy` response. Container orchestration uses this for liveness probes.

## 4.7 Frontend Implementation

The administrative frontend (`techtoniccms-app/`, commit `505bdc9`) is SvelteKit with TypeScript.

### 4.7.1 Data Fetching

Server-side `load` functions use a `query()` wrapper:

```typescript
export async function query<T>(document: TypedDocumentNode<T>, variables?: unknown) {
    const client = new GraphQLClient(GRAPHQL_ENDPOINT, {
        headers: { Authorization: `Bearer ${locals.accessToken}` }
    });
    return await client.request(document, variables);
}
```

Error normalization maps GraphQL codes to HTTP errors (`UNAUTHENTICATED` → 401, `FORBIDDEN` → 403).

### 4.7.2 Permission-Aware UI

The `permissions.ts` module mirrors server-side ABAC logic for UI gating:

```typescript
export function canManagePolicies(user: User | null): boolean {
    if (!user) return false;
    if (user.roles.some(r => r.name === 'Admin')) return true;
    return hasPolicy(user, BaseResource.AbacPolicies, PermissionAction.Manage);
}
```

This is a client-side pre-check; all enforcement remains server-side.

### 4.7.3 Dynamic Form Components

The `entry-editor.svelte` renders forms from collection field definitions:

- `FieldDataType.Text` → `Input`
- `FieldDataType.Boolean` → `Switch`
- `FieldDataType.Number` → `Input type="number"`
- `FieldDataType.DateTime` → `DatePicker`
- `FieldDataType.Relation` → `RelationPicker`
- `FieldDataType.Asset` → `AssetUploader`

Validation constraints apply at both client (UX) and server (security) levels.

## 4.8 Blog Use Case Implementation

The blog (`techtoniccms-blog/`) is an Astro SSR application.

### 4.8.1 Content Loader

The `techtonicPostsLoader` (`src/lib/cms-loader.ts`) implements Astro's `LiveLoader`:

```typescript
export function techtonicPostsLoader(config: {
    apiUrl: string, apiKey: string
}): LiveLoader<BlogPost, { id: string }, GetBlogPostsQueryVariables> {
    const client = new GraphQLClient(config.apiUrl, {
        headers: { Authorization: `X-Api-Key ${config.apiKey}` }
    });

    return {
        name: "techtonic-posts-loader",
        loadEntry: async ({ filter }) => {
            const res = await client.request(POST_BY_SLUG_QUERY, { slug: filter.id });
            const node = res.collections.entries.blogPosts?.edges?.[0]?.node;
            return node ? flattenNode(node) : undefined;
        },
        loadCollection: async ({ filter }) => {
            const res = await client.request(POSTS_QUERY, filter ?? {});
            const entries = res.collections.entries.blogPosts?.edges
                ?.map(ed => ed.node)
                .filter((node): node is NonNullable<typeof node> => node != null)
                .map(flattenNode) ?? [];
            return { entries };
        }
    };
}
```

The loader uses API Key authentication. GraphQL queries request only needed fields, eliminating over-fetching.

### 4.8.2 Live Collections

```typescript
const posts = defineLiveCollection({
    loader: techtonicPostsLoader({
        apiKey: import.meta.env.API_KEY,
        apiUrl: import.meta.env.API_URL + "graphql"
    })
});

export const collections = { posts };
```

### 4.8.3 Asset Proxy

```typescript
export const GET: APIRoute = async ({ params }) => {
    const id = params.path;
    const asset = await fetch(`${API_URL}assets/${id}`, {
        headers: { Authorization: `X-Api-Key ${API_KEY}` }
    });

    const headers = new Headers();
    headers.set("Cache-Control", "public, max-age=3600, immutable");
    return new Response(asset.body, { status: 200, headers });
};
```

The `immutable` directive is safe because CMS assets receive new IDs on update.

### 4.8.4 Typed Client Generation

The `techtonic-client-gql` package contains GraphQL Code Generator output, producing TypeScript types from the live CMS schema. When the administrator adds a field to the "Blog Posts" collection, regenerating the client produces updated types without manual schema editing.

## 4.9 Benchmark Implementation

### 4.9.1 ABAC Micro-Benchmarks

`Benchmarks.cs` implements five BenchmarkDotNet benchmarks:

**Benchmark 1 — Cache Hit vs. Miss:**
```csharp
[Benchmark(Baseline = true)]
public async Task<bool> CacheHit()
    => await _abacService.CheckPermissionAsync(_userId, _resource, _action);

[Benchmark]
public async Task<bool> CacheMiss()
    => await _abacService.CheckPermissionAsync(Guid.NewGuid(), _resource, _action);
```

**Benchmark 2 — Policy Scaling:**
```csharp
[Params(1, 5, 10, 25, 50)]
public int PolicyCount;

[Benchmark]
public async Task<bool> EvaluatePolicies()
    => await _abacService.CheckPermissionAsync(_userId, BaseResource.Entries, PermissionAction.Read);
```

**Benchmark 3 — Row Filter Overhead:**
```csharp
[Benchmark(Baseline = true)]
public async Task<int> NoFilterBaseline()
    => await _dbContext.Entries.CountAsync();

[Benchmark]
public async Task<int> UnrestrictedUser()
    => await _dbContext.Entries.CountAsync();

[Benchmark]
public async Task<int> RestrictedUser()
    => await _dbContext.Entries.Where(e => e.CreatedBy == _restrictedUserId).CountAsync();
```

**Benchmark 4 — Deny vs. Allow Timing:**
```csharp
[Benchmark]
public async Task<bool> DenyDecision()
    => await _denyAbacService.CheckPermissionAsync(_denyUserId, BaseResource.Entries, PermissionAction.Read);

[Benchmark]
public async Task<bool> AllowDecision()
    => await _allowAbacService.CheckPermissionAsync(_allowUserId, BaseResource.Entries, PermissionAction.Read);
```

**Benchmark 5 — Audit Logging:**
```csharp
[Benchmark]
public async Task<bool> WithAuditLogging()
    => await _withAuditService.CheckPermissionAsync(_userId, BaseResource.Entries, PermissionAction.Read);
```

All benchmarks use EF Core InMemory for isolation. Production-like numbers require PostgreSQL.

### 4.9.2 Schema Generation Load Tests

`schema-generation-benchmark.js` uses K6 with staged load:

```javascript
export const options = {
  stages: [
    { duration: '10s', target: 10 },
    { duration: '30s', target: 50 },
    { duration: '60s', target: 50 },
    { duration: '10s', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],
    http_req_failed: ['rate<0.01'],
  },
};
```

## 4.10 Security Implementation

### 4.10.1 Security Headers

`SecurityHeadersMiddleware` adds response headers:

```csharp
public async Task InvokeAsync(HttpContext context)
{
    context.Response.Headers["X-Content-Type-Options"] = "nosniff";
    context.Response.Headers["X-Frame-Options"] = "DENY";
    context.Response.Headers["Referrer-Policy"] = "strict-origin-when-cross-origin";
    context.Response.Headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains; preload";
    await _next(context);
}
```

### 4.10.2 Password Storage

`PasswordService` uses Argon2id with SHA256 fallback:

```csharp
private static readonly Argon2Config DefaultConfig = new()
{
    Type = Argon2Type.DataIndependentAddressing,
    Version = Argon2Version.Nineteen,
    TimeCost = 3,
    MemoryCost = 65536,
    Lanes = 4,
    Threads = 4,
    HashLength = 32,
};
```

The `VerifyPassword` method checks Argon2id first, then SHA256 (for legacy migration). If SHA256 matches, it returns `(true, newHash)` where `newHash` is the Argon2id re-hash, enabling transparent upgrades.

### 4.10.3 Rate Limiting

Three tiers are configured:

| Endpoint | Strategy | Limit |
|----------|----------|-------|
| Login | Fixed window | 10 requests / minute |
| Upload | Token bucket | 5 MB burst, 1 MB/sec refill |
| General API | Fixed window | 1000 requests / minute |

## 4.11 DevOps and Deployment

### 4.11.1 Containerization

The Dockerfile uses multi-stage build with a non-root user:

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY . .
RUN dotnet restore
RUN dotnet publish -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .
RUN adduser --disabled-password --gecos "" --uid 10001 appuser
USER appuser
EXPOSE 8080
ENTRYPOINT ["dotnet", "TechtonicCmsApi.dll"]
```

### 4.11.2 Health Checks

The `/healthcheck` endpoint returns 200 when dependencies are reachable.

---

**End of Chapter 4**
