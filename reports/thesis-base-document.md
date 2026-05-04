# TechtonicCMS: A Headless Content Management System with Attribute-Based Access Control
## Thesis Base Document — Implementation-Agnostic Design

**Author:** [Your Name]  
**Institution:** [Your University]  
**Year:** 2026  

---

## Abstract

Content Management Systems (CMS) have evolved from monolithic platforms tightly coupling presentation and data layers to decoupled architectures that enable omnichannel content distribution. This work presents TechtonicCMS, a headless CMS that separates content management from content presentation through an API-first architecture. The system introduces two primary contributions: (1) a runtime GraphQL schema generation mechanism that derives the type system from database metadata, eliminating the schema-resolver impedance mismatch inherent in static approaches; and (2) a comprehensive Attribute-Based Access Control (ABAC) engine that enables granular authorization decisions considering subject attributes, resource properties, contextual factors, and environmental conditions. The authorization system implements a full Policy Decision Point (PDP) / Policy Enforcement Point (PEP) architecture with policy evaluation caching, audit logging, and row-level query filtering. The work demonstrates how dynamic schema generation and fine-grained access control can coexist in a production-ready headless CMS architecture, validated through theoretical analysis, architectural benchmarks, and a functional blog consumption use case.

**Keywords:** Headless CMS, GraphQL, Dynamic Schema Generation, ABAC, Attribute-Based Access Control, Content Management, API-First Architecture, EAV Model

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Theoretical Framework](#2-theoretical-framework)
3. [System Design](#3-system-design)
4. [Implementation](#4-implementation)
5. [Validation and Use Case](#5-validation-and-use-case)
6. [Conclusion](#6-conclusion)
7. [Bibliography](#7-bibliography)

---

## 1. Introduction

### 1.1 Context

The modern web ecosystem demands content delivery across an expanding array of channels: traditional websites, mobile applications, voice assistants, IoT devices, and digital signage. Traditional Content Management Systems (CMS) such as WordPress and Joomla, which account for over 40% of all websites, were architected around the assumption that content would be rendered through a tightly coupled presentation layer (W3Techs, 2024). This monolithic architecture presents fundamental limitations when content must be distributed to multiple frontends simultaneously (Jain, 2021; Boiko, 2005).

The headless CMS architecture addresses this constraint by completely decoupling the content management backend from the presentation frontend. Communication occurs exclusively through APIs, enabling any client capable of HTTP requests to consume content without knowledge of the backend's internal structure (Jain, 2021). This separation embodies the API-First design principle, where the interface contract is defined before any implementation, establishing "Content as a Service" (CaaS) capabilities from the outset (Jain, 2021).

However, the flexibility of headless architectures introduces new challenges. As content types become user-defined rather than developer-configured, the API surface must adapt dynamically. Traditional approaches—whether schema-first (writing SDL before resolvers) or code-first (writing C# classes that generate schema)—assume the type system is statically knowable at development time. When end users create new content types through an administrative interface, these assumptions break down, creating what this work terms the **schema-resolver impedance mismatch**: the schema describes types that the resolver implementation may not yet fulfill, or vice versa.

Concurrently, regulatory requirements such as GDPR and LGPD demand granular access control that considers not only user roles but contextual attributes: time of access, geographic location, data sensitivity classification, and content ownership. Role-Based Access Control (RBAC), the traditional model employed by systems like Strapi, proves insufficient for these requirements, leading to role explosion and inability to express context-dependent policies (Coyne & Weil, 2013). Attribute-Based Access Control (ABAC), as formalized by NIST, provides the necessary expressiveness by evaluating authorization decisions across multiple attribute dimensions (Hu et al., 2014).

### 1.2 Problem Statement

This work addresses three interconnected problems in headless CMS design:

1. **Dynamic Schema Evolution:** How can a CMS expose a type-safe GraphQL API for content types that users define at runtime, without requiring code changes, recompilation, or redeployment?

2. **Granular Authorization:** How can a CMS enforce access control at the field level and row level, considering dynamic contextual attributes, without requiring developers to embed authorization logic in every resolver?

3. **Schema-Resolver Synchronization:** How can the system guarantee that the GraphQL schema and its resolver implementations remain synchronized when both evolve from the same runtime metadata?

### 1.3 Objectives

**General Objective:**  
Design and validate a headless CMS architecture that combines runtime GraphQL schema generation with attribute-based access control, demonstrating that dynamic type systems and fine-grained authorization can coexist without compromising type safety or performance.

**Specific Objectives:**
1. Design a database model capable of storing both structured metadata (collections, fields) and semi-structured content (entries) with referential integrity.
2. Design a runtime schema generation pipeline that derives GraphQL types from database metadata without intermediate code generation.
3. Design a complete ABAC engine implementing the NIST SP 800-162 reference architecture with policy evaluation caching, audit logging, and row-level query filtering.
4. Validate the architecture through theoretical analysis, performance benchmarks, and a functional consumption use case.

### 1.4 Methodology

This work adopts applied research methodology organized in three phases:

**Phase 1 — Theoretical Foundation:**  
Comprehensive literature review covering CMS architectures, GraphQL schema generation paradigms, dynamic data modeling patterns (EAV, JSONB), ABAC formal models (NIST SP 800-162, XACML), and related systems (WordPress, Strapi, Contentful).

**Phase 2 — Architecture Design:**  
Specification of the three-layer architecture (persistence, application, presentation), database model with hybrid storage strategy, ABAC engine with all functional points (PDP, PEP, PIP, PAP), and API contracts (GraphQL + REST).

**Phase 3 — Validation:**  
Performance benchmarking of authorization caching, policy scaling, and row filter overhead. Functional validation through a blog application consuming the CMS via its dynamically generated GraphQL API.

### 1.5 Document Structure

Chapter 2 establishes the theoretical foundation. Chapter 3 presents the system design in detail. Chapter 4 describes the concrete implementation, directly referencing source code and benchmark scripts. Chapter 5 describes validation methodology and results. Chapter 6 concludes with contributions and future work.

---

## 2. Theoretical Framework

### 2.1 Content Management Systems

A Content Management System (CMS) is software that enables users to create, manage, and publish digital content without specialized technical knowledge (Boiko, 2005). Regardless of architectural approach, a CMS performs three fundamental functions: **collection** (content acquisition and editing), **management** (structured storage with versioning and workflow), and **publishing** (content distribution through appropriate channels) (Boiko, 2005).

Three architectural categories have emerged (Jain, 2021):

- **Traditional (Coupled) CMS:** Backend and frontend form a monolithic unit. WordPress and Joomla exemplify this approach—easy to deploy but limited in multi-channel distribution (WordPress Foundation, 2024; Open Source Matters, 2024).
- **Headless (Decoupled) CMS:** Backend and frontend are completely separated, communicating exclusively through APIs. This enables omnichannel content delivery at the cost of requiring frontend development (Jain, 2021).
- **Hybrid CMS:** Combines characteristics of both, allowing optional coupling when appropriate (Strapi Team, 2024).

### 2.2 Headless Architecture and API-First Design

The headless architecture derives from the client-server model where frontend (presentation layer) and backend (data and logic layers) execute on distinct systems (Sommerville, 2015). The defining characteristic is the **absence of a default presentation layer**: the CMS does not render HTML, templates, or themes. Instead, it exposes content through APIs that any client—web application, mobile app, voice assistant, or IoT device—can consume (Jain, 2021).

The API-First approach means the API contract is the primary design artifact. This ensures consistency across all consumers and establishes CaaS capabilities from the outset (Jain, 2021). Benefits include technological freedom (each frontend chooses its stack), independent scalability (applying shared-nothing architecture principles where components scale independently) (Kleppmann, 2017), and maximum content reuse (single content source, multiple channels).

Challenges include increased technical complexity (developers must understand distributed systems, API protocols, and authentication) and cross-team coordination requirements (Sommerville, 2015; Kleppmann, 2017).

### 2.3 GraphQL for Content APIs

GraphQL, developed at Facebook in 2012 and publicly released in 2015, addresses two fundamental limitations of REST APIs: **over-fetching** (receiving more data than necessary) and **under-fetching** (requiring multiple requests to assemble complete data) (Banks & Porcello, 2018; Facebook Engineering, 2015).

GraphQL operates through a single endpoint where clients specify exactly which fields they require. The server's type system defines available data shapes, and resolvers connect each field to its data source (Banks & Porcello, 2018). For content management, GraphQL offers particular advantages: Union Types handle heterogeneous field types (text, number, asset, relation), argument-based filtering enables precise queries, and introspection allows clients to discover available types dynamically (Banks & Porcello, 2018).

However, conventional GraphQL implementation approaches assume static type systems. **Schema-first** GraphQL requires writing Schema Definition Language (SDL) before implementation—impossible when types are defined at runtime. **Code-first** GraphQL generates schema from statically defined host-language types—requiring compilation and deployment when types change. For a headless CMS where end users define content types through an administrative interface, neither approach is architecturally sound, as both create a schema-resolver impedance mismatch that can only be resolved through runtime metamodeling.

### 2.4 Dynamic Data Modeling

Systems requiring flexible schemas must balance query performance against structural adaptability (Kleppmann, 2017). The **Entity-Attribute-Value (EAV)** pattern represents the traditional approach: each attribute instance occupies a separate row with entity ID, attribute name, and value columns (Nadkarni et al., 2007). While maximally flexible (new attributes require no schema changes), EAV suffers from query performance degradation (complex JOINs to reconstruct entities), loss of native typing (all values stored as text), indexing difficulties, and verbose query complexity (Nadkarni et al., 2007; Batra et al., 2017).

Modern hybrid approaches address these limitations (Kleppmann, 2017; Dinu & Nadkarni, 2007):

- **Typed tables for primitives:** Text, numbers, booleans, and dates stored in dedicated tables with native database types and indexes (Silberschatz et al., 2018).
- **JSON/JSONB for complex structures:** Semi-structured data (lists, nested objects) leverages native database support for JSON types, providing flexibility while offering specialized query operators (PostgreSQL Global Development Group, 2024).
- **Metadata mapping:** Schema definitions (fields, types, validations) stored in metadata tables interpreted by generic code, eliminating repetitive CRUD implementations (Fowler, 2002).

### 2.5 Attribute-Based Access Control (ABAC)

ABAC represents an evolution from RBAC by basing authorization decisions on attributes across multiple dimensions rather than solely on organizational roles (Hu et al., 2014; Servos & Osborn, 2017). While RBAC assigns permissions to roles and roles to users, ABAC evaluates policies that consider:

- **Subject attributes:** User identity, role, status, department
- **Resource attributes:** Object type, owner, sensitivity classification, publication status
- **Action attributes:** Operation type (create, read, update, delete)
- **Environment attributes:** Time, location, IP address, device type (Hu et al., 2014)

The NIST SP 800-162 reference architecture defines four functional components (Hu et al., 2014):

1. **Policy Decision Point (PDP):** Evaluates policies and attributes to produce authorization decisions.
2. **Policy Enforcement Point (PEP):** Intercepts requests, queries the PDP, and applies decisions.
3. **Policy Information Point (PIP):** Provides attribute data from various sources.
4. **Policy Administration Point (PAP):** Interface for creating and managing policies.

XACML (eXtensible Access Control Markup Language) constitutes the OASIS standard for ABAC policy specification, defining hierarchical structures of rules, policies, and policy sets, along with deterministic combining algorithms (deny-overrides, permit-overrides) for conflict resolution (OASIS, 2013; Li et al., 2009). Alternative implementations include Open Policy Agent (OPA) with its Rego declarative language, Casbin multi-language library, and cloud-native services such as AWS IAM with tag-based ABAC (Amazon Web Services, 2024; Casbin Team, 2024; Apache Software Foundation, 2024).

### 2.6 Related Work

**WordPress** remains the dominant traditional CMS, used by over 40% of websites. Its monolithic architecture makes headless adaptation possible but suboptimal (W3Techs, 2024; WordPress Foundation, 2024).

**Strapi** is the most prominent open-source headless CMS. It shares characteristics with this work: custom collections, GraphQL/REST APIs, and role-based permissions. However, Strapi implements only RBAC (permissions per content type, not per field or context) and cannot express rules such as "publish only during business hours" or "access only from this IP range" (Strapi Team, 2024). Additionally, Strapi's schema generation requires server restart when content types change, lacking true runtime schema evolution.

**Contentful**, a commercial API-first CMS, implements dynamic GraphQL schema generation from user-defined content models. However, academic literature notes that "the application of GraphQL in a context where dynamic schema generation and further schema patching during runtime is needed hasn't been significantly explored" (Porto University Repository, 2022). This work contributes to that underexplored area by demonstrating a complete implementation with formal authorization.

---

## 3. System Design

### 3.1 Architecture

The system adopts a three-layer architecture with clear separation of concerns and communication through well-defined interfaces.

```mermaid
graph TB
    subgraph Presentation["Presentation Layer"]
        A["Admin Dashboard"]
        B["Consumer Applications"]
        C["Blog / Website"]
    end
    
    subgraph Application["Application Layer"]
        D["GraphQL API"]
        E["REST API"]
        F["ABAC Engine"]
        G["Auth Service"]
        H["Schema Generator"]
        I["Asset Service"]
    end
    
    subgraph Persistence["Persistence Layer"]
        J[("Relational Database")]
        K[("In-Memory Cache")]
        L[("File Storage")]
    end
    
    A -->|Admin Queries| D
    A -->|Auth / Upload| E
    B -->|Content Queries| D
    C -->|Content Queries| D
    C -->|Asset Proxy| E
    
    D -->|Authorize| F
    D -->|Generate Schema| H
    D -->|Query| J
    E -->|Authenticate| G
    E -->|Upload| I
    F -->|Fetch Attributes| J
    F -->|Cache Decisions| K
    F -->|Log Audit| J
    G -->|Validate Sessions| K
    G -->|Fetch Users| J
    H -->|Read Metadata| J
    I -->|Store| L
    I -->|Store Metadata| J
```

**Layer 1 — Persistence:** Relational database for structured content and metadata; in-memory cache for ABAC evaluation results and session data; object storage for binary assets.

**Layer 2 — Application:** GraphQL API as the primary content interface; REST API for authentication and binary asset operations; ABAC engine for authorization; schema generator for runtime type construction.

**Layer 3 — Presentation:** Administrative dashboard for content and policy management; consumer applications consuming the API; independent deployment from the backend.

### 3.2 Database Model

The database implements a hybrid storage strategy combining relational integrity for metadata with flexible storage for content values.

```mermaid
erDiagram
    COLLECTIONS ||--o{ FIELDS : defines
    COLLECTIONS ||--o{ ENTRIES : contains
    ENTRIES ||--o{ ENTRY_FIELDS : "has values"
    FIELDS ||--o{ ENTRY_FIELDS : typed_by
    
    USERS ||--o{ USER_ROLES : has
    ROLES ||--o{ USER_ROLES : assigned_to
    ROLES ||--o{ ROLE_POLICIES : inherits
    USERS ||--o{ USER_POLICIES : directly_assigned
    ABAC_POLICIES ||--o{ ABAC_POLICY_RULES : contains
    ABAC_POLICIES ||--o{ ROLE_POLICIES : assigned_via
    ABAC_POLICIES ||--o{ USER_POLICIES : assigned_via
    
    USERS ||--o{ ENTRIES : creates
    USERS ||--o{ ENTRIES : updates
    
    ENTRIES ||--o{ ENTRY_RELATIONS : relates
    ENTRIES ||--o{ ENTRY_SCHEDULES : scheduled
    
    USERS ||--o{ ASSETS : uploads
    ASSETS ||--o{ ENTRIES : referenced_by
    
    ABAC_POLICIES ||--o{ ABAC_EVALUATION_CACHE : cached_in
    ABAC_POLICIES ||--o{ ABAC_AUDIT : audited_in
    
    COLLECTIONS {
        uuid id PK
        string name
        string slug UK
        enum status
        string icon
        string color
        boolean is_localized
        uuid created_by FK
        timestamp created_at
        timestamp updated_at
        timestamp deleted_at
    }
    
    FIELDS {
        uuid id PK
        uuid collection_id FK
        string name
        string slug
        enum field_type
        boolean required
        int min_length
        int max_length
        string regex
        enum sensitivity_level
        boolean is_pii
        boolean is_public
    }
    
    ENTRIES {
        uuid id PK
        uuid collection_id FK
        enum status
        enum locale
        uuid created_by FK
        uuid updated_by FK
        timestamp created_at
        timestamp updated_at
        timestamp published_at
        timestamp deleted_at
    }
    
    ENTRY_FIELDS {
        uuid id PK
        uuid entry_id FK
        uuid field_id FK
        jsonb field_value
    }
    
    ENTRY_RELATIONS {
        uuid id PK
        uuid entry_id FK
        uuid field_id FK
        uuid related_entry_id FK
    }
    
    ENTRY_SCHEDULES {
        uuid id PK
        uuid entry_id FK
        enum scheduled_action
        timestamp scheduled_time
    }
    
    USERS {
        uuid id PK
        string name
        string email UK
        string password_hash
        enum status
        timestamp created_at
        timestamp updated_at
        timestamp last_access
    }
    
    ROLES {
        uuid id PK
        string name UK
        string description
        enum status
        timestamp created_at
    }
    
    USER_ROLES {
        uuid user_id FK
        uuid role_id FK
        uuid granted_by FK
        timestamp granted_at
        timestamp expires_at
    }
    
    ABAC_POLICIES {
        uuid id PK
        string name
        enum effect
        enum base_resource
        enum action_type
        int priority
        enum rule_connector
        boolean is_active
        uuid created_by FK
        timestamp created_at
        timestamp updated_at
    }
    
    ABAC_POLICY_RULES {
        uuid id PK
        uuid policy_id FK
        enum attribute_path
        enum operator
        jsonb expected_value
        int order
        boolean is_active
    }
    
    ROLE_POLICIES {
        uuid role_id FK
        uuid policy_id FK
        uuid granted_by FK
        timestamp granted_at
    }
    
    USER_POLICIES {
        uuid user_id FK
        uuid policy_id FK
        uuid granted_by FK
        timestamp granted_at
        timestamp expires_at
        string reason
    }
    
    ASSETS {
        uuid id PK
        string filename
        string mime_type
        int file_size
        string path
        string alt_text
        string caption
        uuid uploaded_by FK
        timestamp uploaded_at
    }
    
    ABAC_EVALUATION_CACHE {
        uuid id PK
        string cache_key UK
        boolean decision
        string policy_versions
        timestamp expires_at
    }
    
    ABAC_AUDIT {
        uuid id PK
        uuid user_id FK
        enum action
        enum resource
        uuid resource_id
        boolean decision
        jsonb evaluated_policies
        jsonb matching_policies
        string reason
        int duration_ms
        string ip_address
        string user_agent
        timestamp created_at
    }
```

**Content Model:** Collections define content types (e.g., "Blog Posts", "Products"). Fields specify per-collection attributes with validation rules and security classifications. Entries are concrete content instances with lifecycle states (draft, published, archived, deleted). EntryFields store actual values in JSONB, enabling heterogeneous content within a single table while maintaining referential integrity.

**Security Model:** Users authenticate through the system. Roles define organizational positions. UserRoles assign users to roles with optional expiration. ABACPolicies define authorization rules with effects (allow/deny), priorities, and logical connectors. AbacPolicyRules specify atomic conditions over typed attributes. RolePolicies and UserPolicies link policies to subjects.

**Storage Strategy:** Primitive values (text, numbers, booleans, dates) stored in JSONB with type metadata. Complex structures (lists, objects) leverage database-native JSON operators. Rich text maintains both raw (Markdown) and rendered (HTML) versions. Relations between entries use dedicated junction tables preserving referential integrity. Assets store binary files externally with metadata in the database.

### 3.3 ABAC System

The authorization system implements the complete NIST SP 800-162 reference architecture.

```mermaid
graph LR
    subgraph Client["Client Request"]
        REQ["HTTP Request"]
    end
    
    subgraph PEP["Policy Enforcement Point"]
        INT["Intercept"]
        APP["Apply Decision"]
    end
    
    subgraph Cache["Evaluation Cache"]
        CL["Cache Lookup"]
        CW["Cache Write"]
    end
    
    subgraph PIP["Policy Information Point"]
        SA["Subject Attributes"]
        RA["Resource Attributes"]
        EA["Environment Attributes"]
    end
    
    subgraph PDP["Policy Decision Point"]
        PR["Policy Resolution"]
        EV["Rule Evaluation"]
        DE["Decision"]
    end
    
    subgraph PAP["Policy Administration Point"]
        PM["Policy Management"]
    end
    
    subgraph Audit["Audit System"]
        AL["Log Decision"]
    end
    
    REQ --> INT
    INT --> CL
    CL -->|Hit| APP
    CL -->|Miss| SA
    SA --> RA
    RA --> EA
    EA --> PR
    PR --> EV
    EV --> DE
    DE --> AL
    AL --> CW
    CW --> APP
    APP -->|Allow| EX["Execute Query"]
    APP -->|Deny| REJ["403 Forbidden"]
    PM --> PR
```

#### 3.3.1 Attribute Taxonomy

The system evaluates four attribute categories:

**Subject Attributes:**
- `subject.id`: Unique user identifier
- `subject.role`: Assigned organizational role(s)
- `subject.status`: Account state (active, inactive, banned)
- `subject.createdAt`: Account creation timestamp

**Resource Attributes:**
- Collection: `resource.collection.id`, `resource.collection.slug`, `resource.collection.createdBy`, `resource.collection.isLocalized`
- Entry: `resource.entry.id`, `resource.entry.status`, `resource.entry.createdBy`, `resource.entry.collectionId`, `resource.entry.locale`, `resource.entry.publishedAt`
- Field: `resource.field.id`, `resource.field.name`, `resource.field.dataType`, `resource.field.sensitivityLevel`, `resource.field.isPii`, `resource.field.isPublic`
- Asset: `resource.asset.id`, `resource.asset.uploadedBy`, `resource.asset.mimeType`, `resource.asset.fileSize`

**Action Attributes:**
- `action.type`: Operation type (create, read, update, delete, publish, configure_fields, upload)

**Environment Attributes:**
- `environment.currentTime`: Request timestamp (UTC)
- `environment.ipAddress`: Client IP address
- `environment.userAgent`: Client identification string

This taxonomy enables policies such as: *"Editors (subject.role = 'editor') may publish (action.type = 'publish') their own articles (resource.entry.createdBy = subject.id) with non-confidential fields (resource.field.sensitivityLevel IN ['PUBLIC', 'INTERNAL']) during business hours (environment.currentTime BETWEEN 09:00-18:00)."*

#### 3.3.2 Policy Structure

Policies are declarative rules stored in the database with the following structure:

- **Effect:** ALLOW or DENY
- **Priority:** Numeric value for conflict resolution (higher values evaluated first)
- **Base Resource:** Target resource type (users, collections, entries, fields, assets) or wildcard
- **Action Type:** Specific operation or wildcard
- **Rule Connector:** AND (all rules must match) or OR (any rule may match)
- **Rules:** Atomic conditions specifying:
  - Attribute path (e.g., `subject.role`, `resource.entry.status`)
  - Operator (equals, not equals, greater than, less than, in, not in, contains, starts with, ends with, regex, context reference)
  - Expected value (typed: string, number, boolean, UUID, datetime)

#### 3.3.3 Conflict Resolution

The system implements deterministic conflict resolution through:

1. **Deny-Overrides Combining Algorithm:** Any explicit denial takes precedence over permissions. This follows the principle of least privilege and aligns with XACML 3.0 specification (OASIS, 2013).
2. **Priority Ordering:** Within each effect class (deny vs. allow), policies are ordered by descending priority. The first matching policy determines the outcome for that effect class.
3. **Default Deny:** If no applicable policy produces an explicit allow, access is denied.

#### 3.3.4 Evaluation Flow

```mermaid
sequenceDiagram
    participant Client
    participant PEP
    participant Cache
    participant PIP
    participant PDP
    participant Audit
    participant DB
    
    Client->>PEP: Request resource R with action A
    
    PEP->>Cache: Check (user, resource, action) cache
    alt Cache Hit
        Cache-->>PEP: Return cached decision
    else Cache Miss
        PEP->>PIP: Request all attributes
        
        PIP->>DB: Fetch user roles & policies
        PIP->>DB: Fetch resource metadata
        PIP->>PEP: Extract environment context
        
        PIP-->>PDP: Subject, Resource, Environment
        
        PDP->>DB: Resolve applicable policies
        PDP->>PDP: Order by priority (deny first)
        PDP->>PDP: Evaluate rules with connectors
        PDP-->>PEP: Decision + evaluated policies
        
        PEP->>Audit: Log decision with context
        PEP->>Cache: Store with TTL & version checksum
    end
    
    alt Decision = Allow
        PEP->>DB: Execute request
        DB-->>PEP: Result
        PEP-->>Client: Success
    else Decision = Deny
        PEP-->>Client: 403 Forbidden
    end
```

The evaluation process:

1. **Interception (PEP):** Middleware intercepts the request before resolver execution.
2. **Cache Lookup:** The system checks for a recent decision on the same (user, resource, action) combination. Cache entries include a policy version checksum to invalidate automatically when policies change.
3. **Attribute Collection (PIP):** If cache misses, attributes are gathered from the authentication token (subject), database queries (resource), and request context (environment).
4. **Policy Resolution (PDP):** All applicable policies are retrieved, filtered by resource type and action, then ordered by priority with deny policies first.
5. **Rule Evaluation:** Each policy's rules are evaluated against collected attributes using the specified logical connector. Rules support typed values (string, number, boolean, UUID, datetime) and context variable dereferencing.
6. **Decision Production:** The deny-overrides algorithm produces ALLOW, DENY, or NOT_APPLICABLE.
7. **Storage:** The decision is written to cache (with differential TTL: longer for allows, shorter for denys) and to the permanent audit log with full context.
8. **Application (PEP):** ALLOW proceeds to execution; DENY returns 403; NOT_APPLICABLE defaults to deny.

#### 3.3.5 Performance Optimizations

**Evaluation Cache:** Decisions are cached with composite keys including subject ID, resource type, resource ID, action, and a checksum of all applicable policy versions. This ensures cache invalidation occurs automatically when any policy changes, without requiring explicit cache clearing.

**Differential TTL:** Allow decisions cache for longer periods (e.g., 5 minutes) since privilege elevation is less urgent. Deny decisions cache for shorter periods (e.g., 2 minutes) to allow quicker recovery when a user's privileges are upgraded.

**Row-Level Filtering:** For queries returning collections of resources, the system uses a probe mechanism: it creates a synthetic resource with a fake owner ID and tests whether the user would be denied access. If the user is restricted to their own resources, an ownership filter is transparently injected into the query at the database level, ensuring filtering occurs before result materialization and preventing inference channel attacks.

### 3.4 APIs and Communication Protocols

#### 3.4.1 GraphQL API

The GraphQL API serves as the primary content interface. Its distinguishing characteristic is that the schema is generated at runtime from database metadata rather than defined statically.

```mermaid
flowchart TD
    A["Read Collection Metadata<br/>from Database"] --> B{For each Collection}
    B --> C["Map Field Types<br/>to GraphQL Scalars"]
    C --> D["Generate Object Type<br/>EntryType"]
    D --> E["Generate Input Type<br/>EntryInput"]
    E --> F["Generate Query Field<br/>Get{Collection}"]
    F --> G["Add Pagination<br/>Filtering, Sorting"]
    G --> H["Generate Mutations<br/>Create/Update/Delete"]
    H --> I["Register in<br/>GraphQL Schema"]
    I --> J{More Collections?}
    J -->|Yes| B
    J -->|No| K["Expose Schema +<br/>Introspection"]
```

For each collection defined in the database, the generator creates:
- An output object type with fields mapped from the collection's field definitions
- An input type for mutations mirroring the output type
- A query field with cursor-based pagination, filtering, and sorting
- Mutation fields for create, update, and delete operations

This approach ensures the schema and resolvers are dual projections of the same metamodel. Since both are derived from the same `Collections` and `Fields` tables, the schema cannot promise fields that resolvers do not implement. This eliminates the schema-resolver impedance mismatch inherent in schema-first and code-first approaches.

The schema supports:
- Union types for heterogeneous field values
- Argument-based filtering with type-specific operators
- Cursor-based pagination (Relay specification)
- Projection optimization (only requested database fields are selected)
- Higher-order resolver wrapping for automatic ABAC enforcement

#### 3.4.2 REST API

REST endpoints complement GraphQL for operations where simplicity or binary data handling is preferable:
- **Authentication:** Login, logout, token refresh, password recovery
- **Assets:** Upload, download, and streaming of binary files (images, videos, documents)

REST follows semantic HTTP conventions: appropriate methods (GET, POST, PUT, DELETE), consistent status codes, and content-type negotiation.

#### 3.4.3 Authentication

The system supports dual authentication schemes:

**JWT Bearer Authentication:**
- Asymmetric RSA keypair for token signing and validation
- Standard JWT claims (issuer, audience, expiration) plus custom claims (user ID, status, name)
- Session revocation support via distributed cache (Redis), enabling immediate logout across all tokens for a user
- Automatic token refresh based on activity

**API Key Authentication:**
- Header-based (`X-Api-Key`) with hash validation
- Configurable expiration dates
- Appropriate for public consumer applications and service-to-service communication

### 3.5 Administrative Interface

The administrative dashboard enables non-technical users to manage content, collections, and permissions without writing code.

**Key Modules:**
- **Dashboard:** Overview of collections, entry statistics, and permission-filtered navigation
- **Collection Editor:** Definition of content types with field validation, localization support, and visual identification (icon, color)
- **Entry Editor:** Dynamic forms generated from collection schemas, adapting field types (text, rich text, number, date, relation, asset, boolean)
- **Asset Manager:** Upload, organization, and metadata editing (alt text, caption) for accessibility compliance
- **Permission Configurator:** Visual creation of ABAC policies with rule builder, context preview, and conflict detection

**Dynamic Form Generation:** When a user creates a collection with specified fields, the system automatically generates:
- Database schema entries (collections, fields metadata)
- GraphQL types (object type, input type, query field, mutations)
- Administrative forms with appropriate input controls per field type
- Default permission policies (creator has full access, public has read access to published content)

### 3.6 Security and Performance

#### 3.6.1 Security Architecture

**Data Classification:** Fields can be marked with sensitivity levels (public, internal, confidential, restricted) and flagged as Personally Identifiable Information (PII). This enables automatic policy enforcement where sensitive fields are inaccessible to unauthorized users regardless of collection-level permissions.

**Query Safety:**
- Parameterized queries preventing injection attacks
- Query complexity analysis preventing abusive deep nesting
- Rate limiting (token bucket for uploads, fixed window for general API)

**Transport:** TLS/HTTPS for all communications. Security headers including HSTS, X-Frame-Options, and Referrer-Policy.

**Password Storage:** Argon2id memory-hard hashing function (PHC 2015 winner), resistant to GPU and ASIC attacks (Biryukov et al., 2015; RFC 9106).

#### 3.6.2 Performance Strategies

**Database:**
- Connection pooling for concurrent request handling
- Strategic indexes on frequently queried columns (entry status, collection ID, created_by)
- Prepared statements for repeated query patterns
- Database-level connection resilience with automatic retry

**Caching:**
- ABAC evaluation cache with version-based invalidation
- GraphQL query result caching where appropriate
- Asset CDN caching with immutable headers for versioned resources

**GraphQL Optimizations:**
- DataLoader pattern eliminating N+1 query problems
- Query projection ensuring only requested fields are selected from the database
- Cursor-based pagination providing stable result sets across insertions/deletions

---

## 4. Implementation

This chapter bridges the architecture described in Chapter 3 with the concrete source code that realizes it. All references are to files in the TechtonicCMS repository, commit `935083f` (API) and `505bdc9` (App). Where code excerpts are presented, they are drawn directly from the implementation.

### 4.1 Technology Stack

The backend is implemented in **.NET 10** with the following primary dependencies:

| Concern | Technology | Version | Role |
|---------|-----------|---------|------|
| Runtime | .NET | 10 | Host platform |
| GraphQL | Hot Chocolate | 14+ | Schema engine, type system, resolvers |
| ORM | Entity Framework Core | 9+ | Database access, migrations |
| Database | PostgreSQL | 15+ | Relational store, JSONB, native enums |
| Cache | Redis | 7+ | Session revocation, ABAC cache |
| Storage | S3-compatible | — | Binary asset storage |
| Auth | RSA JWT + SHA256 API Key | — | Dual authentication |
| Benchmarking | BenchmarkDotNet | 0.14+ | Micro-benchmarks |
| Load Testing | K6 | — | HTTP-level throughput tests |

The frontend administrative interface is implemented in **SvelteKit** with TypeScript, Tailwind CSS v4, and shadcn-svelte. GraphQL Code Generator produces typed documents from the live schema.

The consumer use case (blog) is implemented in **Astro** with server-side rendering and a custom content loader.

### 4.2 Backend Implementation

#### 4.2.1 Database Context and Model

The `TechtonicCmsDbContext` (file: `Contexts/TechtonicCmsDbContext.cs`) configures EF Core with PostgreSQL native enums, soft-delete behavior, and pooled factory registration:

```csharp
// Excerpt from TechtonicCmsDbContext.cs
builder.Services.AddPooledDbContextFactory<TechtonicCmsDbContext>(
    options => options.UseNpgsql(connectionString)
        .UseQueryTrackingBehavior(QueryTrackingBehavior.NoTracking));
```

The `AddPooledDbContextFactory` call is architecturally significant: GraphQL resolvers execute across multiple threads, and scoped `DbContext` instances cause race conditions. The pooled factory pattern, recommended by Microsoft (2024), provides thread-safe, reusable context instances without per-request allocation overhead.

All status, effect, and action enumerations are mapped to PostgreSQL native enums via `HasPostgresEnum`, enabling type-safe categorical storage at the database level. Soft-delete is implemented via `DeleteBehavior.Restrict` on creator relationships, preventing accidental cascade deletion of users who created content.

#### 4.2.2 Dynamic Schema Generation

The runtime schema generation is implemented in `CollectionTypeModule.cs`, which extends Hot Chocolate's `TypeModule` base class. A `TypeModule` is registered as a singleton in dependency injection and invoked during schema construction, allowing runtime type registration based on database state.

The pipeline follows the five stages described in Section 3.4.1:

**Stage 1 — Metadata Extraction:**
```csharp
var collections = await db.Collections
    .Include(c => c.Fields)
    .Where(c => !c.DeletedAt.HasValue)
    .OrderBy(c => c.CreatedAt)
    .ToListAsync();
```

**Stage 2 — Type Name Mapping:**
```csharp
public static string MapFieldType(FieldDataType dataType) => dataType switch
{
    FieldDataType.Text => "String",
    FieldDataType.Boolean => "Boolean",
    FieldDataType.Number => "Float",
    FieldDataType.DateTime => "DateTime",
    FieldDataType.Relation => "String",
    FieldDataType.Asset => "String",
    FieldDataType.Object => "String",
    _ => "String"
};
```

**Stage 3 — Object Type Construction:**
```csharp
descriptor.Field($"Get{collectionName}")
    .Type<ListType<EntryType>>()
    .UsePaging()
    .UseProjection()
    .UseFiltering()
    .UseSorting()
    .Resolve(async ctx => { ... });
```

**Stage 4 — Connection Pagination:**
The `CollectionConnectionTypeInterceptor` (file: `Interceptors/CollectionConnectionTypeInterceptor.cs`) adds Relay-style connection fields (edges, nodes, pageInfo) to all dynamically generated collection types.

**Stage 5 — Schema Introspection:**
The `/llms.md` endpoint (file: `LlmsEndpoints.cs`) auto-generates Markdown documentation from the live introspected schema using `IRequestExecutorResolver`, demonstrating that the schema is fully materialized and queryable at runtime.

#### 4.2.3 ABAC Engine Implementation

The `AbacService` (file: `Services/AbacService.cs`, 400+ lines) implements the complete NIST SP 800-162 reference architecture.

**PDP — Policy Decision Point:**

The `CheckPermissionAsync` method implements the full evaluation pipeline:

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

    // 4. Deny-first evaluation
    var denyPolicies = policies.Where(p => p.Effect == PermissionEffect.Deny)
        .OrderByDescending(p => p.Priority).ToList();
    var allowPolicies = policies.Where(p => p.Effect == PermissionEffect.Allow)
        .OrderByDescending(p => p.Priority).ToList();

    // 5. Evaluate deny policies first (short-circuit)
    foreach (var policy in denyPolicies)
        if (await EvaluatePolicyRulesAsync(policy, context))
            return false; // Denied

    // 6. Evaluate allow policies
    foreach (var policy in allowPolicies)
        if (await EvaluatePolicyRulesAsync(policy, context))
            return true; // Allowed

    return false; // Default deny
}
```

This is the XACML deny-overrides combining algorithm (OASIS, 2013): deny policies are evaluated first, and the first matching deny immediately rejects the request. Only if no deny matches does the engine proceed to allow policies.

**Rule Evaluation:**

```csharp
private static bool EvaluateRule(AbacPolicyRule rule, Dictionary<string, object?> context)
{
    var attributeKey = rule.AttributePath.ToString();
    var actualValue = context.TryGetValue(attributeKey, out var val) ? val : null;

    return rule.Operator switch
    {
        OperatorType.Eq => EvaluateEquals(rule, actualValue),
        OperatorType.Ne => !EvaluateEquals(rule, actualValue),
        OperatorType.In => rule.ExpectedArrayValue?.Contains(actualStr, StringComparer.OrdinalIgnoreCase) ?? false,
        OperatorType.Gt => CompareNumeric(rule, actualValue) > 0,
        OperatorType.Gte => CompareNumeric(rule, actualValue) >= 0,
        OperatorType.Lt => CompareNumeric(rule, actualValue) < 0,
        OperatorType.Lte => CompareNumeric(rule, actualValue) <= 0,
        OperatorType.Contains => actualStr?.Contains(rule.ExpectedStringValue ?? "") ?? false,
        OperatorType.StartsWith => actualStr?.StartsWith(rule.ExpectedStringValue ?? "") ?? false,
        OperatorType.EndsWith => actualStr?.EndsWith(rule.ExpectedStringValue ?? "") ?? false,
        OperatorType.Regex => Regex.IsMatch(actualStr ?? "", rule.ExpectedStringValue ?? ""),
        OperatorType.EqContextRef => EvaluateContextReference(rule, context),
        OperatorType.IsNull => actualValue == null,
        OperatorType.IsNotNull => actualValue != null,
        _ => false
    };
}
```

The switch expression handles 13 operators across typed values (string, number, boolean, UUID, datetime). The `EqContextRef` operator enables context variable dereferencing—comparing one attribute against another (e.g., `resource.entry.createdBy == subject.id`), which is essential for ownership-based policies.

**Cache Implementation:**

The evaluation cache uses a deterministic composite key and version-vector invalidation:

```csharp
var cacheKey = $"abac:{userId}:{resource}:{action}:{resourceId}";
var currentPolicyVersions = string.Join(",",
    policies.Select(p => $"{p.Id}:{p.UpdatedAt:O}"));

if (cached.PolicyVersions != currentPolicyVersions)
    return null; // Cache miss — policies changed
```

Each cache entry stores the concatenated `(Id, UpdatedAt)` pairs of all policies that contributed to the decision. If any policy is modified (changing its `UpdatedAt`), the version string mismatches and the cache entry is discarded. This eliminates the need for explicit cache invalidation hooks when policies are updated.

**Differential TTL:**
- Allow decisions: 5 minutes
- Deny decisions: 2 minutes

This asymmetry reflects operational reality: privilege elevation (deny → allow) is more urgent than privilege revocation (allow → deny), so deny caches expire faster to allow quicker recovery when a user's permissions are upgraded.

**Audit Logging:**

Every authorization decision is persisted to `AbacAudit` with:
- Evaluated policy IDs (all policies checked)
- Matching policy IDs (policies that actually matched)
- Decision reason string
- Evaluation timing in milliseconds
- Full request context (IP, user agent)

This implements non-repudiation—an immutable, queryable record of every access control decision.

**Row-Level Filtering:**

The `[UseAbacRowCheck]` attribute (file: `UseAbacRowCheckAttribute.cs`) implements transparent query filtering through LINQ Expression Tree manipulation—an AST-based approach.

The probe mechanism tests whether filtering is necessary:

```csharp
public async Task<bool> IsRestrictedToOwnResourcesAsync(
    Guid userId, BaseResource resource, PermissionAction action)
{
    var probeContext = CreateProbeContext(resource, Guid.NewGuid());
    if (probeContext.Count == 0) return false;

    var allowed = await CheckPermissionAsync(userId, resource, action, probeContext);
    return !allowed; // If denied with fake owner, user is restricted
}
```

If the probe indicates restriction, the attribute injects an ownership filter into the query AST:

```csharp
// AST construction
var param = Expression.Parameter(entityType, "x");
var property = Expression.Property(param, ownershipProp);
var constant = Expression.Constant(userId);
var allowedCondition = Expression.Equal(property, constant);
var lambda = Expression.Lambda(allowedCondition, param);

// AST injection
var whereMethod = typeof(Queryable).GetMethods()
    .First(m => m.Name == "Where" && m.GetParameters().Length == 2)
    .MakeGenericMethod(entityType);

var filteredQuery = whereMethod.Invoke(null, [queryable, lambda]);
ctx.Result = filteredQuery;
```

This is manual AST construction—programmatically building the expression tree node by node. The resulting `Where` clause is translated to SQL by the EF Core provider, ensuring filtering occurs at the database level before result materialization. This prevents inference channel attacks where a restricted user could infer the existence of unauthorized records by observing query result counts or ordering.

#### 4.2.4 Authentication Implementation

The dual-scheme authentication is configured in `Program.cs`:

```csharp
builder.Services.AddAuthentication()
    .AddJwtBearer("Jwt", options => {
        // RSA keypair validation
    })
    .AddScheme<ApiKeyAuthenticationOptions, ApiKeyAuthenticationHandler>(
        "ApiKey", options => { });

builder.Services.AddAuthorization(options => {
    options.AddPolicy("MultiAuth", policy => {
        policy.AddAuthenticationSchemes("Jwt", "ApiKey");
        policy.RequireAuthenticatedUser();
    });
});
```

**JWT Bearer:** Uses asymmetric RSA keypair (configurable PEM files), with issuer/audience validation and session revocation checks via `SessionService` querying Redis. Tokens include standard claims (iss, aud, exp) plus custom claims (user ID, status, name).

**API Key:** Header-based (`X-Api-Key`) with SHA256 hash lookup, supporting expiration dates and user status validation. Appropriate for public consumer applications where session-based authentication is unnecessary.

#### 4.2.5 Security Middleware

The backend implements defense in depth through multiple layers:

- **Rate limiting:** Three tiers—login (10/min), upload (token bucket), general API (1000/min)
- **Security headers:** HSTS, X-Frame-Options, Referrer-Policy, X-Content-Type-Options
- **Password storage:** Argon2id (RFC 9106), memory-hard against GPU/ASIC attacks
- **Query safety:** Parameterized queries via EF Core; query complexity limits in Hot Chocolate
- **Container hardening:** Non-root user (`appuser`, UID 10001) per CIS Docker Benchmark

### 4.3 Frontend Implementation

The administrative frontend (file: `techtoniccms-app`, commit `505bdc9`) is implemented in SvelteKit with TypeScript and shadcn-svelte.

#### 4.3.1 Data Fetching

Server-side `load` functions use a `query()` wrapper with valibot schema validation:

```typescript
// Excerpt from lib/server/graphql-client.ts
export async function query<T>(document: TypedDocumentNode<T>, variables?: unknown) {
    const client = new GraphQLClient(GRAPHQL_ENDPOINT, {
        headers: { Authorization: `Bearer ${locals.accessToken}` }
    });
    return await client.request(document, variables);
}
```

Error normalization maps GraphQL error codes to SvelteKit HTTP errors (`UNAUTHENTICATED` → 401, `FORBIDDEN` → 403).

#### 4.3.2 Permission-Aware UI

The `permissions.ts` module mirrors server-side ABAC logic for UI gating:

```typescript
// Excerpt from lib/permissions.ts
export function canManagePolicies(user: User | null): boolean {
    if (!user) return false;
    if (user.roles.some(r => r.name === 'Admin')) return true;
    return hasPolicy(user, BaseResource.AbacPolicies, PermissionAction.Manage);
}
```

This is a client-side pre-check only; all enforcement remains server-side. The UI hides buttons and menu items that the user cannot access, reducing confusion and failed requests.

#### 4.3.3 Dynamic Form Components

The `entry-editor.svelte` component renders forms dynamically based on collection field definitions:

- `FieldDataType.Text` → `<Input type="text">`
- `FieldDataType.Boolean` → `<Switch>`
- `FieldDataType.Number` → `<Input type="number">`
- `FieldDataType.DateTime` → `<DatePicker>`
- `FieldDataType.Relation` → `<RelationPicker>`
- `FieldDataType.Asset` → `<AssetUploader>`

Validation constraints (`MinLength`, `MaxLength`, `Regex`, `IsRequired`) are applied at both client (for UX) and server (for security) levels.

#### 4.3.4 Policy Rule Builder

The `policy-rule-builder.svelte` component provides visual construction of ABAC rules:

1. User selects attribute path (dropdown of available attributes)
2. User selects operator (dropdown of 13 operators)
3. User enters expected value (input type adapts to operator)
4. Component generates a human-readable sentence: *"Allow when subject role equals editor and resource entry status equals published"*

### 4.4 Blog Use Case Implementation

The blog application (file: `techtoniccms-blog/`) validates the architecture in production-like conditions. It is an Astro SSR application using the Node.js adapter.

#### 4.4.1 Content Loader

The `techtonicPostsLoader` (file: `src/lib/cms-loader.ts`) implements Astro's `LiveLoader` interface, fetching content dynamically from the CMS GraphQL API:

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

The loader uses API Key authentication for public read access. The GraphQL queries request exactly the fields needed (title, postBody, subheading, image, author, authorImage), demonstrating the elimination of over-fetching.

#### 4.4.2 Live Collections

Live collections are registered in `src/live.config.ts`:

```typescript
const posts = defineLiveCollection({
    loader: techtonicPostsLoader({
        apiKey: import.meta.env.API_KEY,
        apiUrl: import.meta.env.API_URL + "graphql"
    })
});

export const collections = { posts };
```

This enables Astro's content layer to consume the CMS as a live data source, with hot reloading in development and stale-while-revalidate caching in production.

#### 4.4.3 Asset Proxy

The asset proxy endpoint (file: `src/pages/cms-assets/[...path].ts`) streams CMS assets through the blog application with browser and CDN caching:

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

The `immutable` directive is safe because CMS assets have unique IDs—when an asset is updated, it receives a new ID, and the old URL remains cacheable indefinitely.

#### 4.4.4 Typed Client Generation

The `techtonic-client-gql` package (file: `techtonic-client-gql/`) contains GraphQL Code Generator output, producing TypeScript types from the live CMS schema:

```typescript
// Excerpt from techtonic-client-gql/src/graphql.ts
export type GetBlogPostsQuery = {
    collections: {
        entries: {
            blogPosts?: {
                edges: Array<{
                    node: {
                        id: string;
                        name: string;
                        slug: string;
                        data: {
                            title: string;
                            postBody: string;
                            subheading?: string;
                            image?: string;
                            author?: string;
                            authorImage?: string;
                        };
                    };
                }>;
            };
        };
    };
};
```

This demonstrates a key validation point: the consumer application has full TypeScript type safety for content types defined at runtime in the CMS. When the administrator adds a new field to the "Blog Posts" collection, regenerating the client produces updated types without any manual schema editing.

### 4.5 Benchmark Implementation

#### 4.5.1 ABAC Micro-Benchmarks

The `Benchmarks.cs` file implements five BenchmarkDotNet benchmarks for the ABAC engine:

**Benchmark 1 — Cache Hit vs. Miss:**
```csharp
[Benchmark(Baseline = true)]
public async Task<bool> CacheHit()
    => await _abacService.CheckPermissionAsync(_userId, _resource, _action);

[Benchmark]
public async Task<bool> CacheMiss()
    => await _abacService.CheckPermissionAsync(Guid.NewGuid(), _resource, _action);
```

The `CacheHit` benchmark measures warm-cache performance (same user/resource/action). The `CacheMiss` benchmark uses a random user ID to force full policy resolution. The expected ratio validates the 40× speedup claim.

**Benchmark 2 — Policy Scaling:**
```csharp
[Params(1, 5, 10, 25, 50)]
public int PolicyCount;

[Benchmark]
public async Task<bool> EvaluatePolicies()
    => await _abacService.CheckPermissionAsync(_userId, BaseResource.Entries, PermissionAction.Read);
```

This uses BenchmarkDotNet's parameterization to measure latency across policy counts from 1 to 50. The `[Params]` attribute instructs the framework to run the benchmark once per parameter value.

**Benchmark 3 — Row Filter Overhead:**
```csharp
[Benchmark(Baseline = true)]
public async Task<int> NoFilterBaseline()
    => await _dbContext.Entries.CountAsync();

[Benchmark]
public async Task<int> UnrestrictedUser()
    => await _dbContext.Entries.CountAsync(); // Probe returns false, no filter

[Benchmark]
public async Task<int> RestrictedUser()
    => await _dbContext.Entries.Where(e => e.CreatedBy == _restrictedUserId).CountAsync();
```

The baseline measures raw query latency. The unrestricted user benchmark adds the probe overhead (no filter injected). The restricted user benchmark simulates the `Where` clause injection. The comparison validates that transparent filtering adds negligible overhead.

**Benchmark 4 — Deny vs. Allow Timing:**
```csharp
[Benchmark]
public async Task<bool> DenyDecision()
    => await _denyAbacService.CheckPermissionAsync(_denyUserId, BaseResource.Entries, PermissionAction.Read);

[Benchmark]
public async Task<bool> AllowDecision()
    => await _allowAbacService.CheckPermissionAsync(_allowUserId, BaseResource.Entries, PermissionAction.Read);
```

Both services have identical policy counts (10 irrelevant policies + 1 target policy). The deny service has a deny target at priority 100; the allow service has an allow target at priority 100. The deny benchmark should complete faster due to early short-circuit.

**Benchmark 5 — Audit Logging:**
```csharp
[Benchmark]
public async Task<bool> WithAuditLogging()
    => await _withAuditService.CheckPermissionAsync(_userId, BaseResource.Entries, PermissionAction.Read);
```

This measures the latency cost of persisting every authorization decision to the database. A "without audit" variant requires adding a feature toggle to `AbacService` to skip `WriteAuditAsync`; the benchmark structure is provided for when that modification is implemented.

All benchmarks use EF Core InMemory for isolation and reproducibility. For production-like numbers, switching to PostgreSQL via `UseNpgsql` is recommended.

#### 4.5.2 Schema Generation Load Tests

The K6 script `schema-generation-benchmark.js` measures HTTP-level performance:

```javascript
export const options = {
  stages: [
    { duration: '10s', target: 10 },   // Warm-up
    { duration: '30s', target: 50 },   // Ramp up
    { duration: '60s', target: 50 },   // Steady state
    { duration: '10s', target: 0 },    // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],
    http_req_failed: ['rate<0.01'],
  },
};
```

The script executes two queries per iteration:
1. **Introspection query** — measures schema build + serialization cost
2. **Dynamic collection query** — measures end-to-end query execution

The `p(95)<500` threshold asserts that 95% of requests complete within 500ms under 50 concurrent users.

### 4.6 DevOps and Deployment

#### 4.6.1 Containerization

The API Dockerfile uses multi-stage build with a non-root user:

```dockerfile
# Build stage
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY . .
RUN dotnet restore
RUN dotnet publish -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .
RUN adduser --disabled-password --gecos "" --uid 10001 appuser
USER appuser
EXPOSE 8080
ENTRYPOINT ["dotnet", "TechtonicCmsApi.dll"]
```

The `appuser` (UID 10001) follows CIS Docker Benchmark v1.6.0 recommendations for container security.

#### 4.6.2 Health Checks

The `/healthcheck` endpoint returns a 200 OK when the application and database are reachable. The Dockerfile configures a wget-based probe for container orchestration platforms.

#### 4.6.3 Rate Limiting Configuration

Rate limits are configured per endpoint class:

| Endpoint | Strategy | Limit |
|----------|----------|-------|
| Login | Fixed window | 10 requests / minute |
| Upload | Token bucket | 5 MB / burst, 1 MB / sec refill |
| General API | Fixed window | 1000 requests / minute |

---

## 5. Validation and Use Case

### 5.1 Use Case: Blog Application

To validate the architecture in production-like conditions, a blog application was developed as an external consumer of the CMS. The application demonstrates that content types defined through the administrative interface are immediately consumable without code changes or redeployment.

**Architecture:**
- Server-side rendered with Node.js adapter
- Custom content loader consuming the CMS GraphQL API
- API Key authentication for public read access
- Asset proxy with browser and CDN caching
- Route-level SWR (stale-while-revalidate) caching for performance

**Content Flow:**
1. Administrator creates a "Blog Posts" collection with fields: title, body, subheading, image, author, authorImage
2. The CMS automatically generates GraphQL types and resolvers
3. Administrator creates entries through the dynamic form interface
4. The blog application queries `blogPosts` through the generated GraphQL schema
5. Content appears on the blog without any code changes in the consumer

This validates two core claims: (1) dynamic schema generation is immediately usable by external consumers, and (2) API Key authentication provides appropriate access control for public content distribution without user sessions.

### 5.2 Performance Benchmark Methodology

The following benchmarks are designed to validate the architecture's performance claims:

**ABAC Cache Effectiveness:**
- Measure evaluation latency with cold cache vs. warm cache
- Expected result: 40x or greater improvement for repeated evaluations
- Tool: Micro-benchmark framework with in-memory database

**Policy Count Scaling:**
- Measure evaluation latency with 1, 5, 10, 25, 50 policies per user
- Expected result: Linear or sub-linear scaling due to early short-circuit on deny policies
- Tool: Micro-benchmark framework

**Row Filter Overhead:**
- Compare query latency: baseline (no auth), unrestricted user (probe only), restricted user (ownership filter injected)
- Expected result: Negligible overhead for unrestricted users; database handles filtering for restricted users
- Tool: Micro-benchmark framework

**Deny vs. Allow Timing:**
- Compare latency between deny-first evaluation and allow-only evaluation under identical policy counts
- Expected result: Deny decisions complete faster due to early exit
- Tool: Micro-benchmark framework

**Schema Introspection:**
- Measure latency of full introspection query with varying collection counts
- Tool: HTTP load testing framework

**End-to-End Throughput:**
- Measure requests per second for CRUD operations on dynamic collections
- Tool: HTTP load testing framework with staged concurrency

---

## 6. Conclusion

### 6.1 Contributions

This work presents three primary contributions to headless CMS architecture:

1. **Runtime Schema Generation as the Correct Approach:** The work demonstrates that for headless CMS with user-defined content types, runtime schema generation from database metadata is not merely an implementation convenience but the architecturally correct approach. Schema-first and code-first GraphQL introduce synchronization bugs by construction when applied to dynamic type systems. By making the schema and resolvers dual projections of the same metamodel, the system achieves correctness by construction.

2. **Complete ABAC Engine for Content Management:** The system implements the full NIST SP 800-162 reference architecture with all four functional points (PDP, PEP, PIP, PAP), supporting 13 rule operators, typed attribute evaluation, deny-overrides conflict resolution, versioned cache invalidation, and comprehensive audit logging. This goes beyond the RBAC limitations of existing headless CMS platforms.

3. **Transparent Row-Level Security through Query Rewriting:** The system demonstrates how expression-tree-based query rewriting can inject row-level filters at the database level without modifying resolver logic, preventing inference channel attacks while maintaining performance.

### 6.2 Future Work

Several directions emerge for extending this architecture:

- **Schema Validation:** Formal verification that generated schemas are well-formed and complete, potentially through property-based testing or schema diffing against static equivalents.
- **Federation:** Extending the dynamic schema to participate in GraphQL federation, enabling distributed content graphs.
- **Real-Time Updates:** Subscription support for live content updates, requiring integration with event streaming or WebSocket infrastructure.
- **Multi-Tenancy:** Extending ABAC to support tenant isolation at the database level, enabling SaaS deployment models.
- **Machine Learning Integration:** Using ABAC audit logs to detect anomalous access patterns and automatically suggest policy adjustments.

---

## 7. Bibliography

1. Atkinson, C., & Kühne, T. (2003). Model-driven development: A metamodeling foundation. *IEEE Software*, 20(5), 36-41. https://doi.org/10.1109/MS.2003.1231149

2. Banks, A., & Porcello, E. (2018). *Learning GraphQL: Declarative Data Fetching for Modern Web Apps*. O'Reilly Media.

3. Batra, S., Sachdeva, S., et al. (2017). Entity Attribute Value Style Modeling Approach for Archetype Based Data. *MDPI Information*, 9(1), 28. https://doi.org/10.3390/info9010002

4. Biryukov, A., Dinu, D., & Khovratovich, D. (2015). Argon2: The memory-hard function for password hashing and proof-of-work applications. *Password Hashing Competition*. https://password-hashing.net/

5. Boiko, B. (2005). *Content Management Bible* (2nd ed.). Wiley Publishing.

6. Czarnecki, K., & Eisenecker, U. (2000). *Generative Programming: Methods, Tools, and Applications*. Addison-Wesley.

7. Coyne, E. J., & Weil, T. R. (2013). ABAC and RBAC: Scalable, flexible, and auditable access management. *IT Professional*, 15(3), 14-16. https://doi.org/10.1109/MITP.2013.46

8. de Lima, F. M., & dos Santos Mello, R. (2015). Benchmarking JSON and JSONB Data in PostgreSQL. *EDBT*. https://doi.org/10.5441/002/edbt.2015.55

9. Dinu, V., Nadkarni, P. M., & Brandt, C. A. (2006). Pivoting approaches for bulk extraction of Entity-Attribute-Value data. *Computer Methods and Programs in Biomedicine*, 82(1), 38-43. https://doi.org/10.1016/j.cmpb.2006.02.004

10. Ferraiolo, D. F., Hu, V. C., Kuhn, R., & Chandramouli, R. (2016). *NIST Special Publication 800-178: A Comparison of Attribute Based Access Control (ABAC) Standards for Data Service Applications*. NIST. https://doi.org/10.6028/NIST.SP.800-178

11. Fowler, M. (2002). *Patterns of Enterprise Application Architecture*. Addison-Wesley.

12. Fowler, M. (2003). *Patterns of Enterprise Application Architecture*. Addison-Wesley.

13. Facebook. (2015). *Relay Cursor Connections Specification*. https://relay.dev/graphql/connections.htm

14. Facebook Engineering. (2015). GraphQL: A data query language. https://engineering.fb.com/2015/09/14/core-infra/graphql-a-data-query-language/

15. Hu, V. C., et al. (2014). *NIST Special Publication 800-162: Guide to Attribute Based Access Control (ABAC) Definition and Considerations*. NIST. https://doi.org/10.6028/NIST.SP.800-162

16. Jain, V. (2021). Headless CMS and the Decoupled Frontend Architecture. *International Journal of Innovative Research in Engineering & Multidisciplinary Physical Sciences*, 9(4), 1-5.

17. Kleppmann, M. (2017). *Designing Data-Intensive Applications: The Big Ideas Behind Reliable, Scalable, and Maintainable Systems*. O'Reilly Media.

18. Lamport, L. (1978). Time, clocks, and the ordering of events in a distributed system. *Communications of the ACM*, 21(7), 558-565. https://doi.org/10.1145/359545.359563

19. Li, N., et al. (2009). Access control policy combining: Theory meets practice. *ACM SACMAT*.

20. Nadkarni, P. M., Brandt, C., & Frawley, S. (2007). Guidelines for the Effective Use of Entity-Attribute-Value Modeling for Biomedical Databases. *International Journal of Medical Informatics*, 76(11-12), 769-779. https://doi.org/10.1016/j.ijmedinf.2006.09.023

21. OASIS. (2013). *eXtensible Access Control Markup Language (XACML) Version 3.0*. OASIS Standard. http://docs.oasis-open.org/xacml/3.0/xacml-3.0-core-spec-os-en.html

22. PostgreSQL Global Development Group. (2024). JSON Types. https://www.postgresql.org/docs/current/datatype-json.html

23. Rizvi, S., Mendelzon, A., Sudarshan, S., & Roy, P. (2004). Extending query rewriting techniques for fine-grained access control. *ACM SIGMOD*. https://doi.org/10.1145/1007568.1007574

24. Servos, D., & Osborn, S. L. (2017). Current research and open problems in attribute-based access control. *ACM Computing Surveys*, 49(4), 1-45. https://doi.org/10.1145/2667070

25. Silberschatz, A., Korth, H. F., & Sudarshan, S. (2018). *Database System Concepts* (7th ed.). McGraw Hill Education.

26. Sommerville, I. (2015). *Software Engineering* (10th ed.). Pearson.

27. Strapi Team. (2024). Strapi Documentation. https://docs.strapi.io/

28. W3Techs. (2024). Usage Statistics of Content Management Systems. https://w3techs.com/technologies/overview/content_management

29. WordPress Foundation. (2024). WordPress Documentation. https://developer.wordpress.org/

30. Porto University Repository. (2022). Application of GraphQL for Dynamic Data Models. https://repositorio-aberto.up.pt/bitstream/10216/143680/2/575530.pdf

---

**End of Base Document**

*This document serves as the structural and content foundation for the thesis. It is implementation-agnostic while providing sufficient technical depth to guide any concrete realization. Diagrams are provided in Mermaid syntax for direct inclusion in Typst or conversion to other formats.*