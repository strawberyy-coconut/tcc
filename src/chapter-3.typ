
= Conceito e Design do Sistema

Este capítulo apresenta o design conceitual do sistema, descrevendo a arquitetura, o modelo de dados, os subsistemas de autenticação e controle de acesso, e os principais fluxos de operação. O foco está em _o que_ o sistema faz e _por que_, sem considerar detalhes de implementação ou tecnologias específicas, que são abordados no Capítulo 4.

== Arquitetura do Sistema

O sistema adota arquitetura em três camadas com separação clara de responsabilidades e comunicação via interfaces bem definidas.
#pagebreak()
#figure(
  image("diagramas/system-diagram.png"),  caption: [Diagrama de componentes do TechtonicCMS — camadas Cliente, API e Dados]
) <fig-system-diagram>

#align(left)[#text(size: 10pt)[Fonte: Criação do autor.]]

=== Camadas Arquiteturais

*Camada de Persistência*:
- Banco de dados relacional para dados estruturados, relacionais e cache de avaliações ABAC
- Sistema de cache em memória para sessões de usuário

*Camada de Aplicação*:
- API GraphQL como interface exclusiva de consulta e mutação
- Endpoints auxiliares para operações binárias (upload e download de assets)
- Motor ABAC integrado para controle de acesso

*Camada de Apresentação*:
- Painel administrativo para gerenciamento de conteúdo
- Frontend consumidor pode ser implementado em qualquer tecnologia

=== Decisões Arquiteturais

A arquitetura foi projetada priorizando:
#linebreak()
*Separação de Responsabilidades*: Cada camada possui escopo bem definido, facilitando manutenção e evolução independente dos componentes.
#linebreak()
*Desacoplamento via APIs*: A comunicação entre camadas ocorre exclusivamente através de interfaces contratuais, permitindo substituição de implementações sem impacto em outras camadas.
#linebreak()
*Escalabilidade Horizontal*: As camadas podem escalar independentemente baseado na demanda específica de cada componente.
#linebreak()
*Flexibilidade Tecnológica*: A camada de apresentação não está acoplada a nenhuma tecnologia específica, permitindo múltiplas implementações consumindo as mesmas APIs.

== Modelagem do Banco de Dados

A modelagem de dados utiliza abordagem unificada baseada em armazenamento JSON para conteúdo dinâmico, eliminando a fragmentação do padrão EAV. Metadados estruturais (coleções, campos) permanecem em tabelas tipadas, enquanto valores concretos de entrada são persistidos em uma única coluna de dados semi-estruturados, acessível via funções de banco para filtragem e ordenação a nível de banco.

=== Entidades Principais

O sistema organiza dados em cinco entidades principais de conteúdo:
#linebreak()
*_Collections_ (Coleções)*: Define os tipos de conteúdo gerenciáveis (ex: "Artigos", "Produtos"). Cada coleção especifica seus campos através de metadados estruturados, suporte à internacionalização via múltiplos locales, e identificadores visuais (ícone, cor) para interface administrativa.
#linebreak()
*_Fields_ (Campos)*: Especifica os atributos de cada coleção incluindo tipo de dado (`Text`, `Boolean`, `Number`, `DateTime`, `Relation`, `Asset`, `Object`), regras de obrigatoriedade, unicidade e valores padrão. Campos de relacionamento definem referências entre coleções via `relatedCollectionId`.
#linebreak()
*_Entries_ (Entradas)*: Representa as instâncias concretas de conteúdo com estados bem definidos: `DRAFT` (rascunho em edição), `PUBLISHED` (publicado e visível), `ARCHIVED` (arquivado sem exibição), `DELETED` (deletado logicamente). Cada entrada possui locale específico e uma coluna `Data` que armazena todos os valores de campos dinâmicos em formato semi-estruturado. O suporte multilíngue é realizado através de entradas vinculadas por `defaultLocale`.
#linebreak()
*_Assets_ (Arquivos)*: Gerencia recursos binários (imagens, vídeos, documentos) armazenando metadados essenciais: `filename`, `mimeType`, `fileSize`, `path`, além de campos para acessibilidade (`alt` para leitores de tela, `caption` descritivo) e rastreamento de propriedade (`uploadedBy`, `uploadedAt`).
#linebreak()
*_EntrySchedules_ (Agendamentos)*: Controla transições de estado programadas para entradas. Cada agendamento especifica uma entrada alvo, um horário de execução (`scheduledTime`), uma ação a ser realizada (`Publish`, `Unpublish`, `Archive`, `Restore`, `Delete`) e um indicador de execução (`alreadyExecuted`). Um serviço de processamento assíncrono verifica agendamentos pendentes periodicamente e aplica as transições de estado correspondentes.
#linebreak()
*_ApiKeys_ (Chaves de API)*: Gerencia chaves de acesso para integração _machine-to-machine_. Cada chave é vinculada a um usuário, possui nome descritivo, hash criptográfico do valor, prefixo para identificação visual, data de expiração opcional, indicador de ativação e registro de último uso. Este mecanismo complementa a autenticação por sessão, oferecendo um canal _stateless_ para consumo programático da API.
#linebreak()
A Figura 3.2 apresenta em detalhe como essas entidades se relacionam, com destaque para a coluna de dados semi-estruturados unificada de entradas e a tabela de relacionamentos:

