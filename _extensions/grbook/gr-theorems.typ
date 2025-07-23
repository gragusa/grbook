#import "@preview/ctheorems:1.1.3": *
#show: thmrules

// Enhanced example environment with lines and darker background
#let example = thmbox("example", "Example", 
  titlefmt: smallcaps, 
  bodyfmt: body => [
    #body #h(1fr) $square$ // float a QED symbol to the right
  ], 
  fill: rgb("#f3f1f1"),  // darker background
  stroke: (
    top: 1pt + black,     // line on top
    bottom: 1pt + black   // line at bottom
  )
)

#let exercise = thmbox("exercise", "Exercise")
