# Attach in the begining
library(shiny)
library(ggplot2)
library(plotly)
library(dplyr)
library(RColorBrewer)

# Pastel2 colors
pal <- brewer.pal(8, "Pastel2")
bg_color   <- pal[2]  # light green
grad1      <- pal[1]
grad2      <- pal[2]
text_color <- "#333333"
shadow     <- pal[6]
btn_color  <- pal[5]
btn_hover  <- pal[6]
accent1    <- pal[3]
accent2    <- pal[4]

# At the end attach
shinyApp(ui, server)