#figure(
  image("diagramas/database-diagram.png"),
  caption: [Diagrama ER do TechtonicCMS — esquema relacional com armazenamento semi-estruturado unificado e relacionamentos ABAC]
) <fig-collections-entries>

#align(left)[#text(size: 10pt)[Fonte: Criação do autor.]]

=== Estratégia de Armazenamento

Diferentemente do padrão EAV discutido no referencial teórico, o sistema utiliza uma abordagem de *armazenamento semi-estruturado unificado* para todos os valores dinâmicos de entrada. Cada entrada possui uma coluna `Data` que armazena todos os valores de campos — texto, números, booleanos, datas, objetos, listas — em uma única estrutura de dados semi-estruturada. Os metadados sobre quais campos existem e seus tipos permanecem na tabela `fields`, mas os valores concretos habitam em `Entry.Data`.

Esta estratégia elimina a necessidade de múltiplas tabelas de valores tipados (EAV), simplificando o schema e reduzindo a complexidade de joins. Para viabilizar filtragem e ordenação a nível de banco em campos dinâmicos, o sistema registra funções customizadas de extração de dados que operam diretamente sobre a coluna semi-estruturada, permitindo que queries como "título igual a 'Hello'" sejam executadas no banco sem carregar todas as entidades em memória.

*Relacionamentos entre Entradas*: Relacionamentos tipados entre entradas (ex: "Autor" referenciando "Usuários") utilizam uma tabela de junção `entry_relations` com restrição de unicidade por `(EntryId, FieldId)`, garantindo que cada campo de relacionamento em uma entrada aponte para no máximo um alvo. A integridade referencial é preservada via chaves estrangeiras em cascata.

*Exemplo Prático de Armazenamento*: Para uma coleção "Artigos de Blog" com campos heterogêneos, a entrada armazena todos os valores em `Data`:

#table(
  columns: 2,
  [*Campo*], [*Valor em Data*],
  [Título (pt)], [`{"title": "Introdução ao GraphQL", "locale": "pt"}`],
  [Título (en)], [`{"title": "Introduction to GraphQL", "locale": "en"}`],
  [Configurações], [`{"layout": "grid", "theme": "dark"}`],
  [Tags], [`{"tags": ["GraphQL", "API", "Tutorial"]}`],
  [Autor], [Referência via `entry_relations`]
)

O banco executa consultas dentro da estrutura semi-estruturada usando operadores nativos e funções de extração customizadas, como filtrar artigos por `theme='dark'` ou `title eq 'Hello'`.

=== Tabelas de Segurança e Controle de Acesso

O banco de dados inclui um conjunto completo de tabelas para implementar o sistema ABAC, conforme ilustrado na Figura 3.3:
#pagebreak()
#figure(
  image("diagramas/security-simplified.png", width: 100%),
  caption: [Tabelas de segurança (users, roles, policies, api_keys) e sua relação com as entidades de conteúdo (collections, entries, fields, assets, entry_schedules)]
) <fig-security-content>

#align(left)[#text(size: 10pt)[Fonte: Criação do autor.]]

