#import "../udf-tcc-template/template.typ": *
#import "@preview/mmdr:0.2.2": mermaid
#import "chapter-1.typ"
#import "chapter-2.typ"
#import "chapter-3.typ"
#import "chapter-4.typ"
#import "chapter-5.typ"

// Document content
#show: udf-paper.with(
  title: "TechtonicCMS: Um Sistema de Gerenciamento de Conteúdo Headless",
  subtitle: "Uma Abordagem Moderna para CMS",
  authors: (
    (name: "Gustavo Medeiros Lima", student-id: "31466281"),
  ),
  course: "Ciência da Computação",
  advisor: "Eliel Dias",
  city: "Brasília",
  year: 2025,
  bibliography: "../src/refs.yml"
)

// ===========================================
// CAPÍTULO 1 - DEFINIÇÃO DO PROBLEMA, OBJETIVOS E METODOLOGIA
// ===========================================

#chapter-1

// ================================
// CAPÍTULO 2 - REFERENCIAL TEÓRICO
// ================================

#chapter-2

// ================================
// CAPÍTULO 3 - CONCEITO E DESIGN DO SISTEMA
// ================================

#chapter-3

// ================================
// CAPÍTULO 4 - IMPLEMENTAÇÃO
// ================================

#chapter-4


// ================================
// CAPÍTULO 5 - CONCLUSÃO
// ================================

#chapter-5