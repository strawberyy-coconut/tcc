#import "../udf-tcc-template/template.typ": *
#import "@preview/mmdr:0.2.2": mermaid

// Document content
#show: udf-paper.with(
  title: "TechtonicCMS: Um Sistema de Gerenciamento de Conteúdo Headless",
  subtitle: "Uma Abordagem Moderna para CMS",
  authors: (
    (name: "Gustavo Medeiros Lima", student-id: "31466281"),
  ),
  course: "Ciência da Computação",
  advisor: "",
  city: "Brasília",
  year: 2025,
  bibliography: "../src/refs.yml"
)

#let breakpar = () => [
  #linebreak()
  #linebreak()
]

// ===========================================
// CAPÍTULO 1 - DEFINIÇÃO DO PROBLEMA, OBJETIVOS E METODOLOGIA
// ===========================================

= Introdução

O desenvolvimento de aplicações web modernas que integram conteúdo dinâmico com bancos de dados representa um desafio significativo para desenvolvedores, exigindo domínio de múltiplas tecnologias que abrangem desde a camada de apresentação até a lógica de negócios e persistência de dados. A complexidade aumenta quando consideramos requisitos não-funcionais como performance, responsividade, segurança e controle de acesso granular, além da necessidade de distribuir conteúdo através de múltiplos canais — sites, aplicativos móveis, assistentes de voz, dispositivos IoT @headless2021decoupled.
#breakpar()
Sistemas de gerenciamento de conteúdo (CMS) consolidaram-se como ferramentas essenciais da infraestrutura digital moderna. O WordPress, exemplo mais emblemático desta categoria, é utilizado por mais de 40% de todos os sites da internet @w3techs2024usage. Entretanto, a arquitetura monolítica de CMS tradicionais, onde backend e frontend estão fortemente acoplados, apresenta limitações evidentes frente às demandas de distribuição _omnichannel_ e personalização em escala @headless2021decoupled; @boiko2005.
#breakpar()
A arquitetura _headless_ emerge como resposta a estas limitações, propondo desacoplamento completo entre gestão de conteúdo e apresentação através de APIs @headless2021decoupled. Esta separação oferece flexibilidade tecnológica sem precedentes, enquanto requisitos crescentes de conformidade regulatória — como GDPR e LGPD — demandam controle de acesso granular com políticas baseadas em atributos contextuais @nist2014abac.
#breakpar()
Este trabalho apresenta o TechtonicCMS, um sistema de gerenciamento de conteúdo _headless_ que combina arquitetura desacoplada _API-first_, controle de acesso baseado em atributos (ABAC), e criação dinamica de esquemas GraphQL. O sistema demonstra como balancear usabilidade para editores não-técnicos, flexibilidade para desenvolvedores e requisitos rigorosos de segurança.

== Objetivos


Desenvolver um sistema de gerenciamento de conteúdo headless (CMS Headless) que permita a criação, edição e distribuição de conteúdo de forma desacoplada, oferecendo flexibilidade para desenvolvedores criarem interfaces personalizadas enquanto mantém a facilidade de uso para editores de conteúdo, demonstrando na prática as vantagens arquiteturais desta abordagem moderna em comparação aos CMS tradicionais.

=== Objetivos Específicos

1. Desenvolver uma interface administrativa web para facilitar o gerenciamento de conteúdo sem necessidade de ferramentas externas


== Metodologia

Este trabalho adota uma abordagem de pesquisa aplicada, combinando fundamentação teórica com desenvolvimento prático de um protótipo funcional. A metodologia está organizada em três etapas complementares:

=== Etapa 1: Pesquisa e Fundamentação Teórica

Revisão bibliográfica de fontes acadêmicas e técnicas sobre CMS, sistemas de controle de acesso (RBAC e ABAC), arquiteturas web modernas e APIs. Análise comparativa de sistemas existentes para identificar padrões e oportunidades de inovação. Analize de metodos de geração de esquemas GraphQL. Especificação dos requisitos funcionais e não-funcionais do sistema.

=== Etapa 2: Design e Modelagem

Modelagem do banco de dados relacional com suporte a schemas dinâmicos. Definição da arquitetura em camadas e especificação das interfaces REST e GraphQL. Projeto do sistema ABAC com suas políticas e regras de autorização.

=== Etapa 3: Implementação e Validação

Desenvolvimento incremental do protótipo em cinco fases:

*Fase 1 - Fundação*: Implementação da infraestrutura base (banco de dados, autenticação e estruturas para schemas dinâmicos).

*Fase 2 - Core*: Desenvolvimento das funcionalidades centrais de gerenciamento de coleções e entradas, incluindo o sistema ABAC.

*Fase 3 - APIs*: Construção das camadas REST e GraphQL com validação e otimização de consultas.

*Fase 4 - Interface*: Desenvolvimento do painel administrativo com formulários dinâmicos baseados nos schemas.

*Fase 5 - Validação*: Testes funcionais, de performance e segurança, seguidos de ajustes baseados nos resultados.

// ================================
// CAPÍTULO 2 - REFERENCIAL TEÓRICO
// ================================

= Referencial Teórico

Este capítulo apresenta o referencial teórico fundamental para compreensão dos conceitos, tecnologias e metodologias empregadas no desenvolvimento do sistema proposto, abrangendo desde fundamentos de CMS tradicionais até arquiteturas headless modernas e sistemas avançados de controle de acesso.

== Sistemas de Gerenciamento de Conteúdo (CMS)

Um Sistema de Gerenciamento de Conteúdo (ou CMS, da sigla em inglês _Content Management System_) é como um painel de controle para gerenciar o conteúdo de um site @nath2010content. Ele permite que pessoas sem conhecimento técnico possam criar, editar e publicar textos, imagens e vídeos em um site, sem precisar saber programação.
#breakpar()
Pense no CMS como um editor de documentos, similar ao Microsoft Word, mas para sites. Em vez de precisar escrever código para adicionar uma nova notícia ou atualizar uma foto, você simplesmente usa uma interface visual, clica em botões e preenche formulários @boiko2005.

=== A Evolução dos CMS

