#import "../udf-tcc-template/template.typ"

= Referencial Teórico

Este capítulo apresenta o referencial teórico fundamental para compreensão dos conceitos, tecnologias e metodologias empregadas no desenvolvimento do sistema proposto, abrangendo desde fundamentos de CMS tradicionais até arquiteturas headless modernas e sistemas avançados de controle de acesso.

== Sistemas de Gerenciamento de Conteúdo (CMS)

Um Sistema de Gerenciamento de Conteúdo (ou CMS, da sigla em inglês _Content Management System_) é como um painel de controle para gerenciar o conteúdo de um site @manish2008content. Ele permite que pessoas sem conhecimento técnico possam criar, editar e publicar textos, imagens e vídeos em um site, sem precisar saber programação.

Pense no CMS como um editor de documentos, similar ao Microsoft Word, mas para sites. Em vez de precisar escrever código para adicionar uma nova notícia ou atualizar uma foto, você simplesmente usa uma interface visual, clica em botões e preenche formulários @boiko2005.

=== A Evolução dos CMS

Os sistemas de gerenciamento de conteúdo evoluíram significativamente desde o surgimento da web. Inicialmente, a publicação de conteúdo na internet exigia conhecimento técnico: desenvolvedores precisavam editar manualmente arquivos HTML e fazer upload via FTP para cada atualização no site @boiko2005.
#linebreak()
#linebreak()
Com o amadurecimento da web nos anos 2000, surgiram plataformas que simplificaram radicalmente este processo. Sistemas como WordPress (lançado em 2003) e Joomla (2005) democratizaram a criação de sites ao oferecer interfaces visuais intuitivas, permitindo que usuários sem conhecimento de programação pudessem gerenciar conteúdo @boiko2005; @wordpress2024docs; @joomla2024docs. Esta abordagem foi tão bem-sucedida que, atualmente, o WordPress sozinho é utilizado por mais de 40% de todos os sites da internet @w3techs2024usage.

Mais recentemente, observa-se o crescimento de uma arquitetura conhecida como CMS headless, onde o backend de gerenciamento de conteúdo é completamente separado do frontend de apresentação através de APIs @headless2021decoupled; @boiko2005; @caoxuanan2023headless. Esta separação oferece maior flexibilidade para distribuir o mesmo conteúdo através de múltiplos canais (web, aplicativos móveis, dispositivos IoT, etc.), respondendo às demandas de uma experiência digital cada vez mais diversificada.

=== Funções Fundamentais de um CMS

Um sistema de gerenciamento de conteúdo, independentemente de sua complexidade, realiza três funções fundamentais @boiko2005:

1. *Coleta (_Collection_)*: Criação ou aquisição de conteúdo de fontes existentes. Dependendo da origem, pode ser necessário converter o conteúdo para um formato padrão. Esta etapa inclui edição, segmentação em componentes menores e adição de metadados apropriados.

2. *Gerenciamento (_Management_)*: Armazenamento estruturado do conteúdo em um repositório, que consiste em registros de banco de dados e/ou arquivos contendo componentes de conteúdo e dados administrativos. Inclui controle de versões, workflow e administração de usuários.

3. *Publicação (_Publishing_)*: Disponibilização do conteúdo através da extração de componentes do repositório e construção de publicações direcionadas, como sites, documentos imprimíveis e newsletters. As publicações consistem em componentes organizados adequadamente, funcionalidades, informações padrão e navegação.

=== Três Tipos de CMS

Hoje existem três categorias principais de CMS @headless2021decoupled:
#linebreak()
*CMS Tradicionais*: Sistemas integrados onde backend e frontend formam um pacote único com forte acoplamento entre as camadas @headless2021decoupled; @wordpress2024docs. Exemplos como WordPress e Joomla são fáceis de usar e instalar, mas têm limitações quando se precisa de personalização avançada ou suporte a múltiplos canais de distribuição.
#linebreak()
*CMS _Headless_ (Desacoplados)*: Arquiteturas que separam completamente o gerenciamento de conteúdo da camada de apresentação através de APIs @headless2021decoupled; @boiko2005. Esta abordagem permite distribuir o mesmo conteúdo através de múltiplos canais (web, mobile, IoT) de forma agnóstica à tecnologia de frontend, oferecendo flexibilidade máxima para criar experiências personalizadas.
#linebreak()
*CMS Híbridos*: Combinam características de ambas as abordagens, oferecendo flexibilidade para escolher entre acoplamento tradicional ou arquitetura desacoplada conforme a necessidade específica do projeto @headless2021decoupled; @strapi2024docs.