As tabelas principais de segurança incluem:
#linebreak()
*users*: Armazena credenciais de autenticação com hash criptográfico de senha, status do usuário (`ACTIVE`, `INACTIVE`, `BANNED`), e timestamps de criação, último acesso e última modificação.
#linebreak()
*roles*: Define papéis organizacionais do sistema com identificador único, descrição funcional e metadados temporais.
#linebreak()
*user_roles*: Tabela associativa entre usuários e papéis com suporte a expiração temporal configurável, permitindo concessões temporárias de privilégios.
#linebreak()
*abac_policies*: Define políticas de controle de acesso com efeito (`ALLOW`/`DENY`), prioridade numérica para resolução de conflitos, escopo do recurso (`users`, `collections`, `entries`, `assets`, `fields`), tipo de ação controlada (operações granulares como `Create`, `Read`, `Update`, `Delete`, `Publish`, `Unpublish`, `Schedule`, `Archive`, `Restore`, `Activate`, `Deactivate`, `Upload`, `Download`, `ManageSchema`, `Wildcard`), e conector lógico (`AND`/`OR`) para composição de regras.
#linebreak()
*abac_policy_rules*: Regras atômicas de cada política especificando atributo a avaliar (ex: `subject.role`, `resource.entry.status`), operador de comparação (`eq`, `in`, `gt`, `contains`, `regex`), valor esperado serializado em JSON, e tipo do valor para parsing adequado.
#linebreak()
*role_policies* e *user_policies*: Atribuição de políticas a papéis (herança organizacional) e usuários (exceções individuais), com metadados de auditoria (`assignedBy`, `reason`, `expiresAt`).
#linebreak()
*resource_ownerships*: Rastreamento de propriedade de recursos com três categorias: `CREATOR` (criador original), `ASSIGNED` (designação manual), `INHERITED` (herança hierárquica). Suporta expiração temporal e auditoria de atribuições.
#linebreak()
*abac_evaluation_cache*: Cache persistente de avaliação armazenado no banco de dados relacional, utilizado para otimização de performance através de armazenamento de decisões recentes com TTL configurável e invalidação automática baseada em mudanças de políticas.
#linebreak()
*abac_audit*: Registro de auditoria completo de decisões de autorização para conformidade regulatória e análise forense, incluindo contexto da requisição e métricas de performance.
#linebreak()
*api_keys*: Armazena chaves de API vinculadas a usuários, com hash criptográfico do valor, prefixo para identificação, data de expiração, indicador de ativação e registro de último uso.
#linebreak()
A Figura 3.4 apresenta o diagrama completo com todas as tabelas do sistema ABAC e seus relacionamentos detalhados:

#figure(
  image("diagramas/security-complete.png", width: 100%),
  caption: [Diagrama completo do sistema ABAC mostrando todas as tabelas de segurança (policies, rules, cache, audit, api_keys) e suas relações com usuários e recursos]
) <fig-security-complete>

#align(left)[#text(size: 10pt)[Fonte: Criação do autor.]]

== Sistema de Controle de Acesso

Implementação do modelo ABAC discutido no referencial teórico, com políticas declarativas armazenadas no banco de dados e motor de avaliação integrado.

=== Arquitetura do ABAC

O sistema utiliza quatro componentes principais:
#linebreak()
*Políticas e Regras*: Políticas declarativas com efeito (permitir/negar), prioridade e conectores lógicos. Cada política contém regras que avaliam atributos do sujeito (usuário), recurso, ação e ambiente (horário, IP).
#linebreak()
*_Cache_ de Avaliação*: Sistema de _cache_ persistente no banco de dados que armazena decisões recentes, reduzindo drasticamente o tempo de autorização em operações frequentes.
#linebreak()
*Sistema de Auditoria*: _Log_ completo de todas as decisões incluindo contexto, políticas avaliadas e justificativa, essencial para _compliance_ e _debugging_.
#linebreak()
*Propriedade de Recursos*: Rastreamento de propriedade de recursos com três categorias (`CREATOR`, `ASSIGNED`, `INHERITED`), permitindo políticas baseadas em ownership de conteúdo.

=== Tipos de Atributos

O sistema avalia decisões baseado em atributos extraídos de quatro categorias, conforme definido no enum `attribute_path` do schema:
#linebreak()
*Atributos do Sujeito (Usuário)*:
- `subject.id`: Identificador único do usuário
- `subject.role`: Papel(éis) do usuário no sistema
- `subject.status`: Status atual (`ACTIVE`, `INACTIVE`, `BANNED`)
- `subject.createdAt`: Timestamp de criação da conta
#linebreak()
*Atributos do Recurso*:

Para coleções:
- `resource.collection.id`, `resource.collection.slug`: Identificadores
- `resource.collection.createdBy`: Criador da coleção
- `resource.collection.isLocalized`: Se suporta múltiplos idiomas

Para entradas:
- `resource.entry.id`, `resource.entry.status`: Identificador e estado (`DRAFT`, `PUBLISHED`, `ARCHIVED`, `DELETED`)
- `resource.entry.createdBy`, `resource.entry.collectionId`: Relações de propriedade
- `resource.entry.locale`, `resource.entry.publishedAt`: Internacionalização e publicação