Os sistemas de gerenciamento de conteúdo evoluíram significativamente desde o surgimento da web. Inicialmente, a publicação de conteúdo na internet exigia conhecimento técnico: desenvolvedores precisavam editar manualmente arquivos HTML e fazer upload via FTP para cada atualização no site @boiko2005.
#linebreak()
#linebreak()
Com o amadurecimento da web nos anos 2000, surgiram plataformas que simplificaram radicalmente este processo. Sistemas como WordPress (lançado em 2003) e Joomla (2005) democratizaram a criação de sites ao oferecer interfaces visuais intuitivas, permitindo que usuários sem conhecimento de programação pudessem gerenciar conteúdo @headless2021decoupled; @boiko2005; @wordpress2024docs; @joomla2024docs. Esta abordagem foi tão bem-sucedida que, atualmente, o WordPress sozinho é utilizado por mais de 40% de todos os sites da internet @w3techs2024usage.
#breakpar()
Mais recentemente, observa-se o crescimento de uma arquitetura conhecida como CMS headless, onde o backend de gerenciamento de conteúdo é completamente separado do frontend de apresentação através de APIs @headless2021decoupled; @boiko2005. Esta separação oferece maior flexibilidade para distribuir o mesmo conteúdo através de múltiplos canais (web, aplicativos móveis, dispositivos IoT, etc.), respondendo às demandas de uma experiência digital cada vez mais diversificada.

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

Antes de entender a arquitetura headless, é importante conhecer dois conceitos fundamentais da arquitetura cliente-servidor @sommerville2010. Em sistemas distribuídos que são acessados pela internet, o usuário interage com um programa executando em seu computador local (como um navegador web ou aplicativo móvel), que se comunica com outro programa executando em um computador remoto (como um servidor web). Essa arquitetura cliente-servidor pode ser modelada em camadas lógicas, cada uma com responsabilidades distintas:
#linebreak()
#linebreak()
#linebreak()
*_Backend_ (Retaguarda)*: Corresponde às camadas de aplicação, manipulação de dados e banco de dados no servidor. Inclui o armazenamento de dados, a lógica de negócios que processa as informações, e o sistema de segurança que controla o acesso. É a parte "invisível" do sistema que executa no servidor, como os bastidores de um teatro onde todo o trabalho acontece.
#linebreak()
*_Frontend_ (Interface)*: Corresponde à camada de apresentação que executa no cliente. É responsável por apresentar informações ao usuário e gerenciar toda a interação - a interface gráfica, botões, formulários e menus. Executa no navegador do usuário (Chrome, Firefox, Safari) ou em aplicativos nativos, comunicando-se com o backend para buscar ou enviar dados. É como o palco do teatro onde a apresentação acontece.

=== O Que É um CMS _Headless_
#parbreak()
Em um CMS tradicional, a camada de apresentação (frontend) está fortemente acoplada à camada de gerenciamento de conteúdo (backend), formando uma aplicação monolítica. Isso significa que alterações na interface requerem modificações no sistema como um todo.

#linebreak()
Um CMS _Headless_ implementa uma arquitetura desacoplada: a "cabeça" (_frontend_ - a camada de apresentação) está completamente separada do "corpo" (_backend_ - as camadas de dados e lógica de negócios) @headless2021decoupled. A comunicação entre essas camadas acontece exclusivamente através de uma API (_Application Programming Interface_ - Interface de Programação de Aplicações). Essa separação permite que cada camada seja desenvolvida, mantida e escalada de forma independente.

=== _API-First_: Construindo Pela Ponte de Comunicação

O conceito "_API-first_" significa que, ao construir o sistema, a primeira coisa que se define é a interface de comunicação (a API) entre as camadas @headless2021decoupled. Isso garante que o backend possa servir dados de forma consistente para qualquer tipo de cliente (web, móvel, IoT) desde o início do projeto.

Essa abordagem permite o "_Content as a Service_" (CaaS), ou "Conteúdo como Serviço": o conteúdo é disponibilizado através da API como um serviço independente. Múltiplos clientes podem consumir o mesmo conteúdo simultaneamente - sites, aplicativos móveis, dispositivos IoT, assistentes de voz - todos acessando a mesma fonte de dados através de chamadas à API.

=== Vantagens da Arquitetura _Headless_

*Liberdade Tecnológica*: Você pode usar as melhores ferramentas para cada parte @headless2021decoupled. Diferentes tecnologias de interface podem coexistir - site, aplicativo móvel e painel administrativo podem usar tecnologias distintas, mas todos consomem os mesmos dados do backend.
#linebreak()
*Escalabilidade Independente*: A arquitetura desacoplada permite que cada componente escale de forma independente conforme sua demanda específica @headless2021decoupled. Aplicando princípios de arquiteturas _shared-nothing_, onde cada componente utiliza recursos computacionais independentes @kleppmann2017designing, é possível aumentar recursos do frontend quando há picos de tráfego ou expandir o backend quando necessário processar mais conteúdo, sem afetar outros componentes do sistema.
#linebreak()
*Reutilização Máxima de Conteúdo*: O mesmo conteúdo pode ser consumido por múltiplos canais sem necessidade de duplicação @headless2021decoupled. Um artigo criado uma vez pode ser distribuído automaticamente para site, aplicativo móvel, assistentes de voz, smartwatches e outros dispositivos conectados.
#linebreak()
*Estratégia _Omnichannel_*: _Omnichannel_ significa "todos os canais" @headless2021decoupled. Você oferece uma experiência unificada para seus usuários em qualquer plataforma que eles escolham usar.

=== Desafios da Arquitetura _Headless_

A arquitetura _headless_ apresenta complexidades que devem ser consideradas @headless2021decoupled:
#linebreak()
*Maior Complexidade Técnica*: Diferentemente de sistemas monolíticos tradicionais que oferecem interfaces integradas prontas para uso, sistemas headless exigem que desenvolvedores compreendam conceitos de APIs, protocolos de comunicação cliente-servidor, e arquiteturas distribuídas @sommerville2010.
#linebreak()
*Coordenação Entre Equipes*: A separação entre frontend e backend requer coordenação cuidadosa entre equipes que trabalham em cada camada, garantindo que as interfaces de comunicação permaneçam consistentes e que mudanças sejam sincronizadas adequadamente. Em sistemas distribuídos, a coordenação adequada é essencial para manter a integridade e consistência dos dados @kleppmann2017designing.

