#import "@preview/drafting:0.1.1": *
#import "@preview/ctheorems:1.1.2": *
#import "@preview/droplet:0.2.0": dropcap

// ======== METHODS ========
#let (in-margin, out-margin) = (2cm, 1.75in)
#let sn-counter = counter("sn-counter")

#let measurable(
  body,
  size: 12pt,
) = context {
  let it = text(size: size, body)

  it
  v(-.75em)
  line(
    length: measure(it).width,
    stroke: size/12
  )
}

#let sidebar-item(..args) = {
  locate(loc => {
    if calc.odd(counter(page).get().first()) {
      margin-note(margin-left: in-margin, margin-right: out-margin, side: right, ..args)
    } else {
      margin-note(margin-left: out-margin, margin-right: in-margin, side: left, ..args)
    }
  })
}

#let sidebar-quote(body, author: []) = context {
  let page-number = counter(page).get().first()

  set par(justify: false, first-line-indent: 0em, leading: .75em)

  sidebar-item(stroke: none)[
    #set text(size: 9pt, font: "")

    #let alignment = left
    #if calc.even(page-number) {
      alignment = right
    }

    #set align(alignment)

    #emph(body)
    
    #smallcaps(author)
  ]
}


#let sidebar-note(body, custom-v-space: []) = context {
  text(weight: "medium", fill: rgb("444352"))[#super[#sn-counter.display()]]
  
  let page-number = counter(page).get().first()

  sidebar-item(stroke: none)[
    #set par(justify: false, first-line-indent: 0em, leading: .75em)
    #set text(size: 9pt, font: "", fill: rgb("444352"))

    #let alignment = left
    #if calc.even(page-number) {
      alignment = right
    }

    #set align(alignment)
    
    #v(-1.75em)
    #custom-v-space
    *[#sn-counter.display()]*
    #emph(body)
  ]
  sn-counter.step()
}

#let page-summary(body, fill: red) = {
  pagebreak()
  set page(
    number-align: bottom + center,
    margin: (
      inside: in-margin,
      outside: out-margin,
    ),
    footer: context [
      #set text(8pt)

      #let pageNum = counter(page).get().first()

      #let closureTitle = str(counter(heading).get().first())

      #if calc.even(pageNum) {
        pad(
          x: -(out-margin * 0.75)
        )[
          #align(left)[
            _Chapter #closureTitle Summary_
            |
            *_#counter(page).display(
              "1",
            )_*
          ]
        ]
      } else {
        pad(
          x: -(out-margin * 0.75)
        )[
          #align(right)[
            _Chapter #closureTitle Summary_
            |
            *_#counter(page).display(
              "1",
            )_*
          ]
        ]
      }
    ]
  )
  set text(white)
  set page(fill: rgb("444352"))
  
  set text(font: "Barlow", weight: "bold", size: 22pt)
  text[*Summary:\ *]
  set text(
    10pt,
    font: "Charter",
    weight: "regular",
    lang: "en",
  )

  v(1em)
  
  set enum(numbering: n => [*1.*] + [*#n*])
  set list(marker: [ 💡], indent: 15pt)
  show cite: it => emph(text(fill: rgb("444352"), it))
  text[#body]
}

#let chat(caption: [], width-caption: 80%, body) = {
  body
  align(center)[
    #box(width: width-caption)[
      #figure(caption: caption, kind: "chat", supplement: [Chat])[]
    ]
  ]
}

#let chat-box(box-alignment: [left], chatbot: "chat-gpt", body) = {
  set text(font: "Barlow", size: 7.8pt)
  set box(width: 70%, inset: 1em)
  if box-alignment == "right" {
    set align(right)
    box(fill: rgb("d0e4f5"), radius: (top: 1em, bottom-left: 1em))[#body]
    h(1em)
    box(width: auto, inset: 0em)[#image("../img/user-icon.png", width: 3em)]
  
  } else {
    set align(left)
    box(inset: 0em, clip: true, width: 3em, radius: 4pt)[#image("../img/" + chatbot + "-icon.png")]
    h(1em)
    box(fill: rgb("e9e9e9"), radius: (top: 1em, bottom-right: 1em))[#body]
  }
}

#let fancy-citation(body) = {
  emph(text(fill: rgb("444352"), body))
}

#let front-cover() = {
  set page(
    width: 17.5cm,
    height: 24cm,
    margin: (
      top: 0em,
      bottom: 0em,
      left: 0em,
      right: 0em
    ),
    header: context[],
    footer: context[]
  )
  
  image("../img/temporary-cover.png", width: 100%, height: 100%, fit: "stretch")

}

#let intro-page(title, authors, copyright) = {
  set page(
    width: 17.5cm,
    height: 24cm,
    margin: (
      inside: in-margin,
    ),
    header: context[],
    footer: context[]
  )
  
  
  align(horizon + left)[
    #text(weight: "bold", size: 24pt)[#title]
    #line(length: 50%, stroke: 0.5pt + luma(20%))
    \
    #let emphasized = authors.map(a => strong(a))
    #let names = emphasized.join(", ", last: " & ")
    #emph(names)
  ]

  pagebreak()

  align(bottom)[
    #copyright
  ]
}