== Arquitetura _Headless_: Separando a "Cabeça" do "Corpo"

Antes de entender a arquitetura headless, é importante conhecer dois conceitos fundamentais da arquitetura cliente-servidor @sommerville2015. Em sistemas distribuídos que são acessados pela internet, o usuário interage com um programa executando em seu computador local (como um navegador web ou aplicativo móvel), que se comunica com outro programa executando em um computador remoto (como um servidor web). Essa arquitetura cliente-servidor pode ser modelada em camadas lógicas, cada uma com responsabilidades distintas:
#linebreak()
#linebreak()
#linebreak()
*_Backend_ (Retaguarda)*: Corresponde às camadas de aplicação, manipulação de dados e banco de dados no servidor. Inclui o armazenamento de dados, a lógica de negócios que processa as informações, e o sistema de segurança que controla o acesso. É a parte "invisível" do sistema que executa no servidor, como os bastidores de um teatro onde todo o trabalho acontece.
#linebreak()
*_Frontend_ (Interface)*: Corresponde à camada de apresentação que executa no cliente. É responsável por apresentar informações ao usuário e gerenciar toda a interação - a interface gráfica, botões, formulários e menus. Executa no navegador do usuário (Chrome, Firefox, Safari) ou em aplicativos nativos, comunicando-se com o backend para buscar ou enviar dados. É como o palco do teatro onde a apresentação acontece.

=== O Que É um CMS _Headless_
#parbreak()
Em um CMS tradicional, a camada de apresentação (frontend) está fortemente acoplada à camada de gerenciamento de conteúdo (backend), formando uma aplicação monolítica. Isso significa que alterações na interface requerem modificações no sistema como um todo.

#pagebreak()
Um CMS _Headless_ implementa uma arquitetura desacoplada: a "cabeça" (_frontend_ - a camada de apresentação) está completamente separada do "corpo" (_backend_ - as camadas de dados e lógica de negócios) @headless2021decoupled; @fielding2000architectural. A comunicação entre essas camadas acontece exclusivamente através de uma API (_Application Programming Interface_ - Interface de Programação de Aplicações). Essa separação permite que cada camada seja desenvolvida, mantida e escalada de forma independente.

=== _API-First_: Construindo Pela Ponte de Comunicação

O conceito "_API-first_" significa que, ao construir o sistema, a primeira coisa que se define é a interface de comunicação (a API) entre as camadas @headless2021decoupled; @fielding2000architectural; @caoxuanan2023headless. Isso garante que o backend possa servir dados de forma consistente para qualquer tipo de cliente (web, móvel, IoT) desde o início do projeto.

Essa abordagem permite o "_Content as a Service_" (CaaS), ou "Conteúdo como Serviço": o conteúdo é disponibilizado através da API como um serviço independente. Múltiplos clientes podem consumir o mesmo conteúdo simultaneamente - sites, aplicativos móveis, dispositivos IoT, assistentes de voz - todos acessando a mesma fonte de dados através de chamadas à API.

=== Vantagens da Arquitetura _Headless_

*Liberdade Tecnológica*: Você pode usar as melhores ferramentas para cada parte @headless2021decoupled; @caoxuanan2023headless. Diferentes tecnologias de interface podem coexistir - site, aplicativo móvel e painel administrativo podem usar tecnologias distintas, mas todos consomem os mesmos dados do backend.
#pagebreak()
*Escalabilidade Independente*: A arquitetura desacoplada permite que cada componente escale de forma independente conforme sua demanda específica. Aplicando princípios de arquiteturas _shared-nothing_, onde cada componente utiliza recursos computacionais independentes @kleppmann2017designing, é possível aumentar recursos do frontend quando há picos de tráfego ou expandir o backend quando necessário processar mais conteúdo, sem afetar outros componentes do sistema.
#linebreak()
*Reutilização Máxima de Conteúdo*: O mesmo conteúdo pode ser consumido por múltiplos canais sem necessidade de duplicação @headless2021decoupled; @caoxuanan2023headless. Um artigo criado uma vez pode ser distribuído automaticamente para site, aplicativo móvel, assistentes de voz, smartwatches e outros dispositivos conectados.
#linebreak()
*Estratégia _Omnichannel_*: _Omnichannel_ significa "todos os canais" @headless2021decoupled; @caoxuanan2023headless. Você oferece uma experiência unificada para seus usuários em qualquer plataforma que eles escolham usar.