== APIs e Protocolos de Comunicação

A comunicação entre as camadas de um sistema _headless_ ocorre exclusivamente através de interfaces bem definidas. Esta seção apresenta os principais padrões e protocolos empregados na construção de APIs modernas.

=== GraphQL: Uma Forma Mais Inteligente de Buscar Dados

Imagine que você vai a um restaurante e pede um prato específico. Com APIs REST tradicionais, é como se o garçom trouxesse a refeição completa mesmo que você só quisesse a salada. Ou então você precisasse fazer três pedidos diferentes para conseguir montar sua refeição completa - um pedido para o prato principal, outro para a bebida, outro para a sobremesa.
#linebreak()
Isso causa dois problemas principais @banks2018learning:
1. *_Over-fetching_*: Receber mais dados do que você precisa (desperdício de internet e processamento)
2. *_Under-fetching_*: Precisar fazer várias requisições separadas para conseguir todos os dados necessários (lentidão)

O GraphQL, criado pelo Facebook em 2012 e lançado publicamente em 2015 @graphql2015facebook, funciona como um cardápio inteligente. O cliente especifica exatamente os campos necessários, eliminando _over-fetching_ e _under-fetching_ inerentes a APIs REST tradicionais @banks2018learning. O GraphQL trabalha com duas operações principais: _queries_ (consultas de leitura) e _mutations_ (operações de escrita) @banks2018learning. Cada campo na API possui um _resolver_ correspondente — uma função que busca dados no repositório subjacente e os retorna no formato e tipo especificados pelo _schema_ @banks2018learning.
#breakpar()
Para sistemas de gerenciamento de conteúdo, o GraphQL oferece vantagens específicas: suporte a _Union Types_ que permitem campos com diferentes tipos de dados, e argumentos de filtragem que viabilizam buscas precisas em campos de texto, numéricos e de data @banks2018learning.

=== Autenticação e Autorização em APIs

A autenticação em APIs modernas emprega diferentes mecanismos conforme o cenário de uso. Tokens de sessão baseados em JWT (_JSON Web Token_) constituem fichas de autenticação compactas e assinadas digitalmente, permitindo que o cliente prove sua identidade sem reenviar credenciais a cada requisição @jones2015jwt.
#breakpar()
Para integração _machine-to-machine_, APIs frequentemente empregam chaves de acesso (API keys) transmitidas via _header_ de autorização, seguindo o padrão _Bearer_ definido pelo OAuth 2.0 @rfc6750. Este modelo diferencia-se de tokens de sessão por ser _stateless_ do ponto de vista do cliente, embora o servidor mantenha metadados de controle para rastreamento e revogação @habib2025gateway.

=== Rate Limiting e Controle de Tráfego

_Rate limiting_ constitui uma camada de defesa contra abuso de APIs e negação de serviço. O código HTTP 429 (_Too Many Requests_), padronizado na RFC 6585 @rfc6585, sinaliza que o cliente excedeu sua cota. Padrões arquiteturais documentados por @serbout2023patterns descrevem estratégias como janela fixa, _token bucket_ e _sliding window_, cada uma com _trade-offs_ entre precisão e _overhead_ computacional.

== Segurança e Controle de Acesso

A segurança em sistemas de gerenciamento de conteúdo abrange desde o armazenamento seguro de credenciais até o controle granular sobre quem pode acessar quais recursos em quais condições.

=== Armazenamento Seguro de Credenciais

Argon2id, vencedor da _Password Hashing Competition_ de 2015 @biryukov2015argon2, é atualmente o algoritmo recomendado pelo OWASP para armazenamento de senhas, configurado como função _memory-hard_ que resiste a ataques paralelizados em GPU @owasp2023argon2. A migração transparente de hashes legados ao autenticar o usuário é uma prática defensiva reconhecida para elevar a segurança sem forçar _reset_ de senhas em massa.

=== Cache em Memória para Sessões

Sistemas de cache em memória, como Redis, são empregados para armazenamento temporário de dados de alta frequência de acesso, oferecendo TTL (_time-to-live_) automático e operações atômicas em batch @redis2024docs. Esta arquitetura permite redução de carga em bancos de dados relacionais e revogação instantânea de sessões sem consultas adicionais ao armazenamento persistente.

=== Controle de Acesso Baseado em Atributos (ABAC)

Sistemas de controle de acesso definem quem pode acessar quais recursos em um sistema. O modelo tradicional RBAC (_Role-Based Access Control_) associa permissões a papéis organizacionais: um usuário com papel "Editor" recebe todas as permissões definidas para esse papel @sandhu1996role. Embora amplamente utilizado @ferraiolo2003role, o RBAC apresenta limitações em ambientes complexos: explosão do número de papéis necessários, incapacidade de considerar atributos dinâmicos como horário e localização, e dificuldade em implementar controle granular fino @coyne2013abac.
#breakpar()
O ABAC (_Attribute-Based Access Control_) representa evolução dos modelos de controle de acesso ao basear decisões de autorização em atributos de múltiplas dimensões @nist2014abac. Diferentemente do RBAC, que avalia apenas o papel do usuário, o ABAC considera atributos do sujeito (usuário), do recurso (objeto sendo acessado), da ação (operação requisitada) e do ambiente (contexto situacional como horário e localização) @servos2017abac.

==== Arquitetura e Componentes

A arquitetura ABAC, conforme especificada por @nist2014abac, compreende quatro componentes principais:
#linebreak()
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
#breakpar()
_Open Policy Agent_ (OPA) emergiu como implementação moderna de ABAC, oferecendo linguagem declarativa Rego para especificação de políticas e arquitetura desacoplada _policy-as-code_ @openpolicyagentcontributors2024opa. Outras implementações incluem Casbin (biblioteca multi-linguagem) @casbin2024docs, AWS IAM com atributos baseados em tags @aws2024abac, e Apache Ranger para segurança de dados @ranger2024docs.
#breakpar()
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

