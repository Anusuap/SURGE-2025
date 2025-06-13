server <- function(input, output, session) {
  is_inside <- function(x, y) x^2 + y^2 < 1
  
  phi <- reactive({
    switch(input$phi_fun,
           "x^2" = function(x, y) x^2,
           "y^2" = function(x, y) y^2,
           "x^2 + y^2" = function(x, y) x^2 + y^2,
           "sin(pi*x)" = function(x, y) sin(pi * x),
           "cos(pi*y)" = function(x, y) cos(pi * y),
           "sin(pi*x)*cos(pi*y)" = function(x, y) sin(pi * x) * cos(pi * y),
           "exp(x*y)" = function(x, y) exp(x * y),
           "x^3 - y^3" = function(x, y) x^3 - y^3)
  })
  
  simulate_BM_to_boundary <- function(x0, y0, h = 0.01, max_steps = 10000) {
    x <- x0; y <- y0
    for (i in 1:max_steps) {
      x <- x + rnorm(1, 0, sqrt(h))
      y <- y + rnorm(1, 0, sqrt(h))
      if (!is_inside(x, y)) {
        norm <- sqrt(x^2 + y^2)
        x <- x / norm; y <- y / norm
        return(phi()(x, y))
      }
    }
    return(NA)
  }
  
  estimate_u <- function(x0, y0, n_sim = 300) {
    vals <- replicate(n_sim, simulate_BM_to_boundary(x0, y0))
    mean(vals, na.rm = TRUE)
  }
  
  vals <- reactiveValues(df = NULL)
  
  observeEvent(input$simulate, {
    req(input$x_range[1] < input$x_range[2], input$y_range[1] < input$y_range[2])
    
    xs <- seq(input$x_range[1], input$x_range[2], length.out = 40)
    ys <- seq(input$y_range[1], input$y_range[2], length.out = 40)
    
    total_points <- sum(mapply(is_inside, rep(xs, each = length(ys)), rep(ys, times = length(xs))))
    progress <- Progress$new(session, min = 0, max = total_points)
    progress$set(message = "Simulating Brownian motion...", value = 0)
    
    df <- expand.grid(x = xs, y = ys)
    df$u <- NA_real_
    
    count <- 0
    for (i in seq_len(nrow(df))) {
      if (is_inside(df$x[i], df$y[i])) {
        df$u[i] <- estimate_u(df$x[i], df$y[i], input$n_sim)
        count <- count + 1
        progress$inc(1, detail = paste("Point", count, "of", total_points))
      }
    }
    progress$close()
    
    vals$df <- na.omit(df)
  })
  
  output$heatmap <- renderPlot({
    req(vals$df)
    ggplot(vals$df, aes(x = x, y = y, fill = u)) +
      geom_tile(color = "#DDD", linewidth = 0.3) +
      coord_fixed() +
      scale_fill_distiller(palette = "Spectral", direction = 1, na.value = "transparent") +
      labs(title = paste("Heatmap of u(x,y) for φ(x,y) =", input$phi_fun),
           fill = "u(x, y)", x = "x", y = "y") +
      theme_minimal(base_size = 16) +
      theme(
        panel.background = element_rect(fill = bg_color),
        plot.background = element_rect(fill = bg_color),
        legend.key = element_rect(fill = "#FAF8F0"),
        plot.title = element_text(face = "bold", size = 20, color = text_color),
        axis.title = element_text(size = 14, face = "bold", color = text_color),
        axis.text = element_text(color = text_color)
      )
  })
  
  output$plot3d <- renderPlotly({
    req(vals$df)
    df <- vals$df
    xs <- sort(unique(df$x))
    ys <- sort(unique(df$y))
    zmat <- matrix(NA, nrow = length(xs), ncol = length(ys))
    
    for (i in 1:length(xs)) {
      for (j in 1:length(ys)) {
        val <- df %>% filter(abs(x - xs[i]) < 1e-6, abs(y - ys[j]) < 1e-6)
        if (nrow(val) > 0) {
          zmat[i, j] <- val$u[1]
        }
      }
    }
    
    plot_ly(x = xs, y = ys, z = ~zmat,
            type = "surface",
            colorscale = "Spectral",
            showscale = TRUE) %>%
      layout(title = paste("3D Surface of u(x,y) for ϕ(x,y) =", input$phi_fun),
             scene = list(
               xaxis = list(title = "x"),
               yaxis = list(title = "y"),
               zaxis = list(title = "u(x,y)")
             ))
  })
  
  output$click_value <- renderPrint({
    req(input$plot_click)
    click <- input$plot_click
    df <- vals$df
    if (is.null(df)) return(NULL)
    
    dist <- sqrt((df$x - click$x)^2 + (df$y - click$y)^2)
    nearest <- df[which.min(dist), ]
    
    cat(sprintf("Estimated u(%.2f, %.2f) = %.5f", nearest$x, nearest$y, nearest$u))
  })
}