Para campos:
- `resource.field.id`, `resource.field.name`, `resource.field.dataType`: Identificação e tipo
- `resource.field.collectionId`: Coleção proprietária

Para assets:
- `resource.asset.id`, `resource.asset.uploadedBy`: Identificação e propriedade
- `resource.asset.mimeType`, `resource.asset.fileSize`: Metadados do arquivo
#linebreak()
*Atributos da Ação*:
- `action.type`: Tipo de operação sendo requisitada, usando valores do enum `permission_actions` (ex: `Create`, `Read`, `Update`, `Delete`, `Publish`, `Unpublish`, `Schedule`, `Archive`, `Restore`, `Activate`, `Deactivate`, `Upload`, `Download`, `ManageSchema`, `Wildcard`)
#linebreak()
*Atributos Ambientais (Contexto)*:
- `environment.currentTime`: Timestamp UTC da requisição
- `environment.ipAddress`: Endereço IP de origem
- `environment.userAgent`: Identificação do cliente
#linebreak()
Esta combinação permite criar regras contextuais precisas como "editores (`subject.role = 'editor'`) podem publicar (`action.type = 'Publish'`) artigos do seu departamento (`resource.entry.createdBy = subject.id`) durante horário comercial (`environment.currentTime BETWEEN 09:00-18:00`)"

=== Resolução de Conflitos

O sistema implementa resolução determinística de conflitos através de:
- Prioridade numérica para ordenar políticas conflitantes
- Conectores lógicos (AND/OR) para combinar múltiplas condições
- Arquitetura "negar por padrão" seguindo o princípio de menor privilégio

Exemplo de política implementável usando a estrutura do sistema:

```
Policy: "Allow Entry Publication During Business Hours"
Effect: ALLOW
Resource Type: entries
Action: Publish
Rule Connector: AND

Rules:
  1. attribute: resource.entry.status
     operator: eq
     value: "DRAFT"
     
  2. attribute: subject.role
     operator: in
     value: ["editor", "admin"]
     
  3. attribute: environment.currentTime
     operator: gte
     value: "09:00:00"
     
  4. attribute: environment.currentTime
     operator: lte
     value: "18:00:00"
```

Esta política permite publicação de entradas em rascunho apenas para editores e administradores durante horário comercial.

=== Fluxo de Avaliação de Requisições

O processo de autorização segue uma sequência bem definida que balanceia segurança com performance:
#linebreak()
*1. Interceptação (PEP)*: O _Policy Enforcement Point_ intercepta a requisição antes de qualquer processamento. Em uma API GraphQL, isso ocorre através de _middlewares_ ou _higher-order functions_ que envolvem os resolvers.
#linebreak()
*2. Consulta ao Cache*: O sistema verifica se existe uma decisão em cache persistente no banco de dados para a combinação de usuário, recurso e ação. Decisões são cacheadas com tempo de expiração configurável para otimizar operações frequentes.
#linebreak()
*3. Coleta de Atributos (PIP)*: Se não houver cache válido, o _Policy Information Point_ coleta atributos de múltiplas fontes:
- Atributos do usuário: extraídos do token de autenticação (papel, departamento, status)
- Atributos do recurso: consultados no banco de dados (tipo, proprietário, status de publicação)
- Atributos ambientais: derivados da requisição (horário UTC, endereço IP, tipo de dispositivo)
#linebreak()
*4. Avaliação (PDP)*: O _Policy Decision Point_ executa o motor de decisão:
- Recupera todas as políticas aplicáveis ao tipo de recurso e ação
- Ordena políticas por prioridade (valor numérico descendente)
- Avalia condições de cada regra substituindo atributos por valores coletados
- Aplica algoritmo de combinação _deny-overrides_ (qualquer negação explícita prevalece)
- Produz veredicto final: ALLOW, DENY ou NOT_APPLICABLE
#linebreak()
*5. Armazenamento*: A decisão é armazenada em duas localizações:
- Cache persistente no banco de dados relacional (tabela `abac_evaluation_cache`) para otimizar requisições futuras idênticas, com invalidação automática baseada em mudanças de políticas
- Tabela de auditoria permanente com timestamp, contexto completo e justificativa
#linebreak()
*6. Aplicação (PEP)*: O _Policy Enforcement Point_ aplica o veredicto:
- ALLOW: Requisição prossegue para execução normal
- DENY: Retorna erro de autorização ao cliente
- NOT_APPLICABLE: Aplicado princípio _deny-by-default_, retorna negação
#linebreak()
Métricas típicas de performance: avaliação com cache em tempo constante, avaliação sem cache com latência proporcional à complexidade das políticas avaliadas.