#breakpar()
Esta abordagem oferece flexibilidade máxima, pois novos atributos podem ser adicionados sem alterações na estrutura da tabela @batra2016eav. No entanto, o padrão EAV apresenta limitações significativas @nadkarni2007eav:
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
*Metadados de Schema*: Informações sobre a estrutura dos dados (definição de campos, tipos, validações) são mantidas em tabelas de metadados. Esta abordagem de "Metadata Mapping" permite processar mapeamentos objeto-relacional de forma genérica através de código que interpreta os metadados, facilitando operações de leitura, inserção e atualização sem código repetitivo @fowler2002patterns.
#linebreak()
*Estratégias de Relacionamento*: Referências entre entidades são gerenciadas através de tabelas de junção dedicadas, preservando integridade referencial enquanto suportam cardinalidades variadas (um-para-um, um-para-muitos, muitos-para-muitos) @silberschatz2018database.
#linebreak()
Estas abordagens híbridas permitem que sistemas modernos de gerenciamento de conteúdo ofereçam a flexibilidade de schemas dinâmicos sem comprometer significativamente a performance das operações mais comuns.

=== Agendamento e Processamento Assíncrono

Sistemas modernos de gerenciamento de conteúdo empregam filas de tarefas assíncronas e serviços de agendamento em _background_ para executar operações pesadas — como publicação programada, arquivamento automático e processamento de mídia — sem bloquear a _thread_ principal da aplicação @prakash2016performance. Este padrão arquitetural viabiliza _workflows_ de conteúdo com transições temporais automáticas, onde o estado de uma entrada pode evoluir de acordo com regras de negócio e horários pré-determinados.

== Tecnologias de Interface Moderna

As tecnologias de interface modernas representam uma evolução significativa no desenvolvimento de aplicações web, oferecendo diferentes abordagens para gerenciamento de estado e atualização de interfaces de usuário. _Frameworks_ modernos como React @react2024docs, Vue @vue2024docs, Svelte @svelte2024docs e SolidJS @solidjs2024docs utilizam programação reativa e _virtual DOM_ (ou compilação direta) para otimizar atualizações de interface.
#linebreak()
Para aplicações de gerenciamento de conteúdo, as características das tecnologias de interface modernas oferecem vantagens específicas:
#linebreak()
*Tamanho Otimizado*: Tecnologias modernas oferecem pacotes menores e tempo de carregamento reduzido, beneficiando _dashboards_ administrativos que frequentemente incluem múltiplas bibliotecas especializadas. Svelte, por exemplo, compila componentes em código JavaScript otimizado, resultando em _bundles_ menores que frameworks tradicionais @svelte2024docs.
#linebreak()
*_Performance_ Consistente*: Técnicas modernas de atualização de interface, como o _Virtual DOM_ do React @react2024docs e a reatividade granular do SolidJS @solidjs2024docs, oferecem renderização mais eficiente para aplicações que manipulam grandes volumes de dados, como listas de entradas de conteúdo ou árvores de categorias.

== Trabalhos Correlatos

Para entender melhor o que este projeto oferece, é importante comparar com outros sistemas de gerenciamento de conteúdo existentes no mercado, identificando suas características, limitações e como este trabalho se diferencia.

=== WordPress: O Gigante Tradicional

O WordPress é o sistema de gerenciamento de conteúdo mais popular do mundo, usado por mais de 40% de todos os sites @w3techs2024usage. Ele representa o modelo tradicional de CMS monolítico onde todas as camadas estão fortemente acopladas @headless2021decoupled; @wordpress2024docs.
#linebreak()
*Pontos Fortes*: Fácil de usar, ecossistema extenso com milhares de temas e plugins, grande comunidade de suporte @wordpress2024docs.
#linebreak()
*Limitações*: A arquitetura monolítica dificulta escalabilidade em ambientes de alto tráfego e integração com múltiplos canais de distribuição @headless2021decoupled. Embora existam extensões para funcionar como headless CMS, o sistema não foi originalmente projetado para essa arquitetura, resultando em performance subótima quando usado apenas como backend.

=== Joomla: O Meio-Termo

O Joomla é uma alternativa ao WordPress que oferece controle de usuários e sistema de permissões mais robusto, mantendo a estrutura tradicional monolítica característica de CMS acoplados @headless2021decoupled; @joomla2024docs. Assim como outros CMS tradicionais, enfrenta limitações similares ao WordPress quando se trata de arquiteturas multi-canal e escalabilidade distribuída.

=== Strapi: O Principal Concorrente _Headless_

O Strapi é o CMS _headless open-source_ (código aberto) mais conhecido atualmente @strapi2024docs. Ele compartilha várias ideias com este projeto:
#linebreak()
*Semelhanças*:
- Permite criar coleções de conteúdo personalizadas @strapi2024docs
- Oferece APIs GraphQL e REST para acesso ao conteúdo
- Tem sistema de permissões baseado em papéis (roles)
- Suporta vários tipos de dados diferentes
#linebreak()
*Diferenças Importantes*:
#linebreak()
*Controle de Permissões*: O Strapi usa apenas o sistema tradicional RBAC (controle por papéis) @strapi2024docs, que só permite definir permissões por tipo de conteúdo inteiro. Este projeto usa ABAC, permitindo controle muito mais fino - até mesmo por campo individual e considerando o contexto (horário, localização, etc.) conforme especificado por @nist2014abac.
#linebreak()
*Organização dos Dados*: Este projeto usa uma estratégia híbrida que organiza os dados de forma mais otimizada dependendo do tipo de informação, evitando as limitações do padrão EAV @nadkarni2007eav enquanto mantém flexibilidade de schema.
#linebreak()
*Regras Contextuais*: O Strapi não consegue criar regras como "só pode publicar durante horário comercial" ou "só pode acessar deste local". Este projeto implementa essas capacidades através do ABAC @nist2014abac.

// ================================
// CAPÍTULO 3 - CONCEITO E DESIGN DO SISTEMA
// ================================

= Conceito e Design do Sistema

Este capítulo explica como o sistema foi pensado e construído, quais tecnologias foram escolhidas e por que, e como todas as partes trabalham juntas para criar uma solução completa de gerenciamento de conteúdo.

