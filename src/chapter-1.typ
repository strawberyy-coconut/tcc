
= Introdução

O desenvolvimento de aplicações web modernas que integram conteúdo dinâmico com bancos de dados representa um desafio significativo para desenvolvedores, exigindo domínio de múltiplas tecnologias que abrangem desde a camada de apresentação até a lógica de negócios e persistência de dados. A complexidade aumenta quando consideramos requisitos não-funcionais como performance, responsividade, segurança e controle de acesso granular, além da necessidade de distribuir conteúdo através de múltiplos canais — sites, aplicativos móveis, assistentes de voz, dispositivos IoT @headless2021decoupled; @fielding2000architectural.

Sistemas de gerenciamento de conteúdo (CMS) consolidaram-se como ferramentas essenciais da infraestrutura digital moderna. O WordPress, exemplo mais emblemático desta categoria, é utilizado por mais de 40% de todos os sites da internet @w3techs2024usage. Entretanto, a arquitetura monolítica de CMS tradicionais, onde backend e frontend estão fortemente acoplados, apresenta limitações evidentes frente às demandas de distribuição omnichannel e personalização em escala @headless2021decoupled.

A arquitetura headless emerge como resposta a estas limitações, propondo desacoplamento completo entre gestão de conteúdo e apresentação através de APIs @headless2021decoupled; @caoxuanan2023headless. Soluções headless maduras como o Strapi consolidaram esse modelo, oferecendo criação dinâmica de coleções, APIs GraphQL e REST, e ecossistema extensível de plugins. Entretanto, estas soluções adotam modelos de controle de acesso baseados em papéis (RBAC), onde permissões são concedidas por papel e por tipo de conteúdo — uma abordagem que apresenta limitações em ambientes regulados. Requisitos crescentes de conformidade demandam controle de acesso granular com políticas baseadas em atributos contextuais: quem criou o recurso, em que horário a operação está sendo requisitada, de qual localização geográfica @nist2014abac. O RBAC tradicional não consegue expressar essas regras sem workarounds arquiteturais que comprometem a auditabilidade e a manutenibilidade das políticas de acesso.

Este trabalho apresenta o TechtonicCMS, um sistema de gerenciamento de conteúdo headless que endereça essa lacuna combinando arquitetura desacoplada API-first, controle de acesso baseado em atributos (ABAC) com modelo formal de decisão, e geração dinâmica de schemas GraphQL em tempo de execução sem necessidade de recompilação ou reinicialização do serviço. O sistema demonstra como balancear usabilidade para editores não-técnicos, flexibilidade para desenvolvedores e requisitos rigorosos de segurança em ambientes que demandam auditabilidade completa das decisões de autorização.

== Objetivos


Desenvolver um sistema de gerenciamento de conteúdo headless (CMS Headless) que permita a criação, edição e distribuição de conteúdo de forma desacoplada, oferecendo flexibilidade para desenvolvedores criarem interfaces personalizadas enquanto mantém a facilidade de uso para editores de conteúdo, demonstrando na prática as vantagens arquiteturais desta abordagem moderna em comparação aos CMS tradicionais.

=== Objetivos Específicos

+ Especificar e implementar uma arquitetura _headless_ nativa, desacoplada completamente entre _backend_ e _frontend_, utilizando GraphQL como interface exclusiva de comunicação para todas as operações de conteúdo, autenticação e autorização.
+ Projetar e desenvolver um motor de controle de acesso baseado em atributos (ABAC) com suporte a políticas contextuais que avaliem atributos do sujeito, do recurso, da ação e do ambiente, incluindo resolução determinística de conflitos por prioridade, _cache_ persistente de avaliações e auditoria completa das decisões de autorização.
+ Criar um mecanismo de geração dinâmica de _schemas_ GraphQL que reconstrua o contrato da API em tempo de execução a partir das definições de coleções e campos armazenadas em metadados, eliminando a necessidade de recompilação ou reinicialização do serviço.
+ Modelar uma estratégia de armazenamento semi-estruturado unificado utilizando JSONB em banco de dados relacional, eliminando a fragmentação do padrão EAV e viabilizando filtragem, ordenação e paginação a nível de banco através de funções de extração customizadas.
+ Implementar um sistema de autenticação duplo que combine sessões JWT com _refresh tokens_ de uso único para usuários humanos e chaves de API com hash criptográfico para integrações _machine-to-machine_, com armazenamento de sessões em cache em memória para revogação instantânea.
+ Construir uma interface administrativa reativa e adaptativa em SvelteKit que consuma a API GraphQL, gerando formulários e componentes dinamicamente conforme o _schema_ de cada coleção e respeitando as permissões ABAC do usuário autenticado.
+ Validar a arquitetura proposta através de um caso de uso real (blog institucional) que demonstre o consumo multi-canal do conteúdo, comprovando a viabilidade prática da abordagem _API-first_ combinada com controle de acesso granular.

== Metodologia

Este trabalho adota uma abordagem de pesquisa aplicada, combinando fundamentação teórica com desenvolvimento prático de um protótipo funcional. A metodologia está organizada em três etapas complementares:

=== Etapa 1: Pesquisa e Fundamentação Teórica

Revisão bibliográfica de fontes acadêmicas e técnicas sobre CMS, sistemas de controle de acesso (RBAC e ABAC), arquiteturas web modernas e APIs. Análise comparativa de sistemas existentes para identificar padrões e oportunidades de inovação. Análise de métodos de geração de esquemas GraphQL. Especificação dos requisitos funcionais e não-funcionais do sistema.

=== Etapa 2: Design e Modelagem

Modelagem do banco de dados relacional com suporte a schemas dinâmicos. Definição da arquitetura em camadas e especificação das interfaces REST e GraphQL. Projeto do sistema ABAC com suas políticas e regras de autorização.

=== Etapa 3: Implementação e Validação

Desenvolvimento incremental do protótipo em cinco fases:

*Fase 1 - Fundação*: Implementação da infraestrutura base (banco de dados, autenticação e estruturas para schemas dinâmicos).

*Fase 2 - Core*: Desenvolvimento das funcionalidades centrais de gerenciamento de coleções e entradas, incluindo o sistema ABAC.

*Fase 3 - APIs*: Construção das camadas REST e GraphQL com validação e otimização de consultas.

*Fase 4 - Interface*: Desenvolvimento do painel administrativo com formulários dinâmicos baseados nos schemas.

*Fase 5 - Validação*: Testes funcionais, de performance e segurança, seguidos de ajustes baseados nos resultados.