=== Filtragem de Resultados Baseada em Permissões

Além da autorização binária (permitir ou negar uma operação), o sistema aplica filtragem em nível de linha (_row-level filtering_) sobre consultas que retornam múltiplos recursos. Quando um usuário solicita uma lista de entradas, coleções ou assets, o sistema determina, com base nas políticas ABAC aplicáveis, se o usuário está restrito a visualizar apenas recursos de sua própria propriedade ou se pode acessar recursos de outros usuários.
#linebreak()
O mecanismo opera da seguinte forma: antes de executar uma consulta que retorna uma coleção de recursos, o sistema verifica se existem políticas que restringem o acesso do usuário aos recursos que ele próprio criou. Caso essa restrição esteja configurada, a consulta é enriquecida com uma condição que filtra o resultado, retornando apenas os registros cujo criador corresponde ao identificador do usuário requisitante.
#linebreak()
Este comportamento garante que, por exemplo, um editor comum visualize apenas seus próprios rascunhos em uma listagem, enquanto um editor-chefe, sujeito a políticas diferentes, possa visualizar todos os artigos de todos os autores. A filtragem ocorre de forma transparente para o cliente da API, que recebe apenas os dados autorizados sem necessidade de aplicar filtros adicionais.
#linebreak()
A combinação de autorização por operação (impedir que um usuário execute `Publish` sem permissão) e filtragem de resultados (garantir que ele apenas visualize o que pode acessar) constitui uma defesa em profundidade: mesmo que um usuário descubra a existência de recursos alheios, não consegue lê-los nem operar sobre eles.

=== Modelo Formal de Decisão

O sistema implementa controle de acesso baseado em atributos como função de decisão matemática. Seja $u in U$ o usuário (sujeito), $r in R$ o tipo de recurso, $a in A$ a ação requisitada, e $"ctx"$ o contexto de avaliação composto por atributos do sujeito, recurso, ação e ambiente. A função de decisão $D$ produz um veredicto no conjunto $"Allow", "Deny"$:

$D = "Decide"(u, r, a, "ctx")$

O conjunto de políticas é unificado, não pré-particionado:

$P(u, r, a) = P_"role"(u, r, a) union P_"direct"(u, r, a)$

onde $P_"role"$ são políticas herdadas via _roles_ do usuário e $P_"direct"$ são políticas atribuídas diretamente ao usuário.

==== Função de Avaliação de uma Política

Cada política $p$ tem um conector lógico $lambda_p in {"AND", "OR"}$ e um conjunto de regras $R_p$:

$"Eval"(p, "ctx") = cases(
  and.big_(r in R_p) "EvalRule"(r, "ctx") & "se" lambda_p = "AND",
  or.big_(r in R_p) "EvalRule"(r, "ctx") & "se" lambda_p = "OR"
)$

onde cada regra atômica avalia um atributo contra um valor esperado via operador $omega$:

$"EvalRule"(r, "ctx") = "ctx"[r."attr"] med omega_r med r."value"$

com $omega in {=, in, >, >=, <, <=, "contains", "regex"}$.

==== Algoritmo de Decisão

O conjunto $P$ é ordenado por prioridade $pi(p) in NN$ e avaliado em duas passagens sequenciais, refletindo o _deny-overrides_ com _short-circuit_:

$D = cases(
  "Deny" & "se" exists p in P : "effect"(p) = "DENY" and "Eval"(p, "ctx") = top,
  "Allow" & "se" exists p in P : "effect"(p) = "ALLOW" and "Eval"(p, "ctx") = top,
  "Deny" & "caso contrário"
)$
avaliando _deny policies_ primeiro, em ordem $pi$ descendente — um _match_ causa retorno imediato sem avaliar _allow policies_.

==== Cache

A decisão real passa por _lookup_ antes da avaliação:

$D = cases(
  D_"cache" & "se" exists "cache"(u, r, a) and "valid"("cache"),
  "Decide"(u, r, a, "ctx") & "caso contrário"
)$
onde $"valid"("cache")$ verifica TTL e $"PolicyVersions"$ — a string concatenada de $(p."id" : p."updatedAt")$ de todas as políticas contribuintes. Se qualquer política foi modificada, o cache é descartado.