== Arquitetura do Sistema

O sistema adota arquitetura em três camadas com separação clara de responsabilidades e comunicação via interfaces bem definidas.
#pagebreak()
#figure(
  image("diagramas/system-diagram.png"),  caption: [Diagrama de componentes do TechtonicCMS — camadas Cliente, API e Dados]
) <fig-system-diagram> 

#align(left)[#text(size: 10pt)[Fonte: Criação do autor.]]

=== Camadas Arquiteturais

*Camada de Persistência*:
- Banco de dados relacional para dados estruturados e relacionais
- Sistema de cache em memória para sessões e resultados de avaliações ABAC

*Camada de Aplicação*:
- API GraphQL como interface principal de consulta
- Endpoints REST para autenticação e gerenciamento de assets
- Motor ABAC integrado para controle de acesso

*Camada de Apresentação*:
- Painel administrativo implementado com tecnologia de interface moderna
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

A modelagem de dados utiliza abordagem unificada baseada em PostgreSQL JSONB para armazenamento de conteúdo dinâmico, eliminando a fragmentação do padrão EAV. Metadados estruturais (coleções, campos) permanecem em tabelas tipadas, enquanto valores concretos de entrada são persistidos em uma única coluna `jsonb`, acessível via stored procedures customizadas para filtragem e ordenação a nível de banco.

=== Entidades Principais

O sistema organiza dados em três níveis hierárquicos:
#linebreak()
*_Collections_ (Coleções)*: Define os tipos de conteúdo gerenciáveis (ex: "Artigos", "Produtos"). Cada coleção especifica seus campos através de metadados estruturados, suporte à internacionalização via múltiplos locales, e identificadores visuais (ícone, cor) para interface administrativa.
#linebreak()
*_Fields_ (Campos)*: Especifica os atributos de cada coleção incluindo tipo de dado (`text`, `number`, `boolean`, `date_time`, `rich_text`, `json`, `asset`, `relation`), regras de validação customizadas, e classificação de segurança em quatro níveis: `PUBLIC`, `INTERNAL`, `CONFIDENTIAL`, `RESTRICTED`. Campos podem ser marcados como PII (Personally Identifiable Information) e configurados para criptografia em repouso.
#linebreak()
*_Entries_ (Entradas)*: Representa as instâncias concretas de conteúdo com estados bem definidos: `DRAFT` (rascunho em edição), `PUBLISHED` (publicado e visível), `ARCHIVED` (arquivado sem exibição), `DELETED` (deletado logicamente). Cada entrada possui locale específico e uma coluna `Data` do tipo `jsonb` que armazena todos os valores de campos dinâmicos. O suporte multilíngue é realizado através de entradas vinculadas por `defaultLocale`.
#linebreak()
*_Assets_ (Arquivos)*: Gerencia recursos binários (imagens, vídeos, documentos) armazenando metadados essenciais: `filename`, `mimeType`, `fileSize`, `path`, além de campos para acessibilidade (`alt` para leitores de tela, `caption` descritivo) e rastreamento de propriedade (`uploadedBy`, `uploadedAt`).
#linebreak()
A Figura 3.2 apresenta em detalhe como essas entidades se relacionam, com destaque para a coluna JSONB unificada de entradas e a tabela de relacionamentos:

#figure(
  image("diagramas/database-diagram.svg"),
  caption: [Diagrama ER do TechtonicCMS — esquema PostgreSQL com JSONB unificado e relacionamentos ABAC]
) <fig-collections-entries>

#align(left)[#text(size: 10pt)[Fonte: Criação do autor.]]

=== Estratégia de Armazenamento

Diferentemente do padrão EAV discutido no referencial teórico, o sistema utiliza uma abordagem de *armazenamento JSONB unificado* para todos os valores dinâmicos de entrada. Cada entrada possui uma coluna `Data` do tipo `jsonb` que armazena todos os valores de campos — texto, números, booleanos, datas, objetos, listas — em uma única estrutura JSON. Os metadados sobre quais campos existem e seus tipos permanecem na tabela `fields`, mas os valores concretos habitam em `Entry.Data`.
#breakpar()
Esta estratégia elimina a necessidade de múltiplas tabelas de valores tipados (EAV), simplificando o schema e reduzindo a complexidade de joins. Para viabilizar filtragem e ordenação a nível de banco em campos dinâmicos, o sistema registra funções de banco mapeadas para stored procedures PostgreSQL — `cms_extract_text`, `cms_extract_number`, `cms_extract_boolean`, `cms_extract_datetime` — que operam diretamente sobre a coluna JSONB. Isso permite que queries como "título igual a 'Hello'" sejam traduzidas para SQL nativo com possível otimização via índices GIN.
#breakpar()
*Relacionamentos entre Entradas*: Relacionamentos tipados entre entradas (ex: "Autor" referenciando "Usuários") utilizam uma tabela de junção `entry_relations` com restrição de unicidade por `(EntryId, FieldId)`, garantindo que cada campo de relacionamento em uma entrada aponte para no máximo um alvo. A integridade referencial é preservada via foreign keys em cascata.
#breakpar()
*Exemplo Prático de Armazenamento*: Para uma coleção "Artigos de Blog" com campos heterogêneos, a entrada armazena todos os valores em `Data`:

#table(
  columns: 2,
  [*Campo*], [*Valor em JSONB*],
  [Título (pt)], [`{"title": "Introdução ao GraphQL", "locale": "pt"}`],
  [Título (en)], [`{"title": "Introduction to GraphQL", "locale": "en"}`],
  [Configurações], [`{"layout": "grid", "theme": "dark"}`],
  [Tags], [`{"tags": ["GraphQL", "API", "Tutorial"]}`],
  [Autor], [Referência via `entry_relations`]
)

O banco executa consultas dentro da estrutura JSON usando operadores nativos e stored procedures customizadas, como filtrar artigos por `theme='dark'` ou `title eq 'Hello'`.

=== Tabelas de Segurança e Controle de Acesso