=== Desafios da Arquitetura _Headless_

A arquitetura _headless_ apresenta complexidades que devem ser consideradas @headless2021decoupled:
#linebreak()
*Maior Complexidade Técnica*: Diferentemente de sistemas monolíticos tradicionais que oferecem interfaces integradas prontas para uso, sistemas headless exigem que desenvolvedores compreendam conceitos de APIs, protocolos de comunicação cliente-servidor, e arquiteturas distribuídas @sommerville2015.
#linebreak()
*Coordenação Entre Equipes*: A separação entre frontend e backend requer coordenação cuidadosa entre equipes que trabalham em cada camada, garantindo que as interfaces de comunicação permaneçam consistentes e que mudanças sejam sincronizadas adequadamente. Em sistemas distribuídos, a coordenação adequada é essencial para manter a integridade e consistência dos dados @kleppmann2017designing.

== APIs e Protocolos de Comunicação

A comunicação entre as camadas de um sistema _headless_ ocorre exclusivamente através de interfaces bem definidas. Esta seção apresenta os principais padrões e protocolos empregados na construção de APIs modernas.

=== GraphQL: Uma Forma Mais Inteligente de Buscar Dados

Para ilustrar esses problemas, considere a seguinte analogia: ao pedir um prato específico em um restaurante, o garçom traz a refeição completa mesmo que o cliente só queira a salada; ou então o cliente precisa fazer três pedidos separados para montar sua refeição completa — um para o prato principal, outro para a bebida, outro para a sobremesa. Essa situação reflete dois problemas bem documentados na literatura sobre APIs @banks2018learning:
1. *_Over-fetching_*: Receber mais dados do que você precisa (desperdício de internet e processamento)
2. *_Under-fetching_*: Precisar fazer várias requisições separadas para conseguir todos os dados necessários (lentidão)

O GraphQL, criado pelo Facebook em 2012 e lançado publicamente em 2015 @graphql2015facebook, funciona como um cardápio inteligente. O cliente especifica exatamente os campos necessários, eliminando _over-fetching_ e _under-fetching_ inerentes a APIs REST tradicionais @banks2018learning; @hartig2018semantics. O GraphQL trabalha com duas operações principais: _queries_ (consultas de leitura) e _mutations_ (operações de escrita) @banks2018learning; @graphqlspec2025. Cada campo na API possui um _resolver_ correspondente — uma função que busca dados no repositório subjacente e os retorna no formato e tipo especificados pelo _schema_ @banks2018learning.

Para sistemas de gerenciamento de conteúdo, o GraphQL oferece vantagens específicas: suporte a _Union Types_ que permitem campos com diferentes tipos de dados, e argumentos de filtragem que viabilizam buscas precisas em campos de texto, numéricos e de data @banks2018learning; @hartig2018semantics.

=== Autenticação e Autorização em APIs

A autenticação em APIs modernas emprega diferentes mecanismos conforme o cenário de uso. Tokens de sessão baseados em JWT (_JSON Web Token_) constituem fichas de autenticação compactas e assinadas digitalmente, permitindo que o cliente prove sua identidade sem reenviar credenciais a cada requisição @jones2015jwt.

Para integração _machine-to-machine_, APIs frequentemente empregam chaves de acesso (API keys) transmitidas via _header_ de autorização, seguindo o padrão _Bearer_ definido pelo OAuth 2.0 @rfc6750. Este modelo diferencia-se de tokens de sessão por ser _stateless_ do ponto de vista do cliente, embora o servidor mantenha metadados de controle para rastreamento e revogação @elmalki2022impact.