==== Filtragem em Nível de Linha

A decisão binária é complementada por uma função de filtragem que opera sobre conjuntos de recursos:

$"Filter"(u, r, a, S) = cases(
  S & "se" not "IsRestricted"(u, r, a),
  {x in S : x."createdBy" = u} & "caso contrário"
)$

onde $"IsRestricted"$ é determinado avaliando $"Decide"$ com um recurso sintético de _owner_ aleatório — se negar, o usuário está restrito aos próprios recursos.

Esta versão captura os três aspectos que o modelo original omitia: o conector lógico por política, o _short-circuit_ do _deny_, e o cache como camada anterior à decisão.

== Sistema de Autenticação

O sistema prevê dois mecanismos de autenticação complementares: autenticação baseada em sessão para usuários humanos e autenticação por chave de API para integrações _machine-to-machine_.

=== Autenticação por Sessão

Usuários humanos autenticam-se através de um fluxo de login que valida credenciais e estabelece uma sessão ativa. O sistema emite um par de tokens: um token de acesso de curta duração para requisições subsequentes e um token de renovação (_refresh_) de longa duração. O token de acesso transporta identidade, papéis e status do usuário, permitindo validação _stateless_ por qualquer instância do serviço. O token de renovação é _single-use_: ao ser consumido, é imediatamente invalidado e substituído por um novo par, prevenindo ataques de _replay_. Sessões são armazenadas em cache em memória com expiração automática, permitindo revogação instantânea sem consultas ao banco de dados persistente.

=== Autenticação por API Key

Integrações _machine-to-machine_ utilizam chaves de API transmitidas via _header_ de requisição. Cada chave é vinculada a um usuário do sistema, possui data de expiração configurável e pode ser revogada individualmente. O servidor armazena apenas o hash criptográfico da chave, juntamente com um prefixo para identificação visual. Um mecanismo de multi-autenticação determina, para cada requisição, se a credencial apresentada é um token de sessão ou uma chave de API, encaminhando para o validador apropriado.

== Agendamento de Conteúdo

O sistema prevê um mecanismo de agendamento que permite programar transições automáticas de estado para entradas de conteúdo. Este recurso viabiliza _workflows_ editoriais onde publicações, arquivamentos e outras operações podem ser executadas em horários futuros sem intervenção manual.

=== Estados e Transições

As entradas transitam entre quatro estados principais: `DRAFT` (rascunho em edição), `PUBLISHED` (publicado e visível), `ARCHIVED` (arquivado sem exibição) e `DELETED` (deletado logicamente). Além das transições manuais, o sistema permite agendar as seguintes ações: `Publish` (publicar), `Unpublish` (despublicar), `Archive` (arquivar), `Restore` (restaurar de arquivado) e `Delete` (remover).

=== Modelo de Agendamento

Cada agendamento vincula uma entrada a uma ação futura, especificando o horário de execução desejado. Um serviço de processamento assíncrono verifica periodicamente agendamentos pendentes cuja data de execução já foi atingida, aplica a transição de estado correspondente e marca o agendamento como executado. Este modelo garante que transições programadas ocorram mesmo que o sistema tenha sido indisponível no horário exato, desde que a verificação subsequente alcance o agendamento.

== Geração Dinâmica de Schema

Um dos pilares do design do sistema é a capacidade de gerar o schema da API de forma dinâmica, refletindo em tempo real as definições de coleções e campos armazenadas no banco de dados. Este mecanismo elimina a necessidade de recompilar ou reiniciar o serviço quando novos tipos de conteúdo são criados pela interface administrativa.

=== Modelo de Geração

Para cada coleção definida no banco de dados, o sistema constrói automaticamente um conjunto de tipos e operações GraphQL:
#linebreak()
*Tipos de Dados*: Representam a estrutura de cada entrada da coleção, incluindo campos escalares (texto, número, booleano, data) e campos de relacionamento que referenciam outras coleções.
#linebreak()
*Tipos de Entrada*: Definem o formato esperado para criação e atualização de entradas, com validações de obrigatoriedade e unicidade derivadas dos metadados da coleção.
#linebreak()
*Filtros e Ordenação*: Para cada campo tipado, o sistema gera inputs de filtro com operadores específicos ao tipo de dado (igualdade, comparação, contém, intervalo) e inputs de ordenação para classificação ascendente ou descendente.
#linebreak()
*Mutações*: Operações de escrita são geradas por coleção, incluindo criação, atualização, exclusão, publicação, despublicação, arquivamento e restauração de entradas.