#let prologue-page(title: [], body) = {
  set page(
    width: 17.5cm,
    height: 24cm,
    margin: (
      inside: in-margin,
    ),
    header: context[],
    footer: context [
      #set text(8pt)
      #let elems = query(
        selector(heading).before(here()),
      )
      #let pageNum = counter(page).get().first()

      #if calc.even(pageNum) {
        pad[
          #emph(align(right)[
            Prologue *| #counter(page).display("1")*
          ])
        ]
      } else {
        pad[
          #emph(align(left)[
            *#counter(page).display("1") |* Prologue
          ])
        ]
      }
    ]
  )
  
  pad(
    top: 2em,
    bottom: 1em,
    align(left)[
      #text(font: "Barlow", weight: "bold", 22pt, "" + emph(title))
    ]
  )
  
  dropcap(
    height: 2,
    justify: true,
    gap: 4pt,
    hanging-indent: 0em,
    overhang: 0pt,
  )[
    #body
  ]
}

// ======== TEMPLATES ========
#let book(

  // The book's authors
  authors: (),

  // The book's title
  title: [Book Title],

  // The book's copyright
  copyright: [Copyright text],

  // editions: (1),

  body
) = {

  // ======== PAGE SETUP ========
  // Set the document's basic properties.
  set document(
    author: authors.join(", ", last: " and "),
    title: title
  )

  front-cover()

  intro-page(title, authors, copyright)
  
  // Set the page's properties
  set page(
    width: 17.5cm,
    height: 24cm,
    numbering: "1",
    number-align: bottom + center,
    margin: (
      inside: in-margin,
      outside: out-margin,
    ),
    footer: context [
      #set text(8pt)
      #let elems = query(
        selector(heading).before(here()),
      )
      #let pageNum = counter(page).get().first()

      #if calc.even(pageNum) {
        pad[
          #emph(align(right)[
            #if elems.len() != 0 {
              let body = elems.last().body
              body
            } *|
            #counter(page).display(
              "1",
            )*
          ])
        ]
      } else {
        pad[
          #emph(align(left)[
            *#counter(page).display(
              "1",
            ) 
            |*
            #if elems.len() != 0 {
              let body = elems.last().body
              body
            }
          ])
        ]
      }
    ]
  )
  counter("sn-counter").update(1)
  set-page-properties()

  // Set the text properties
  set text(
    10pt,
    font: "Charter",
    weight: "regular",
    lang: "en",
  )

  // set heading(numbering: "1.1")
  set heading(numbering: "1.1.1.", supplement: [Chapter])

  show outline.entry.where(
    level: 1
  ): it => {
    v(12pt, weak: true)
    strong(it)
  }
  
  outline(indent: 1em)

  // show par: set block(below: .5em)
  
  
  show heading: it => {
    if it.level == 1 {
      return [
        #pagebreak(to: "odd")
        #pad(
          top: 2em,
          bottom: 3em,
          align(center)[
            #set text(font: "Barlow", weight: "bold")

            #measurable(
              size: 10pt,
              [C H A P T E R #h(.5em) #counter(heading).display("I")]
            )

            #text(22pt, it.body)
          ]
        )
      ]
    }

    return it
  }

  set par(
    first-line-indent: 0em,
    justify: true,
    leading: 1em
  )

  body

  /*show heading: it => {
    if it.level == 1 {
      return [
        #pagebreak(to: "odd")
        #pad(
          top: 2em,
          bottom: 3em,
          align(center)[
            #set text(font: "Barlow", weight: "bold")

            #text(22pt, it.body)
          ]
        )
      ]
    }
  }*/
  
  bibliography(
    "../bibliography.bib",
    style: "apa"
  )
}

#let appendix(body) = {
  set heading(numbering: "A", supplement: [Appendix])
  counter(heading).update(0)
  body
}

// ──────── Pandoc template variables ────────
#show: book.with(
  title: "$title$",
  authors: (
$for(author)$
  "$author$"$sep$, 
$endfor$
  ),
  copyright: [
    Copyright © $publication$
      
    _First Edition \u{2219} First printing, July 2023_

    PUBLISHED BY $publisher$

    This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International.
    
    This license requires that reusers give credit to the creator. It allows reusers to distribute, remix, adapt, and build upon the material in any medium or format, for noncommercial purposes only. If others modify or adapt the material, they must license the modified material under identical terms.
    
    To view a copy of this license, please visit https://creativecommons.org/licenses/by-nc-sa/4.0
  ]
)

$body$