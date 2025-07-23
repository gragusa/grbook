#let book(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  abstract: none,
  abstract-title: none,
  paperheight: 9in,
  paperwidth: 8in,
  margin: (y: 7em, left: 4em, right: 18em),
  lang: "en",
  region: "US",
  font: "TeX Gyre Pagella",
  fontsize: 11pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: "TeX Gyre Pagella",
  heading-weight: "normal",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  sectionnumbering: "1.1",
  pagenumbering: "1",
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  set page(
    width: 8in,
    height: 9in,
    margin: (y: 7em, left: 4em, right: 18em),
    header: context {
      if here().page() != 1 {
        set text(font: "TeX Gyre Pagella", 
                 weight: "regular", size: 8pt, tracking: 1.1pt)
        place(right, dy: 6em, dx: 20em)[
          #smallcaps(title) #h(1em) #text(size: 11pt, counter(page).display())
        ]
      }
    }
  )
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)
  show heading: it => {
    set text(
      font: heading-family, 
      style: "italic",        // Make headings italic like Tufte
      weight: "regular",       // Normal weight, not bold
      size: if it.level == 1 { 1.4em } else if it.level == 2 { 1.2em } else { 1em }
    )
    
    // Add space before and after headings
    block(
      above: if it.level == 1 { 2em } else { 1.5em },
      below: if it.level == 1 { 1.75em } else { 1.25em }
    )[#it]
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  doc

}

#set table(
  inset: 6pt,
  stroke: none
)