=== Ciclo de Vida do Schema

O processo de geração ocorre em duas fases: descoberta e materialização. Na fase de descoberta, o sistema consulta as tabelas de metadados (`collections` e `fields`) para identificar todas as coleções e seus atributos. Na fase de materialização, os tipos são construídos e integrados ao schema executável da API. Quando uma nova coleção é criada ou um campo é modificado, o schema é reconstruído automaticamente, tornando as novas operações disponíveis imediatamente.

Este modelo assegura que o contrato da API esteja sempre sincronizado com o modelo de dados, eliminando inconsistências entre o backend e os consumidores da interface. A abordagem de evolução de schema em sistemas interativos, onde mudanças estruturais são propagadas incrementalmente, fundamenta esta capacidade de adaptação dinâmica sem interromper clientes conectados @wang2001schema; @kleppmann2017designing.

=== Tradução de Filtros e Ordenação para Consultas de Banco

Um diferencial do sistema de filtragem e ordenação é a tradução direta dos argumentos GraphQL para cláusulas nativas do banco de dados relacional. Em vez de carregar todos os registros em memória e aplicar filtros posteriormente, o sistema converte cada operador de filtro em uma condição equivalente a uma cláusula `WHERE` de SQL, e cada campo de ordenação em uma cláusula `ORDER BY`.
#linebreak()
*Operadores de Filtro*: Para cada tipo de dado, o sistema disponibiliza operadores semanticamente apropriados. Campos de texto suportam igualdade, contém, início com e término com. Campos numéricos e de data suportam comparações de maior, menor, maior ou igual, menor ou igual e igualdade. Campos booleanos suportam apenas igualdade. Campos de relacionamento suportam existência e pertencimento a conjuntos. Cada operador é mapeado para uma função de extração que opera diretamente sobre a coluna semi-estruturada, permitindo que o banco execute a filtragem sem materializar as entidades em memória.
#linebreak()
*Ordenação*: A ordenação por múltiplos campos é suportada através de uma lista de critérios, onde cada critério especifica um campo e uma direção (ascendente ou descendente). O sistema traduz essa lista para uma sequência de cláusulas `ORDER BY` aplicadas diretamente na consulta do banco.
#linebreak()
*Paginação*: Consultas que retornam coleções de entradas utilizam paginação baseada em cursor, onde o sistema traduz os parâmetros de paginação para cláusulas `LIMIT` e `OFFSET` (ou equivalentes) no SQL gerado. Isso evita o carregamento de grandes conjuntos de dados em memória e garante tempos de resposta consistentes mesmo com volumes elevados de conteúdo.
#linebreak()
A propriedade fundamental deste pipeline é que toda a filtragem, ordenação e paginação é expressa como uma única consulta composta, traduzida para um único comando SQL. Nenhum dado é materializado em memória até a projeção final dos campos solicitados pelo cliente GraphQL. Esta técnica de _predicate pushdown_ — empurrar os predicados de filtragem para a camada de persistência — é reconhecida como estratégia central de otimização de consultas em sistemas com grandes volumes de dados, pois minimiza a transferência de registros desnecessários entre o banco de dados e a aplicação @levy1994predicate.

=== Exemplo de Query Dinâmica

Para ilustrar o funcionamento do schema dinâmico, considere uma coleção "Artigos de Blog" com campos `title` (texto), `publishedAt` (data) e `author` (relacionamento com usuários). O sistema gera automaticamente os tipos e operações necessários para que um cliente possa executar consultas como:
#pagebreak()
```graphql
query {
  blogPosts(
    where: {
      data: {
        title: { contains: "GraphQL" }
        publishedAt: { gte: "2025-01-01" }
      }
    }
    order: { publishedAt: DESC }
    first: 10
  ) {
    edges {
      node {
        id
        name
        status
        data {
          title
          publishedAt
        }
        author {
          name
        }
      }
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
```

Neste exemplo, o cliente solicita os dez artigos mais recentes cujo título contém "GraphQL" e cuja data de publicação é posterior a 1º de janeiro de 2025, ordenados pela data de publicação em ordem decrescente. O sistema traduz esta consulta GraphQL para uma única query SQL que aplica as condições de filtro na coluna semi-estruturada, ordena pelo campo de data, limita o resultado a dez registros e retorna apenas os campos solicitados. Se o usuário requisitante estiver sujeito a políticas ABAC que restrinjam a visualização a recursos próprios, a consulta SQL também incluirá a cláusula de filtragem row-level antes da execução.