=== Rate Limiting e Controle de Tráfego

_Rate limiting_ constitui uma camada de defesa contra abuso de APIs e negação de serviço. O código HTTP 429 (_Too Many Requests_), padronizado na RFC 6585 @rfc6585, sinaliza que o cliente excedeu sua cota. Padrões arquiteturais documentados por @serbout2023patterns; @elmalki2022impact descrevem estratégias como janela fixa, _token bucket_ e _sliding window_, cada uma com _trade-offs_ entre precisão e _overhead_ computacional.

== Segurança e Controle de Acesso

A segurança em sistemas de gerenciamento de conteúdo abrange desde o armazenamento seguro de credenciais até o controle granular sobre quem pode acessar quais recursos em quais condições.

=== Armazenamento Seguro de Credenciais

Argon2id, vencedor da _Password Hashing Competition_ de 2015 @biryukov2015argon2, é atualmente o algoritmo recomendado pelo OWASP para armazenamento de senhas, configurado como função _memory-hard_ que resiste a ataques paralelizados em GPU @owasp2023argon2. A migração transparente de hashes legados ao autenticar o usuário é uma prática defensiva reconhecida para elevar a segurança sem forçar _reset_ de senhas em massa.

=== Cache em Memória para Sessões

Sistemas de cache em memória, como Redis, são empregados para armazenamento temporário de dados de alta frequência de acesso, oferecendo TTL (_time-to-live_) automático e operações atômicas em batch @redis2024docs. Esta arquitetura permite redução de carga em bancos de dados relacionais e revogação instantânea de sessões sem consultas adicionais ao armazenamento persistente.

=== Headers de Segurança HTTP

A camada de transporte HTTP emprega _headers_ de segurança como mecanismo de defesa em profundidade contra vetores de ataque comuns. O OWASP documenta práticas recomendadas para proteção contra _clickjacking_ (`X-Frame-Options`), _MIME sniffing_ (`X-Content-Type-Options`), vazamento de informações por _referrer_ (`Referrer-Policy`), e ataques de interceptação (`Strict-Transport-Security`) @owasp2026secureheaders. Estes mecanismos constituem uma camada complementar à autenticação e autorização, dificultando a exploração de vulnerabilidades do navegador mesmo quando o acesso ao recurso é legítimo.

=== Controle de Acesso Baseado em Atributos (ABAC)

Sistemas de controle de acesso definem quem pode acessar quais recursos em um sistema. O modelo tradicional RBAC (_Role-Based Access Control_) associa permissões a papéis organizacionais: um usuário com papel "Editor" recebe todas as permissões definidas para esse papel @sandhu1996role. Embora amplamente utilizado @ferraiolo2003role, o RBAC apresenta limitações em ambientes complexos: explosão do número de papéis necessários, incapacidade de considerar atributos dinâmicos como horário e localização, e dificuldade em implementar controle granular fino @coyne2013abac.

O ABAC (_Attribute-Based Access Control_) representa evolução dos modelos de controle de acesso ao basear decisões de autorização em atributos de múltiplas dimensões @nist2014abac. Diferentemente do RBAC, que avalia apenas o papel do usuário, o ABAC considera atributos do sujeito (usuário), do recurso (objeto sendo acessado), da ação (operação requisitada) e do ambiente (contexto situacional como horário e localização) @servos2017abac.

==== Arquitetura e Componentes

A arquitetura ABAC, conforme especificada por @nist2014abac, compreende quatro componentes principais:
#pagebreak()
*Policy Decision Point (PDP)*: Motor de decisão que avalia políticas e atributos para produzir veredictos de autorização.
#linebreak()
*Policy Enforcement Point (PEP)*: Ponto de interceptação que requisita decisões ao PDP e aplica os veredictos.
#linebreak()
*Policy Information Point (PIP)*: Repositório de atributos que fornece informações contextuais ao PDP.
#linebreak()
*Policy Administration Point (PAP)*: Interface para criação e gerenciamento de políticas.
#linebreak()
Esta arquitetura permite expressar regras como "usuários do departamento X podem editar recursos confidenciais apenas durante horário comercial", combinando múltiplos atributos em uma única política @nist2014abac.

==== Padrões e Implementações

