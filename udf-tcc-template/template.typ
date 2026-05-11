// UDF Academic Paper Template
// Based on Centro Universitário do Distrito Federal standards
#let std-bibliography = bibliography

#let udf-paper(
  title: "",
  subtitle: none,
  authors: (),
  course: "Ciencias da computação",
  advisor: "",
  city: "Brasília",
  year: datetime.today().year(),
  dedication: none,
  acknowledgments: none,
  abstract-pt: none,
  keywords-pt: (),
  abstract-en: none,
  keywords-en: (),
  bibliography: auto,
  body,
) = {
  
  // Set document metadata
  set document(title: title, author: authors.map(a => a.name))
  
  // Set page layout
  set page(
    paper: "a4",
    margin: (left: 3cm, right: 2cm, top: 3cm, bottom: 2cm),
    numbering: none,
  )
  
  // Set text formatting
  set text(
    font: "Arial",
    size: 12pt,
    lang: "pt",
    
  )
  
  // Set paragraph formatting
  set par(
    justify: true,
    leading: 1.5em,
    first-line-indent: 0cm,
    linebreaks: "optimized"
    
  )

  show par: it => {
    it
    v(0.43cm)
  }

  // Set heading formatting
  show heading.where(level: 1): it => {
    v(1cm)
    set text(size: 14pt, weight: "bold")
    pagebreak()
    it
    v(1cm)
  }

  show heading.where(level: 2): it => {
    v(0.7cm)
    set text(size: 12pt, weight: "bold")
    it
    v(0.7cm)
  }

  show heading.where(level: 3): it => {
    v(0.7cm)
    set text(size: 12pt, weight: "bold")
    it
    v(0.7cm)
  }
  set heading(numbering: "1.")
  
  // ABNT formatting for figures (illustrations)
  show figure.where(kind: image): it => {
    set align(center)
    v(0.5cm)
    
    // Title at the top: bold, centered
    // Format: "Figura N – Title"
    set text(size: 10pt)
    [#it.supplement #it.counter.display(it.numbering) -- #it.caption.body]
    
    v(0.3cm)
    
    // The image itself
    it.body
    
    v(0.3cm)
    
    // Source at the bottom: left-aligned, size 10pt, no bold
    if it.caption.fields().keys().contains("source") [
      #set align(left)
      #set text(size: 10pt, weight: "regular")
      Fonte: #it.caption.source
    ]
    
    v(0.5cm)
  }
  
  // ABNT formatting for tables
  show figure.where(kind: table): it => {
    set align(center)
    v(0.5cm)
    
    // Title at the top: bold, centered
    // Format: "Tabela N – Title"
    set text(size: 12pt, weight: "bold")
    [#it.supplement #it.counter.display(it.numbering) -- #it.caption.body]
    
    v(0.3cm)
    
    // The table itself with ABNT formatting
    // Tables should not have left and right vertical borders
    show table: set table(
      stroke: (x, y) => (
        top: if y == 0 { 1pt } else { 0pt },
        bottom: 1pt,
        left: 0pt,
        right: 0pt,
      )
    )
    
    it.body
    
    v(0.3cm)
    
    // Source at the bottom: left-aligned, size 10pt, no bold
    if it.caption.fields().keys().contains("source") [
      #set align(left)
      #set text(size: 10pt, weight: "regular")
      Fonte: #it.caption.source
    ]
    
    v(0.5cm)
  }
  
  // Cover page
  page(
    margin: 3cm,
    [
      #align(center)[
        #image("udf-logo.png", width: 4cm) // Replace with actual UDF logo
        
        #v(1cm)
        
        #text(size: 14pt, weight: "bold")[
          CENTRO UNIVERSITÁRIO DO DISTRITO FEDERAL -- UDF
        ]
        
        #v(0.5cm)
        
        #text(size: 12pt, weight: "bold")[
          COORDENAÇÃO DO CURSO DE #upper(course)
        ]
        
        #v(3cm)
        
        #text(size: 12pt, weight: "bold")[
          #for author in authors [
            #author.name
            #if author != authors.last() [ \ ]
          ]
        ]
        
        #v(3cm)
        
        #text(size: 14pt, weight: "bold")[
          #upper(title)
          #if subtitle != none [
            \ 
            #upper(subtitle)
          ]
        ]
        
        #v(1fr)
        
        #text(size: 14pt, weight: "bold")[
          #upper(city) \
          #str(year)
        ]
      ]
    ]
  )
  
  // Title page (verso da folha de rosto)
  page(
    margin: 3cm,
    [
      #align(center)[
        #v(3cm)
        
        #text(size: 14pt, weight: "bold")[
          #for author in authors [
            #author.name
            #if author != authors.last() [ \ ]
          ]
        ]
        
        #v(3cm)
        
        #text(size: 14pt, weight: "bold")[
          #title
          #if subtitle != none [
            \ 
            #subtitle
          ]
        ]
        
        #v(2cm)
        
        #align(center)[
          #box(width: 8cm)[
            #set text(size: 10pt)
            #set par(justify: true, first-line-indent: 0pt)
            Trabalho de conclusão de curso apresentado à Coordenação de #course, do Centro Universitário do Distrito Federal - UDF, como requisito parcial para obtenção do grau de bacharel em #course.
            
            #v(0.5cm)
            Orientador: #advisor
          ]
        ]
        
        #v(1fr)
        
        #text(size: 14pt, weight: "bold")[
          #upper(city) \
          #str(year)
        ]
      ]
    ]
  )
  
  // Approval page
  page(
    margin: 3cm,
    [
      #align(center)[
        #v(3cm)
        
        #text(size: 14pt, weight: "bold")[
          #for author in authors [
            #author.name
            #if author != authors.last() [ \ ]
          ]
        ]
        
        #v(1cm)
        
        #text(size: 14pt, weight: "bold")[
          #title
          #if subtitle != none [
            \ 
            #subtitle
          ]
        ]
        
        #v(2cm)
        
        #align(center)[
          #box(width: 8cm)[
            #set text(size: 10pt)
            #set par(justify: true, first-line-indent: 0pt)
            Trabalho de conclusão de curso apresentado à Coordenação de #course, do Centro Universitário do Distrito Federal - UDF, como requisito parcial para obtenção do grau de bacharel em #course.
            
            #v(0.5cm)
            Orientador: #advisor
          ]
        ]
        
        #v(1cm)

        
        #stack(
          dir: ltr,
          [#city], [#h(1%) #line(length: 5%)], [de], [#h(1%) #line(length: 10%)], [de], [#h(1%) #line(length: 12%)]
        )

     
        
        
        #v(2cm)
        
        *Banca Examinadora*
        
        #v(1cm)
        
        #line(length: 100%)
        NOME DO EXAMINADOR \
        Titulação \
        Instituição a qual é filiado
        
        #v(1cm)
        
        #line(length: 100%)
        NOME DO EXAMINADOR \
        Titulação \
        Instituição a qual é filiado
        
        #v(1cm)
        
        #line(length: 100%)
        NOME DO EXAMINADOR \
        Titulação \
        Instituição a qual é filiado
        
        #v(1cm)
        
        #stack(
          dir: ltr,
          [NOTA:],
          [#h(1%) #line(length: 10%)]
        )
      ]
    ]
  )
  
  // Dedication page (optional)
  if dedication != none {
    page(
      margin: 3cm,
      [
        #v(1fr)
        #align(right)[
          #set par(first-line-indent: 0pt)
          #dedication
        ]
      ]
    )
  }
  
  // Acknowledgments page (optional)
  if acknowledgments != none {
    page(
      margin: 3cm,
      [
        #align(center)[
          #text(size: 14pt, weight: "bold")[AGRADECIMENTOS]
        ]
        #v(1cm)
        #set par(first-line-indent: 0pt)
        #acknowledgments
      ]
    )
  }
  
  // Epigraph page (optional)
  page(
    margin: 3cm,
    [
      #v(1fr)
      #align(center)[
        #set par(first-line-indent: 0pt)
        #emph["A prática é o critério da verdade"]
        
        Mao Zedong
      ]
    ]
  )
  
  // Portuguese abstract
  if abstract-pt != none {
    page(
      margin: 3cm,
      [
        #align(center)[
          #text(size: 14pt, weight: "bold")[RESUMO]
        ]
        #v(1cm)
        #set par(first-line-indent: 0pt)
        #abstract-pt
        
        #if keywords-pt.len() > 0 [
          #v(1cm)
          *Palavras-chave*: #keywords-pt.join(". ").
        ]
      ]
    )
  }
  
  // English abstract
  if abstract-en != none {
    page(
      margin: 3cm,
      [
        #align(center)[
          #text(size: 14pt, weight: "bold")[ABSTRACT]
        ]
        #v(1cm)
        #set par(first-line-indent: 0pt)
        #abstract-en
        
        #if keywords-en.len() > 0 [
          #v(1cm)
          *Key words*: #keywords-en.join(". ").
        ]
      ]
    )
  }
  
  // Lists (figures, tables, abbreviations) would go here
  // For simplicity, I'm including a basic table of contents
  
  page(
    margin: 3cm,
    [
      #align(center)[
        #text(size: 14pt, weight: "bold")[SUMÁRIO]
      ]
      #v(1cm)
      #outline(
        title: none,
        indent: auto,
        
      )
    ]
  )
  
  // Start page numbering for content
  set page(numbering: "1")
  counter(page).update(1)
  
  // Main content
  body
  


    if bibliography != none {
    pagebreak()
    show std-bibliography: bib => [
      #set text(0.85em)
      #bib
      
    ]
    // Use default paragraph properties for bibliography.
    show std-bibliography: set par(leading: 0.65em, justify: false, linebreaks: auto)
      std-bibliography(bibliography, style: "associacao-brasileira-de-normas-tecnicas")
  }

}