== APIs e Protocolos de Comunicação

O design da interface de comunicação prioriza uma API GraphQL como canal exclusivo para todas as operações de conteúdo, autenticação, autorização e administração. Não há API REST para CRUD de conteúdo, gerenciamento de sessões ou administração de políticas.

A escolha do GraphQL como protocolo principal justifica-se pela necessidade de consultas flexíveis em um sistema com schemas dinâmicos: clientes podem solicitar exatamente os campos necessários, eliminando _over-fetching_ e _under-fetching_. O schema é gerado dinamicamente a partir das definições de coleções no banco de dados, criando tipos de dados, filtros, ordenações e mutações específicos por coleção.

Quatro rotas auxiliares não-GraphQL complementam a API principal: upload de assets (operação multipart), download de assets, documentação automática do schema e _health check_ de disponibilidade.

== Interface Administrativa

O painel administrativo consome a API GraphQL para todas as operações, apresentando uma interface adaptativa que se ajusta automaticamente aos schemas definidos.

=== Características do Design

*Arquitetura Reativa*: Atualizações eficientes de interface baseadas em mudanças de estado.
#linebreak()
*Segurança de Tipos*: Integração com tipagem estática entre frontend e backend.
#linebreak()
*Interface Adaptativa*: Geração dinâmica de formulários e componentes específicos por tipo de campo.

=== Módulos Principais

*Painel de Controle*: Visão geral de coleções, estatísticas e navegação filtrada por permissões ABAC.
#linebreak()
*Editor de Coleções*: Definição de tipos de conteúdo com validação em tempo real.
#linebreak()
*Editor de Entradas*: Formulários gerados dinamicamente baseados no _schema_ da coleção.
#linebreak()
*Gerenciador de Assets*: Envio e organização de mídias com metadados de acessibilidade.
#linebreak()
*Configuração de Permissões*: Interface para criação e gerenciamento de políticas ABAC.

=== Exemplo de Uso: Criando uma Coleção

Para ilustrar o funcionamento da interface administrativa, considere o processo de criação de uma coleção "Artigos de Blog":
#linebreak()
*Etapa 1 - Definição Básica*: O usuário acessa o módulo "Nova Coleção" e configura propriedades fundamentais:
- Nome de exibição: "Artigos de Blog"
- Identificador técnico (_slug_): "blog_posts" (validado para unicidade)
- Descrição: "Publicações do blog institucional"
- Suporte multilíngue: Português (pt-BR) e Inglês (en-US)
- Ícone e cor para identificação visual no painel
#linebreak()
*Etapa 2 - Modelagem de Campos*: O sistema apresenta interface para adição dinâmica de campos. Para cada campo, o usuário especifica:

*Campo "Título"*:
- Tipo: `Text`
- Obrigatoriedade: Sim
- Multilíngue: Sim
- Validações: Comprimento mínimo 10, máximo 200 caracteres

*Campo "Conteúdo"*:
- Tipo: `Text`
- Obrigatoriedade: Sim
- Multilíngue: Sim

*Campo "Autor"*:
- Tipo: `Relation` → Coleção "Usuários"
- Cardinalidade: Um para um
- Obrigatoriedade: Sim (preenchido automaticamente com criador)

*Campo "Tags"*:
- Tipo: `Object`
- Obrigatoriedade: Não
- Multilíngue: Não
- Validações: Máximo 10 tags, cada tag máximo 30 caracteres
#linebreak()
*Etapa 3 - Configuração de Permissões*: O usuário define políticas ABAC específicas para esta coleção:
- Editores: podem criar e editar rascunhos próprios
- Editores-chefe: podem publicar qualquer artigo
- Público: pode ler artigos com status "publicado"
- Restrição temporal: Publicação apenas em horário comercial
#linebreak()
*Etapa 4 - Validação e Pré-visualização*: O sistema executa validação em tempo real:
- Verifica se há campos obrigatórios sem valor padrão
- Alerta sobre conflitos de permissões
- Mostra pré-visualização do formulário de edição que será gerado
- Estima tamanho de armazenamento baseado nos tipos de campos
#linebreak()
*Etapa 5 - Criação e Propagação*: Ao confirmar, o sistema executa automaticamente:
- Insere registros nas tabelas de metadados (`collections` e `fields`)
- Atualiza o schema da API com tipos dinâmicos correspondentes
- Cria formulário de edição no painel administrativo
- Registra operação na auditoria com timestamp e usuário responsável