XACML (_eXtensible Access Control Markup Language_) constitui o padrão OASIS para especificação de políticas ABAC @oasis2013xacml. XACML define estrutura hierárquica de _rules_, _policies_ e _policy sets_, além de algoritmos de combinação (`deny-overrides`, `permit-overrides`) para resolução determinística de conflitos entre políticas @combiningpolicies2009.

_Open Policy Agent_ (OPA) emergiu como implementação moderna de ABAC, oferecendo linguagem declarativa Rego para especificação de políticas e arquitetura desacoplada _policy-as-code_ @openpolicyagentcontributors2024opa. Outras implementações incluem Casbin (biblioteca multi-linguagem) @casbin2024docs, AWS IAM com atributos baseados em tags @aws2024abac, e Apache Ranger para segurança de dados @ranger2024docs.

Para sistemas de gerenciamento de conteúdo, o ABAC oferece controle granular essencial: diferentes campos podem ter diferentes níveis de sensibilidade, e o acesso pode variar baseado em propriedade do conteúdo, status de publicação e contexto do usuário. Esta flexibilidade permite implementar requisitos complexos de segurança mantendo políticas centralizadas e auditáveis @nist2014abac.

== Modelagem de Dados Dinâmica e Flexível

A modelagem de dados para CMS que permitem definição dinâmica de tipos de conteúdo apresenta desafios únicos na engenharia de software. Segundo @kleppmann2017designing, sistemas que necessitam de flexibilidade de schema devem balancear cuidadosamente entre performance de consultas e adaptabilidade estrutural.

=== O Padrão _Entity-Attribute-Value_ (EAV)

O padrão _Entity-Attribute-Value_ (EAV), também conhecido como _object-attribute-value_ ou _open schema_, é uma abordagem tradicional para modelagem de dados com _schemas_ dinâmicos @nadkarni2007eav. No modelo EAV, os dados são armazenados em três colunas principais:

- *_Entity_*: Identifica a entidade sendo descrita (ex: ID do produto)
- *_Attribute_*: Nome do atributo (ex: "cor", "tamanho", "peso")
- *_Value_*: Valor do atributo (geralmente armazenado como texto)

#pagebreak()

#figure(
  image("diagramas/eav.png", width: 70%),
  caption: [Modelo básico de classes da estrutura de armazenamento EAV mostrando as três entidades principais e seus relacionamentos]
) <fig-eav-model>

#align(left)[#text(size: 10pt)[Fonte: Dinu e Nadkarni (2007) via ResearchGate (https://www.researchgate.net/figure/Basic-Class-Model-of-the-EAV-Storage-Structure-The-basic-class-model-of-the-EAV-storage_fig1_257884193).]]

Esta abordagem oferece flexibilidade máxima, pois novos atributos podem ser adicionados sem alterações na estrutura da tabela @batra2017eav. No entanto, o padrão EAV apresenta limitações significativas @nadkarni2007eav:
#linebreak()
*_Performance_ de Consultas*: Cada atributo requer uma linha separada na tabela, resultando em operações de JOIN complexas para reconstruir entidades completas. Consultas que em modelos tradicionais seriam simples tornam-se substancialmente mais lentas.
#linebreak()
*Perda de Tipagem*: Armazenar todos os valores como texto elimina as vantagens de tipos de dados nativos do banco, incluindo validação automática, otimizações de armazenamento e operações específicas por tipo.
#linebreak()
*Dificuldade de Indexação*: Índices tradicionais tornam-se menos efetivos quando todos os valores estão na mesma coluna, independentemente do tipo de dado ou semântica.
#linebreak()
*Complexidade de Consultas*: Queries SQL para filtrar ou ordenar por múltiplos atributos tornam-se extremamente verbosas e difíceis de manter.

=== Abordagens Híbridas Modernas

