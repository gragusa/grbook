#import "@preview/drafting:0.2.2"
#import "@preview/marginalia:0.2.3" as marginalia: note, notefigure, wideblock

#show: marginalia.setup.with(
  inner: (far: 0mm, width: 4em, sep: 0em),
  outer: ( far: 3em, width: 13em, sep: 2em ),
  book: true,
)

#let a-note-counter = counter("a-note")
#let unote = note.with(
  numbering: none,
  anchor-numbering: none
)

#let note = note.with(
    numbering: (.., i) => text(font: "Inria Sans", fill: blue, size: 9pt)[#super[#i]#h(0.5em - 2pt)],
    anchor-numbering: (.., i) => super[#i],
)

#let footnote = note

// This take care of caption

#show figure.caption: it => {
  context {
    // Access the figure counter for the current figure kind
    let fig_counter = counter(figure.where(kind: it.kind))
    let current_num = fig_counter.get().first()
    
    note(
      numbering: none,
      anchor-numbering: none,
      dy: 1.5em
    )[
      // Style the "Figure/Table 1:" part
      #text(
        font: "TeX Gyre Pagella",
        size: 9pt,
        weight: "bold",           // Bold for the figure number
        fill: black
      )[#it.supplement #current_num:] 
      // Style the caption body text
      #text(
        font: "TeX Gyre Pagella",
        size: 9pt,
        style: "italic",          // Italic for the body text
        weight: "regular",
        fill: gray
      )[ #it.body]
    ]
  }
}

#let styled_show_caption = (number, caption) => {
  [
    // Style the "Figure/Table 1:" part
    #text(
      font: "TeX Gyre Pagella",
      size: 9pt,
      weight: "bold",           // Bold for the figure number
      fill: black
    )[#caption.supplement #caption.counter.display(caption.numbering):] 
    // Style the caption body text
    #text(
      font: "TeX Gyre Pagella",
      size: 9pt,
      style: "italic",          // Italic for the body text
      weight: "regular",
      fill: gray
    )[ #caption.body]
  ]
}

#let notefigure = notefigure.with(
  show-caption: styled_show_caption,
  // numbering: none,
  anchor-numbering: none)