O banco de dados inclui um conjunto completo de tabelas para implementar o sistema ABAC, conforme ilustrado na Figura 3.3:
#pagebreak()
#figure(
  image("diagramas/simplified_security_related_to_content.png", width: 100%),
  caption: [Tabelas de segurança (users, roles, policies) e sua relação com as entidades de conteúdo (collections, entries, fields, assets)]
) <fig-security-content>

#align(left)[#text(size: 10pt)[Fonte: Criação do autor.]]
#breakpar()
As tabelas principais de segurança incluem:
#linebreak()
*users*: Armazena credenciais de autenticação com hash criptográfico de senha, status do usuário (`ACTIVE`, `INACTIVE`, `BANNED`), e timestamps de criação, último acesso e última modificação.
#linebreak()
*roles*: Define papéis organizacionais do sistema com identificador único, descrição funcional e metadados temporais.
#linebreak()
*user_roles*: Tabela associativa entre usuários e papéis com suporte a expiração temporal configurável, permitindo concessões temporárias de privilégios.
#linebreak()
*abac_policies*: Define políticas de controle de acesso com efeito (`ALLOW`/`DENY`), prioridade numérica para resolução de conflitos, escopo do recurso (`users`, `collections`, `entries`, `assets`, `fields`), tipo de ação controlada (operações granulares como `create`, `read`, `update`, `delete`, `publish`, `configure_fields`), e conector lógico (`AND`/`OR`) para composição de regras.
#linebreak()
*abac_policy_rules*: Regras atômicas de cada política especificando atributo a avaliar (ex: `subject.role`, `resource.field.sensitivityLevel`), operador de comparação (`eq`, `in`, `gt`, `contains`, `regex`), valor esperado serializado em JSON, e tipo do valor para parsing adequado.
#linebreak()
*role_policies* e *user_policies*: Atribuição de políticas a papéis (herança organizacional) e usuários (exceções individuais), com metadados de auditoria (`assignedBy`, `reason`, `expiresAt`).
#linebreak()
*resource_ownerships*: Rastreamento de propriedade de recursos com três categorias: `CREATOR` (criador original), `ASSIGNED` (designação manual), `INHERITED` (herança hierárquica). Suporta expiração temporal e auditoria de atribuições.
#linebreak()
*abac_evaluation_cache*: Cache de avaliação para otimização de performance através de armazenamento temporário de decisões recentes com TTL configurável e invalidação automática baseada em mudanças de políticas.
#linebreak()
*abac_audit*: Registro de auditoria completo de decisões de autorização para conformidade regulatória e análise forense, incluindo contexto da requisição e métricas de performance.
#linebreak()
A Figura 3.4 apresenta o diagrama completo com todas as tabelas do sistema ABAC e seus relacionamentos detalhados:

#figure(
  image("diagramas/security.png", width: 100%),
  caption: [Diagrama completo do sistema ABAC mostrando todas as tabelas de segurança (policies, rules, cache, audit) e suas relações com usuários e recursos]
) <fig-security-complete>

#align(left)[#text(size: 10pt)[Fonte: Criação do autor.]]

== Sistema de Controle de Acesso

Implementação do modelo ABAC discutido no referencial teórico, com políticas declarativas armazenadas no banco de dados e motor de avaliação integrado.

=== Arquitetura do ABAC

O sistema utiliza quatro componentes principais:
#linebreak()
*Políticas e Regras*: Políticas declarativas com efeito (permitir/negar), prioridade e conectores lógicos. Cada política contém regras que avaliam atributos do sujeito (usuário), recurso, ação e ambiente (horário, IP).
#linebreak()
*_Cache_ de Avaliação*: Sistema de _cache_ de alta _performance_ que armazena decisões recentes, reduzindo drasticamente o tempo de autorização em operações frequentes.
#linebreak()
*Sistema de Auditoria*: _Log_ completo de todas as decisões incluindo contexto, políticas avaliadas e justificativa, essencial para _compliance_ e _debugging_.
#linebreak()
*Classificação de Dados*: Campos podem ser marcados com níveis de sensibilidade (público, interno, confidencial, restrito) e identificados como dados pessoais (PII), permitindo políticas automáticas baseadas na classificação.

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
- `resource.field.sensitivityLevel`: Nível de segurança (`PUBLIC`, `INTERNAL`, `CONFIDENTIAL`, `RESTRICTED`)
- `resource.field.isPii`, `resource.field.isPublic`: Classificações de privacidade
- `resource.field.collectionId`: Coleção proprietária

Para assets:
- `resource.asset.id`, `resource.asset.uploadedBy`: Identificação e propriedade
- `resource.asset.mimeType`, `resource.asset.fileSize`: Metadados do arquivo
#linebreak()
*Atributos da Ação*:
- `action.type`: Tipo de operação sendo requisitada, usando valores do enum `permission_actions` (ex: `create`, `read`, `update`, `delete`, `publish`, `configure_fields`, `upload`)
#linebreak()
*Atributos Ambientais (Contexto)*:
- `environment.currentTime`: Timestamp UTC da requisição
- `environment.ipAddress`: Endereço IP de origem
- `environment.userAgent`: Identificação do cliente
#linebreak()
Esta combinação permite criar regras contextuais precisas como "editores (`subject.role = 'editor'`) podem publicar (`action.type = 'publish'`) artigos do seu departamento (`resource.entry.createdBy = subject.id`) com campos não-confidenciais (`resource.field.sensitivityLevel IN ['PUBLIC', 'INTERNAL']`) durante horário comercial (`environment.currentTime BETWEEN 09:00-18:00`)".

=== Resolução de Conflitos

O sistema implementa resolução determinística de conflitos através de:
- Prioridade numérica para ordenar políticas conflitantes
- Conectores lógicos (AND/OR) para combinar múltiplas condições
- Arquitetura "negar por padrão" seguindo o princípio de menor privilégio

Exemplo de política implementável usando a estrutura do sistema:

```
Policy: "Allow Internal Field Access During Business Hours"
Effect: ALLOW
Resource Type: fields
Action: read
Rule Connector: AND

Rules:
  1. attribute: resource.field.sensitivityLevel
     operator: in
     value: ["PUBLIC", "INTERNAL"]
     
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

Esta política permite leitura de campos públicos e internos apenas para editores e administradores durante horário comercial.

=== Fluxo de Avaliação de Requisições

O processo de autorização segue uma sequência bem definida que balanceia segurança com performance:
#linebreak()
*1. Interceptação (PEP)*: O _Policy Enforcement Point_ intercepta a requisição antes de qualquer processamento. Em uma API GraphQL, isso ocorre através de _middlewares_ ou _higher-order functions_ que envolvem os resolvers.
#linebreak()
*2. Consulta ao Cache*: O sistema verifica se existe uma decisão em cache para a combinação de usuário, recurso e ação. Decisões são cacheadas com tempo de expiração configurável (tipicamente 5 minutos) para otimizar operações frequentes.
#linebreak()
*3. Coleta de Atributos (PIP)*: Se não houver cache válido, o _Policy Information Point_ coleta atributos de múltiplas fontes:
- Atributos do usuário: extraídos do token de autenticação (papel, departamento, status)
- Atributos do recurso: consultados no banco de dados (tipo, proprietário, sensibilidade, status de publicação)
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
- Cache em banco de dados PostgreSQL (tabela `abac_evaluation_cache`) para otimizar requisições futuras idênticas, com invalidação automática baseada em mudanças de políticas
- Tabela de auditoria permanente com timestamp, contexto completo e justificativa
#linebreak()
*6. Aplicação (PEP)*: O _Policy Enforcement Point_ aplica o veredicto:
- ALLOW: Requisição prossegue para execução normal
- DENY: Retorna erro de autorização ao cliente (HTTP 403)
- NOT_APPLICABLE: Aplicado princípio _deny-by-default_, retorna negação
#linebreak()
Métricas típicas de performance: avaliação com cache em menos de 5ms, avaliação sem cache aproximadamente 50ms incluindo consultas ao banco de dados.

== APIs e Protocolos de Comunicação

O sistema é *exclusivamente GraphQL* para todas as operações de conteúdo, autenticação, autorização e administração. Não existe API REST para CRUD de conteúdo, gerenciamento de sessões, ou administração de políticas.

=== Endpoints Não-GraphQL

Quatro rotas auxiliares mapeadas via `app.MapPost`/`app.MapGet` complementam o endpoint GraphQL:
#linebreak()
*_Assets_* (`POST /assets/upload`, `GET /assets/{id}`): Envio e download de arquivos binários. A natureza multipart e necessidade de transmissão em tempo real justificam endpoints HTTP diretos sobre GraphQL.
#linebreak()
*Documentação de Schema* (`GET /llms.md`): Geração automática de documentação Markdown do schema GraphQL para consumo por LLMs e desenvolvedores.
#linebreak()
*Health Check* (`GET /healthcheck`): Verificação rápida de disponibilidade do serviço, retornando `healthy`.

=== API GraphQL — Interface Principal e Única

Todas as operações do sistema transitam pelo endpoint `/graphql` via Hot Chocolate 14+.
#linebreak()
*Autenticação*: Login, logout, refresh de tokens e gerenciamento de sessões são implementados como mutations GraphQL (`auth.login`, `auth.refresh`, `auth.logout`, `auth.logoutAll`), não como endpoints REST. Tokens de acesso JWT (RS256, TTL 15 minutos) e refresh tokens (TTL 30 dias, single-use) são gerenciados integralmente via GraphQL.
#linebreak()
*CRUD de Conteúdo*: Criação, leitura, atualização, deleção, publicação e arquivamento de entradas são mutations GraphQL dinâmicas, geradas em tempo de execução pelo `CollectionTypeModule` baseado nos metadados das coleções.
#linebreak()
*Administração ABAC*: Criação, modificação e atribuição de políticas e regras são mutations GraphQL sob a namespace `policies`.
#linebreak()
*_Design_ do Esquema*: _Queries_ e _mutations_ estruturadas para eliminar necessidade de _joins_ manuais pelo cliente. O schema é gerado dinamicamente em tempo de execução: para cada coleção definida no banco de dados, o sistema cria tipos de dados (`BlogPostEntryData`), tipos de entrada (`BlogPostEntry`), inputs de filtro (`BlogPostEntryFilterInput`), inputs de ordenação (`BlogPostEntrySortInput`) e mutations (`blogPosts.create`, `blogPosts.update`, etc.).
#linebreak()
*Sistema de Filtragem*: Filtros específicos por tipo implementando operadores que se traduzem diretamente para SQL via funções de banco (`cms_extract_text`, `cms_extract_number`, `cms_extract_boolean`, `cms_extract_datetime`):
- Texto: `contains`, `startsWith`, `endsWith`, `eq`
- Numérico: `gt`, `gte`, `lt`, `lte`, `eq`
- Data: `before`, `after`, `eq`
- Booleano: `eq`
- Relacionamentos: `exists`, `in`, `notIn`
#linebreak()
*Otimizações*:
- _Resolvers_ aplicam filtros diretamente no banco via SQL otimizado, traduzindo LINQ composta em query única
- _Cursor-based pagination_ para conjuntos de dados grandes
- Ordenação multi-campo
- Análise de complexidade de query com limites de profundidade (máx. 15) e custo de campo (máx. 20.000)

*Integração com ABAC*:
- _Higher-order functions_ protegendo _resolvers_ automaticamente
- Filtragem de resultados baseada em permissões do usuário (row-level filtering via `[UseAbacRowCheck]`)
- Controle _field-level_ impedindo acesso a campos restritos
- _Error handling_ padronizado para autenticação e autorização

== Interface Administrativa

Implementação utilizando tecnologia de interface moderna aproveitando as características discutidas no referencial teórico.

=== Características Técnicas

*Arquitetura Reativa*: Atualizações eficientes de interface baseadas em mudanças de estado.
#linebreak()
*Segurança de Tipos*: Integração com tipagem estática end-to-end entre frontend e backend.
#linebreak()
*Interface Adaptativa*: UI se adapta automaticamente aos schemas definidos, gerando formulários e componentes específicos por tipo de campo.

=== Módulos Principais

*Painel de Controle*: Visão geral de coleções, estatísticas e navegação filtrada por permissões ABAC.
#linebreak()
*Editor de Coleções*: Definição de tipos de conteúdo com validação em tempo real.
#linebreak()
*Editor de Entradas*: Formulários gerados dinamicamente baseados no _schema_ da coleção.
#linebreak()
*Gerenciador de _Assets_*: Envio e organização de mídias com metadados de acessibilidade.
#linebreak()
*Configuração de Permissões*: _Interface_ para criação e gerenciamento de políticas ABAC.

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
- Tipo: Texto
- Obrigatoriedade: Sim
- Multilíngue: Sim
- Classificação de segurança: Público
- Validações: Comprimento mínimo 10, máximo 200 caracteres

*Campo "Conteúdo"*:
- Tipo: Rich Text (editor WYSIWYG)
- Obrigatoriedade: Sim
- Multilíngue: Sim
- Classificação de segurança: Interno
- Recursos habilitados: Negrito, itálico, listas, links, imagens

*Campo "Autor"*:
- Tipo: Relacionamento → Coleção "Usuários"
- Cardinalidade: Um para um
- Obrigatoriedade: Sim (preenchido automaticamente com criador)
- Classificação de segurança: Público

*Campo "Tags"*:
- Tipo: Lista de Texto
- Obrigatoriedade: Não
- Multilíngue: Não
- Classificação de segurança: Público
- Validações: Máximo 10 tags, cada tag máximo 30 caracteres
#linebreak()
*Etapa 3 - Configuração de Permissões*: O usuário define políticas ABAC específicas para esta coleção:
- Editores: podem criar e editar rascunhos próprios
- Editores-chefe: podem publicar qualquer artigo
- Público: pode ler artigos com status "publicado"
- Restrição temporal: Publicação apenas em horário comercial (09:00-18:00 UTC-3)
#linebreak()
*Etapa 4 - Validação e Pré-visualização*: O sistema executa validação em tempo real:
- Verifica se há campos obrigatórios sem valor padrão
- Alerta sobre conflitos de permissões
- Mostra pré-visualização do formulário de edição que será gerado
- Estima tamanho de armazenamento baseado nos tipos de campos
#linebreak()
*Etapa 5 - Criação e Propagação*: Ao confirmar, o sistema executa automaticamente:
- Insere registros nas tabelas `collections` e `fields`
- Gera tipos GraphQL dinâmicos (`BlogPost`, `BlogPostInput`, `BlogPostFilter`)
- Adiciona resolvers específicos para consulta e mutação
- Cria formulário de edição no painel administrativo
- Registra operação na auditoria com timestamp e usuário responsável
#linebreak()


== Tecnologias, Segurança e Performance

Esta seção apresenta as tecnologias selecionadas e as estratégias implementadas para garantir segurança e performance do sistema.

=== Requisitos Tecnológicos

Este projeto documenta o design conceitual do sistema, mantendo-se agnóstico a implementações específicas para garantir atemporalidade. As escolhas tecnológicas devem atender aos seguintes requisitos:
#linebreak()
*Camada de Persistência*: Banco de dados relacional com conformidade ACID, suporte nativo a tipos JSON, e capacidade de indexação avançada. Sistema de cache em memória com suporte a expiração automática (TTL) para otimização de consultas frequentes e decisões ABAC.
#linebreak()
*Camada de Aplicação*: Linguagem com sistema de tipos robusto (tipagem estática ou gradual), modelo de execução adequado para operações I/O intensivas (assíncrono ou concorrente), bibliotecas maduras para implementação de servidores GraphQL, e suporte a validação de schemas em tempo de execução.
#linebreak()
*Camada de Apresentação*: _Framework_ de interface com arquitetura reativa ou declarativa, capacidade de geração dinâmica de formulários baseados em schemas, sistema de componentes reutilizáveis, e integração de tipos _end-to-end_ com as APIs do backend quando possível.
#linebreak()
*Protocolos de Comunicação*: Implementação GraphQL conforme especificação oficial para consultas flexíveis, e endpoints REST para operações binárias e autenticação. Suporte obrigatório a TLS/HTTPS para todas as comunicações.

=== Segurança

*Autenticação e Sessões*: Sistema baseado em JWT com criptografia assimétrica, permitindo validação distribuída. Sessões gerenciadas com TTL automático e renovação baseada em atividade.
#linebreak()
*Controle de Acesso*: Sistema ABAC integrado em todos os _resolvers_ GraphQL e _endpoints_ REST, com auditoria completa de decisões.
#linebreak()
*Proteção de Dados*: Validação de _inputs_ via _schemas_ tipados. _Queries_ parametrizadas prevenindo _SQL injection_. Suporte a criptografia em repouso para campos sensíveis.
#linebreak()
*Transporte*: TLS/HTTPS garantindo confidencialidade e integridade de todas as comunicações.

=== Otimizações de Performance

*Banco de Dados*: Índices estratégicos para consultas e filtragem de conteúdo. _Connection pooling_ otimizado. _Prepared statements_ para _queries_ frequentes.
#linebreak()
*GraphQL*: _DataLoader_ eliminando problema N+1 em consultas relacionadas. _Query complexity analysis_ prevenindo _queries_ abusivas. _Cache_ de _schemas_.


// ================================
// CAPÍTULO 4 - IMPLEMENTAÇÃO
// ================================

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

O motor ABAC (`Services/AbacService.cs`, ~700 linhas) implementa a arquitetura NIST SP 800-162 com quatro componentes: PAP, PDP, PIP e PEP.

=== Modelo Formal

O sistema implementa controle de acesso baseado em atributos como função de decisão:

$D = text{"Decide"}(u, r, a, text{"ctx"})$

Onde $u in U$ é o usuário (sujeito), $r in R$ é o tipo de recurso, $a in A$ é a ação, $text{"ctx"}$ é o contexto de avaliação, e $D in {text{"Allow"}, text{"Deny"}}$. A função implementa combinação *deny-overrides*:

$D = cases(
  text{"Deny"} & "se" exists p in P_text{"deny"} : text{"Eval"}(p, text{"ctx"}) = text{"true"},
  text{"Allow"} & "se" exists p in P_text{"allow"} : text{"Eval"}(p, text{"ctx"}) = text{"true"},
  text{"Deny"} & "caso contrário (negar por padrão)"
)$

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