Para endereçar as limitações do EAV, arquiteturas modernas de CMS adotam estratégias híbridas que balanceiam flexibilidade com performance @kleppmann2017designing:
#linebreak()
*Tabelas Tipadas para Primitivos*: Tipos de dados simples e frequentemente consultados (texto, números, datas, booleanos) são armazenados em tabelas dedicadas com tipos nativos do banco de dados. Esta abordagem permite indexação eficiente e otimizações específicas por tipo @silberschatz2018database.
#linebreak()
*Armazenamento JSON para Complexidade*: Estruturas complexas como listas, objetos aninhados e dados semi-estruturados aproveitam suporte nativo de bancos relacionais modernos (PostgreSQL, MySQL 8+) para tipos JSON @postgresql2024json. Isso mantém flexibilidade estrutural enquanto oferece operadores de consulta especializados.
#linebreak()
*Funções de Banco de Dados para Consultas Dinâmicas*: Bancos relacionais modernos permitem registrar funções e stored procedures customizadas que operam sobre tipos complexos como JSON, viabilizando filtragem, extração e ordenação eficiente em schemas dinâmicos sem recorrer a múltiplos JOINs ou materialização em memória @krosing2013server; @postgresql2024jsonfunctions. Esta extensibilidade permite que o banco de dados execute operações especializadas diretamente sobre dados semi-estruturados, mantendo a performance próxima à de colunas tipadas nativas.
#linebreak()
*Metadados de Schema*: Informações sobre a estrutura dos dados (definição de campos, tipos, validações) são mantidas em tabelas de metadados. Esta abordagem de "Metadata Mapping" permite processar mapeamentos objeto-relacional de forma genérica através de código que interpreta os metadados, facilitando operações de leitura, inserção e atualização sem código repetitivo @fowler2002patterns.
#linebreak()
*Estratégias de Relacionamento*: Referências entre entidades são gerenciadas através de tabelas de junção dedicadas, preservando integridade referencial enquanto suportam cardinalidades variadas (um-para-um, um-para-muitos, muitos-para-muitos) @silberschatz2018database.
#linebreak()
Estas abordagens híbridas permitem que sistemas modernos de gerenciamento de conteúdo ofereçam a flexibilidade de schemas dinâmicos sem comprometer significativamente a performance das operações mais comuns.

=== Agendamento e Processamento Assíncrono

Sistemas modernos de gerenciamento de conteúdo empregam filas de tarefas assíncronas e serviços de agendamento em _background_ para executar operações pesadas — como publicação programada, arquivamento automático e processamento de mídia — sem bloquear a _thread_ principal da aplicação @prakash2016performance. Este padrão arquitetural viabiliza _workflows_ de conteúdo com transições temporais automáticas, onde o estado de uma entrada pode evoluir de acordo com regras de negócio e horários pré-determinados.

=== Otimização de Consultas por Push-Down de Predicados

A eficiência de consultas em sistemas com schemas dinâmicos depende da capacidade de empurrar condições de filtragem o mais próximo possível da fonte de dados — técnica conhecida como _predicate pushdown_ (empurrar predicado para baixo) @yan2023predicate. Em vez de carregar todos os registros em memória e aplicar filtros posteriormente, o sistema traduz os predicados da consulta diretamente para cláusulas nativas do banco de dados, como `WHERE` e `ORDER BY`.
#linebreak()
A otimização por _predicate move-around_ estende o conceito de _pushdown_ ao permitir que predicados sejam movidos entre blocos de consulta (views e subqueries), ampliando as oportunidades de aplicação de filtros em diferentes partes do grafo de consulta @levy1994predicate. Esta técnica é particularmente relevante em sistemas que gerenciam grandes volumes de dados semi-estruturados, onde a materialização prematura de resultados intermediários comprometeria a performance.
#linebreak()
Abordagens modernas de síntese automática de _predicate pushdown_ empregam técnicas de síntese de programas para gerar planos de execução ótimos, determinando automaticamente quais predicados podem ser empurrados para cada operador do plano de consulta. Esta síntese é especialmente valiosa em sistemas com schemas dinâmicos, onde a estrutura das consultas varia conforme os metadados definidos pelo usuário.

=== Geração Dinâmica de Schemas em APIs

A geração dinâmica de schemas em APIs GraphQL permite que o contrato da interface evolua em tempo real, refletindo as definições de tipos de conteúdo armazenadas em metadados. Diferentemente de APIs estáticas, onde os tipos são definidos em tempo de compilação, sistemas com geração dinâmica consultam o repositório de metadados para construir o schema executável @hartig2018semantics.
#linebreak()
A adoção automatizada de APIs GraphQL preservando _type safety_ apresenta desafios significativos: o sistema deve garantir que os tipos gerados dinamicamente sejam consistentes com o modelo de dados subjacente, evitando violações de tipagem em tempo de execução @hartig2018semantics. Técnicas de evolução de schema em sistemas interativos exploram modelos onde as mudanças estruturais são propagadas incrementalmente, minimizando o impacto sobre clientes já conectados @edwards2024schema.
#linebreak()
Estas abordagens fundamentam o design de sistemas que permitem aos usuários finais definir novos tipos de conteúdo sem intervenção de desenvolvedores, mantendo a integridade do contrato da API e a performance das consultas.

== Tecnologias de Interface Moderna

As tecnologias de interface modernas representam uma evolução significativa no desenvolvimento de aplicações web, oferecendo diferentes abordagens para gerenciamento de estado e atualização de interfaces de usuário. _Frameworks_ modernos como React, Vue, Svelte e SolidJS utilizam programação reativa e _virtual DOM_ (ou compilação direta) para otimizar atualizações de interface @kleppmann2017designing; @nagel2014codegen.
#linebreak()
Para aplicações de gerenciamento de conteúdo, as características das tecnologias de interface modernas oferecem vantagens específicas:
#linebreak()
*Tamanho Otimizado*: Tecnologias modernas oferecem pacotes menores e tempo de carregamento reduzido, beneficiando _dashboards_ administrativos que frequentemente incluem múltiplas bibliotecas especializadas. Svelte, por exemplo, compila componentes em código JavaScript otimizado, resultando em _bundles_ menores que frameworks tradicionais @svelte2024docs.
#linebreak()
*_Performance_ Consistente*: Técnicas modernas de atualização de interface, como o _Virtual DOM_ do React @react2024docs e a reatividade granular do SolidJS @solidjs2024docs, oferecem renderização mais eficiente para aplicações que manipulam grandes volumes de dados, como listas de entradas de conteúdo ou árvores de categorias.

== Trabalhos Correlatos

Para entender melhor o que este projeto oferece, é importante comparar com outros sistemas de gerenciamento de conteúdo existentes no mercado, identificando suas características, limitações e como este trabalho se diferencia.

=== WordPress: O Gigante Tradicional

O WordPress é o sistema de gerenciamento de conteúdo mais popular do mundo, usado por mais de 40% de todos os sites @w3techs2024usage. Lançado em 2003, consolidou-se como padrão _de facto_ para publicação web, com ecossistema de temas e plugins que cobre praticamente qualquer necessidade de site @wordpress2024docs.
#linebreak()
*Vantagens do WordPress sobre este projeto*:
- Ecossistema maduro com dezenas de milhares de plugins e temas verificados
- Instalação e configuração em minutos, sem necessidade de conhecimento técnico
- Comunidade de suporte massiva, documentação extensa e hospedagem otimizada disponível em praticamente qualquer provedor
- Sistema de _blocks_ (Gutenberg) para edição visual de conteúdo
- SEO integrado, cache, CDN e otimização de mídia via plugins consolidados
- Economia de escala: hospedagem barata, desenvolvedores abundantes, curva de aprendizado mínima
#linebreak()
*Diferenças Arquiteturais*:
#linebreak()
*Arquitetura*: O WordPress adota modelo monolítico onde backend, frontend e camada de apresentação estão fortemente acoplados @headless2021decoupled; @caoxuanan2023headless. Embora existam extensões para operar em modo _headless_, o sistema não foi projetado para essa arquitetura, resultando em complexidade adicional quando usado apenas como backend de APIs. Este projeto, por outro lado, adota arquitetura _headless_ nativa desde a concepção, priorizando desacoplamento e distribuição multi-canal.

*Escopo e Maturidade*: O WordPress é um produto com mais de vinte anos de desenvolvimento contínuo, testado em escala global e com garantias de estabilidade comprovadas. O TechtonicCMS é um protótipo acadêmico que explora conceitos arquiteturais específicos (ABAC, schemas GraphQL dinâmicos, armazenamento híbrido), não concorrente direto em termos de funcionalidade geral, ecossistema ou confiabilidade operacional.

=== Joomla: O Meio-Termo

O Joomla é um CMS tradicional lançado em 2005, conhecido por oferecer controle de usuários e sistema de permissões mais granular que o WordPress, com suporte nativo a múltiplos níveis de acesso (_Access Control Levels_) e gerenciamento de conteúdo multilíngue @joomla2024docs.
#linebreak()
*Vantagens do Joomla sobre este projeto*:
- Sistema de ACL nativo com grupos de usuários, níveis de acesso e permissões configuráveis por categoria e artigo
- Suporte multilíngue integrado sem necessidade de plugins adicionais
- Templates e extensões maduras, com comunidade ativa de desenvolvedores
- Interface administrativa completa com gerenciamento de menus, módulos e componentes
- Estabilidade comprovada em produção por quase duas décadas
#linebreak()
*Diferenças Arquiteturais*:
#linebreak()
*Arquitetura*: O Joomla mantém a estrutura monolítica característica de CMS tradicionais @headless2021decoupled, com forte acoplamento entre gestão de conteúdo e apresentação. Embora ofereça APIs para integração, não foi projetado como sistema _headless first_, apresentando limitações em arquiteturas multi-canal e escalabilidade distribuída. Este projeto explora uma abordagem oposta: desacoplamento total desde a concepção.
#linebreak()
*Escopo e Maturidade*: O Joomla é um produto consolidado com quase vinte anos de evolução, ecossistema de extensões estabelecido e uso comprovado em produção. O TechtonicCMS é um protótipo acadêmico focado em demonstrar conceitos específicos de arquitetura moderna (ABAC, schemas dinâmicos, GraphQL nativo), sem pretensão de equivalência funcional ou operacional.

=== Strapi: O Principal Concorrente _Headless_

O Strapi é o CMS _headless open-source_ mais maduro e amplamente adotado atualmente @strapi2024docs, com mais de cinco anos de desenvolvimento contínuo, ecossistema extenso de plugins e comunidade ativa. Como produto consolidado, oferece funcionalidades que excedem o escopo deste trabalho acadêmico:
#linebreak()
*Vantagens do Strapi sobre este projeto*:
- Suporte nativo a múltiplos bancos de dados (PostgreSQL, MySQL, MariaDB, SQLite)
- Sistema de plugins extensível com marketplace oficial
- Interface administrativa visual completa com internacionalização de UI
- Documentação de API automática (Swagger/OpenAPI)
- Migrations de banco de dados automatizadas e versionamento de schema
- Suporte a _webhooks_, _emailing_ e notificações integradas
- Editor de conteúdo rico (_rich text_) e componentes reutilizáveis
- Testes de produção, _performance tuning_ e estabilidade comprovada em larga escala
#linebreak()
*Semelhanças com este projeto*:
- Permite criar coleções de conteúdo personalizadas com tipos dinâmicos
- Oferece APIs GraphQL e REST para acesso ao conteúdo
- Suporta múltiplos tipos de dados (texto, número, mídia, relacionamentos)
#linebreak()
*Diferenças Arquiteturais*:
#linebreak()
*Controle de Acesso*: O Strapi utiliza RBAC tradicional @strapi2024docs, onde permissões são concedidas por papel e por tipo de conteúdo. Este projeto explora ABAC como prova de conceito, permitindo regras baseadas em atributos contextuais (horário, localização, propriedade de recurso) conforme @nist2014abac, embora sem a maturidade e cobertura funcional de um produto em produção.
#linebreak()
*Interface e APIs*: O Strapi oferece tanto REST quanto GraphQL como opções de primeira classe, enquanto este projeto adota GraphQL como interface exclusiva — uma decisão deliberada de simplicidade que reduz a superfície de manutenção, mas limita a compatibilidade com clientes que esperam REST.
#linebreak()
*Escopo e Maturidade*: O Strapi é um produto pronto para produção com garantias de estabilidade, _LTS_ e suporte comercial. O TechtonicCMS é um protótipo acadêmico focado em demonstrar conceitos específicos (ABAC, schema GraphQL dinâmico, armazenamento híbrido), não concorrente direto em termos de funcionalidade ou confiabilidade operacional.